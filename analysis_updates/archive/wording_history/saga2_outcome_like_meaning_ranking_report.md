# SaGa2 `outcomeLikeByte` Meaning-Ranking Report

## Summary
- `outcomeLikeByte` の first consumer 意味として現時点で最も自然なのは、**selected branch code** か **adopted result byte** であり、`success-qualified local result` はそれらを少し抽象化したまとめ方として持つのが安全である。
- この 2 つのうち、いま一段だけ重みを置くなら **selected branch code** を first line、`adopted result byte` を second line に置くのが自然である。
- 理由は、`6157` が player-scoped outcome relay であり、その直後の battle-side consumer は large record の完全解釈より、まず「どの処理枝へ進むか」を必要とする可能性が高いからである。

## 1. Three Candidate Meanings

既報で残っている候補は次の 3 つ。

1. adopted result byte  
   採用済みの local result 値
2. selected branch code  
   次に入る action resolve の処理枝を示す 1byte code
3. success-qualified local result  
   成功時のみ有効な局所結果という抽象的表現

このうち 3 は 1 と 2 を束ねる上位概念として便利だが、
次の実探索では 1 か 2 に寄せたほうが効率的である。

## 2. Why Branch Code Gets Slight Priority

現在の narrow bridge は:

```ts
commitResolvedSelection(seedByte)   // 019E
applyResolvedOutcome(player, outcomeLikeByte) // 6157 entry
```

と読める。

`6157` entry 直後に欲しいのは、
page-wide state 全体より
**battle-side がこの player をどう扱うかの分岐情報**
である可能性が高い。

そのため `outcomeLikeByte` は、
まず

- branch selector
- action-path selector
- adopted branch code

のような **処理枝を決める code**
として読むのが一段自然になる。

## 3. Why Adopted Result Still Remains Strong

ただし `019E` は resolved seed byte を受けて
success-side local meaning を確定する commit frontier なので、
その値がそのまま

- adopted local result
- resolved outcome value

として保持される可能性も強い。

したがって `selected branch code` を first line にしても、
`adopted result byte` は very close second line に残すべきである。

## 4. Safe Current Ranking

現時点の安全な優先順位:

1. selected branch code  
2. adopted result byte  
3. success-qualified local result (umbrella reading)

## 5. Search Consequence

次に consumer 側を見るときは、
まず次の問いを当てるのがよい。

1. この 1byte は「どの処理枝へ進むか」を決めているか  
2. それとも「採用済み local result 値」そのものか  
3. 両方の性質を併せ持つ short code か  

## Implication
- `outcomeLikeByte` は first line で selected branch code とみるのが自然
- adopted result byte はほぼ同等の second line
- 次の主戦場は `6157` 以降でこの 1byte が branch/input meaning として読まれるかの確認である
