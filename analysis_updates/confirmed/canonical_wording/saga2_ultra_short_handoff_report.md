# saga2 ultra short handoff

## Do

- keep the 5-layer contract
- keep deferred numeric binding
- grow preview coverage through stable labels
- keep selfcheck aligned with preview/debug changes

## Do not

- do not bind `branchVariant 0|1` to exact side names
- do not branch semantically on raw numeric values
- do not bake opcode-native semantics into source logic

## Core reading

- `branch` = resolution lane pair
- `branchVariant` = candidate-family lane refinement bit
- `postBranchRoute` = lane-transfer core
- `pointerFlavor` = target-provenance path pair
- `target` = downstream terminal result

## Analysis frontier

- `41E3-41E5`
- `41E3-41E9`
- `41E7-41E9`

## One line

**the contract is ready; only the numeric glue is deferred.**
