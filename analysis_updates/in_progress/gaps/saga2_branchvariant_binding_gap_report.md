# SaGa2 BranchVariant Binding Gap Report

## Question

`branchVariant?: 0 | 1` について、

- field role はかなり安定している
- side semantics もかなり見えている

一方で、なぜ `0` と `1` の exact binding だけをまだ固定しないのが safest か。

## Current best reading

現時点では、`branchVariant` の current safest stance は

- shape = `0 | 1`
- role = PTR-only candidate-family lane refinement bit
- side semantics =
  - shared/default-leaning lane refinement
  - candidate-aware/strict-leaning lane refinement
- numeric binding = still provisional

である。

つまり **semantic polarity は回収できているが、numeric polarity はまだ回収し切っていない**
というのが current frontier の実態である。

## Why the gap remains

現在ある evidence は主に、

- `0E/0F` family difference が primary axis
- blocked-ordinal shadow は strict side へ寄る
- `pointerFlavor="shared"/"candidate"` と pair alignment を持つ
- `postBranchRoute` を経て second-line reopening へ carry される

という **構造的 / relational evidence** である。

これらは

- どちらの side が fast/default 側か
- どちらの side が strict/candidate-aware 側か

をかなり自然に示しているが、
**その side が `0` か `1` かを直接ラベルづけする evidence** はまだ弱い。

## What kind of evidence would decide the binding

binding を強く固定するには、少なくとも次のどちらかが欲しい。

1. `branchVariant` の raw numeric valueが、
   second-line の `"shared"` / `"candidate"` reopening と
   **一方向に対応づく stronger trace**

2. battle-side で
   `0E/0F` family difference と
   raw `0/1` が
   **direct に近い形で結びつく additional local evidence**

つまり今足りないのは shape ではなく、
**numeric polarity を side semantics に焼き付ける directness**
である。

## Why waiting is still the safer implementation choice

ここで premature に

- `0 = shared/default`
- `1 = candidate-aware/strict`

のように固定してしまうと、

- docs wording
- debug wording
- later recovered semantics

の 3 つを同時に lock してしまう。

しかし current code shape では、
数値を raw のまま保持しつつ semantic labels を併記できるので、
binding を保留しても実装上の不利益は小さい。

したがって現時点の safest policy は、
**numeric binding を未固定のまま、side semantics だけを強く使う**
ことである。

## Current safest wording

現時点の safest wording は次のとおり。

- `branchVariant` = PTR-only candidate-family lane refinement bit
- side semantics:
  - shared/default-leaning side
  - candidate-aware/strict-leaning side
- unresolved:
  - which side is `0`
  - which side is `1`

## Next decisive frontier

次に一番効くのは、
`branchVariant` raw value が second-line の

- `pointerFlavor="shared"`
- `pointerFlavor="candidate"`

のどちらと stronger に対応するかを、
current trace / battle-side wording の両方からさらに詰めることである。
