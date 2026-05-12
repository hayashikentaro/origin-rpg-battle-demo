# saga2 cross-family coverage surface

## Summary

- current preview matrix は、単なる command preview 群ではなく **cross-family coverage surface** として読むのが safest である
- current 最小有効セットは  
  **`ATK / ATKX / ATKS / DEF / PTR / ABLX0 / ABLS0 / ABL...`**
- これにより
  - attack family
  - ability family
  - candidate family
  - distinct local lane family
  
  を同じ 5-layer contract のもとで横並びに比較できる

## Family layout

### Attack family

- `ATK`
- `ATKX`
- `ATKS`

shared/default lane の target-mode contrast を担う family。

### Ability family

- `ABLX0`
- `ABLS0`
- `ABL...`

ability lane の target-mode contrast と arg/slot diversity を担う family。

### Candidate family

- `PTR`

candidate path / deferred-binding probe を担う family。

### Distinct local lane family

- `DEF`

attack/ability とは違う local lane の contrast を担う family。

## Why this is useful

この surface により current frontier では、

- same 5-layer shape
- different command families
- different target modes
- different path types

を同時に観測できる。

つまり current matrix は “preview list” ではなく、**semantic contract consistency surface** として機能している。

## Relation to deferred-binding policy

この cross-family surface は、

- `branchVariant 0|1` の exact naming を決めず
- `pointerFlavor` side semantics を保ち
- same-side carry semantics を維持したまま

広がっている。

したがって coverage widening が semantic overcommit になっていない、という点が重要である。

## One-line reading

current safest wording は、

**the preview matrix is now a cross-family coverage surface for the same 5-layer contract, not a binding-resolution surface.**

である。
