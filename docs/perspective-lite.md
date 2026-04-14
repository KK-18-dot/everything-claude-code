# Perspective-Lite — 運用リファレンス

**更新: 2026-04-13**

Perspective-Liteは、`hybrid`モードの上に乗る多角的レビューオーバーレイです。
NotebookLM不要・dev-env up/down不要・既存eccエージェントをそのまま拡張します。

---

## コアコンセプト

```
Perspective = Model × Role Frame × Dedicated Knowledge
```

各eccエージェントに `## Perspective Frame` セクションを注入することで、
同じエージェントが「視座を持った専門家」として動作します。

---

## 4視座マッピング

| 視座 | 映画比喩 | eccエージェント | Model | 思考コア |
|------|---------|----------------|-------|----------|
| ARCHITECT | 脚本家 | `architect` | Codex gpt-5.4 | "この変更は5年後の保守性にどう影響するか？" |
| GUARDIAN | 法務監修 | `security-reviewer` | Opus | "攻撃者はこの変更を悪用できるか？" |
| BUILDER | 撮影監督 | `tdd-guide` / `build-error-resolver` | Sonnet | "テストは通るか？動くか？ship it." |
| CRITIC | 編集 | `code-reviewer` | Opus | "6ヶ月後に自分でこのコードを理解できるか？" |

**統合された視座（日常使用なし）:**
- CONDUCTOR → メインClaude Codeセッションに吸収
- SCOUT → `gemini` CLI / `ollama_web_search` でアドホック呼び出し
- OPERATOR → GUARDIANに統合（デプロイ安全性チェックを追加）

---

## スキル

### `/review --multi`

```
用途: セキュリティ敏感な変更・リファクタ・本番デプロイ前
動作: GUARDIAN + CRITIC を並列subagentで起動
出力: MergeVerdict (MERGE/REVISE/REJECT) + 両視座の所見
```

MergeVerdict ゲートロジック（`artifact.py`）:
```
CRITICAL >= 1 → REVISE
HIGH >= 2     → REVISE
else          → MERGE
```

### `/ask-local`

```
用途: ドメイン専門知識の深堀り（オフライン・機密コード安全）
動作: capsule/_index.md をコンテキストに gemma4:e2b へ質問
例:   /ask-local "OWASPのセッション管理" --perspective guardian
      /ask-local "循環的複雑度の下げ方" --perspective critic
```

---

## 知識レイヤー（NotebookLM代替）

| Layer | 手段 | レイテンシ | 使うとき |
|-------|------|-----------|----------|
| **L1** | Capsule injection（agent Perspective Frame） | 0ms | 常時有効・無意識に効く |
| **L2** | `/ask-local` + gemma4:e2b | 5-10s | ドメイン深堀り・オフライン必須 |
| **L3** | `ollama_web_search` / `gemini` CLI | 10-30s | 外部調査・最新情報 |

Capsule ファイル:
```
~/Projects/dev-env-built/knowledge/capsules/
  architect/_index.md
  guardian/_index.md
  builder/_index.md
  critic/_index.md
  operator/_index.md
```

---

## Perspective Frame注入済みエージェント

| ファイル | 注入内容 |
|---------|---------|
| `~/.claude/agents/security-reviewer.md` | GUARDIAN + OPERATOR |
| `~/.claude/agents/code-reviewer.md` | CRITIC |
| `~/.claude/agents/architect.md` | ARCHITECT |
| `~/.claude/agents/tdd-guide.md` | BUILDER |
| `~/.claude/agents/build-error-resolver.md` | BUILDER |

各エージェントファイルの末尾に `## Perspective Frame` セクションあり。

---

## グローバルMCP（`~/.claude.json`）

```json
"mcpServers": {
  "ollama": {
    "command": "npx", "args": ["-y", "ollama-mcp"],
    "env": {"OLLAMA_HOST": "http://localhost:11434"}
  },
  "execution": {
    "command": "uv",
    "args": ["run", "--directory", "/home/kk-18-dot/Projects/dev-env-built",
             "python", "-m", "mcp_servers.execution.server"]
  }
}
```

`execution` MCPが提供するツール: `create_task`, `list_tasks`, `log_event`, `check_budget`, `store_artifact`

---

## いつどのモードを使うか

| シナリオ | モード | 理由 |
|----------|--------|------|
| バグ修正・小機能・ドキュメント | **ecc** | capsule注入済みagentで十分 |
| 大規模リポジトリ探索 | **orchestra** | Codex gpt-5.4の深い推論 |
| 設計+実装+レビューの一連 | **hybrid** | eccベースにCodex/Geminiを追加 |
| セキュリティ敏感・多角的検証 | **hybrid + `/review --multi`** | GUARDIAN+CRITIC並列レビュー |
| ドメイン専門知識の深堀り | **ecc + `/ask-local`** | gemma4:e2bでローカル処理 |

---

## ローカルLLM (gemma4:e2b)

```
モデル: gemma4:e2b (MoEアーキテクチャ、2.3B有効パラメータ、7.2GB)
コンテキスト: 128K (アクティブ ~8K)
用途: L2知識クエリ・機密コード分析・オフライン処理
起動: systemctl --user start ollama (自動起動設定済み)
```

---

## 検証チェックリスト

- [ ] **V1**: `security-reviewer` に GUARDIAN視点の所見が出力される（OWASP/CWE参照あり）
- [ ] **V2**: `code-reviewer` に CRITIC視点の所見が出力される（スタイル・複雑度中心）
- [ ] **V3**: `/review --multi` が両視座を並列起動し MergeVerdict を返す
- [ ] **V4**: `execution` MCP で `create_task` が dev-env-built 外のプロジェクトから動作する
- [ ] **V5**: `/ask-local` が gemma4:e2b + capsule内容で回答する
