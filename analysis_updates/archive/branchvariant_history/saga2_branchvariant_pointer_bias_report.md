# Saga2 BranchVariant Pointer-Bias Report

## 要点

- current best reading では、`branchVariant` が second-line reopening に与える影響は **`postBranchTargetSource` より `pointerFlavor` に強く出る** とみるのが最も自然である
- 理由は、`PTR` の path-specific 差分が current best reading では target label より **candidate-like pointer provenance** に強く寄っており、`branchVariant` もその provenance を second-line へ運ぶ refinement とみるほうが flow に合うからである
- したがって current best bias は、`branchVariant` は  
  - `postBranchTargetSource` を弱く条件づけ  
  - `pointerFlavor` を強く条件づけ  
  - final `target` にはその downstream effect として効く  
 という順に作用すると置くのが safest である

## 1. Why Pointer Is The Stronger Carrier Of PTR Specificity

既報では `PTR` の candidate 由来差分は

- `candidateOffset`
- `branchVariant`
- candidate-flavored second-line reopening

へ段階的に要約されると整理している。

このとき second-line の中で
最も PTR らしい差分が強く残る場所は、
単なる source label より
**pointer/materialization の provenance**
とみるほうが自然である。

つまり `postBranchTargetSource="candidate"` は
second-line reopening の入口 marker としては有効だが、
`branchVariant` が本当に細かく作用するのは
その後ろの `pointerFlavor`
だとみるのが safest になる。

## 2. Why TargetSource Still Matters, But Less

この整理は
`postBranchTargetSource`
を無意味だとするものではない。

current best reading では順序自体は

1. `postBranchTargetSource`
2. `pointerFlavor`
3. `target`

のままである。

ただし `branchVariant`
の effect の強さという観点では、

- `postBranchTargetSource` は weak gate / marker
- `pointerFlavor` は strong PTR-specific reopening

と読むほうが evidence に合う。

したがって current safest bias は、
PTR-specific second-line refinement の中心は
`pointerFlavor`
にある、というものである。

## 3. Provisional Meaning

現時点の safest provisional reading は次のように書ける。

```ts
type SecondLineReopening = {
  postBranchTargetSource: "explicit" | "candidate" | "slotIndex"
  pointerFlavor: "candidate" | "shared"
  target: number
}
```

そして current best bias は:

```ts
branchVariant strongly influences pointerFlavor
branchVariant weakly influences postBranchTargetSource
target is downstream of both
```

である。

## implication for step 6

この整理を採ると、step 6 の current code shape でも
PTR-specific second-line reopening を観測するとき、
まず注目すべきなのは

- `pointerFlavor`

であって、
`postBranchTargetSource`
はその前段 marker として読むのが自然になる。

つまり next debugging / next analysis の主観測点も
`pointerFlavor`
へ寄せるのが安全である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `branchVariant` が `pointerFlavor` の candidate/shared 差に最も強く効くか
2. `postBranchTargetSource` は branchVariant 非依存でも説明できるか
3. final `target` の差分は pointer reopening の downstream effect として十分か

ここが取れれば、PTR-specific second-line refinement の中心はかなり明確になる。
