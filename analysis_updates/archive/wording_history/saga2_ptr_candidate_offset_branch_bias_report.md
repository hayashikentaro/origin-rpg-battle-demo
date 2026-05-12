# Saga2 PTR Candidate-Offset Branch Bias Report

## 要点

- current best reading では、`PTR` false 側で保持される `candidateOffset` は **target routing 専用の残骸** より、まず **strict fallback branch generator に関与する candidate-flavored selector material** とみるのが最も自然である
- 理由は、いま詰めている `combatDecision` 自体が target writeback より前の **actor-local accept/reject branch** に寄っており、false 側で残る path-specific 情報もまず branch 側へ効くとみるほうが flow 上整合するからである
- したがって current best bias は、`PTR` false 側の `candidateOffset` は  
  - first fallback step では branch selector material に残り  
  - target routing への再利用は second line  
 という順位を持つ

## 1. Why Branch Bias Fits Better Than Routing Bias

もし `candidateOffset` が false 側でただちに target routing 専用へ落ちるなら、
それは accept/reject の narrow opener を越えた後段 state に近い意味になる。

しかし current best reading では `combatDecision` の first consumer は

- wide staging
- final target writeback

ではなく、

- actor-local opener の accept/reject branch

に置かれている。

このため、false 側でまだ残る path-specific candidate 情報も、
まずは **branch generator material**
とみるほうが flow に合う。

## 2. Why This Still Preserves Candidate Flavor

既報では `PTR` false 側を

- `fallbackKind="strict-path"`
- `fallbackEntryFlavor="candidate"`
- `preservesCandidateOffsetInitially=true`

として読む bias を置いている。

ここで `candidateOffset` を branch selector material とみるのは、
candidate flavor を弱める話ではなく、
その flavor の中身を一段具体化するだけである。

つまり current best reading では:

- flavor label = candidate
- flavor payload = candidateOffset
- first use = branch generator

という 3 段に分けるのが自然になる。

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
}
```

この意味では `candidateOffset` は
まだ final target を直接決めるのではなく、
**どの strict fallback branch を開くか**
に寄与する selector material とみなされる。

## implication for step 6

この整理を採ると、step 6 の current bridge でも
`PTR` false 側は

- target routing 再実行待ちの状態

というより、

- candidate-flavored strict fallback branch を選ぶ途中状態

として扱うのが自然になる。

つまり `PTR` false 側の unresolved 部分は
**targetSource recompute**
より
**branch choice shaping**
に重みを置いて観測するのがよい。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `candidateOffset` が false 側 branch code の違いに影響するか
2. strict fallback の second step で初めて target routing に渡るか
3. `ATK` false 側との差が branch choice shaping に最も強く出るか

ここが取れれば、`PTR` false 側は
**strict fallback with candidate-offset-shaped branch selection**
としてかなり実装寄りに固められる。
