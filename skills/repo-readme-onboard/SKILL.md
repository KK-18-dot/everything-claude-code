---
name: repo-readme-onboard
description: Audit or improve a repository README and onboarding surface. Use when a repo lacks a clear README, setup instructions are stale, commands are hard to discover, or a fast onboarding summary is needed from verified files.
---

# Repo README Onboard

Use this skill to produce a reliable onboarding view of a repository and, if asked, tighten the README with verified facts only.

## When To Use

- The repo has no README or an outdated one
- Setup instructions are incomplete
- A user asks for a quick onboarding summary
- Commands, environment rules, or project status need to be surfaced clearly

## Read In This Order

1. `README.md` if present
2. `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md` if present
3. package manifests or build files (`package.json`, `pyproject.toml`, `Cargo.toml`, etc.)
4. project docs that define workflow, roadmap, or environment policy

If needed, use `references/checklist.md`.

## Workflow

1. Inventory verified facts only.
2. Extract:
   - project purpose
   - main stack
   - install / run / build / test commands
   - environment and secrets handling at a high level
   - current status or roadmap if explicitly documented
3. Note gaps, contradictions, or stale instructions.
4. Produce one of these outputs:
   - concise onboarding summary
   - README patch plan
   - direct README edit if the user asked for file changes

## Guardrails

- Do not read `.env` or secrets files.
- Do not invent commands.
- Prefer compact READMEs over aspirational long-form docs.
- If commands conflict across files, say so explicitly instead of guessing.
