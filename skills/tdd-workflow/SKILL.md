---
name: tdd-workflow
description: Use when writing new features, fixing bugs, or refactoring code. Enforces test-first delivery with clear user journeys, failing tests before implementation, and verification across unit, integration, and E2E layers.
triggers:
  - "use tdd"
  - "write tests first"
  - "fix this bug"
  - "add tests"
  - "refactor safely"
---

# TDD Workflow

Use this skill when implementation quality depends on writing tests before code and verifying behavior through the right test layers.

## Working Model

1. Write the user journey first.
2. Turn the journey into failing tests.
3. Implement the smallest change that makes tests pass.
4. Refactor with tests still green.
5. Verify coverage and critical flows.

## Layer Selection

- User journeys and scope:
  - `references/test-planning.md`
- Unit, integration, and E2E examples:
  - `references/test-patterns.md`
- Mocks, coverage, CI, and anti-patterns:
  - `references/mocks-coverage-ci.md`

## Core Rules

- Tests before code.
- Cover happy path, edge cases, and error paths.
- Prefer behavior-focused assertions over implementation details.
- Use the smallest test layer that proves the requirement.
- Add E2E only for critical user flows and integration seams.

## Minimum Verification

- new functionality has tests
- bug fixes include a regression test
- failing test exists before implementation whenever feasible
- coverage meets repo standard or stays above 80% when no repo-specific threshold exists

## Output Contract

Return:

- user journey or failure statement
- planned test layers
- tests added or updated
- implementation added or changed
- verification commands run
- remaining gaps or follow-up tests

## Troubleshooting

### No clear user journey

Write the bug as a failing behavior statement before touching code.

### Test runner or environment is broken

Stabilize the smallest runnable test path first, then continue. Do not skip directly to implementation unless you record the reason.

### Coverage target is unrealistic for the repo

Use repo-native thresholds first. If none exist, use 80% as the default target and explain any intentional exception.

## Validation

- Trigger test:
  - activates on new feature, bug fix, refactor, or explicit TDD request
- Function test:
  - produces failing tests before implementation whenever feasible
- Performance test:
  - chooses only the necessary test layers and avoids unnecessary E2E sprawl

## References

- `references/test-planning.md`
- `references/test-patterns.md`
- `references/mocks-coverage-ci.md`
