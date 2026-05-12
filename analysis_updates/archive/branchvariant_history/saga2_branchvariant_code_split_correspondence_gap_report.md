# saga2 branchVariant code split correspondence gap

## Summary

- `41E3-41E5` は current frontier で **strongest binding-candidate band**
- この帯が strongest に carry している semantic payload は **`0E/0F` code-family split**
- それでも numeric binding が未固定なのは、**raw `0/1` と `0E/0F` side の stronger local correspondence** がまだ direct には見えていないからである

## Current strongest reading

いま safest に言えるのは次の 3 点である。

1. `41E3-41E5` は route-core terminal band / retained refinement handoff edge  
2. この帯の strongest semantic payload は `0E/0F` special-candidate family split carry  
3. `41E7-41E9` では same-side pair visibility が first effective に現れる  

したがって `branchVariant` の current best reading はかなり細く、

- first-line では code-led refinement
- second-line では same-side provenance reopening

という構図まで固まっている。

## The remaining gap

残っている gap は、semantic payload の特定ではない。  
残っているのは **correspondence strength** だけである。

つまり未確定なのは、

- raw `0` が `0E` 側か `0F` 側か
- raw `1` がその反対側か

を `41E3-41E5` の中で **direct local correspondence** として言えるかどうかである。

言い換えると current frontier は、

- `0E/0F` split is the carried meaning  
までは言えるが、
- raw `0/1` is locally bound to that split  
まではまだ言い切れない。

## Why this gap is now very narrow

この gap が narrow なのは、他の論点がすでにかなり片付いているからである。

- side semantics は回収済み
- same-side carry / same-side visibility は回収済み
- remap-free carry bias も strong
- strongest band も `41E3-41E5` に絞れている
- strongest payload も `0E/0F` code-family split に絞れている

したがって今残っている未回収部分は、

**raw numeric と code-family side の one-step local glue**

だけである。

## Safest wording

current safest wording は次の通りである。

- `41E3-41E5` = strongest binding-candidate band
- strongest payload = `0E/0F` code-family split carry
- remaining gap = raw `0/1` と `0E/0F` side の stronger local correspondence gap

つまり `branchVariant` の numeric binding は、広い意味での semantics 不足ではなく **one-step local correspondence gap** の問題として扱うのが current best reading である。
