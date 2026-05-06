# saga2 implementation-ready snapshot

## Summary

- current frontier では、battle/RNG bridge の **semantic core contract** だけでなく、frontend / debug / selfcheck まで含めた **implementation-ready snapshot** をかなり明確に切れる
- つまり今は interface discovery の段階ではなく、**shape-preserving implementation and contract hardening** の段階に入っている
- remaining uncertainty は raw numeric binding や instruction-level anchoring に限られ、運用面の contract はかなり安定している

## 1. Core semantic contract

current code-ready semantic core は次の通りである。

- `branch` = actor-local resolution lane pair
- `branchVariant` = PTR-only candidate-family lane refinement bit
- `postBranchRoute` = lane-transfer core
- `pointerFlavor` = target-provenance path pair
- `target` = downstream terminal result

つまり actor-local bridge は **lane -> transfer -> provenance -> terminal** の flow としてそのまま使える。

## 2. Frontend bridge contract

Godot / frontend 側では current frontier で、

- actor-local preview
- command matrix preview
- `ATK / DEF / PTR / ABL...` の差分観測

がすでに可能である。

この観測は current best reading に沿って

- `branch`
- `branchVariant`
- `postBranchRoute`
- `pointerFlavor`
- `target`

を UI 上で追えるようになっているため、semantic core の実装検証に十分使える。

## 3. Debug contract

current safest debug order は固定されている。

**`branch -> branchVariant -> postBranchRoute -> pointerFlavor -> target`**

また trace contract もかなり安定していて、

- `combat hook`
- `post-branch marker + pointer`
- `target terminal`

の順が code-ready な debug policy として扱える。

追加で、

- `branchVariantCarryMeaning = same_side_pointer_correspondence`
- `branchVariantBindingStatus = deferred_numeric_binding`
- `pointerFlavorMeaning`

が visible なので、exact numeric binding を lock しなくても semantic relation を十分観測できる。

## 4. Selfcheck contract

current selfcheck では、少なくとも次が固定されている。

- attack / pointerProbe / matrix の shape
- debugTrace ordering
- pointerFlavor wording
- branchVariant wording
- deferred-binding wording

つまり selfcheck は単なる type check ではなく、**current semantic debug policy の contract test** として機能している。

## 5. Safe implementation scope

current snapshot で safe に進めてよいのは次である。

- core contract stabilization
- debug wording / ordering maintenance
- frontend bridge usage
- shape-oriented selfcheck reinforcement

逆に stop line はかなり狭く、

- raw `branchVariant 0|1` の exact semantic naming
- raw numeric を semantic branch key として直接使うこと
- instruction-level exact anchoring を前提にした実装

だけである。

## Practical reading

したがって current implementation-ready snapshot を一文で書くなら、

**the semantic core, frontend preview surface, debug ordering, and selfcheck policy are all stable enough to implement against, while raw numeric binding and opcode-level anchoring remain explicitly deferred.**

である。
