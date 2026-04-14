---
description: Stage, commit, push, and open a Draft PR with safety checks. Ask for confirmation before commit/push unless user requests auto-ship.
---

# Ship

Goal: take local changes and create a Draft PR safely.

## Defaults
- Use short-lived feature branches (feat/<topic>)
- Create Draft PRs
- Require confirmation before `git commit` and `git push`

## Inputs to Confirm
- Branch name and scope
- Commit message
- Test commands to run (if applicable)
- Auto-ship requested? (only if explicitly approved)

## Procedure
1. Review changes: `git status`, `git diff` (and `git diff --cached` if staging).
2. If on main, create a feature branch: `git checkout -b feat/<topic>`.
3. Run agreed tests or linters.
4. Stage: `git add -A`.
5. Confirm commit message, then `git commit -m "<msg>"`.
6. Push: `git push -u origin HEAD`.
7. Create PR as Draft: `gh pr create --draft --fill --web`.

## Output
- Status summary
- Next steps (review, merge)
