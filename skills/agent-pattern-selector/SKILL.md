---
name: agent-pattern-selector
description: |
  Select the minimum effective AI execution pattern before implementation.
  Use when choosing among single prompt, chaining, routing, parallelization,
  orchestrator-workers, and evaluator-optimizer.
metadata:
  short-description: Pattern selection before orchestration
---

# Agent Pattern Selector

Start simple and escalate only when needed.

Order:
1. Single prompt
2. Prompt chaining
3. Routing
4. Parallelization
5. Orchestrator-workers
6. Evaluator-optimizer

## Procedure

1. Read `references/pattern-decision-table.md`.
2. Select one pattern and explain why.
3. List why heavier patterns are not selected.
4. Define verification metrics before execution.

## Output

```markdown
## Pattern Decision
- Task:
- Constraints:
- Selected pattern:
- Why selected:
- Why not heavier patterns:
- Verification plan:
```
