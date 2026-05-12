# Saga2 Post-Branch Route Alignment Transfer Report

## 要点

- current best reading では、`postBranchRoute` は単なる numeric continuation より、**first-line の branch pair alignment を second-line の pointer pair alignment へ受け渡す shared route core** とみるのが最も自然である
- したがって `routeAfterDecision(branch, branchVariant?)` は current frontier では、  
  - `branch` の fast/default side と strict side  
  - optional `branchVariant` refinement  
  をまとめて **second-line reopening shape へ写す transfer layer** として持つのが safest である
- この整理を採ると、5-layer flow は  
  `combatDecision -> postBranchRoute -> pointerFlavor pair -> target`
  という alignment-preserving chain としてかなりきれいに読める

## 1. Why `postBranchRoute` Should Be Read As A Transfer Layer

既報では:

- first-line `branch`
  = fast/default side と strict sideを持つ shared pair
- `branchVariant`
  = PTR-only refinement
- second-line `pointerFlavor`
  = same pair alignment を provenance reopening として見せる

まで整理している。

この前提を採ると、
`postBranchRoute`
の最も軽い役割は、
first-line の pair/refinement を second-line reopening へ
**そのまま運ぶ shared route core**
である。

つまり `postBranchRoute`
は target を直接決める layer というより、
alignment を second-line 側へ移す
transfer layer
として読むのが safest になる。

## 2. Why This Fits Better Than A Generic Opaque Route Id

もし `postBranchRoute`
を opaque number とみなすだけなら、

- first-line pair alignment
- second-line pair alignment

のつながりが文書上もコード上も一度切れてしまう。

しかし既報では
`branch`
と
`pointerFlavor`
の両方に pair semantics がかなり強く乗っているため、
その中間にある `postBranchRoute`
も
**alignment-preserving route core**
とみるほうが整合する。

この読みなら
`routeAfterDecision(...)`
は

- branch pair
- optional branchVariant

を受けて、
それを second-line reopening order へ写すだけでよい。

## 3. Relation To `accepted`

既報では `accepted`
は first-line / second-line の pair alignment の向きを変えるのではなく、
reader-side role を

- fallback
- admitted-path activation

に切り替える field
と整理している。

この前提を採ると、
`postBranchRoute`
自体も true/false で別 route class に分裂するより、
**same alignment transfer, different control-flow role**
として持つのが自然である。

つまり:

- false 側では fallback-side transfer
- true 側では admitted-path transfer

だが、
route core が運ぶ alignment 自体は shared とみるのが safest になる。

## 4. Relation To `pointerFlavor`

second-line では `pointerFlavor`
が

- `"shared"` = fast/default aligned provenance reopening
- `"candidate"` = strict-side aligned provenance reopening

の pair を current best reading で持っている。

このため `postBranchRoute`
の最も自然な output interpretation は、
最終 target より先に
**which pointer-side alignment should reopen**
を決めることである。

つまり:

- first-line branch pair
  -> `postBranchRoute`
  -> second-line pointer pair

という transfer chain が current best reading の中心になる。

## 5. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
postBranchRoute = routeAfterDecision(branch, branchVariant?)
```

の exact-bias は:

```ts
alignment-preserving shared route core
```

にかなり近い。

つまり `postBranchRoute`
は opaque continuation id というより、
**first-line branch pair/refinement を second-line reopening pair へ写す transfer result**
として持つのが current best である。

## implication for step 6

この整理を採ると、
step 6 の provisional code で
`postBranchRoute`
を持っている意味もかなり明確になる。

- `combatDecision`
  = decision layer
- `postBranchRoute`
  = alignment transfer layer
- `pointerFlavor`
  = reopened second-line class
- `target`
  = downstream terminal

という 4 段の流れとして見られるからである。

つまり next analysis / next implementation では、
`postBranchRoute`
を opaque number として扱うより、
**alignment transfer result**
として debug / docs を強めるほうが安全である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `postBranchRoute` が `pointerFlavor` pair のどちらを reopen するかをどこまで直接に決めるか
2. `branchVariant` refinement が route core の中でどこまで保持されるか
3. final `target` 差分がこの transfer chain の terminal consequence としてどこまで説明できるか

ここが取れれば、5-layer flow の exact semantics はかなり recovered decomposition に近づく。
