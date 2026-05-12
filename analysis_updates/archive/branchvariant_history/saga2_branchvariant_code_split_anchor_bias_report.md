# saga2 branchVariant code split anchor bias

## Summary

- `41E3-41E5` は current frontier で **strongest binding-candidate band**
- この帯の中で direct local anchor gap を埋める本命軸は、current best reading では **`0E/0F` special-candidate family split** に寄る
- つまり raw `0/1` binding を最短で lock できる可能性が高いのは、pure side naming より **code-family split anchoring** である

## Why the code split is the best anchor candidate

current frontier で `branchVariant` はすでに次のように読めている。

- PTR-only candidate-family lane refinement bit
- semantic polarity は `shared/default-leaning` と `candidate-aware/strict-leaning`
- 主軸は **`0E/0F` family difference**
- qualifier `1` blocked ordinal は secondary shadow

この時点で、`branchVariant` の意味を strongest に規定しているのは pure qualifier ではなく **code-led split** である。

したがって `41E3-41E5` の direct local anchor gap を埋める最短線も、

- raw `0/1` がどちらの code-family side に貼りつくか

を見る方向に寄るのが自然である。

## Competing anchor options

### Option A: side-semantic direct anchor

- raw `0/1` が `shared/default-leaning` と `candidate-aware/strict-leaning` のどちらかへ直接貼りつく

これは最終的には欲しいが、current frontier では naming layer が一段抽象的で、局所 anchor としては少し遠い。

### Option B: `0E/0F` family split anchor

- raw `0/1` split が `0E/0F` family split に stronger に対応する

これは `branchVariant` の current best reading の主軸と一致しており、局所 anchor として最も自然である。

### Option C: qualifier-class anchor

- raw `0/1` split が qualifier `0 / 1 / 2+` の分類に stronger に対応する

current frontier では qualifier は secondary modifier / shadow として読んでいるため、最初の direct anchor 候補としては一段弱い。

## Current safest ranking

`41E3-41E5` の direct local anchor gap を埋める候補順位は、current safest stance では次の通りである。

1. **`0E/0F` family split anchor**
2. side-semantic direct anchor
3. qualifier-class anchor

つまり next frontier では、`41E3-41E5` の中で何より先に **code-family split が strongest に carry されているか** を見るのが自然である。

## Practical consequence

今後 `branchVariant 0/1` の numeric binding を lock するなら、まず聞くべき問いは

- `41E3-41E5` は raw `0/1` と `0E/0F` family split を stronger に結びつける帯か

である。

ここで yes に届けば、その次に

- どちらの raw value がどちらの code-family side に貼りつくか

を詰めればよい。

したがって current safest wording は、

- `41E3-41E5` = strongest binding-candidate band
- unresolved gap = direct local anchor gap
- best anchor candidate = **`0E/0F` code-family split**

である。
