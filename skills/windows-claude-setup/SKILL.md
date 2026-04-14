---
name: windows-claude-setup
description: Use this skill when auditing, repairing, or standardizing a mixed WSL + Windows Claude Code setup. Covers canonical runtime selection, filesystem MCP repair, WSL-to-Windows mirror sync, and verification of hooks, routes, and representative projects.
---

# Windows Claude Setup

Use this skill for machine-level Claude Code maintenance in a mixed WSL + Windows environment.

This environment uses:
- WSL as the canonical runtime
- Windows native Claude as a compatibility mirror

Read these references before making changes:
- `references/repair-checklist.md`
- `~/.claude/docs/runtime-sync-policy.md`
- `~/.claude/docs/troubleshooting.md`
- `~/.claude/docs/operation-overview.md`

## Core Workflow

1. Confirm canonical files:
   - `~/.claude/`
   - `~/.claude.json`
   - `~/.codex/ops.md`
   - `~/.codex/rules/`

2. Audit active control points:
   - `~/.claude/CLAUDE.md`
   - `~/.claude/settings.json`
   - `~/.claude.json`
   - representative project mode files

3. Repair filesystem MCP first.
   - In WSL, use `npx -y @modelcontextprotocol/server-filesystem` with `/mnt/c/...` paths.
   - In Windows mirror, keep `cmd /c npx` with `C:\...` paths.

4. Sync shared assets into Windows with:
   - `~/.claude/scripts/sync-runtime-mirror.sh`

5. Verify representative projects:
   - `career-planning` should remain `orchestra`
   - `smart-buy-app` should remain `ecc`

## Guardrails

- Back up before editing runtime control files.
- Do not mirror runtime-specific files such as hooks, `settings.json`, history, sessions, cache, or telemetry.
- Treat WSL and Windows `.claude.json` as intentionally different at the `filesystem` MCP command layer.
- Prefer dry runs when syncing into `/mnt/c`.

## Expected Outputs

When using this skill, report:
- canonical vs mirror status
- MCP status
- project mode status
- exact remediation steps
- what still requires elevated write access
