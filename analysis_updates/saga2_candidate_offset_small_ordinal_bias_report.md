# Saga2 Candidate-Offset Small-Ordinal Bias Report

## 要点

- current best reading では、`PTR` false 側で `candidateOffset` が刻む branch-space は **large table index** より、まず **small ordinal 的な branch selector** とみるのが最も自然である
- 理由は、いま詰めている `combatDecision` の first consumer が wide target resolution ではなく actor-local opener の narrow accept/reject branch に寄っているため、その first output も fine-grained address ではなく **少数の local branch variant** であるほうが flow に合うからである
- したがって current best bias は、`candidateOffset` の値域差は  
  - final target を直接指す index ではなく  
  - false-side branch code の small ordinal variant  
 へ first-line で写る、と置くのが safest である

## 1. Why A Small Ordinal Fits Better Than A Large Index

もし `candidateOffset` が false 側で large table index 的にそのまま使われるなら、
それは branch opener というより target resolution / pointer materialization の層に近い。

しかし current best reading では `combatDecision` の first consumer は

- accepted / rejected
- strict fallback
- branch second

という narrow actor-local gate に置かれている。

このため `candidateOffset` の first semantic use も、
まずは
**どの local fallback branch variant を採るか**
を表す small ordinal に落ちるとみるほうが自然になる。

## 2. Why This Still Preserves Range Partition Bias

既報では `PTR` false 側の branch-space 拡張は
`candidateOffset` の値域差に対応する
という bias を置いている。

この reading は small ordinal 仮説と矛盾しない。

むしろ:

- `candidateOffset` 自体は wider range を持つ
- その range が 2〜数個の bucket に畳まれる
- その bucket が false-side branch ordinal を決める

と読むほうが flow に合う。

つまり current best reading は、
`candidateOffset` が
**range-partitioned -> ordinalized -> branch-coded**
という順で使われるとみるのが自然である。

## 3. Provisional Meaning

現時点の safest provisional reading は次のように書ける。

```ts
type CombatDecisionConsumerResult = {
  accepted: boolean
  branch: number
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

この意味では、`PTR` false 側で増える branch-space は
candidate pointer の raw range をそのまま露出するのではなく、
**small ordinal 化された local fallback selector**
として first-line に現れる。

## implication for step 6

この整理を採ると、step 6 の unresolved `combatDecision` を
TypeScript へ落とすときも、
`PTR` false 側を

- offset-driven large index

として持つ必要はなく、

- offset-range bucket -> small branch ordinal

として持つほうが自然になる。

つまり次の観測軸は、
`candidateOffset` が large target index を直接作るかではなく、
**small ordinal 的な false-side branch code** を first-line で作るか
にかなり集約できる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `candidateOffset` の値域差が 2〜数個の ordinal bucket に畳まれているか
2. その ordinal bucket が false-side branch code とほぼ同じ粒度か
3. target routing はその small ordinal branch 決定後にだけ二次的に走るか

ここが取れれば、`PTR` false 側は
**shared strict fallback policy with offset-bucketed small-ordinal branch selection**
としてかなり実装寄りに固められる。
