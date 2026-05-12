# saga2 branchVariant deferred binding contract

## Summary

- current frontier では `branchVariant 0/1` の exact numeric binding は still unconfirmed
- source 側もこの状態に合わせて、**raw numeric transport は保持しつつ semantic naming を deferred-binding contract に寄せた**
- したがって current source contract は、raw `0|1` を side name に焼き込まないまま shape と relation を強く保持する形になっている

## Current source-side contract

### Preserved as-is

- `branchVariant?: 0 | 1`
- `branchVariantCarryMeaning = "same_side_pointer_correspondence"`

つまり raw numeric field と side-level correspondence field はそのまま維持されている。

### Renamed / stabilized

- `branchVariantMeaning = "candidate_family_lane_refinement_bit"`
- `branchVariantBindingStatus = "deferred_numeric_binding"`

つまり source はもはや

- `0 = shared/default-leaning`
- `1 = candidate-aware/strict-leaning`

のような exact side binding を返さず、**field-level meaning** と **binding deferred status** を返す。

## Why this is the safest current contract

current frontier で既に強いのは

- field shape
- same-side correspondence
- code-family split carry
- side semantics

である。

いっぽう未確定なのは

- raw `0/1` と named side の one-step local glue

だけである。

したがって source contract も、

- raw value は transport field として保持
- same-side relation は明示
- exact binding は deferred

とするのが current best reading に最も合う。

## Practical consequence

この contract により、実装側は

- shape-oriented logic
- ordering / trace policy
- pointerFlavor side semantics
- same-side carry semantics

をそのまま進められる。

いっぽうで raw `0|1` を直接 semantic branch key にする実装だけは、引き続き stop line にできる。

## Current safest wording

したがって current source contract を 1 行で書くなら、

**`branchVariant` is a PTR-only candidate-family lane refinement bit with deferred numeric binding and explicit same-side carry semantics.**

である。
