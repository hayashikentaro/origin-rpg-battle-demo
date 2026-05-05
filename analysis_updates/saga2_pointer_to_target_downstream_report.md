# SaGa2 Pointer To Target Downstream Report

## Question

`41E7-41E9` で `pointerFlavor` pair alignment が first effective に visible になったあと、
その差分は final `target` へどう downstream すると読むのが safest か。

## Current best reading

現時点では、`pointerFlavor` の pair difference は
**final `target` の値そのものを直接 encode するのではなく、
target determination を形作る provenance path を downstream で分岐させる**
とみるのが safest である。

つまり current best reading では、

- `"shared"` = shared/default target-determination path
- `"candidate"` = candidate-flavored target-determination path

という 2 本の provenance path があり、
`target` はそのどちらが active になったかの terminal consequence と読むのが自然である。

## Why not treat `pointerFlavor` as direct target code

既報の role split では `target` は second-line の terminal result であり、
`pointerFlavor` はその upstream の provenance discriminator である。

この前提を維持するなら、`pointerFlavor` を

- target number そのもの
- direct target selector value

として読むより、
**target を決めに行く path の class** と読むほうが current code shape に整合する。

## What downstream means here

ここでいう downstream は、「target へ行くまでに別 field を増やす」という意味ではない。

むしろ current safest reading では、

1. `postBranchRoute`
2. `postBranchTargetSource`
3. `pointerFlavor`
4. `target`

の 4 段で十分であり、
`pointerFlavor` は `target` の直前にある **thin path discriminator**
として持つのが最も自然である。

つまり `pointerFlavor` と `target` の間に大きな hidden layer を足す必要は薄い。

## PTR / ATK difference under this reading

この読みでは、

- `ATK` 側は `"shared"` path により default/shared target determination へ流れる
- `PTR` 側は `"candidate"` path により candidate-flavored target determination へ流れる

と読める。

ここで重要なのは、差分の主戦場は依然として `pointerFlavor` にあり、
`target` 自体はその **terminal consequence** として扱う、という点である。

## Implication for the provisional API

この読みを provisional API に戻すと、

- `pointerFlavor` = final target の upstream path class
- `target` = path class の downstream result

という relationship を明記してよい。

つまり `target` は still-provisional ではあるが、
その provisionalness は `pointerFlavor` の unresolved semantics にかなり従属している。

## Current safest wording

現時点の safest wording は次のとおり。

- `pointerFlavor` = target-determination provenance path discriminator
- `target` = that path's downstream terminal result

## Remaining uncertainty

未確定なのは、

- `"shared"` / `"candidate"` の target-determination path が battle-side でどこまで explicit に分かれているか
- final target の exact numeric meaning をどこまで provenance class だけで説明できるか

の finer detail である。

ただし current frontier では、
**`pointerFlavor` を path discriminator、`target` を terminal consequence**
と読むのが最も安全である。
