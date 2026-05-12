# Saga2 Post-Branch Routing Shared-Core Report

## 要点

- current best reading では、`ATK` と `PTR` の post-branch routing は **完全別系統** より、まず **shared core routing + PTR-only optional refinement** とみるのが最も自然である
- 理由は、ここまでの narrowing で両者の差分を `combatDecision` 側へかなり押し込めており、後段 routing まで別物にすると shared `branch` を保ってきた利点が薄くなるからである
- したがって current best bias は、post-branch routing は  
  - `branch` を共通入力とする shared core  
  - `PTR` のときだけ `branchVariant` を見る optional refinement  
 という 2 層で持つのが safest である

## 1. Why A Shared Core Fits Better Than Split Routing

既報では current provisional shape を

- `accepted`
- shared `branch`
- optional PTR-only `branchVariant`

へかなり寄せている。

この時点で後段 routing まで完全に分けると、
shared `branch`
を維持してきた意味がかなり弱くなる。

一方 shared core routing を置けば、

- `ATK` false 側は `branch` だけで進める
- `PTR` false 側は同じ `branch` に入りつつ `branchVariant` で refinement する

という構造が自然に作れる。

このため safest reading は、
post-branch routing 自体は first-line では
**共通骨格を持つ**
とみることである。

## 2. Why PTR Still Needs An Optional Refinement

shared core といっても、
`PTR` false 側の path-specific 差分が消えるわけではない。

既報では `PTR` だけが:

- `candidateOffset` を持ち
- その 2-way bucket が
- `branchVariant 0/1` に direct mapping される

という bias を置いている。

したがって post-branch routing の safest reading は

- core routing shape は shared
- PTR だけが `branchVariant` で local refinement

となる。

つまり差分は routing 層全体ではなく、
**shared routing の中の optional refinement**
として持つのがよい。

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

そして post-branch routing は current best bias では

```ts
routeAfterDecision(branch, branchVariant?)
```

の形で十分であり、

- `ATK`: `routeAfterDecision(branch)`
- `PTR`: `routeAfterDecision(branch, branchVariant)`

のように shared core を持つのが自然である。

## implication for step 6

この整理を採ると、step 6 の TypeScript 側では
`resolveCombatRngAfterLocalPath(...)`
の戻りをそのまま

- shared `branch`
- optional `branchVariant`

として返し、
後段の routing 側で
shared core を実装しつつ
PTR-only refinement を optional に見る設計がかなり自然になる。

これは current `resolveActorCommand(...)` skeleton ともよく噛み合う。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `ATK` false 側と `PTR` false 側が同じ post-branch routing core に入れるか
2. `PTR` だけがその core の中で `branchVariant` を追加参照するか
3. その core 以降で初めて target routing / targetSource 整理が走るか

ここが取れれば、`combatDecision` は
**accepted + shared branch + optional PTR-only branchVariant**
としてかなりそのまま実装へ落とせる。
