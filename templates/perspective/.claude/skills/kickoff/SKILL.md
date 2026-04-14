---
name: kickoff
description: "Start a new task with Intent-Only flow. Tier 1 command: the primary way to begin work."
---

# /kickoff -- Intent-Only Start

Start a new task from the Producer's intent. This is the **primary entry point** for all work.

## Input: $ARGUMENTS

If no arguments provided, ask the Producer for:
1. What to build
2. Success criteria (3 items)
3. Constraints (timeline/budget)
4. NG items

## Execution Flow

As CONDUCTOR, read `.claude/perspective.yaml` for perspective bindings, then:

### 1. Requirements Normalization
- Parse intent into structured format
- Identify task type: feature / bugfix / research / refactor

### 2. 2-Wave Execution Plan
- **Wave A**: SCOUT + ARCHITECT in parallel -- research & design
- **Wave B**: BUILDER implements, then GUARDIAN + CRITIC + OPERATOR verify in parallel

### 3. Budget Setting
- Estimate time/token/retry budget per perspective
- Apply current formation from perspective.yaml

### 4. Debate Necessity Check
- If design bifurcation exists -> flag for debate after Wave A
- If single obvious approach -> skip debate, proceed to Wave B

## Output (fixed 4 blocks)

```
## Scope
{What will be built, what won't}

## Plan (2-wave)
Wave A: {SCOUT task} + {ARCHITECT task} (parallel)
Wave B: {BUILDER task} -> {GUARDIAN + CRITIC + OPERATOR verification}

## Risks
{Top 2-3 risks with mitigation}

## First Action
{The exact first step to execute now}
```

## Rules
- Never ask more than 1 clarifying question
- Output Contract (PerspectiveOutput JSON) for all perspective returns
- Long details go to artifact files, not chat
