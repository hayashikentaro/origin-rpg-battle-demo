# saga2 preview matrix ability slot snapshot

## Summary

- current preview matrix は ability family でも **explicit target** と **slot fallback** の両方を持つようになった
- current 最小有効セットは  
  **`ATK / ATKX / ATKS / DEF / PTR / ABLX0 / ABLS0 / ABL...`**
- これにより attack family と ability family の両方で、same 5-layer contract を target-mode diversity と一緒に比較できる

## New probe: `ABLS0`

`ABLS0` は current frontier で、

- ability family
- shared/default pointerFlavor
- slot-fallback target mode

を観測する probe である。

つまり `ABLX0` が ability family の explicit probe なら、`ABLS0` はその slot-fallback counterpart である。

## Updated family symmetry

### Attack family

- `ATK` = shared/default + slot fallback
- `ATKX` = shared/default + explicit target
- `ATKS` = shared/default + alternate slot fallback

### Ability family

- `ABLX0` = ability path + explicit target
- `ABLS0` = ability path + slot fallback
- `ABL...` = ability arg/slot diversity

### Candidate family

- `PTR` = candidate path + candidate RNG + strongest deferred-binding probe

### Other lane family

- `DEF` = distinct local lane + explicit target

## Why this matters

current matrix は now

- attack family target-mode contrast
- ability family target-mode contrast
- candidate vs shared path contrast

を一つの operational surface の上で観測できる。

つまり matrix は current frontier では、単なる command list ではなく **cross-family coverage surface** になっている。

## Current safest reading

したがって current preview matrix snapshot は、

**deferred-binding policy を維持したまま attack/ability families の target-mode symmetry まで含んだ coverage surface**

と読むのが safest である。
