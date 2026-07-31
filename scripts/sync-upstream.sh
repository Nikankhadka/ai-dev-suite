#!/usr/bin/env bash
#
# sync-upstream.sh — Interactive guided update for the AI Dev Suite.
#
# Detects when vendor git submodules have upstream changes, maps them to
# affected local files (commands, agents, local skills, docs, config),
# and lets you approve/reject each change one at a time.
#
# Usage:
#   ./scripts/sync-upstream.sh              # Interactive mode
#   ./scripts/sync-upstream.sh --dry-run    # Show changes, don't modify files
#   ./scripts/sync-upstream.sh --yes        # Non-interactive, apply all well-defined changes
#   ./scripts/sync-upstream.sh --phase <n>  # Run only one phase (detect|analyze|review|apply)
#
# Options:
#   --dry-run   Show all proposed changes but modify no files
#   --yes       Skip prompts, apply all well-defined changes automatically
#   --phase N   Run only the specified phase (1-4 or detect|analyze|review|apply)
#   --help      Show this help

set -euo pipefail

# ── Resolve paths ────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR"
REPO_ROOT=$(cd "$SCRIPTS_DIR/.." && pwd)

# Source library files
source "$SCRIPTS_DIR/lib/sync-frontmatter.sh"
source "$SCRIPTS_DIR/lib/sync-core.sh"
source "$SCRIPTS_DIR/lib/sync-review.sh"
source "$SCRIPTS_DIR/lib/sync-commands.sh"
source "$SCRIPTS_DIR/lib/sync-agents.sh"
source "$SCRIPTS_DIR/lib/sync-local-skills.sh"
source "$SCRIPTS_DIR/lib/sync-docs.sh"
source "$SCRIPTS_DIR/lib/sync-config.sh"

# ── Argument parsing ─────────────────────────────────────────────────────

DRY_RUN=false
YES_MODE=false
PHASE="all"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--dry-run] [--yes] [--phase detect|analyze|review|apply]

Options:
  --dry-run   Show proposed changes but modify no files
  --yes       Non-interactive: apply all well-defined changes automatically
  --phase N   Run only phase: detect, analyze, review, or apply
  --help      Show this help

Phases:
  detect   Compare submodule HEADs with recorded state, find changed SKILL.md files
  analyze  Map changed SKILL.md files to affected local files
  review   Interactive review of each change
  apply    Write accepted changes to local files and update state
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --yes)     YES_MODE=true; shift ;;
    --phase)
      PHASE="$2"
      shift 2
      ;;
    --help)    usage; exit 0 ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

# ── Preflight checks ─────────────────────────────────────────────────────

if [[ ! -f "$MAPPINGS_FILE" ]]; then
  echo "ERROR: sync-mappings.json not found at $MAPPINGS_FILE" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "ERROR: jq is required but not installed." >&2
  echo "Install with: brew install jq  (macOS) or apt-get install jq (Linux)" >&2
  exit 1
fi

cd "$REPO_ROOT"

# ── Summary counters ─────────────────────────────────────────────────────

TOTAL_ITEMS=0
ACCEPTED=0
KEPT=0
SKIPPED=0
MODIFIED_FILES=()

# ── Phase 1: DETECT ──────────────────────────────────────────────────────

