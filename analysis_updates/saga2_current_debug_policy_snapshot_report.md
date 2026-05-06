# SaGa2 Current Debug Policy Snapshot Report

## Goal

source 側で現在採用している debug / trace wording を、
current best reading と対応づけて 1 本にまとめる。

## Current field order

現時点の safest debug order は次のとおり。

1. `branch`
2. `branchVariant`
3. `postBranchRoute`
4. `pointerFlavor`
5. `target`

これは

- first-line lane pair
- PTR-only lane refinement
- lane-transfer core
- second-line provenance reopening
- downstream terminal result

という 5-layer flow をそのまま見せる順である。

## Current wording policy

### `branch`

- actor-local resolution lane pair

### `branchVariant`

- raw `0|1` は保持
- side semantics を併記
- same-side carry correspondence を別に示す

### `postBranchRoute`

- lane-transfer core
- debug 上は `branchVariant` の直後、`pointerFlavor` の直前に置く

### `postBranchTargetSource`

- weak/shared entry marker
- debug 上は主役にしない
- `source` ではなく `marker` / `m` として見せる

### `pointerFlavor`

- strongest second-line reopening core
- `"shared"` / `"candidate"` の provenance path meaning を併記

### `target`

- downstream terminal result
- debug 上は `target terminal` / `tgt` として最後に置く

## Trace policy

current safest trace wording は、

- first-line decision/refinement を先に出す
- second-line は `pointerFlavor` を主語にする
- `target` は terminal consequence として最後に出す

という方針である。

## Why this is safe

この policy だと、

- unresolved numeric binding を premature に固定しない
- first-line / second-line の carry が見えやすい
- `postBranchTargetSource` を過剰に強い field と見せない

という current best reading の主要要件を満たせる。

## Current safest summary

現時点の safest debug policy は、
**lane pair / refinement を先に、lane-transfer core を中段に、provenance reopening を後段に、terminal target を最後に見せる**
ことである。
