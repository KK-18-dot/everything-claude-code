---
description: Prepare, run, or review repeated company research batches for the career-planning dataset. Use this plugin inside the career-planning repo and default to the v10.2 role-research pipeline unless the user asks for an older pipeline.
---

# Research Batch Companies

Run this command from the `career-planning` project root.

## Read First

- `CLAUDE.local.md`
- `evaluation_framework_v10.2.md`
- `evaluation_rubric.md`
- `companies_db_schema_v10.2.json`
- `companies_db_v10.2.json`
- `v10_2_score_report.json`

Use the `company-research-batch` skill.

## Default Pipeline

1. `python3 scripts/prepare_role_research_v10_2.py`
2. `python3 scripts/run_role_research_v10_2.py --batch-dir /tmp/role_research_v10_2_batches --raw-dir /tmp/role_research_v10_2_raw`
3. `python3 scripts/apply_role_research_v10_2.py dry-run`
4. `python3 scripts/apply_role_research_v10_2.py all`

Use `research-verifier` before merge when the research output is surprising or weakly supported.
