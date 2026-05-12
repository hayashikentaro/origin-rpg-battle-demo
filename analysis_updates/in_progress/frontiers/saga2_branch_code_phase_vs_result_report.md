# SaGa2 `selected branch code` Phase-vs-Result Report

## Summary
- `selected branch code` を local action-path selector とみるなら、次に切るべき差は **即時結果分岐 (`hit/miss`, `adopt/reject`)** か、**次の局所 phase 遷移** かである。
- 現時点では、`6157` が narrow bridge の直後に大きな staging を始めることを考えると、branchCode はまず **次に進む局所 phase / path** を示す code とみるほうがやや自然である。
- したがって次の consumer 観測では、単発の result flag より **next local phase selector** として読めるかを first line に置くのが安全である。

## 1. Two Close Readings

### A. Immediate result branch
- hit vs miss
- adopt vs reject
- success vs fail

### B. Next local phase selector
- 次に入る action resolve 小段階
- 次の apply sub-path
- player-local resolve 後の進行枝

どちらも local action-path selector の一種だが、
粒度が違う。

## 2. Why Phase Selector Gets Slight Priority

`6157` は entry 後に:

- `C200/C7EE`
- `D400/D500`
- dispatch / staging

をまとめて動かし始める。

この形だと、bridge で渡される 1byte は
単に yes/no を示すより、
**この player を次にどの局所 phase へ進めるか**
を決めるほうが自然である。

要するに、branchCode は
result そのものより
**result を受けた battle-side の進行先**
に近い可能性がある。

## 3. Why Immediate Result Still Remains

とはいえ second line としては、

- hit/miss
- adopt/reject

のような immediate result branch も残る。

`019E` 自体が success-side commit frontier なので、
その直後の 1byte がまず result polarity を示す、
という読みも十分 plausible である。

ただし今の最短目標は
`6157` 以降で battle 本線がどう進むかなので、
phase selector 側を first line に置くほうが consumer 探索に直結しやすい。

## 4. Safe Current Ranking

現時点の安全な優先順位:

1. next local phase selector
2. immediate result branch code
3. adopted-result classifier

## Implication
- `selected branch code` は first line で next local phase selector とみるのが自然
- immediate result branch は close second line
- 次の主戦場は `6157` 以降でこの 1byte がどの局所 phase 遷移を開くかの確認である
