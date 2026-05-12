# SaGa2 Debug Contract Report

## Goal

current source 側で selfcheck まで通して固定している debug / trace policy を、
code-ready contract として 1 本にまとめる。

## Current contract

現時点の debug contract は、少なくとも次を保証する shape と wording である。

### 1. Trace stage order

`debugTrace` の後半 3 行は次の順で固定されている。

1. `combat hook ...`
2. `post-branch marker=... pointer=...`
3. `target terminal source=...`

つまり

- first-line decision/refinement
- weak/shared second-line entry marker + reopening core
- downstream terminal result

の順序が contract になっている。

### 2. Pointer wording

`post-branch marker` 行では、

- `pointer=shared/shared_default_target_provenance_path`
- `pointer=candidate/candidate_entry_target_provenance_path`

のように、
second-line core field とその meaning が一緒に出る。

### 3. BranchVariant wording

`combat hook` 行では、

- no-variant path では `variant=--/--`
- PTR refinement path では `variant=<raw>/<meaning>`

が保証される。

ここで `<meaning>` は

- `shared_default_leaning`
- `candidate_aware_strict_leaning`

の side semantics である。

### 4. Marker wording

`postBranchTargetSource` は debug contract 上、
`source` ではなく **`marker`** として扱う。

これは current best reading どおり、
この field が weak/shared entry marker であることを反映している。

### 5. Terminal wording

`target` は debug contract 上、
**`target terminal`** として扱う。

これは current best reading どおり、
`target` が `pointerFlavor` pair の downstream terminal result であることを反映している。

## Why this is code-ready

この contract は

- raw numeric binding を固定しない
- side semantics は見せる
- layer order を崩さない
- `marker -> pointer -> target terminal` の主従を保つ

という current safest policy と完全に整合する。

そのため future evidence が増えても、
この contract を壊さずに semantics を sharpen しやすい。

## Current safest summary

現時点の debug contract は、
**first-line decision/refinement -> weak marker + second-line reopening core -> downstream terminal**
の順で trace を見せる code-ready contract である。
