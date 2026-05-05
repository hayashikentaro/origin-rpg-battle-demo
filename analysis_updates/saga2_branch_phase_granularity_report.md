# SaGa2 `branch` Phase-Granularity Report

## Summary
- `decodeResolvedOutcome(player, outcomeLikeByte)` が返す `branch` を考えるとき、次に重要なのは **その branch がどの粒度の local phase を表すか** である。
- 現時点では、これは battle round 全体の大きい phase より、**1 player 分の action resolve を一段先へ進める小さい phase/code** とみるのが最も自然である。
- したがって次の解析では、`branch` を global battle phase や UI state と結びつけるより、**per-actor local resolve step** として consumer を探すのが安全である。

## 1. What `branch` Is Unlikely To Mean

優先度を下げてよい読み:

- battle round 全体の大 phase
- scene / UI mode
- page-wide staging mode
- global turn controller state

理由は、いま見えている narrow bridge が
`playerIndex + outcomeLikeByte`
という 1 player 単位の handoff だからである。

## 2. More Natural Granularity

いま自然な粒度は次のようなもの。

1. per-actor local resolve step  
   その player の action resolve が次に入る小段階
2. per-actor apply sub-branch  
   その player の battle-side apply の分岐
3. per-actor adopted outcome class  
   採用済み結果に応じた小分岐

共通点はどれも、
**1 player の処理を次の局所段階へ進める**
ということ。

## 3. Why This Granularity Fits The Current Model

現状の読みは:

```ts
const outcomeLikeByte = commitResolvedSelection(seedByte) // 019E
const branch = decodeResolvedOutcome(playerIndex, outcomeLikeByte)
advanceActionPhase(playerIndex, branch)
```

ここで `advanceActionPhase` が前へ進める対象は、
まずその player の局所処理であるほうが自然である。

もし `branch` が大域 phase を直接選ぶなら、
`C709` で player を固定して `611C -> 6157` を回す親ループ構造と
少し噛み合いにくい。

## 4. Practical Search Consequence

次に consumer を見るときの first-line question は:

1. この `branch` は actor-local の小分岐か  
2. その分岐は hit/miss より一段広い action resolve step か  
3. その後に初めて larger staging/page effect へつながるか  

## Implication
- `branch` は first line で per-actor local resolve step とみるのが自然
- 次の主戦場は `advanceActionPhase(player, branch)` に相当する actor-local consumer
- これが取れると `battle` 側の中間 state がかなり API 化しやすくなる
