#!/usr/bin/env bash
set -euo pipefail

VERSION="1.4.0"

usage() {
  cat <<USAGE
Usage: project-env-router.sh [project_dir] [options]

Route a project to ecc/orchestra/hybrid mode, optionally with perspective sub-mode.

Options:
  --mode MODE       Set mode (ecc|orchestra|hybrid)
  --perspective     Enable perspective sub-mode (orchestra/hybrid only)
  --no-prompt       Use defaults without prompting
  --force           Re-apply even if already configured
  --dry-run         Show what would happen without making changes
  --version         Show version
  -h, --help        Show this help

Examples:
  project-env-router.sh .                             # Interactive mode selection
  project-env-router.sh . --mode ecc                  # Force ecc mode
  project-env-router.sh . --mode orchestra --perspective  # Orchestra + perspective
  project-env-router.sh ~/Projects/app --perspective  # Add perspective to existing
  project-env-router.sh . --force                     # Re-apply overlays
USAGE
}

# Parse arguments
PROJECT_DIR="."
MODE=""
PERSPECTIVE=0
NO_PROMPT=0
FORCE=0
DRY_RUN=0
PROJECT_DIR_SET=0

while [ $# -gt 0 ]; do
  case "$1" in
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --perspective)
      PERSPECTIVE=1
      shift
      ;;
    --no-prompt)
      NO_PROMPT=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --version)
      echo "project-env-router v$VERSION"
      exit 0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [ "$PROJECT_DIR_SET" -eq 0 ]; then
        PROJECT_DIR="$1"
        PROJECT_DIR_SET=1
        shift
      else
        echo "Unexpected argument: $1" >&2
        usage >&2
        exit 1
      fi
      ;;
  esac
done

# Resolve paths
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
CLAUDE_DIR="$PROJECT_DIR/.claude"
MODE_FILE="$CLAUDE_DIR/project-mode"
LOCAL_CLAUDE_FILE="$PROJECT_DIR/CLAUDE.local.md"
TEMPLATE_ORCH=""
TEMPLATE_PERSP=""

log() {
  echo "[claude-route] $*"
}

warn() {
  echo "[claude-route] WARN: $*" >&2
}

error() {
  echo "[claude-route] ERROR: $*" >&2
  exit 1
}

dry_run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    log "(dry-run) $*"
    return 0
  fi
  return 1
}

backup_path() {
  local target="$1"
  local ts
  ts="$(date +%Y%m%d-%H%M%S)"
  local backup="${target}.bak-${ts}"
  [ -e "$backup" ] && backup="${backup}-$$"

  if dry_run "Backup $target -> $backup"; then
    return
  fi

  mv "$target" "$backup"
  log "Backed up: $target -> $(basename "$backup")"
}

sync_template_path() {
  local src="$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    warn "Template path missing, skipped: $src"
    return
  fi

  if [ -d "$src" ]; then
    if [ ! -e "$dest" ]; then
      if dry_run "Copy dir $src -> $dest"; then
        return
      fi
      mkdir -p "$(dirname "$dest")"
      cp -R "$src" "$dest"
      log "Added dir: $dest"
      return
    fi

    if [ "$FORCE" -eq 1 ]; then
      backup_path "$dest"
      if dry_run "Re-copy dir $src -> $dest"; then
        return
      fi
      mkdir -p "$(dirname "$dest")"
      cp -R "$src" "$dest"
      log "Updated dir from template: $dest"
      return
    fi

    if dry_run "Merge missing files from $src -> $dest"; then
      return
    fi
    if cp -R --update=none "$src/." "$dest/" 2>/dev/null; then
      :
    else
      cp -Rn "$src/." "$dest/"
    fi
    log "Merged missing files: $dest"
    return
  fi

  if [ ! -e "$dest" ]; then
    if dry_run "Copy file $src -> $dest"; then
      return
    fi
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    log "Added file: $dest"
    return
  fi

  if [ "$FORCE" -eq 1 ]; then
    backup_path "$dest"
    if dry_run "Re-copy file $src -> $dest"; then
      return
    fi
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    log "Updated file from template: $dest"
    return
  fi

  log "Kept existing file: $dest"
}

normalize_mode() {
  printf "%s" "$1" | tr '[:upper:]' '[:lower:]' | tr -d ' \t\r\n'
}

resolve_template_dir() {
  local name="$1"
  local candidate
  for candidate in \
    "$HOME/.claude/templates/$name" \
    "$HOME/claude-templates/$name"
  do
    if [ -d "$candidate" ]; then
      printf "%s" "$candidate"
      return 0
    fi
  done
  return 1
}

