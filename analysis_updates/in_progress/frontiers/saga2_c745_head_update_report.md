# SaGa2 `C745` head update report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c745_c70a_cost_tables_report.md`

## 目的

- `6310-632D` を切る
- `C745+0/+1/+2` が固定 3byte value なのか phase-dependent workspace なのかを整理する

## 結論

`6310-632D` から見ると、`C745/C746` は少なくともこの phase では
**16bit head/pointer 的に更新される workspace**
と読むのが自然。

したがって `C745` は常に「3byte cost 値そのもの」とは限らず、
phase によって

- 3byte cost head
- 16bit pointer/head workspace
- cost table base

のいずれかとして再利用されている可能性が高い。

今回の強い確定点は次の 3 点。

1. `0156 -> 0376` は **`HL -= DE` の 16bit subtract helper** 候補  
2. `6312-6318` では record から `DE` と `HL` を組み、`CALL $0156` で差分を出している  
3. その差分を `C745/C746` に `ADD HL,DE` して書き戻しているため、ここでは `C745/C746` が数値 head/pointer として使われている

## 1. `0156 -> 0376`

wrapper:

```text
0156: JP $0376
```

実体:

```text
0376: LDH ($FF90),A
0378: PUSH DE
0379: LD A,L
037A: SUB E
037B: LD L,A
037C: LD A,H
037D: SBC D
037E: LD H,A
037F: JR C,$0384
0381: OR L
0382: JR $0385
0384: OR L
0385: SCF
0386: POP DE
0387: LDH A,($FF90)
0389: RET
```

少なくとも本体演算はかなり素直に:

```ts
HL = HL - DE
```

である。

flag 処理はまだ厳密に切っていないが、
この call site では主に **16bit delta 生成** として見てよい。

## 2. `6310-632D` の流れ

実バイト:

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

ここで見えているのは:

- record header の flag byte を見て特定 class を弾く
- record から 16bit `DE`
- record から 16bit `HL`
- `HL -= DE`
- その delta を `C745/C746` に加算

という流れ。

つまり `C745/C746` はこの局面では
**累積 offset / pointer head**
として扱われている可能性が高い。

## 3. `C745` の再解釈

前報では `64B0-64BC` から
`C745` を 3byte cost table base と読むのが自然だった。

今回の `6310-632D` まで含めると、
少なくとも `C745` には 2 通りの読み方が必要になる。

### 読み方 A

`62D1` 文脈:

```text
DE=$C2A2
HL=$C745
CALL $0168 / $0165
```

このときは `C745..` が 3byte threshold/cost head に見える。

### 読み方 B

`6310-632D` 文脈:

`C745/C746` は 16bit head/pointer として更新される。

このため一番安全なのは、
`C745` を固定 struct 名で早く閉じるより
**phase-dependent selector workspace**
として保留すること。

## 4. `64B0-64BC` との整合

`64B0` では:

```text
LD DE,$C745
LD B,$08
...
CALL $6669
```

なので、この時点では `C745` ベースへ 3byte entries を並べているように見える。

これと `6310-632D` を無理に 1 つへ潰すより、

- phase 1: sourceIndex list -> value table materialization
- phase 2: head/pointer update
- phase 3: compare/subtract against current head

のように、
同じ backing bytes を再利用していると見るのが整合しやすい。

## 5. 移植上の意味

TypeScript 側では `C745` を単純な `Value24` で固定せず、
selector-runtime の内部一時状態として

```ts
type SelectorCostWorkspace = {
  costTable?: number[]
  currentHeadValue?: number
  currentHeadPtr?: number
}
```

程度に phase を分けて持つほうが安全。

## 6. まだ未確定な点

- `62D1` 時点で `HL=$C745` が table head なのか別 scratch なのか
- `64B0` で作る 8件 table が `6310` より前か後か
- `6310` の record source が item/shop/script のどれか
- `C747` 以降の 3byte/array layout

## 次の一手

1. `62A2-6330` を 1 本の caller cluster として擬似コード化する
2. `64B0` と `62D1` の実行順を caller 側から切る
3. `6310` で読んでいる record source の base table を確定する
