---
name: verify-multi
description: "3-perspective parallel verification (GUARDIAN + CRITIC + OPERATOR). Tier 2: used after BUILDER completes implementation."
---

# /verify-multi -- 3-Perspective Parallel Verification

Run GUARDIAN + CRITIC + OPERATOR in parallel to verify BUILDER's output.

## Input: $ARGUMENTS

The implementation output or file paths to verify.

## Execution

Launch 3 parallel sub-agents with perspective-specific prompts:

### GUARDIAN (Security & Reliability)
- Check for security vulnerabilities (OWASP Top 10)
- Validate error handling and edge cases
- Assess reliability and failure modes

### CRITIC (Quality & Standards)
- Code quality review (naming, structure, patterns)
- Consistency with project style
- Test coverage assessment

### OPERATOR (Operations & Deployment)
- Operational readiness check
- Performance implications
- Monitoring and observability

## Output

Each perspective returns PerspectiveOutput:
```json
{
  "summary": ["max 5 bullets"],
  "risks": [{"level": "CRITICAL|HIGH|MEDIUM|LOW", "item": "..."}],
  "actions": ["max 3 next steps"],
  "confidence": 0.0-1.0,
  "artifact_path": "path/to/detail.md"
}
```

## MergeVerdict
- CRITICAL >= 1 -> REVISE (mandatory fix)
- HIGH >= 2 -> REVISE (human approval required)
- tests/lint fail -> REJECT
- Otherwise -> MERGE
