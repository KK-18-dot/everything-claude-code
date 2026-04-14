---
description: Initialize project onboarding. Sets up project mode, creates CLAUDE.md draft, and produces an onboarding checklist.
---

# Kickoff

Initialize a new or existing project for Claude Code development.

## Prerequisites

Before running this command:
1. Ensure you're in the project root directory
2. Have basic project information ready (tech stack, commands, etc.)

## Workflow

### Step 1: Set Project Mode

If `.claude/project-mode` doesn't exist, run the router:

```bash
~/.claude/scripts/project-env-router.sh .
```

Or use the skill: `project-env-router`

### Step 2: Gather Information

Confirm the following (ask if not provided):

**Basic Info:**
- Project name
- Repository path
- Tech stack (languages, frameworks)

**Commands:**
- Dev server: `npm run dev` / `pnpm dev` / etc.
- Build: `npm run build`
- Test: `npm test` / `pytest` / etc.
- Lint: `npm run lint` / `ruff check .`
- Type check: `tsc --noEmit` / `mypy .`

**Environment:**
- Secrets location (`.env`, `.env.local`, vault, etc.)
- Required environment variables

**Quality Gates:**
- Workflow: Plan → Work → Review
- TDD required? Coverage threshold?
- Code review process

### Step 3: Discover Existing Docs

Check for existing documentation:
- `README.md`
- `CONTRIBUTING.md`
- `AGENTS.md`
- `CLAUDE.md` (existing)
- `.claude/` directory

### Step 4: Draft CLAUDE.md

Create a project-specific CLAUDE.md with:

```markdown
# Project: [Name]

## Overview
[Brief description]

## Tech Stack
- [Language/Framework]
- [Database]
- [Other tools]

## Commands
| Task | Command |
|------|---------|
| Dev | `npm run dev` |
| Build | `npm run build` |
| Test | `npm test` |
| Lint | `npm run lint` |

## Environment
- Secrets in: `.env.local` (git-ignored)
- Required vars: `DATABASE_URL`, `API_KEY`

## Quality Gates
- [ ] Plan before implementing complex features
- [ ] TDD for new features
- [ ] Code review before merge
- [ ] 80% test coverage

## Project-Specific Rules
[Any special considerations]
```

### Step 5: Confirm Before Writing

**Always ask for confirmation before writing files.**

Present:
1. CLAUDE.md draft
2. Any questions about missing information
3. Proposed file changes

Wait for explicit approval.

## Output

After confirmation:
- `CLAUDE.md` (created or updated)
- `.claude/project-mode` (if not present)
- `CLAUDE.local.md` (auto-generated)
- `.gitignore` entry for `CLAUDE.local.md`

## Next Steps Checklist

After kickoff, suggest:
- [ ] Review generated CLAUDE.md
- [ ] Run `/plan` for first feature
- [ ] Set up CI/CD if not present
- [ ] Configure pre-commit hooks
