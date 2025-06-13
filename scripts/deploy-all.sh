#!/bin/bash
set -e

# ------------------------------------------
# DEPLOY-ALL.SH — Recursive version
# Scans ~/projects/ recursively, finds Git repos,
# pulls updates from origin/main, and runs a matching deploy script.
# ------------------------------------------

PROJECTS_ROOT="/home/roger/projects"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # Get script location
DEPLOY_SCRIPTS="$SCRIPT_DIR/deploy"

echo "🚀 Searching recursively in: $PROJECTS_ROOT"

# Find all Git repos under ~/projects (max depth 4)
find "$PROJECTS_ROOT" -type d -name ".git" -prune | while read -r gitdir; do
  # Get the parent directory of the .git folder
  REPO_DIR=$(dirname "$gitdir")
  PROJECT_NAME=$(basename "$REPO_DIR")

  echo ""
  echo "🔍 Found project: $PROJECT_NAME"
  cd "$REPO_DIR"

  # Fetch remote changes
  git fetch origin

  LOCAL_COMMIT=$(git rev-parse @)
  REMOTE_COMMIT=$(git rev-parse origin/main)

  if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
    echo "  🔄 Changes found — pulling and deploying $PROJECT_NAME..."
    git pull origin main

  # Try to find a matching deploy script, case-insensitively
  SCRIPT_BASENAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')
  SCRIPT_PATH=$(find "$DEPLOY_SCRIPTS" -iname "deploy-$SCRIPT_BASENAME.sh" | head -n 1)

  if [ -n "$SCRIPT_PATH" ] && [ -x "$SCRIPT_PATH" ]; then
    echo "  🚀 Running: deploy-$SCRIPT_BASENAME.sh"
    bash "$SCRIPT_PATH"
    echo "  ✅ $PROJECT_NAME deployed successfully."
  else
    echo "  ❌ No deploy script found for $PROJECT_NAME → expected: deploy-$SCRIPT_BASENAME.sh"
  fi
  else
    echo "  🟢 $PROJECT_NAME is already up to date."
  fi
done

echo ""
echo "✅ Done — all Git projects processed."
