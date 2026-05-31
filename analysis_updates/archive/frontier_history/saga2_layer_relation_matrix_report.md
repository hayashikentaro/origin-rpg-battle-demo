# SaGa2 Layer Relation Matrix Report

## Current best relation matrix

### First-line

- `accepted`
  - local consume-path admission bit
- `branch`
  - shared/default local-resolution mode
  - candidate-aware local-resolution mode
- `branchVariant`
  - PTR-only candidate-family refinement bit
  - side semantics:
    - shared/default-leaning
    - candidate-aware/strict-leaning

### Transfer

- `postBranchRoute`
  - alignment-transfer core
  - carries `branch`
  - retains `branchVariant` until second-line reopening

### Second-line

- `postBranchTargetSource`
  - weak/shared reopening entry marker
- `pointerFlavor`
  - shared/default target-provenance path
  - candidate-entry target-provenance path
- `target`
  - downstream terminal result

## Carry relation

- `branch` -> route pair side
- `branchVariant` -> PTR-only carried refinement
- `pointerFlavor` -> strongest second-line landing point for carried refinement
- `target` -> downstream consequence of `pointerFlavor`
