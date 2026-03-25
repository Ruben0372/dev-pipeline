#!/bin/bash
# commit-doc.sh — Stage, commit, and push a doc file
# Usage: commit-doc.sh <file-path> [commit-message]
set -e

FILE_PATH="$1"
MSG="${2:-"docs: update $(basename "$FILE_PATH")"}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ -z "$FILE_PATH" ]; then
  echo "Usage: commit-doc.sh <file-path> [commit-message]"
  exit 1
fi

cd "$REPO_ROOT"
git add "$FILE_PATH"

# Exit silently if nothing to commit
git diff --cached --quiet && exit 0

git commit -m "$MSG"
git push
echo "Committed: $FILE_PATH"
