# Saga2 PTR Candidate-Offset Branch-Code Bias Report

## 要点

- current best reading では、`PTR` false 側の `candidateOffset` は **strict fallback branch の存在を支える曖昧な補助値** より、まず **false-side branch code の違いを形作る first-line selector material** とみるのが最も自然である
- 理由は、いまの `combatDecision` frontier がすでに `accepted` first / `branch` second に寄っており、`PTR` 固有の path-specific 情報が残るなら、その first reusable point も branch code 差分であるほうが flow に合うからである
- したがって current best bias は、`PTR` false 側では  
  - `candidateOffset` は strict fallback の entry flavor に残るだけでなく  
  - first-line では branch code shaping に使われる  
 という形になる

## 1. Why Branch-Code Shaping Beats Passive Retention

もし `candidateOffset` が false 側でただ「保持されるだけ」なら、
それは still-unresolved metadata であって、
`combatDecision` の consumer narrowing に対する寄与が弱い。

しかし current best reading では `combatDecision` の consumer はすでに

- accepted / rejected
- strict fallback bias
- branch second

という narrow opener に寄っている。

このため、`PTR` 固有差分である `candidateOffset` も
最初に寄与する場所は
**false-side branch code shaping**
とみるほうが自然になる。

## 2. Why This Still Preserves The Earlier Biases

この整理は既報の

- `fallbackKind="strict-path"`
- `fallbackEntryFlavor="candidate"`
- `preservesCandidateOffsetInitially=true`
- `usesCandidateOffsetForFallbackBranch=true`

と矛盾しない。

むしろそれらを一段具体化して、

- entry flavor = candidate
- retained payload = candidateOffset
- first semantic use = branch-code shaping

という 3 段構造にするだけである。

したがって current best reading は、
`candidateOffset` を target routing へ直結させるより
**strict fallback branch code を分ける材料**
として先に使うほうが flow 上整合的である。

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
}
```

この意味では `candidateOffset` は
strict fallback 後に残る candidate metadata というだけでなく、
**どの false-side branch code を採るか**
の first-line 決定材料とみなされる。

## implication for step 6

この整理を採ると、step 6 の unresolved `combatDecision` は

- accepted / rejected
- fallbackKind
- branch

のうち、`PTR` では特に
**branch の path-specific variant**
を `candidateOffset` が shaping している可能性が高い、
という形まで持てる。

つまり次の観測軸は
`targetSource` 再計算や final routing よりも、
**false-side branch code の分岐差**
を見ることにかなり集約できる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `candidateOffset` の違いが false-side branch code の variant 差へ直接つながるか
2. `PTR` false 側で branch code 決定後に初めて target routing が再開されるか
3. `ATK` false 側との差が `branch` の variant 数に最も強く出るか

ここが取れれば、`PTR` false 側は
**strict fallback whose branch code is shaped by candidateOffset**
としてかなり実装寄りに固められる。
