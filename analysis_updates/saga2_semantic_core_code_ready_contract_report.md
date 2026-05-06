# saga2 semantic core code-ready contract

## Summary

- `branchVariant` に続いて、`branch` / `postBranchRoute` / `pointerFlavor` も current frontier で十分 code-ready な contract に圧縮できる
- この 3 field は 5-layer model の semantic core を成しており、**lane -> transfer -> provenance** の順でかなり stable である
- remaining uncertainty は exact battle-native naming の finer sharpening であり、field contract 自体ではない

## 1. branch

### Code-ready contract

- field role: **actor-local resolution lane pair**
- current safest wording:
  - `default resolution lane`
  - `candidate-aware resolution lane`

### Safe implementation rule

- `branch` は actor-local resolution mode の selector として使う
- `accepted=true/false` に応じて admitted-path activation / fallback selection の role が変わる
- raw numeric branch id の battle-native exact naming は future sharpening に回してよい

## 2. postBranchRoute

### Code-ready contract

- field role: **lane-transfer core**
- current safest wording:
  - first-line lane / refinement を second-line reopening へ渡す transfer core

### Safe implementation rule

- `postBranchRoute` は route id というより alignment transfer core として扱う
- `branch` と optional `branchVariant` を受けて second-line reopening の入口を形成する
- exact micro-boundary (`41E3-41E5` vs `41E6`) は deferred でも contract 利用は問題ない

## 3. pointerFlavor

### Code-ready contract

- field role: **target-provenance path pair**
- current safest wording:
  - `"shared"` = shared/default target-provenance path
  - `"candidate"` = candidate-entry target-provenance path

### Safe implementation rule

- `pointerFlavor` は target terminal そのものではなく、その downstream provenance path discriminator として使う
- `target` は `pointerFlavor` の terminal consequence として読む
- `postBranchTargetSource` は weak/shared entry marker に留める

## Cross-field relation

current safest semantic core relation は次の通りである。

1. `branch` picks an actor-local resolution lane  
2. `branchVariant` optionally refines PTR candidate-family lane semantics  
3. `postBranchRoute` transfers that lane/refinement into second-line reopening  
4. `pointerFlavor` names the reopened target-provenance path  
5. `target` is the downstream terminal result

つまり core contract は **lane -> transfer -> provenance -> terminal** の flow としてそのまま使える。

## Remaining deferred pieces

still deferred なのは次のような finer sharpening である。

- `branch` raw numeric naming
- `branchVariant 0/1` exact numeric binding
- `postBranchRoute` exact instruction-level anchor
- `pointerFlavor` の even finer battle-native wording

しかしこれらは field contract の成立を妨げない。

## One-line contract

current semantic core contract を一文で書くなら、

**`branch` selects a local resolution lane, `postBranchRoute` transfers it, and `pointerFlavor` reopens it as a target-provenance path whose terminal consequence is `target`.**

である。
