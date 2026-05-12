# SaGa2 Debug Route Insertion Policy Report

## Goal

current safest debug order

- `branch`
- `branchVariant`
- `pointerFlavor`

の中で、`postBranchRoute` をどこに挿すと
carry / transfer の意味が最も見やすいかを整理する。

## Current safest insertion point

現時点の safest insertion point は、

**`branch -> branchVariant -> postBranchRoute -> pointerFlavor`**

である。

つまり `postBranchRoute` は

- first-line pair / refinement
と
- second-line provenance reopening

の **間** に置くのが最も自然である。

## Why this position works

current best reading では、

- `branch` = actor-local resolution lane pair
- `branchVariant` = PTR-only candidate-family lane refinement bit
- `postBranchRoute` = lane-transfer core
- `pointerFlavor` = target-provenance path pair

となっている。

この 4 つを debug で並べるなら、
`postBranchRoute` は source-side fields のあと、landing-point field の前に置くことで、
**what is being carried** と **where it lands** の境界が最も見えやすい。

## Why not place route before `branchVariant`

`postBranchRoute` を `branchVariant` より前に置くと、
retained refinement が route core に入って carry される構図が崩れやすい。

current best reading では `branchVariant` は
`postBranchRoute` に retained されたまま second-line reopening へ渡るので、
route core は refinement の **後** に見せるのが safest である。

## Why not place route after `pointerFlavor`

逆に `pointerFlavor` の後へ置くと、
route core が second-line reopening の downstream result のように見えやすい。

しかし current best reading では `postBranchRoute` は
**second-line reopening の前にある transfer core**
なので、`pointerFlavor` より前に置く必要がある。

## Recommended debug order

current safest debug order は次のとおり。

1. `branch`
2. `branchVariant`
3. `postBranchRoute`
4. `pointerFlavor`
5. `target`

この順なら、

- first-line lane pair
- PTR-only refinement
- transfer core
- provenance reopening
- downstream terminal

という 5-layer flow がほぼそのまま見える。

## Current safest summary

現時点の safest display policy は、
**`postBranchRoute` を `branchVariant` の直後、`pointerFlavor` の直前に置く**
ことである。
