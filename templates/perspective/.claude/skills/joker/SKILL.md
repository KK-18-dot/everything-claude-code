---
name: joker
description: "Emergency agent with merged knowledge for stuck situations. Tier 2: use when same error occurs twice."
---

# /joker — Joker Invocation (PLAN Section 6.2, Level 4)

Emergency pattern for when normal escalation (OPERATOR → BUILDER → CONDUCTOR) has failed.

## Trigger Conditions
- Same error/approach has failed 2+ times
- Producer explicitly requests `/joker`

## Execution: 18→16 Relay

### Phase 1: Joker (18番 — 停滞打破)

Invoke ARCHITECT (脚本家 / Codex) with **temporarily merged knowledge**:
- Load ARCHITECT's own capsule
- Add GUARDIAN's incident playbooks (read-only)
- Add OPERATOR's runbooks (read-only)
- Add BUILDER's test fixtures (read-only)

Task: Root cause analysis + emergency fix proposal

### Phase 2: Closer (16番 — 固定化)

After Joker produces an emergency fix, run 3-perspective verification:
1. **編集 (CRITIC)**: Code quality of the emergency fix
2. **法務監修 (GUARDIAN)**: Security check on the fix
3. **映写技師 (OPERATOR)**: Production deployment safety

Then:
- Stabilize the fix (add tests, proper error handling)
- Record in postmortem (knowledge distillation to L3 Episodes)
- Update relevant capsule with the failure pattern

## Output

```
=== Joker Report ===

Root Cause: {analysis}
Emergency Fix: {what was done}
Confidence: {0.0-1.0}

--- Closer Verification ---
CRITIC:   {findings}
GUARDIAN: {findings}
OPERATOR: {findings}

Stabilization:
- [ ] Tests added
- [ ] Error handling added
- [ ] Postmortem recorded
- [ ] Capsule updated with failure pattern

Status: {STABILIZED / NEEDS_ATTENTION}
```

## Rules
- Joker knowledge merge is TEMPORARY (reverts after task)
- Always run Closer after Joker (never skip)
- Record the failure pattern for future prevention
- Budget for Joker is drawn from contingency (5%)
