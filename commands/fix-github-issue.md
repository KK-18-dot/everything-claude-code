---
description: Fix a GitHub issue by ID or URL. Ask before commit/push/PR.
---

# Fix GitHub Issue

Goal: read the issue, implement a fix, and create a Draft PR.

## Input
- Issue number or URL: $ARGUMENTS

## Steps
1. Read issue details: `gh issue view $ARGUMENTS --json title,body,labels,assignees`
2. Restate scope and propose a short plan.
3. Implement changes and run minimal tests.
4. Summarize changes and ask before commit/push.
5. Create Draft PR: `gh pr create --draft --fill --web`
