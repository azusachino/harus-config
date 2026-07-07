#!/usr/bin/env bash
# Claude Code PreToolUse hook — quality gate before commits and PRs.
# Runs `make check` before git commit, `make validate` before gh pr create.
# Exit 0 = allow, exit 2 = block (stderr shown to Claude).

set -euo pipefail

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

[ -z "$CMD" ] && exit 0

# Resolve project directory from tool input or fall back to cwd
PROJECT_DIR=$(echo "$INPUT" | jq -r '.tool_input.description // empty' | head -1)
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"

# Only act if a Makefile exists in the project
find_makefile() {
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    [ -f "$dir/Makefile" ] && echo "$dir/Makefile" && return 0
    dir=$(dirname "$dir")
  done
  return 1
}

MAKEFILE=$(find_makefile) || exit 0
MAKEFILE_DIR=$(dirname "$MAKEFILE")

# Gate: git commit → make check
if echo "$CMD" | grep -qE '\bgit\b.*\bcommit\b'; then
  if grep -q '^check:' "$MAKEFILE"; then
    if ! make -C "$MAKEFILE_DIR" check >/dev/null 2>&1; then
      echo "make check failed — commit blocked. Fix issues and retry." >&2
      exit 2
    fi
  fi
fi

# Gate: gh pr create → make validate
if echo "$CMD" | grep -qE '\bgh\b.*\bpr\b.*\bcreate\b'; then
  if grep -q '^validate:' "$MAKEFILE"; then
    if ! make -C "$MAKEFILE_DIR" validate >/dev/null 2>&1; then
      echo "make validate failed — PR blocked. Fix issues and retry." >&2
      exit 2
    fi
  fi
fi

exit 0
