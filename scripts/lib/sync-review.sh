#!/usr/bin/env bash
#
# sync-review.sh — Interactive review UI for sync-upstream.
# No external dependencies beyond tput (terminal width).
#
# Usage: source this file, then call review_items.
# The caller provides an array of review items as JSON lines via stdin.

# ANSI color codes
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_RED='\033[31m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_CYAN='\033[36m'

# ── Output helpers ──────────────────────────────────────────────────────

color() { printf '%b' "$1$2$C_RESET"; }
green()  { color "$C_GREEN"  "$1"; }
yellow() { color "$C_YELLOW" "$1"; }
red()    { color "$C_RED"    "$1"; }
cyan()   { color "$C_CYAN"   "$1"; }
bold()   { color "$C_BOLD"   "$1"; }
dim()    { color "$C_DIM"    "$1"; }

# Print a horizontal rule
hr() {
  local width
  width=$(tput cols 2>/dev/null || echo 80)
  printf "%${width}s\n" "" | tr ' ' '─'
}

# ── Card renderers ───────────────────────────────────────────────────────

render_cmd_desc_card() {
  local cmd="$1" file="$2" upstream="$3" old_desc="$4" new_desc="$5" cur_desc="$6"
  local skill_name="$7" name_changed="$8"

  echo ""
  cyan "Command description: $(bold "$file")"
  echo ""
  echo "  Upstream: $(dim "$upstream")"
  if [[ "$name_changed" == "true" ]]; then
    yellow "  Skill name changed: $(red "$old_name") → $(green "$new_name")"
  else
    echo "  Skill name: $(green "$skill_name")  (unchanged)"
  fi
  echo ""

  if [[ -n "$old_desc" ]]; then
    echo "  $(dim 'Old upstream description:')"
    echo "    $(yellow "$old_desc")"
    echo ""
  fi

  echo "  $(dim 'Current upstream description:')"
  echo "    $(green "$new_desc")"
  echo ""

  echo "  $(dim 'Current local description:')"
  echo "    $(cyan "$cur_desc")"
  echo ""
}

render_skill_rename_card() {
  local old_name="$1" new_name="$2" upstream="$3"
  local affected_files="$4"

  echo ""
  yellow "Skill rename: $(red "$old_name") → $(green "$new_name")"
  echo ""
  echo "  Upstream: $(dim "$upstream")"
  echo "  Affected files:"
  echo "$affected_files" | while read -r f; do
    echo "    $(cyan "$f")"
  done
  echo ""
}

render_missing_path_card() {
  local path="$1" file="$2" reason="$3"

  echo ""
  red "Missing path: $(bold "$path")"
  echo ""
  echo "  Referenced by: $(cyan "$file")"
  echo "  Reason: $reason"
  echo ""
}

render_unmapped_card() {
  local skill_name="$1" upstream="$2"

  echo ""
  cyan "New unmapped skill: $(bold "$skill_name")"
  echo ""
  echo "  Upstream: $(dim "$upstream")"
  echo "  Action: add to $(cyan 'scripts/sync-mappings.json') if you want a command wrapper"
  echo ""
}

render_agent_orphan_card() {
  local skill_name="$1" agent_file="$2"

  echo ""
  red "Orphaned skill reference in agent: $(bold "$skill_name")"
  echo ""
  echo "  Agent file: $(cyan "$agent_file")"
  echo "  Reason: skill not found in any vendor submodule"
  echo ""
}

render_config_path_card() {
  local path="$1" exists="$2"

  echo ""
  if [[ "$exists" == "true" ]]; then
    echo "  $(green '✓') $path"
  else
    red "  Missing config path: $(bold "$path")"
  fi
}

# ── Interactive prompt ────────────────────────────────────────────────────

# Prompt the user for a decision. Returns 0=accept, 1=keep, 2=skip, 3=view, 4=quit.
prompt_decision() {
  local input
  printf '\n%b' "$(bold 'Action:') [$(green 'a')]ccept new  [$(yellow 'k')]eep current  [$(dim 's')]kip  [$(cyan 'v')]iew full diff  [$(red 'q')]uit "
  read -r -n 1 input
  echo ""
  case "$input" in
    a|A) return 0 ;;
    k|K) return 1 ;;
    s|S) return 2 ;;
    v|V) return 3 ;;
    q|Q) return 4 ;;
    *)   return 5 ;;  # invalid, re-prompt
  esac
}

prompt_binary() {
  local input
  printf '\n%b' "$(bold 'Action:') [$(green 'a')]pply all  [$(yellow 'r')]eview each  [$(dim 's')]kip "
  read -r -n 1 input
  echo ""
  case "$input" in
    a|A) return 0 ;;
    r|R) return 1 ;;
    s|S) return 2 ;;
    *)   return 3 ;;
  esac
}

