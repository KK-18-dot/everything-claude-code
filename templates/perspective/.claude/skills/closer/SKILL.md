---
name: closer
description: "Stabilize after Joker emergency fix. Tier 2: always follows /joker."
---

# /closer -- Post-Joker Stabilization

After /joker provides an emergency fix, /closer stabilizes the implementation.

## Input: $ARGUMENTS

The Joker's emergency fix output.

## Execution

### 1. Review Joker Output
- Read the joker's merged-knowledge fix
- Identify temporary workarounds vs proper fixes

### 2. Stabilize
- Replace temporary fixes with production-quality code
- Add proper error handling
- Ensure test coverage

### 3. Verify
Run /verify-multi on the stabilized code.

## Output

```
## Closer Report
- Stabilized: {list of fixes properly implemented}
- Tests: {pass/fail}
- Verdict: {STABLE / NEEDS_REVIEW}
```

## Rules
- Always follows /joker (never standalone)
- Must run /verify-multi before declaring STABLE
