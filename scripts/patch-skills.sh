#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO/vendor/mattpocock-skills/skills"

echo "=== Patching skills for agent-agnostic compatibility ==="

# git-guardrails-claude-code -> git-guardrails (agent-agnostic)
if [ -d "$SKILLS_DIR/misc/git-guardrails-claude-code" ]; then
  echo "-> Patching git-guardrails-claude-code..."

  if [ ! -d "$SKILLS_DIR/misc/git-guardrails" ]; then
    mkdir -p "$SKILLS_DIR/misc/git-guardrails"
    cp "$SKILLS_DIR/misc/git-guardrails-claude-code/SKILL.md" \
       "$SKILLS_DIR/misc/git-guardrails/SKILL.md"

    SED_FLAG=(-i)
    [[ "$(uname)" == "Darwin" ]] && SED_FLAG=(-i '')

    sed "${SED_FLAG[@]}" 's/git-guardrails-claude-code/git-guardrails/g' \
      "$SKILLS_DIR/misc/git-guardrails/SKILL.md"

    sed "${SED_FLAG[@]}" 's|\.claude/settings\.json|the agent settings file|g' \
      "$SKILLS_DIR/misc/git-guardrails/SKILL.md"

    sed "${SED_FLAG[@]}" 's|~/.claude/|~/|g' \
      "$SKILLS_DIR/misc/git-guardrails/SKILL.md"

    if [ -d "$SKILLS_DIR/misc/git-guardrails-claude-code/scripts" ]; then
      cp -r "$SKILLS_DIR/misc/git-guardrails-claude-code/scripts" \
            "$SKILLS_DIR/misc/git-guardrails/"
    fi

    echo "    Created $SKILLS_DIR/misc/git-guardrails/"
  fi
fi

echo "=== Patch complete ==="
