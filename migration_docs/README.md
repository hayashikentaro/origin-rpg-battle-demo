# saga-analyze

サ・ガ2 秘宝伝説の ROM / 解析成果を、移植実装向けに整理するための作業リポジトリです。

このリポジトリの目的は、解析レポートを「読むための置き場」から、「TypeScript のコアロジックと Godot フロントへ分離移植するための仕様基盤」へ変えることです。

## 移植対象アーキテクチャ

### コアロジック

- TypeScript
- battle
- growth
- transform
- rng

### フロント

- Godot
- UI
- 入力
- 表示

## 現在の一次ソース

- `rom/`
  - 原本 ROM
  - アセンブリ断片
- `reports/`
  - 解析パスごとのレポート
  - CSV / JSON / Markdown / GDScript の生成物

## 移植用ドキュメント

- `docs/porting/architecture.md`
  - 全体方針
  - データ責務の分離
  - 実装順
- `docs/porting/modules/battle.md`
- `docs/porting/modules/growth.md`
- `docs/porting/modules/transform.md`
- `docs/porting/modules/rng.md`
- `docs/porting/modules/frontend.md`
- `docs/porting/modules/shared-data.md`

## 重要方針

- ROM 生データの意味が未確定な箇所は、推定を確定値として潰さない
- TypeScript 側は「中立データ構造」と「純粋ロジック」を優先する
- Godot 側は UI / 入力 / 表示 / シーン遷移に集中し、ゲームルールを持ち込みすぎない
- battle / growth / transform / rng は相互依存を薄く保つ

## 次にやること

1. `docs/porting/modules/` を起点に、対象ごとの仕様確定を進める
2. `reports/` の CSV / JSON から、実装投入用の正規化データを別ディレクトリへ抽出する
3. TypeScript 側で再現対象を `battle` から順に固定する
