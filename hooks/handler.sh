#!/usr/bin/env bash
set -euo pipefail

event_name="${1:-}"

raw=""
if [ -t 0 ]; then
  raw=""
else
  raw="$(cat)"
fi

tool=""
command=""
file_path=""

if [ -n "$raw" ]; then
  eval "$(RAW_INPUT="$raw" python3 - <<'PY'
import json
import os
import shlex

raw = os.environ.get("RAW_INPUT", "")
tool = ""
command = ""
file_path = ""

try:
    payload = json.loads(raw) if raw.strip() else None
except Exception:
    payload = None

if isinstance(payload, dict):
    tool = payload.get("tool") or payload.get("tool_name") or ""
    tool_input = payload.get("tool_input") or {}
    if isinstance(tool_input, dict):
        command = tool_input.get("command") or ""
        file_path = tool_input.get("file_path") or tool_input.get("path") or ""

print(f"tool={shlex.quote(str(tool))}")
print(f"command={shlex.quote(str(command))}")
print(f"file_path={shlex.quote(str(file_path))}")
PY
)"
fi

warnings=()
actions=()

sanitize_log_value() {
  local value="${1:-}"
  if [ -z "$value" ]; then
    echo ""
    return
  fi
  if echo "$value" | grep -Eiq 'token|secret|key|authorization|password'; then
    echo "<redacted>"
    return
  fi
  local v="${value//\"/\'}"
  v=$(echo "$v" | tr '\n' ' ' | tr -s ' ')
  v="${v#"${v%%[![:space:]]*}"}"
  v="${v%"${v##*[![:space:]]}"}"
  echo "$v"
}

get_compact_counter_path() {
  local base="${TMPDIR:-}"
  if [ -z "$base" ] && [ -d "$HOME/DevSandbox" ]; then
    base="$HOME/DevSandbox"
  fi
  if [ -z "$base" ]; then
    base="/tmp"
  fi
  echo "$base/claude-compact-counter.json"
}

get_compact_count() {
  local path
  path="$(get_compact_counter_path)"
  if [ ! -f "$path" ]; then
    echo 0
    return
  fi
  python3 - <<'PY' "$path" 2>/dev/null || echo 0
import json
import sys

try:
    path = sys.argv[1] if len(sys.argv) > 1 else ""
    if not path:
        print(0)
        raise SystemExit
    with open(path, "r", encoding="utf-8") as handle:
        raw = handle.read()
    if not raw.strip():
        print(0)
    else:
        obj = json.loads(raw)
        count = obj.get("count", 0)
        print(int(count) if isinstance(count, int) else 0)
except Exception:
    print(0)
PY
}

set_compact_count() {
  local count="${1:-0}"
  local path
  path="$(get_compact_counter_path)"
  mkdir -p "$(dirname "$path")" 2>/dev/null || true
  python3 - <<'PY' >"$path" 2>/dev/null || true
import json
import sys
from datetime import datetime

count = int(sys.argv[1]) if len(sys.argv) > 1 else 0
obj = {"count": count, "updatedAt": datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
print(json.dumps(obj, separators=(',', ':')))
PY "$count"
}

in_git_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

get_git_diff_text() {
  if ! in_git_repo; then
    echo ""
    return
  fi
  local diff cached
  diff=$(git diff -U0 2>/dev/null || true)
  cached=$(git diff --cached -U0 2>/dev/null || true)
  printf '%s\n%s' "$diff" "$cached"
}

has_possible_secret_in_diff() {
  local diff_text="$1"
  [ -z "$diff_text" ] && return 1
  local patterns=(
    '(?i)\b(api[_-]?key|secret|token|password)\b'
    '(?i)\bauthorization\b'
    '(?i)bearer\s+[a-z0-9\-\._=]{10,}'
    '(?i)-----BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY-----'
    '(?i)\bsk-[a-z0-9]{20,}\b'
    '(?i)\bAKIA[0-9A-Z]{16}\b'
    '(?i)\bAIza[0-9A-Za-z\-_]{35}\b'
  )
  while IFS= read -r line; do
    [[ $line == +++* ]] && continue
    [[ $line != +* ]] && continue
    for pattern in "${patterns[@]}"; do
      if echo "$line" | grep -Eiq "$pattern"; then
        return 0
      fi
    done
  done <<<"$diff_text"
  return 1
}

is_destructive_command() {
  local cmd="${1:-}"
  [ -z "$cmd" ] && return 1
  local patterns=(
    '(^|[[:space:]])rm[[:space:]]+-rf([[:space:]]|$)'
    '(^|[[:space:]])del[[:space:]]+/f([[:space:]]|$)'
    '(^|[[:space:]])rd[[:space:]]+/s[[:space:]]+/q([[:space:]]|$)'
    '(^|[[:space:]])rmdir[[:space:]]+/s[[:space:]]+/q([[:space:]]|$)'
    'Remove-Item.*-Recurse.*-Force'
    'git[[:space:]]+reset[[:space:]]+--hard'
    'git[[:space:]]+clean[[:space:]]+-fdx'
    '(^|[[:space:]])format([[:space:]]|$)'
    '(^|[[:space:]])mkfs([[:space:]]|$)'
    'dd[[:space:]]+if='
  )
  for pattern in "${patterns[@]}"; do
    if echo "$cmd" | grep -Eiq "$pattern"; then
      return 0
    fi
  done
  return 1
}

is_js_ts_file() {
  local path="${1:-}"
  local ext="${path##*.}"
  case "${ext,,}" in
    js|jsx|ts|tsx|mjs|cjs) return 0 ;;
    *) return 1 ;;
  esac
}

