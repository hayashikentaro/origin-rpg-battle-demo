# Saga2 CombatDecision Code-Shape Report

## 要点

- current implementation frontier では、`combatDecision` は **`accepted + shared branch + optional PTR-only branchVariant`** として provisional にコードへ反映できる段階まで来ている
- さらに post-branch routing も first-line では **`branch -> branchVariant -> postBranchRoute`** の shared-core skeleton として持つのが自然である
- したがって現在の safest code shape は、raw `candidateOffset` を後段へ直接漏らさず、  
  - `combatDecision` が `branch/branchVariant` を返し  
  - routing 側がそれを受けて `postBranchRoute` を作る  
 という 2 層分離である

## 1. CombatDecision Current Provisional Shape

current best reading に対応する first-line shape は次の通りである。

```ts
type CombatDecision = {
  accepted: boolean
  branch: number
  branchVariant?: 0 | 1
}
```

ここで:

- `accepted` は accept/reject の first output
- `branch` は shared strict-fallback branch
- `branchVariant` は `PTR` false 側だけが持つ optional refinement

と読むのが safest である。

## 2. How PTR Maps Into This Shape

current best bias では `PTR` false 側は

- `candidateOffset`
- 2-way bucket
- direct mapping to `branchVariant 0/1`

という narrow path を持つ。

したがって code shape 上は、
`candidateOffset` を `combatDecision` の外へ出すより
`branchVariant`
へ要約して返すのが自然になる。

このとき `ATK` false 側は
`branchVariant` を持たない shared path として扱える。

## 3. Post-Branch Routing Current Skeleton

後段の routing も current best reading では

```ts
postBranchRoute = routeAfterDecision(branch, branchVariant?)
```

の shared-core skeleton で十分である。

これは:

- `ATK` = `routeAfterDecision(branch)`
- `PTR` = `routeAfterDecision(branch, branchVariant)`

の形を許しつつ、
shared core routing + PTR-only optional refinement
という解析側の current best reading と整合する。

## implication for step 6

この整理により、step 6 の current code frontier はかなり明確になった。

- unresolved material である `candidateOffset` は `combatDecision` 内へ閉じる
- `combatDecision` は `accepted/branch/branchVariant` を返す
- routing 側はそれを受けて `postBranchRoute` を作る

つまり first-line では
**decision layer** と **routing layer** が分離できている。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. battle-side evidence が `branch` / `branchVariant` / `postBranchRoute` の 3 層分離を支持するか
2. `PTR` false 側だけが `branchVariant` を必要とする current bias を維持できるか
3. `postBranchRoute` がさらに target routing / targetSource 整理へどうつながるか

ここが取れれば、current code shape は provisional から battle-side recovered semantics に一段押し上げやすくなる。
