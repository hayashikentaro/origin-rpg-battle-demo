# Shared Data

## 役割

`battle / growth / transform / frontend` の全てが参照する共通データの索引です。

## 最重要ソース

- `reports/saga2_next_summary.json`
- `reports/saga2_abilities_items_pass24.json`
- `reports/saga2_abilities_items_pass24.min.json`
- `reports/saga2_items_enriched_fields_pass29.csv`
- `reports/saga2_monsters_table_named_raw.csv`
- `reports/saga2_monster_names_decoded.csv`
- `reports/saga2_monster_inventories_by_monster.csv`
- `reports/saga2_monster_inventory_analysis_summary.json`
- `reports/saga2_charmap_initial.csv`

## 現時点で強いこと

- アイテムは 272 件
- モンスターは 256 件
- アイテムレコードは 8 byte
- モンスターレコードは 10 byte
- モンスター末尾 2 byte は inventory pointer の可能性が高い
- 能力とアイテム名は同一系テーブル上に存在する可能性が高い

## 実装に必要な共通モデル

- `ItemRecordRaw`
- `MonsterRecordRaw`
- `MonsterInventory`
- `AbilityOrItemRef`
- `UsageHandlerRef`
- `ConfidenceTaggedField`

## 注意点

- item 8 byte は全カテゴリ共通の固定意味ではない
- category / usage ごとに意味が変わる前提で保持する
- raw byte 列は捨てない

## 次の抽出候補

- `data/items.json`
- `data/monsters.json`
- `data/monster-inventories.json`
- `data/charmap.json`
