# saga2 finish handoff snapshot

## Current stable surface

- semantic core is stable:
  - `branch`
  - `branchVariant`
  - `postBranchRoute`
  - `pointerFlavor`
  - `target`
- semantic flow is stable:
  - lane -> transfer -> provenance -> terminal
- deferred-binding policy is stable:
  - keep raw `branchVariant?: 0 | 1`
  - keep semantic metadata explicit
  - defer exact numeric interpretation

## Current operational surface

- preview matrix is now a **cross-family coverage surface**
- minimum effective set:
  - `ATK / ATKX / ATKS / DEF / PTR / ABLX0 / ABLS0 / ABL...`
- debug order is stable:
  - `branch -> branchVariant -> postBranchRoute -> pointerFlavor -> target`
- trace order is stable:
  - `combat hook -> post-branch marker + pointer -> target terminal`
- readability policy is stable:
  - stable label lookup
  - family prefixes
  - fixed semantic field order
- selfcheck is now a semantic regression guard, not just a shape check

## Current deferred items

- raw `branchVariant 0|1` exact side naming
- raw `0/1` to `0E/0F` one-step local glue
- opcode / instruction-level exact anchoring

## Safe implementation stance

Continue:

- shape-preserving implementation
- coverage widening
- debug readability maintenance
- selfcheck expansion

Avoid:

- exact side naming for raw `0|1`
- raw numeric as semantic branch key
- opcode-native semantics in source logic

## Best re-entry points

If resuming from analysis:
- `41E3-41E5` as strongest binding-candidate band
- `41E3-41E9` as minimal binding candidate cluster
- `41E7-41E9` as same-side visibility slot

If resuming from implementation:
- expand preview matrix coverage
- keep label-based canonical probes
- strengthen selfcheck around new probes

## One-line handoff

**The project is ready for shape-preserving implementation and coverage growth, while exact branchVariant binding and opcode-native semantics remain intentionally deferred.**
