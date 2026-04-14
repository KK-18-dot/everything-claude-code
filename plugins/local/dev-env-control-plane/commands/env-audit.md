---
description: Audit the current Claude/Codex runtime, MCP state, hooks, and WSL/Windows drift; report the exact remediation steps.
---

# Environment Audit

Use this command when the user asks to:
- audit the Claude/Codex environment
- explain global setup
- diagnose hooks or MCP
- compare WSL and Windows runtime state
- check whether Everything Claude Code style assets are correctly applied

## Workflow

1. Read the current control plane:
   - `~/.claude/CLAUDE.md`
   - `~/.claude/settings.json`
   - `~/.claude.json`
   - `~/.codex/ops.md`
   - `~/.claude/docs/operation-overview.md`
   - `~/.claude/docs/runtime-sync-policy.md`
   - `~/.claude/docs/troubleshooting.md`

2. If the environment mixes WSL and Windows paths, use the `windows-claude-setup` skill.

3. Check, at minimum:
   - runtime identity (`cwd`, shell, WSL vs Windows)
   - global mode policy and router behavior
   - hooks configuration
   - `filesystem` MCP configuration and health
   - WSL canonical vs Windows mirror drift
   - representative project mode alignment for active projects

4. Report results in this format:
   - `Runtime Summary`
   - `Control Plane`
   - `Hooks`
   - `MCP`
   - `Drift / Risk`
   - `Remediation`

## Rules

- Be explicit about which file is canonical.
- Use exact paths in remediation steps.
- If verification cannot be completed because a command hangs or requires approval, state that clearly.
- Do not dump full configs unless the user asks; summarize the decisive lines only.