phase_detect() {
  echo ""
  echo "  $(bold 'Phase 1/4: Detect') — Comparing submodules against last-known state..."
  echo ""

  if [[ ! -f "$STATE_FILE" ]]; then
    echo "  $(yellow 'First run.') Initializing state file from current submodule HEADs..."
    init_state "$REPO_ROOT" > "$STATE_FILE"
    echo "  $(green 'State file created') at scripts/sync-state.json"
    echo ""
    echo "  Run again after $(cyan 'git pull --recurse-submodules') to detect upstream changes."
    exit 0
  fi

  local state
  state=$(load_state)

  # Check for submodule changes
  local changes
  changes=$(detect_submodule_changes "$REPO_ROOT" "$state")

  if [[ -z "$changes" ]]; then
    echo "  $(green 'No submodule changes detected.') Already up to date."
    exit 0
  fi

  # Process changes
  local changed_count=0
  local changed_skills=""
  echo "$changes" | while IFS='|' read -r status sub_path old_hash new_hash; do
    changed_count=$((changed_count + 1))
    echo "  $(yellow 'Changed:') $sub_path ($old_hash → $new_hash)"

    # Find changed SKILL.md files
    local skill_changes
    skill_changes=$(changed_skills_in_submodule "$REPO_ROOT" "$sub_path" "$old_hash" "$new_hash" 2>/dev/null || true)
    echo "$skill_changes" | while IFS='|' read -r s_status s_file; do
      case "$s_status" in
        A|M) echo "    $(green '+') $s_file (modified)" ;;
        D)   echo "    $(red '-') $s_file (removed)"    ;;
        R*)  echo "    $(yellow '~') $s_file (renamed)"   ;;
      esac
    done

    # Save changed skills for phase 2
    echo "$skill_changes" >> "$TMPDIR/sync-changed-skills.txt"
  done

  echo ""
  echo "  $(bold 'Detect complete.') Run with $(cyan '--phase analyze') or the full pipeline to continue."
}

# ── Phase 2: ANALYZE ─────────────────────────────────────────────────────

phase_analyze() {
  local state output_file="$TMPDIR/sync-review-items.jsonl"
  state=$(load_state)

  echo ""
  echo "  $(bold 'Phase 2/4: Analyze') — Mapping changes to affected local files..."
  echo ""

  # Build skill registry for cross-referencing
  local registry
  registry=$(build_skill_registry "$REPO_ROOT")

  > "$output_file"  # Clear output file

  # 1. Analyze command descriptions
  echo "  Checking command descriptions..."
  analyze_all_commands "$REPO_ROOT" "$state" >> "$output_file" 2>/dev/null || true

  # 2. Analyze agent skill lists
  echo "  Checking agent skill lists..."
  analyze_all_agents "$REPO_ROOT" "$state" "$registry" >> "$output_file" 2>/dev/null || true

  # 3. Verify local skill vendor paths
  echo "  Checking local skill vendor references..."
  analyze_local_skills "$REPO_ROOT" >> "$output_file" 2>/dev/null || true

  # 4. Check doc references
  echo "  Checking documentation references..."
  analyze_docs "$REPO_ROOT" "$registry" >> "$output_file" 2>/dev/null || true

  # 5. Check config paths
  echo "  Checking opencode.jsonc paths..."
  analyze_config "$REPO_ROOT" >> "$output_file" 2>/dev/null || true

  # 6. Discover unmapped vendor skills (only ones changed since last sync)
  echo "  Discovering unmapped skills..."
  local mapped_upstreams prev_frontmatter all_skill_paths
  mapped_upstreams=$(jq -r '.commands[].upstream // empty' "$MAPPINGS_FILE" 2>/dev/null | sort -u)
  prev_frontmatter=$(echo "$state" | jq -r '.skill_frontmatter | keys[]' 2>/dev/null || true)
  all_skill_paths=$(echo "$registry" | cut -d'|' -f2 | sort -u)

  echo "$all_skill_paths" | while read -r skill_path; do
    if echo "$mapped_upstreams" | grep -qxF "$skill_path" 2>/dev/null; then
      continue
    fi
    if echo "$prev_frontmatter" | grep -qxF "$skill_path" 2>/dev/null; then
      continue
    fi
    local skill_name
    skill_name=$(echo "$registry" | grep "|$skill_path\$" | head -1 | cut -d'|' -f1)
    if [[ -n "$skill_name" ]]; then
      jq -nc --arg type "unmapped" --arg skill_name "$skill_name" --arg upstream "$skill_path" \
        '{type:$type, skill_name:$skill_name, upstream:$upstream}' >> "$output_file"
    fi
  done

  local item_count
  item_count=$(wc -l < "$output_file" | tr -d ' ')
  echo ""
  echo "  $(bold 'Analyze complete.') $item_count items flagged for review."
}

