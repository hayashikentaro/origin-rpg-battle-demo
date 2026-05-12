# SaGa2 `6157` Minimal-Handoff-Shape Report

## Summary
- `6157` entry 前に既にある local success-side state を最小形で持つなら、現時点では **`playerIndex + 1byte outcome-like state`** を first line、`playerIndex + short pair` を second line に置くのが最も自然である。
- 理由は、`019E` が resolved seed byte を受けて success-side local meaning を確定する commit frontier であり、その直後に `6157` へ渡る最小 handoff としては、まず 1byte の意味値を仮定するのが最も軽く、既存 evidence とも整合するからである。
- したがって次の consumer 探索では、`6157` entry を **`(player, outcomeLikeByte)`** で受ける narrow contract とみるのが safest first guess になる。

## 1. Minimum Inputs We Already Accept

既報から、`6157` entry で事前に存在するとみてよいのは:

1. `current player (C709)`
2. `611C` success を成立させた local success-side state

である。

この 2 本をどう具体化するかが今の論点になる。

## 2. Why One Byte Comes First

これまでの整理では:

- `019E` target は big struct ではない
- short settled-state family に寄る
- `outcome byte` 仮説が first line
- `marker + outcome byte` は second line

となっている。

このため `6157` へ渡る最小 handoff も、
まずは:

```ts
{ playerIndex, outcomeLikeByte }
```

の形を仮定するのが最も自然である。

## 3. Why Short Pair Still Remains

second line として残すべきものは:

- `outcome byte + adopted marker`
- `result code + validity flag`

のような short pair である。

ただしこれは、
`6157` entry を考える最初の仮説としては
1byte より一段重い。

したがっていまは:

1. まず 1byte outcome-like state
2. それで説明不足なら short pair

の順で持つのが安全。

## 4. Safe Current Contract

```ts
type MinimalPlayerScopedHandoff =
  | { playerIndex: number; outcome: number }
  | { playerIndex: number; outcome: number; adopted: boolean }
```

この程度なら、
アドレス未確定のままでも TypeScript core 側の中間表現として先に置ける。

## Implication
- `6157` entry の minimal handoff は `player + 1byte outcome-like state` を first line に置くのが自然
- short pair は second line で十分
- 次の主戦場は `6157` が受ける local state を 1byte outcome として説明できるかの確認である
