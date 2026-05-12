# Saga2 Target Pair-Alignment Explanatory Power Report

## 要点

- current best reading では、final `target` 差分は **`pointerFlavor` の pair alignment** だけで first-line かなり説明できるとみるのが最も自然である
- つまり `target` は独立の PTR-specific semantic source ではなく、  
  - `"candidate"` = strict-side aligned provenance reopening  
  - `"shared"` = fast/default aligned provenance reopening  
  の downstream terminal として読むのが safest である
- このため current frontier では、`target` に新しい class field や polarity field を足すより、**`pointerFlavor` pair の explanatory power を強める** ほうが battle-side evidence に合う

## 1. Why Pair Alignment Explains Target Better Than A New Target-Level Axis

既報では:

- `pointerFlavor`
  = second-line reopening の中心 field
- `"candidate"`
  = strict-side aligned provenance reopening
- `"shared"`
  = fast/default aligned provenance reopening
- `target`
  = pointer reopening downstream result

と整理している。

この前提を採ると、
final `target`
差分を説明する最も軽い読みは、
新しい target-level axis を導入することではなく、
**pointerFlavor pair の downstream effect**
として読むことである。

つまり safest bias は、
`target`
を second-line pair alignment の
**terminal consequence**
として持つことにある。

## 2. Why This Works Across ATK / PTR

ATK/PTR の second-line 差は current best reading では:

- ATK
  -> `"shared"` default reopening
- PTR
  -> `"candidate"` candidate reopening

としてかなり整理されている。

この時点で final `target`
差分も、

- ATK 側では default pointer lineage downstream
- PTR 側では candidate pointer lineage downstream

と読めばかなり自然につながる。

つまり `target`
の primary explanatory source は
`pointerFlavor`
で十分であり、
ATK/PTR 差分を target 自体へ押し込む必要は薄い。

## 3. Why This Works Across `accepted=false/true`

既報では `pointerFlavor`
も `accepted=false/true`
をまたいで same alignment を保つと読んでいる。

この前提を採ると、
final `target`
もまた

- false 側 = fallback downstream
- true 側 = admitted downstream

という role 差を持つだけで、
alignment 自体は
`pointerFlavor`
からそのまま継承されると読むのが自然になる。

つまり `accepted`
が変えるのは target の polarity ではなく、
**same alignment をどの control-flow role で読むか**
だけである。

## 4. Why `postBranchTargetSource` Still Stays Secondary

既報では
`postBranchTargetSource`
は second-line reopening の入口 marker として useful だが、
PTR-specific 差分の中心ではないと整理している。

このため final `target`
差分の first-line explanation も、

- `postBranchTargetSource`
 だけではなく
- `pointerFlavor`

に重みを置くほうが自然である。

つまり current safest reading は:

- `postBranchTargetSource`
  = entry marker
- `pointerFlavor`
  = explanatory core
- `target`
  = downstream terminal

である。

## 5. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
type SecondLine = {
  postBranchTargetSource: "explicit" | "candidate" | "slotIndex"
  pointerFlavor: "shared" | "candidate"
  target: number
}
```

そして exact-bias は:

```ts
target ~= downstream terminal of pointerFlavor pair alignment
```

にかなり近い。

つまり current frontier では、
final `target`
差分は
**pointerFlavor pair の explanatory power**
だけで first-line かなり吸収できる、
と読むのが safest である。

## implication for step 6

この整理を採ると、
step 6 の provisional API では
`target`
に別の semantic field を足す必要がかなり薄くなる。

- `pointerFlavor`
 で class/alignment を持つ
- `target`
 で terminal result を持つ

という 2 層で十分だからである。

つまり next analysis / next implementation は、
`target`
自体を細分化するより、
**pointerFlavor -> target**
の downstream relation を強めるほうが安全である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. final `target` 差分のうち pair alignment だけで説明し切れない residual が本当にあるか
2. `postBranchRoute` が downstream terminal としての `target` にどこまで直接効くか
3. `branch` family 自体も `pointerFlavor` pair とどこまで対称な alignment を持つか

ここが取れれば、second-line の exact semantics はかなり recovered semantics に近づく。
