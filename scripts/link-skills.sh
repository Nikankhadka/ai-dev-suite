#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DESTS=("$HOME/.claude/skills" "$HOME/.agents/skills")
VENDOR_SKILLS="$REPO/vendor/mattpocock-skills/skills"
LOCAL_SKILLS="$REPO/skills"

link_vendor() {
  local bucket="$1"
  for skill_dir in "$VENDOR_SKILLS/$bucket"/*/; do
    [ -d "$skill_dir" ] || continue
    local name="$(basename "$skill_dir")"
    for DEST in "${DESTS[@]}"; do
      mkdir -p "$DEST"
      ln -sfn "$skill_dir" "$DEST/$name"
      echo "  linked $name -> $DEST/$name"
    done
  done
}

link_local() {
  for skill_dir in "$LOCAL_SKILLS"/*/; do
    [ -d "$skill_dir" ] || continue
    local name="$(basename "$skill_dir")"
    for DEST in "${DESTS[@]}"; do
      mkdir -p "$DEST"
      ln -sfn "$skill_dir" "$DEST/$name"
      echo "  linked $name -> $DEST/$name"
    done
  done
}

echo "Linking vendor skills..."
for bucket in engineering productivity misc in-progress; do
  echo "  $bucket/"
  link_vendor "$bucket"
done

echo "Linking local skills..."
link_local

echo "Done. Skills linked for Claude Code, OpenCode, and Codex."
