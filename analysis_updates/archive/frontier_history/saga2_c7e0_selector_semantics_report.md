# SaGa2 C7E0 selector semantics report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_c7e0_shared_scratch_report.md`
- `reports/saga2_script_opcode_analysis.csv`

## 目的

- bank0 `1237-124B` と `109F-10C2` の `C7E0` read path を切る
- `C7E0` 各 entry が候補IDかスロット番号かを一段絞る

## 結論

今回の結論は、
`C7E0..C7ED` は単なる presence bitmap ではなく
**index -> resolved candidate value を返す 14件 selector table**
とみるのが自然だということ。

特に:

- `0x1D @ 1237` は `REMOVE_ITEM_OR_CONSUME` 候補
- `0x1C @ 109F` は inventory / save data 系 selector

として既報 `saga2_script_opcode_analysis.csv` と整合しており、
どちらも script 引数を分類したあと
`HL = C7E0 + index` を引いて
`A=(HL); CP $FF` をしている。

この形から、`C7E0` 各 entry は
**候補が存在するかどうかを `FF` で示しつつ、存在する場合は “実スロット番号 / 実 candidate index” を返す sparse remap table**
とみるのが最も安全。

## 1. `1237-124B` の形

実バイト:

```text
1237: RST $30
1238: CP $10
123A: JR C,$1244
123C: LD A,($C709)
123F: CALL $10CC
1242: JR $1248
1244: LD HL,$C7E0
1247: RST $00
1248: LD B,$01
124A: LD A,(HL)
124B: CP $FF
```

`saga2_script_opcode_analysis.csv` では opcode `0x1D` を:

- `REMOVE_ITEM_OR_CONSUME`
- `party/inventory/save data`

としている。

ここで重要なのは、
この code path が `A < 0x10` のとき
**`C7E0 + A` を直接読む**
こと。

したがって script 側から見た low range 引数は、
`C7E0` を通じて実候補へ再マップされている可能性が高い。

## 2. `109F-10C2` の形

実バイト:

```text
109F: RST $30
10A0: CP $10
10A2: JR C,$10B1
10A4: CP $30
10A6: JR NC,$10B7
10A8: SUB $20
10AA: LD HL,$C71D
10AD: ADD A,A
10AE: RST $00
10AF: JR $10BD
10B1: LD HL,$C7E0
10B4: RST $00
10B5: JR $10BD
10B7: LD A,($C709)
10BA: CALL $10CC
10BD: LD B,$08
10BF: LD A,(HL)
10C0: CP $FF
10C2: JP Z,$1562
```

`saga2_script_opcode_analysis.csv` では opcode `0x1C` を:

- `party/inventory/save data`

としている。

ここでも `A < 0x10` の low range は
`C7E0 + A`
へ落ちる。

一方 `0x20..0x2F` は `C71D` 側の 2byte table へ行く。

つまり設計としては:

- low range: `C7E0` sparse selector table
- mid range: fixed 2byte table (`C71D`)
- high range: player-local inventory pointer (`10CC`)

という **複数 selector space の切替**
になっている。

## 3. 候補IDより「実スロット番号」のほうが自然な理由

`C7E0` read のあとにやっているのは:

```text
LD A,(HL)
CP $FF
```

であり、値そのものを直後に算術変換していない。

また `5B64-5B90` では high nibble 0 entry について
`LD A,C ; LD (DE),A`
で `sourceIndex` を flat に詰めている。

この 2 点を合わせると、
`C7E0` に入るのは抽象IDより
**元テーブル中の sourceIndex / 実スロット番号**
と見るほうが自然。

つまり `C7E0[logicalIndex] = physicalSlotIndex`
で、`FF` は未割当。

## 4. 暫定型

```ts
type SharedEntryList14 = Array<number | null>
// null <=> 0xFF
// value = resolved source slot / physical slot index
```

この見方なら:

- `5B64-5B90` の `LD A,C ; LD (DE),A`
- `1237` / `109F` の `CP $FF`

がかなり自然につながる。

## 5. 移植への意味

TypeScript 側では `C7E0` を
「候補IDの配列」より
**logical selector を physical slot へ変換する sparse remap table**
として持つほうが安全。

たとえば:

```ts
resolveSharedSelection(logicalIndex): number | null
```

のように切ると、battle / item / magi の共有 scratch として扱いやすい。

## 次の一手

1. `10CC` の契約を切って high range 側が返す physical slot と比較する
2. `5B64-5B90` caller 文脈で `logicalIndex` の意味を決める
3. `C71D` 側 selector table と `C7E0` の役割差を整理する
