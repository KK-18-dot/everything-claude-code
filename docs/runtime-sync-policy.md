# Runtime Sync Policy

WSL is the canonical runtime for this machine.

## Canonical Sources

- `~/.claude/`
- `~/.claude.json`
- `~/.codex/ops.md`
- `~/.codex/rules/`

## Windows Mirror Scope

Mirror only shared, non-runtime assets into `C:\\Users\\kawad`:

- `~/.claude/CLAUDE.md`
- `~/.claude/commands/` excluding `*.local.md`
- `~/.claude/agents/` excluding `*.local.md`
- `~/.claude/skills/`
- `~/.claude/plugins/local/`
- `~/.claude/rules/` excluding `*.local.md`
- active docs in `~/.claude/docs/`
- `~/.codex/ops.md`
- `~/.codex/rules/`

Do not mirror:

- `settings.json`
- `hooks/`
- `statusline` scripts
- `history`, `sessions`, `cache`, `telemetry`, `downloads`, `image-cache`

These remain runtime-specific.

## MCP Policy

- WSL `~/.claude.json` uses `npx -y @modelcontextprotocol/server-filesystem` with `/mnt/c/...` paths.
- Windows `C:\\Users\\kawad\\.claude.json` keeps the `cmd /c npx` wrapper with native `C:\\...` paths.
- Only the `mcpServers.filesystem` block is mirrored into Windows; the rest of `C:\\Users\\kawad\\.claude.json` stays native.

## Sync Mechanism

Use `~/.claude/scripts/sync-runtime-mirror.sh` to copy shared assets into the Windows mirror.

- default target: `/mnt/c/Users/kawad`
- creates timestamped backups under `C:\\Users\\kawad\\.claude-sync-backups`
- copies without deleting Windows-only runtime files
- mirrors local plugin source under `C:\\Users\\kawad\\.claude\\plugins\\local`
