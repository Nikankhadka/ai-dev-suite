#!/usr/bin/env bash
set -euo pipefail

# Symlink this repo's skills into every harness's global skills directory.
#
# Claude Code reads ~/.claude/skills, Codex reads ~/.agents/skills. OpenCode
# reads the paths in opencode.jsonc directly and needs no symlinks, so the set
# linked here must stay in sync with `skills.paths` in that file.
#
# Not linked on purpose:
#   - taste-skill and hallmark: skills/frontend-design/SKILL.md loads them by
#     file path, so registering them as skills only costs context.
#   - in-progress: unblessed upstream work.
#   - git-guardrails-claude-code: patch-skills.sh produces the agent-agnostic
#     git-guardrails fork from it; linking both registers the same skill twice.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DESTS=("$HOME/.claude/skills" "$HOME/.agents/skills")
BACKUPS="$HOME/.ai-dev-suite-backups/$(date +%Y%m%d-%H%M%S)"

# Directories that contain skill folders (each holding a SKILL.md).
SOURCES=(
  "$REPO/vendor/mattpocock-skills/skills/engineering"
  "$REPO/vendor/mattpocock-skills/skills/productivity"
  "$REPO/vendor/mattpocock-skills/skills/misc"
  "$REPO/vendor/lavish-axi/skills"
  "$REPO/vendor/no-mistakes/skills"
  "$REPO/vendor/gnhf/skills"
  "$REPO/vendor/axi/.agents/skills"
  "$REPO/vendor/firstmate/skills"
  "$REPO/vendor/ponytail/skills"
  "$REPO/skills"
)

SKIP=("git-guardrails-claude-code")

should_skip() {
  local name="$1"
  for s in "${SKIP[@]}"; do [ "$name" = "$s" ] && return 0; done
  return 1
}

# Every skill name this run intends to link, resolved before anything is
# written so the prune pass knows what is still wanted.
WANTED=()
for source in "${SOURCES[@]}"; do
  [ -d "$source" ] || { echo "Skipping missing source: $source"; continue; }
  for skill_dir in "$source"/*/; do
    [ -f "$skill_dir/SKILL.md" ] || continue
    name="$(basename "$skill_dir")"
    should_skip "$name" && continue
    WANTED+=("$name")
  done
done

is_wanted() {
  local name="$1"
  for w in "${WANTED[@]}"; do [ "$name" = "$w" ] && return 0; done
  return 1
}

# Remove links this repo owns that no longer resolve. Links pointing outside
# this repo belong to something else and are left alone. A link this repo owns
# that is not in the wanted set is left over from an earlier layout, from a
# source that has since been dropped, or from a skill that was renamed.
prune_dest() {
  local dest="$1"
  [ -d "$dest" ] || return 0
  local entry name target reason
  for entry in "$dest"/*; do
    [ -L "$entry" ] || continue
    name="$(basename "$entry")"
    target="$(readlink "$entry")"
    case "$target" in
      "$REPO"/*) ;;
      *) continue ;;
    esac

    reason=""
    [ -e "$entry" ] || reason="dangling"
    is_wanted "$name" || reason="${reason:-no longer linked}"

    if [ -n "$reason" ]; then
      rm -f "$entry"
      echo "  pruned $name ($reason)"
    fi
  done
}

# `ln -sfn <dir> <existing-dir>` links *into* the directory instead of
# replacing it, which silently shadows the real skill with a stale copy.
link_skill() {
  local src="$1" dest_dir="$2" name="$3"
  local dest="$dest_dir/$name"

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    # One backup subdirectory per destination, so the same skill name coming
    # from two harnesses does not collide.
    local tag backup_dir
    tag="$(basename "$(dirname "$dest_dir")")"
    backup_dir="$BACKUPS/$tag"
    mkdir -p "$backup_dir"
    mv "$dest" "$backup_dir/$name"
    echo "  moved real $name aside -> $backup_dir/$name"
  fi

  rm -f "$dest"
  ln -sfn "$src" "$dest"
}

echo "Pruning stale links..."
for dest in "${DESTS[@]}"; do
  mkdir -p "$dest"
  prune_dest "$dest"
done

echo "Linking skills..."
count=0
for source in "${SOURCES[@]}"; do
  [ -d "$source" ] || continue
  for skill_dir in "$source"/*/; do
    [ -f "$skill_dir/SKILL.md" ] || continue
    name="$(basename "$skill_dir")"
    should_skip "$name" && continue
    for dest in "${DESTS[@]}"; do
      link_skill "${skill_dir%/}" "$dest" "$name"
    done
    count=$((count + 1))
    echo "  $name"
  done
done

echo "Done. $count skills linked into ${DESTS[*]}"