find_up_with_file() {
  local start_dir="$1"
  local filename="$2"
  local dir="$start_dir"
  while [ -n "$dir" ] && [ -d "$dir" ]; do
    if [ -f "$dir/$filename" ]; then
      echo "$dir"
      return 0
    fi
    local parent
    parent="$(dirname "$dir")"
    [ "$parent" = "$dir" ] && break
    dir="$parent"
  done
  return 1
}

is_docs_path() {
  local path="${1:-}"
  [ -z "$path" ] && return 1
  local norm="${path//\\//}"
  if echo "$norm" | grep -Eiq '(^|/)docs/'; then
    return 0
  fi
  local base
  base="$(basename "$norm")"
  if echo "$base" | grep -Eiq '^readme(\.|$)'; then
    return 0
  fi
  return 1
}

get_local_bin() {
  local root="${1:-}"
  local bin_name="${2:-}"
  [ -z "$root" ] && return 1
  local path="$root/node_modules/.bin/$bin_name"
  [ -x "$path" ] && echo "$path" && return 0
  [ -f "$path" ] && echo "$path" && return 0
  return 1
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

get_test_script() {
  local pkg_root="${1:-}"
  [ -z "$pkg_root" ] && return 1
  local pkg_path="$pkg_root/package.json"
  [ ! -f "$pkg_path" ] && return 1
  python3 - <<'PY' "$pkg_path" 2>/dev/null
import json
import sys

try:
    path = sys.argv[1] if len(sys.argv) > 1 else ""
    if not path:
        raise SystemExit
    with open(path, "r", encoding="utf-8") as handle:
        pkg = json.load(handle)
    scripts = pkg.get("scripts") or {}
    script = scripts.get("test") or ""
    if script:
        print(script)
except Exception:
    pass
PY
}

is_heavy_test_script() {
  local script="${1:-}"
  [ -z "$script" ] && return 1
  echo "$script" | grep -Eiq 'playwright|cypress|e2e|coverage|--watch|--runInBand'
}

get_git_root() {
  in_git_repo && git rev-parse --show-toplevel 2>/dev/null || true
}

get_git_branch() {
  in_git_repo && git rev-parse --abbrev-ref HEAD 2>/dev/null || true
}

get_git_status_short() {
  in_git_repo && git status --short 2>/dev/null || true
}

get_git_changed_files() {
  if ! in_git_repo; then
    return
  fi
  git diff --name-only 2>/dev/null || true
  git diff --cached --name-only 2>/dev/null || true
}

filter_sensitive_paths() {
  local filtered=()
  local path
  while IFS= read -r path; do
    [ -z "$path" ] && continue
    if echo "$path" | grep -Eiq '(^|/|\\)\.env(\.|$)'; then
      continue
    fi
    if echo "$path" | grep -Eiq '(^|/|\\)secrets(/|\\)'; then
      continue
    fi
    filtered+=("$path")
  done
  printf '%s\n' "${filtered[@]}"
}

write_session_log() {
  [ "${CLAUDE_SESSION_LOG:-}" != "1" ] && return
  local base="$HOME/DevSandbox/session-logs"
  mkdir -p "$base" 2>/dev/null || return
  local timestamp
  timestamp=$(date +'%Y%m%d-%H%M%S')
  local log_path="$base/claude-session-$timestamp.txt"

  local tool_log cmd_log path_log
  tool_log="$(sanitize_log_value "${1:-}")"
  cmd_log="$(sanitize_log_value "${2:-}")"
  path_log="$(sanitize_log_value "${3:-}")"

  {
    echo "timestamp: $(date +'%Y-%m-%d %H:%M:%S')"
    echo "event: ${event_name}"
    echo "tool: ${tool_log}"
    echo "command: ${cmd_log}"
    echo "file: ${path_log}"

    local root branch
    root=$(get_git_root | tr -d '\r')
    [ -n "$root" ] && echo "repo: $root"
    branch=$(get_git_branch | tr -d '\r')
    [ -n "$branch" ] && echo "branch: $branch"

    local status
    status=$(get_git_status_short)
    if [ -n "$status" ]; then
      echo "status:"
      echo "$status" | sed 's/^/  /'
    fi

    local changed
    changed=$(get_git_changed_files | filter_sensitive_paths)
    if [ -n "$changed" ]; then
      echo "changed_files:"
      echo "$changed" | sed 's/^/  /'
    fi
  } >"$log_path" 2>/dev/null || true
}

run_with_timeout() {
  local timeout_sec="$1"
  shift
  timeout "${timeout_sec}s" "$@" >/dev/null 2>&1
  local code=$?
  if [ $code -eq 0 ]; then
    echo "ok"
  elif [ $code -eq 124 ]; then
    echo "timeout"
  else
    echo "failed"
  fi
}

mode="${HOOK_MODE:-warning}"
mode="${mode,,}"
active_mode=false
[ "$mode" = "active" ] && active_mode=true

case "$event_name" in
  PreToolUse)
    compact_threshold=25
    count=$(get_compact_count)
    count=$((count + 1))
    if [ "$count" -ge "$compact_threshold" ]; then
      warnings+=("WARNING: Consider running /compact after exploration or before the next major step.")
      count=0
    fi
    set_compact_count "$count"

    if [ -n "$command" ]; then
      cmd_trim=$(echo "$command" | sed -E 's/^\s+//;s/\s+$//')
      first_token="${cmd_trim%% *}"
      first_token="${first_token,,}"
      long_cmds=(npm pnpm yarn bun cargo pytest vitest playwright docker make)
      for c in "${long_cmds[@]}"; do
        if [ "$first_token" = "$c" ]; then
          warnings+=("WARNING: This command may take time. Consider running it when you can monitor progress.")
          break
        fi
      done
      if is_destructive_command "$command"; then
        warnings+=("WARNING: This command looks destructive. Double-check before running.")
      fi
      if echo "$command" | grep -Eiq '\bgit\s+push\b'; then
        warnings+=("WARNING: Consider reviewing changes before git push.")
      fi
    fi

    if [ "${tool:-}" = "Write" ] && [ -n "$file_path" ]; then
      if echo "$file_path" | grep -Eiq '\.(md|txt)$'; then
        if ! echo "$file_path" | grep -Eiq '(README|CLAUDE|AGENTS|CONTRIBUTING)\.md$'; then
          if ! echo "${file_path//\\//}" | grep -Eiq '(^|/)docs/'; then
            warnings+=("WARNING: Consider consolidating docs into README.md/CLAUDE.md/AGENTS.md/CONTRIBUTING.md.")
          fi
        fi
      fi
    fi
    ;;
  PostToolUse)
    warnings+=("WARNING: Consider running format, typecheck, and tests for this change.")

    if [ -n "$file_path" ] && [ -f "$file_path" ]; then
      if grep -q 'console.log' "$file_path" 2>/dev/null; then
        warnings+=("WARNING: console.log found in edited file. Consider removing before commit.")
      fi
    fi

    active_eligible=false
    if $active_mode && [[ "${tool:-}" =~ ^(Edit|Update)$ ]]; then
      if [ -n "$file_path" ] && [ -f "$file_path" ] && is_js_ts_file "$file_path"; then
        active_eligible=true
      fi
    fi

    if $active_eligible; then
      actions+=("HOOK_MODE=active summary:")
      start_dir="$(dirname "$file_path")"
      pkg_root="$(find_up_with_file "$start_dir" "package.json" || true)"

      if is_js_ts_file "$file_path"; then
        prettier_path="$(get_local_bin "$pkg_root" "prettier" || true)"
        work_dir="${pkg_root:-$start_dir}"
        if [ -n "$prettier_path" ]; then
          status=$( (cd "$work_dir" && run_with_timeout 60 "$prettier_path" --write "$file_path") )
          actions+=("prettier: $status")
        elif has_command npx; then
          status=$( (cd "$work_dir" && run_with_timeout 60 npx -y prettier --write "$file_path") )
          actions+=("prettier: $status")
        else
          actions+=("prettier: skipped")
        fi
      else
        actions+=("prettier: skipped")
      fi

      ts_root="$(find_up_with_file "$start_dir" "tsconfig.json" || true)"
      if [ -n "$ts_root" ]; then
        tsc_path="$(get_local_bin "$ts_root" "tsc" || true)"
        [ -z "$tsc_path" ] && tsc_path="$(get_local_bin "$pkg_root" "tsc" || true)"
        if [ -n "$tsc_path" ]; then
          status=$( (cd "$ts_root" && run_with_timeout 60 "$tsc_path" --noEmit --pretty false) )
          actions+=("tsc: $status")
        elif has_command npx; then
          status=$( (cd "$ts_root" && run_with_timeout 60 npx -y tsc --noEmit --pretty false) )
          actions+=("tsc: $status")
        else
          actions+=("tsc: skipped")
        fi
      else
        actions+=("tsc: skipped")
      fi

      if [ -n "$pkg_root" ]; then
        test_script="$(get_test_script "$pkg_root" || true)"
        if [ -n "$test_script" ] && ! echo "$test_script" | grep -Eiq 'no test specified'; then
          if is_heavy_test_script "$test_script"; then
            actions+=("npm test: skipped")
          elif is_docs_path "$file_path"; then
            actions+=("npm test: skipped")
          else
            status=$( (cd "$pkg_root" && run_with_timeout 60 npm test) )
            actions+=("npm test: $status")
          fi
        else
          actions+=("npm test: skipped")
        fi
      else
        actions+=("npm test: skipped")
      fi
    fi
    ;;
  Stop)
    if type get_git_diff_text >/dev/null 2>&1; then
      diff_text="$(get_git_diff_text)"
    else
      if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        diff_text="$(git diff -U0 2>/dev/null || true)$(printf '\n')$(git diff --cached -U0 2>/dev/null || true)"
      else
        diff_text=""
      fi
    fi
    if [ -n "$diff_text" ]; then
      if has_possible_secret_in_diff "$diff_text"; then
        warnings+=("WARNING: git diff contains possible secrets. Remove or rotate before commit.")
      fi
      if echo "$diff_text" | grep -Eiq '\bconsole\.log\b|\bTODO\b|\bFIXME\b'; then
        warnings+=("WARNING: git diff contains console.log / TODO / FIXME. Consider cleaning before commit.")
      fi
    fi
    write_session_log "${tool:-}" "${command:-}" "${file_path:-}"
    ;;
  *)
    ;;
