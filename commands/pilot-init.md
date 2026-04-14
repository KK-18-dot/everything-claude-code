---
description: Scaffold the experimental pilot-harness lane into the current project and define the first sprint.
---

# Pilot Init

Initialize the opt-in pilot harness for the current project.

## Workflow

1. Run:

```bash
~/.claude/scripts/bootstrap-pilot-harness.sh .
```

2. Customize:

- `.claude/pilot/spec.md`
- `.claude/pilot/sprint-01-contract.md`

3. Keep the first sprint narrow:

- one bounded problem
- one clear verification target
- one handoff file

## Policy

- this is experimental
- do not treat it as the default project workflow
- use it only when the task is long-running or structurally ambiguous
