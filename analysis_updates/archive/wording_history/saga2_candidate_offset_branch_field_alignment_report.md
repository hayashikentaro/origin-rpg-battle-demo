# Saga2 Candidate-Offset Branch-Field Alignment Report

## 要点

- current best reading では、`PTR` false 側で `candidateOffset` から得られる small ordinal bucket は **`branch` フィールドそのもの** より、まず **`branch` の下位 variant** とみるのが最も自然である
- 理由は、既報の `branch` 自体が actor-local opener の比較的高位な local phase / path selector として読まれている一方、`candidateOffset` から得られる差分は `PTR` false 側にだけ現れる path-specific refinement だからである
- したがって current best bias は、`PTR` false 側の offset bucket は  
  - top-level `branch` を丸ごと置き換えるのではなく  
  - strict fallback branch の内側で variant を分ける sub-branch material  
 になる、という形で持つのが safest である

## 1. Why The Bucket Is Too Narrow To Replace `branch`

既報では `branch` は

- `decodeResolvedOutcome(player, outcomeLikeByte)` が返す
- actor-local opener をどの local path / phase へ送るかを決める

という比較的高位の selector として整理している。

一方で `candidateOffset` の差分は、

- `PTR` path にのみ現れる
- false 側 strict fallback でだけ効く
- candidate-flavored entry を細分化する

という **局所的で path-specific** な性質を持つ。

このため safest reading は、
`candidateOffset` bucket が top-level `branch` そのものを置き換えるのではなく、
その branch の内側にある
**sub-branch / variant slot**
を刻むとみることである。

## 2. Why This Still Preserves Small-Ordinal Bias

この整理は既報の

- offset-range-partitioned branch-space
- small ordinal branch selector

と矛盾しない。

むしろ:

- `branch` = high-level local phase / path
- `candidateOffset bucket` = false-side strict fallback variant

と 2 層化することで、
small ordinal bias を battle-side API に落としやすくする。

つまり current best reading では、
`candidateOffset` から得られる ordinal は
**branch field**
より
**branchVariant field**
に近い。

## 3. Provisional Meaning

現時点の safest provisional reading は次のように書ける。

```ts
type CombatDecisionConsumerResult = {
  accepted: boolean
  branch: number
  branchVariant?: number
  fallbackKind?: "strict-path"
  bypassesCurrentConsumeBelt?: boolean
  fallbackEntryFlavor?: "candidate"
  preservesCandidateOffsetInitially?: true
  usesCandidateOffsetForFallbackBranch?: true
  candidateOffsetShapesFalseBranchCode?: true
  falseBranchVariantsTrackCandidateOffsetRange?: true
  falseBranchActsLikeSmallOrdinalSelector?: true
}
```

この意味では `PTR` false 側の specialness は、
top-level の phase selector を変えることではなく、
**strict fallback branch の内部 variant**
を増やすことにある。

## implication for step 6

この整理を採ると、step 6 の TypeScript provisional shape でも
`combatDecision.branch` を path 共通の high-level branch として保ちつつ、
`PTR` false 側だけ

- `branchVariant`

を増やす方向が自然になる。

つまり current frontier では、
`candidateOffset` の問いは
「branch を変えるか」ではなく
「branch の内側でどの variant を開くか」
へかなり集約できる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `PTR` false 側の offset bucket が branch の下位 variant として扱えるか
2. `ATK` false 側には対応する `branchVariant` が実質不要か
3. target routing は `branchVariant` 決定後にだけ二次的に走るか

ここが取れれば、`PTR` false 側は
**shared branch + PTR-only strict-fallback variant**
としてかなり実装寄りに固められる。
