# Transform Module

## 対象

TypeScript `transform` モジュールで再現する領域。

- モンスター系統判定
- 肉 / 食肉などの変身入力解決
- 変身先モンスター決定

## 主要ソース

- `reports/saga2_monster_family_transform_report.md`
- `reports/saga2_monster_family_transform_summary.json`
- `reports/saga2_monster_family_by_monster.csv`
- `reports/saga2_monster_family_groups.csv`
- `reports/saga2_monster_transformation_matrix_36x16.csv`
- `reports/saga2_monster_transformation_long.csv`
- `reports/saga2_monster_inventory_report.md`
- `reports/saga2_monsters_annotated_hypothesis.csv`
- `reports/saga2_monster_names_decoded.csv`

## 確度が高いこと

- family テーブルは 256 byte で monster id ごとに 1 byte
- transformation テーブルは 36 x 16 で綺麗に読める
- 各セルは変身後の monster id
- `E0` / `F0` 系 family は特殊グループの可能性が高い

## 実装方針

- `monsterId -> familyCode`
- `familyCode + meatRank -> nextMonsterId`
- `nextMonsterId -> full monster record`

という 3 段階に分離する。

## 必要モデル

- `MonsterFamilyCode`
- `TransformationMatrix`
- `TransformationInput`
- `TransformationResult`

## 注意点

- family code と monster family 名は分ける
- 特殊 family は通常マトリクス外として扱う
- 実装では raw code を失わない

## すぐに着手できること

- JSON 化しやすい transform テーブル抽出
- family code の enum 化候補作成
- 変身後の能力 / inventory 再構成ルールの整理
