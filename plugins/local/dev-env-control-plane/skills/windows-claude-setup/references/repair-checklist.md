# Repair Checklist

## WSL Canonical

- `~/.claude.json` uses `npx` for `mcpServers.filesystem`
- filesystem paths are `/mnt/c/Users/kawad/Claude-Code-Workspace` and `/mnt/c/Users/kawad/DevSandbox`
- `~/.claude/CLAUDE.md` is the authoritative global behavior file

## Windows Mirror

- `C:\Users\kawad\.claude.json` keeps `command: "cmd"` and `args: ["/c", "npx", ...]`
- shared markdown assets and local plugins are mirrored from WSL
- hooks and `settings.json` remain native

## Verification

- `claude mcp list`
- `~/.claude/scripts/sync-runtime-mirror.sh --dry-run`
- `~/.claude/scripts/project-env-router.sh <project> --dry-run`
- check `career-planning/.claude/project-mode`
- check `smart-buy-app/.claude/project-mode`
