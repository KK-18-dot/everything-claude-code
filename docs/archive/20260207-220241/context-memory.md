# Context and Memory (Solo)

Use this guide to keep sessions focused and avoid context overload.

## Session Controls
- `/clear`: Use between unrelated tasks.
- `/compact`: Use after exploration or a major milestone, before implementation.
- `/rewind`: Use after risky changes or when you want a clean rollback.
- `claude --continue` or `/resume`: Use for multi-session work.
- `/rename`: Name long-running sessions for quick retrieval.

## Recommended Rhythm
- Explore -> `/compact` -> Implement -> Verify -> `/compact` (optional)
- If the same issue is corrected twice, `/clear` and restate requirements.

## Failure Patterns to Avoid
- Mixing unrelated tasks in one session.
- Long instruction lists that hide key rules.
- Infinite exploration without a concrete next action.
