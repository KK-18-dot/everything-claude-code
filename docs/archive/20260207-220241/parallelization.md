# Parallelization (Solo)

Parallel work is powerful but should stay minimal and intentional.

## Principles
- Use the smallest number of parallel sessions needed.
- Prefer "main changes, fork investigates."
- Keep scopes narrow and non-overlapping.

## Practical Patterns
- Writer/Reviewer: one session implements, another reviews.
- Fork Investigation: use a subagent or separate session for deep search.
- Cascade: a few terminals with fixed roles (code / tests / docs).

## Worktrees (Optional)
- Use git worktrees if you truly need parallel branches.
- Keep each worktree tied to a single Claude session.
