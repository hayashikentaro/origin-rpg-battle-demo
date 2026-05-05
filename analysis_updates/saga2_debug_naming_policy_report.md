# SaGa2 Debug Naming Policy Report

## Goal

`branchVariant` の numeric `0/1` を premature に固定せず、
docs / debug / implementation で同じ semantic wording を共有する方針を明文化する。

## Current safest policy

現時点の safest policy は次のとおり。

- field shape はそのまま保持する
- numeric value は raw のまま保持する
- debug / docs では side semantics を併記する

つまり `branchVariant` は

- storage / API shape = `0 | 1`
- semantic wording = shared/default-leaning side vs candidate-aware/strict-leaning side

という二段で持つのが safest である。

## Why this policy works

この policy だと、

- code shape を premature に固定しすぎない
- docs 側の recovered semantics を先に強められる
- debug UI で user-facing wording を安定させられる

という 3 つの利点がある。

## Recommended debug wording

- `branch` = local-resolution mode pair
- `branchVariant` = PTR-only candidate-family refinement bit
- `pointerFlavor` = target-provenance path pair

数値そのものは表示してよいが、
それに加えて side semantics を表示するのが safest である。