# ── Phase 3: REVIEW ──────────────────────────────────────────────────────

phase_review() {
  local input_file="$TMPDIR/sync-review-items.jsonl"

  if [[ ! -f "$input_file" || ! -s "$input_file" ]]; then
    echo "  $(yellow 'No items to review.') Run $(cyan '--phase analyze') first."
    exit 0
  fi

  echo ""
  echo "  $(bold 'Phase 3/4: Review') — Interactive review of each change..."
  echo ""

  # If stdin is not a TTY, switch to non-interactive mode
  if [[ ! -t 0 ]]; then
    echo "  $(yellow 'No TTY detected.') Switching to non-interactive mode."
    YES_MODE=true
  fi

  TOTAL_ITEMS=$(wc -l < "$input_file" | tr -d ' ')

  local num=1
  while IFS= read -r item; do
    if [[ -z "$item" ]]; then continue; fi

    local type
    type=$(echo "$item" | jq -r '.type // empty')

    # Types that can be auto-applied (well-defined changes)
    local auto_types="cmd-desc skill-rename agent-orphan config-path-missing config-no-paths vendor-ref-missing doc-stale-ref"

    if [[ "$YES_MODE" == "true" ]]; then
      if echo "$auto_types" | grep -qw "$type"; then
        ACCEPTED=$((ACCEPTED + 1))
        if [[ "$DRY_RUN" != "true" ]]; then
          apply_item "$item"
        fi
      else
        # Informational: just report
        case "$type" in
          unmapped)
            local sn up
            sn=$(echo "$item" | jq -r '.skill_name // "unknown"')
            up=$(echo "$item" | jq -r '.upstream // "unknown"')
            echo "  $(dim '[new]') New skill: $(cyan "$sn") at $(dim "$up") — add to sync-mappings.json if needed"
            ;;
          cmd-removed|cmd-missing|agent-missing|doc-missing|local-skill-missing)
            echo "$item" | jq -r '"  " + "\u001b[31m[\(.type)]\u001b[0m" + " \(.file // .skill // "")"'
            ;;
          config-path-ok)
            ;;  # silent — paths that exist
          *)
            echo "  $(dim "[$type]") $(echo "$item" | jq -r '.skill_name // .path // .file // ""' 2>/dev/null)"
            ;;
        esac
        SKIPPED=$((SKIPPED + 1))
      fi
    else
      # Interactive mode
      review_one_item "$num" "$TOTAL_ITEMS" "$type" "$item" </dev/tty
      local rc=$?
      case $rc in
        0) ACCEPTED=$((ACCEPTED + 1))
           if [[ "$DRY_RUN" != "true" ]]; then
             apply_item "$item"
           fi
           ;;
        1) KEPT=$((KEPT + 1)) ;;
        2) SKIPPED=$((SKIPPED + 1)) ;;
        3) ;; # view — handled inside review loop
        4) echo ""; echo "  $(yellow 'Review stopped by user.')"; break ;;
      esac
    fi

    num=$((num + 1))
  done < "$input_file"
}

