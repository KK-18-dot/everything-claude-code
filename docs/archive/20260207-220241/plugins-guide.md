# Plugins Usage Guide

Use plugins intentionally to avoid context bloat and confusion.

## Principles
- Prefer official marketplace plugins only.
- Enable for a clear task; avoid leaving unused plugins active.
- Favor commands/skills/hooks when they are lighter.

## When to Use (Examples)
- `commit-commands`: commit/PR flows
- `code-review` / `pr-review-toolkit`: post-implementation reviews
- `feature-dev`: multi-step feature delivery
- `frontend-design`: UI work requiring stronger layout guidance
- `security-guidance`: sensitive changes (auth, secrets, payments)
- `hookify`: generating hooks safely
- `plugin-dev`: creating or modifying plugins

## Selection Checklist
- Does the plugin solve a concrete need right now?
- Is the context cost worth it for this task?
- Can a simpler command or skill do the same job?

## Default Policy
- No automatic plugin execution.
- Use on demand, then return to the minimal set.
