#!/usr/bin/env bash
#
# sync-commands.sh — Command file sync logic.
# Compares upstream SKILL.md descriptions with local command frontmatter.
#
# Usage: source this file. Requires sync-core.sh, sync-frontmatter.sh sourced first.

source "${SCRIPTS_DIR}/lib/sync-frontmatter.sh"

# Analyze a single command's description against its upstream SKILL.md.
# Outputs JSON on stdout if there's a change to review.
analyze_command() {
  local repo_root="$1" state="$2" cmd_slug="$3" cmd_file="$4" upstream="$5"
  local full_upstream="$repo_root/$upstream"
  local full_cmd="$repo_root/$cmd_file"

  if [[ ! -f "$full_upstream" ]]; then
    # Upstream SKILL.md was removed!
    jq -nc --arg cmd "$cmd_slug" --arg file "$cmd_file" --arg upstream "$upstream" \
      '{type:"cmd-removed", command:$cmd, file:$file, upstream:$upstream}'
    return
  fi

  if [[ ! -f "$full_cmd" ]]; then
    jq -nc --arg cmd "$cmd_slug" --arg file "$cmd_file" \
      '{type:"cmd-missing", command:$cmd, file:$file, reason:"command file does not exist"}'
    return
  fi

  # Get current upstream frontmatter
  local new_name new_desc new_hash
  new_name=$(frontmatter_get "$full_upstream" "name" 2>/dev/null || echo "")
  new_desc=$(frontmatter_get "$full_upstream" "description" 2>/dev/null || echo "")
  new_hash=$(frontmatter_hash "$full_upstream" 2>/dev/null || echo "")

  # Get previously recorded frontmatter
  local old_name old_desc old_hash
  old_name=$(echo "$state" | jq -r ".skill_frontmatter[\"$upstream\"].name // empty" 2>/dev/null || echo "")
  old_desc=$(echo "$state" | jq -r ".skill_frontmatter[\"$upstream\"].description // empty" 2>/dev/null || echo "")
  old_hash=$(echo "$state" | jq -r ".skill_frontmatter[\"$upstream\"].sha256 // empty" 2>/dev/null || echo "")

  # Get current local description
  local cur_desc
  cur_desc=$(frontmatter_get "$full_cmd" "description" 2>/dev/null || echo "")

  # Check for changes
  local name_changed="false"
  if [[ -n "$old_name" && "$old_name" != "$new_name" ]]; then
    name_changed="true"
  fi

  if [[ "$old_hash" == "$new_hash" && "$name_changed" == "false" ]]; then
    # No change
    return
  fi

  # Emit the review item
  local escaped_old escaped_new escaped_cur
  escaped_old=$(echo "$old_desc" | sed 's/"/\\"/g')
  escaped_new=$(echo "$new_desc" | sed 's/"/\\"/g')
  escaped_cur=$(echo "$cur_desc" | sed 's/"/\\"/g')

  jq -nc \
    --arg type "cmd-desc" \
    --arg cmd "$cmd_slug" \
    --arg file "$cmd_file" \
    --arg upstream "$upstream" \
    --arg old_desc "$escaped_old" \
    --arg new_desc "$escaped_new" \
    --arg cur_desc "$escaped_cur" \
    --arg skill_name "$new_name" \
    --arg changed "$name_changed" \
    --arg old_hash "$old_hash" \
    --arg new_hash "$new_hash" \
    '{type:$type, command:$cmd, file:$file, upstream:$upstream,
      old_upstream_desc:$old_desc, new_upstream_desc:$new_desc,
      local_desc:$cur_desc, skill_name:$skill_name,
      name_changed:$changed, old_hash:$old_hash, new_hash:$new_hash}'
}

# Apply an accepted command description update.
# Replaces the description: line in the YAML frontmatter.
apply_command_description() {
  local repo_root="$1" cmd_file="$2" new_desc="$3"
  local full_path="$repo_root/$cmd_file"

  if [[ ! -f "$full_path" ]]; then
    echo "ERROR: cannot apply — file not found: $full_path" >&2
    return 1
  fi

  local tmpfile
  tmpfile=$(mktemp)
  local in_fm=0 replaced=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "---" ]]; then
      echo "$line"
      ((in_fm++))
      continue
    fi
    ((in_fm == 0)) && { echo "$line"; continue; }
    ((in_fm > 1)) && { echo "$line"; continue; }
    if [[ $replaced -eq 0 && "$line" =~ ^description: ]]; then
      echo "description: $new_desc"
      replaced=1
    else
      echo "$line"
    fi
  done < "$full_path" > "$tmpfile"

  if [[ $replaced -eq 1 ]]; then
    mv "$tmpfile" "$full_path"
  else
    rm -f "$tmpfile"
    echo "WARNING: could not find description line in $cmd_file" >&2
    return 1
  fi
}

# Analyze all commands from the mappings file.
# Outputs review items as JSON lines to stdout.
analyze_all_commands() {
  local repo_root="$1" state="$2"
  local mappings
  mappings=$(jq -c '.commands | to_entries[]' "$MAPPINGS_FILE" 2>/dev/null)

  echo "$mappings" | while read -r entry; do
    local cmd_slug cmd_file upstream
    cmd_slug=$(echo "$entry" | jq -r '.key')
    cmd_file=$(echo "$entry" | jq -r '.value.file')
    upstream=$(echo "$entry" | jq -r '.value.upstream')

    analyze_command "$repo_root" "$state" "$cmd_slug" "$cmd_file" "$upstream" 2>/dev/null
  done
}
