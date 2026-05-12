# Saga2 PTR Pointer-Persistence Bias Report

## 要点

- current best reading では、`PTR` false 側の second-line reopening で見える candidate flavor は **`targetSource` 段で止まる** より、まず **pointer/materialization 段まで持続する** とみるのが最も自然である
- 理由は、`PTR` path のもともとの特殊性が target ラベルより **pointer-like candidate source** に強く寄っており、second-line reopening でもその provenance が target/source だけで切れると path-specific 差分が弱くなりすぎるからである
- したがって current best bias は、`PTR` false 側の second-line は  
  - candidate-flavored target/source reopening  
  - candidate-flavored pointer/materialization reopening  
  の 2 段を持つ、という形になる

## 1. Why Candidate Flavor Should Reach Pointer Materialization

既報では `PTR` の特徴は

- `didConsumeCandidateRng`
- `targetSource="candidate"`
- `candidateOffset`

という 3 本で観測されている。

このうち `targetSource` だけが second-line に残り、
pointer/materialization では消えるとすると、
`PTR` の path-specific 差分はかなり label 的なものに縮退する。

しかし current best reading では、
`PTR` の差分はむしろ
**candidate-like pointer provenance**
に強くある。

したがって safest reading は、
second-line でも
candidate flavor が pointer/materialization まで伸びる
とみることである。

## 2. Why This Still Preserves The Layering

この整理は、
target/pointer を first-line に戻す話ではない。

順序は引き続き:

1. `combatDecision`
2. `postBranchRoute`
3. candidate-flavored target/source reopening
4. candidate-flavored pointer/materialization reopening

である。

つまり candidate flavor persistence は
**routing layer の second-line 内部**
での話であり、
decision layer の独立性は保たれている。

## 3. Safest Current Decomposition

現時点の safest decomposition は次のように書ける。

```ts
type SecondLineTargetEvidence = {
  target?: number
  targetSource?: "candidate" | "explicit" | "slotIndex"
}

type SecondLinePointerEvidence = {
  pointerRecord?: number
  pointerFlavor?: "candidate" | "shared"
}
```

そして `PTR` false 側の current best bias は:

```ts
targetSource === "candidate"
pointerFlavor === "candidate"
```

である。

## implication for step 6

この整理を採ると、step 6 の second-line 実装では
`PTR` 側だけ

- target reopening
- pointer reopening

の両方に candidate flavor を通す設計がかなり自然になる。

つまり current frontier では、
`PTR` second-line は
target/source だけでなく
pointer/materialization にも path-specific bias を持つ
と見ておくのが安全である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `PTR` false 側で `targetSource="candidate"` のあとに pointer/materialization も candidate-flavored に reopening するか
2. `ATK` second-line との差が target より pointer 側に強く出るか
3. second-line の pointer reopening が final target 決定より前に現れるか

ここが取れれば、routing layer の second-line decomposition は PTR 側までかなり具体化する。
