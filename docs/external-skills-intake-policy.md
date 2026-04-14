# External Skills Intake Policy

Use this policy before importing third-party skills.

## Required Checks

1. Source trust (owner, maintenance activity, license)
2. Execution safety (no destructive defaults, explicit script behavior)
3. Operational fit (`project-mode`, ecc/orchestra separation)
4. Ownership (local maintainer + review date)

## Procedure

1. Stage candidate in temporary path
2. Review SKILL and scripts manually
3. Pilot in one project
4. Promote to managed skill path only after approval
5. Record decision in repo docs

## Rollback

1. Remove skill from managed path
2. Re-run install + project re-route
3. Record failure reason and replacement plan
