#!/usr/bin/env bash
set -euo pipefail

WINDOWS_HOME="/mnt/c/Users/kawad"
DRY_RUN=0
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT=""

usage() {
  cat <<'EOF'
Usage: sync-runtime-mirror.sh [--windows-home /mnt/c/Users/<name>] [--dry-run]

Sync shared WSL runtime assets into the Windows compatibility mirror.
This script does not touch runtime-specific files such as hooks, settings.json,
history, cache, or telemetry.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --windows-home)
      WINDOWS_HOME="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

WSL_CLAUDE_HOME="$HOME/.claude"
WSL_CODEX_HOME="$HOME/.codex"
WIN_CLAUDE_HOME="$WINDOWS_HOME/.claude"
WIN_CODEX_HOME="$WINDOWS_HOME/.codex"
WIN_CLAUDE_JSON="$WINDOWS_HOME/.claude.json"
BACKUP_ROOT="$WINDOWS_HOME/.claude-sync-backups/$TIMESTAMP"

log() {
  echo "[sync-runtime-mirror] $*"
}

run_cmd() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[sync-runtime-mirror] (dry-run) '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

ensure_dir() {
  run_cmd mkdir -p "$1"
}

backup_path() {
  local target="$1"
  local rel="${target#"$WINDOWS_HOME"/}"
  local dest="$BACKUP_ROOT/$rel"

  if [ ! -e "$target" ]; then
    return 0
  fi

  ensure_dir "$(dirname "$dest")"
  if [ -d "$target" ]; then
    run_cmd rsync -a "$target/" "$dest/"
  else
    run_cmd cp -a "$target" "$dest"
  fi
}

sync_file() {
  local src="$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    return 0
  fi

  backup_path "$dest"
  ensure_dir "$(dirname "$dest")"
  run_cmd cp -a "$src" "$dest"
}

sync_markdown_dir() {
  local src="$1"
  local dest="$2"

  if [ ! -d "$src" ]; then
    return 0
  fi

  backup_path "$dest"
  ensure_dir "$dest"
  run_cmd rsync -a \
    --prune-empty-dirs \
    --include='*/' \
    --include='*.md' \
    --exclude='*.local.md' \
    --exclude='*' \
    "$src/" "$dest/"
}

sync_tree() {
  local src="$1"
  local dest="$2"

  if [ ! -d "$src" ]; then
    return 0
  fi

  backup_path "$dest"
  ensure_dir "$dest"
  run_cmd rsync -a \
    --exclude='.git/' \
    --exclude='node_modules/' \
    --exclude='dist/' \
    --exclude='build/' \
    --exclude='__pycache__/' \
    "$src/" "$dest/"
}

sync_active_docs() {
  local src="$1"
  local dest="$2"
  local name

  ensure_dir "$dest"
  for name in README.md operation-overview.md runtime-sync-policy.md template-policy.md troubleshooting.md external-skills-intake-policy.md; do
    if [ -f "$src/$name" ]; then
      sync_file "$src/$name" "$dest/$name"
    fi
  done
}

sync_windows_claude_json() {
  local src="$HOME/.claude.json"
  local dest="$WIN_CLAUDE_JSON"

  if [ ! -f "$src" ]; then
    log "Skipped .claude.json sync: source missing"
    return 0
  fi

  backup_path "$dest"
  ensure_dir "$(dirname "$dest")"

  if [ "$DRY_RUN" -eq 1 ]; then
    log "(dry-run) rewrite mcpServers.filesystem in $dest from WSL canonical config"
    return 0
  fi

  python3 - "$src" "$dest" <<'PY'
import json
import re
import sys
from pathlib import Path

src = Path(sys.argv[1])
dest = Path(sys.argv[2])

src_obj = json.loads(src.read_text(encoding="utf-8"))
dest_obj = json.loads(dest.read_text(encoding="utf-8")) if dest.exists() else {}

fs = src_obj.get("mcpServers", {}).get("filesystem")
if not fs:
    raise SystemExit("source mcpServers.filesystem missing")

args = []
for item in fs.get("args", []):
    if isinstance(item, str) and item.startswith("/mnt/"):
        if item.lower().startswith("/mnt/c/"):
            tail = item[7:].replace("/", "\\")
            args.append(f"C:\\{tail}")
        else:
            args.append(item)
    else:
        args.append(item)

dest_obj.setdefault("mcpServers", {})
dest_obj["mcpServers"]["filesystem"] = {
    "type": fs.get("type", "stdio"),
    "command": "cmd",
    "args": ["/c", "npx"] + args,
    "env": fs.get("env", {}),
}

dest.write_text(json.dumps(dest_obj, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
PY
}

main() {
  log "WSL canonical source: $WSL_CLAUDE_HOME"
  log "Windows mirror target: $WINDOWS_HOME"

  ensure_dir "$BACKUP_ROOT"

  sync_file "$WSL_CLAUDE_HOME/CLAUDE.md" "$WIN_CLAUDE_HOME/CLAUDE.md"
  sync_markdown_dir "$WSL_CLAUDE_HOME/commands" "$WIN_CLAUDE_HOME/commands"
  sync_markdown_dir "$WSL_CLAUDE_HOME/agents" "$WIN_CLAUDE_HOME/agents"
  sync_tree "$WSL_CLAUDE_HOME/skills" "$WIN_CLAUDE_HOME/skills"
  sync_tree "$WSL_CLAUDE_HOME/plugins/local" "$WIN_CLAUDE_HOME/plugins/local"
  sync_markdown_dir "$WSL_CLAUDE_HOME/rules" "$WIN_CLAUDE_HOME/rules"
  sync_active_docs "$WSL_CLAUDE_HOME/docs" "$WIN_CLAUDE_HOME/docs"

  sync_file "$WSL_CODEX_HOME/ops.md" "$WIN_CODEX_HOME/ops.md"
  sync_file "$WSL_CODEX_HOME/rules/default.rules" "$WIN_CODEX_HOME/rules/default.rules"

  sync_windows_claude_json

  log "Done"
  log "Backups: $BACKUP_ROOT"
}

main "$@"
