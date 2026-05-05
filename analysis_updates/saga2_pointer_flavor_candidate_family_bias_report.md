# Saga2 PointerFlavor Candidate-Family Bias Report

## 要点

- current best reading では、`pointerFlavor="candidate"` は battle-side で最も自然に **`D?12..` repeated candidate-entry family** に結びつくとみるのが safest である
- 理由は、既報の narrowing が  
  - `C/H` pair origin  
  - `D?12..` entry semantics  
  - special-candidate family gate  
  - PTR-specific candidate reopening  
  を一続きでつないでおり、second-line の `"candidate"` provenance もその continuation とみるのが最小仮説になるからである
- したがって current best bias は、`pointerFlavor="candidate"` は generic candidate label ではなく、**`D?12..` family 由来の candidate pointer provenance** として持つのがもっとも自然である

## 1. Why `D?12..` Is The Best Current Anchor

既報では `D?12..` repeated entry family について、

- low byte = candidate/type code
- high byte = qualifier / owner / count-like byte

という reading を current best として置いている。

さらに `41BC-41C3` の `C/H` pair、`41C4-41D8` の special-candidate gate、
`41D9-41EC` の consume belt までを重ねると、
PTR 側で reopening する candidate provenance も
この family から伸びているとみるのが最も軽い。

このため `pointerFlavor="candidate"` のアンカーは、
item raw storage や compact action head より
**`D?12..` candidate-entry family**
へ置くのが自然になる。

## 2. Why This Fits The PTR Path Better Than ActionHead

`BattleActionHead`
は current best reading では

- `kindId`
- `arg`
- `target`
- `slotIndex`

から local path を開く入力 head として十分強いが、
PTR second-line の pointer provenance を直接担うには一段高位すぎる。

いっぽう `D?12..` family は:

- repeated candidate entries
- special-candidate family code/qualifier pair
- candidate consume/accept policy

といった lower-level material を already 持っている。

このため `pointerFlavor="candidate"` は
ActionHead 直下より
**candidate-entry family の provenance reopening**
として読むほうが整合する。

## 3. Safest Current Reading

現時点の safest reading は次のように要約できる。

```ts
pointerFlavor === "candidate"
```

は:

```ts
candidate pointer provenance reopened from the D?12.. entry family
```

にかなり近い。

つまり `"candidate"` は generic label ではなく、
`D?12..`
candidate-entry line の downstream reopening とみるのが safest である。

## implication for step 6

この整理を採ると、step 6 の current code / debug shape では
`pointerFlavor="candidate"` を見たとき、
単に

- PTR path だった

と読むより、

- `D?12..` candidate-entry provenance が second-line で reopening している

と読むほうが battle-side semantics に近い。

つまり next analysis は、
`pointerFlavor` をより深くするなら
`D?12..` family との exact mapping を first target に置くのが自然である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `pointerFlavor="candidate"` が `D?12..` family のどの sub-entry class に最も近いか
2. `branchVariant 0/1` が `D?12..` entry の code/qualifier 差とどう対応するか
3. final `target` の差分も `D?12..` provenance の違いでかなり説明できるか

ここが取れれば、`pointerFlavor="candidate"` の exact semantics はかなり recovered semantics に近づく。
