# SaGa2 Handoff Edge Wording Bias Report

## Question

`41E3-41E5` を current best reading では
retained refinement handoff edge と読んでいるが、
この帯の中でどこまでを exact route-core 終端と呼ぶのが safest か。

## Current best reading

現時点では、`41E3-41E5` は
**single exact instruction point** として固定するより、
**route-core terminal band**
とみるのが safest である。

つまり current best wording では、

- `41D9-41E2` = route material gathering
- `41E3-41E5` = route-core terminal band / retained refinement handoff edge
- `41E6` = reopening / consume halo entry

という 3 分割が最も自然である。

## Why terminal band is better than exact point

current frontier では `41E3-41E5` 帯の役割自体はかなり安定しているが、

- `41E3`
- `41E4`
- `41E5`

のどれを single exact route-core point と呼ぶかまではまだ direct evidence が薄い。

そのため safest wording は、
exact point を premature に固定するより
**terminal band**
と呼んで幅を持たせることである。

## Why it is still narrower than the whole nucleus

いっぽう `41D9-41E5` 全体を terminal band と呼ぶのは広すぎる。

既報どおり current best reading では、

- `41D9-41E2` は material gathering
- `41E3-41E5` が handoff

という internal split がかなり自然である。

したがって safest wording は、
**`41D9-41E5` nucleus の後半 terminal band**
として `41E3-41E5` を持つことである。

## Implication for `postBranchRoute`

この wording を `postBranchRoute` に戻すと、
これは依然として

- alignment-transfer core
- lane-transfer core

として読めるが、その battle-side exact anchoring は
**single point より terminal band**
として表現するのが current best reading に合う。

つまり今後の解析では、
`postBranchRoute` の role 自体より
この band 内の finer internal timing を詰めることが主課題になる。

## Current safest wording

現時点の safest wording は次のとおり。

- `41E3-41E5` = route-core terminal band / retained refinement handoff edge

## Remaining uncertainty

未確定なのは、

- `41E3` 側がまだ route-core 色をどの程度残すか
- `41E5` 側がどの程度 halo entry に近いか

の finer nuance である。

ただし current frontier では、
**exact point より terminal band**
と呼ぶのが最も安全である。