# ── Main review loop ──────────────────────────────────────────────────────

# Takes: item_num, total, type, json_data_string
# Returns: 0=accepted, 1=kept, 2=skipped, 3=quit
review_one_item() {
  local num="$1" total="$2" type="$3" data="$4"

  while true; do
    # Clear screen and draw header
    printf '\033[2J\033[H'
    echo ""
    printf '  %s [%s/%s]' "$(bold 'sync-upstream')" "$num" "$total"
    hr

    # Render the card based on type
    case "$type" in
      cmd-desc)
        local cmd file upstream old_desc new_desc cur_desc skill_name name_changed
        cmd=$(echo "$data" | jq -r '.command // empty')
        file=$(echo "$data" | jq -r '.file // empty')
        upstream=$(echo "$data" | jq -r '.upstream // empty')
        old_desc=$(echo "$data" | jq -r '.old_upstream_desc // empty')
        new_desc=$(echo "$data" | jq -r '.new_upstream_desc // empty')
        cur_desc=$(echo "$data" | jq -r '.local_desc // empty')
        skill_name=$(echo "$data" | jq -r '.skill_name // empty')
        name_changed=$(echo "$data" | jq -r '.name_changed // "false"')
        render_cmd_desc_card "$cmd" "$file" "$upstream" "$old_desc" "$new_desc" "$cur_desc" "$skill_name" "$name_changed"
        prompt_decision
        ;;
      skill-rename)
        local old_name new_name upstream affected
        old_name=$(echo "$data" | jq -r '.old_name // empty')
        new_name=$(echo "$data" | jq -r '.new_name // empty')
        upstream=$(echo "$data" | jq -r '.upstream // empty')
        affected=$(echo "$data" | jq -r '.affected_files[]? // empty')
        render_skill_rename_card "$old_name" "$new_name" "$upstream" "$affected"
        prompt_binary
        ;;
      missing-path)
        local path file reason
        path=$(echo "$data" | jq -r '.path // empty')
        file=$(echo "$data" | jq -r '.file // empty')
        reason=$(echo "$data" | jq -r '.reason // empty')
        render_missing_path_card "$path" "$file" "$reason"
        prompt_binary
        ;;
      unmapped)
        local skill_name upstream
        skill_name=$(echo "$data" | jq -r '.skill_name // empty')
        upstream=$(echo "$data" | jq -r '.upstream // empty')
        render_unmapped_card "$skill_name" "$upstream"
        prompt_decision
        ;;
      agent-orphan)
        local skill_name agent_file
        skill_name=$(echo "$data" | jq -r '.skill_name // empty')
        agent_file=$(echo "$data" | jq -r '.agent_file // empty')
        render_agent_orphan_card "$skill_name" "$agent_file"
        prompt_decision
        ;;
      *)
        echo "Unknown review type: $type"
        return 2
        ;;
    esac

    local rc=$?
    case $rc in
      0) return 0 ;;  # accept
      1) return 1 ;;  # keep
      2) return 2 ;;  # skip
      3) return 3 ;;  # view
      4) return 4 ;;  # quit
      *) ;;           # re-prompt
    esac
  done
}

# Show a full diff of the upstream SKILL.md between old and new.
# This requires both old and new files to be accessible.
show_full_diff() {
  local data="$1"
  local upstream old_upstream new_upstream repo_root
  upstream=$(echo "$data" | jq -r '.upstream // empty')
  repo_root="$REPO_ROOT"

  printf '\033[2J\033[H'
  echo ""
  bold "Full upstream diff for: $upstream"
  hr

  # Try to show git diff in the submodule
  local sub_path="${upstream%%/*}"
  if [[ "$sub_path" == "vendor"* ]]; then
    sub_path="${upstream%%/skills*}"
    local old_hash new_hash
    old_hash=$(echo "$data" | jq -r '.old_hash // empty')
    new_hash=$(echo "$data" | jq -r '.new_hash // empty')
    if [[ -n "$old_hash" && -n "$new_hash" ]]; then
      (cd "$repo_root/$sub_path" && git diff "$old_hash" "$new_hash" -- "${upstream#$sub_path/}" 2>/dev/null) || echo "(diff not available)"
    else
      echo "(diff not available — run git fetch in vendor submodules first)"
    fi
  else
    echo "(diff not available)"
  fi

  echo ""
  printf '%b' "$(dim 'Press any key to return...')"
  read -r -n 1
}
