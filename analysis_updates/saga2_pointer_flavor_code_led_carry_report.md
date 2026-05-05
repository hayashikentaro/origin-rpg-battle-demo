# Saga2 PointerFlavor Code-Led Carry Report

## 要点

- current best reading では、`pointerFlavor="candidate"` は generic candidate label ではなく、**first-line の code-led compressed split を second-line へ持ち越した candidate provenance class** とみるのが最も自然である
- したがって `branchVariant` と `pointerFlavor="candidate"` は、どちらも `D?12..` family 差分を表すが、役割は  
  - `branchVariant` = first-line compressed refinement  
  - `pointerFlavor="candidate"` = second-line provenance reopening  
  と分かれる
- この carry でも主軸は qualifier 単独ではなく、**`0E/0F` special-candidate family 差** にあるとみるのが safest である

## 1. Why `pointerFlavor="candidate"` Should Be Read As A Carry

既報では `pointerFlavor="candidate"` は
`D?12..` repeated candidate-entry family に結びつく
PTR-specific reopening class
と読むのが current best である。

また `branchVariant`
も current best reading では
`D?12..` family 差分の first-line compressed image
と読んでいる。

この 2 本を最も軽くつなぐ読みは、
`pointerFlavor="candidate"`
を
**first-line で圧縮された同じ差分の second-line carry**
として持つことである。

つまり:

- first-line: `branchVariant`
- second-line: `pointerFlavor="candidate"`

は無関係な 2 種類の candidate 差分ではなく、
同じ provenance 差を別層で見せている
とみるのが safest である。

## 2. Why This Carry Is Code-Led

既報 `branchVariant primary axis`
では、
`branchVariant`
は pure qualifier split ではなく
**`0E/0F` special-candidate family difference を主軸**
にした binary refinement
と読むのが safest だと整理している。

この前提を second-line carry にそのまま延長すると、
`pointerFlavor="candidate"`
も generic candidate reopening より、
**`0E/0F` family 差を保持した candidate provenance class**
とみるのが自然になる。

つまり second-line でも主軸は:

- primary = `0E/0F` family difference
- secondary = qualifier class

である。

## 3. Why This Fits Better Than A Pure Qualifier Carry

もし `pointerFlavor="candidate"`
を pure qualifier carry とみるなら、
`branchVariant`
の code-led compressed split と
second-line provenance reopening の間に
意味軸のズレが生じる。

いっぽう code-led carry なら、

- first-line binary refinement
- second-line candidate provenance reopening

の両方が
**同じ `0E/0F` family difference**
を主軸にした別層表現としてそろう。

このため current best bias は、
`pointerFlavor="candidate"`
も qualifier-first ではなく
**code-led carry**
として持つほうが battle-side flow によく合う。

## 4. Role Split Between `branchVariant` And `pointerFlavor`

現時点の safest role split は次のように書ける。

```ts
branchVariant?: 0 | 1
```

= first-line compressed refinement

```ts
pointerFlavor: "shared" | "candidate"
```

= second-line reopening provenance class

そして current best reading では:

- `branchVariant` は local branch refinement を first-line で決める
- `pointerFlavor="candidate"` は同じ差分を second-line で provenance reopening として見せる

と読むのが自然である。

つまり
`pointerFlavor="candidate"`
は `branchVariant`
の duplicate ではなく、
**同じ差分の downstream reopening**
とみるのが safest になる。

## 5. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
branchVariant?: 0 | 1
pointerFlavor: "shared" | "candidate"
```

のうち、
`pointerFlavor === "candidate"`
は

```ts
second-line candidate provenance class
carrying the same D?12.. family difference
whose primary axis is 0E/0F
```

にかなり近い。

つまり `branchVariant`
が first-line の code-led compressed split なら、
`pointerFlavor="candidate"`
は second-line の code-led provenance reopening
と読むのが current best である。

## implication for step 6

この整理を採ると、
step 6 の provisional API は field を増やさずに意味を強められる。

- `branchVariant` = first-line refinement
- `pointerFlavor` = second-line provenance class

という分離を保ちつつ、
両者が battle-side では同じ `D?12..` family 差分に anchored している
と明記できるからである。

つまり next analysis は、
`pointerFlavor="candidate"`
を generic label としてではなく、
**code-led carry**
としてさらに sharpen すればよい。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `pointerFlavor="candidate"` が `0E/0F` family 差を second-line でどの程度保っているか
2. qualifier `1` blocked ordinal が second-line provenance reopening にどこまで残るか
3. final `target` の差分がこの code-led provenance class の downstream result としてどこまで説明できるか

ここが取れれば、`pointerFlavor` の exact semantics はかなり recovered semantics に近づく。
