#!/usr/bin/env bash
#
# sync-docs.sh — Verify skill and command references in documentation.
#
# Usage: source this file. Requires sync-core.sh sourced first.

# Verify skill and command names referenced in documentation files.
# Outputs review items as JSON lines.
analyze_docs() {
  local repo_root="$1" registry="$2"

  # Build sets of known names
  local known_skills known_commands
  known_skills=$(echo "$registry" | cut -d'|' -f1 | sort -u)
  known_commands=$(cd "$repo_root/.opencode/command" && ls *.md 2>/dev/null | sed 's/\.md$//' | sort -u)
  known_commands+=$'\n'"$(echo "$known_skills" | grep -v '^$' || true)"  # commands are named after skills too

  local docs
  docs=$(jq -c '.docs | to_entries[]' "$MAPPINGS_FILE" 2>/dev/null)

  echo "$docs" | while read -r entry; do
    local doc_file
    doc_file=$(echo "$entry" | jq -r '.key')
    local full_path="$repo_root/$doc_file"

    if [[ ! -f "$full_path" ]]; then
      jq -nc --arg type "doc-missing" --arg file "$doc_file" \
        '{type:$type, file:$file, reason:"documentation file does not exist"}'
      continue
    fi

    # Extract quoted backtick references like `skill-name`
    local refs
    refs=$(grep -oE '\`[a-zA-Z][a-zA-Z0-9_-]*\`' "$full_path" | sed 's/`//g' | sort -u)

    local skill
    for skill in $refs; do
      # Skip short/common words that aren't skill names
      if [[ ${#skill} -lt 3 ]]; then continue; fi

      # Check if it's a known skill or command, but only if it looks like one
      local is_skill=false is_cmd=false
      echo "$known_skills" | grep -qxF "$skill" 2>/dev/null && is_skill=true
      echo "$known_commands" | grep -qxF "$skill" 2>/dev/null && is_cmd=true

      # We only flag items that look like they might be skill/command names
      # (contain hyphens or are in a known format)
      if [[ "$skill" =~ [-] || "$skill" =~ ^(tdd|lavish|gnhf|ponytail|hallmark|axi) ]]; then
        if ! $is_skill && ! $is_cmd; then
          jq -nc --arg type "doc-stale-ref" --arg file "$doc_file" --arg ref "$skill" \
            '{type:$type, file:$file, ref:$ref,
              reason:"referenced name not found in known skills or commands — may be stale"}'
        fi
      fi
    done
  done
}
