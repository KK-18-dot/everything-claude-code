# Global CLAUDE.md

This file defines global behavior for Claude Code across all projects.

## Include Local Config (CRITICAL)

**If `CLAUDE.local.md` exists in the project root, read it first and follow its directives.**

The local file contains a mode marker like:
```
<!-- claude_env: ecc|orchestra|hybrid -->
```

This marker determines which workflow to use. See `rules/project-mode.md` for resolution logic.

## Scope

- Personal/solo development environment
- Two configuration layers: global (`~/.claude/`) + project (`.claude/`)
- Project settings override global when conflicting
- Project mode is selected per project by `CLAUDE.local.md` + `.claude/project-mode`
- `ecc` is marker-only; `orchestra` / `hybrid` add a thin project overlay (`.codex`, `.gemini`, selected `.claude/` assets, and project `.mcp.json`)

## Runtime Policy

- WSL is the canonical runtime on this machine: treat `~/.claude/`, `~/.claude.json`, and `~/.codex/` as the source of truth.
- Windows native Claude under `C:\Users\kawad` is a compatibility mirror, not the canonical source.
- When shared assets need to appear in Windows native Claude, refresh the mirror with `~/.claude/scripts/sync-runtime-mirror.sh`.
- Keep runtime-specific files isolated per environment. Do not assume `settings.json`, hooks, logs, history, cache, or telemetry are safely interchangeable across WSL and Windows.

## Model Role Policy

- **Claude**: default to `opusplan` with `medium` effort for orchestration, planning, synthesis, task routing, quality gates, and final user-facing output.
- **Codex**: default to `gpt-5.4` with `xhigh` reasoning for deep repo exploration, implementation-heavy work, cross-file edits, and technical verification in `orchestra` / `hybrid`.
- **Gemini**: external research, comparative analysis, and multi-source exploration in `orchestra` / `hybrid`.
- In `hybrid`, default to ecc conventions first and call Codex/Gemini only when external reasoning or specialized exploration adds value.

### Agent Allocation

- `ecc` top-level session: `opusplan` + `medium`
- `ecc` high-judgment agents: `planner`, `architect`, `security-reviewer`, `architecture-security-critic`, `env-migrator`, `code-reviewer`, `next-step-operator`, `sync-triager` use `opus`
- `ecc` execution/ops agents: `build-error-resolver`, `doc-updater`, `e2e-runner`, `refactor-cleaner`, `tdd-guide` use `sonnet`
- `orchestra` / `hybrid` top-level session: `opusplan` + `medium`
- `orchestra` / `hybrid` Claude subagent: `general-purpose` uses `sonnet`
- `orchestra` / `hybrid` Codex worker: `gpt-5.4` + `xhigh`
- `orchestra` / `hybrid` Gemini defaults: `gemini-3-flash-preview` for normal research, `gemini-3.1-pro-preview` for deep research
- `perspective` overlay: `CONDUCTOR=opusplan`, `ARCHITECT=gpt-5.4`, `GUARDIAN=opus`, `BUILDER=sonnet`, `SCOUT=gemini-3-flash-preview`, `CRITIC=opus`, `OPERATOR=deepseek-coder-v2`

## Project Mode Behaviors

### ecc mode
- Use `/plan`, `/tdd`, `/code-review`, `/e2e` commands
- Delegate to specialized agents (planner, architect, code-reviewer, etc.)
- Focus on structured, test-driven development

### orchestra mode
- Coordinate with Codex CLI for deep reasoning and design decisions
- Use Gemini CLI for research and multi-modal analysis
- Route tasks through the general-purpose subagent
- Save large outputs to files to preserve context
- Project setup stays thin: use the global `~/.claude` base plus orchestra-specific project overlays only

### hybrid mode
- Combine ecc workflows with orchestra tools
- Use ecc commands by default
- Invoke Codex/Gemini when research or design exploration is needed
- On skill/command conflict, prefer ecc versions
- Treat hybrid as `ecc` global base + orchestra-specific project overlays

### perspective overlay
- `orchestra` and `hybrid` may be combined with a perspective overlay.
- Treat the overlay as an additive review lens, not a separate base mode.
- Do not collapse overlay behavior into `ecc`.

## Language

- Output: Japanese (日本語)
- Internal reasoning: English

## Safety and Permissions

- Never read `.env`, `.env.*`, `secrets/**`, or credential files
- Avoid destructive commands unless explicitly confirmed
- Prefer minimal permissions
- Do not bypass safety checks

## Standard Workflow

1. **Plan** → Use `/plan` for complex tasks (wait for confirmation)
2. **Work** → Implement with `/tdd` for new features
3. **Review** → Use `/code-review` after implementation
4. **Test** → Use `/e2e` for critical user flows
5. **Handoff** → Use `/handoff` when switching tools or agents

## Continuation Contract

When the user asks to continue work, summarize progress, or asks for the next step, always produce:

1. `Current State`
2. `Next AI Step`
3. `Next User Step`
4. `Risks / Blockers`
5. `Recommended Immediate Action`

Use `/continue-project` and the `next-step-operator` agent when the request matches this pattern.

Apply these operating rules in all modes:
- `rules/plan-then-implement.md`
- `rules/verification-first.md`
- `rules/session-hygiene.md`

## References

- `docs/template-policy.md` — Template update and conflict policy
- `docs/troubleshooting.md` — Common issues and solutions
- `docs/external-skills-intake-policy.md` — Third-party skill intake governance
- `rules/project-mode.md` — Mode resolution logic
- `rules/plan-then-implement.md` — Planning discipline
- `rules/verification-first.md` — Verification discipline
- `rules/session-hygiene.md` — Session hygiene and reset policy
- `skills/agent-pattern-selector/SKILL.md` — Pattern selection before orchestration
- `skills/context-handoff/SKILL.md` — Compact handoff before context reset
- `skills/japanese-output-polish/SKILL.md` — Optional Japanese quality polish
- `skills/project-env-router/SKILL.md` — Routing workflow
