# SaGa2 BranchVariant Pointer Correspondence Report

## Question

`branchVariant?: 0 | 1` の raw numeric value は、
second-line の

- `pointerFlavor="shared"`
- `pointerFlavor="candidate"`

と current frontier でどこまで stronger に対応づくと読めるか。

## Current best reading

現時点では、`branchVariant` raw value は
**`pointerFlavor` pair side と structurally strong に対応づく**
とみるのが safest である。

ただし、その correspondence は

- `0` = shared / `1` = candidate

のような numeric binding までを直接確定するものではなく、
**one side corresponds to `shared`, the other to `candidate`**
という side-level correspondence に留めるのが current best reading である。

## Why the correspondence is strong

既報の current best reading では、

- `branchVariant` = PTR-only candidate-family lane refinement bit
- `postBranchRoute` = lane-transfer core
- `pointerFlavor` = second-line reopening core

であり、`branchVariant` retained refinement の strongest landing point は
`pointerFlavor` にある。

そのため raw value 自体も、少なくとも
**どちらの provenance side を downstream で開くか**
にかなり直接近い compressed split とみるのが自然である。

## Why the numeric naming still waits

いっぽうで current evidence は、

- side A <-> one pointerFlavor side
- side B <-> the other pointerFlavor side

という correspondence をかなり強く示しているが、
**A = 0 or 1**
の binding を battle-side wording で直接保証するにはまだ弱い。

つまり current frontier では、

- semantic correspondence = strong
- numeric assignment = still provisional

という二段の stance が safest である。

## Safest wording

現時点の safest wording は次のとおり。

- `branchVariant` raw value carries a strong side-level correspondence to `pointerFlavor`
- one raw side corresponds to `"shared"`
- the other raw side corresponds to `"candidate"`
- exact `0/1` binding remains unresolved

## Implementation implication

この読みを implementation policy に戻すと、

- raw `0|1` は保持する
- docs/debug では side semantics を強く出す
- `pointerFlavor` との relation は “strong correspondence” として扱う
- `0 == shared` などの direct binding はまだ書かない

という stance が最も安全である。

## Next decisive frontier

次に本当に欲しいのは、
`branchVariant` raw value が current debug trace か battle-side wording のどちらかで
**片方向に近い numeric anchoring**
を得ることである。

それが取れれば、初めて `0/1` の exact naming を lock できる。
