# saga2 restart playbook

## Current stable surface

- semantic core:
  - `branch`
  - `branchVariant`
  - `postBranchRoute`
  - `pointerFlavor`
  - `target`
- semantic flow:
  - lane -> transfer -> provenance -> terminal
- debug order:
  - `branch -> branchVariant -> postBranchRoute -> pointerFlavor -> target`
- trace order:
  - `combat hook -> post-branch marker + pointer -> target terminal`
- preview matrix:
  - `ATK / ATKX / ATKS / DEF / PTR / ABLX0 / ABLS0 / ABL...`
- operational guard:
  - frontend preview
  - growth-safe label lookup
  - family-prefixed readability
  - selfcheck regression coverage

## Deferred line

- keep raw `branchVariant?: 0 | 1`
- keep `candidate_family_lane_refinement_bit`
- keep `deferred_numeric_binding`
- keep `same_side_pointer_correspondence`
- do not bind `0` or `1` to an exact side name
- do not use raw numeric as semantic branch key
- do not bake opcode-native semantics into source logic

## Best re-entry points

- implementation:
  - expand preview coverage without breaking label-based canonical probes
  - preserve 5-layer field order
  - preserve deferred-binding wording
  - extend selfcheck whenever preview/debug surface grows
- analysis:
  - `41E3-41E5` strongest binding-candidate band
  - `41E3-41E9` single-side carry candidate cluster
  - `41E7-41E9` first effective same-side visibility slot

## Practical rule

current safest restart rule is:

**keep growing shape, ordering, coverage, and readability; keep exact numeric binding and opcode-level anchoring deferred.**
