# Troubleshooting

Common issues and solutions for the Claude dev environment.

## Mode Not Taking Effect

### Symptoms
- Claude ignores the project mode
- Wrong commands/skills being used
- Orchestra tools not available in orchestra mode

### Solutions

1. **Verify the marker exists**
   ```bash
   head -5 CLAUDE.local.md
   # Should show: <!-- claude_env: ecc|orchestra|hybrid -->
   ```

2. **Check project-mode file**
   ```bash
   cat .claude/project-mode
   # Should match CLAUDE.local.md marker
   ```

3. **Re-apply with force**
   ```bash
   claude-route . --force
   ```

4. **Verify global CLAUDE.md has include directive**
   ```bash
   grep -i "local" ~/.claude/CLAUDE.md
   # Should mention reading CLAUDE.local.md
   ```

## CLAUDE.local.md Not Read by Claude

### Cause
Claude Code doesn't automatically read `CLAUDE.local.md`. It must be instructed via `~/.claude/CLAUDE.md`.

### Solution
Ensure `~/.claude/CLAUDE.md` contains:

```markdown
## Include Local Config (CRITICAL)
If `CLAUDE.local.md` exists in the project root, read it first.
```

Re-run install if missing:
```bash
~/claude-dev-env/scripts/install-dotfiles.sh
```

## Project Filesystem MCP Fails in WSL (`spawn cmd ENOENT`)

### Symptoms
- `claude mcp list` shows filesystem connection failure
- debug logs show `spawn cmd ENOENT`
- orchestra/hybrid repo loses access to workspace mirrors under `/mnt/c/...`

### Cause
The project `.mcp.json` contains a Windows-style filesystem MCP definition or stale mirror settings.

### Solution
Use a WSL-native **project-scoped** filesystem MCP entry:

```json
{
  "mcpServers": {
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/mnt/c/Users/kawad/Claude-Code-Workspace",
        "/mnt/c/Users/kawad/DevSandbox"
      ],
      "env": {}
    }
  }
}
```

Then verify:

```bash
cat .mcp.json
claude mcp list
```

## Codex/Gemini CLI Not Found

### Symptoms
```
WARN: codex command not found in PATH
WARN: gemini command not found in PATH
```

### Solutions

1. **Install the CLIs**
   ```bash
   npm install -g @openai/codex
   npm install -g @google/gemini-cli
   ```

2. **Authenticate**
   ```bash
   codex login
   gemini login
   ```

3. **Verify PATH**
   ```bash
   which codex gemini
   # Should show paths like /usr/local/bin/codex
   ```

4. **Check npm global bin**
   ```bash
   npm bin -g
   # Add this to PATH if not already
   ```

## Orchestra Overlay Template Missing

### Symptoms
```
ERROR: orchestra template missing
```

### Solution
Ensure the orchestra overlay template exists:
```bash
ls ~/.claude/templates/orchestra
```

If missing, restore it from your dotfiles/runtime setup before routing an orchestra/hybrid project.

Historical alternative if you still keep external template sources:
```bash
git clone https://github.com/DeL-TaiseiOzaki/claude-code-orchestra.git ~/claude-templates/orchestra
```

## Switching Modes Leaves Orphan Files

### Scenario
Switched from orchestra to ecc, but `.codex/` and `.gemini/` are still referenced.

### Explanation
The router renames (not deletes) these directories to `*.disabled` for safety.

### Solutions

**To fully remove:**
```bash
rm -rf .codex.disabled .gemini.disabled
```

**To restore (switch back to orchestra):**
```bash
mv .codex.disabled .codex
mv .gemini.disabled .gemini
claude-route . --mode orchestra --force
```

## Hybrid Mode Conflicts

### Symptoms
- Command behaves differently than expected
- Wrong agent being invoked

### Resolution Rules

In hybrid mode, **ecc takes priority**:

| Conflict Type | Resolution |
|---------------|------------|
| Same command name | ecc version wins |
| Same skill name | ecc version wins |
| Same agent name | ecc version wins |

To explicitly use orchestra version, invoke Codex/Gemini directly:
```bash
codex "Design the database schema"
gemini "Research best practices for X"
```

## Install Script Overwrote My Config

### Cause
The install script backs up existing files but then overwrites.

### Recovery
Backups are saved to `~/.dotfiles-backup-YYYYMMDD-HHMMSS/`

```bash
ls ~/.dotfiles-backup-*
# Find your backup, then restore:
cp -R ~/.dotfiles-backup-XXXXXXXX/.claude/* ~/.claude/
```

## Zellij Session Issues

### Session won't attach
```bash
zellij kill-session main
zellij attach --create main
```

### Layout not loading
Ensure layout file exists:
```bash
ls ~/.config/zellij/layouts/claude-dev.kdl
```

## Testing the Setup

Run the verification script:
```bash
~/claude-dev-env/tests/verify-setup.sh
```

This checks:
- Global CLAUDE.md exists and has include directive
- Templates are cloned
- Scripts are executable
- Shell helpers are sourceable
