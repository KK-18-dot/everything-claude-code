# Verification (Solo)

Keep a minimal verification loop for every change.

## Baseline Checks
- `git status`
- `git diff` (and `git diff --cached` when staging)
- Run the smallest relevant test

## Change-Type Guidance
- Docs-only: spellcheck or quick read-through.
- Logic changes: unit or targeted tests.
- UI changes: manual check, and VRT for critical screens.

## Evidence to Capture
- Commands run
- Tests executed and results
- Any known gaps or assumptions
