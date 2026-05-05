# Saga2 Candidate-Offset Value-Range Bias Report

## 要点

- current best reading では、`PTR` false 側の branch-space 拡張は **`candidateOffset` の値域差** に対応しているとみるのが最も自然である
- 理由は、`PTR` false 側の specialness を policy 差ではなく branch-space の細分化に置くなら、その細分化を first-line で支える path-specific payload も `candidateOffset` しか見えていないからである
- したがって current best bias は、`PTR` false 側の branch code variant は  
  - `candidateOffset` の有無ではなく  
  - `candidateOffset` の値域/区分差  
 で増える、と置くのが safest である

## 1. Why Presence/Absence Alone Is Too Weak

もし `candidateOffset` が単に

- ある
- ない

だけで false 側 branch を分けるなら、
それは `PTR` と `ATK` の区別には使えても、
既報の「`PTR` false 側は `ATK` false 側より branch variant 数が多い」
という current best bias を十分に支えない。

`PTR` false 側の branch-space 拡張を本気で読むなら、
`candidateOffset` は mere presence ではなく
**値域差を持つ selector material**
とみるほうが自然である。

## 2. Why Range Bias Fits The Current Skeleton

現在の skeleton で `PTR` path に特有なのは

- `didConsumeCandidateRng`
- `targetSource="candidate"`
- `candidateOffset`

であり、この中で離散的な分岐材料になりうるのは
`candidateOffset` だけである。

しかも既報ではこれを

- first fallback step に保持される
- branch selector material
- branch code shaping に使われる

ところまで押し上げている。

そのため次の safest extension は、
`candidateOffset` が
**branch-space を区分化する値域差**
を持つとみることである。

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
}
```

この意味では、`PTR` false 側の branch variant 増加は
単なる candidate provenance ではなく、
**candidateOffset の値域が strict fallback branch code を刻む**
ことで生じる。

## implication for step 6

この整理を採ると、step 6 の unresolved `combatDecision` は

- shared strict fallback policy
- expanded false-side branch-space

のうち、後者の source を
**candidateOffset range partition**
として持てるようになる。

つまり次の観測軸は
`PTR` false 側が `ATK` と違う branch を持つか
だけでなく、
**その branch 差が offset 値域の違いに沿うか**
へかなり集中できる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `candidateOffset` の値域が false-side branch code の variant 区分に対応するか
2. その区分が small ordinal 的な branch selector か
3. target routing はその branch code 決定後に二次的に走るだけか

ここが取れれば、`PTR` false 側は
**shared strict fallback policy with offset-range-partitioned branch-space**
としてかなり実装寄りに固められる。
