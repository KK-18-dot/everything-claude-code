---
description: Diagnose WSL/Windows mirror drift, sync failures, router mismatches, and cross-runtime configuration problems without taking destructive action.
---

# Sync Diagnose

Investigate sync or drift failures across WSL, Windows native Claude, and project-local mode state.

## Read First

- `~/.claude/docs/runtime-sync-policy.md`
- `~/.claude/docs/troubleshooting.md`
- `~/.claude/docs/operation-overview.md`
- `~/.claude/CLAUDE.md`

If the issue is project-specific, also read:
- `CLAUDE.local.md`
- `.claude/project-mode`
- relevant project `.claude/settings.json`, hooks, or local docs

## Workflow

1. Capture the exact symptom before editing anything.
2. Classify the failure:
   - WSL vs Windows runtime drift
   - project mode mismatch (`ecc` / `orchestra` / `hybrid`)
   - mirror sync omission
   - MCP failure
   - hooks/router failure
   - external sync issue (for example Obsidian or git-backed sync)
3. Compare the canonical WSL source with the affected mirror or project surface.
4. Use the `windows-claude-setup` skill when mixed WSL/Windows paths or launcher mismatches appear.
5. Prefer read-only verification first:
   - file existence
   - mode markers
   - `claude mcp list`
   - router dry-runs
   - debug logs
6. Only recommend edits after isolating the cause.

## Output Contract

Always return these sections:

### Symptoms
### Probable Cause
### Evidence
### Next Checks
### Recommended Action
