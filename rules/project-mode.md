# Project Mode Resolution

## Priority Order (highest to lowest)

1. **CLAUDE.local.md marker** — `<!-- claude_env: ecc|orchestra|hybrid -->`
2. **`.claude/project-mode` file** — Plain text containing mode name
3. **Directory detection** — If `.codex/` or `.gemini/` exists → orchestra
4. **Default** — ecc

## Reading the Mode

At the start of each session, determine the project mode:

```
if CLAUDE.local.md exists and contains <!-- claude_env: X -->:
    mode = X
else if .claude/project-mode exists:
    mode = contents of file
else if .codex/ or .gemini/ exists:
    mode = orchestra
else:
    mode = ecc
```

## Mode Behaviors

### ecc
- Use commands: `/plan`, `/tdd`, `/code-review`, `/e2e`, `/build-fix`
- Delegate to agents: `planner`, `architect`, `code-reviewer`, `tdd-guide`
- No external CLI integration
- Router writes markers only; no project template or project `CLAUDE.md` copy is required
- Default model split: top-level `opusplan` with `medium`; high-judgment agents `opus`; execution/ops agents `sonnet`

### orchestra
- Coordinate with Codex CLI for design/debugging
- Use Gemini CLI for research/analysis
- Route through `general-purpose` subagent
- Large outputs → save to files
- Router applies a thin project overlay: `.codex`, `.gemini`, orchestra-specific `.claude/` assets, and project `.mcp.json`
- Default model split: top-level `opusplan` with `medium`; `general-purpose=sonnet`; `Codex=gpt-5.4/xhigh`; Gemini flash for normal research and Pro 3.1 for deep research

### hybrid
- All ecc commands and agents available
- Codex/Gemini available when explicitly needed
- Treat hybrid as the global ecc base plus the same thin orchestra project overlay
- **Conflict resolution**: ecc takes priority
  - Same command name → use ecc version
  - Same skill name → use ecc version
  - Invoke orchestra tools only when: research needed, design exploration, multi-source analysis
- Default model split: ecc allocation first, then orchestra tools added selectively

### perspective (sub-mode of orchestra/hybrid)
- Requires: orchestra or hybrid as base mode
- Activated by: `.claude/perspective.yaml` exists + `<!-- perspective: enabled -->` marker
- Adds: 6-perspective differentiated architecture (CONDUCTOR, ARCHITECT, GUARDIAN, BUILDER, SCOUT, CRITIC, OPERATOR)
- Adds: Knowledge layer (L0-L3 Memory Stack + NotebookLM via MCP)
- Adds: Structured workflows (2-Wave, Debate, Joker/Closer)
- Adds: `dev-env` CLI, MCP servers (Knowledge Oracle, Execution)
- Commands: `/kickoff`, `/cast`, `/debate`, `/joker`, `/closer`, `/verify-multi`, `/status`, `/ship`
- Perspective bindings are read from `.claude/perspective.yaml` (customizable per project)
- Recommended allocation: `CONDUCTOR=opusplan`, `ARCHITECT=gpt-5.4`, `GUARDIAN=opus`, `BUILDER=sonnet`, `SCOUT=gemini-3-flash-preview`, `CRITIC=opus`, `OPERATOR=deepseek-coder-v2`

## Conflict Resolution Table (hybrid mode)

| Resource | ecc | orchestra | Winner |
|----------|-----|-----------|--------|
| `/plan` | ✅ | ✅ | ecc |
| `/tdd` | ✅ | ✅ | ecc |
| `agents/planner.md` | ✅ | ❌ | ecc |
| `agents/general-purpose.md` | ❌ | ✅ | orchestra |
| Codex CLI integration | ❌ | ✅ | orchestra (additive) |
| Gemini CLI integration | ❌ | ✅ | orchestra (additive) |
| `/kickoff`, `/cast` | ❌ | perspective | perspective (additive) |
| `dev-env` CLI | ❌ | perspective | perspective (additive) |

## Verification

After routing, verify with:

```bash
head -3 CLAUDE.local.md          # Should show marker
cat .claude/project-mode         # Should match
ls -la .codex .gemini 2>/dev/null # Present only for orchestra/hybrid
cat .mcp.json 2>/dev/null         # Filesystem MCP present only when the overlay needs it
cat .claude/perspective.yaml 2>/dev/null  # Present only for perspective
```
