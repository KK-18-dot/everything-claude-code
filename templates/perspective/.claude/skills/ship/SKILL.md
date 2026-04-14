---
name: ship
description: "Run quality gates and prepare for merge/deploy. Tier 1 command."
---

# /ship — Quality Gate & Ship (PLAN Section 9)

Run all quality gates and prepare the current work for merge.

## Pre-flight Checks (automated)

### 1. Test Gate
```bash
uv run pytest -v --tb=short
```
- All tests must pass
- Coverage must be >= 80%

### 2. Lint Gate
```bash
uv run ruff check . && uv run ruff format --check .
```
- Zero errors required

### 3. Multi-Perspective Verification
Launch 3 perspectives in parallel:
- **法務監修 (GUARDIAN)**: Security review of all changes
- **編集 (CRITIC)**: Code quality review of all changes
- **映写技師 (OPERATOR)**: Deployment readiness check

Each returns Output Contract JSON.

### 4. Merge Gate (automated, PLAN Section 9)

Apply rules:
- `CRITICAL >= 1` → auto REVISE (cannot ship)
- `HIGH >= 2` → requires Producer approval
- `tests` or `lint` fail → blocked
- Budget 100% → stopped

## Output

```
=== Ship Report ===

Tests:  {PASS/FAIL} ({passed}/{total}, coverage {X}%)
Lint:   {PASS/FAIL}

--- Perspective Reviews ---
GUARDIAN:  {CRITICAL: N, HIGH: N, MEDIUM: N}
CRITIC:   {CRITICAL: N, HIGH: N, MEDIUM: N}
OPERATOR: {CRITICAL: N, HIGH: N, MEDIUM: N}

Verdict: {MERGE / REVISE / REJECT}
Reason:  {why}

{If MERGE}: Ready for Producer's final approval.
{If REVISE}: Issues to fix: {list}
{If REJECT}: Blocked: {reason}
```

## Rules
- Never auto-merge without Producer confirmation
- Always show the verdict reason
- If REVISE, list the specific fixes needed
- Log verdict to SQLite event log
