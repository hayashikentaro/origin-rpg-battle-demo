# saga2 branchVariant binding subspan ranking

## Summary

- `41E3-41E9` は current best reading で **minimal branchVariant binding candidate cluster**
- その内部でも、raw `0/1` binding を strongest に運ぶ帯は均等ではない
- current safest ranking は、**`41E3-41E5` > `41E6` > `41E7-41E9`** である

## Ranking

### A-rank: `41E3-41E5`

- route-core terminal band
- retained refinement handoff edge
- first-line から second-line へ渡る前の **last compressed refinement state**

この帯は current frontier で、raw `branchVariant` binding を最も強く保持している候補である。  
理由は、まだ second-line visibility へ変換される前であり、**raw value と side semantics の距離が最も短い** と読めるからである。

### B-rank: `41E6`

- reopening / consume halo entry
- handoff 後の immediate boundary

ここは new semantic axis の生成点というより **boundary marker** と読むのが safest である。  
したがって raw binding を strongest に保持する本体というより、A-rank から C-rank へ移る **boundary witness** として重要である。

### C-rank: `41E7-41E9`

- first effective same-side visibility slot
- pointerFlavor pair の first visible landing

ここは visibility の主戦場としては最重要だが、raw numeric binding の主戦場としては一段下がる。  
理由は、この段ではすでに **same-side correspondence が public になる** いっぽう、raw `0/1` 自体は visible side pair によって読まれる後段になっているためである。

## Why this ranking is safest

current frontier の整理を重ねると、

- `41E3-41E5` は **retained refinement の last dense point**
- `41E6` は **handoff boundary**
- `41E7-41E9` は **same-side visibility point**

という役割差が最も自然である。

したがって

- binding を strongest に運ぶのは `41E3-41E5`
- carry continuity を示すのは `41E6`
- side visibility を示すのは `41E7-41E9`

と分けるのが safest である。

## Binding-ready / not-ready boundary

この ranking を前提にすると、current frontier の境界はかなり明確である。

### Already strong

- side semantics
- same-side correspondence
- remap-free carry bias
- `41E3-41E5` が strongest binding sub-span だという順位づけ

### Still missing

- `41E3-41E5` の中で raw `0/1` が named side に貼りつく **direct local anchor**
- あるいは `0E/0F` family split と raw `0/1` split の stronger same-band correspondence

つまり current best reading では、**A-rank sub-span は絞れたが、そこでも still direct lock evidence は不足** という形である。

## Practical consequence

今後 numeric binding をさらに詰めるなら、主戦場は `41E7-41E9` ではなく **`41E3-41E5`** に寄せるのが最も自然である。  
`41E7-41E9` は same-side visibility の確認点、`41E3-41E5` は binding lock evidence の本命帯、と役割分担をはっきり持つのが current safest policy である。