# Determine mode
determine_mode() {
  # Already specified via --mode
  if [ -n "$MODE" ]; then
    return 0
  fi

  # Read from existing file (unless --force)
  if [ -f "$MODE_FILE" ] && [ "$FORCE" -eq 0 ]; then
    MODE="$(normalize_mode "$(cat "$MODE_FILE")")"
    log "Using existing mode: $MODE"
    return 0
  fi

  # Detect from directory structure
  if [ -d "$PROJECT_DIR/.codex" ] || [ -d "$PROJECT_DIR/.gemini" ]; then
    MODE="orchestra"
    log "Detected orchestra (found .codex or .gemini)"
    return 0
  fi

  # Check environment variable
  if [ -n "${CLAUDE_ENV:-}" ]; then
    local env_mode
    env_mode="$(normalize_mode "$CLAUDE_ENV")"
    case "$env_mode" in
      ecc|orchestra|hybrid)
        MODE="$env_mode"
        log "Using CLAUDE_ENV: $MODE"
        return 0
        ;;
    esac
  fi

  # Prompt user or use default
  if [ "$NO_PROMPT" -eq 1 ]; then
    MODE="ecc"
    log "Using default: ecc"
  else
    echo ""
    echo "Select project mode:"
    echo "  [1] ecc       - TDD, specialized agents, no external CLIs"
    echo "  [2] orchestra - Codex + Gemini integration, research-focused"
    echo "  [3] hybrid    - Both (ecc priority, orchestra tools available)"
    echo ""
    read -rp "Choice [1/2/3] (default: 1): " choice || true
    case "$choice" in
      ""|1|ecc) MODE="ecc" ;;
      2|orchestra) MODE="orchestra" ;;
      3|hybrid) MODE="hybrid" ;;
      *)
        error "Invalid choice: $choice"
        ;;
    esac
  fi
}

# Validate mode
validate_mode() {
  case "$MODE" in
    ecc|orchestra|hybrid) ;;
    *)
      error "Invalid mode: $MODE (expected: ecc, orchestra, hybrid)"
      ;;
  esac
}

# Check external CLI availability
check_external_clis() {
  local missing=0

  if [ ! -d "$HOME/.codex" ]; then
    warn "~/.codex not found (Codex CLI not configured)"
    missing=1
  fi
  if ! command -v codex >/dev/null 2>&1; then
    warn "codex command not in PATH"
    missing=1
  fi
  if [ ! -d "$HOME/.gemini" ]; then
    warn "~/.gemini not found (Gemini CLI not configured)"
    missing=1
  fi
  if ! command -v gemini >/dev/null 2>&1; then
    warn "gemini command not in PATH"
    missing=1
  fi

  if [ "$missing" -eq 1 ]; then
    echo ""
    echo "To install missing CLIs:"
    echo "  npm install -g @openai/codex && codex login"
    echo "  npm install -g @google/gemini-cli && gemini login"
    echo ""
  fi

  return 0
}

# Check templates exist
check_templates() {
  if [ "$MODE" = "orchestra" ] || [ "$MODE" = "hybrid" ]; then
    TEMPLATE_ORCH="$(resolve_template_dir orchestra || true)"
    if [ -z "$TEMPLATE_ORCH" ]; then
      error "orchestra template missing (checked: ~/claude-templates/orchestra and ~/.claude/templates/orchestra). Run install-dotfiles.sh and/or bootstrap-templates.sh."
    fi
    log "Using orchestra template: $TEMPLATE_ORCH"
  fi

  if [ "$PERSPECTIVE" -eq 1 ]; then
    TEMPLATE_PERSP="$(resolve_template_dir perspective || true)"
    if [ -z "$TEMPLATE_PERSP" ]; then
      error "perspective template missing (checked: ~/claude-templates/perspective and ~/.claude/templates/perspective)."
    fi
    log "Using perspective template: $TEMPLATE_PERSP"
  fi
}

# Write mode file
write_mode_file() {
  dry_run "mkdir -p $CLAUDE_DIR" && return
  mkdir -p "$CLAUDE_DIR"

  dry_run "echo $MODE > $MODE_FILE" && return
  echo "$MODE" > "$MODE_FILE"
  log "Wrote mode: $MODE_FILE"
}

