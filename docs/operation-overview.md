# Claude Dev Environment - Operational Reference

This document is the current operational baseline for switching between `ecc` and `orchestra` in WSL.

## 1) System Topology

```text
[Upstream Sources]
  ~/ecc-orchestra/
    ├─ everything-claude-code/      (ECC upstream)
    └─ claude-code-orchestra/       (Orchestra upstream)

[Template Layer]
  ~/.claude/templates/
    └─ orchestra/   (thin overlay only)

[Global Runtime Layer]
  ~/.claude/
    ├─ CLAUDE.md
    ├─ rules/project-mode.md
    └─ scripts/project-env-router.sh

[Project Layer]
  ~/Projects/<project>/
    ├─ .claude/project-mode
    ├─ CLAUDE.local.md
    ├─ .mcp.json    (orchestra/hybrid only, merged non-destructively)
    ├─ .codex/      (orchestra/hybrid only)
    └─ .gemini/     (orchestra/hybrid only)
```

## 2) End-to-End Flow

```text
(1) You select a project
    cd ~/Projects/<project>

(2) You apply or confirm mode
    claude-route . --mode ecc|orchestra|hybrid [--force]

(3) Router writes state
    - .claude/project-mode
    - CLAUDE.local.md marker
    - .gitignore entry for CLAUDE.local.md
    - orchestra/hybrid only: sync .codex/.gemini + thin orchestra overlay
      (selected .claude assets + merged project .mcp.json)

(4) You run Claude Code
    claude "task"

(5) Claude resolves effective mode from marker + files
    and behaves as ecc/orchestra/hybrid
```

## 3) Mode Resolution Order

```text
Priority 1: CLAUDE.local.md marker
  <!-- claude_env: ecc|orchestra|hybrid -->

Priority 2: .claude/project-mode

Priority 3: .codex/.gemini presence

Fallback: ecc
```

## 4) Your Daily Procedure

```bash
# A. Open project
cd ~/Projects/<project>

# B. Verify mode quickly
cat .claude/project-mode
head -3 CLAUDE.local.md

# C. Start work
claude "today's task"
```

### When changing mode

```bash
# Re-route explicitly
claude-route . --mode orchestra --force
# or
claude-route . --mode ecc --force
```

## 5) Current Canonical Examples

### Example A: Orchestra project (`career-planning`)

```text
/home/kk-18-dot/Projects/career-planning
  mode: orchestra
  marker: orchestra
  .mcp.json: present
  .codex: present
  .gemini: present
  .claude/settings.json: present
```

Use this project as the reference for:
- Codex/Gemini-assisted workflow
- Orchestra hooks/rules/skills behavior
- Research-heavy execution pattern

### Example B: ECC project (`smart-buy-app`)

```text
/home/kk-18-dot/Projects/smart-buy-app
  mode: ecc
  marker: ecc
  .codex: absent
  .gemini: absent
  .claude/settings.json: absent
```

Use this project as the reference for:
- Claude-centered implementation flow
- No external CLI delegation baseline
- ECC-first operating model

## 6) Operator Command Map

```bash
# Route project mode
claude-route . --mode ecc
claude-route . --mode orchestra
claude-route . --mode hybrid

# Re-apply overlay safely
claude-route . --force

# Show project mode helper (if shell helper loaded)
claude-mode

# Update local templates from upstream
claude-update-templates
```

## 7) Fast Health Check

```bash
# 1) Check global control plane
ls ~/.claude/scripts/project-env-router.sh
ls ~/.claude/rules/project-mode.md

# 2) Check current project state
cat .claude/project-mode
head -3 CLAUDE.local.md
cat .mcp.json 2>/dev/null
ls -la .codex .gemini 2>/dev/null

# 3) Dry-run route validation
~/.claude/scripts/project-env-router.sh . --mode "$(cat .claude/project-mode)" --dry-run
```

## 8) Notes

- WSL is the canonical runtime layer for this machine: `~/.claude/`, `~/.claude.json`, and `~/.codex/`.
- Windows native Claude remains supported as a compatibility mirror under `C:\Users\kawad`, but runtime-specific files are not mirrored verbatim.
- The Windows mirror should be refreshed via `~/.claude/scripts/sync-runtime-mirror.sh`.

---

## 9) Perspective-Lite Overlay (hybrid mode add-on)

Perspective-Lite is an additive layer on top of `hybrid` mode that activates multi-perspective review.

### 4 Active Perspectives

| Perspective | eccエージェント | Model | 担当 |
|-------------|----------------|-------|------|
| ARCHITECT | `architect` | Codex gpt-5.4 | 設計判断・ADR・API契約 |
| GUARDIAN | `security-reviewer` | Opus | セキュリティ + デプロイ安全性 |
| BUILDER | `tdd-guide` / `build-error-resolver` | Sonnet | TDD・実装・ビルド修正 |
| CRITIC | `code-reviewer` | Opus | コード品質・可読性・カバレッジ |

### モード選択ガイド

| シナリオ | モード |
|----------|--------|
| バグ修正・小機能・ドキュメント | **ecc** |
| 大規模リポジトリ探索・外部調査 | **orchestra** |
| 設計+実装+レビューの一連の作業 | **hybrid** |
| セキュリティ敏感・設計の多角的検証 | **hybrid + `/review --multi`** |

### Perspective-Lite スキル

```bash
/review --multi    # GUARDIAN + CRITIC 並列レビュー → MergeVerdict
/ask-local "<質問>" --perspective guardian|critic|architect|builder|operator
                   # gemma4:e2b でローカル知識クエリ（オフライン・機密安全）
```

### MergeVerdict 自動ゲート

```
CRITICAL >= 1  → REVISE ⚠️
HIGH >= 2      → REVISE ⚠️
else           → MERGE ✅
```

### 知識レイヤー

| Layer | 手段 | レイテンシ |
|-------|------|-----------|
| L1 | agentのPerspective Frame（capsule注入済み） | 0ms |
| L2 | `/ask-local` + gemma4:e2b (ollama) | 5-10s |
| L3 | `ollama_web_search` / `gemini` CLI | 10-30s |

### グローバル MCP サーバー（`~/.claude.json`）

```json
"mcpServers": {
  "ollama":    { gemma4:e2b generate/chat/embed },
  "execution": { create_task, list_tasks, log_event, check_budget }
}
```

詳細: `~/Projects/dev-env-built/README.md` および `~/.claude/skills/perspective-review/SKILL.md`
- Shared local plugin source under `~/.claude/plugins/local/` is mirrored into the Windows compatibility layer.
- WSL filesystem MCP is project-scoped for orchestra/hybrid repos and should stay in `.mcp.json`, not in the user-global config.
- `career-planning` and `smart-buy-app` are the active pair for validating global-to-project propagation.
- Orchestra parity is maintained by thin overlay sync via router.
- ECC behavior is route-driven in this environment; plugin-level parity can be managed separately.
