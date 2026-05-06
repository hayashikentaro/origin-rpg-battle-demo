# saga2 preview readability policy

## Summary

- preview matrix が cross-family coverage surface へ広がったことで、readability policy も current frontier では重要な contract になっている
- current safest policy は、expanded probe list を **family-aware** に見せることだ
- そのため current UI/debug side では
  - stable label lookup
  - family prefix
  - fixed semantic field order
  
  の 3 本を readability contract として持つのが自然である

## 1. Stable label lookup

canonical probe は fixed index ではなく

- `ATK`
- `PTR`

のような stable label で引く。

これにより matrix growth があっても canonical display point が壊れない。

## 2. Family prefix

expanded matrix では probe 数が増えるため、label だけでは family grouping が見えにくくなる。  
したがって current safest UI policy は、preview/debug lines に

- `[ATK]`
- `[DEF]`
- `[CND]`
- `[ABL]`

の family prefix を付けることである。

これにより

- canonical probe
- expansion probe
- family relation

を短い行の中でも読み分けやすくできる。

## 3. Fixed semantic field order

family prefix を入れても semantic order は変えない。

current safest order は引き続き

**`branch -> branchVariant -> postBranchRoute -> pointerFlavor -> target`**

である。

つまり readability policy は、semantic order を壊さずに family grouping を追加する方針である。

## Why this matters

current matrix は単なる preview list ではなく **cross-family coverage surface** なので、

- coverage widening
- canonical probe stability
- visual scannability

を同時に満たす必要がある。

family-aware readability policy は、そのための実務上の guardrail と読める。

## One-line reading

current safest preview readability policy is:

**keep semantic order fixed, select canonical probes by label, and add family prefixes so matrix growth does not reduce scannability.**

## Relation to the wider contract

この policy は purely cosmetic ではない。  
deferred-binding contract と operational coverage surface が already stable だからこそ、次の主題は “どこまで広げられるか” と同時に “どこまで読みやすく保てるか” になっている。
