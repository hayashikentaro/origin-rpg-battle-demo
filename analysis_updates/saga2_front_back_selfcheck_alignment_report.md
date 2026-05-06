# saga2 front back selfcheck alignment

## Summary

- current frontier では、battle/RNG bridge の alignment は **core contract / frontend preview / debug wording / selfcheck guard** の 4 層でかなり強く揃っている
- さらに preview matrix growth-safe policy も入ったことで、coverage widening を続けても canonical probes が壊れにくい構造になった
- remaining uncertainty は alignment の外側、つまり numeric binding と opcode-level anchoring にかなり押し出されている

## 1. Core contract alignment

core 側では current semantic core が揃っている。

- `branch`
- `branchVariant`
- `postBranchRoute`
- `pointerFlavor`
- `target`

この 5-layer contract は lane -> transfer -> provenance -> terminal の flow として stable であり、current implementation の基準面になっている。

## 2. Frontend preview alignment

frontend 側では current matrix が

**`ATK / ATKX / ATKS / DEF / PTR / ABLX0 / ABL...`**

まで広がっており、

- command-class diversity
- target-mode diversity
- candidate/shared path diversity

を same contract のもとで観測できる。

さらに canonical probe display は fixed index ではなく stable label lookup に移ったため、matrix growth に対して壊れにくい。

## 3. Debug wording alignment

debug wording は current frontier で次に揃っている。

- field order: `branch -> branchVariant -> postBranchRoute -> pointerFlavor -> target`
- trace order: `combat hook -> post-branch marker + pointer -> target terminal`

これにより first-line carry と second-line reopening / terminal の relation が front/back で同じ順序で読める。

## 4. Selfcheck alignment

selfcheck は現在、

- shape
- wording
- ordering
- deferred-binding semantics
- route / marker / pointer / target relation
- matrix target-mode diversity

まで cover している。

つまり current selfcheck は type check ではなく **alignment guard** として機能している。

## 5. Why this matters

この 4 層 alignment が強いので、今後の source work は

- contract-preserving expansion
- deferred-binding-safe maintenance

に集中できる。

言い換えると、current frontier では “何を作るか” より “どう壊さずに広げるか” が主題である。

## One-line reading

current safest reading は、

**core semantics, frontend preview, debug ordering, and selfcheck now form a tightly aligned operational surface, while exact numeric binding remains explicitly outside that aligned surface.**

である。
