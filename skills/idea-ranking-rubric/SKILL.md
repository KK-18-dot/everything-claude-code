---
name: idea-ranking-rubric
description: Rank ideas, automations, products, or workflow investments with a reusable rubric. Use when comparing multiple options, deciding what to build next, or separating high-leverage bets from low-value work.
---

# Idea Ranking Rubric

Use this skill when the user has multiple options and needs a defensible prioritization.

## Default Rubric

Read `references/default-rubric.md` unless the user already supplied dimensions or weights.

## Workflow

1. List the options clearly.
2. Score each option against the rubric.
3. Make trade-offs explicit instead of hiding them in a single total.
4. Produce:
   - per-dimension scores
   - total score
   - why the top option wins
   - what would change the ranking

## Output Shape

- `Option`
- `Why It Matters`
- `Scores`
- `Total`
- `Recommendation`

## Guardrails

- Do not pretend the rubric is objective truth.
- If information is missing, mark the assumption.
- Penalize hidden maintenance cost and dependency risk.
- Prefer the option with repeatable leverage over one-off novelty when scores are close.
