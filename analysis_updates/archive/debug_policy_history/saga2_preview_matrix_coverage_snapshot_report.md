# saga2 preview matrix coverage snapshot

## Summary

- current preview matrix は deferred-binding policy を保ったまま、**target-mode diversity** と **command-class diversity** をかなり広く観測できる段階にある
- 現在の最小有効セットは  
  **`ATK / ATKX / ATKS / DEF / PTR / ABL...`**
- これにより same 5-layer contract が
  - shared/default path
  - candidate path
  - explicit target
  - slot fallback
  - ability path
  
  を跨いでも崩れないかを front/selfcheck の両方で見られる

## Current matrix roles

### `ATK`

- shared/default lane
- slot fallback target
- no candidate RNG

これは current shared/default baseline の主観測点である。

### `ATKX`

- shared/default lane
- explicit target
- no candidate RNG

これは `ATK` と同じ lane / route / pointer を保ちながら、terminal target mode だけを explicit に変える comparison probe である。

### `ATKS`

- shared/default lane
- slot fallback target with different slot
- no candidate RNG

これは `ATK` と同じ semantic core のまま、slot fallback downstream だけを 1 段変える probe である。

### `DEF`

- distinct localPath / branch family
- explicit target
- no candidate RNG

これは attack 系とは違う actor-local lane を見る probe である。

### `PTR`

- candidate path
- candidate RNG 07/08 consumption
- branchVariant / pointerFlavor の strongest semantic probe

これは deferred-binding contract の主観測点であり、matrix から外さないのが safest である。

### `ABL...`

- ability class diversity
- arg / slotIndex diversity
- actor-local bridge の generality probe

これは semantic core が attack 以外でも保たれるかをみる coverage set である。

## Why this snapshot matters

この matrix は、ただ command 数を増やしただけではない。  
current frontier では次の 3 層を同時に観測できる。

1. lane / refinement (`branch`, `branchVariant`)
2. transfer / provenance (`postBranchRoute`, `pointerFlavor`)
3. terminal target mode (`target`, `targetSource`)

しかも `branchVariant` numeric binding を lock せずに、それができている。

## Current safest reading

したがって current preview matrix snapshot は、

**coverage widening under deferred-binding policy**

として読むのが safest である。

つまり matrix の目的は

- exact numeric binding を決めることではなく
- same 5-layer contract が多様な command/target mode でも崩れないことを観測すること

にある。
