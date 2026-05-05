# Saga2 Post-Route Target-Evidence Order Report

## 要点

- current best reading では、battle-side の **target routing evidence** は `combatDecision` の直後ではなく、まず **`postBranchRoute` が確定したあと** に現れるとみるのが最も自然である
- つまり `ATK` でも `PTR` でも、first-line では  
  - decision layer  
  - post-branch routing core  
 までが先にあり、target/source/pointer の差分は second-line でぶら下がる
- したがって current frontier では、`target` や `targetSource` を `combatDecision` に押し込むより、`postBranchRoute` のあとで reopening する evidence として扱うのが safest である

## 1. Why Target Evidence Comes After `postBranchRoute`

既報では current best reading を

1. `accepted`
2. `branch`
3. optional `branchVariant`
4. `postBranchRoute`

まで first-line で固定してきた。

この流れを採るなら、
target routing が first-line に戻る余地は小さい。

特に `PTR` false 側では、

- `candidateOffset`
- `branchVariant`
- post-branch routing

の順で narrow 化しているため、
`targetSource` や final target はその後で初めて意味を持つとみるほうが自然になる。

## 2. How This Fits ATK/PTR Together

`ATK` と `PTR` の違いは current best reading では、

- `branchVariant` が要るか
- candidate-flavored refinement があるか

に寄っている。

しかしその差分があるとしても、
second-line の target evidence へ入る前に
**shared `postBranchRoute` core**
が一度挟まるほうが全体構造はきれいである。

つまり safest decomposition は:

- `ATK`: `branch -> postBranchRoute -> target evidence`
- `PTR`: `branch -> branchVariant -> postBranchRoute -> target evidence`

であり、target evidence は両者とも routing core の後ろに置くのが自然である。

## 3. Safest Current Decomposition

現時点の safest decomposition は次のように書ける。

```ts
type CombatDecision = {
  accepted: boolean
  branch: number
  branchVariant?: 0 | 1
}

type PostBranchRoute = number

type SecondLineTargetEvidence = {
  target?: number
  targetSource?: "explicit" | "candidate" | "slotIndex"
  pointerRecord?: number
}
```

ここで `SecondLineTargetEvidence` は
`CombatDecision` の直返り値ではなく、
`PostBranchRoute`
の後で初めて reopening するものとして持つのが safest である。

## implication for step 6

この整理を採ると、step 6 の provisional 実装では

1. `resolveCombatRngAfterLocalPath(...)`
2. `routeAfterDecision(...)`
3. target/pointer materialization

の順に機能を足していけばよい。

つまり current code frontier では、
`target` / `targetSource`
はまだ debug/output に存在していても、
意味論としては second-line reopening として扱うのが安全である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `postBranchRoute` のあとで初めて target/source evidence が現れるか
2. `PTR` second-line が `ATK` second-line より pointer/materialization に強く寄るか
3. `targetSource="candidate"` が false 側 second-line reopening でも維持されるか

ここが取れれば、routing layer の second-line decomposition はかなり recovered semantics に近づく。
