#!/usr/bin/env bash
set -euo pipefail

# AI Dev Suite - One-line installer
# Usage: curl -fsSL https://raw.githubusercontent.com/Nikankhadka/ai-dev-suite/main/setup.sh | bash

OPENDIR="${AI_DEVSUITE_DIR:-$HOME/.config/opencode}"
REPO_URL="${AI_DEVSUITE_REPO:-https://github.com/Nikankhadka/ai-dev-suite.git}"

echo "=== AI Dev Suite Installer ==="

# 1. Clone or update repo
if [ -d "$OPENDIR/.git" ]; then
  echo "-> Updating existing repo at $OPENDIR..."
  git -C "$OPENDIR" pull --recurse-submodules
else
  echo "-> Cloning ai-dev-suite to $OPENDIR..."
  git clone --recursive "$REPO_URL" "$OPENDIR"
fi

# 2. Init submodules (idempotent)
echo "-> Initializing submodules..."
git -C "$OPENDIR" submodule update --init --recursive

# 3. Install npm deps
if [ -f "$OPENDIR/package.json" ]; then
  echo "-> Installing npm dependencies..."
  (cd "$OPENDIR" && npm install)
fi

# 4. Patch skills for agent-agnostic compatibility
echo "-> Patching skills for agent-agnostic compatibility..."
bash "$OPENDIR/scripts/patch-skills.sh"

# 5. Link skills for all agents
echo "-> Linking skills for Claude Code, OpenCode, Codex..."
bash "$OPENDIR/scripts/link-skills.sh"

# 6. Verify
echo ""
echo "=== Installation Complete ==="
echo "Skills directory: $OPENDIR/vendor/mattpocock-skills/skills"
echo "OpenCode config:  $OPENDIR/opencode.jsonc"
echo ""
echo "Available commands (run in OpenCode):"
echo "  /tdd       /code-review  /diagnosing-bugs  /grill-me"
echo "  /to-spec   /to-tickets   /implement        /triage"
echo "  /handoff   /teach        /prototype        /wayfinder"
echo "  /ask-matt  /improve-codebase-architecture"
