#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: bootstrap-pilot-harness.sh [project_dir]

Scaffold the experimental pilot-harness lane into a project.

Examples:
  bootstrap-pilot-harness.sh .
  bootstrap-pilot-harness.sh ~/Projects/my-app
USAGE
}

PROJECT_DIR="${1:-.}"

if [ "${PROJECT_DIR}" = "-h" ] || [ "${PROJECT_DIR}" = "--help" ]; then
  usage
  exit 0
fi

PROJECT_DIR="$(cd "${PROJECT_DIR}" && pwd)"
TEMPLATE_DIR="${HOME}/.claude/templates/pilot-harness"

if [ ! -d "${TEMPLATE_DIR}" ]; then
  echo "pilot-harness template not found: ${TEMPLATE_DIR}" >&2
  exit 1
fi

mkdir -p "${PROJECT_DIR}/.claude"

copy_dir() {
  local src="$1"
  local dest="$2"
  mkdir -p "${dest}"
  cp -Rn "${src}/." "${dest}/"
}

copy_dir "${TEMPLATE_DIR}/.claude/pilot" "${PROJECT_DIR}/.claude/pilot"
copy_dir "${TEMPLATE_DIR}/.claude/commands" "${PROJECT_DIR}/.claude/commands"

PROJECT_NAME="$(basename "${PROJECT_DIR}")"
if command -v sed >/dev/null 2>&1; then
  find "${PROJECT_DIR}/.claude/pilot" -type f -name '*.md' -exec sed -i "s/__PROJECT_NAME__/${PROJECT_NAME}/g" {} +
fi

cat <<EOF
Scaffolded pilot harness into:
  ${PROJECT_DIR}

Next:
  1. Edit .claude/pilot/spec.md
  2. Edit .claude/pilot/sprint-01-contract.md
  3. Run the first bounded sprint
EOF
