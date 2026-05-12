# Saga2 Candidate-Offset Two-Way Bucket Bias Report

## 要点

- current best reading では、`PTR` false 側で `branchVariant` を作る `candidateOffset` の値域 bucket は **first-line では実質 2-way split** とみるのが最も自然である
- 理由は、`branchVariant` 自体を current frontier では 2-way か少数段階の refinement に抑えており、その upstream にある `candidateOffset` bucket も first-line では同程度の粗さで畳まれていると読むほうが flow に合うからである
- したがって current best bias は、`candidateOffset` は false 側で  
  - raw range をそのまま使うのではなく  
  - まず 2-way bucket に畳まれ  
  - その bucket が PTR-only `branchVariant` を支える  
 という形になる

## 1. Why Two-Way Bucketing Fits Better Than Multi-Bucket First

既報では `PTR` false 側の refinement を

- offset-range-partitioned
- small ordinal
- branch の下位 variant
- small-cardinality

と順に狭めてきた。

この流れをそのまま一段進めると、
first-line の safest reading は
**2-way bucket**
である。

もし最初から 3-way 以上の bucket を強く採ると、
それは evidence より一歩先に行き過ぎる。

一方 2-way split なら、

- strict fallback をそのまま保ちながら
- PTR にだけ minimal refinement を与える

という current best bias ときれいに噛み合う。

## 2. Why This Still Leaves Room For Later Refinement

この整理は
「最終的に絶対 2 段階しかない」
と断定するものではない。

むしろ current safest reading は、

- first-line = 2-way bucket
- second-line = 必要なら 3-way 以上へ拡張

という順序である。

つまり現段階では、
TypeScript provisional shape を
`0 | 1`
に寄せやすくするための bias
として使うのが自然になる。

## 3. Provisional Meaning

現時点の safest provisional reading は次のように書ける。

```ts
type CombatDecisionConsumerResult = {
  accepted: boolean
  branch: number
  branchVariant?: 0 | 1
  fallbackKind?: "strict-path"
  bypassesCurrentConsumeBelt?: boolean
}
```

そして `PTR` false 側の `branchVariant` は
first-line では
**candidateOffset の 2-way bucket**
に支えられているとみるのが自然である。

## implication for step 6

この整理を採ると、step 6 では
`combatDecision.branchVariant`
を generic number にしておくより、
まずは

- `undefined | 0 | 1`

という極小 shape で仮置きする方向がかなり自然になる。

つまり current frontier では、
`PTR` false 側の unresolved 部分は
「variant がある」
ではなく
**`candidateOffset` が first-line で 2-way bucket に畳まれる**
と読むところまで来ている。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `candidateOffset` の false 側 bucket が first-line で 2-way split に留まるか
2. その 2-way split が `branchVariant 0/1` にほぼ直結するか
3. より細かい bucket 差は second-step routing 以降へ遅延しているか

ここが取れれば、`combatDecision` は
**shared branch + optional PTR-only `branchVariant?: 0 | 1`**
としてかなり直接実装へ落とせる。
