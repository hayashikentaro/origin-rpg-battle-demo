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
- `reports/saga2_growth_rng_structural_report.md`
- `reports/saga2_growth_rng_structures.json`

## ROM から直接確定した構造

- `data_growth_table` は `bank $0C:$7FB0` の 32 byte table
- 値は `07, 0F, 17, ... FF` の等差列
- `value[n] = ((n + 1) * 8) - 1` の形なので、rank を 0..255 の比較しきい値へ変換する表である可能性が高い
- `data_ability_learning_thresholds` は単純なしきい値列ではなく、16 個の 2 byte ペアに見える
- `data_ability_learning_results` は bank 末尾の 16 byte しかなく、現ラベル名の意味づけは再検証が必要
- direct ref としての `LD HL,$7FB0 / $7FD0` は現時点で未検出
- 近縁アクセサとして `0C:7F80 + index` を読む computed-address 型ルーチンは確認できた

## 逆引きメモ

- `reports/saga2_growth_rng_reverse_lookup_report.md`
- `0C:7FB0 / 7FD0` の direct ref は未確認
- 今回の静的探索では、`growth` 側は generic banked read や上位テーブル帯の近縁アクセサまで確認した段階

## growth が依存する周辺仕様

- 戦闘で何を使ったか
- usage の分類
- アイテム / 能力の種別
- 種族別のデータ表現

## 現状評価

growth 専用の意味論はまだ薄いですが、構造面では前進しています。今は「growth 入力モデルを先に固定しつつ、ROM 上の補助表の役割をコード参照から確定する」段階です。

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
- `growth_table` を chance-rank table 候補として保持するデータモデル

## 追加解析の優先度

1. `data_growth_table` を参照するコードの特定
2. `7FD0-7FFF` を読む戦闘後 / 学習ルーチンの特定
3. 人間 / エスパー成長ルーチンの RAM 参照
