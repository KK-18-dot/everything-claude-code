---
name: debate
description: "Multi-perspective debate on a design decision. Tier 2: use when design bifurcation exists."
---

# /debate — Agent Debate (PLAN Section 6.1)

Structured multi-perspective discussion. **Only invoke when design bifurcation exists.**

## Input: $ARGUMENTS

The design question or bifurcation point, e.g.:
- "JWT vs Session for auth"
- "Monorepo vs polyrepo"
- "REST vs GraphQL for this API"

## Execution

### 1. Frame the Question
CONDUCTOR (監督) frames:
- Option A vs Option B (vs Option C if applicable)
- Evaluation criteria (max 5)

### 2. Perspective Opinions (parallel)
Each perspective responds ONLY from their expertise:
- **脚本家 (ARCHITECT)**: Structural and long-term impact
- **法務監修 (GUARDIAN)**: Security and compliance risks
- **撮影監督 (BUILDER)**: Implementation effort and speed
- **ロケハン (SCOUT)**: External data and adoption trends
- **映写技師 (OPERATOR)**: Operational and deployment impact

### 3. Synthesis
CONDUCTOR (監督) synthesizes:
- Recommendation with rationale
- Dissenting views preserved
- Conditions under which recommendation changes

## Output

```
## Debate: {question}

### Opinions
| Perspective | Position | Key Argument |
|---|---|---|
| 脚本家 | {A/B} | {1 sentence} |
| 法務監修 | {A/B} | {1 sentence} |
| 撮影監督 | {A/B} | {1 sentence} |
| ロケハン | {A/B} | {1 sentence} |
| 映写技師 | {A/B} | {1 sentence} |

### Synthesis
Recommendation: {A or B}
Rationale: {2-3 sentences}
Dissent: {who disagreed and why}

### Decision needed from Producer
{Clear question for approval}
```

## Rules
- Max 5 perspectives participate
- Each opinion is 1-3 sentences only
- Debate artifact saved to .claude/docs/research/debate-{topic}.md
- Never debate trivially obvious choices
