#!/usr/bin/env bash
set -euo pipefail

# report-issue.sh — File a structured issue report to the dev-pipeline repo.
# Usage:
#   ./scripts/report-issue.sh <project-slug> \
#     --severity <critical|high|medium|low> \
#     --domain <frontend|backend|infra|data|devops> \
#     --title "Short description" \
#     --body "Detailed description"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DISPATCH_RULES="$REPO_ROOT/config/dispatch-rules.json"

# --- Argument parsing ---
PROJECT=""
SEVERITY=""
DOMAIN=""
TITLE=""
BODY=""

if [ $# -lt 1 ]; then
  echo "Usage: report-issue.sh <project-slug> --severity <level> --domain <area> --title \"...\" --body \"...\""
  exit 1
fi

PROJECT="$1"
shift

while [ $# -gt 0 ]; do
  case "$1" in
    --severity) SEVERITY="$2"; shift 2 ;;
    --domain)   DOMAIN="$2"; shift 2 ;;
    --title)    TITLE="$2"; shift 2 ;;
    --body)     BODY="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# --- Validation ---
if [ -z "$PROJECT" ] || [ -z "$SEVERITY" ] || [ -z "$DOMAIN" ] || [ -z "$TITLE" ]; then
  echo "Error: project, --severity, --domain, and --title are required."
  exit 1
fi

case "$SEVERITY" in
  critical|high|medium|low) ;;
  *) echo "Error: severity must be critical|high|medium|low"; exit 1 ;;
esac

case "$DOMAIN" in
  frontend|backend|infra|data|devops) ;;
  *) echo "Error: domain must be frontend|backend|infra|data|devops"; exit 1 ;;
esac

# --- Determine dispatch mode from rules ---
DISPATCH_MODE="needs_approval"
if [ -f "$DISPATCH_RULES" ] && command -v python3 &>/dev/null; then
  DISPATCH_MODE=$(python3 -c "
import json, sys
with open('$DISPATCH_RULES') as f:
    rules = json.load(f)
mode = rules.get('severity_routing', {}).get('$SEVERITY', {}).get('approval', 'needs_approval')
print(mode)
" 2>/dev/null || echo "needs_approval")
fi

# --- Generate ID and timestamp ---
TIMESTAMP=$(date -u +"%Y%m%d%H%M%S")
FILED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ISSUE_ID="ISS-${PROJECT}-${TIMESTAMP}"

# --- Slugify title for filename ---
FILENAME=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 -]//g' | tr ' ' '-' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
FILENAME="${TIMESTAMP}-${FILENAME}"

# --- Create issues directory ---
ISSUES_DIR="$REPO_ROOT/sites/$PROJECT/issues"
mkdir -p "$ISSUES_DIR"

# --- Write the issue file ---
ISSUE_FILE="$ISSUES_DIR/${FILENAME}.md"
cat > "$ISSUE_FILE" <<EOF
---
id: "$ISSUE_ID"
severity: "$SEVERITY"
domain: "$DOMAIN"
status: "open"
reporter: "claude-agent"
source_context: "report-issue.sh"
project: "$PROJECT"
filed_at: "$FILED_AT"
dispatch_mode: "$DISPATCH_MODE"
assigned_to: ""
resolved_at: ""
dispatch_id: ""
---

# $TITLE

## Description

${BODY:-No additional details provided.}

## Environment

- Project: $PROJECT
- Domain: $DOMAIN
- Severity: $SEVERITY
- Filed: $FILED_AT
EOF

# --- Git commit ---
cd "$REPO_ROOT"
git add "$ISSUE_FILE"
git commit -m "issue($PROJECT): $TITLE

severity: $SEVERITY | domain: $DOMAIN | dispatch: $DISPATCH_MODE"

echo "Filed: $ISSUE_ID → $ISSUE_FILE"
echo "Severity: $SEVERITY | Dispatch: $DISPATCH_MODE"
