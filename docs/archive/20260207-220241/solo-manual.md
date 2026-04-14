# Claude Code Solo Manual

このドキュメントは「アイデア -> 完成」までを最短で回すための個人用運用マニュアルです。

## 全体像 0-100（設定の理解）
### 0-20: 基礎（どこに何があるか）
- グローバル指針: `/home/kk-18-dot/.claude/CLAUDE.md`
- フック設定: `/home/kk-18-dot/.claude/settings.json`
- コマンド: `/home/kk-18-dot/.claude/commands/`
- Skills: `/home/kk-18-dot/.claude/skills/`
- 運用ドキュメント: `/home/kk-18-dot/.claude/docs/`
- アプリ内部状態: `/home/kk-18-dot/.claude.json`（通常触らない）

### 20-40: 安全・権限制御
- `.env` / `.env.*` / `secrets/**` の読み取りは禁止
- 破壊的コマンドは明示依頼がない限り避ける
- 権限は最小化、危険操作は警告のみ

### 40-60: 標準フローと自動適用
- 既定フロー: Plan -> Work -> Review
- `/plan` `/tdd` `/code-review` `/e2e` を標準化
- 自然言語で「レビュー/テスト/計画/出荷」等が出たら該当コマンドを暗黙適用

### 60-80: Hooks（警告中心）
- PreToolUse: 長時間コマンド/破壊的コマンド/`git push` 警告
- PostToolUse: フォーマット/テスト推奨、`console.log` 警告
- Stop: 差分内の秘密情報や TODO/console.log を警告
- `/compact` 促しは一定回数で表示

### 80-100: 発展（運用ドキュメント）
- `/home/kk-18-dot/.claude/docs/context-memory.md`
- `/home/kk-18-dot/.claude/docs/parallelization.md`
- `/home/kk-18-dot/.claude/docs/verification.md`
- `/home/kk-18-dot/.claude/docs/mcp-plugins.md`
- Git運用: `/home/kk-18-dot/.claude/docs/git-automation.md`
- UI/UX: `/home/kk-18-dot/.claude/docs/ui-ux.md`

## 作業ディレクトリの基準
- 開発本体: `/home/kk-18-dot/Projects`
- アイデア置き場: `/home/kk-18-dot/Projects/_ideas`
- アーカイブ: `/home/kk-18-dot/Projects/_archive`
- 実験/検証: `/home/kk-18-dot/DevSandbox`
- 参照専用: `/home/kk-18-dot/Claude-Code-Workspace`

## 1) 始め方
- 対象プロジェクトへ移動: `cd /home/kk-18-dot/Projects/<project>`
- 起動: `claude`
- 続きから: `claude --continue` or `/resume`

## 実際の使い方 0-100
### 0-20: 起動と基本操作
- Windows Terminalを開く
- `/home/kk-18-dot/Projects` に移動
- `claude` を起動
- 日本語で「やりたいこと」を短く書く

### 20-40: 調査 -> 計画
- 「まず現状確認して」でOK
- 変更が大きいときは `/plan`
- 実装前に確認を求められたらOKを出す

### 40-60: 実装（自動適用）
- 「実装して」「修正して」で進む
- 「レビューして」「テストして」で該当コマンド適用
- Hooksが警告を出す（止まらない）

### 60-80: 仕上げ
- `/code-review` で差分レビュー
- `/commit-msg` でコミット文案
- `/ship` で commit -> push -> Draft PR

### 80-100: 新規/長期運用
- `/repo-init` で新規作成
- `/kickoff` でプロジェクトCLAUDE.md作成
- 長期作業は `/compact` を使う

## 2) 標準フロー
- **Plan -> Work -> Review**
- 迷ったら `/plan`
- 実装は `/tdd`
- 完了後は `/code-review`

## 3) よく使うコマンド
- 新規作成: `/repo-init`
- 初期ルール: `/kickoff`
- 出荷: `/ship`
- コミット文案: `/commit-msg`
- Issue修正: `/fix-github-issue <id|url>`

## 4) GitHub運用
- 認証状態確認: `gh auth status`
- Draft PRを基本にする

## 4.5) 差分表示（delta / difftastic）
- 既定の `git diff` / `git show` は **delta** を使用
- **difftastic** は構造差分が必要なときに手動で使う
- VS Codeは編集・マージなどGUI用途で残す

使い分け:
- ざっと確認: `git diff`
- 履歴確認: `git show`
- 構造差分（理解が難しい時）: `git dt`

自動起動:
- `git diff` / `git show` を使うと **deltaが自動表示**
- `git dt` 実行時のみ **difftastic**

## 5) Hooksの挙動
- 警告中心。自動ブロックなし。
- `/compact` の促しは一定回数で表示される。
- ログ保存は任意: `CLAUDE_SESSION_LOG=1`

## 6) 迷ったとき
- 話題が変わったら `/clear`
- フェーズ切替は `/compact`
- 危険な変更は `/rewind`
- 長期作業は `/rename`

## アイデアから完成まで（最短フロー）
1. アイデアを一行で固定（`/home/kk-18-dot/Projects/_ideas`）
2. MVP定義（やらないことを決める）
3. `/repo-init` でリポジトリ作成
4. `/kickoff` でプロジェクトCLAUDE.md作成
5. `/plan` で計画 -> OKなら実装
6. `/tdd` で実装
7. `/code-review` でレビュー
8. `/commit-msg` -> `/ship` で出荷



