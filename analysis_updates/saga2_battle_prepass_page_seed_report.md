# SaGa2 battle prepass page seed report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_battle_prepass_hl_source_report.md`

## 目的

- `0D:4090-40B4` の役割を実バイトベースで整理する
- `43FA` 実行直前に `D?2A/2B/2C` がどう準備されるかを切る

## 結論

`0D:4090-40B4` は、
**`C2DA` から 14 個の 2byte entry を読み、対応する `D?2A/2B/2C` に page-local seed 情報を書き込む前処理 loop**
とみるのが自然。

見えている骨格はこうなる。

1. `HL = $C2DA`
2. `B = 0x0E`, `C = 0`
3. 2byte entry を 14 回読む
4. entry byte0 の high nibble が 0 でなければ page を選ぶ
5. その page の `+2A/+2B/+2C` に
   - `C`  
   - `01`
   - entry byte1
   を書く
6. 各 iteration で `C++`, `HL += 2`

したがってこれは
`43FA` が `D?12..` slot list を走査する前に、
**各 battle page に「どの source entry が有効か」を page-local に配る seed/setup loop**
として扱うのが安全。

## 1. 実コード

```text
4090: LD HL,$C2DA
4093: LD B,$0E
4095: LD C,$00

4097: PUSH BC
4098: LD A,(HL)
4099: AND $F0
409B: JR Z,$40AF
409D: PUSH HL
409E: INC HL
409F: LD E,(HL)
40A0: SWAP A
40A2: DEC A
40A3: ADD A,$D0
40A5: LD H,A
40A6: LD L,$2A
40A8: LD (HL),C
40A9: INC L
40AA: LD (HL),$01
40AC: INC L
40AD: LD (HL),E
40AE: POP HL

40AF: INC HL
40B0: INC HL
40B1: POP BC
40B2: INC C
40B3: DEC B
40B4: JR NZ,$4097
```

## 2. 入力 `C2DA` の形

loop は毎回:

```text
LD A,(HL)
...
INC HL
LD E,(HL)
...
INC HL
INC HL
```

なので `C2DA` 側は
**2byte entry が 14 個並ぶ table**
と読むのが自然。

使われ方から見ると:

- byte0: high nibble に page selector
- byte1: page-local payload

という構造がかなり強い。

low nibble はこの loop では使っていない。

## 3. page selector の作り方

selector 部は:

```text
LD A,(HL)
AND $F0
JR Z,skip
SWAP A
DEC A
ADD A,$D0
LD H,A
```

なので

```ts
pageHigh = 0xD0 + ((entry0 >> 4) - 1)
```

となる。

つまり high nibble `1..N` を
`D0..` page 番号へ変換していると読むのが自然。

少なくとも high nibble `0` は「無効/未使用 entry」扱い。

## 4. `D?2A/2B/2C` に入る値

書き込みは固定で:

```text
LD L,$2A
LD (HL),C
INC L
LD (HL),$01
INC L
LD (HL),E
```

したがって各 page には:

- `D?2A = source entry index (0..13)`
- `D?2B = 1`
- `D?2C = entry byte1 payload`

が入る。

このため `D?2A/2B/2C` は
page-local working fields であり、
`43FA` の直前 seed としてかなり自然。

## 5. `43FA` との接続

直後の既報では:

```text
40B6: LD HL,$D012
40B9: LD A,$08
...
40BD: CALL $43FA
40C1: INC H
```

で `43FA` を各 page に対して回している。

したがって `4090-40B4` は、
`43FA` 実行前に各 page の `2A/2B/2C` を埋める
**seed/setup phase**
として読むのが最も整合する。

## 6. 擬似コード

```ts
for (let i = 0; i < 14; i++) {
  const entry0 = read8(0xC2DA + i * 2)
  const entry1 = read8(0xC2DA + i * 2 + 1)

  const pageNibble = entry0 >> 4
  if (pageNibble === 0) continue

  const page = 0xD0 + (pageNibble - 1)
  write8((page << 8) | 0x2A, i)
  write8((page << 8) | 0x2B, 1)
  write8((page << 8) | 0x2C, entry1)
}
```

high nibble の意味そのものはまだ未確定だが、
少なくとも
**`C2DA` の entry が battle page を指名している**
ところまではかなり強い。

## 7. 現時点の意味づけ

いま安全に言える範囲では、
`D?2A/2B/2C` は次のような仮名が合う。

```ts
type BattlePagePrepassSeed = {
  sourceIndex: number   // +2A
  enabled: number       // +2B, usually 1
  payload: number       // +2C
}
```

`payload` の意味はまだ不明だが、
少なくとも page ごとの action/slot 候補に付随する
small metadata とみるのが自然。

## 移植への意味

TypeScript 側では `preparePageClassFlagsFromSlots()` の前に、
page-local seed を配る deterministic step を分けておくと安全。

```ts
seedBattlePagesFromC2daTable()
preparePageClassFlagsFromSlots()
```

## 次の一手

1. `C2DA` table の producer を追って、14 entry の意味を確定する
2. `43FA` 本体が `D?2A/2B/2C` をどこまで参照するかを再確認する
3. `D?12..` の 9件が inventory か action candidate かを `437E` 側と照合する
