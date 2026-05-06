# saga2 deferred binding strategy shortform

## Short form

- keep raw `branchVariant?: 0 | 1`
- do not assign exact side names to `0/1`
- use `branchVariantMeaning = candidate_family_lane_refinement_bit`
- use `branchVariantBindingStatus = deferred_numeric_binding`
- use `branchVariantCarryMeaning = same_side_pointer_correspondence`
- prefer `branch`, `postBranchRoute`, `pointerFlavor`, `targetSource`, `target` for semantic reading
- widen coverage, not binding

## Safe reading

current safest implementation reading is:

**preserve the numeric field, preserve the semantic metadata, and defer exact numeric interpretation.**

## Explicit no-go

- `0 == shared/default-leaning`
- `1 == candidate-aware/strict-leaning`
- raw `branchVariant` as a semantic branch key
- pointer semantics derived directly from raw `0/1`
