# RNG Module

## 対象

TypeScript `rng` モジュールで再現する領域。

- 戦闘ダメージや分岐に使う乱数供給
- 将来的な成長 / ドロップ / 変身補助乱数

## 現時点の直接ソース

- `reports/saga2_damage_formula_pass21_report.md`
- `reports/Saga2DamageModelPass21.gd`
- `reports/Saga2DamagePipelinePass22.gd`

## 現状

このリポジトリには、乱数ルーチン単体を主対象にした解析成果はまだありません。

現時点で見えているのは battle 側からの利用形だけです。

- ダメージ算出で `rng & 0x03` 相当の分散を使う仮説がある
- 乱数の入力箇所は battle upstream の確定と一緒に詰める必要がある

## 実装方針

最初は ROM 完全再現よりも、注入可能なインターフェースで始めるのが安全です。

- `next(): number`
- `peek?(): number`
- `fork?(seed): Rng`

## battle 側との境界

- `battle` は RNG 実装詳細を知らない
- `rng` は seed 更新と値供給だけを担当する
- ROM 実機再現が進んだら実装を差し替えられる形にする

## 追加解析の優先度

1. 乱数更新ルーチンの特定
2. 戦闘開始時の seed 初期化
3. 行動順 / 命中 / ダメージ / ドロップでの消費順
