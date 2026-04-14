# Pilot Harness Template

This template is an opt-in experimental lane for `planner / generator / evaluator` work.

It is not part of the default `ecc / orchestra / hybrid` router flow.

## Purpose

- scaffold reusable pilot artifacts
- keep long-running experimental work out of the normal lane
- make handoff, review, and decision artifacts explicit

## Includes

- `.claude/pilot/README.md`
- `.claude/pilot/spec.md`
- `.claude/pilot/evaluator-rubric.md`
- `.claude/pilot/sprint-01-contract.md`
- `.claude/pilot/sprint-01-review.md`
- `.claude/pilot/handoff.md`
- `.claude/pilot/two-stage-decision.md`
- `.claude/commands/pilot-sprint.md`

## Usage

```bash
~/.claude/scripts/bootstrap-pilot-harness.sh /path/to/project
```

Then edit the scaffolded files for the target project.

## Policy

- use only for long-running or high-ambiguity work
- do not auto-apply to all projects
- promote to global default only after multiple successful pilots
