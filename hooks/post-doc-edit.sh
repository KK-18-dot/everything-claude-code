#!/bin/bash
# post-doc-edit.sh
# PostToolUse hook: ドキュメント編集後に NotebookLM 同期を提案する
#
# 対象: ~/.claude/docs/, ~/.claude/rules/, dev-env-built/*.md, ubuntu26-migration-kit/docs/
# 動作: 上記パスのファイルが Edit/Write された場合に sync コマンドを案内する
#
# このスクリプトは警告のみ。実際の同期は手動または /sync-docs で実行。

EDITED_FILE="${TOOL_INPUT_FILE_PATH:-}"

DOC_DIRS=(
  "$HOME/.claude/docs"
  "$HOME/.claude/rules"
  "$HOME/Projects/dev-env-built"
  "$HOME/Projects/ubuntu26-migration-kit/docs"
)

for dir in "${DOC_DIRS[@]}"; do
  if [[ "$EDITED_FILE" == "$dir"* ]]; then
    echo "⚠ [NotebookLM] ドキュメントが更新されました: $(basename "$EDITED_FILE")"
    echo "  同期するには: uv --directory ~/Projects/dev-env-built run python knowledge/oracles/sync/sync_to_notebooklm.py"
    echo "  または: /sync-docs"
    break
  fi
done
