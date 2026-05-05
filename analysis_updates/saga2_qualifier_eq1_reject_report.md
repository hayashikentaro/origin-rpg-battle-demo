# Saga2 `qualifier == 1` Reject Report

## 要点

- current best reading では、`41D5-41D7` の `DEC A ; JR Z,$41F1` による reject は  
  **`qualifier == 1` が special-candidate family における reserved / blocked ordinal state**  
  を表しているとみるのが最も自然である
- これは pure boolean の「有効/無効」より、`0`, `1`, `2+` に意味差のある **small ordinal qualifier** とみるほうが evidence に合う
- したがって `combatDecision` の unresolved source も、`counter` そのものではなく **candidate-entry family の ordinal qualifier gate** にかなり近い

## relevant flow

```text
41CD: CP $0F
41CF: JR NZ,$41D9
41D1: LD A,H
41D2: OR A
41D3: JR Z,$41D9
41D5: LD A,H
41D6: DEC A
41D7: JR Z,$41F1
```

ここで `41D5-41D7` は

- `H == 1` のときだけ reject
- `H == 0` や `H >= 2` では reject しない

という形に見える。

## 1. なぜ boolean より ordinal なのか

もし `H` が単純な有効/無効 bit なら、

- `0 = false`
- `1 = true`

のどちらかで一様に分岐すれば足りる。

しかしここでは、

- `0` は `0F` の fast-path を開く
- `1` は reject
- `2+` は reject しない

という **3 区分以上** が見えている。

このため safest reading は、
`H` を boolean より

- ordinal qualifier
- count-like qualifier
- subtype-local state byte

として扱うことである。

## 2. `qualifier == 1` の位置づけ

現時点で battle-side の具体名は未確定だが、
`qualifier == 1` のふるまいは少なくとも

- fast-path 許可ではない
- empty sentinel でもない
- 一時的に consume path を閉じる

という profile を持つ。

したがって provisional semantics としては、

- reserved
- blocked
- single-instance-disallowed

のような **special family 内の禁止 ordinal**
とみるのが最も安全である。

## 3. `0` と `2+` が両方許可される意味

`0F` では `qualifier == 0` だけが `41D9` へ直進し、
それ以外は `41D5` に落ちる。

そのうえで `41D5-41D7` により

- `1` は reject
- `2+` は継続

となるため、current best reading では:

- `0` = special fast-path available
- `1` = blocked ordinal
- `2+` = non-fast-path but still consumable

という 3 区分がもっとも自然である。

## provisional semantics

現時点では次のように持つのが安全である。

```ts
type SpecialCandidateQualifier =
  | { value: 0; meaning: "fast-path-allowed" }
  | { value: 1; meaning: "blocked-ordinal" }
  | { value: number; meaning: "slow-path-consumable" } // 2+
```

もちろん battle 実意味がそのまま
`fast/blocked/slow`
とは限らないが、
少なくとも local gate の形としてはこの 3 分類が evidence に最もよく合う。

## implication for `combatDecision`

この整理を採ると、current `combatDecision` は

- `shouldConsumeCounter`

だけではなく、

- `special family qualifier gate`
- `blocked ordinal reject`

のような source semantics を背後に持つとみるのが自然になる。

特に `PTR` 系 path の unresolved gate は、
candidate-selection のあとに
`special family + qualifier`
を通る local branch として読むとかなり整合する。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `qualifier == 1` が owner / count / availability のどれに最も近いか
2. `qualifier >= 2` が単なる「残数あり」なのか、別 subtype ordinal を含むのか
3. `0E` でも `qualifier == 1` reject が同じ意味で働くか

ここが取れれば、`combatDecision` は
`special-candidate family gate`
からさらに
**blocked-ordinal aware local gate**
へ一段具体化できる。
