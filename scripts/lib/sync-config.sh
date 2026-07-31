#!/usr/bin/env bash
#
# sync-config.sh — Verify opencode.jsonc skill paths exist.
#
# Usage: source this file.

# Verify that all paths listed in opencode.jsonc's skills.paths exist.
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
import json, sys

try:
    with open('$config_file') as f:
        text = f.read()

    # Strip // comments (naive but works for our JSONC)
    lines = []
    for line in text.split('\n'):
        # Remove // comments (but not URLs with //)
        stripped = line.rstrip()
        if '//' in stripped:
            # Only strip if // is outside double quotes (simple heuristic)
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

    clean = '\n'.join(lines)
    config = json.loads(clean)

    paths = config.get('skills', {}).get('paths', [])
    if not paths:
        print(json.dumps({'type': 'config-no-paths', 'reason': 'skills.paths array is empty'}))
        sys.exit(0)

    for p in paths:
        import os
        full = os.path.join('$repo_root', p.lstrip('./'))
        exists = os.path.isdir(full)
        print(json.dumps({'type': 'config-path-ok' if exists else 'config-path-missing',
                          'path': p, 'exists': exists,
                          'reason': '' if exists else 'directory does not exist — vendor submodule may not be checked out'}))

except json.JSONDecodeError as e:
    print(json.dumps({'type': 'config-no-paths', 'reason': f'JSON parse error: {e}'}))
except Exception as e:
    print(json.dumps({'type': 'config-no-paths', 'reason': str(e)}))
" 2>/dev/null
}

# Add a path to opencode.jsonc's skills.paths array.
apply_config_add_path() {
  local repo_root="$1" new_path="$2"
  local config_file="$repo_root/opencode.jsonc"

  python3 -c "
import json, sys

with open('$config_file') as f:
    text = f.read()

# Strip // comments
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

clean = '\n'.join(lines)
config = json.loads(clean)
config['skills']['paths'].append('$new_path')

# Pretty print (no comments preserved for this operation)
with open('$config_file', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')
" 2>/dev/null || {
    echo "WARNING: could not add path to opencode.jsonc" >&2
    return 1
  }
}

# Remove a path from opencode.jsonc's skills.paths array.
apply_config_remove_path() {
  local repo_root="$1" path_to_remove="$2"
  local config_file="$repo_root/opencode.jsonc"

  python3 -c "
import json, sys

with open('$config_file') as f:
    text = f.read()

# Strip // comments
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

clean = '\n'.join(lines)
config = json.loads(clean)
paths = config.get('skills', {}).get('paths', [])

if '$path_to_remove' in paths:
    paths.remove('$path_to_remove')
    config['skills']['paths'] = paths

with open('$config_file', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')
" 2>/dev/null || {
    echo "WARNING: could not remove path from opencode.jsonc" >&2
    return 1
  }
}
