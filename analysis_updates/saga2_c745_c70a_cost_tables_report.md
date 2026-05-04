# SaGa2 `C745/C70A` cost table report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c2a2_budget_report.md`

## 目的

- `C745` と `C70A` の producer を追う
- `C2A2` が比較/減算している cost 側の実体を整理する

## 結論

現時点では、

- `C70A` は **current sourceIndex から `6669` で都度作る単発 3byte cost/value scratch**
- `C745` は **複数 sourceIndex から構築される連続 3byte table の base**

とみるのが最も整合する。

特に強いのは次の 4 点。

1. `6548-6554` では `DE=$C70A` に対して `CALL $6669` を当て、その直後 `DE=$C2A2 ; HL=$C70A ; CALL $0168/$0165` を行っている  
2. したがって `C70A` は current candidate の **一時 cost scratch** とみてよい  
3. `64B0-64BC` では `HL=$C71D`, `DE=$C745`, `B=$08` で `CALL $6669` を 8 回回している  
4. `6669` は 1 回ごとに `DE` を 3 byte 進めるため、`C745` は **8 件ぶんの 3byte table base** と読むのが自然

このため `62D1` の `HL=$C745` compare/subtract は
単一 threshold より
**list/table 化された cost 群の先頭か current head**
を使っている可能性が高い。

## 1. `C70A` は単発 cost scratch

`6548-6559`:

```text
6548: LD A,C
6549: LD DE,$C70A
654C: PUSH DE
654D: CALL $6669
6550: POP HL
6551: LD DE,$C2A2
6554: CALL $0168
6557: JR C,$6589
6559: CALL $0165
```

ここでは:

- `A=C = resolved sourceIndex`
- `DE=$C70A`
- `CALL $6669`

なので、`6669` は `sourceIndex -> 3byte value` を `C70A` へ展開している。

その直後に:

- `DE=$C2A2`
- `HL=$C70A`
- compare / subtract

となるため、`C70A` はかなり明確に
**current candidate cost/value の一時 scratch**
である。

## 2. `C745` は table base 候補

`64B0-64BC`:

```text
64B0: LD DE,$C745
64B3: LD B,$08
64B5: LDI A,(HL)
64B6: INC HL
64B7: CALL $6669
64BA: DEC B
64BB: JR NZ,$64B5
```

この直前で `HL=$C71D` へ寄っているので、
`C71D` pair list の byte0 を 8 件取り出し、
それぞれを `6669` で 3byte value 化して `C745` へ並べている流れと読むのが自然。

重要なのは、`6669` が copy 中に `DE` を進めること。
したがって 8 回ループすると

```ts
C745 + 0x00 : value[0] (3 bytes)
C745 + 0x03 : value[1] (3 bytes)
C745 + 0x06 : value[2] (3 bytes)
...
```

のような layout を作る可能性が高い。

つまり `C745` は単一 3byte 値というより
**3byte record array の base**
として持つほうが整合する。

## 3. `62A2` の zero init

`62A2-62A8`:

```text
62A2: XOR A
62A3: LD HL,$C745
62A6: LDI (HL),A
62A7: LDI (HL),A
62A8: LD (HL),A
```

少なくとも compare/subtract 前に
先頭 3 byte を 0 初期化している。

これは:

- table head clear
- running total clear
- current active entry clear

のいずれにも読めるが、
`64B0` の bulk builder と並べると
**base/first entry を明示初期化してから後段で table を埋める**
読み方が自然。

## 4. `62D1` の位置づけ

`62D1-62DC`:

```text
62D1: LD DE,$C2A2
62D4: LD HL,$C745
62D7: CALL $0168
62DA: JR C,$62F6
62DC: CALL $0165
```

ここだけ見ると `C745` は単一 cost に見えるが、
`64B0` の bulk builder まで考えると

- 先頭 entry を使っている
- current active head が `C745+0` にある
- table の中でも特別扱いの slot 0 を見ている

などの可能性が残る。

したがって現時点では
**`C745` = 3byte threshold**
と断定するより、
**`C745` = cost table base / current head workspace**
と持つのが安全。

## 5. `C71D` との接続

`64B0` は `C71D` から `C745` を作っているため、
high-range selector runtime buffer `C71D` の `sourceIndex` が
`6669` に通されて value/cost table 化される構造が見える。

つまり:

```ts
C71D[i].sourceIndex -> lookup7860(sourceIndex) -> C745[i]
```

という presentation/selection ではなく
**cost evaluation 用の table materialization**
が起きている可能性が高い。

## 6. 現時点の実装寄り整理

いまのところ最も安全なのは次の分け方。

```ts
type Value24 = number

type CurrentCostScratch = Value24   // C70A
type CostTable = Value24[]          // C745 base
type BudgetPool = Value24           // C2A2
```

そして subsystem によって

- current sourceIndex を `C70A` へ出す path
- sourceIndex list を `C745[]` に展開する path

の 2 本があるとみる。

## 7. まだ未確定な点

- `C745` が本当に 8 件全部使われるか
- `62D1` が `C745[0]` だけを見るのか、別 path で pointer が進むのか
- `6310-632D` が `C745` の head 更新をしているか
- `C70A` の caller cluster が item/shop/script のどれに属するか

## 次の一手

1. `6310-632D` を切って `C745+0/+1/+2` の更新規則を確認する
2. `64B0` caller cluster を整理して `C71D -> C745[]` の subsystem を固定する
3. `6554` caller cluster を整理して `C70A` path のドメインを分ける
