# SaGa2 `selected branch code` Consumer-Bias Report

## Summary
- `selected branch code` を local action resolve code とみるなら、現時点では **apply-mode selector** より **action-path selector** に少し重みを置くのが自然である。
- 理由は、`6157` が page-wide staging を内部で行う前に、まず「この player の結果をどの局所処理枝へ進めるか」を知る必要があると読むほうが狭い bridge 仮説と整合するからである。
- したがって次の consumer 観測は、`outcomeLikeByte` が `6157` の内部 mode を選ぶ code かどうかより、**battle action resolve の局所 branch/input meaning** を与える code かどうかを first line に置くのが安全である。

## 1. Two Close Reads

残っている近い読みは次の 2 つ。

1. action-path selector  
   その player の action resolve が次に入る局所分岐
2. apply-mode selector  
   `6157` が後段 staging/apply のどの型を起動するか

どちらも plausible だが、同じ重さではない。

## 2. Why Action-Path Comes First

いまの narrow bridge は:

```ts
applyResolvedOutcome(playerIndex, branchCode)
```

のように見えている。

このとき最小限に必要なのは、
page 構築より先に
**その player の結果を battle 本線のどの局所枝へ送るか**
である可能性が高い。

つまり `branchCode` はまず:

- hit / miss 側
- adopt / reject 側
- next local phase

のような **局所 action resolve の分岐** を示すと読むのが一段自然になる。

## 3. Why Apply-Mode Still Remains

second line として `apply-mode selector` を残す理由もある。

`6157` 自体が:

- `C200/C7EE`
- `D400/D500`
- dispatch / staging

を内部で行うからである。

したがって branchCode が
`6157` 内部の apply pattern を変える可能性はまだある。

ただし今の最短目標は page 内部の差分より、
**battle 本線がその byte を最初にどう意味づけるか**
なので、優先順位は一段下げてよい。

## 4. Safe Current Ranking

現時点の安全な優先順位:

1. local action-path selector
2. apply-mode selector
3. adopted-result classifier

## Implication
- `selected branch code` は first line で local action resolve branch を開く code とみるのが自然
- apply-mode 仮説は second line に下げてよい
- 次の主戦場は `6157` 以降でこの 1byte が最初にどの局所分岐を選ばせるかの確認である
