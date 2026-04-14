# Test Planning

## Start with a user journey

Use:

```text
As a [role], I want to [action], so that [benefit].
```

For a bug fix, use:

```text
When [condition], the system should [expected behavior], but it currently [failure].
```

## Turn the journey into tests

For each journey, cover:

- primary success path
- boundary or empty input case
- failure path
- fallback behavior if the feature has one

## Choose the smallest useful test layer

- unit:
  - pure functions, components, helpers
- integration:
  - route handlers, DB/service boundaries, adapters
- E2E:
  - critical flows that must work in the browser/runtime

## Default workflow

1. write journey
2. write tests
3. run tests and confirm failure
4. implement minimum code
5. rerun tests
6. refactor
7. verify coverage
