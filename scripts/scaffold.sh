#!/bin/bash
# scaffold.sh — Create a new site record from template
# Usage: scaffold.sh <project-slug> [project-name] [--profile <code|library|content|enterprise>]
set -e

PROJECT_SLUG=""
PROJECT_NAME=""
PROFILE="code"

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --profile) PROFILE="$2"; shift 2 ;;
    *)
      if [ -z "$PROJECT_SLUG" ]; then
        PROJECT_SLUG="$1"
      elif [ -z "$PROJECT_NAME" ]; then
        PROJECT_NAME="$1"
      fi
      shift ;;
  esac
done

PROJECT_NAME="${PROJECT_NAME:-$PROJECT_SLUG}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SITE_DIR="$REPO_ROOT/sites/$PROJECT_SLUG"

if [ -z "$PROJECT_SLUG" ]; then
  echo "Usage: scaffold.sh <project-slug> [project-name] [--profile <code|library|content|enterprise>]"
  exit 1
fi

# Validate profile exists
PROFILE_FILE="$REPO_ROOT/profiles/$PROFILE.yaml"
if [ ! -f "$PROFILE_FILE" ]; then
  echo "Error: profile '$PROFILE' not found at $PROFILE_FILE"
  echo "Available: code, library, content, enterprise"
  exit 1
fi

if [ -d "$SITE_DIR" ]; then
  echo "Site '$PROJECT_SLUG' already exists at $SITE_DIR"
  exit 0
fi

echo "Scaffolding site: $PROJECT_SLUG ($PROJECT_NAME) [profile: $PROFILE]"
cp -r "$REPO_ROOT/templates/new-site" "$SITE_DIR"

# Create issues directory
mkdir -p "$SITE_DIR/issues"

# Replace template placeholder in overview.md
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s/{project_name}/$PROJECT_NAME/g" "$SITE_DIR/overview.md"
else
  sed -i "s/{project_name}/$PROJECT_NAME/g" "$SITE_DIR/overview.md"
fi

cd "$REPO_ROOT"
git add "sites/$PROJECT_SLUG"
git commit -m "feat: scaffold site record for $PROJECT_SLUG (profile: $PROFILE)"
git push

echo "Done: $SITE_DIR (profile: $PROFILE)"
echo "Add 'profile: $PROFILE' to the project's .beads file."
