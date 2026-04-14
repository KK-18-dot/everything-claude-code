# Mocks, Coverage, CI, and Anti-Patterns

## Mock External Dependencies

Examples:

- Supabase
- Redis
- OpenAI

Keep mocks small and behavior-oriented. Do not recreate the whole dependency.

## Coverage

Default threshold when the repo has no stricter rule:

- branches: 80
- functions: 80
- lines: 80
- statements: 80

## Continuous Verification

- local watch mode during development
- pre-commit test/lint check
- CI coverage run on push/PR

## Common Mistakes

### Testing implementation details

Bad:

```typescript
expect(component.state.count).toBe(5)
```

Better:

```typescript
expect(screen.getByText("Count: 5")).toBeInTheDocument()
```

### Brittle selectors

Bad:

```typescript
await page.click(".css-class-xyz")
```

Better:

```typescript
await page.click('button:has-text("Submit")')
```

### Shared mutable test state

Each test should set up its own state unless the suite intentionally models a sequence.
