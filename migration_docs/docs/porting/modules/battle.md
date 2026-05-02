# Battle Module

## 対象

TypeScript `battle` モジュールで再現する領域。

- 行動選択
- 対象解決
- 効果解決
- ダメージ適用
- HP 書き戻し
- 戦闘メッセージの中立イベント化

## 主要ソース

- `reports/saga2_damage_pass19_report.md`
- `reports/saga2_damage_narrow_pass20_report.md`
- `reports/saga2_damage_formula_pass21_report.md`
- `reports/saga2_damage_formula_hypothesis_pass21.json`
- `reports/saga2_damage_upstream_pass22_report.md`
- `reports/saga2_damage_upstream_pass23_report.md`
- `reports/saga2_damage_upstream_hypothesis_pass23.json`
- `reports/saga2_usage_handlers_pass27_report.md`
- `reports/saga2_usage_handler_names_pass28_report.md`
- `reports/saga2_item_fields_by_category_pass29_report.md`
- `reports/saga2_ability_item_table_pass24.csv`
- `reports/saga2_usage_values_pass26.json`

## 解析から読み取れる現在の安全な分解

1. ability / item / script から effect を引く
2. usage handler で broad kind を決める
3. upstream routine で amount を計算する
4. HP へ subtract / writeback を行う
5. 死亡判定と副次効果を処理する
6. メッセージや演出トリガを中立イベントとして返す

## battle 実装の最初の責務

- `BattleActor`
- `BattleAction`
- `BattleEffect`
- `DamageContext`
- `applyDamage`
- `resolveAction`
- `resolveUsageHandler`

## 現時点で確度が高いこと

- ダメージ出口は HP 関連フィールドへの subtract → writeback
- usage handler は battle / script / menu / shop などへ大分類できる
- battle item effect handler 群は十分に独立した入り口として扱える

## 未確定事項

- 最終ダメージの上流生成で、乱数・属性・耐性・係数の完全確定がまだ不足
- item 8 byte の各列は usage/category 依存
- script 由来の戦闘演出と純粋な数値処理の切り分けは今後さらに必要

## TypeScript 側の実装方針

- まず broad kind ベースで handler を分岐する
- raw bytes と named hypothesis を両方保持する
- effect 解決と HP 適用を分ける
- ダメージ計算は `rng` 注入型にして純粋関数で持つ
