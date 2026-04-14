---
description: Resume a project by summarizing current state, identifying the next highest-leverage step, and separating user-owned work from AI-owned work.
---

# Continue Project

Use this command when the user says things like:
- "continue the project"
- "what's the next step?"
- "wrap up the current phase"
- "tell me what I should do and what you should do"

## Required Behavior

1. Read project context first:
   - `CLAUDE.md`
   - `CLAUDE.local.md`
   - `.claude/project-mode`
   - `README.md` and any obvious roadmap / status docs
   - current git status if available

2. Invoke the `next-step-operator` agent unless the task is too small to justify delegation.

3. Output these sections in order:
   - `Current State`
   - `Next AI Step`
   - `Next User Step`
   - `Risks / Blockers`
   - `Recommended Immediate Action`

## Rules

- Do not answer with a vague motivational summary.
- Prefer one concrete next action over a long backlog.
- If the project is blocked by missing information, say exactly what is missing.
- If the next step is the assistant's responsibility, start executing it unless the user asked to only summarize.
- If the next step is the user's responsibility, make it specific and testable.
