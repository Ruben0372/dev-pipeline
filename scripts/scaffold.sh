#!/bin/bash
# scaffold.sh — Create a new site record from template
# Usage: scaffold.sh <project-slug> [project-name]
set -e

PROJECT_SLUG="$1"
PROJECT_NAME="${2:-$PROJECT_SLUG}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SITE_DIR="$REPO_ROOT/sites/$PROJECT_SLUG"

if [ -z "$PROJECT_SLUG" ]; then
  echo "Usage: scaffold.sh <project-slug> [project-name]"
  exit 1
fi

if [ -d "$SITE_DIR" ]; then
  echo "Site '$PROJECT_SLUG' already exists at $SITE_DIR"
  exit 0
fi

echo "Scaffolding site: $PROJECT_SLUG ($PROJECT_NAME)"
cp -r "$REPO_ROOT/templates/new-site" "$SITE_DIR"

# Replace template placeholder in overview.md
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s/{project_name}/$PROJECT_NAME/g" "$SITE_DIR/overview.md"
else
  sed -i "s/{project_name}/$PROJECT_NAME/g" "$SITE_DIR/overview.md"
fi

cd "$REPO_ROOT"
git add "sites/$PROJECT_SLUG"
git commit -m "feat: scaffold site record for $PROJECT_SLUG"
git push

echo "Done: $SITE_DIR"
