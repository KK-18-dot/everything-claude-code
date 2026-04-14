---
name: cast
description: "Assign perspectives to a task using the Capability Router. Tier 2: used by CONDUCTOR for task assignment."
---

# /cast -- Perspective Casting

Assign the right perspectives and models to a task based on the Capability Router.

## Input: $ARGUMENTS

The task description or task ID to cast perspectives for.

## Execution

### 1. Task Analysis
CONDUCTOR analyzes the task to determine:
- Task type: feature / bugfix / research / refactor
- Required perspectives (usually all 6, but some tasks need fewer)
- Wave assignment (A or B)

### 2. Capability Lookup
Read `.claude/perspective.yaml` for model bindings and use `dev-env cast` to:
- Get fixed model bindings for each perspective
- Check win-rates from agent_metrics
- Apply confidence boost from historical performance

### 3. Budget Allocation
Apply current formation from perspective.yaml.

## Output

```
=== Casting: {task title} ===

Wave A (parallel research + design):
  SCOUT ({display_name} / {model}): {specific research task}
  ARCHITECT ({display_name} / {model}): {specific design task}

Wave B (build then verify):
  BUILDER ({display_name} / {model}): {implementation task}
  ---
  GUARDIAN ({display_name} / {model}): security verification
  CRITIC ({display_name} / {model}): quality verification
  OPERATOR ({display_name} / {model}): operational verification

Win-rates:
  {perspective}: {rate}% ({total} tasks)

Debate: {needed / not needed}
```

## Rules
- Always use the fixed model pairings from perspective.yaml (never override)
- Win-rate adjustments affect confidence, not model selection
