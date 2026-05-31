# SaGa2 Route Core Implementation Note Report

## Implementation note

`postBranchRoute` は current best reading では、
**route id** より
**alignment-transfer core from local-resolution mode to target-provenance reopening**
として扱うのが safest である。

## Practical consequence

実装側では、

- branch family を second-line reopening に橋渡しする
- PTR path では branchVariant refinement を保持する
- strongest downstream landing point は pointerFlavor

という役割を前提に置くのが自然である。

## What not to do yet

- `postBranchRoute` を exact ROM address semantics に固定しすぎない
- route number 自体へ過度な meaning を載せない

いまは transfer-role を先に固定するのが safest である。
