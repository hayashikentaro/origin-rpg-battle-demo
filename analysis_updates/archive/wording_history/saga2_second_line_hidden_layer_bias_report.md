# Saga2 Second-Line Hidden-Layer Bias Report

## 要点

- current best reading では、`PTR` second-line の `pointerFlavor` と final `target` の間に **大きな追加 hidden layer** を first-line で置く必要は薄く、まずは **薄い target determination step** だけを想定するのが最も自然である
- 理由は、現在の narrowing がすでに  
  - `postBranchTargetSource`
  - `pointerFlavor`
  - `target`
  まで code / analysis の両方で整列しており、この間にさらに厚い中間層を入れると provisional API boundary の利点がかなり弱くなるからである
- したがって current best bias は、second-line reopening は  
  - source reopening
  - pointer reopening
  - thin final-target step  
  で十分であり、もし hidden layer があっても second-line の下位 detail に留まる、と置くのが safest である

## 1. Why A Large Hidden Layer Is Unnecessary Right Now

もし `pointerFlavor` の後ろにさらに大きい hidden layer を置くなら、
それは second-line reopening の current shape をもう一段分解することになる。

しかし現時点では、

- `combatDecision`
- `postBranchRoute`
- `postBranchTargetSource`
- `pointerFlavor`
- `target`

という並びが
battle-side reading と code frontier の両方でかなりよく噛み合っている。

このため safest reading は、
`pointerFlavor -> target`
の間には first-line では大きな hidden layer を増やさず、
あっても **thin target determination step**
として扱うことである。

## 2. Why This Still Leaves Room For Later Refinement

この整理は、
将来追加の detail が見つからないと断定するものではない。

ただし current frontier で重要なのは
API boundary を安定させることであり、
そこで不必要に hidden layer を増やすと

- `postBranchTargetSource`
- `pointerFlavor`
- `target`

の second-line meaning がぼやける。

したがって current best bias は、
hidden layer の可能性を second-line 下位 detail に留めて、
first-line の recovered decomposition では
**pointer -> target**
をほぼ直列に保つことである。

## 3. Safest Current Decomposition

現時点の safest decomposition は次のように書ける。

```ts
type SecondLineReopening = {
  postBranchTargetSource: "explicit" | "candidate" | "slotIndex"
  pointerFlavor: "candidate" | "shared"
  target: number
}
```

ここで `target` は
pointer reopening の downstream にある
thin final determination として扱うのが自然である。

つまり現段階では、
別の named field をこの間へ追加するより、
`target` を second-line の終端として維持するほうが安全になる。

## implication for step 6

この整理を採ると、step 6 の provisional API は

1. `combatDecision`
2. `postBranchRoute`
3. `postBranchTargetSource`
4. `pointerFlavor`
5. `target`

の 5 段で十分であり、
余計な hidden layer を前倒しで API に露出しなくてよい。

つまり current frontier では、
second-line reopening の最後は
**thin final-target step**
として実装・解析をそろえるのが safest である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. battle-side evidence が `pointerFlavor -> target` の thin step で足りるか
2. `PTR` second-line の specialness が target 自体より pointer 段に強く残るか
3. hidden layer が見つかるとしても、それが API field 追加を要するほど大きいか

ここが取れれば、second-line reopening の provisional API shape はかなり安定する。
