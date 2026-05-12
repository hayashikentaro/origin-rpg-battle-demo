# SaGa2 BranchVariant Exact Naming Report

## Question

`branchVariant?: 0 | 1` を offset bucket のような弱い説明ではなく、
current best reading に沿って exact naming へ寄せるなら、どう呼ぶのが safest か。

## Current best reading

現時点では、`branchVariant` は
**candidate-family refinement bit**
と読むのが safest である。

つまりこれは

- `D?12..` candidate-entry family
- `0E/0F` family difference
- blocked-ordinal shadow

を first-line に圧縮して運ぶ PTR-only optional refinement である。

## Why not “offset bucket” anymore

`candidateOffset` はこの field の source material ではあるが、
current best reading では `branchVariant` 自体は
**candidate-entry family difference の compressed split**
として battle-side semantics に anchored している。

したがって code-ready wording では、
raw offset bucket より
**candidate-family refinement bit**
と呼ぶほうが自然である。

## Why keep it as a bit

数値 `0/1` の exact polarity naming はまだ保留すべきだが、
cardinality は first-line でかなり安定して 2-way split に見える。

そのため safest wording は、

- field shape は `0 | 1`
- semantics は `candidate-family refinement bit`

という二段の持ち方である。

## Current safest wording

- `branchVariant` = PTR-only candidate-family refinement bit

## Remaining uncertainty

未確定なのは `0` と `1` の numeric polarity naming だけであり、
field role 自体はかなり安定している。
