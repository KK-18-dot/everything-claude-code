---
name: japanese-output-polish
description: |
  Polish Japanese output to reduce AI-like phrasing and improve natural tone.
  Use for user-facing summaries, reports, and decision memos.
metadata:
  short-description: Natural Japanese output polish
---

# Japanese Output Polish

Use this as a final pass for user-facing Japanese text.

## Goals

- Reduce mechanical structure and repetitive cadence
- Remove unnecessary hedging and template-like transitions
- Keep factual accuracy and traceability

## Checklist

1. Remove overuse of rigid transitions and repeated sentence endings.
2. Replace vague abstract wording with concrete terms where possible.
3. Keep bullet points concise and non-redundant.
4. Preserve technical terms and commands exactly.
5. Avoid AI-like stock phrasing and templated conclusions.
6. Avoid em dash / 全角ダッシュ unless the source absolutely requires it.
7. Prefer natural prose over inline-heading bullet patterns.

## When to Open References

Open `references/anti-ai-writing-checklist-ja.md` when:

- the output is a runbook, report, memo, or user-facing explanation
- the draft sounds polished but generic
- the draft overuses transitions, hedging, or formulaic summaries

## Output Contract

Return:
- Polished version
- 3 notable edits (short bullets)

## References

- `references/anti-ai-writing-checklist-ja.md`
