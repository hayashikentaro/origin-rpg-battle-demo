# Saga2 Post-Branch TargetSource Independence Report

## 要点

- current best reading では、`postBranchTargetSource` は **`branchVariant` に強く依存する field** より、まず **shared post-branch entry marker** とみるのが最も自然である
- 理由は、既報で `branchVariant` の second-line effect を `pointerFlavor` に強く寄せているため、`postBranchTargetSource` まで同じ強さで依存させると PTR-specific refinement の中心がぼやけるからである
- したがって current best bias は、second-line では  
  - `postBranchTargetSource` = branchVariant 非依存でも説明しやすい入口 marker  
  - `pointerFlavor` = branchVariant に強く依る PTR-specific reopening  
  という役割分担で持つのが safest である

## 1. Why TargetSource Works Better As A Shared Marker

既報では second-line の順序は

1. `postBranchTargetSource`
2. `pointerFlavor`
3. `target`

と置いている。

このとき `postBranchTargetSource` を
`branchVariant` が細かく分ける本体とみなすより、
まずは
**post-branch reopening が candidate 寄りか shared 寄りかを示す入口 marker**
とみるほうが flow に合う。

特に current best reading では、
PTR-specific 差分の本体は pointer provenance に寄っているため、
targetSource まで同じ強さで refinement を背負わせる必要は薄い。

## 2. Why PointerFlavor Still Carries The PTR Specificity

`postBranchTargetSource` を shared marker に寄せるといっても、
PTR-specific 差分が消えるわけではない。

むしろ safest decomposition は:

- `postBranchTargetSource` = second-line reopening の入口 marker
- `pointerFlavor` = branchVariant による PTR-specific reopening の本体
- `target` = その downstream effect

である。

この形なら、
`branchVariant`
の効果が second-line でどこに一番強く出るかがかなり明確になる。

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
postBranchTargetSource is weakly or not directly branchVariant-dependent
pointerFlavor is strongly branchVariant-dependent
```

である。

## implication for step 6

この整理を採ると、step 6 の debug / API 読みもかなり素直になる。

- `postBranchTargetSource` は reopening の入口を見る field
- `pointerFlavor` は PTR-specific reopening の本体を見る field

として役割を分けて観測すればよい。

つまり next debug / next analysis の主観測点を
`pointerFlavor`
へ寄せても、
`postBranchTargetSource`
は still useful な前段 marker として残る。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `postBranchTargetSource` が branchVariant 非依存でもかなり説明できるか
2. `pointerFlavor` が branchVariant の主要な反映先とみてよいか
3. final `target` は `pointerFlavor` の downstream effect として十分説明できるか

ここが取れれば、second-line field の役割分担はかなり安定する。
