---
name: project-env-router
description: |
  Route a project to ecc/orchestra/hybrid mode, optionally with perspective sub-mode.
  Use during project kickoff, when migrating repos, or when adding/removing
  Codex/Gemini/perspective support. Produces a recommendation, records the choice,
  and applies the minimum project-scoped overlay safely.
triggers:
  - "set up project mode"
  - "switch to ecc"
  - "switch to orchestra"
  - "enable codex"
  - "enable gemini"
  - "enable perspective"
  - "add perspective"
---

# Project Env Router

## Overview

This skill determines and applies the correct Claude Code environment for a project:
- **ecc**: Test-driven development with specialized agents
- **orchestra**: Multi-LLM coordination with Codex and Gemini
- **hybrid**: Both approaches combined (ecc priority)

## When to Use

- New project setup
- Migrating existing project to use Claude Code
- Switching modes (e.g., adding Codex/Gemini to an ecc project)
- Troubleshooting mode recognition issues

## Workflow

### Step 1: Check Current State

```bash
# Check if already configured
cat .claude/project-mode 2>/dev/null || echo "Not set"
head -3 CLAUDE.local.md 2>/dev/null || echo "No local config"
ls -la .codex .gemini 2>/dev/null || echo "No orchestra dirs"
```

### Step 2: Determine Appropriate Mode

Use criteria from `references/env-criteria.md`:

| Signal | Recommended Mode |
|--------|------------------|
| Frontend-heavy (React/Next.js) | ecc |
| TDD-focused development | ecc |
| Backend architecture decisions | orchestra |
| Research or multi-source analysis | orchestra |
| Large mixed project | hybrid |
| Unclear | default to ecc |

### Step 3: Apply with Script (Preferred)

```bash
# Interactive
~/.claude/scripts/project-env-router.sh .

# Non-interactive
~/.claude/scripts/project-env-router.sh . --mode ecc --no-prompt

# Orchestra with perspective (6-perspective differentiated architecture)
~/.claude/scripts/project-env-router.sh . --mode orchestra --perspective

# Add perspective to existing project
~/.claude/scripts/project-env-router.sh . --perspective --force

# Force re-apply
~/.claude/scripts/project-env-router.sh . --force

# Dry run (see what would happen)
~/.claude/scripts/project-env-router.sh . --mode orchestra --perspective --dry-run
```

### Step 4: Verify

```bash
# All three should be consistent
cat .claude/project-mode
head -3 CLAUDE.local.md
ls -la .codex .gemini 2>/dev/null
```

## What the Script Does

| Mode | Actions |
|------|---------|
| **ecc** | Write mode file, update CLAUDE.local.md, disable .codex/.gemini if present |
| **orchestra** | Write mode file, update CLAUDE.local.md, sync `.codex` / `.gemini`, add thin orchestra `.claude/` overlay, merge project `.mcp.json`, warn if CLIs missing |
| **hybrid** | Global ecc base + the same orchestra overlay |
| **+perspective** | Overlay: copy perspective.yaml, skills, hooks, knowledge/, mcp-servers/, merge MCP config |

## Manual Alternative

If you prefer not to use the script:

```bash
# 1. Create mode file
mkdir -p .claude
echo "orchestra" > .claude/project-mode

# 2. Create CLAUDE.local.md
cat > CLAUDE.local.md << 'EOF'
<!-- claude_env: orchestra -->
Mode: orchestra (ecc|orchestra|hybrid). Follow this mode for commands, skills, and integrations.
EOF

# 3. Copy thin orchestra overlay (orchestra example)
cp -R ~/.claude/templates/orchestra/.codex .
cp -R ~/.claude/templates/orchestra/.gemini .
cp ~/.claude/templates/orchestra/.mcp.json .

# 4. Add to .gitignore
echo "CLAUDE.local.md" >> .gitignore
```

## Switching Modes

### ecc → orchestra
```bash
claude-route . --mode orchestra --force
```

### orchestra → ecc
```bash
claude-route . --mode ecc --force
# .codex and .gemini are renamed to *.disabled (not deleted)
```

### Restoring disabled directories
```bash
mv .codex.disabled .codex
mv .gemini.disabled .gemini
claude-route . --mode orchestra --force
```

## Troubleshooting

See `~/.claude/docs/troubleshooting.md` for common issues.

## References

- `references/env-criteria.md` — Selection criteria
- `~/.claude/rules/project-mode.md` — Resolution priority
- `~/.claude/docs/template-policy.md` — Update and conflict policy
