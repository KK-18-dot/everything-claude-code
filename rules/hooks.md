# Hooks System

## Hook Types
- PreToolUse: before tool execution (warnings, safety checks)
- PostToolUse: after tool execution (warnings, optional light automation)
- Stop: end of session (final checks)

## Active Hooks (settings.json)

### PreToolUse (matcher: Bash|Write)
- Long command warning for: npm, pnpm, yarn, bun, cargo, pytest, vitest, playwright, docker, make
- Destructive command warning (rm -rf, del /f, rd /s /q, Remove-Item -Recurse -Force, git reset --hard, git clean -fdx, format, mkfs, dd if=)
- git push warning
- Doc sprawl warning for new .md/.txt outside README/CLAUDE/AGENTS/CONTRIBUTING or docs/
- Periodic /compact suggestion (warning only)

### PostToolUse (matcher: Edit|Update|Write)
- Always warn to consider format, typecheck, and tests
- Warn if console.log found in edited file
- When HOOK_MODE=active and editing JS/TS:
  - Prettier --write (local bin or npx)
  - tsc --noEmit (tsconfig present)
  - npm test (only if test script exists and is not heavy)

### Stop
- Warn if git diff includes console.log / TODO / FIXME
- Warn if git diff includes possible secrets (api keys/tokens/passwords/private keys)
- Optional session log when `CLAUDE_SESSION_LOG=1` (summary only, no secrets)

## Runtime Modes
- HOOK_MODE=warning|active (default: warning)
- CLAUDE_HOOK_DEBUG=1 logs to /home/kk-18-dot/.claude/hooks/hook.log
- CLAUDE_SESSION_LOG=1 saves session summary logs to /home/kk-18-dot/DevSandbox/session-logs

## Notes
- Hooks emit warnings only; they do not block execution.


