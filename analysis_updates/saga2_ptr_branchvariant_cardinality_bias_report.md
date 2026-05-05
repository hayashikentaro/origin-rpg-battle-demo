# Saga2 PTR BranchVariant Cardinality Bias Report

## 要点

- current best reading では、`PTR` false 側の `branchVariant` は **多段の大きい variant 空間** より、まず **2-way か少数段階の refinement** とみるのが最も自然である
- 理由は、`candidateOffset` から得られる差分を current frontier では large index ではなく small ordinal selector として読んでおり、strict fallback branch の first consumer も actor-local opener の narrow gate に寄っているからである
- したがって current best bias は、`PTR` false 側の `branchVariant` は  
  - large fan-out ではなく  
  - まず 2-way、広く見ても少数段階  
 という形にとどめるのが safest である

## 1. Why A Small Cardinality Fits The Current Branch Model

既報では `PTR` false 側の refinement は

- `candidateOffset` の値域差
- offset-bucketed small-ordinal selector
- top-level `branch` ではなく strict fallback branch の下位 variant

として整理してきた。

この流れをそのまま伸ばすと、
`branchVariant` は raw pointer-scale fan-out ではなく、
**local fallback の分岐を少しだけ増やす refinement**
とみるのが自然になる。

つまり safest reading は、
first-line では

- binary split
  または
- 2〜3 個程度の small refinement

に留めることである。

## 2. Why Large Cardinality Would Be Too Strong

もし `branchVariant` が多段の大きい variant 空間を持つなら、
それは strict fallback gate というより
再び target resolution / pointer materialization の層へ近づく。

しかし current best reading では、
`combatDecision` の first consumer は

- accepted / rejected
- strict fallback
- narrow actor-local opener

に置かれている。

したがってここで必要なのは、
多数の fan-out ではなく
**small ordinal 的な refinement**
である。

## 3. Provisional Meaning

現時点の safest provisional reading は次のように書ける。

```ts
type CombatDecisionConsumerResult = {
  accepted: boolean
  branch: number
  branchVariant?: 0 | 1 | 2
  fallbackKind?: "strict-path"
  bypassesCurrentConsumeBelt?: boolean
}
```

ただし first-line bias は

```ts
branchVariant?: 0 | 1
```

であり、`2` は拡張余地として second line に置くのが安全である。

## implication for step 6

この整理を採ると、step 6 の TypeScript provisional shape でも
`branchVariant` を generic `number` のまま放置するより、
まずは

- optional small ordinal
- first-line は 2-way refinement

として扱うほうが battle-side meaning に近い。

つまり current frontier では、
`PTR` false 側の unresolved 部分は
「variant があるか」だけでなく
**その variant 空間は狭い**
という前提で進めるのが安全である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `PTR` false 側の `branchVariant` が first-line で 2-way split に留まるか
2. `candidateOffset` の値域 bucket も実質 2-way に近いか
3. target routing はその small-cardinality variant 決定後に二次的に走るか

ここが取れれば、`combatDecision` は
**shared branch + optional small-cardinality PTR-only branchVariant**
としてかなり実装寄りに固められる。
