# Pattern Decision Table

Use this table to pick the minimum viable orchestration pattern.

| Pattern | Use When | Stop Conditions | Common Failure |
|---|---|---|---|
| Single prompt | Scope is narrow, deterministic, low-risk | One pass gets acceptable result | Overfitting by adding unnecessary structure |
| Prompt chaining | Clear sequential stages exist | Each stage has objective output check | Too many stages increase latency/cost |
| Routing | Inputs are heterogeneous and classifiable | Classifier confidence is stable | Wrong route produces silent quality drop |
| Parallelization | Independent subtasks can run concurrently | Merger has deterministic combine logic | Merge step loses consistency |
| Orchestrator-workers | Task decomposition is dynamic at runtime | Work units and budgets are bounded | Task explosion, excessive context churn |
| Evaluator-optimizer | Quality can be measured with explicit criteria | Max iteration count and acceptance gate set | Endless loops with vague evaluator feedback |

## Selection Heuristics

1. Start from single prompt.
2. Move up one level only when a concrete bottleneck appears.
3. Define exit criteria before running any multi-step pattern.
4. Cap retries and total iterations.

## Minimal Metrics

- **Latency**: end-to-end execution time
- **Quality**: tests passed or checklist completion
- **Cost proxy**: number of turns, output size, tool calls
- **Reliability**: first-pass success rate
