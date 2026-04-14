---
name: sync-docs
description: Sync updated documentation to NotebookLM notebook 9fdaa1bc. Uploads new/changed markdown files, skips unchanged files. Run after editing docs.
user-invocable: true
---

# /sync-docs

NotebookLM にドキュメントを同期します。

## 同期対象

| ディレクトリ | ラベル |
|------------|--------|
| `~/.claude/docs/` | `claude-docs` |
| `~/.claude/rules/` | `claude-rules` |
| `~/Projects/dev-env-built/*.md` | `dev-env-built` |
| `~/Projects/ubuntu26-migration-kit/docs/` | `ubuntu26-docs` |

除外: `archive/` ディレクトリ、`CLAUDE.local.md`

## ターゲットノートブック

```
ID: 9fdaa1bc-48cb-492b-b3c4-e45b395d2210
URL: https://notebooklm.google.com/notebook/9fdaa1bc-48cb-492b-b3c4-e45b395d2210
```

## 実行

### 通常同期（差分のみ）
```bash
uv --directory ~/Projects/dev-env-built run python knowledge/oracles/sync/sync_to_notebooklm.py
```

### 確認のみ（変更なし）
```bash
uv --directory ~/Projects/dev-env-built run python knowledge/oracles/sync/sync_to_notebooklm.py --dry-run
```

### 削除ファイルも除去（完全同期）
```bash
uv --directory ~/Projects/dev-env-built run python knowledge/oracles/sync/sync_to_notebooklm.py --prune
```

### 現在のソース一覧
```bash
uv --directory ~/Projects/dev-env-built run python knowledge/oracles/sync/sync_to_notebooklm.py --list
```

## 認証が切れた場合

```bash
uv --directory ~/Projects/dev-env-built run notebooklm login
```

ブラウザが開きます。Google アカウントでサインインしてください。
認証情報は `~/.notebooklm/storage_state.json` に保存されます。

## マニフェスト

`knowledge/oracles/sync/sync_manifest.json` がソースIDとハッシュを管理します。
このファイルは git commit しても問題ありません。

## 動作原理

1. 対象ディレクトリの `.md` ファイルを収集
2. `sync_manifest.json` と照合（ファイルハッシュで変更検知）
3. 新規ファイル → `sources.add_text()` でアップロード
4. 変更ファイル → 旧ソース削除 → 再アップロード
5. 未変更ファイル → スキップ
6. マニフェスト更新
