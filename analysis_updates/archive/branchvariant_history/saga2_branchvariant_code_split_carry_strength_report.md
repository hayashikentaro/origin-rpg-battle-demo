# saga2 branchVariant code split carry strength

## Summary

- `41E3-41E5` は current frontier で **strongest binding-candidate band**
- その direct local anchor gap を埋める本命軸は **`0E/0F` code-family split**
- current best reading では、この帯は raw `0/1` binding そのものを lock するにはまだ足りないが、**`0E/0F` split を strongest に carry する帯** とみるのが safest である

## Why carry strength matters

`41E3-41E5` をただの handoff edge とだけ呼ぶと、

- retained refinement は見えている
- しかし何が strongest semantic payload なのか

が曖昧に残る。

いま残っている gap は numeric binding そのものなので、ここでまず切るべきなのは

- raw `0/1` が strongest に何を背負っているか

である。

current frontier では、その答えは **`0E/0F` family split** に最も強く寄る。

## Current safest reading

`branchVariant` の current best semantics は次の通りである。

- PTR-only candidate-family lane refinement bit
- shared/default-leaning side と candidate-aware/strict-leaning sideの polarity
- 主軸は `0E/0F` special-candidate family difference
- qualifier shadow は secondary

この読みを `41E3-41E5` に戻すと、この帯が strongest に carry しているのは

- abstract side semantics
より先に
- **`0E/0F` code-family split**

だとみるのがもっとも自然である。

## What this does and does not prove

### Strong enough to say

- `41E3-41E5` は route-core terminal band である
- retained refinement handoff edge である
- `branchVariant` の strongest semantic payload は `0E/0F` code-family split である
- したがってこの帯は **code-split carry strongest band** と呼ぶのが safest

### Still not enough to say

- raw `0` が `0E` 側か `0F` 側か
- raw `1` がその反対側か
- そこから直ちに `shared/candidate` side へ numeric binding が lock される

つまり `41E3-41E5` は strongest carry band ではあるが、まだ **numeric binding confirmed band** ではない。

## Practical consequence

ここまで来ると next frontier はさらに狭くなる。

今後の問いは

- `41E3-41E5` で strongest に carry される `0E/0F` split が、raw `0/1` と local に stronger correspondence を持つか

の 1 点にかなり集約できる。

したがって current safest wording は、

- `41E3-41E5` = strongest binding-candidate band
- stronger local anchor gap remains
- strongest semantic payload = **`0E/0F` code-family split carry**

である。
