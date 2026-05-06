# SaGa2 BranchVariant Binding Decision Rule Report

## Goal

`branchVariant 0/1` の numeric binding を

- まだ固定しない理由
- 何が揃えば固定してよいか

を current frontier に即して整理する。

## Current status

現時点で確定しているのは次の部分である。

- `branchVariant` = PTR-only candidate-family lane refinement bit
- semantic polarity:
  - shared/default-leaning side
  - candidate-aware/strict-leaning side
- second-line では `pointerFlavor` に strong side-level correspondence を持つ

未確定なのは、

- `0` がどちら側か
- `1` がどちら側か

という **numeric binding** だけである。

## What counts as enough evidence

current frontier で binding を固定してよい条件は、
少なくとも次のどちらかである。

### Condition A

raw `branchVariant` value が、
`pointerFlavor="shared"` / `"candidate"` のどちらかへ
**one-way に近い trace correspondence** を示すこと。

つまり debug / battle-side wording のどちらかで、

- raw `0` は consistently one side
- raw `1` は consistently the other side

と読めるだけの追加 directness が必要である。

### Condition B

`0E/0F` candidate-family difference と raw `0/1` が、
battle-side の同じ局所 cluster で
**同時に anchor される stronger local evidence**
を得ること。

つまり source-side compressed split と battle-side family split の間に、
もう一段近い local bridge が必要である。

## What current evidence can do, and cannot do

今ある evidence で言えること:

- side semantics は強い
- `pointerFlavor` との correspondence も strong
- `0E/0F` 主軸 / qualifier 副次という reading も安定

今ある evidence でまだ言えないこと:

- `0 == shared` / `1 == candidate`
- `0 == candidate` / `1 == shared`

のどちらが正しいかを **numeric level** で lock すること。

つまり current evidence は、
**pair polarity を回収するには十分だが、digit polarity を回収するにはまだ一歩足りない**
という性質を持つ。

## Safest implementation rule

したがって current safest rule は次のとおり。

1. raw numeric `0|1` はそのまま保持する  
2. docs/debug では side semantics を強く使う  
3. exact numeric binding は Condition A or B が満たされるまで固定しない  

## Practical implication

今後の解析で一番効くのは、

- `branchVariant raw -> pointerFlavor side`
の correspondence を
さらに “same-side” 以上に direct にできるかを見ること、

または

- `0E/0F` split と raw `0/1` split を同じ局所 cluster に押し込むこと

である。

どちらも取れない限り、numeric binding を急いで決めるより
side semantics を使い続けるほうが safer である。

## Current safest summary

**`branchVariant 0/1` の binding は、pair polarity の回収だけでは固定せず、raw value と side semantics の橋が one-way に近い directness を持ったときに初めて lock する。**
