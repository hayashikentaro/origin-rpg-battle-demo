# Saga2 Combat Decision Reject/Fallback Report

## 要点

- current best reading では、`accepted=false` は **即座に battle-wide reject/fail 終了** というより、まず **current candidate を通さず strict / alternate local path へ落とす fallback** とみるのが最も安全である
- 理由は、`combatDecision` の current shape が `blocked ordinal` / `zero-fast-path privilege` / `consumable nonzero class` という **candidate policy** に寄っており、wide phase 終了より先に local opener 内の path 選択へ効くほうが自然だからである
- したがって `accepted=false` の first-line 意味は、`hard reject` より **candidate reject with local fallback** に置くのが safest provisional reading になる

## 1. Why Immediate Hard Reject Is Too Strong

もし `accepted=false` が即時の hard reject なら、
現在までの evidence はもっと早い段で

- wide fail branch
- global abort
- page-wide clear

のような強い side effect を示していてよい。

しかし current narrowing で見えているのは、

- `41C4-41D8` の special-candidate gate
- `41D9-41EC` の consume belt
- actor-local opener の narrow branch

であって、まずは **local candidate policy**
として読むほうが整合する。

## 2. Why Fallback Is More Natural

現在の family semantics は:

- `0F + 0` = zero-fast-path privilege
- `0E + 0` = strict allowed zero
- `1` = blocked ordinal
- `2+` = consumable nonzero class

である。

この語彙は yes/no より、

- shortcut に進める
- strict path に残す
- blocked candidate とみなす

といった **local path fallback**
のほうへ自然につながる。

特に `0F` が fast-path を持ち、`0E` は strict path を通るという非対称性は、
`accepted=false` をただの fail にするより
**shortcut を取れず strict/alternate path に落ちる**
と読むほうが筋がよい。

## 3. Provisional Meaning

現時点では、`accepted=false` の safest reading は次のどちらかである。

1. blocked candidate  
   current candidate entry を通さない
2. fallback to strict/alternate local path  
   current shortcut/privileged pathを閉じて別 local path へ落とす

この 2 つのうち、battle API へ近い first-line wording は
**candidate reject with local fallback**
である。

## provisional API reading

現時点の provisional shape は次のように持つのが安全である。

```ts
type CombatDecisionConsumerResult = {
  accepted: boolean
  branch: number
  fallbackKind?: "strict-path" | "alternate-candidate-path"
}
```

もちろん `fallbackKind` 自体はまだ未確定だが、
少なくとも `accepted=false` を
`battle ends here`
とみなすより、
**local opener の中で次の path を選び直す**
と持つほうが現状 evidence に近い。

## implication for `combatDecision`

この整理を採ると、current `combatDecision` は

- accepted=true なら consumable / shortcut 許可側
- accepted=false なら blocked / fallback 側

という **local candidate policy bifurcation**
として扱える。

つまり `combatDecision` の first consumer は、
単なる boolean reader ではなく
**accept/fallback branch opener**
とみるのが最も自然になる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `accepted=false` が strict path 残留と alternate candidate path のどちらに近いか
2. `0E + 0` と `0F + nonzero` が同じ fallback branch に流れるか
3. `accepted=false` のとき consume belt (`41D9-41EC`) を完全に回避するか

ここが取れれば、`combatDecision` は
**accepted + branch + fallback flavor**
までかなり実装寄りに持っていける。
