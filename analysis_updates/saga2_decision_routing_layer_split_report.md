# Saga2 Decision/Routing Layer Split Report

## 要点

- current best reading では、battle-side evidence も **decision layer** と **routing layer** の 2 層分離をかなり自然に支持している
- `combatDecision` が担うのは  
  - accepted / rejected
  - shared branch
  - optional PTR-only branchVariant  
 までであり、後段の target/pointer/materialization はその結果を受ける routing layer に置くのが safest である
- したがって current code shape の  
  `combatDecision -> postBranchRoute`  
 という分離は、単なる実装都合ではなく battle-side narrowing とかなり整合している

## 1. Why The Battle-Side Evidence Supports A Decision Layer

既報で狭めてきた `combatDecision` の source/consumer は、
最終的に

- special-candidate family accept policy
- accepted first
- branch second
- PTR false 側だけ optional branchVariant

という narrow opener に収束している。

この時点で `combatDecision` は、
すでに target routing や pointer materialization を直接返す層ではない。

むしろ battle-side evidence が first-line で教えてくれるのは、
**この candidate を通すか**
**strict fallback のどの local branch に落とすか**
という decision 情報までである。

したがって decision layer を

- `accepted`
- `branch`
- optional `branchVariant`

に閉じるのは自然である。

## 2. Why Routing Naturally Comes Later

いっぽうで `targetSource`, `candidateOffset`, pointer-like record, materialization は、
解析の current best reading では

- path-specific source material
- branch choice shaping
- post-branch handling

の順で後ろに押し出されている。

特に `PTR` false 側では、
`candidateOffset` を最終 target へ直結させるより、
まず `branchVariant` に要約してから後段へ渡すほうが整合する。

このため routing layer は、
decision layer のあとに

- shared route core
- optional PTR refinement

として置くのが最も軽い。

## 3. Safest Current Decomposition

現時点の safest decomposition は次の通りである。

```ts
type CombatDecision = {
  accepted: boolean
  branch: number
  branchVariant?: 0 | 1
}

type PostBranchRoutingInput = {
  branch: number
  branchVariant?: 0 | 1
}
```

ここで raw `candidateOffset` は
`CombatDecision` の内部 unresolved material に留まり、
`PostBranchRoutingInput`
には出ない。

つまり:

1. decision layer が branch 情報へ要約する
2. routing layer がその要約結果を読む

という順が current best reading である。

## implication for step 6

この整理により、step 6 での provisional 実装方針もかなり明快になる。

- `resolveCombatRngAfterLocalPath(...)` は decision layer
- `routeAfterDecision(...)` は routing layer

として分けてよい。

しかもこの分離は、
`ATK/PTR` 共通化と `PTR-only branchVariant`
の両方を無理なく保持できる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. battle-side の local opener が first-line で本当に decision layer だけを必要としているか
2. routing layer が `branch/branchVariant` だけで十分説明できるか
3. target routing や pointer materialization が second-line evidence としてどこに現れるか

ここが取れれば、current code shape は provisional の域をかなり超えて、battle-side recovered decomposition に近づく。
