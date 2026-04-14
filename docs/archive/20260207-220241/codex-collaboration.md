# Codex Collaboration (Global)

This guide defines how to collaborate between Claude Code and Codex.

## Roles
- Claude Code: context gathering, planning, documentation, review feedback
- Codex: implementation, tests, diff summary

## Standard Flow
1. Plan (Claude Code)
2. Work (Codex)
3. Review (Claude Code)
4. Finalize (Codex)

## Handoff Format
Use `/handoff` and keep outputs concise.

## Parallel Usage
- Split by function: implementation / tests / documentation.
- Keep each agent scope narrow and explicit.
- Consolidate outputs via `/handoff`.

## Safety
- Do not log secrets or credentials.
- Avoid destructive commands unless explicitly approved.
