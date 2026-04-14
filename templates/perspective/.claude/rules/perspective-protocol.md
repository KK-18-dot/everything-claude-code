# Perspective Protocol

## Activation

Perspective mode is **active** when `.claude/perspective.yaml` exists.

## Core Rules

1. **All tasks start with /kickoff** (intent-only input)
2. **2-Wave workflow** is mandatory for features:
   - Wave A: SCOUT + ARCHITECT (parallel) -> research & design
   - Wave B: BUILDER -> GUARDIAN + CRITIC + OPERATOR (verify)
3. **Output contract**: All perspective agents return PerspectiveOutput JSON
4. **Debate is conditional**: Only when design bifurcation is detected
5. **MergeVerdict** gates all merges:
   - CRITICAL >= 1 -> REVISE
   - HIGH >= 2 -> human approval
   - tests/lint fail -> REJECT

## Perspective Bindings

Read from `.claude/perspective.yaml`. Each perspective has:
- Fixed model (do NOT override at runtime)
- Fixed tool (CLI or subagent)
- Display name (customizable per project)

## Knowledge Layer

- L0 Anchors: `knowledge/capsules/shared-core/` (immutable)
- L1 Task: `knowledge/capsules/{perspective}/` (perspective-specific)
- L2 Evidence: In-memory cache of query results
- L3 Episodes: SQLite event store history

## Budget

Formation from perspective.yaml controls budget allocation.
Run `dev-env status` to check current budget usage.

## Commands

| Command | Purpose | Tier |
|---------|---------|------|
| /kickoff | Start new task | 1 |
| /status | Show progress | 1 |
| /ship | Final merge | 1 |
| /cast | Perspective assignment | 2 |
| /debate | Design bifurcation | 2 |
| /verify-multi | 3-perspective check | 2 |
| /joker | Emergency agent | 2 |
| /closer | Post-joker stabilize | 2 |
