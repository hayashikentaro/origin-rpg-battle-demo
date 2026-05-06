# saga2 preview matrix ability explicit snapshot

## Summary

- current preview matrix は target-mode diversity を attack 系だけでなく **ability path** にも広げた
- 現在の最小有効セットは  
  **`ATK / ATKX / ATKS / DEF / PTR / ABLX0 / ABL...`**
- これにより same 5-layer contract が
  - attack shared/default path
  - candidate PTR path
  - defend path
  - ability path
  - explicit target
  - slot fallback
  
  を跨いでも保たれることを front/selfcheck の両方で見られる

## New probe: `ABLX0`

`ABLX0` は current frontier で、

- ability lane/path
- explicit target mode
- no candidate RNG

を同時に観測する explicit ability probe である。

これは `ABL...` と同じ ability family に属しつつ、target terminal mode だけを explicit 側へ振る comparison probe として機能する。

## Updated matrix roles

### Attack family

- `ATK` = shared/default lane + slot fallback
- `ATKX` = shared/default lane + explicit target
- `ATKS` = shared/default lane + alternate slot fallback

### Non-attack family

- `DEF` = distinct local lane + explicit target
- `PTR` = candidate path + candidate RNG + strongest deferred-binding probe
- `ABLX0` = ability path + explicit target
- `ABL...` = ability path + slot fallback / arg diversity

## Why this matters

この更新で、preview matrix は

- same 5-layer semantic core
- multiple command classes
- multiple target modes

をかなり対称に観測できるようになった。

つまり matrix は current frontier で、single command demo ではなく **operational coverage surface** としてかなり実用的になっている。

## Current safest reading

したがって current snapshot の preview matrix は、

**deferred-binding contract を維持したまま command-class diversity と target-mode diversity を同時に広げた coverage surface**

と読むのが safest である。
