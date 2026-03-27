#!/usr/bin/env bash
# suggest-stage.sh — Checks recent git activity and suggests pipeline stage advancement.
# Intended for use as a Claude Code Stop hook.
# Outputs a suggestion if the current work implies a stage transition.

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

# Extract project name from beads
PROJECT=$(grep "^project:" "$BEADS_FILE" | cut -d: -f2 | tr -d ' ')
[ -z "$PROJECT" ] && exit 0

# Check recent git log (last 5 commits in this session)
RECENT=$(git log --oneline -5 2>/dev/null || exit 0)

# Detect stage from commit patterns
if echo "$RECENT" | grep -qiE "^[a-f0-9]+ (feat|fix|refactor):"; then
  echo "Build complete for $PROJECT — consider advancing to Test stage."
elif echo "$RECENT" | grep -qiE "^[a-f0-9]+ test:"; then
  echo "Tests added for $PROJECT — consider advancing to Review stage."
elif echo "$RECENT" | grep -qiE "^[a-f0-9]+ (docs|chore): (review|code.review)"; then
  echo "Review done for $PROJECT — consider advancing to Ship stage."
fi
