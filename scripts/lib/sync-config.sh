#!/usr/bin/env bash
#
# sync-config.sh - Verify the harness-sync state of opencode.jsonc.
#
# Skills are no longer listed in opencode.jsonc: scripts/link-skills.sh symlinks
# them into ~/.claude/skills and ~/.agents/skills, which opencode, Claude Code,
# and Codex all read globally. This analyzer checks the two things the config
# still owns: the shared instructions path exists, and the skill symlink dirs
# are present.
#
# Usage: source this file.

# Verify opencode.jsonc's shared-instructions path exists and that the skill
# symlink dirs for the harnesses are present.
# Uses python3 for JSONC parsing (handles comments).
# Outputs review items as JSON lines.
analyze_config() {
  local repo_root="$1"
  local config_file="$repo_root/opencode.jsonc"

  if [[ ! -f "$config_file" ]]; then
    printf '{"type":"config-missing","reason":"opencode.jsonc not found"}\n'
    return
  fi

  python3 -c "
import json, sys, os

home = os.path.expanduser('~')

def strip_jsonc(text):
    lines = []
    for line in text.split('\n'):
        stripped = line.rstrip()
        if '//' in stripped:
            in_string = False
            result = []
            i = 0
            while i < len(stripped):
                if stripped[i] == '\"':
                    in_string = not in_string
                    result.append(stripped[i])
                    i += 1
                elif not in_string and i < len(stripped) - 1 and stripped[i:i+2] == '//':
                    break
                else:
                    result.append(stripped[i])
                    i += 1
            stripped = ''.join(result).rstrip()
        lines.append(stripped)
    return '\n'.join(lines)

def expand(p):
    if p.startswith('~/'):
        return os.path.join(home, p[2:])
    if p == '~':
        return home
    return p

try:
    with open('$config_file') as f:
        config = json.loads(strip_jsonc(f.read()))

    for raw in config.get('instructions', []):
        if raw.startswith('http://') or raw.startswith('https://'):
            continue
        full = expand(raw)
        exists = os.path.isfile(full)
        print(json.dumps({'type': 'config-instruction-ok' if exists else 'config-instruction-missing',
                          'path': full, 'exists': exists,
                          'reason': '' if exists else 'instruction file does not exist - opencode will not load the shared instructions'}))

    for link_dir in (os.path.join(home, '.claude', 'skills'), os.path.join(home, '.agents', 'skills')):
        exists = os.path.isdir(link_dir)
        print(json.dumps({'type': 'config-skill-links-ok' if exists else 'config-skill-links-missing',
                          'path': link_dir, 'exists': exists,
                          'reason': '' if exists else 'skill dir missing - run scripts/link-skills.sh so every harness sees the same skills'}))

except json.JSONDecodeError as e:
    print(json.dumps({'type': 'config-missing', 'reason': f'JSON parse error: {e}'}))
except Exception as e:
    print(json.dumps({'type': 'config-missing', 'reason': str(e)}))
" 2>/dev/null
}
