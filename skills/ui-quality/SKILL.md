---
name: ui-quality
description: UI/UX, design, layout, Tailwind, shadcn, Radix, a11y, tokens, spacing, states. Use for screens, forms, and visual polish.
---

# UI Quality Skill

Use this skill when building or refining UI/UX.

## Core Rules
- Use Tailwind v4 tokens for colors/shadows/radius/spacing.
- 8px grid only.
- Typography: H1/H2/body only.
- States required: Empty/Loading/Error/Hover/Focus/Disabled.
- Forms must use Field/Label/Description/Error.
- Use Radix for Dialog/Dropdown/Tabs; keep focus visible.
- Avoid gradients and neon by default.

## Working Model

Before building, write:

1. visual thesis
2. content plan
3. interaction thesis

Use the review rubric in `references/review-rubric.md` when the task needs more than routine polish.

## Implementation Notes
- Prefer shadcn/ui for base components.
- Use semantic HTML (header/main/footer).
- Split large UI into smaller components.
- Prefer composition over card stacking.
- Avoid obvious AI-slop patterns such as random accent bars, generic dashboards, and decorative chrome with no information value.

## Verification
- Manual visual check for key flows.
- If critical UI, add Playwright screenshot test.

## References

- `references/review-rubric.md`
