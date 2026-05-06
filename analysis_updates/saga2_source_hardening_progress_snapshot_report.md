# saga2 source hardening progress snapshot

## Summary

- current frontier では source-side hardening がかなり進んでおり、semantic discovery より **contract-consistency maintenance** が主戦場になっている
- 特に
  - deferred-binding policy
  - semantic debug ordering
  - selfcheck contract
  - preview matrix coverage
  
  の 4 本は、かなり強い operational contract として扱える
- remaining uncertainty は source contract の外側、つまり **raw numeric binding** と **opcode-level anchoring** にほぼ押し出されている

## 1. Deferred-binding policy is now source-stable

current source contract では `branchVariant` について、

- `branchVariant?: 0 | 1`
- `branchVariantMeaning = candidate_family_lane_refinement_bit`
- `branchVariantBindingStatus = deferred_numeric_binding`
- `branchVariantCarryMeaning = same_side_pointer_correspondence`

が揃っている。

これにより source は

- raw transport field
- field-level semantic role
- binding deferred state
- carry relation

を同時に表せるようになり、premature numeric naming を避けながら contract を強く維持できている。

## 2. Semantic debug ordering is now source-stable

current safest ordering は source 側でもかなり固定されている。

- field order: `branch -> branchVariant -> postBranchRoute -> pointerFlavor -> target`
- trace order: `combat hook -> post-branch marker + pointer -> target terminal`

これにより first-line lane/refinement から second-line provenance/terminal へ流れる carry/result 関係が、UI と trace の両方で一貫して読める。

## 3. Selfcheck has moved from shape-check to contract-check

current selfcheck は単なる type/shape 検証ではなく、

- wording
- ordering
- deferred-binding semantics
- route / marker / pointer / target correspondence
- target-mode diversity

まで固定する semantic regression guard として機能している。

特に

- `ATK`
- `ATKX`
- `ATKS`
- `PTR`

の差分が selfcheck に入ったことで、matrix expansion も source-side contract の一部として扱えるようになっている。

## 4. Preview matrix coverage is now operationally useful

current preview matrix の最小有効セットは

**`ATK / ATKX / ATKS / DEF / PTR / ABL...`**

である。

これにより、

- shared/default lane
- candidate path
- explicit target
- slot fallback
- ability path

を same 5-layer contract のもとで front/selfcheck の両方から観測できる。

つまり matrix は現在、semantic widening のためというより **coverage widening under deferred-binding policy** のための運用面 asset になっている。

## 5. Remaining source hardening work

current snapshot でなお価値が高い hardening は次である。

- semantic debug wording の小さなズレを防ぐ
- selfcheck を contract-first で増やす
- preview matrix coverage を壊さずに広げる

逆に current snapshot でまだ source に入れないほうがよいのは次である。

- raw `branchVariant 0|1` の exact side naming
- raw numeric を semantic branch key として使うこと
- `41E3-41E5` などの instruction-level semantics の焼き込み

## Practical reading

したがって current source hardening progress を一文で言うなら、

**the source is now strong at preserving the deferred-binding contract and semantic flow, and weak only where exact binding or opcode-native semantics would need to be forced too early.**

である。
