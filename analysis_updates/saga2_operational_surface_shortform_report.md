# saga2 operational surface shortform

## Short form

- semantic core:
  - `branch`
  - `branchVariant`
  - `postBranchRoute`
  - `pointerFlavor`
  - `target`
- semantic flow:
  - lane -> transfer -> provenance -> terminal
- deferred binding:
  - keep raw `branchVariant?: 0 | 1`
  - do not assign exact side names to `0/1`
  - keep semantic metadata explicit
- preview surface:
  - `ATK / ATKX / ATKS / DEF / PTR / ABLX0 / ABLS0 / ABL...`
- debug order:
  - `branch -> branchVariant -> postBranchRoute -> pointerFlavor -> target`
- trace order:
  - `combat hook -> post-branch marker + pointer -> target terminal`
- readability policy:
  - canonical probes by stable label
  - family prefixes for expanded matrix
- selfcheck role:
  - regression guard for shape, wording, ordering, and target-mode diversity

## Safe reading

current safest operational reading is:

**the bridge is ready to implement and expand at the shape/ordering/coverage level, while exact numeric binding and opcode-level anchoring remain deferred.**

## No-go

- exact side naming for raw `branchVariant 0|1`
- raw numeric as semantic branch key
- opcode-native semantics baked into source logic
