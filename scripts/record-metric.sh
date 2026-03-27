#!/usr/bin/env bash
set -euo pipefail

# record-metric.sh — Append a pipeline metric entry to the JSON lines file.
# Usage: record-metric.sh <project> <version> <stage> <started_at> <completed_at> [agent_used] [success]

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
METRICS_FILE="$REPO_ROOT/metrics/pipeline-metrics.jsonl"

PROJECT="${1:-}"
VERSION="${2:-}"
STAGE="${3:-}"
STARTED_AT="${4:-}"
COMPLETED_AT="${5:-$(date -u +"%Y-%m-%dT%H:%M:%SZ")}"
AGENT_USED="${6:-claude}"
SUCCESS="${7:-true}"

if [ -z "$PROJECT" ] || [ -z "$STAGE" ]; then
  echo "Usage: record-metric.sh <project> <version> <stage> <started_at> [completed_at] [agent_used] [success]"
  exit 1
fi

# Calculate duration in minutes
if [ -n "$STARTED_AT" ] && command -v python3 &>/dev/null; then
  DURATION_MIN=$(python3 -c "
from datetime import datetime
try:
    s = datetime.fromisoformat('$STARTED_AT'.replace('Z','+00:00'))
    e = datetime.fromisoformat('$COMPLETED_AT'.replace('Z','+00:00'))
    print(round((e - s).total_seconds() / 60, 1))
except:
    print(0)
" 2>/dev/null || echo "0")
else
  DURATION_MIN=0
fi

mkdir -p "$(dirname "$METRICS_FILE")"

# Append JSON line
echo "{\"project\":\"$PROJECT\",\"version\":\"$VERSION\",\"stage\":\"$STAGE\",\"started_at\":\"$STARTED_AT\",\"completed_at\":\"$COMPLETED_AT\",\"duration_min\":$DURATION_MIN,\"agent_used\":\"$AGENT_USED\",\"success\":$SUCCESS}" >> "$METRICS_FILE"

echo "Metric recorded: $PROJECT/$STAGE ($DURATION_MIN min)"
