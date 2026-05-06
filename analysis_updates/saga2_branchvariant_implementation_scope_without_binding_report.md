# saga2 branchVariant implementation scope without binding

## Summary

- current frontier で未回収なのは、**raw `0/1` と `0E/0F` code-family side の one-step local glue** だけである
- したがって implementation policy は、numeric binding を lock しなくてもかなり広い範囲で **GO** にできる
- remaining NO-GO は、raw `0/1` に exact semantic name を焼き込むことだけにかなり収束している

## What is already safe to implement

### 1. Type shape

以下の shape は current frontier で十分 stable である。

- `branch`
- `branchVariant?: 0 | 1`
- `postBranchRoute`
- `pointerFlavor`
- `target`

つまり `branchVariant` の **field existence / optionality / value range** は GO である。

### 2. Side-semantic debug wording

以下の wording も GO である。

- `branch` = actor-local resolution lane pair
- `branchVariant` = PTR-only candidate-family lane refinement bit
- `pointerFlavor` = target-provenance path pair

つまり raw numeric binding を lock しなくても、**side semantics を debug/docs/UI に出す** ことは safe である。

### 3. Same-side carry / correspondence policy

以下も current frontier で GO である。

- `branchVariant` raw numeric は保持する
- same-side correspondence を別 field / wording で示す
- `pointerFlavor` との side-level correspondence を明示する

つまり **`0 == shared` と書かないまま実装を強くできる**。

### 4. Ordering / selfcheck / trace contract

以下も GO である。

- `branch -> branchVariant -> postBranchRoute -> pointerFlavor -> target`
- `combat hook -> post-branch marker + pointer -> target terminal`
- selfcheck で wording / ordering を固定する

これらは numeric binding 非依存である。

## What remains NO-GO

### 1. Raw numeric semantic naming

以下はまだ NO-GO である。

- `0 = shared/default-leaning`
- `1 = candidate-aware/strict-leaning`

あるいはその逆

この exact binding は current frontier では still provisional である。

### 2. Numeric-driven branching in code

以下のような実装はまだ避けるのが safest である。

- `if branchVariant == 0 then shared-side branch`
- `if branchVariant == 1 then candidate-side branch`

side semantics を直接 raw numeric に焼き込む分岐は、binding lock までは保留するのがよい。

## Safest implementation stance

したがって current safest stance は次の通りである。

- raw `0|1` は transport field として保持
- side semantics は separate wording / metadata で運ぶ
- code path は `pointerFlavor` や semantic helper を経由して読む
- `branchVariant` raw numeric 自体を semantic branch key にしない

つまり **shape と relation は実装するが、raw numeric naming だけ deferred** にするのが current best policy である。

## Practical consequence

今後の implementation は、

- contract hardening
- debugTrace maintenance
- frontend bridge usage
- selfcheck reinforcement

をそのまま進めてよい。

残る stop line は、

- raw `0/1` を exact side name で固定すること
- raw `0/1` を semantic branch key として直接使うこと

の 2 点だけである。