# Apply a single accepted item to the local files
apply_item() {
  local item="$1"
  local type
  type=$(echo "$item" | jq -r '.type')

  case "$type" in
    cmd-desc)
      local cmd_file new_desc
      cmd_file=$(echo "$item" | jq -r '.file')
      new_desc=$(echo "$item" | jq -r '.new_upstream_desc')
      apply_command_description "$REPO_ROOT" "$cmd_file" "$new_desc"
      MODIFIED_FILES+=("$cmd_file")
      echo "    $(green 'Applied:') $cmd_file"
      ;;
    skill-rename)
      local old_name new_name
      old_name=$(echo "$item" | jq -r '.old_name')
      new_name=$(echo "$item" | jq -r '.new_name')
      # Apply renames to all agent files and docs
      local agent_files
      agent_files=$(echo "$item" | jq -r '.affected_files[]?' 2>/dev/null || true)
      for af in $agent_files; do
        apply_agent_skill_rename "$REPO_ROOT" "$af" "$old_name" "$new_name"
        MODIFIED_FILES+=("$af")
        echo "    $(green 'Applied:') $af"
      done
      ;;
    agent-orphan)
      local agent_file skill_name
      agent_file=$(echo "$item" | jq -r '.file')
      skill_name=$(echo "$item" | jq -r '.skill_name')
      apply_agent_remove_skill "$REPO_ROOT" "$agent_file" "$skill_name"
      MODIFIED_FILES+=("$agent_file")
      echo "    $(green 'Removed orphan from:') $agent_file"
      ;;
    config-path-missing)
      local path
      path=$(echo "$item" | jq -r '.path')
      apply_config_remove_path "$REPO_ROOT" "$path"
      MODIFIED_FILES+=("opencode.jsonc")
      echo "    $(green 'Removed path from opencode.jsonc:') $path"
      ;;
    config-no-paths|config-path-ok|vendor-ref-missing|doc-stale-ref)
      echo "    $(dim 'Review item — may need manual update')"
      ;;
    *)
      echo "    $(dim 'No action for type:') $type"
      ;;
  esac
}

# ── Phase 4: APPLY ───────────────────────────────────────────────────────

phase_apply() {
  echo ""
  echo "  $(bold 'Phase 4/4: Apply') — Writing changes and updating state..."

  if [[ "$DRY_RUN" == "true" ]]; then
    echo ""
    echo "  $(yellow 'DRY RUN') — No files were modified."
  else
    # Update state file with new submodule hashes and frontmatter
    init_state "$REPO_ROOT" > "$STATE_FILE"
    echo "  $(green 'State file updated') at scripts/sync-state.json"
  fi

  # Print summary
  echo ""
  hr
  echo ""
  echo "  $(bold 'Sync summary:')"
  echo "    Items reviewed:  $TOTAL_ITEMS"
  echo "    Accepted:        $(green "$ACCEPTED")"
  echo "    Kept current:    $(yellow "$KEPT")"
  echo "    Skipped:         $(dim "$SKIPPED")"
  if [[ ${#MODIFIED_FILES[@]} -gt 0 ]]; then
    echo "    Files modified:  ${#MODIFIED_FILES[@]}"
    for f in "${MODIFIED_FILES[@]}"; do
      echo "      $(cyan "$f")"
    done
  fi
  echo ""
  if [[ "$DRY_RUN" != "true" ]]; then
    echo "  Run $(cyan 'git diff') to review changes before committing."
  fi
  echo ""
}

# ── Main ───────────────────────────────────────────────────────────────────

main() {
  echo ""
  hr
  echo ""
  echo "  $(bold 'sync-upstream') — AI Dev Suite upstream change detector"
  echo "  $(dim "$REPO_ROOT")"
  echo ""

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "  $(yellow 'DRY RUN MODE') — No files will be modified."
  fi
  if [[ "$YES_MODE" == "true" ]]; then
    echo "  $(yellow 'NON-INTERACTIVE MODE') — All changes applied automatically."
  fi

  TMPDIR=$(mktemp -d)
  trap 'rm -rf "$TMPDIR"' EXIT

  case "$PHASE" in
    detect|1)
      phase_detect
      ;;
    analyze|2)
      phase_analyze
      ;;
    review|3)
      phase_review
      ;;
    apply|4)
      phase_apply
      ;;
    all)
      phase_detect
      phase_analyze
      phase_review
      phase_apply
      ;;
    *)
      echo "ERROR: unknown phase '$PHASE'" >&2
      exit 1
      ;;
  esac
}

main
