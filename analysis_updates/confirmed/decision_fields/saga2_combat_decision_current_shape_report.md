# Saga2 Combat Decision Current Shape Report

## 要点

- current best reading では、`combatDecision` はもはや単純な `counter gate` ではなく、**special-candidate family の local accept policy** として持つのが最も自然である
- その current shape は、少なくとも次の 4 層に整理できる
  1. family-common accept/reject
  2. `qualifier == 1` blocked ordinal
  3. `0F + qualifier == 0` zero-fast-path privilege
  4. `qualifier >= 2` consumable nonzero class
- さらに battle-side meaning は inventory raw item より **action-path candidate layer** に寄せて持つのが safest である

## 1. source layer

source は current best reading では

- `BattleActionHead` 直下

ではなく、

- `branch/path` が開いたあと
- `D?12..` repeated candidate entry family
- `code/qualifier` pair

にある local gate である。

つまり `combatDecision` は
**action-path candidate accept policy**
と読むのが最も自然になる。

## 2. family-common rule

`0E/0F` は別々の magic number ではなく、
同じ special-candidate family の 2 variant とみるのが current best reading である。

共通しているのは:

- qualifier-aware path を持つ
- `41D9-41EC` consume belt へ進入しうる
- blocked rule を共有する

という点である。

## 3. blocked ordinal

`41D5-41D7` の `DEC A ; JR Z` は、

- `qualifier == 1` だけ reject

という rule を示している。

したがって current frontier では、
`qualifier == 1` は

- reserved
- blocked
- temporarily disallowed

のような **blocked ordinal**
として扱うのが safest である。

## 4. zero-fast-path privilege

family 内の非対称性は `0F` にある。

- `0E + 0` は strict path を通る
- `0F + 0` は `41D9` へ直進する

このため `qualifier == 0` は family-common に allowed 側でも、
`0F` だけが持つ **variant-specific privilege** があるとみるのが自然である。

## 5. nonzero consumable class

現時点の evidence では、

- `2`
- `3`
- ...

の内部差はまだ見えていない。

したがって `qualifier >= 2` はまず
**family-common consumable nonzero class**
としてまとめるのが safest である。

## provisional API reading

この current shape を TypeScript API に近い形で書くと、
次のような意味づけが自然になる。

```ts
type CombatDecisionCurrentShape = {
  domain: "action-path-candidate-accept-policy"
  family: "special-candidate"
  blockedOrdinal: 1
  zeroVariantPrivilege: "0F-only"
  nonzeroConsumableClass: "2+"
}
```

もちろんこれは final semantics ではないが、
今の `pendingMeaning` をどう読むべきかの current best summary にはなる。

## implication for step 6

step 6 の unresolved hook は現在、

- `special_candidate_local_accept_policy`
- `special_candidate_candidate_accept_policy`

という provisional label に上がっている。

この label は、上の current shape とかなり整合する。

つまり step 6 は、
単なる stub を返している段階ではなく、
**family-common accept policy + variant privilege**
までを背後 semantics に持つ unresolved hook を返している段階に入っている。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `2+` の内部差が存在するか
2. `0E + 2+` と `0F + 2+` が truly 同一 consume semantics か
3. battle 本線でこの accept policy がどの局所 phase / branch opener に読まれるか

ここが取れれば、`combatDecision` は
current provisional shape から
first recovered battle semantics へかなり近づく。
