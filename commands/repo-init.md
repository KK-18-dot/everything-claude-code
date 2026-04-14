---
description: Initialize a new GitHub repo with safe defaults. Ask for confirmation before running git/gh.
---

# Repo Init

Goal: create a new repository with private visibility, no license, and Node gitignore.

## Defaults
- Visibility: private
- License: none
- .gitignore: Node
- README: add only for remote-first

## Inputs to Confirm
- Repo name and owner (user or org)
- Target path
- Mode: remote-first (create + clone) or local-first (existing folder)
- README on remote-first (default yes)

## Procedure
1. Verify `gh` is installed and authenticated: `gh --version`, `gh auth status`.
2. Remote-first:
   - `gh repo create <name> --private --gitignore Node --add-readme --clone`
3. Local-first:
   - `git init`
   - `git add -A`
   - `git commit -m "chore: initial commit"`
   - `git branch -M main`
   - `gh repo create <name> --private --source=. --remote=origin --push`
4. Offer `/kickoff` to draft project CLAUDE.md.

## Output
- Commands to run
- Any missing prerequisites or errors
