# saga2 operational contract snapshot

## Summary

- current frontier では、battle/RNG bridge の実運用に必要な contract はかなり揃っている
- semantic core / frontend preview / debug ordering / selfcheck / deferred-binding policy は、**shape-preserving implementation** を進めるには十分 stable である
- 残る未確定は `branchVariant 0/1` の exact numeric binding と opcode-level anchoring にかなり集中している

## Core contract

current code-ready semantic core は次の通りである。

- `branch` = actor-local resolution lane pair
- `branchVariant` = PTR-only candidate-family lane refinement bit
- `postBranchRoute` = lane-transfer core
- `pointerFlavor` = target-provenance path pair
- `target` = downstream terminal result

これは **lane -> transfer -> provenance -> terminal** の flow として implementation に使ってよい。

## Deferred-binding contract

`branchVariant` について current source/docs/debug contract は次で揃っている。

- `branchVariant?: 0 | 1`
- `branchVariantMeaning = "candidate_family_lane_refinement_bit"`
- `branchVariantBindingStatus = "deferred_numeric_binding"`
- `branchVariantCarryMeaning = "same_side_pointer_correspondence"`

つまり raw numeric field は transport として保持しつつ、exact side naming は明示的に deferred にしている。

## Frontend preview contract

Godot / frontend 側では、current frontier で

- actor-local preview
- command matrix preview
- `ATK / DEF / PTR / ABL...`

の差分観測ができる。

また current safest UI flow は、

**`branch -> branchVariant -> postBranchRoute -> pointerFlavor -> target`**

を front 側でも追いやすい形に揃っている。

## Debug / trace contract

current safest debug contract は次である。

- `combat hook`
- `post-branch marker + pointer`
- `target terminal`

また表示順は

**`branch -> branchVariant -> postBranchRoute -> pointerFlavor -> target`**

で固定してよい。

この contract により、semantic core の carry/result 関係を raw binding なしで観測できる。

## Selfcheck contract

current selfcheck はすでに

- shape
- ordering
- pointer wording
- branchVariant wording
- deferred-binding wording
- route / marker / pointer / target terminal correspondence

まで確認している。

つまり selfcheck は type check ではなく、**current semantic contract の regression guard** として機能している。

## Safe implementation scope

いま safe に進めてよいのは次である。

- semantic core contract stabilization
- frontend preview maintenance
- debug wording / ordering maintenance
- selfcheck contract expansion

いっぽう stop line は次である。

- raw `branchVariant 0|1` への exact side naming
- raw numeric を semantic branch key として直接使うこと
- opcode/instruction-level exact anchoringの焼き込み

## One-line operational reading

current operational contract を一文で書くなら、

**the bridge is implementation-ready at the shape, ordering, preview, debug, and selfcheck levels, while exact numeric binding and opcode-level anchoring remain explicitly deferred.**

である。
