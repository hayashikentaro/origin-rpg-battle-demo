# Saga2 Target-Diff Explained By Pointer-Class Report

## 要点

- current best reading では、`ATK/PTR` の final `target` 差分は **主に `pointerFlavor` の class 差** で説明できるとみるのが最も自然である
- 理由は、既報で second-line の中心を `pointerFlavor` に置き、`target` をその downstream result と読んでいる以上、ATK と PTR の final target 差も first-line では pointer-side provenance class の違いとして吸収するのが最小仮説になるからである
- したがって current best bias は、`target` は独立に複雑な path を持つより、  
  - `"shared"` class から来る ATK 側 target  
  - `"candidate"` class から来る PTR 側 target  
  という 2 class downstream result として読むのが safest である

## 1. Why Pointer-Class Is The Natural Explainer

current best reading では second-line の役割分担を

- `postBranchTargetSource` = entry marker
- `pointerFlavor` = reopening core
- `target` = downstream result

として整理している。

この構図を採るなら、
`ATK/PTR` の final target 差も
最初に疑うべきなのは
`pointerFlavor`
である。

つまり final target の違いを
それ自体の mystery に戻すより、
まず
**pointer/materialization class が違うから target の downstream result も違う**
とみるほうが自然になる。

## 2. Why This Does Not Eliminate All Later Detail

この整理は、
`target`
の exact ROM-level route をすべて説明したと主張するものではない。

ただし current frontier では、
shape を増やさずに semantics を強めることが重要なので、
first-line の safest reading としては
`target` 差分の大部分を
`pointerFlavor`
の class 差へ還元するのがいちばん軽い。

より細かい差分は、
そのあとで second-line downstream detail
として追加確認すればよい。

## 3. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
type PointerFlavor = "shared" | "candidate"

type FinalTarget = number
```

そして relation は:

```ts
pointerFlavor determines target-family bias
target is downstream of pointerFlavor
```

である。

ここで:

- `"shared"` => ATK 側 default target family
- `"candidate"` => PTR 側 candidate target family

とみるのが自然である。

## implication for step 6

この整理を採ると、step 6 の current code / debug shape では
`target`
を先に増やして説明するより、
まず

- `pointerFlavor`
- `target`

の対応を強く見る方針がかなり取りやすい。

つまり second-line の主観測点は引き続き
`pointerFlavor`
であり、
`target`
はその class 差でかなり吸収できるとみるのが safest である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `ATK/PTR` の target 差分が `pointerFlavor` の class 差でかなり説明できるか
2. `postBranchTargetSource` を足しても target 差分の主因は `pointerFlavor` に残るか
3. final target の追加 detail が必要だとしても、それは second-line downstream detail に留まるか

ここが取れれば、`pointerFlavor -> target` の関係はかなり安定する。
