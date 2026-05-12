# Saga2 PTR Second-Line Candidate-Source Persistence Report

## 要点

- current best reading では、`PTR` false 側の second-line reopening でも **`targetSource="candidate"` の flavor は少なくとも最初の target evidence までは維持される** とみるのが最も自然である
- 理由は、first-line で `candidateOffset` を `branchVariant` に要約しても、`PTR` 側の path-specific 差分が second-line reopening の入口で完全に消えると、`PTR` を別 refinement として持っている意味がかなり弱くなるからである
- したがって current best bias は、`PTR` false 側の second-line は  
  - shared `postBranchRoute` core のあとに  
  - candidate-flavored target/source reopening  
  が始まる、という形になる

## 1. Why Candidate Flavor Should Survive Into Second-Line Target Evidence

既報では first-line で

- `candidateOffset`
- 2-way bucket
- `branchVariant 0/1`

まで narrow 化している。

ただしこれは、
`PTR` の candidate 由来差分が second-line で即失われる
という意味ではない。

むしろ current best reading では、
first-line は decision/routing へ要約する層であり、
second-line で reopening する target/source evidence には
**candidate-flavored provenance**
がまだ残るとみるほうが自然になる。

## 2. Why This Does Not Pull TargetSource Back Into First-Line

ここで `targetSource="candidate"` が second-line まで残ると言っても、
それは `combatDecision` の direct payload に戻す話ではない。

順序は引き続き:

1. `combatDecision`
2. `postBranchRoute`
3. candidate-flavored target/source reopening

である。

つまり candidate source persistence は
first-line ではなく、
**second-line reopening の flavor**
として持つのが safest である。

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
  targetSource?: "candidate" | "explicit" | "slotIndex"
  pointerRecord?: number
}
```

このとき `PTR` false 側の current best bias は:

```ts
targetSource === "candidate" // at least at second-line reopening entry
```

である。

## implication for step 6

この整理を採ると、step 6 の current debug/output にある
`targetSource`
は、first-line decision shape ではなく
**second-line reopening evidence**
として読み直すのが自然になる。

つまり `combatDecision` と `postBranchRoute` を先に固定したうえで、
`PTR` 側だけが second-line で
candidate-flavored target reopening を見せる、
という整理がかなりしやすくなる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `PTR` false 側の second-line reopening 入口で `targetSource="candidate"` が維持されるか
2. その candidate flavor が pointer/materialization まで持続するか
3. `ATK` second-line との差が `targetSource` か `pointerRecord` のどちらに強く出るか

ここが取れれば、routing layer の second-line decomposition は `PTR` 側までかなり具体化する。
