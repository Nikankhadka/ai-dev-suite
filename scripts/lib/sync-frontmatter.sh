#!/usr/bin/env bash
#
# sync-frontmatter.sh — Pure-bash YAML frontmatter parser for Markdown files.
# No external dependencies (no yq, no jq, no python).
#
# Usage: source this file, then call:
#   frontmatter_get <file> <key>        — extract a value
#   frontmatter_hash <file>             — sha256 of name+description
#   frontmatter_keys <file>             — list all keys in frontmatter
#   frontmatter_snapshot <file>         — JSON fragment: { name, description, sha256 }

# Extract a single key's value from YAML frontmatter in a Markdown file.
# Handles: bare scalars, double-quoted strings, single-quoted strings,
#          YAML folded blocks (description: >).
frontmatter_get() {
  local file="$1" key="$2"
  local in_fm=0 in_key=0 value="" depth=0
  local line stripped

  if [[ ! -f "$file" ]]; then
    return 1
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Toggle frontmatter block (--- delimiters)
    if [[ "$line" == "---" ]]; then
      ((in_fm++))
      continue
    fi
    ((in_fm == 0)) && continue   # before frontmatter
    ((in_fm > 1)) && break       # after frontmatter

    # Inside a folded-block continuation (>)
    if ((in_key == 2)); then
      stripped="${line#"${line%%[![:space:]]*}"}"
      # Stop if we hit a non-indented line that's a new key or empty frontmatter part
      if [[ "$stripped" != "" && ! "$line" =~ ^[[:space:]] ]]; then
        # This is a new frontmatter key — stop collecting
        in_key=0
        continue
      fi
      if [[ "$stripped" == "" ]]; then
        # Empty line in folded block — might end the block
        # Peek: does the next non-empty line look like a new key?
        value+=" "
        continue
      fi
      value+="${stripped} "
      continue
    fi

    # Match key: value patterns
    # Double-quoted: key: "value"
    if [[ "$line" =~ ^${key}:[[:space:]]*\"(.*)\"$ ]]; then
      value="${BASH_REMATCH[1]}"
      in_key=1
    # Single-quoted: key: 'value'
    elif [[ "$line" =~ ^${key}:[[:space:]]*\'(.*)\'$ ]]; then
      value="${BASH_REMATCH[1]}"
      in_key=1
    # Folded block: key: >  or  key: >-
    elif [[ "$line" =~ ^${key}:[[:space:]]*\>[-\ ]*$ ]]; then
      value=""
      in_key=2
    # Folded block with inline text: key: > first line
    elif [[ "$line" =~ ^${key}:[[:space:]]*\>[[:space:]]+(.*)$ ]]; then
      value="${BASH_REMATCH[1]} "
      in_key=2
    # Bare scalar: key: value
    elif [[ "$line" =~ ^${key}:[[:space:]]+(.*)$ ]]; then
      value="${BASH_REMATCH[1]}"
      in_key=1
    fi
  done < "$file"

  # Trim leading/trailing whitespace
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"

  printf '%s' "$value"
}

# Compute a stable hash of the frontmatter (name + description).
# Returns sha256 hex digest. On macOS uses shasum -a 256, on Linux sha256sum.
frontmatter_hash() {
  local file="$1"
  local name desc combined

  name=$(frontmatter_get "$file" "name" 2>/dev/null || true)
  desc=$(frontmatter_get "$file" "description" 2>/dev/null || true)
  combined="${name}|${desc}"

  if command -v shasum &>/dev/null; then
    printf '%s' "$combined" | shasum -a 256 | cut -d' ' -f1
  elif command -v sha256sum &>/dev/null; then
    printf '%s' "$combined" | sha256sum | cut -d' ' -f1
  else
    echo "ERROR: no sha256 tool found (shasum or sha256sum)" >&2
    return 1
  fi
}

# List all top-level keys in the frontmatter block.
frontmatter_keys() {
  local file="$1"
  local in_fm=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "---" ]]; then
      ((in_fm++))
      continue
    fi
    ((in_fm == 0)) && continue
    ((in_fm > 1)) && break
    if [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_-]*): ]]; then
      echo "${BASH_REMATCH[1]}"
    fi
  done < "$file"
}

# Produce a JSON-compatible snapshot: { "name": "...", "description": "...", "sha256": "..." }
frontmatter_snapshot() {
  local file="$1"
  local name desc hash

  name=$(frontmatter_get "$file" "name" 2>/dev/null || echo "null")
  desc=$(frontmatter_get "$file" "description" 2>/dev/null || echo "")
  hash=$(frontmatter_hash "$file" 2>/dev/null || echo "00000000")

  # Escape JSON strings minimally (handle backslashes and double quotes)
  name="${name//\\/\\\\}"
  name="${name//\"/\\\"}"
  desc="${desc//\\/\\\\}"
  desc="${desc//\"/\\\"}"

  printf '{"name":"%s","description":"%s","sha256":"%s"}' "$name" "$desc" "$hash"
}
