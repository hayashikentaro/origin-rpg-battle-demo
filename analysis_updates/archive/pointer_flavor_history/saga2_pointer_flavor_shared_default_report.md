# Saga2 PointerFlavor Shared-Default Report

## 要点

- current best reading では、`pointerFlavor="shared"` は **単なる not-candidate 残余カテゴリ** より、まず **ATK 側の default pointer/materialization reopening class** とみるのが最も自然である
- 理由は、既報で `pointerFlavor` を second-line reopening の provenance class と読んでいる以上、その 2 値は対称に読むほうが軽く、`"candidate"` が PTR-specific class なら `"shared"` は shared/default class と置くのが最小仮説になるからである
- したがって current best bias は、`pointerFlavor` は  
  - `"shared"` = ATK 側を含む default reopening class  
  - `"candidate"` = PTR-specific reopening class  
 という 2 値で持つのが safest である

## 1. Why `"shared"` Should Be Read Positively

もし `"shared"` を単なる

- not-candidate
- fallback bucket
- uncategorized remainder

として扱うと、
`pointerFlavor`
自体の semantics が片側だけ強く、片側だけ弱いものになる。

しかし current best reading では、
`pointerFlavor`
は second-line の意味中心にかなり寄っている。

このため safest reading は、
`"shared"` もまた
**意味を持つ reopening class**
として正に読むことである。

## 2. Why ATK Is The Natural Anchor For `"shared"`

既報では `ATK` 側について:

- first-line では `branchVariant` が不要
- second-line では candidate-flavored reopening を持たない

という整理を置いている。

この current bias と最もよく噛み合うのが、
`ATK`
を `pointerFlavor="shared"` のアンカーとして読むことである。

つまり:

- `ATK` は shared/default reopening class
- `PTR` は candidate reopening class

という 2 分割が自然になる。

この構図なら、
`pointerFlavor`
は current debug matrix にもかなり素直に対応する。

## 3. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
type PointerFlavor = "shared" | "candidate"
```

そして semantics は:

```ts
"shared"    => ATK-anchored default pointer/materialization reopening
"candidate" => PTR-anchored candidate pointer/materialization reopening
```

である。

この読みだと、
`pointerFlavor`
は second-line の中心 field としてかなり安定する。

## implication for step 6

この整理を採ると、step 6 の current code / debug shape では
`pointerFlavor`
を

- ATK default
- PTR candidate

という 2 class で読めばよく、
新しい field を足す必要はかなり薄い。

つまり next analysis の焦点は
`pointerFlavor`
自体の設計ではなく、
この 2 class が battle-side でどこまで exact semantics を持つかに移る。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `"shared"` が ATK 側の default reopening class とみてよいか
2. `ATK/PTR` の final target 差分がこの class 差でかなり説明できるか
3. `pointerFlavor` 以外に second-line の主要 class field が要らないか

ここが取れれば、`pointerFlavor` の 2 値 semantics はかなり安定する。
