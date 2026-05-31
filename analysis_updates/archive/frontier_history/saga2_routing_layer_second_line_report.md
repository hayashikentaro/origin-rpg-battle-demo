# Saga2 Routing-Layer Second-Line Report

## 要点

- current best reading では、routing layer の second-line evidence は **target routing / pointer materialization** にあり、これは `combatDecision` の `accepted/branch/branchVariant` が先に確定したあとで初めて意味を持つとみるのが最も自然である
- つまり battle-side decomposition は first-line で  
  - decision layer  
  - routing layer  
 へ分かれ、second-line で routing layer の中に  
  - target routing  
  - pointer/materialization  
 がぶら下がる、という 2 段構造になる
- したがって current code frontier でも、`postBranchRoute` のあとに target/pointer 系を実装していく順は battle-side narrowing と整合している

## 1. Why Target/Pointer Belong To The Second Line

既報では `combatDecision` を

- `accepted`
- `branch`
- optional `branchVariant`

に閉じてよいところまで狭めてきた。

この reading が成り立つなら、
target や pointer の意味は
その decision を受けた後段で初めて展開されるはずである。

逆に target/pointer を first-line に戻してしまうと、
`combatDecision` の narrowing で得た
decision layer の独立性が弱くなる。

このため safest reading は、
target routing / pointer materialization を
**routing layer の second-line evidence**
として置くことである。

## 2. How This Fits PTR

`PTR` false 側では、

- `candidateOffset`
- `branchVariant 0/1`
- post-branch routing

の順が current best reading である。

このとき `candidateOffset` 自体は first-line では
`branchVariant` に要約され、
target/pointer の direct input とはみなさない。

したがって `PTR` でも second-line で初めて

- target routing
- pointer-like record materialization

が reopening するとみるほうが自然になる。

つまり `PTR` の特別さは first-line の decision refinement にあり、
target/pointer 層の reopening はそのあとである。

## 3. Safest Current Decomposition

現時点の safest decomposition は次のように書ける。

```ts
type CombatDecision = {
  accepted: boolean
  branch: number
  branchVariant?: 0 | 1
}

type PostBranchRoute = number

// second line
type RoutingMaterialization = {
  target?: number
  targetSource?: "explicit" | "candidate" | "slotIndex"
  pointerRecord?: number
}
```

ここで重要なのは、
`RoutingMaterialization`
が `CombatDecision` の direct payload ではなく、
`PostBranchRoute`
の後に現れる second-line evidence だという点である。

## implication for step 6

この整理を採ると、step 6 の実装順もかなり明快になる。

1. `combatDecision`
2. `postBranchRoute`
3. target routing / pointer materialization

の順で layer を積めばよい。

つまり current code frontier は、
まだ target/pointer の最終意味が未確定でも
decision/routing の骨格を先に作って問題ない段階にある。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `postBranchRoute` のあとで初めて target routing evidence が現れるか
2. pointer-like materialization が `PTR` でも second-line へ遅延しているか
3. `ATK` と `PTR` の second-line 差分が target/pointer 層でどう出るか

ここが取れれば、routing layer の second-line evidence まで含めた recovered decomposition がかなり具体化する。
