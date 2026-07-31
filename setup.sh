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

# 6. Link the shared instruction file into each harness
echo "-> Linking global instructions..."
INSTRUCTIONS="$OPENDIR/instructions/AGENTS.md"
link_instructions() {
  local dest="$1"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak"
    echo "   backed up existing $dest -> $dest.bak"
  fi
  ln -sfn "$INSTRUCTIONS" "$dest"
  echo "   $dest -> $INSTRUCTIONS"
}
link_instructions "$HOME/.claude/CLAUDE.md"
link_instructions "$HOME/.codex/AGENTS.md"
link_instructions "$HOME/.agents/CLAUDE.md"

# 7. Remove links from the pre-.opencode layout
# Commands and agents are OpenCode-specific and live in $OPENDIR/.opencode/.
# Older installs pointed ~/.claude at directories that no longer exist.
for stale in "$HOME/.claude/commands" "$HOME/.claude/agents"; do
  if [ -L "$stale" ] && [ ! -e "$stale" ]; then
    rm -f "$stale"
    echo "-> Removed dead symlink $stale"
  fi
done

# 8. Verify
echo ""
echo "=== Installation Complete ==="
echo "Skills:          $OPENDIR/skills, $OPENDIR/vendor/*/skills"
echo "OpenCode config: $OPENDIR/opencode.jsonc"
echo "Instructions:    $INSTRUCTIONS (linked into Claude Code and Codex)"
echo ""
echo "Commands are OpenCode-only ($OPENDIR/.opencode/command). Skills work everywhere."
echo ""
echo "  Plan:      /grill-me  /grill-with-docs  /to-spec  /to-tickets  /wayfinder"
echo "             /design    /lavish           /ask-matt"
echo "  Build:     /tdd       /implement        /prototype  /ship"
echo "  Review:    /code-review  /ponytail-review  /ponytail-audit  /ponytail-debt"
echo "  Validate:  /no-mistakes  /gnhf"
echo "  Maintain:  /maintain  /memory  /handoff  /triage  /diagnosing-bugs"
echo "             /improve-codebase-architecture"
echo ""
echo "Workflow guides:"
echo "  $OPENDIR/docs/unified-flow.md    # the full suite, tool by tool"
echo "  $OPENDIR/docs/loop-flow.md       # loops and multi-agent work"
echo ""
echo "Keeping vendored skills current:"
echo "  bash $OPENDIR/scripts/sync-upstream.sh --dry-run"
echo ""
echo "Optional CLI tools (install separately):"
echo "  npx skills add kunchenguid/axi       # AXI design principles"
echo "  npm install -g gnhf                  # gnhf autonomous runner"
echo "  curl -fsSL https://raw.githubusercontent.com/kunchenguid/treehouse/main/docs/install.sh | sh"
echo "  curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh"
