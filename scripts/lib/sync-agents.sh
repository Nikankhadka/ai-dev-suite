#!/usr/bin/env bash
#
# sync-agents.sh — Agent file sync logic.
# Verifies that each agent's "Available skills" list matches vendor reality.
#
# Usage: source this file. Requires sync-core.sh sourced first.

# Analyze agent skill lists against the vendor skill registry.
# Outputs review items as JSON lines.
analyze_all_agents() {
  local repo_root="$1" state="$2" registry="$3"

  # Build a set of known skill names from the registry
  local known_names
  known_names=$(echo "$registry" | cut -d'|' -f1 | sort -u)

  local agents
  agents=$(jq -c '.agents | to_entries[]' "$MAPPINGS_FILE" 2>/dev/null)

  echo "$agents" | while read -r entry; do
    local agent_name agent_file
    agent_name=$(echo "$entry" | jq -r '.key')
    agent_file=$(echo "$entry" | jq -r '.value.file')
    local full_path="$repo_root/$agent_file"

    if [[ ! -f "$full_path" ]]; then
      jq -nc --arg type "agent-missing" --arg agent "$agent_name" --arg file "$agent_file" \
        '{type:$type, agent:$agent, file:$file, reason:"agent file does not exist"}'
      continue
    fi

    # Extract skill names from the agent's "Available skills" section
    local listed_skills
    listed_skills=$(extract_agent_skills "$full_path")

    # Check each listed skill exists
    local skill
    for skill in $listed_skills; do
      if ! echo "$known_names" | grep -qxF "$skill"; then
        # Skill not found in any vendor
        jq -nc --arg type "agent-orphan" --arg agent "$agent_name" \
          --arg file "$agent_file" --arg skill_name "$skill" \
          '{type:$type, agent:$agent, file:$file, skill_name:$skill_name,
            reason:"skill not found in any vendor submodule"}'
      fi
    done
  done
}

# Extract skill names from an agent file's "Available skills" section.
# Looks for `- \`skill-name\`` patterns in bullet points.
extract_agent_skills() {
  local file="$1"
  local in_section=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Detect section start
    if [[ "$line" =~ ^#[[:space:]]*Available\ skills ]]; then
      in_section=1
      continue
    fi
    # Detect next section
    if ((in_section == 1)) && [[ "$line" =~ ^#[[:space:]] && ! "$line" =~ ^#[[:space:]]*Available\ skills ]]; then
      in_section=0
      continue
    fi
    if ((in_section == 1)) && [[ "$line" =~ ^#[[:space:]]*## ]]; then
      in_section=0
      continue
    fi

    # Extract `skill-name` from bullet points
    if ((in_section == 1)) && [[ "$line" =~ \`([a-zA-Z0-9_-]+)\` ]]; then
      echo "${BASH_REMATCH[1]}"
    fi
  done < "$file"
}

# Apply a skill rename in an agent file.
# Replaces `old-name` with `new-name` in backtick-quoted skill names
# within the "Available skills" section.
apply_agent_skill_rename() {
  local repo_root="$1" agent_file="$2" old_name="$3" new_name="$4"
  local full_path="$repo_root/$agent_file"

  if [[ ! -f "$full_path" ]]; then
    return 1
  fi

  local tmpfile
  tmpfile=$(mktemp)
  local in_section=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^#[[:space:]]*Available\ skills ]]; then
      in_section=1
    elif ((in_section == 1)) && [[ "$line" =~ ^#[[:space:]] && ! "$line" =~ ^#[[:space:]]*Available\ skills ]]; then
      in_section=0
    elif ((in_section == 1)) && [[ "$line" =~ ^#[[:space:]]*## ]]; then
      in_section=0
    fi

    if ((in_section == 1)); then
      # Replace `old-name` with `new-name` only within backticks in the skills section
      line="${line//\`$old_name\`/\`$new_name\`}"
    fi

    echo "$line"
  done < "$full_path" > "$tmpfile"

  mv "$tmpfile" "$full_path"
}

# Remove an orphaned skill reference from an agent file.
apply_agent_remove_skill() {
  local repo_root="$1" agent_file="$2" skill_name="$3"
  local full_path="$repo_root/$agent_file"

  if [[ ! -f "$full_path" ]]; then
    return 1
  fi

  local tmpfile
  tmpfile=$(mktemp)

  grep -v "\`$skill_name\`" "$full_path" > "$tmpfile" 2>/dev/null || true
  mv "$tmpfile" "$full_path"
}
