# Pattern Decision Table

| Pattern | Use When | Stop Conditions | Common Failure |
|---|---|---|---|
| Single prompt | Task is narrow and deterministic | One-pass output meets criteria | Unnecessary over-structuring |
| Prompt chaining | Sequential stages are clear | Stage output is objectively checkable | Too many stages increase cost |
| Routing | Inputs can be classified reliably | Route confidence remains stable | Misrouting degrades quality silently |
| Parallelization | Subtasks are independent | Merge logic is deterministic | Weak merger causes inconsistency |
| Orchestrator-workers | Runtime decomposition is needed | Work units and budgets are bounded | Task explosion and context churn |
| Evaluator-optimizer | Quality criteria are explicit | Max loops and acceptance gate are set | Endless loops with vague feedback |

## Heuristics

1. Start with the simplest pattern.
2. Escalate one level per observed bottleneck.
3. Define success metrics before execution.
4. Cap retries and total iterations.
