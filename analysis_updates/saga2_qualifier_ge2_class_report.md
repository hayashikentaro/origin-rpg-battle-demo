# Saga2 `qualifier >= 2` Class Report

## 要点

- current best reading では、`qualifier >= 2` は現時点でさらに細かい subtype を増やすより、**`0E/0F` family 共通の nonzero-consumable class** として持つのが最も安全である
- 理由は、今見えている evidence では `2`, `3`, ... の内部差より
  - `0` = special handling つき許可
  - `1` = blocked
  - `2+` = reject されない nonzero class
  という大きな 3 分類しか高確度に見えていないためである
- したがって `combatDecision` の current frontier も、まずは **blocked ordinal vs consumable nonzero class** を切るところまでで十分 battle semantics に近い

## relevant flow

```text
41D5: LD A,H
41D6: DEC A
41D7: JR Z,$41F1
41D9: INC E
...
41E6: LD A,(DE)
41E7: CP $FE
41E9: JR Z,$41ED
41EB: DEC A
41EC: LD (DE),A
```

この flow から直接分かるのは:

- `H == 1` だけ reject
- `H == 0` は reject されない
- `H >= 2` も reject されない

である。

## 1. なぜ `2+` をまとめるのか

現時点の evidence では、`2`, `3`, `4` などの間に

- 別 path
- 別 sentinel
- 別 table index

があるとはまだ見えていない。

したがって safest reading は、
`2+` を細かく分けるより

- **blocked ではない nonzero qualifier class**

としてまとめることである。

## 2. `0` との違い

`0` も reject されないが、`0F` では special fast-path を開く。

いっぽう `2+` は

- fast-path evidence がない
- reject もされない
- `41D5` 後に consume belt へ進む

という profile を持つ。

したがって `0` と `2+` を同じ「allowed」に潰すより、

- `0` = zero-state permission
- `2+` = nonzero-consumable class

と分けて持つのが安全である。

## 3. `0E` と `0F` での扱い

現時点で最も安全なのは、

- `0E + 2+`
- `0F + 2+`

のどちらも family-common な
**slow-path consumable**
として仮置きすることである。

もちろん後で `0E` と `0F` で後段 meaning 差が見つかる可能性はあるが、
今の evidence ではそこまで言えない。

## provisional semantics

現時点では次のように持つのが safest である。

```ts
type SpecialCandidateQualifier =
  | { value: 0; meaning: "allowed-zero"; variantPrivilege?: "zero-fast-path" }
  | { value: 1; meaning: "blocked-ordinal" }
  | { value: number; meaning: "consumable-nonzero-class" } // 2+
```

この shape なら、

- `0F` の zero-fast-path
- family-common blocked rule
- `2+` の共通 consumable class

を最小限の仮説で同時に持てる。

## implication for `combatDecision`

この整理を採ると、current `combatDecision` は

- `family-common accept/reject`
- `blocked ordinal`
- `0F` zero-fast-path privilege
- `consumable nonzero class`

までを暫定的に背後 semantics として持てる。

つまり step 6 の unresolved hook は、
単純な `shouldConsumeCounter` の yes/no より
**special-candidate family の local accept policy**
にかなり近づく。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `2+` の内部に true ordinal 差があるか
2. `0E + 2+` と `0F + 2+` が後段で truly 同一 consume semantics を持つか
3. この family が inventory 由来 candidate か action-path candidate か

ここが取れれば、`combatDecision` は
**family rule + blocked ordinal + nonzero consumable class**
としてかなり安定する。
