---
name: status
description: "Show current progress, budget, and bottlenecks. Tier 1 command."
---

# /status — Session Status Dashboard (PLAN Section 11)

Show the Producer a concise overview of current session state.

## Output Format

```
=== dev-env status ===

Formation: {current formation, e.g., 4-2-3-1}

--- Tasks ---
Active:    {count} {brief list}
Pending:   {count}
Completed: {count}

--- Budget ---
Tokens: {spent}/{budget} ({percentage}%)
Time:   {elapsed}
Retries: {used}/{max}

--- Perspectives ---
CONDUCTOR (監督):      {status}
ARCHITECT (脚本家):    {last action or idle}
GUARDIAN  (法務監修):   {last action or idle}
BUILDER   (撮影監督):  {last action or idle}
SCOUT     (ロケハン):   {last action or idle}
CRITIC    (編集):       {last action or idle}
OPERATOR  (映写技師):   {last action or idle}

--- Bottlenecks ---
{Any blocked tasks, failed retries, or budget warnings}

--- Next Action ---
{The single most important next step}
```

## Data Sources
1. SQLite event log (.dev-env/dev-env.db)
2. Task board (tasks table)
3. Budget tracking (budget table)
4. Git worktree list

## Rules
- Fit in one screen (< 30 lines)
- Always end with "Next Action"
- Flag budget > 80% as warning
- Flag budget = 100% as STOP
