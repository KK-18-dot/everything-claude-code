---
name: project-onboarding
description: Create or refresh a project CLAUDE.md and onboarding context for a new or existing repo. Use when starting a project, standardizing project rules, or aligning commands, quality gates, and secrets handling.
---

# Project Onboarding

## Goal
Produce a project CLAUDE.md draft and a minimal onboarding checklist.

## Inputs to Collect
- Project name and repo path
- Tech stack
- Primary commands (dev/build/test/lint/typecheck)
- Secrets policy and env var source
- Existing docs (README/AGENTS/CONTRIBUTING/CLAUDE)

## Process
1. Discover relevant docs and commands.
2. Draft CLAUDE.md using the template; fill only verified facts.
3. List open questions for missing info.
4. Ask for confirmation before writing any file.

## Output
- CLAUDE.md draft text
- Open questions list
- Suggested next steps

## Resources
- CLAUDE.md template: references/CLAUDE_TEMPLATE.md (read before drafting)

## Guardrails
- Do not read .env or secrets files.
- Do not modify files until user confirms.
