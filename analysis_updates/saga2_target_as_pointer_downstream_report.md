# Saga2 Target-As-Pointer-Downstream Report

## 要点

- current best reading では、second-line の final `target` は **独立した PTR-specific field** より、まず **`pointerFlavor` の downstream effect** とみるのが最も自然である
- 理由は、既報で `PTR` second-line の中心を `pointerFlavor` に置き、`postBranchTargetSource` を弱い入口 marker として分けた以上、残る `target` はその pointer reopening を受けて downstream に決まると読むほうが flow に合うからである
- したがって current best bias は、second-line の役割分担を  
  - `postBranchTargetSource` = entry marker  
  - `pointerFlavor` = PTR-specific reopening core  
  - `target` = pointer reopening downstream result  
  と置くのが safest である

## 1. Why Target Is Best Read As A Downstream Result

もし final `target` 自体を PTR-specific 差分の中心とみなすなら、
それは second-line の主戦場を target 側へ戻すことになる。

しかし current best reading では、
PTR の path-specific 差分は

- first-line では `branchVariant`
- second-line では `pointerFlavor`

へかなり集約されている。

このため safest reading は、
`target`
をそれ自体の特異 field として持つより、
**pointer reopening の downstream result**
とみることである。

つまり final target は、
PTR-specific 差分の source ではなく
その consequence に近い。

## 2. Why This Keeps The Second-Line Layer Clean

この整理を採ると second-line の役割分担がかなり明快になる。

- `postBranchTargetSource`  
  reopening の入口を示す
- `pointerFlavor`  
  PTR-specific 差分の本体を担う
- `target`  
  その結果として決まる

つまり second-line の中心は
`pointerFlavor`
であり、
`target`
はその downstream terminal として扱える。

この構図なら、
API field の役割もきれいに分かれる。

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
target = resolveFinalTargetFromPointerFlavor(pointerFlavor, ...)
```

にかなり近い。

もちろん `postBranchTargetSource`
も前提にはなるが、
second-line の主たる差分源は
`pointerFlavor`
側にあるとみるのが自然である。

## implication for step 6

この整理を採ると、step 6 の current debug / code shape では
`target`
を first-class unresolved mystery として追い続けるより、
まず

- `branchVariant`
- `pointerFlavor`

のつながりを強くし、
`target`
はその結果として観測する方針がかなり取りやすくなる。

つまり next analysis / next implementation の主観測点は、
引き続き `pointerFlavor`
へ置くのが safest である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. final `target` が `pointerFlavor` の downstream effect だけでかなり説明できるか
2. `postBranchTargetSource` は target の決定そのものより pointer reopening の入口 marker に留まるか
3. `ATK/PTR` の final target 差分も pointer 層の違いでかなり吸収できるか

ここが取れれば、second-line の field 役割分担はかなり安定する。
