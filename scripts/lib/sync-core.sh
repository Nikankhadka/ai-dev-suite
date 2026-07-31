#!/usr/bin/env bash
#
# sync-core.sh — Submodule change detection and state file I/O.
# Depends on: sync-frontmatter.sh
#
# Usage: source this file from sync-upstream.sh (sets SCRIPTS_DIR first).

source "${SCRIPTS_DIR}/lib/sync-frontmatter.sh"

# ── State file ──────────────────────────────────────────────────────────

STATE_FILE="${SCRIPTS_DIR}/sync-state.json"
MAPPINGS_FILE="${SCRIPTS_DIR}/sync-mappings.json"

# Load state file; return 1 if it doesn't exist.
load_state() {
  if [[ ! -f "$STATE_FILE" ]]; then
    return 1
  fi
  cat "$STATE_FILE"
}

# Save state (JSON string piped in via stdin).
save_state() {
  cat > "$STATE_FILE"
}

# Create initial state file from current submodule HEADs and SKILL.md frontmatter.
init_state() {
  local repo_root="$1"
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  echo '{'
  echo '  "version": 1,'
  echo '  "submodules": {'
  local first_sub=true
  for sub_path in $(cd "$repo_root" && jq -r '.submodules | keys[]' "$MAPPINGS_FILE" 2>/dev/null || true); do
    local head
    head=$(cd "$repo_root/$sub_path" 2>/dev/null && git rev-parse HEAD 2>/dev/null || echo "unknown")
    if $first_sub; then first_sub=false; else echo ','; fi
    printf '    "%s": "%s"' "$sub_path" "$head"
  done
  echo ''
  echo '  },'

  echo '  "skill_frontmatter": {'
  local first_skill=true
  # Scan all known upstream paths from mappings
  local upstreams
  upstreams=$(cd "$repo_root" && jq -r '.commands[]?.upstream // empty' "$MAPPINGS_FILE" 2>/dev/null | sort -u)
  for up in $upstreams; do
    local full_path="$repo_root/$up"
    if [[ -f "$full_path" ]]; then
      local snap
      snap=$(frontmatter_snapshot "$full_path")
      if $first_skill; then first_skill=false; else echo ','; fi
      printf '    "%s": %s' "$up" "$snap"
    fi
  done
  echo ''
  echo '  },'

  echo '  "last_sync": "'"$timestamp"'"'
  echo '}'
}

# ── Submodule change detection ──────────────────────────────────────────

# Get current HEAD of a submodule.
submodule_head() {
  local repo_root="$1" sub_path="$2"
  cd "$repo_root/$sub_path" 2>/dev/null && git rev-parse HEAD 2>/dev/null || echo "none"
}

# Get previously recorded HEAD for a submodule from state.
submodule_prev_head() {
  local state="$1" sub_path="$2"
  echo "$state" | jq -r ".submodules[\"$sub_path\"] // empty" 2>/dev/null || echo ""
}

# Compare submodule state vs. recorded state.
# Outputs lines: CHANGED|<sub_path>|<old_hash>|<new_hash>
detect_submodule_changes() {
  local repo_root="$1" state="$2"
  local mappings sub_paths

  sub_paths=$(echo "$state" | jq -r '.submodules | keys[]' 2>/dev/null)
  for sub_path in $sub_paths; do
    local prev new
    prev=$(submodule_prev_head "$state" "$sub_path")
    new=$(submodule_head "$repo_root" "$sub_path")

    if [[ "$prev" == "" ]]; then
      echo "NEW|$sub_path||$new"
    elif [[ "$prev" != "$new" ]]; then
      echo "CHANGED|$sub_path|$prev|$new"
    fi
  done
}

# List changed SKILL.md files within a submodule between two commits.
# Outputs lines: A|path  or  M|path  or  D|path
changed_skills_in_submodule() {
  local repo_root="$1" sub_path="$2" old_hash="$3" new_hash="$4"
  local sub_dir="$repo_root/$sub_path"

  if [[ ! -d "$sub_dir/.git" ]]; then
    return 1
  fi

  # git diff --name-status between the two commits
  # First try with --submodule=log if it's a submodule diff
  cd "$repo_root" && git diff --name-status "$old_hash" "$new_hash" -- "$sub_path" 2>/dev/null | while IFS=$'\t' read -r status file; do
    if [[ "$file" == *SKILL.md || "$file" == *SKILL.md ]]; then
      echo "$status|$file"
    fi
  done

  # Also check within the submodule itself
  if (cd "$sub_dir" && git rev-parse "$old_hash" &>/dev/null && git rev-parse "$new_hash" &>/dev/null); then
    (cd "$sub_dir" && git diff --name-status "$old_hash" "$new_hash" -- '*SKILL.md' 2>/dev/null) | while IFS=$'\t' read -r status file; do
      echo "$status|$sub_path/$file"
    done
  fi
}

# Build a registry of all vendor skills: name → path
# Outputs: <name>|<path>
build_skill_registry() {
  local repo_root="$1"
  local sub_paths mappings_file="$MAPPINGS_FILE"

  sub_paths=$(cd "$repo_root" && jq -r '.submodules | keys[]' "$mappings_file" 2>/dev/null)
  for sub_path in $sub_paths; do
    local full="$repo_root/$sub_path"
    if [[ -d "$full" ]]; then
      find "$full" -name 'SKILL.md' -type f 2>/dev/null | while read -r skill_md; do
        local name
        name=$(frontmatter_get "$skill_md" "name" 2>/dev/null || true)
        if [[ -n "$name" ]]; then
          # Make path relative to repo root
          local rel="${skill_md#$repo_root/}"
          echo "$name|$rel"
        fi
      done
    fi
  done
}

# ── Utility ──────────────────────────────────────────────────────────────

# Check if a submodule directory is dirty (has uncommitted changes).
submodule_is_dirty() {
  local repo_root="$1" sub_path="$2"
  local sub_dir="$repo_root/$sub_path"
  if [[ ! -d "$sub_dir/.git" ]]; then
    return 1
  fi
  cd "$sub_dir" && ! git diff-index --quiet HEAD -- 2>/dev/null
}

# Get the repo root (directory containing .gitmodules).
find_repo_root() {
  local dir="${1:-$(pwd)}"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.gitmodules" ]]; then
      echo "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}
