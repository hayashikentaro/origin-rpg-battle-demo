# SaGa2 `selected branch code` Shape Report

## Summary
- `outcomeLikeByte` を first line で `selected branch code` とみるなら、次に整理すべきなのは **その code が battle-side で何を分岐させる型か** である。
- 現時点では、これは page-wide slot 番号より、**1 player 分の action resolve の局所分岐** を進める 1byte code とみるのが最も自然である。
- したがって次の consumer 観測は、「どのページに書かれたか」より **どの処理枝・どの局所 phase を選ばせる code か** に寄せるのが安全である。

## 1. What The Branch Code Is Unlikely To Be

現時点で優先度を下げてよい読み:

- page index
- wide battle-page selector
- full command descriptor
- visible UI mode code

理由は、`6157` entry の narrow bridge が
`player + outcomeLikeByte`
という最小形で持てているからである。

## 2. What It Is More Likely To Be

いま自然な branch code の型は次のどれか。

1. action-path selector  
   その player の行動解決で次に入る局所分岐
2. apply-mode selector  
   `6157` がどの apply/staging 処理を起動するか
3. adopted-result classifier  
   採用済み local result の種類を示す short code

共通するのはすべて、
**1 player 分の battle resolve を前へ進める局所 code**
だという点である。

## 3. Why This Matters For Porting

移植で必要なのは、
最初から ROM 上の page layout を再現することではなく、

```ts
battle.applyResolvedOutcome(playerIndex, branchCode)
```

の `branchCode` が
何の意味で action resolve を前進させるかである。

この意味が分かれば、
TypeScript core では branch-driven な中間表現を先に置ける。

## 4. Safe Current Bias

現時点の bias は次のとおり。

1. local action-path selector
2. apply-mode selector
3. adopted-result classifier

この 3 つはどれも近いが、
最初の観測軸としては
**局所 action resolve 分岐**
を first line に置くのが自然。

## Implication
- `selected branch code` は wide page selector ではなく local action resolve code とみるのが自然
- 次の主戦場は `6157` 以降でこの 1byte がどの局所分岐を開くかの確認である
