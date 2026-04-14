#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/claude-templates"
FALLBACK_BASE="$HOME/.claude/templates"

log() {
  echo "[update] $*"
}

update_repo() {
  local name="$1"
  local path="$BASE/$name"
  
  echo ""
  log "=== $name ==="
  
  if [ ! -d "$path/.git" ]; then
    log "WARN: $path is not a git repo, skipping"
    return 0
  fi
  
  cd "$path"
  
  # Show current state
  local current_commit
  current_commit=$(git rev-parse --short HEAD)
  log "Current: $current_commit"
  
  # Fetch and show if there are updates
  git fetch origin
  local remote_commit
  remote_commit=$(git rev-parse --short origin/main 2>/dev/null || git rev-parse --short origin/master)
  
  if [ "$current_commit" = "$remote_commit" ]; then
    log "Already up to date"
  else
    log "Updating: $current_commit -> $remote_commit"
    git pull --rebase
    log "Updated successfully"
  fi
  
  git status -sb
}

sync_fallback_templates() {
  log "Syncing fallback templates to $FALLBACK_BASE ..."
  mkdir -p "$FALLBACK_BASE/ecc" "$FALLBACK_BASE/orchestra"

  if [ -d "$BASE/ecc/commands" ]; then
    rm -rf "$FALLBACK_BASE/ecc/commands"
    cp -R "$BASE/ecc/commands" "$FALLBACK_BASE/ecc/"
  fi

  for item in CLAUDE.md .codex .gemini .claude; do
    if [ -e "$BASE/orchestra/$item" ]; then
      rm -rf "$FALLBACK_BASE/orchestra/$item"
      cp -R "$BASE/orchestra/$item" "$FALLBACK_BASE/orchestra/"
    fi
  done
}

log "Updating Claude templates..."

update_repo ecc
update_repo orchestra
sync_fallback_templates

echo ""
log "Done!"
echo ""
echo "To apply updates to a project:"
echo "  cd ~/Projects/<project>"
echo "  claude-route . --force"
