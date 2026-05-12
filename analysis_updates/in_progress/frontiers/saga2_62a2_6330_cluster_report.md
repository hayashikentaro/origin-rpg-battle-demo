# SaGa2 `62A2-6330` selector budget cluster report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c2a2_budget_report.md`
- 既存 `saga2_c745_c70a_cost_tables_report.md`
- 既存 `saga2_c745_head_update_report.md`

## 目的

- `62A2-6330` を 1 本の caller cluster として擬似コード化する
- `C2A2`, `C745`, `C70A`, `C71D` の phase 切替を整理する

## 結論

`62A2-6330` は、現時点では
**selector candidate を 1 件ずつ試し、budget `C2A2` で支払えるか判定し、成功/失敗で別 UI/flow へ分岐する高位 cluster**
とみるのが最も整合する。

この cluster の重要点は 3 つある。

1. `C745` はこの cluster 内だけでも  
   `head/threshold scratch` と `record-derived pointer/head` を行き来している  
2. `C2A2` は current candidate value を積む pool であると同時に、`C745` head と compare/subtract される spendable budget として使われる  
3. `62FF -> CALL $0174 -> CALL $01A7` で active entry を進める loop があり、1 件ずつ candidate を消費/選別している

したがって `C745` を固定 struct に閉じず、
**phase-based workspace cluster**
として持つのが移植上安全。

## 1. cluster 全体

対象範囲:

```text
62A2: XOR A
62A3: LD HL,$C745
62A6: LDI (HL),A
62A7: LDI (HL),A
62A8: LD (HL),A
62A9: LD HL,$C207
62AC: LD B,$04
62AE: CALL $630B
62B1: DEC B
62B2: JR NZ,$62AE
62B4: CALL $0198
62B7: CALL NZ,$630B
62BA: LD E,$1E
62BC: RST $08
62BD: XOR A
62BE: CALL $01B9
62C1: LD E,$2A
62C3: LDH A,($FF8C)
62C5: CP $FF
62C7: JR Z,$62F9
62C9: AND A
62CA: CALL NZ,$5F07
62CD: JR NZ,$62F9
62CF: LD DE,$C2A2
62D2: LD HL,$C745
62D5: CALL $0168
62D8: JR C,$62F4
62DA: CALL $0165
62DD: LD A,$33
62DF: LDH ($FFB2),A
62E1: CALL $6332
62E4: CALL $5E35
62E7: LD DE,$1C1B
62EA: CALL $5E65
62ED: LD E,$1D
62EF: RST $08
62F0: LD E,$29
62F2: JR $62F9
62F4: CALL $5EFE
62F7: LD E,$1F
62F9: CALL $01B0
62FC: RST $08
62FD: CALL $0174
6300: CALL $01A7
6303: AND A
6304: JR Z,$62FC
6306: JP $5EB1
```

## 2. phase 分解

### phase A: `C745` head clear

```text
62A2-62A8: C745..C747 = 0
```

ここでまず `C745` 先頭 3 byte を clear する。

### phase B: record scan / head update

```text
62A9: HL=$C207
62AC: B=4
62AE: CALL $630B
...
62B4: CALL $0198
62B7: CALL NZ,$630B
```

`630B` は record header を見て、
条件に合うものだけ `0156` の 16bit subtract delta を
`C745/C746` に加算する helper だった。

したがってこの段は、
**record 集合を走査して `C745` head を準備する pass**
とみるのが自然。

### phase C: candidate pick / gate

```text
62BA: RST $08(E=$1E)
62BE: CALL $01B9
62C3: A = FF8C
62C5: CP $FF
...
62C9: CALL NZ,$5F07
```

ここで current candidate / current selection を 1 件取り、
`FF8C` と `5F07` を使う gate を通す。

### phase D: budget compare / spend

```text
62CF: DE=$C2A2
62D2: HL=$C745
62D5: CALL $0168
62D8: JR C,$62F4
62DA: CALL $0165
```

支払えなければ fail branch、
支払えるなら `C2A2 -= C745_head`。

したがってこの時点の `C745` は
**current spend head**
である可能性が高い。

### phase E: success / fail side effect

success:

```text
62DD: LD A,$33
62DF: LDH ($FFB2),A
62E1: CALL $6332
62E4: CALL $5E35
62E7: CALL $5E65(DE=$1C1B)
62ED: E=$1D ; RST $08
62F0: E=$29
```

fail:

```text
62F4: CALL $5EFE
62F7: E=$1F
```

### phase F: post-event wait and advance

```text
62F9: CALL $01B0
62FC: RST $08
62FD: CALL $0174
6300: CALL $01A7
6303: AND A
6304: JR Z,$62FC
6306: JP $5EB1
```

ここは `049D/0494` 系の input/wait/advance loop に見える。

つまり 1 件処理するごとに UI/event を挟み、
次 candidate へ進んでいる。

## 3. `630B` helper の意味

`630B-632F`:

```text
630B: PUSH HL
630C: DEC HL
630D: LDI A,(HL)
630E: AND $90
6310: JR NZ,$632D
6312: LD E,(HL)
6313: INC HL
6314: LD D,(HL)
6315: INC HL
6316: LDI A,(HL)
6317: LD H,(HL)
6318: LD L,A
6319: CALL $0156
631C: LD A,($C745)
631F: LD E,A
6320: LD A,($C746)
6323: LD D,A
6324: ADD HL,DE
6325: LD A,L
6326: LD ($C745),A
6329: LD A,H
632A: LD ($C746),A
632D: POP HL
632E: LD A,$20
632F: RST $00
```

ここでは current record の 16bit fields から delta を作り、
`C745/C746` に累積している。

よって `C745/C746` はこの phase では
**table ではなく running head**
と読むのが自然。

## 4. `C745` の phase 切替

この cluster に限定しても `C745` は少なくとも 2 相を持つ。

### `62A2-62D8`

- `C745/C746` = running head / spend head

### それ以外の cluster (`64B0` など)

- `C745+0,+3,+6...` = `6669` 由来の 3byte value table

つまり `C745` は「ひとつの意味を持つ変数」ではなく、
**同じ backing bytes を phase で再利用する workspace family**
である可能性が高い。

## 5. 擬似コード

最も安全な高位擬似コードは:

```ts
clearC745Head()

for each sourceRecord in firstPassRecords:
  updateC745HeadFromRecord(sourceRecord)

maybeUpdateC745HeadFromExtraRecord()

while true:
  candidate = pickCurrentCandidate()

  if candidate == none:
    failOrExit()
    break

  if gateRejects(candidate):
    failOrExit()
    break

  if budgetC2A2 < currentHeadC745:
    showFailPath()
  else:
    budgetC2A2 -= currentHeadC745
    runSuccessPath()

  waitAndAdvance()
  if done():
    break
```

## 6. 移植上の意味

TypeScript 側では、この cluster を

```ts
prepareHead()
pickCandidate()
canSpendHead()
spendHead()
advanceLoop()
```

のように分けると実装しやすい。

とくに `C745` は:

```ts
type SelectorClusterState = {
  head16?: number
  headValue24?: number
  costTable?: number[]
}
```

のように phase ごとの optional state として持つほうが安全。

## 7. まだ未確定な点

- `C207` source records のドメイン
- `6332` success-side helper の厳密な役割
- `0174/01A7` の done 条件
- `64B0` table materialization とこの cluster の前後関係

## 次の一手

1. `6332` を切って success-side effect を確定する
2. `0174/01A7` をまとめて input/advance ループとして契約化する
3. `C207` record source を追って cluster 全体のドメインを item/shop/script で固定する
