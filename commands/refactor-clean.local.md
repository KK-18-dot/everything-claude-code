# refactor-clean

Goal: Refactor safely without changing behavior.

Workflow:
- Restate intent and constraints.
- Identify smallest safe refactor steps.
- Make incremental edits and keep diffs small.
- Update docs/comments only when needed for clarity.
- Suggest tests or smoke checks; do not run them automatically.

Output:
- What changed and why.
- Risks or areas to double-check.
- Suggested verification commands.