# Update CLAUDE.local.md with marker
update_local_claude() {
  local marker="<!-- claude_env: $MODE -->"
  local hint
  if [ "$PERSPECTIVE" -eq 1 ]; then
    hint="Mode: $MODE + perspective (6-perspective differentiated architecture). Follow perspective-protocol rules."
  else
    hint="Mode: $MODE (ecc|orchestra|hybrid). Follow this mode for commands, skills, and integrations."
  fi

  if dry_run "Update $LOCAL_CLAUDE_FILE with marker"; then
    return
  fi

  if [ -f "$LOCAL_CLAUDE_FILE" ]; then
    # Remove old marker and hint, then prepend new
    local tmp
    tmp="$(mktemp)"
    awk -v marker="$marker" -v hint="$hint" '
      BEGIN { printed=0; skip_next=0 }
      function print_block() {
        if (!printed) { print marker; print hint; print ""; printed=1 }
      }
      {
        if ($0 ~ /^<!-- claude_env:/) { skip_next=1; next }
        if ($0 ~ /^<!-- perspective:/) { next }
        if (skip_next && ($0 ~ /^Mode:/ || $0 ~ /^This project uses/)) { skip_next=0; next }
        skip_next=0
        print_block()
        print
      }
      END { if (!printed) print_block() }
    ' "$LOCAL_CLAUDE_FILE" > "$tmp"
    mv "$tmp" "$LOCAL_CLAUDE_FILE"
  else
    printf "%s\n%s\n\n" "$marker" "$hint" > "$LOCAL_CLAUDE_FILE"
  fi

  # Add perspective marker if enabled
  if [ "$PERSPECTIVE" -eq 1 ]; then
    if ! grep -q '<!-- perspective:' "$LOCAL_CLAUDE_FILE"; then
      local tmp2
      tmp2="$(mktemp)"
      awk -v persp_marker="<!-- perspective: enabled -->" '
        NR==1 { print; print persp_marker; next }
        { print }
      ' "$LOCAL_CLAUDE_FILE" > "$tmp2"
      mv "$tmp2" "$LOCAL_CLAUDE_FILE"
    fi
  fi
  log "Updated: $LOCAL_CLAUDE_FILE"
}

# Ensure CLAUDE.local.md is in .gitignore
ensure_gitignore() {
  local ignore_file="$PROJECT_DIR/.gitignore"

  if dry_run "Update $ignore_file"; then
    return
  fi

  if [ ! -f "$ignore_file" ]; then
    printf "# Claude Code local config\nCLAUDE.local.md\n" > "$ignore_file"
    log "Created: $ignore_file"
  fi

  if ! grep -q '^CLAUDE\.local\.md$' "$ignore_file"; then
    printf "\n# Claude Code local config\nCLAUDE.local.md\n" >> "$ignore_file"
    log "Added CLAUDE.local.md to .gitignore"
  fi

}

merge_mcp_json_template() {
  local src="$1"
  local dest="$2"

  if [ ! -f "$src" ]; then
    return
  fi

  if dry_run "Merge MCP config $src -> $dest"; then
    return
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    warn "python3 not available, skipping MCP config merge: $src"
    return
  fi

  mkdir -p "$(dirname "$dest")"
  python3 - "$src" "$dest" "$FORCE" <<'PYEOF'
import json
import sys

src_path, dest_path, force_flag = sys.argv[1], sys.argv[2], sys.argv[3]
force = force_flag == "1"

with open(src_path, encoding="utf-8") as f:
    src = json.load(f)

try:
    with open(dest_path, encoding="utf-8") as f:
        dest = json.load(f)
except FileNotFoundError:
    dest = {}
except json.JSONDecodeError:
    dest = {}

src_servers = src.get("mcpServers", {})
dest_servers = dest.setdefault("mcpServers", {})

for name, config in src_servers.items():
    if force or name not in dest_servers:
        dest_servers[name] = config

with open(dest_path, "w", encoding="utf-8") as f:
    json.dump(dest, f, indent=2, ensure_ascii=False)
    f.write("\n")
PYEOF

  log "Merged MCP config: $dest"
}

