# SaGa2 Layer Naming Symmetry Report

## Goal

5-layer provisional API の first-line / second-line naming を同じ粒度へ揃える。

## Current best symmetry

現時点の safest naming symmetry は次のとおり。

### Decision layer

- `accepted` = local consume-path admission bit
- `branch` = local-resolution mode pair
  - shared/default local-resolution mode
  - candidate-aware local-resolution mode
- `branchVariant` = PTR-only candidate-family refinement bit

### Transfer layer

- `postBranchRoute` = alignment-transfer core from local-resolution mode to target-provenance reopening

### Reopening layer

- `postBranchTargetSource` = weak/shared reopening entry marker
- `pointerFlavor` = target-provenance path pair
  - `"shared"` = shared/default target-provenance path
  - `"candidate"` = candidate-entry target-provenance path
- `target` = downstream terminal result

## Why this is useful

この naming だと、

- first-line = mode/refinement
- second-line = provenance/path/result

という role split がかなり明確になる。

また PTR-specific 差分も

- first-line では `branchVariant`
- second-line では `pointerFlavor="candidate"`

として対称に置ける。
