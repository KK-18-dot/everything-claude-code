---
name: context-handoff
description: |
  Create a compact handoff before clearing context or ending a session.
  Use when switching tasks, switching tools, or after repeated failed attempts.
metadata:
  short-description: Session handoff for fast resume
---

# Context Handoff

Generate a short handoff note before `/clear` or session end.

## Trigger Conditions

- Task is not finished but session should end
- Two failed attempts require context reset
- Tool switch is needed (Claude/Codex/Gemini)

## Output Template

```markdown
## Handoff
- Goal:
- Current status:
- Completed:
- Blockers:
- Next step:
- First command to run:
```

## Constraints

- Keep under 10 lines
- Include exactly one next step
- Include one concrete first command
