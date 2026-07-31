#!/usr/bin/env bash
#
# sync-local-skills.sh — Verify vendor paths referenced by local skills.
#
# Usage: source this file. Requires sync-core.sh sourced first.

# Verify vendor paths referenced by local skills.
# Outputs review items as JSON lines.
analyze_local_skills() {
  local repo_root="$1"

  local skills
  skills=$(jq -c '.local_skills | to_entries[]' "$MAPPINGS_FILE" 2>/dev/null)

  echo "$skills" | while read -r entry; do
    local skill_name skill_file
    skill_name=$(echo "$entry" | jq -r '.key')
    skill_file=$(echo "$entry" | jq -r '.value.file')
    local full_path="$repo_root/$skill_file"

    if [[ ! -f "$full_path" ]]; then
      jq -nc --arg type "local-skill-missing" --arg skill "$skill_name" --arg file "$skill_file" \
        '{type:$type, skill:$skill, file:$file, reason:"local skill file does not exist"}'
      continue
    fi

    # Check each vendor reference
    local refs
    refs=$(echo "$entry" | jq -r '.value.vendor_refs[]?')
    for ref in $refs; do
      local full_ref="$repo_root/$ref"
      if [[ ! -f "$full_ref" ]]; then
        jq -nc --arg type "vendor-ref-missing" --arg skill "$skill_name" \
          --arg file "$skill_file" --arg ref "$ref" \
          '{type:$type, skill:$skill, file:$file, ref:$ref,
            reason:"referenced vendor SKILL.md not found"}'
      fi
    done
  done
}
