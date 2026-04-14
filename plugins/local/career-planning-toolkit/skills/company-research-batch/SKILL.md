---
name: company-research-batch
description: Run repeated company research in career-planning as a versioned pipeline instead of ad hoc prompts. Use when preparing batches, executing Gemini research, merging structured outputs, or deciding which research pipeline version to use.
---

# Company Research Batch

Use this skill inside the `career-planning` repo.

Default to the `v10.2` role-research pipeline unless the user explicitly asks for a legacy pipeline.

If needed, read `references/v10_2-working-set.md`.

## Guardrails

- Never mix versions silently.
- Prefer `dry-run` before apply steps.
- Use `research-verifier` when evidence is thin.