sync_orchestra_claude_surface() {
  # Thin orchestra overlay: only sync project-scoped assets that enable
  # Codex/Gemini collaboration on top of the global ~/.claude base.
  sync_template_path "$TEMPLATE_ORCH/.claude/settings.json" "$PROJECT_DIR/.claude/settings.json"
  sync_template_path "$TEMPLATE_ORCH/.claude/agents/general-purpose.md" "$PROJECT_DIR/.claude/agents/general-purpose.md"
  sync_template_path "$TEMPLATE_ORCH/.claude/hooks" "$PROJECT_DIR/.claude/hooks"
  sync_template_path "$TEMPLATE_ORCH/.claude/rules/codex-delegation.md" "$PROJECT_DIR/.claude/rules/codex-delegation.md"
  sync_template_path "$TEMPLATE_ORCH/.claude/rules/gemini-delegation.md" "$PROJECT_DIR/.claude/rules/gemini-delegation.md"
  sync_template_path "$TEMPLATE_ORCH/.claude/skills/codex-system" "$PROJECT_DIR/.claude/skills/codex-system"
  sync_template_path "$TEMPLATE_ORCH/.claude/skills/gemini-system" "$PROJECT_DIR/.claude/skills/gemini-system"
  sync_template_path "$TEMPLATE_ORCH/.claude/skills/research-lib" "$PROJECT_DIR/.claude/skills/research-lib"
  sync_template_path "$TEMPLATE_ORCH/.claude/docs/DESIGN.md" "$PROJECT_DIR/.claude/docs/DESIGN.md"
  sync_template_path "$TEMPLATE_ORCH/.claude/docs/libraries" "$PROJECT_DIR/.claude/docs/libraries"
  sync_template_path "$TEMPLATE_ORCH/.claude/docs/research" "$PROJECT_DIR/.claude/docs/research"
  merge_mcp_json_template "$TEMPLATE_ORCH/.mcp.json" "$PROJECT_DIR/.mcp.json"
}

# Apply orchestra assets (.codex, .gemini, thin project overlay)
apply_orchestra_assets() {
  if [ "$MODE" != "orchestra" ] && [ "$MODE" != "hybrid" ]; then
    return
  fi

  if [ ! -d "$TEMPLATE_ORCH/.codex" ] || [ ! -d "$TEMPLATE_ORCH/.gemini" ]; then
    error "Orchestra templates incomplete: missing .codex or .gemini in $TEMPLATE_ORCH"
  fi

  sync_template_path "$TEMPLATE_ORCH/.codex" "$PROJECT_DIR/.codex"
  sync_template_path "$TEMPLATE_ORCH/.gemini" "$PROJECT_DIR/.gemini"
  sync_orchestra_claude_surface

  check_external_clis
}

# Check dev-env CLI availability
check_dev_env_cli() {
  if ! command -v dev-env >/dev/null 2>&1; then
    warn "dev-env CLI not found in PATH"
    echo ""
    echo "To install dev-env CLI globally:"
    echo "  uv tool install ~/Projects/dev-env-built"
    echo ""
  else
    log "dev-env CLI found: $(which dev-env)"
  fi
}

