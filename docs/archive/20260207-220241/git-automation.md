# Git Automation Guide (Global)

This guide defines a safe, semi-automated Git workflow for this environment.

## Defaults
- Repo visibility: private
- License: none
- .gitignore: Node
- PRs: Draft by default

## Prerequisites
- GitHub CLI installed and authenticated.
- Recommended auth: `gh auth login --web --git-protocol https`
- Optional setup: `gh auth setup-git`

## Create a Repo (Remote-First)
```powershell
gh repo create <name> --private --gitignore Node --add-readme --clone
```

## Create a Repo (Local-First)
```powershell
git init
git add -A
git commit -m "chore: initial commit"
git branch -M main
gh repo create <name> --private --source=. --remote=origin --push
```

## Ship Changes
```powershell
git status
git diff
git checkout -b feat/<topic>
git add -A
git commit -m "<msg>"
git push -u origin HEAD
gh pr create --draft --fill --web
```

## Safety Boundary
- The assistant may prepare commands, but commit/push/PR require explicit approval.
- If you say "auto-ship", the assistant can proceed with fewer prompts.

## Integration
- Use `/repo-init` to set up new repos.
- Use `/ship` to finalize changes and open PRs.
