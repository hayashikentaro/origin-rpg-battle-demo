# SaGa2 C71D builder subsystems report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c71d_c2b9_runtime_buffers_report.md`

## 目的

- `C71D` を構築する writer 群を subsystem ごとに分ける
- 同一 buffer 共有か、同形式の別用途かを整理する

## 結論

現時点では `C71D` builder は少なくとも 2 系統に分けて扱うのが安全。

1. **single-entry writer 系**: `3F08-3F1C`  
2. **8-entry bulk builder 系**: `6493-64A8`

どちらも最終的に `C71D` へ
`{sourceIndex, auxByte}` 風の pair を書く点は共通しているが、
caller 文脈と構築件数がかなり違う。

したがって今の段階では
「1 本の同一 subsystem が常に同じ意味で `C71D` を持つ」
と決め打ちせず、
**shared runtime buffer を複数 subsystem が上書き再利用している**
とみるのが最も安全。

## 1. single-entry writer: `3F08-3F1C`

実バイト:

```text
3F06: LD (HL),C
3F07: LD A,C
3F08: LD ($C71D),A
3F0B: INC HL
3F0C: PUSH HL
3F0D: LD A,$80
3F0F: ADD A,C
3F10: LD L,A
3F11: LD A,$7E
3F13: ADC A,$00
3F15: LD H,A
3F16: LD A,$0C
3F18: CALL $00D2
3F1B: POP HL
3F1C: LD (HL),A
```

ここでは:

- `C71D[0] = C`
- `C71E[0] = bank0C:7E80 + C` から引いた byte

という **1 pair だけ** の構築が見えている。

直後には `DE=$0107`, `DE=$0104`, `DE=$0106` を伴う UI/selection 呼び出しが並ぶため、
この cluster は
**単一候補の一時 staging**
に寄っている可能性が高い。

## 2. bulk builder: `6493-64A8`

実バイト:

```text
6493: LD DE,$C71D
6496: LD B,$08
6498: PUSH BC
6499: LD A,(HL+)
649A: LD (DE),A
649B: INC DE
649C: PUSH HL
649D: LD HL,$7E80
64A0: RST $00
64A1: LD A,$0C
64A3: CALL $00D2
64A6: POP HL
64A7: LD (DE),A
64A8: INC DE
64A9: POP BC
64AA: DEC B
64AB: JR NZ,$6498
```

ここでは **8 件分まとめて** `C71D..C72C` を埋めている。

さらに後段:

```text
64AD: LD HL,$C71D
64B0: LD DE,$C745
64B3: LD B,$08
64B5: LD A,(HL+)
64B6: INC HL
64B7: CALL $6669
```

で、pair の byte0 だけを取り出して `6669` へ渡している。

したがってこの builder は
**メニュー/ショップ/usage 用の 8候補 selector list**
を作っている可能性が高い。

## 3. 2 系統の共通フォーマット

件数は違っても、pair の形はかなり似ている。

```ts
type C71dPair = {
  sourceIndex: number
  auxByte: number
}
```

両者とも
`auxByte = bank0C:7E80 + sourceIndex`
である可能性が高い。

このため format は共通でも、
producer subsystem は別、
という整理が今のところ最も自然。

## 4. `10CC` / `6640` reader との関係

`10D4-1169` の high-range reader は `C71D` を:

```text
115A: LD HL,$C71D
115D: ADD A,A
1161: RST $00
1164: LD A,(HL)
1169: JP $1551
```

のように読んでおり、
pair の byte0 しか見ていない。

いっぽう `6493-64A8` 後段は `6669` を通して byte0 を表示化している。

なので少なくとも現時点では、
`C71D` pair の **byte0 が主たる source index**、
byte1 は補助 byte とみるのが安全。

## 5. 暫定 subsystem 分離

```ts
type C71dSingleEntryBuilder = (index: number) => void
type C71dBulkListBuilder = (sourceList8: number[]) => void
```

移植上は、同じ `C71D` backing storage を共有していても、
builder API は分けたほうが安全。

## 6. まだ未確定な点

- `3F08` cluster が script / menu / item のどこに属するか
- `6493-64A8` の source `79E0` 8件が shop 品目なのか usage 候補なのか
- pair byte1 の厳密な意味
- subsystem を跨いで `C71D` が生存する期間

## 移植上の意味

TypeScript 側では、
`C71D` を単に `SelectorPair[8]` と持つだけでなく、
**どの subsystem がいつ再構築するか**
も API 側で分けるのが安全。

つまり `selector-runtime` では、

- `buildSingleSelectorPair(...)`
- `buildSelectorList8(...)`

のように producer を分離する設計が向いている。

## 次の一手

1. `3EFC` cluster の caller を追って single-entry writer の subsystem を特定する
2. `79E0` source の caller を追って bulk builder の入力 list 意味を確定する
3. `C2B9` についても writer を subsystem ごとに分ける
