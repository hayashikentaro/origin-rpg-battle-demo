# Saga2 Pointer-Before-Final-Target Report

## 要点

- current best reading では、`PTR` false 側の second-line reopening では **pointer/materialization が final target 決定より先に現れる** とみるのが最も自然である
- 理由は、`PTR` の path-specific 差分が current best reading では candidate-like pointer provenance に最も強くあり、その provenance が second-line で reopening するなら、まず pointer/materialization として現れ、その後に final target 決定へ流れるとみるほうが flow に合うからである
- したがって current best bias は、`PTR` false 側の second-line order は  
  - candidate-flavored target/source reopening  
  - candidate-flavored pointer/materialization reopening  
  - final target determination  
 という順を first-line に置くのが safest である

## 1. Why Pointer Comes Before Final Target

もし final target が pointer/materialization より先に確定するなら、
`PTR` の second-line specialness は target label に近いものへ縮退する。

しかし current best reading では、
`PTR` の差分はもともと

- candidateOffset
- pointer-like candidate source
- branchVariant

に強く寄っている。

このため second-line でも、
candidate flavor の first reopening は
**pointer/materialization**
とみるほうが自然になる。

その pointer-ish reopening を受けて、
はじめて final target 決定が downstream に現れる
と読むのが safest である。

## 2. Why This Still Preserves TargetSource Reopening

ここで target/source reopening を消すわけではない。

順序としては、

1. `postBranchRoute`
2. candidate-flavored target/source reopening
3. candidate-flavored pointer/materialization reopening
4. final target determination

と置くのが自然である。

つまり second-line では
`targetSource="candidate"`
が先に見えつつも、
それは final target の即時確定ではなく、
pointer/materialization へつながる provenance marker として働く、
という読みになる。

## 3. Safest Current Decomposition

現時点の safest decomposition は次のように書ける。

```ts
type SecondLineTargetEvidence = {
  targetSource?: "candidate" | "explicit" | "slotIndex"
}

type SecondLinePointerEvidence = {
  pointerRecord?: number
  pointerFlavor?: "candidate" | "shared"
}

type FinalTargetResolution = {
  target?: number
}
```

この順序では、`PTR` false 側は

- second-line 入口で `targetSource="candidate"`
- つづいて `pointerFlavor="candidate"`
- その後 final target

という流れで読むのが自然である。

## implication for step 6

この整理を採ると、step 6 の後段 skeleton も

1. `combatDecision`
2. `postBranchRoute`
3. `targetSource` reopening
4. `pointer/materialization`
5. final target

の順で積むのが battle-side reading とかなり噛み合う。

つまり current frontier では、
`PTR` second-line は target と pointer を同列に扱うより
**pointer before final target**
の bias を明示するのが安全である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `PTR` false 側の pointer/materialization reopening が final target より先に出るか
2. `ATK` second-line との差が pointer 層で最も強く現れるか
3. final target 決定は pointer reopening を受ける downstream step とみてよいか

ここが取れれば、routing layer の second-line order はかなり recovered semantics に近づく。
