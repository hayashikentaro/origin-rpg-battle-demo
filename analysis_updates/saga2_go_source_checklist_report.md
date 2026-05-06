# saga2 GO source checklist

## Summary

- current frontier では source 側の GO work はかなり明確で、もう broad exploration ではなく **contract-preserving maintenance and expansion** に集中できる
- deferred-binding policy を壊さない限り、次の checklist はそのまま進めてよい

## GO checklist

### 1. Keep the 5-layer field order stable

- `branch`
- `branchVariant`
- `postBranchRoute`
- `pointerFlavor`
- `target`

UI / trace / docs / selfcheck のどこでも、この順が崩れないようにする。

### 2. Keep deferred-binding wording explicit

- `branchVariantMeaning = candidate_family_lane_refinement_bit`
- `branchVariantBindingStatus = deferred_numeric_binding`
- `branchVariantCarryMeaning = same_side_pointer_correspondence`

raw `0|1` に exact side name を戻さない。

### 3. Prefer semantic fields over raw numeric fields

実装や確認では、可能な限り

- `branch`
- `pointerFlavor`
- `targetSource`

などの semantic field を使う。  
raw `branchVariant 0|1` を semantic branch key として直接使わない。

### 4. Expand coverage, not binding

preview matrix や selfcheck を増やすときは、

- command diversity
- target-mode diversity
- candidate/shared path diversity

を広げる。  
exact numeric binding を増やす方向へ進めない。

### 5. Keep selfcheck aligned with UI/debug growth

front 側に probe を足したら、

- trace ordering
- marker/pointer/target relation
- target-mode difference

も selfcheck に入れる。

### 6. Treat opcode/native naming as deferred

以下はまだ source に焼き込まない。

- `branchVariant 0/1` の exact side naming
- opcode/instruction-level exact anchoring
- raw `0|1` と `0E/0F` side の direct local glue

## NO-GO checklist

- `if branchVariant == 0 then shared-side`
- `if branchVariant == 1 then candidate-side`
- `pointerFlavor` を raw `branchVariant` から direct decode する
- UI/trace で `0 == shared` を匂わせる wording

## One-line reading

current safest source stance は、

**preserve shape, preserve ordering, preserve deferred binding, and only widen observable coverage.**

である。
