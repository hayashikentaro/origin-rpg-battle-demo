# Saga2 PTR Candidate-Offset Fallback Bias Report

## 要点

- current best reading では、`PTR` false 側の strict-path fallback では **`candidateOffset` が即座に無意味化される** より、まず **candidate-flavored fallback branch の選択材料として残る** とみるのが最も安全である
- 理由は、`PTR` path の path-specific 差分として `targetSource="candidate"` だけでなく `candidateOffset` も強く観測されており、false 側で candidate flavor を保持するなら offset だけを first fallback step で切り捨てる根拠もまだ弱いからである
- したがって current best bias は、`PTR` false 側は  
  - shared false-side policy  
  - strict-path fallback  
  - candidate-flavored fallback entry  
  - offset-aware first fallback  
  を持つ、という形になる

## 1. Why Offset Preservation Is More Natural Than Immediate Discard

もし `PTR` false 側で `candidateOffset` が first fallback step から完全に無効化されるなら、
candidate path 由来の差分は `targetSource` ラベルだけに縮退することになる。

しかし current skeleton では `PTR` の path-specific 情報は

- `didConsumeCandidateRng`
- `targetSource="candidate"`
- `candidateOffset`

の 3 本がまとまって初めて意味を持つ。

このため safest reading は、
false 側でも first fallback step では
**offset-aware candidate flavor**
をまだ保持するとみることである。

## 2. Why This Still Fits Strict-Path Bias

既報では `PTR` false 側の first-line meaning は

- `accepted=false`
- `bypassesCurrentConsumeBelt=true`
- `fallbackKind="strict-path"`

で整理している。

ここで `candidateOffset` を残すというのは、
strict path そのものを否定する話ではない。

むしろ:

- entry flavor は candidate 由来
- 進行 policy は strict path

という 2 層構造をさらに細かくしただけである。

つまり current best reading は、

- policy layer = strict fallback
- entry flavor layer = candidate
- entry detail layer = offset-aware

という 3 層で持つのが自然になる。

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
}
```

もちろん後段の stricter local phase で
`candidateOffset` が再計算・正規化・破棄される可能性は残る。

ただし current best bias としては、
**first fallback step では offset-aware candidate flavor をまだ持つ**
ほうが evidence に合う。

## implication for step 6

この整理を採ると、step 6 の debug bridge でも
`PTR` false 側を単に

- `fallbackEntryFlavor="candidate"`

とだけ置くより、

- candidate flavor
- candidate offset persistence bias

を内側の仮説として持っておくほうが battle-side reopening に強い。

つまり `PTR` false 側は current best reading では
**strict fallback with offset-aware candidate entry**
と要約できる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. strict-path fallback の second step でも `candidateOffset` が branch selector に残るか
2. `candidateOffset` が target routing ではなく branch generator にだけ残る可能性があるか
3. `ATK` false 側との差が `targetSource` より `candidateOffset` に強く出るか

ここが取れれば、`PTR` false 側は
**strict fallback with offset-aware candidate entry**
としてかなり実装寄りに固められる。
