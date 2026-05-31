# SaGa2 `019E` Settled-Result Semantics Report

## Summary
- `019E` の直後に想定される未命名 local shadow/result slot は、単なる「seed byte の保管場所」より、**resolved seed byte を local settled result として確定する slot** とみるのが自然である。
- 理由は、`019E` が `611C` 成功直前の commit frontier にあり、`CALL $019E` の直後に `SCF ; RET` しているため、ここでは単純な中継より **gate 成功を成立させる状態確定** が起きている可能性が高いからである。
- したがって今後の探索では、shadow slot を「raw seed cache」ではなく、**resolved selection outcome を短期保持する settled local state** として扱うのが安全である。

## 1. Why “Raw Seed Cache” Is Too Weak

`019E` 直前までの流れは:

```asm
614A: CALL $5F07
614D: LD HL,$C73D
6150: RST $00
6151: LD A,(HL)
6152: CALL $019E
6155: SCF
6156: RET
```

ここで `A` に入っているのは
`C73D[index]` の resolved seed byte である。

もし `019E` の役割が単なる raw seed の退避だけなら、
`611C` 全体の成功/失敗境界としてはやや弱い。

しかし実際には:

- `FF8C == $FF` なら失敗
- `5F07` で remap
- `019E` 後に success

という構造なので、
`019E` では「seed を受け取った」以上の、
**selection 結果の確定**
が起きているとみるほうが自然。

## 2. Best Current Reading

もっとも自然な読みは次のようになる。

```ts
const token = resolveSelectionToken()
const localIndex = remapToken(token)
const seedByte = C73D[localIndex]
const settledResult = commitResolvedSelection(seedByte) // 019E
```

ここで `settledResult` は:

- unresolved token ではない
- source table entry そのものでもない
- battle-side applied state でもない

という条件を満たす、
**gate 成功を成立させる local settled state**
に近い。

## 3. What The Shadow Slot Likely Represents

現段階で最も安全な高位意味は次のどちらか。

1. resolved selection outcome  
   「今回の seeded candidate gate で採用された結果」
2. resolved seed application marker  
   「resolved seed byte が正しく消費・確定されたことを表す local mark/result」

どちらにせよ共通するのは、
それが **post-resolve / pre-apply の settled local state**
だという点である。

## 4. Why This Helps The Search

この見方を取ると、
次に探すべきものは
「`A` をそのままどこかへ書く byte」
より広く、

- result flag
- adopted local outcome
- settled candidate marker
- small shadow family

のような **結果確定側の local state**
になる。

つまり immediate target は
raw data sink ではなく、
**commit semantics を持つ local slot**
として探すほうが false positive を減らせる。

## 5. Updated Search Framing

今後の `019E` 探索は次の framing で持つのがよい。

1. `019E` は resolved seed byte を受け取る  
2. その副作用は inner-core local settled state を確定する  
3. その settled state が後段で `6157` apply や `C2F6` reflection に使われる  

## Implication
- 未命名 shadow slot は raw seed cache より settled local result slot とみるのが自然
- `019E` は単なる write helper ではなく local outcome commit helper の色が濃い
- 次の主戦場は inner core の local settled-state / result-marker 仮説である
