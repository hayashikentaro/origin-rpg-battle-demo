# saga2 matrix operational readiness

## Summary

- current preview matrix と selfcheck coverage は、deferred-binding policy を保ったまま **operationally ready** な観測面になっている
- 現在の最小有効セットは  
  **`ATK / ATKX / ATKS / DEF / PTR / ABLX0 / ABL...`**
- これにより same 5-layer contract を
  - command-class diversity
  - target-mode diversity
  - candidate vs shared path diversity
  
  の 3 方向からかなり安定して観測できる

## Why this is now operationally ready

### 1. Command diversity is sufficient

current matrix は

- attack family
- defend family
- pointer/candidate family
- ability family

を含んでいる。

したがって actor-local bridge の semantic core が単一 command class だけに依存していないことを実運用レベルで確認できる。

### 2. Target-mode diversity is sufficient

current matrix は

- explicit target
- slot fallback
- candidate target

の 3 mode を含んでいる。

したがって `target` / `targetSource` が downstream terminal layer としてどう振る舞うかを、lane/route/provenance と切り分けて観測できる。

### 3. Deferred-binding policy is preserved

current matrix expansion は

- raw `branchVariant 0|1` の exact naming を増やさない
- `pointerFlavor` side semantics を強く保つ
- same-side carry semantics を崩さない

形で進められている。

つまり coverage widening が semantic overcommit を生んでいない。

### 4. Selfcheck coverage keeps pace with matrix growth

matrix に追加された

- `ATKX`
- `ATKS`
- `ABLX0`

のような probe は、front 側だけでなく selfcheck にも反映されている。

これにより expanded matrix は “見えるだけ” ではなく、**regression-guarded operational surface** になっている。

## Practical meaning

current matrix/selfcheck pair は、いまや単なる debug convenience ではない。  
current frontier では、

- shape-preserving implementation
- semantic debug maintenance
- preview-based regression detection

の基盤として使ってよい。

## Still deferred

matrix が operationally ready でも、次はまだ deferred である。

- raw `branchVariant 0|1` の exact side naming
- raw numeric を semantic branch key にすること
- opcode-level exact anchoring

つまり matrix readiness は **binding readiness** ではない。

## One-line reading

current safest reading は、

**the preview matrix and selfcheck now form an operationally ready coverage surface for the 5-layer contract, without forcing exact numeric binding.**

である。
