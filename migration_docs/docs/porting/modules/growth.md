# Growth Module

## 対象

TypeScript `growth` モジュールで再現する領域。

- 人間成長
- エスパー成長
- メカ装備反映
- 戦闘後の変化判定

## 現時点の直接ソース

- `reports/saga2_abilities_items_pass24.json`
- `reports/saga2_item_fields_by_category_pass29_report.md`
- `reports/saga2_monster_inventories_by_monster.csv`
- `reports/saga2_monster_inventory_report.md`
- `reports/saga2_usage_handler_names_pass28_report.md`

## growth が依存する周辺仕様

- 戦闘で何を使ったか
- usage の分類
- アイテム / 能力の種別
- 種族別のデータ表現

## 現状評価

growth 専用の確定レポートはまだ薄いです。したがって今は「実装不可」ではなく、「battle / item / race data から growth で必要な入力を先に定義する」段階です。

## 先に固定すべき入出力

- `GrowthInput`
  - race
  - used actions
  - equipped items
  - battle result summary
- `GrowthResult`
  - stat changes
  - learned ability
  - equipment-derived updates

## すぐ着手できる部分

- メカの装備依存能力補正
- 使用回数や usage 分類を growth 入力へ残す共通設計
- モンスター以外の成長処理を battle 後フェーズとして切り出す設計

## 追加解析の優先度

1. 人間 / エスパー成長ルーチンの RAM 参照
2. 戦闘後更新テーブル
3. 種族別の成長分岐条件
