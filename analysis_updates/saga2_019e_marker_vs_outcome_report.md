# SaGa2 `019E` Marker-vs-Outcome Report

## Summary
- `019E` の immediate target を short settled-state family とみるなら、いま最も自然なのは **単なる raw seed byte 保存** より、`result marker` か `resolved local outcome byte` のどちらかで持つ読みである。
- この 2 つは厳密には違うが、どちらも **gate 成功を成立させる意味付きの short state** である点で一致している。
- したがって次の探索では、「`A` がどこへ入るか」だけでなく、**その byte が outcome を表すのか、adopt/validity を表す marker なのか** を同じ重さで持つのが安全である。

## 1. Why Raw Storage Is No Longer The Best First Guess

`019E` の位置は:

```asm
... C73D[index] -> A
CALL $019E
SCF
RET
```

であり、`611C` 成功を成立させる最後の境界にいる。

このため、`019E` がしていることを
単なる raw byte の保管とみるより、
**その byte を意味のある local result へ昇格させる**
とみるほうが自然になる。

## 2. Two Best Semantic Shapes

### A. result marker

例:

- resolved seed accepted
- current local candidate adopted
- commit succeeded

この読みでは、byte 自体の値より
**commit が通ったこと**
を表す local mark が中心になる。

### B. outcome byte

例:

- selected local outcome id
- resolved candidate outcome
- seed-derived local result code

この読みでは、
resolved seed byte が何らかの local outcome へ写像され、
その outcome が保持される。

## 3. Why Both Are Better Than A Big Family Guess

どちらの読みでも共通するのは:

- inner core に属する
- post-resolve / pre-apply にある
- short settled-state である
- `6157` や `C2F6` への後段反映の入力になる

という点である。

つまり次に狙うべきものは、
page-wide shadow record ではなく
**意味付きの short commit state**
である。

## 4. Safe Search Framing

今後の `019E` immediate target は、次の 2 本立てで持つのが安全。

```ts
type ImmediateCommitState =
  | { kind: "marker"; adopted: boolean; code?: number }
  | { kind: "outcome"; value: number }
```

必要ならこれに very small tuple を加えるが、
まず中心になるのはこの 2 種でよい。

## Implication
- `019E` target は raw seed cache より marker/outcome 寄りにみるのが自然
- 次の主戦場は `result marker` と `outcome byte` のどちらに近いかの観測である
- これで `019E` の local settled-state 仮説をさらに意味論側へ進められる
