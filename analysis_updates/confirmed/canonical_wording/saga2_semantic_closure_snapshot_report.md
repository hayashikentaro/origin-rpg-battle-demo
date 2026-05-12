# SaGa2 Semantic Closure Snapshot Report

## Goal

current frontier で残っていた decisive wording を一通り整理したあと、
5-layer provisional API がどこまで **semantic closure** に近づいたかをまとめる。

## Current closure level

現時点では、5-layer provisional API は
**shape だけでなく naming / timing / display policy まで含めて、かなり強い provisional closure**
に達しているとみるのが safest である。

つまり未確定が完全になくなったわけではないが、
今残っているものは

- exact numeric binding
- battle-native wording の finer nuance
- local cluster 内の micro-timing

といった **fine-grain sharpening**
にかなり寄っており、
大きな decomposition や interface の見直しを要する状態ではない。

## What is effectively closed

現時点で実質的に閉じたとみてよいもの:

1. 5-layer shape
   - `combatDecision`
   - `postBranchRoute`
   - `postBranchTargetSource`
   - `pointerFlavor`
   - `target`

2. layer order
   - decision
   - transfer
   - reopening
   - terminal

3. first-line naming
   - `branch` = actor-local resolution lane pair
   - `branchVariant` = PTR-only candidate-family lane refinement bit

4. transfer naming
   - `postBranchRoute` = lane-transfer core

5. second-line naming
   - `pointerFlavor="shared"` = shared/default target-provenance path
   - `pointerFlavor="candidate"` = candidate-entry target-provenance path
   - `target` = downstream terminal result

6. display / trace policy
   - `branch -> branchVariant -> postBranchRoute -> pointerFlavor -> target`
   - `postBranchTargetSource` is shown as a weak marker

## What is still only softly closed

softly closed, but not fully fixed:

1. `branchVariant 0/1` numeric binding
2. `41E3-41E5 -> 41E6 -> 41E7-41E9 -> 41EB-41EC` の finer wording
3. `postBranchRoute` の exact instruction-level anchor

ただしこれらは、
今の interface や naming を不安定にする種類の未確定ではなく、
**既存モデルを少しずつ sharpen するための residual uncertainty**
として扱える。

## Practical consequence

実装判断としては、

- interface design は先に進めてよい
- debug wording は current canonical wording を使ってよい
- additional ROM analysis は semantic sharpening として継続すればよい

という状態にかなり近い。

言い換えると、
この先の解析は「何を作るか」より
**いまの model をどこまで battle-native に磨くか**
に重心を移してよい。

## Current safest summary

現時点の safest summary は次のとおり。

**5-layer provisional API は semantic closure にかなり近づいており、残る課題は interface 発見ではなく exact wording と numeric binding の sharpening である。**
