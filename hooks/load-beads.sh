#!/usr/bin/env bash
# load-beads.sh — Reads .beads from current directory and outputs project context.
# Intended for use as a Claude Code PreToolUse hook on Bash commands.
# If .beads exists in cwd or any parent, outputs the context for injection.

find_beads() {
  local dir="$1"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.beads" ]; then
      echo "$dir/.beads"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

BEADS_FILE=$(find_beads "$(pwd)") || exit 0

echo "--- Project Context (from .beads) ---"
cat "$BEADS_FILE"
echo "--- End Context ---"
