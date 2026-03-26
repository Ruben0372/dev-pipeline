#!/bin/bash
# notion-sync-tasks.sh — Called by Claude Code hook after git commit
# Reads the commit message and checks if it references a Notion task.
# If the commit message contains "fix:" or "feat:" with a task description
# that matches a Tower Tasks entry, marks it as Done.
#
# This script is advisory — it outputs a reminder for the agent to
# update Notion tasks. The actual Notion API call happens in the session
# since the script doesn't have Notion credentials.
#
# Usage: notion-sync-tasks.sh <commit-message>

COMMIT_MSG="$1"

if [ -z "$COMMIT_MSG" ]; then
  exit 0
fi

# Output a reminder that the agent should check Notion tasks
echo "[dev-pipeline] Commit detected: $COMMIT_MSG"
echo "[dev-pipeline] Remember to update Notion tasks if any were completed by this commit."
