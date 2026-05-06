# saga2 branchVariant code-ready contract

## Summary

- current frontier で `branchVariant` は **shape / transport / same-side relation / deferred-binding policy** まで十分 code-ready である
- 未回収なのは exact numeric binding だけであり、これは **field contract** ではなく **future semantic sharpening item** として扱えばよい
- したがって current implementation は、`branchVariant` を **semantic transport field with deferred binding** として進めるのが safest である

## Code-ready pieces

### 1. Field shape

- `branchVariant?: 0 | 1`

この shape 自体は stable である。optional であることも含め、current frontier で十分 code-ready である。

### 2. Field-level meaning

- `branchVariantMeaning = "candidate_family_lane_refinement_bit"`

これは raw `0/1` の side binding を言わずに、field が何を運ぶかだけを明示する wording として current best である。

### 3. Binding status

- `branchVariantBindingStatus = "deferred_numeric_binding"`

これは exact numeric semantics をまだ lock していないことを source contract 上で明確化する field であり、implementation safety をかなり高める。

### 4. Carry relation

- `branchVariantCarryMeaning = "same_side_pointer_correspondence"`

これは first-line refinement と second-line provenance reopening の relation を表す current best wording であり、numeric binding 非依存である。

## Safe implementation rule

current safest implementation rule は単純である。

- raw `branchVariant` は transport field として保持する
- semantic debug / docs / UI は `Meaning` / `BindingStatus` / `CarryMeaning` を見る
- exact side dispatch が必要なら raw `0|1` ではなく `pointerFlavor` など downstream semantic field を使う

つまり **raw numeric を semantic branch key にせず、metadata-carrying transport field として扱う** のが current best policy である。

## What remains deferred

以下は引き続き deferred である。

- `0 == shared/default-leaning` かどうか
- `1 == candidate-aware/strict-leaning` かどうか
- raw `0/1` と `0E/0F` side の exact local glue

ただしこれらは current code-ready contract の成立を妨げない。

## One-line contract

current branchVariant contract を最短で書くなら、

**raw `0|1` is preserved as transport, semantic role is explicit, numeric binding is deferred, and same-side carry is guaranteed at the contract level.**

である。
