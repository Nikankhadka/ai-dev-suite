#!/usr/bin/env bash
set -euo pipefail

# Link the agnostic suite into Pi (https://pi.dev).
#
# Pi already reads ~/.agents/skills globally, so every skill linked by
# link-skills.sh is visible to Pi with no extra work. This script covers
# the two things Pi does NOT share by default:
#   - global instructions: ~/.pi/agent/AGENTS.md -> instructions/AGENTS.md
#   - slash commands: command/*.md -> ~/.pi/agent/prompts/*.md
#     (Pi prompt templates use the same frontmatter and $ARGUMENTS syntax
#     as opencode commands, so the files are symlinked as-is.)
#
# Idempotent. Safe to re-run after submodule bumps.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
PI_DIR="$HOME/.pi/agent"
PROMPTS_DIR="$PI_DIR/prompts"
INSTRUCTIONS="$REPO/instructions/AGENTS.md"

mkdir -p "$PI_DIR" "$PROMPTS_DIR"

# 1. Global instructions
if [ -e "$PI_DIR/AGENTS.md" ] && [ ! -L "$PI_DIR/AGENTS.md" ]; then
  mv "$PI_DIR/AGENTS.md" "$PI_DIR/AGENTS.md.bak"
  echo "  backed up existing $PI_DIR/AGENTS.md -> AGENTS.md.bak"
fi
ln -sfn "$INSTRUCTIONS" "$PI_DIR/AGENTS.md"
echo "  $PI_DIR/AGENTS.md -> $INSTRUCTIONS"

# 2. Prompt templates (one symlink per command, so custom Pi-only
# prompts can live alongside suite prompts in the same directory).
echo "Linking prompts..."
count=0
for src in "$REPO"/command/*.md; do
  [ -f "$src" ] || continue
  name="$(basename "$src")"
  dest="$PROMPTS_DIR/$name"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak"
    echo "  moved real $name aside -> $dest.bak"
  fi
  rm -f "$dest"
  ln -sfn "$src" "$dest"
  count=$((count + 1))
done

# Prune suite-owned prompt links whose command no longer exists.
for entry in "$PROMPTS_DIR"/*.md; do
  [ -L "$entry" ] || continue
  target="$(readlink "$entry")"
  case "$target" in
    "$REPO"/command/*) ;;
    *) continue ;;
  esac
  if [ ! -e "$entry" ] || [ ! -f "$REPO/command/$(basename "$entry")" ]; then
    rm -f "$entry"
    echo "  pruned $(basename "$entry") (no longer a suite command)"
  fi
done

echo "  $count prompts linked into $PROMPTS_DIR"

# 3. settings.json - ensure both shared skills dirs are listed.
# Merges instead of overwriting so user theme/model choices survive.
if [ -f "$PI_DIR/settings.json" ]; then
  python3 - "$PI_DIR/settings.json" <<'EOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    data = json.load(f)
skills = data.get("skills", [])
for want in ("~/.agents/skills", "~/.claude/skills"):
    if want not in skills:
        skills.append(want)
data["skills"] = skills
data.setdefault("enableSkillCommands", True)
with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
EOF
  echo "  merged skills paths into $PI_DIR/settings.json"
else
  cat > "$PI_DIR/settings.json" <<'EOF'
{
  "skills": ["~/.agents/skills", "~/.claude/skills"],
  "enableSkillCommands": true
}
EOF
  echo "  wrote $PI_DIR/settings.json"
fi

echo "Done. Pi reads suite skills via ~/.agents/skills, instructions via AGENTS.md, commands via prompts/."
