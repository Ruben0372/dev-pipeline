#!/usr/bin/env bash
set -euo pipefail

# cache-warm.sh — Pre-pull Docker base images and warm build cache.
# Prevents TLS flakes on Alpine by pulling images during low-traffic hours.
# Schedule: daily 04:00 via Tower scheduled task.

echo "=== Docker Cache Warming: $(date -u +"%Y-%m-%dT%H:%M:%SZ") ==="

IMAGES=(
  "golang:1.25-alpine"
  "node:22-alpine"
  "nginx:alpine"
  "alpine:latest"
)

for img in "${IMAGES[@]}"; do
  echo "Pulling $img..."
  if docker pull "$img" 2>&1; then
    echo "  OK: $img"
  else
    echo "  WARN: Failed to pull $img — retrying with fallback..."
    # Retry once after short pause
    sleep 5
    docker pull "$img" 2>&1 || echo "  FAIL: $img (will retry next run)"
  fi
done

# Warm the dashboard build cache with a no-op build
DASHBOARD_DIR="${DASHBOARD_DIR:-$HOME/dashboard-deploy}"
if [ -d "$DASHBOARD_DIR" ]; then
  echo "Warming dashboard build cache..."
  cd "$DASHBOARD_DIR"
  docker compose build --no-cache=false 2>&1 | tail -5
  echo "  OK: dashboard cache warmed"
else
  echo "  SKIP: $DASHBOARD_DIR not found"
fi

echo "=== Cache Warming: COMPLETE ==="
