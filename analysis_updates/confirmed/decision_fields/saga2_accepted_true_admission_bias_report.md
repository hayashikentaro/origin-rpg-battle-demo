# Saga2 Accepted-True Admission Bias Report

## 要点

- current best reading では、`accepted=true` は **hit/damage 成功** より、まず **current local consume path への admission** とみるのが最も自然である
- 理由は、`accepted=false` 側がすでに  
  - current consume belt を開かない  
  - strict-path fallback に残る  
 という local gate semantics にかなり寄っているため、true 側も対称的に **current consume path を開く** と読むのが最小仮説になるからである
- したがって current best bias は、`accepted` は first-line では  
  - `false` = current consume path denied  
  - `true` = current consume path admitted  
 という **local consume-path admission bit** として持つのが safest である

## 1. Why Admission Fits Better Than Final Success

もし `accepted=true` を final hit / damage success のような大きい意味で読むなら、
それは current battle-side narrowing より一段広すぎる。

既報では `combatDecision` は:

- actor-local opener の narrow gate
- special-candidate family accept policy
- first consumer は accept/reject branch

までかなり狭まっている。

このため `accepted=true` の safest reading も、
まずは
**この local gate を通して current consume path を開く**
とみることである。

つまり `accepted` は final combat result ではなく、
その前段の local admission bit に留まる。

## 2. Why This Complements The False-Side Reading

false 側の current best reading はすでに

- current consume belt を開かない
- strict-path fallback に残る

という local gate semantics にかなり寄っている。

このとき true 側だけ別の大きい意味を持たせるより、

- `false` = deny
- `true` = admit

という対称形に保つほうが自然である。

つまり `accepted` は、
first-line では
**current local consume-path admission**
そのものとみるのが safest である。

## 3. Provisional Meaning

現時点の safest provisional reading は次のように書ける。

```ts
type CombatDecision = {
  // admit current local consume path?
  accepted: boolean
  branch: number
  branchVariant?: 0 | 1
}
```

ここで `accepted=true` の first-line meaning は

```ts
opensCurrentConsumePath === true
```

であり、
まだ hit/damage/order/drop の最終結果とは読まないほうが安全である。

## implication for step 6

この整理を採ると、step 6 の current provisional API では
`accepted`
を `shouldConsumeCounter` のような狭い値へ戻す必要もなく、
かといって final hit/miss へ広げすぎる必要もない。

最も自然なのは、
**local consume-path admission bit**
として持つことである。

これは current code shape にもかなりそのまま乗る。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. battle-side evidence が `accepted=true` を current consume path admission と読んでよいか
2. `accepted=true` の後に `branch` / `branchVariant` がどのように活性化されるか
3. `accepted=true` が second-line reopening をどの程度 shortcut するか

ここが取れれば、`accepted` の semantics は field-level でかなり recovered semantics に近づく。
