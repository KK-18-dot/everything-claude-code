# Permissions and Safety Playbook

This guide keeps the warning-only policy while reducing accidents.

## Principles
- Prefer least privilege and explicit user approval.
- Warnings only; no automatic destructive actions.
- Keep changes small and review diffs frequently.

## Destructive Commands
- Only run destructive commands when explicitly requested.
- Double-check target paths and scope.
- Prefer dry-run or listing commands first.

## Secrets Handling
- Never read `.env`, `.env.*`, or `secrets/**`.
- Do not log credentials or tokens.
- Review diffs for secrets before commit or push.

## Escalated Permissions
- Use only when required (network access, installs, system-wide writes).
- Always include a clear justification for escalation.
- Keep the command as narrow as possible.

## Pre-Push Checklist
- `git status`
- `git diff` (and `git diff --cached` if staging)
- Remove `console.log`, `TODO`, `FIXME` unless intentional
- Run tests if the change is behavior-related
