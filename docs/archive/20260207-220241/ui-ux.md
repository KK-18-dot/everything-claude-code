# UI/UX Guidelines (Solo)

AIっぽさを減らし、プロ品質に寄せるためのUI規約です。

## 推奨スタック
- Tailwind v4 + shadcn/ui + Radix Primitives
- VRT: Playwright toHaveScreenshot()（必要画面のみ）
- 参考指針: Material Design 3（迷った時のみ）

## セットアップ（プロジェクト単位）
- Tailwind v4: `npm install -D tailwindcss@latest`
- shadcn/ui: `npx shadcn@latest init`
- Playwright: `npm install -D @playwright/test` -> `npx playwright install`

## Design Tokens（最優先）
- 色/影/角丸/余白/タイポはトークンのみ
- トークン外の値は禁止

例:
@theme {
  --color-bg: oklch(0.98 0 0);
  --color-fg: oklch(0.2 0 0);
  --radius-sm: 0.75rem;
  --radius-md: 1rem;
  --shadow-sm: 0 1px 2px rgb(0 0 0 / 0.06);
  --shadow-md: 0 8px 30px rgb(0 0 0 / 0.08);
}

## レイアウトとタイポ
- 8pxグリッドを厳守
- H1/H2/本文の3階層
- 太さは2-3段階まで

## 状態設計（必須）
- Empty / Loading / Error
- Hover / Focus / Disabled
- Skeletonを優先

## フォーム規約
- Field + Label + Description + Error を統一
- ラベル紐付け必須

## a11y / 挙動
- フォーカスリングは消さない
- Dialog/Dropdown/TabsはRadixを優先
- asChildで見た目自由 + 挙動品質を両立

## Visual Regression
- 重要画面のみPlaywrightでスクショ差分
- 意図変更時は `-u` で更新

## HTML-only の注意
- header/main/footer を必ず使う
- ボタンとリンクの役割を混ぜない

## AI指示テンプレ（初稿）
- トークン外の色/影/角丸禁止
- 余白は8pxスケール
- タイポは3階層
- Empty/Loading/Error + hover/focus必須
- FormはField/Label/Description/Error
- Dialog/PopoverはRadix
