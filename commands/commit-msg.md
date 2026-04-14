---
description: Generate commit message suggestions from the current git state. Ask before committing.
---

# Commit Message

Goal: propose concise commit messages based on current changes.

## Current State
!git status --short
!git diff --cached --stat
!git diff --stat

## Instructions
- Propose 1-3 commit messages.
- Prefer conventional commits: feat/fix/chore/docs/refactor/test.
- Ask for confirmation before `git commit`.
