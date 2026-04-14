---
name: agent-pattern-selector
description: |
  Select the right AI execution pattern before implementation.
  Use this in orchestra/hybrid when deciding among prompt chaining, routing,
  parallelization, orchestrator-workers, and evaluator-optimizer.
metadata:
  short-description: Pick the minimal effective agent pattern
---

# Agent Pattern Selector

Choose the simplest pattern that can satisfy the task.

Default order:
1. Single prompt
2. Prompt chaining
3. Routing
4. Parallelization
5. Orchestrator-workers
6. Evaluator-optimizer

## When to Use

- Task design is unclear before coding
- You need to choose between Claude-only and multi-agent execution
- Work can fail by over-orchestration (too many tools, too much latency)

## Mandatory Process

1. Classify the task with the decision table in `references/pattern-decision-table.md`
2. Declare selected pattern and rejection reasons for heavier patterns
3. Define verification for pattern success (speed, quality, token cost, failure rate)
4. Execute and record outcome in project notes

## Output Contract

```markdown
## Pattern Decision
- Task:
- Constraints:
- Selected pattern:
- Why this pattern:
- Why not heavier patterns:
- Verification plan:
```
