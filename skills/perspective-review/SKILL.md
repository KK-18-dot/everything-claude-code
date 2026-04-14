---
name: perspective-review
description: Multi-perspective parallel review using GUARDIAN (security) and CRITIC (quality) agents. Produces a MergeVerdict (MERGE/REVISE/REJECT) with aggregated findings. Use for security-sensitive changes, refactors, or any change you want reviewed from multiple angles.
user-invocable: true
---

# /review --multi

Run GUARDIAN (security-reviewer) and CRITIC (code-reviewer) as parallel subagents on the current git diff. Aggregate their findings into a MergeVerdict.

## Workflow

### Step 1: Collect diff
```bash
git diff HEAD
```
If no uncommitted changes:
```bash
git diff HEAD~1 HEAD
```

### Step 2: Launch parallel subagents

Invoke both agents simultaneously with the diff as context:

**GUARDIAN prompt** (send to security-reviewer agent):
```
You are operating in GUARDIAN perspective. Review the following diff exclusively for security vulnerabilities.

Apply your Perspective Frame (GUARDIAN):
- Check every external input for injection, XSS, SSRF, deserialization risks
- Verify auth/authz on every endpoint
- Flag hardcoded secrets, weak crypto, missing rate limits
- Reference OWASP ASVS or CWE for every finding
- Include OPERATOR safety check: rollback plan, blast radius, monitoring gaps

DO NOT evaluate code style or readability.

Output format (strict):
## GUARDIAN Review
### Findings
- [CRITICAL|HIGH|MEDIUM|LOW] <title> — <CWE/OWASP ref>
  - Attack scenario: ...
  - Remediation: ...
### Deployment Safety
- Rollback plan: <present/missing>
- Blast radius: <assessment>
- Monitoring gaps: <list or "none">
### Verdict Input
risks: [list of RiskLevel values: CRITICAL/HIGH/MEDIUM/LOW]

<diff here>
```

**CRITIC prompt** (send to code-reviewer agent):
```
You are operating in CRITIC perspective. Review the following diff exclusively for code quality.

Apply your Perspective Frame (CRITIC):
- Classify findings by severity (CRITICAL/HIGH/MEDIUM/LOW)
- Measure cyclomatic complexity, flag if > 10
- Verify test coverage meets 80% threshold
- Check naming consistency
- Acknowledge good patterns found

DO NOT evaluate security vulnerabilities.

Output format (strict):
## CRITIC Review
### Findings
- [CRITICAL|HIGH|MEDIUM|LOW] <title>
  - Before: ...
  - After: ...
### Metrics
- Complexity: <score or N/A>
- Coverage estimate: <% or unknown>
- Good patterns: <list>
### Verdict Input
risks: [list of RiskLevel values: CRITICAL/HIGH/MEDIUM/LOW]

<diff here>
```

### Step 3: Compute MergeVerdict

Apply the following gate logic (from `artifact.py` MergeVerdict rules):

```
CRITICAL_count = count of CRITICAL risks across both reviews
HIGH_count     = count of HIGH risks across both reviews

if CRITICAL_count >= 1:
    verdict = REVISE
elif HIGH_count >= 2:
    verdict = REVISE
else:
    verdict = MERGE
```

Note: REJECT is reserved for cases where the change should be abandoned entirely (e.g., wrong direction, fundamental flaw). Use human judgment for REJECT.

### Step 4: Display result

```
## MergeVerdict: [MERGE ✅ | REVISE ⚠️ | REJECT ❌]

### GUARDIAN (Security + Deployment)
<GUARDIAN findings summary>

### CRITIC (Quality + Readability)
<CRITIC findings summary>

### Required Actions (if REVISE)
1. <action from CRITICAL/HIGH findings>
2. ...

### Confidence
GUARDIAN: <high/medium/low>
CRITIC: <high/medium/low>
```

## Usage

Invoke as: `/review --multi`

Typical trigger points:
- After implementing security-sensitive changes (auth, payments, input handling)
- After refactoring existing modules
- Before any deploy to production
- When unsure about code quality after a complex change

## Notes

- If git diff is large (>500 lines), focus subagents on the highest-risk files first
- GUARDIAN and CRITIC must not bleed into each other's domains — enforce separation
- This skill does NOT run tests; pair with `/tdd` or `tdd-guide` agent for test coverage
