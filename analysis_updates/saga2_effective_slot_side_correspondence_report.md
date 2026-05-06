# saga2 effective slot side correspondence

## Summary

- `41E7-41E9` は current best reading では **first effective pointerFlavor pair visibility slot**
- この slot で first-line から second-line へ visible になるのは、raw numeric binding ではなく **same-side correspondence**
- したがってここで strongest に言えるのは `branchVariant raw 0|1` と `pointerFlavor "shared"/"candidate"` の **side-level coupling** であり、`0 == shared` のような numeric lock ではない

## Current safest reading

`41E7-41E9` の visibility-led micro-sequence を current frontier で最も安全に書くなら、次の順である。

1. `41E3-41E5` から retained された first-line refinement が handoff される  
2. `41E6` で reopening / consume halo が立ち上がる  
3. `41E7-41E9` で **pointerFlavor pair (`shared` / `candidate`) が first effective に visible** になる  
4. 同じ micro-sequence 内で、その visible pair に aligned した local gate consequence が続く

この 3. の時点で strongest に recover できるのは、raw numeric binding ではなく **same-side visibility** である。

## What is actually visible here

### Strong claim

- `branchVariant` の raw value は、この slot で **pointerFlavor side pair のどちらかと同じ側** を向いて visible になる
- つまり `branchVariant` と `pointerFlavor` の relation は current frontier では **same-side correspondence** と呼ぶのが safest

### Weak / still-provisional claim

- raw `0` が `"shared"` なのか `"candidate"` なのか
- raw `1` がその反対側なのか

この部分は `41E7-41E9` だけではまだ lock し切れず、stronger local cluster evidence が必要である。

## Why this matters

`41E7-41E9` を first effective visibility slot と呼ぶ意味は、ここで **numeric decoding** が見えるからではない。  
ここで first-line refinement と second-line provenance reopening の **same-side carry** が最初に public になるからである。

したがって current best wording は、

- `branchVariant` = PTR-only candidate-family lane refinement bit
- `pointerFlavor` = target-provenance path pair
- `41E7-41E9` = their **first effective same-side correspondence visibility slot**

である。

## Consequence for binding work

この slot を主観測点に置くのは正しいが、ここで直ちに `0 == shared` と書くのはまだ premature である。  
ここで確定できるのは **same-side pair coupling** までで、numeric binding を lock するには

- one-way に近い direct correspondence
- あるいは `0E/0F` split と raw `0/1` split の stronger same-cluster anchoring

が追加で必要である。
