# SaGa2 growth / rng structural report

## 対象

- `rom/data.s`
- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`

## 目的

既存の `growth` / `rng` 未確定点のうち、ROM 生データから直接確定できる構造情報を整理する。

## 確定した構造

### 1. `data_rng` は 256 byte の一意テーブル

- ラベル: `bank $0F : $4000`
- ROM offset: `0x3C000`
- サイズ: `0x100` byte
- 次ラベル `data_sine` が `0x4100` にあるため、`data_rng` の範囲はちょうど 256 byte

確認結果:

- 256 要素すべてが `0x00` から `0xFF` を 1 回ずつ含む
- 単純な連番ではなく、順序がシャッフルされている

このため、少なくとも `data_rng` は

- 乱数の種そのもの
- LCG の係数

ではなく、

- 256 値の参照テーブル
- 擬似乱数順列テーブル
- 乱数値をならすための lookup

のいずれかである可能性が高い。

### 2. `data_growth_table` は 32 entry の等間隔しきい値列

- ラベル: `bank $0C : $7FB0`
- ROM offset: `0x33FB0`
- サイズ: `0x20` byte

raw:

```text
07 0F 17 1F 27 2F 37 3F 47 4F 57 5F 67 6F 77 7F
87 8F 97 9F A7 AF B7 BF C7 CF D7 DF E7 EF F7 FF
```

性質:

- 32 要素
- 単調増加
- 各要素の差分は `0x08`
- `value[n] = ((n + 1) * 8) - 1`

このため、`growth_table` は

- 5 bit 程度の rank / chance index
- 0..255 の RNG 値との比較用しきい値

へ変換する補助表である可能性が高い。

### 3. `data_ability_learning_thresholds` は 32 byte だが、単純なしきい値列ではない

- ラベル: `bank $0C : $7FD0`
- ROM offset: `0x33FD0`
- サイズ: `0x20` byte

raw:

```text
99 E4 B7 E9 B6 ED B5 E6 D5 F0 DD F1 B4 F2 D0 E3
C4 EF DE F4 D1 EB D2 F3 95 EA BD E7 9D FE DC F5
```

観察:

- 値は単調増加しない
- ほぼすべてが `0x95` 以降の ability / special item id 範囲に入る
- 16 組の 2 byte ペアとして見ると自然

対応例:

- `99 E4` = `ケアル / けいかい`
- `B7 E9` = `ファイア / ?どく`
- `D2 F3` = `ヒュプノシス / テレポート`
- `9D FE` = `サイコミラー / さいせい`

このため、現ラベル名の `thresholds` は未再検討とするのが安全で、少なくとも「32 個の数値しきい値」ではない可能性が高い。

### 4. `data_ability_learning_results` は bank 末尾にある 16 byte 領域

- ラベル: `bank $0C : $7FF0`
- ROM offset: `0x33FF0`
- サイズ: `0x10` byte

raw:

```text
3F 42 0F 00 00 00 00 00 00 00 00 00 00 00 00 00
```

観察:

- `results` は 16 byte しかない
- 先頭 3 byte 以外は 0
- 直前の 32 byte table と単純 1:1 対応には見えない

したがって、現時点では

- `thresholds` と `results` の名称対応
- エントリ粒度
- 成長 / 学習における参照順

の再検証が必要。

## ここから言える移植方針

### RNG

- TypeScript `rng` は、まず ROM 完全再現ではなく注入型インターフェースで実装する
- 将来、`data_rng` の参照規則が確定したら lookup-based 実装へ差し替える

### Growth

- `growth_table` は `chance_rank -> threshold_0_255` 変換テーブル候補として保持する
- `ability_learning_thresholds/results` は名前を鵜呑みにせず raw table として扱う
- 学習テーブルは「16 pair + 16 byte 補助表」の構造候補で再解析する

## 次の具体的な掘り方

1. `data_growth_table` を参照するコード箇所を見つける
2. `7FD0-7FFF` を参照する戦闘後 / 成長ルーチンを逆引きする
3. `data_rng` を参照するコード箇所から、index 更新規則と seed 初期化を特定する
