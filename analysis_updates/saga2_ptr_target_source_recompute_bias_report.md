# Saga2 PTR Target-Source Recompute Bias Report

## 要点

- current best reading では、`PTR` false 側の strict-path fallback で **即座に `targetSource` を再計算する** より、まず **candidate flavor を保持したまま strict path に落ちる** とみるのが最も安全である
- 理由は、`PTR` path の path-specific 差分としていちばん強く見えているのが `candidateSource` / `candidateOffset` であり、false 側でもその flavor がすぐ消えるとみなす根拠はまだ弱いからである
- したがって current best bias は、`PTR` false 側は  
  - shared false-side policy  
  - strict-path fallback  
  - candidate-flavored fallback entry  
  を持つ、という形になる

## 1. Why Immediate Recompute Is Too Strong

もし `PTR` false 側で即 `targetSource` が再計算されるなら、
candidate path 由来であることは false 側で早々に失われることになる。

しかし current skeleton では、
`PTR` の path-specific 強みはまさに

- `didConsumeCandidateRng`
- `targetSource="candidate"`
- `candidateOffset`

にある。

このため safest reading は、
false 側でもまず
**candidate-flavored entry**
を保持するとみることである。

## 2. Why Strict Fallback Still Fits

既報では `PTR` false 側の fallbackKind は
strict-path に一段重みを置いている。

これは

- path 自体は candidate-source を持つ
- ただし accept policy は shared
- false 側では current consume belt を開かない

という整理と矛盾しない。

つまり:

- candidate flavor は保持する
- 進行先は strict path に寄る

という 2 層読みが最も自然になる。

## 3. Provisional Meaning

現時点の safest provisional reading は次のように書ける。

```ts
type CombatDecisionConsumerResult = {
  accepted: boolean
  branch: number
  fallbackKind?: "strict-path"
  bypassesCurrentConsumeBelt?: boolean
  fallbackEntryFlavor?: "candidate"
  recomputesTargetSourceImmediately?: false
}
```

もちろん後で battle 本線が
strict path 入口で `targetSource` を上書きしている可能性は残る。

ただし current best bias としては、
**first fallback step ではまだ candidate flavor を保持する**
ほうが evidence に合う。

## implication for step 6

この整理を採ると、step 6 の debug bridge でも
`PTR` false 側を先に

- `fallbackEntryFlavor="candidate"`

として扱うのが自然になる。

つまり `ATK` と `PTR` の差分は、
false 側 policy そのものではなく
**fallback entry flavor**
にあると見るのが safest である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. strict-path fallback 後に `targetSource` が second step で上書きされるか
2. `candidateOffset` が false 側でも fallback branch の選択に残るか
3. `PTR` false 側の branch generator が `ATK` false 側より candidate-flavored か

ここが取れれば、`PTR` false 側は
**strict fallback with candidate-flavored entry**
としてかなり実装寄りに固められる。
