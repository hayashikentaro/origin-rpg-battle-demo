# Saga2 Special Candidate Family Variant Report

## 要点

- current best reading では、`code == 0E` と `code == 0F` は完全に別意味の special code というより、**同じ special-candidate family の非対称 variant** とみるのが最も自然である
- 共通しているのは、どちらも `qualifier (H)` を使う追加 gate を持ち、最終的に `41D9-41EC` の local consume path へ進入しうること
- 非対称なのは、`0F` だけが **`qualifier == 0` で fast-path 的に `41D9` へ直進できる** 点で、`0E` は常に qualifier-aware path を通る

## relevant flow

```text
41C9: CP $0E
41CB: JR Z,$41D5
41CD: CP $0F
41CF: JR NZ,$41D9
41D1: LD A,H
41D2: OR A
41D3: JR Z,$41D9
41D5: LD A,H
41D6: DEC A
41D7: JR Z,$41F1
41D9: INC E
...
41E6: LD A,(DE)
41E7: CP $FE
41E9: JR Z,$41ED
41EB: DEC A
41EC: LD (DE),A
```

## 1. `0E` と `0F` の共通点

どちらも単なる空値ではなく、

- special handling を受ける
- `H` を見る追加 gate を持つ
- 条件を満たせば `41D9-41EC` の consume belt へ進入する

という profile を持つ。

したがって safest provisional reading は、

- `0E`
- `0F`

を「無関係な 2 種類の magic number」として扱うより、
**special candidate family の 2 variant**
として同じ層に置くことである。

## 2. 非対称性

非対称なのは qualifier の扱いである。

### `0E`

`0E` は無条件で `41D5` へ入る。

したがって qualifier を必ず通る
**strict special variant**
とみるのが自然である。

### `0F`

`0F` は

- `H == 0` なら `41D9` へ直進
- `H != 0` なら `41D5` を経由

する。

したがって `0F` は
**qualifier==0 だけ fast-path を持つ special variant**
とみるのが最も整合する。

## 3. `DEC A ; JR Z` の意味

`41D5-41D7` は

- `H == 1` のときだけ reject
- `H == 0` や `H >= 2` は reject しない

という gate と読める。

この形は、qualifier を単なる boolean より

- count-like byte
- owner/count mixed byte
- subtype-local availability byte

のような **small ordinal qualifier**
として扱うほうが自然であることを補強する。

## provisional semantics

現時点では、次のように持つのがいちばん安全である。

```ts
type SpecialCandidateCode =
  | { code: 0x0e; family: "special"; qualifierMode: "strict" }
  | { code: 0x0f; family: "special"; qualifierMode: "zero-fast-path" }
```

ここで重要なのは battle-side の具体 meaning より、

- `0E/0F` は同一 family
- ただし qualifier の扱いが対称ではない

という構造である。

## implication for `combatDecision`

この読みを採ると、current `combatDecision` は
単なる `counter gate` より、

- `normal candidate`
- `special candidate family (0E/0F)`
- `empty sentinel (FF)`

を振り分ける **candidate-entry local gate**
として持つほうが battle semantics に近い。

さらに言えば、`PTR` 系 path で見えている unresolved gate も、
`07/08` で引いた pointer candidate の後に
この special-candidate family を通るかどうか、
という見方にかなり自然につながる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `qualifier == 1` reject が何を意味するか
2. `qualifier == 0` と `qualifier >= 2` が同じ「許可」でも、後段の consume 意味が同一か
3. `0E/0F` family に入る candidate entry が inventory 由来か action-path 由来か

ここが取れれば、`combatDecision` は
**special-candidate family gate**
としてさらに battle API に近づけられる。
