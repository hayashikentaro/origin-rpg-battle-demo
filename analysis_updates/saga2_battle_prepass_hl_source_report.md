# SaGa2 battle prepass HL source report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_battle_action_class_prepass_report.md`
- 既存 `saga2_battle_rng_caller_cluster_report.md`

## 目的

- `43FA-443A` の caller 側から、9 entry list の実体を固定する
- `BC=$D500` が `443A` の主入力だという旧整理を修正する

## 結論

今回の実バイト再確認で、
`43FA-443A` の主入力は **`BC` ではなく `HL`** であり、
その `HL` は `0D:40B6` 以降で
**`D012`, `D112`, `D212`, ... を起点とする slot list**
として与えられている可能性が高くなった。

具体的には:

1. `40BC: CALL $43FA` の直前で `HL=$D012`
2. call ごとに `INC H` して `D0xx -> D1xx -> ...` と page を進める
3. `A=8` 回 loop している
4. `43FA` 自体は `LDI A,(HL)` から始まるため、**caller が渡す `HL` が 9件リスト本体**

したがって `43FA-443A` は、
`D500/D600/D700` page を直接読む helper というより、
**`D?12..` にある action/inventory-like slot list を 1 page ずつ走査して class flags を畳み込む helper**
として見るのが自然。

## 1. caller 実バイト

`0D:4090-40C5`:

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
40B6: LD HL,$D012
40B9: LD A,$08
40BB: PUSH AF
40BC: PUSH HL
40BD: CALL $43FA
40C0: POP HL
40C1: INC H
40C2: POP AF
40C3: DEC A
40C4: JR NZ,$40BB
```

ここから見えることはかなり強い。

## 2. `43FA` への入力は `HL`

`43FA` 本体は:

```text
43FA: LD E,$2D
43FC: LD D,H
...
4405: LDI A,(HL)
...
443A: RET
```

なので page 高位 `H` と、そこで始まる list pointer `HL` が
そのまま principal input になっている。

この helperは `BC` を参照していないため、
以前の
**「`BC=$D500` が `443A` caller page family」**
という整理は強く修正が必要になった。

## 3. `D012` 起点 8 page loop

caller では:

```text
LD HL,$D012
LD A,$08
loop:
  PUSH AF
  PUSH HL
  CALL $43FA
  POP HL
  INC H
  POP AF
  DEC A
  JR NZ,loop
```

なので `43FA` は少なくとも:

- `D012`
- `D112`
- `D212`
- `D312`
- `D412`
- `D512`
- `D612`
- `D712`

の 8 page に対して回される。

`common.i` では `battle.data.1.inventory = $D012` なので、
これはかなり自然に
**battle page 内の inventory / action-slot 起点列**
として読める。

## 4. 9件リストとの整合

`43FA` は内部で:

- `B=9`
- 2byte entry を 9 回読む

ので、各 page では
**`D?12` から始まる 9 個の 2byte slot/candidate entry**
を走査している可能性が高い。

`449A` / `437E` 側で見えていた
`D?12..` の inventory-like 展開ともかなり整合する。

したがって現時点の最も安全な整理は:

```ts
type BattlePageSlotList = Array<{
  lo: number
  hi: number
}> // 9 entries from D?12
```

で、これを `43FA` が class fold 用に消費している、というもの。

## 5. `BC=$D500` の見直し

`4067: LD BC,$D500` は確かに存在するが、
`43FA-443A` の内部では `BC` を使っていない。

そのため、
この `BC` 初期化は:

- 直後に続く別 helper の先行準備
- あるいは caller cluster 全体で必要な副次レジスタ初期化

として扱うほうが安全。

少なくとも、
**`43FA` の 9件 list source を `D500/D600/D700` と決める根拠にはならない**。

## 6. 修正後の擬似コード

```ts
for (let page = 0; page < 8; page++) {
  const list = readSlotList(pageBase(0xd0 + page), 0x12, 9)
  foldActionClassFlags(list, pageBase(0xd0 + page))
}
```

ここで `foldActionClassFlags()` が
既報 `43FA-443A` に対応する。

## 移植への意味

TypeScript 側では、
この処理を `battle.data page` 内 inventory/action-slot 群の prepass として分離すると安全。

```ts
preparePageClassFlagsFromSlots(page)
```

少なくとも現時点では、
controller page family 専用 helper として閉じるより、
**battle.data page の slot list を畳み込む helper**
として持つほうが整合する。

## 次の一手

1. `D?12..` の 9件が inventory なのか action candidate list なのかを `449A` / `437E` と照合する
2. `4090-40B4` の `C2DA -> D?2A/2B/2C` 書き込みを切って、`43FA` 直前の page state を整理する
3. `4067: LD BC,$D500` が本当にどの後続 helperのための初期化かを再確認する