# Apply perspective assets (overlay on top of orchestra/hybrid)
apply_perspective_assets() {
  if [ "$PERSPECTIVE" -ne 1 ]; then
    return
  fi

  if [ "$MODE" = "ecc" ]; then
    warn "Perspective requires orchestra or hybrid mode. Skipping perspective setup."
    return
  fi

  if [ -z "$TEMPLATE_PERSP" ]; then
    warn "Perspective template not found. Skipping perspective setup."
    return
  fi

  log "Applying perspective overlay..."

  # Core config
  sync_template_path "$TEMPLATE_PERSP/.claude/perspective.yaml" "$PROJECT_DIR/.claude/perspective.yaml"

  # Perspective-specific hooks (replace orchestra agent-router with perspective-aware version)
  sync_template_path "$TEMPLATE_PERSP/.claude/hooks/agent-router.py" "$PROJECT_DIR/.claude/hooks/agent-router.py"

  # Perspective skills
  sync_template_path "$TEMPLATE_PERSP/.claude/skills/kickoff" "$PROJECT_DIR/.claude/skills/kickoff"
  sync_template_path "$TEMPLATE_PERSP/.claude/skills/cast" "$PROJECT_DIR/.claude/skills/cast"
  sync_template_path "$TEMPLATE_PERSP/.claude/skills/debate" "$PROJECT_DIR/.claude/skills/debate"
  sync_template_path "$TEMPLATE_PERSP/.claude/skills/joker" "$PROJECT_DIR/.claude/skills/joker"
  sync_template_path "$TEMPLATE_PERSP/.claude/skills/closer" "$PROJECT_DIR/.claude/skills/closer"
  sync_template_path "$TEMPLATE_PERSP/.claude/skills/verify-multi" "$PROJECT_DIR/.claude/skills/verify-multi"
  sync_template_path "$TEMPLATE_PERSP/.claude/skills/status" "$PROJECT_DIR/.claude/skills/status"
  sync_template_path "$TEMPLATE_PERSP/.claude/skills/ship" "$PROJECT_DIR/.claude/skills/ship"

  # Perspective rules
  sync_template_path "$TEMPLATE_PERSP/.claude/rules/perspective-protocol.md" "$PROJECT_DIR/.claude/rules/perspective-protocol.md"

  # Knowledge structure
  sync_template_path "$TEMPLATE_PERSP/knowledge" "$PROJECT_DIR/knowledge"

  # MCP servers
  sync_template_path "$TEMPLATE_PERSP/mcp-servers" "$PROJECT_DIR/mcp-servers"

  # Merge MCP server config into project settings.json
  if [ -f "$TEMPLATE_PERSP/.claude/settings.json" ]; then
    if dry_run "Merge MCP server config into .claude/settings.json"; then
      :
    elif command -v python3 >/dev/null 2>&1; then
      python3 - "$PROJECT_DIR/.claude/settings.json" "$TEMPLATE_PERSP/.claude/settings.json" <<'PYEOF'
import json, sys
proj_path, tmpl_path = sys.argv[1], sys.argv[2]
try:
    with open(proj_path) as f:
        proj = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    proj = {}
with open(tmpl_path) as f:
    tmpl = json.load(f)
# Merge mcpServers
if "mcpServers" in tmpl:
    proj.setdefault("mcpServers", {})
    for k, v in tmpl["mcpServers"].items():
        if k not in proj["mcpServers"]:
            proj["mcpServers"][k] = v
with open(proj_path, 'w') as f:
    json.dump(proj, f, indent=2, ensure_ascii=False)
    f.write('\n')
PYEOF
      log "Merged MCP server config into .claude/settings.json"
    else
      warn "python3 not available, skipping MCP server config merge"
    fi
  fi

  check_dev_env_cli
  log "Perspective overlay applied."
}

# Disable orchestra assets (when switching to ecc)
disable_orchestra_assets() {
  if [ "$MODE" != "ecc" ]; then
    return
  fi

  local ts
  ts="$(date +%Y%m%d-%H%M%S)"

  if [ -d "$PROJECT_DIR/.codex" ]; then
    local dest="$PROJECT_DIR/.codex.disabled"
    [ -e "$dest" ] && dest="$PROJECT_DIR/.codex.disabled-$ts"
    dry_run "Rename .codex to $(basename "$dest")" && return
    mv "$PROJECT_DIR/.codex" "$dest"
    log "Disabled: .codex → $(basename "$dest")"
  fi

  if [ -d "$PROJECT_DIR/.gemini" ]; then
    local dest="$PROJECT_DIR/.gemini.disabled"
    [ -e "$dest" ] && dest="$PROJECT_DIR/.gemini.disabled-$ts"
    dry_run "Rename .gemini to $(basename "$dest")" && return
    mv "$PROJECT_DIR/.gemini" "$dest"
    log "Disabled: .gemini → $(basename "$dest")"
  fi
}

# Main execution
main() {
  log "Routing project: $PROJECT_DIR"

  determine_mode
  validate_mode
  check_templates

  write_mode_file
  update_local_claude
  ensure_gitignore

  case "$MODE" in
    ecc)
      disable_orchestra_assets
      ;;
    orchestra)
      apply_orchestra_assets
      ;;
    hybrid)
      apply_orchestra_assets
      ;;
  esac

  # Apply perspective overlay (after base mode setup)
  apply_perspective_assets

  echo ""
  local mode_label="$MODE"
  if [ "$PERSPECTIVE" -eq 1 ] && [ "$MODE" != "ecc" ]; then
    mode_label="$MODE + perspective"
  fi
  log "✓ Project mode set to '$mode_label'"
  log "  Mode file: $MODE_FILE"
  log "  Local config: $LOCAL_CLAUDE_FILE"

  if [ "$MODE" = "orchestra" ] || [ "$MODE" = "hybrid" ]; then
    log "  Codex config: $PROJECT_DIR/.codex/"
    log "  Gemini config: $PROJECT_DIR/.gemini/"
  fi

  if [ "$PERSPECTIVE" -eq 1 ] && [ "$MODE" != "ecc" ]; then
    log "  Perspective config: $PROJECT_DIR/.claude/perspective.yaml"
    log "  Knowledge capsules: $PROJECT_DIR/knowledge/"
    log "  MCP servers: $PROJECT_DIR/mcp-servers/"
  fi
}

main
