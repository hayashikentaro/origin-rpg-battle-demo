# saga2 next actions shortlist

## If continuing implementation

- preserve the 5-layer order:
  - `branch -> branchVariant -> postBranchRoute -> pointerFlavor -> target`
- preserve deferred-binding wording:
  - raw `branchVariant?: 0 | 1`
  - `candidate_family_lane_refinement_bit`
  - `deferred_numeric_binding`
  - `same_side_pointer_correspondence`
- expand preview coverage only through stable labels and family-aware readability
- extend selfcheck whenever preview, debug, or wording changes

## If continuing analysis

- inspect `41E3-41E5` as the strongest binding-candidate band
- inspect `41E3-41E9` as the smallest carry candidate cluster
- inspect `41E7-41E9` as the first effective same-side visibility slot

## Do not do yet

- do not bind raw `0` or `1` to an exact side name
- do not use raw numeric as a semantic branch key
- do not bake opcode-native semantics into source logic

## One-line rule

**grow contract coverage, not numeric certainty.**