esac

if [ "${CLAUDE_HOOK_DEBUG:-}" = "1" ]; then
  log_path="$HOME/.claude/hooks/hook.log"
  tool_log="$(sanitize_log_value "${tool:-}")"
  cmd_log="$(sanitize_log_value "${command:-}")"
  path_log="$(sanitize_log_value "${file_path:-}")"
  [ -z "$tool_log" ] && tool_log="(unknown)"
  [ -z "$cmd_log" ] && cmd_log="<none>"
  [ -z "$path_log" ] && path_log="<none>"
  printf '%s event=%s tool=%s cmd="%s" path="%s"\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$event_name" "$tool_log" "$cmd_log" "$path_log" >>"$log_path" 2>/dev/null || true
fi

emit=false
[ "${#warnings[@]}" -gt 0 ] && emit=true
if $active_mode && [ "$event_name" = "PostToolUse" ]; then
  emit=true
fi

if $emit; then
  lines=()
  for w in "${warnings[@]}"; do
    lines+=("$w")
  done
  for a in "${actions[@]}"; do
    lines+=("$a")
  done
  if [ "${#lines[@]}" -gt 0 ]; then
    msg=$(printf '%s\n' "${lines[@]}")
    python3 - <<'PY' <<<"$msg"
import json
import sys

msg = sys.stdin.read().rstrip('\n')
print(json.dumps({"systemMessage": msg, "suppressOutput": True}, ensure_ascii=False))
PY
  fi
fi

exit 0
