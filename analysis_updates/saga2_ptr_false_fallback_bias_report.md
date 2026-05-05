# Saga2 PTR False-Fallback Bias Report

## 要点

- current best reading では、`PTR` (`07/08` candidate-selection path) の false 側 fallback も、**alternate-candidate-path** より **strict-path** に一段重みを置くのが最も自然である
- 理由は、`PTR` が違うのは candidate source の作り方であって、最終的にかかる `combatDecision` は shared special-candidate accept policy とみるのが safest だからである
- したがって current best bias は、`PTR` false 側も  
  - consume belt を回避し  
  - strict-path fallback を first line に持つ  
 という形になる

## 1. Why PTR Should Share The Same False-Side Bias

既報では `PTR` は:

- slot `07/08` を使って candidate source を構築する
- `targetSource="candidate"` を持つ
- `candidateOffset` を返す

という path-specific 特徴を持つ。

しかし `combatDecision` 自体の current reading は、
これらの source 差分より後ろにある

- special-candidate family
- blocked ordinal
- zero-fast-path privilege
- consumable nonzero class

という shared policy に寄っている。

したがって false 側の意味も、
まずは `ATK` と共通の accept/fallback 読みを採るのが自然になる。

## 2. Why Strict Path Still Beats Alternate Candidate

`PTR` の false 側で alternate candidate を first line にしたくなる理由は、
もともと path 自体が candidate-selection 由来だからである。

ただし current evidence では、
その candidate-selection は **source の組み方** を説明するものであって、
false 側の accept policy まで別物にする根拠にはまだ弱い。

一方で、family semantics 側では

- `0F + 0` = shortcut
- `0E` / `0F + nonzero` = strict/slow-path

という非対称性が見えている。

この非対称性は `PTR` にもそのまま乗るとみるほうが
最小仮説で済む。

したがって safest ranking は:

1. strict-path fallback
2. alternate-candidate-path

のまま維持するのがよい。

## 3. What Differs For PTR

`PTR` false 側で path-specific に残る違いは、
fallback の **種類** そのものより、

- strict path へ戻る entry point
- fallback 後に再利用される candidate/source scratch
- target routing の再計算有無

のような **entry flavor**
にあるとみるのが自然である。

つまり:

- policy は shared
- fallback entry flavor は path-specific

という 2 層構造で持つのが safest である。

## provisional API reading

現時点では次のように持つのが安全である。

```ts
type CombatDecisionConsumerResult = {
  accepted: boolean
  branch: number
  fallbackKind?: "strict-path" | "alternate-candidate-path"
  bypassesCurrentConsumeBelt?: boolean
  fallbackEntryFlavor?: "local" | "candidate"
}
```

そして current best bias は:

```ts
accepted === false
bypassesCurrentConsumeBelt === true
fallbackKind === "strict-path"
fallbackEntryFlavor === "candidate" // PTR only
```

である。

## implication for step 6

この整理を採ると、step 6 では

- `ATK`
- `PTR`

の false 側を別 semantics として分ける必要はなく、
shared な `combatDecision` を保ったまま
`fallbackEntryFlavor`
だけ path-specific に持てば十分になる。

これは current TypeScript skeleton にかなりよく噛み合う。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `PTR` false 側で strict-path fallback 後に `targetSource` が再計算されるか
2. `PTR` false 側が `ATK` false 側と同じ branch generator を使うか
3. `PTR` true 側だけ current consume belt へ shortcut 的に入りやすいか

ここが取れれば、`combatDecision` は
**shared false-side policy + path-specific entry flavor**
としてかなり実装寄りに固められる。
