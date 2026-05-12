# Saga2 PointerFlavor Exact-Bias Report

## 要点

- current best reading では、`pointerFlavor` は second-line reopening の単なる display class ではなく、**pointer/materialization がどの provenance から来たか** を表す field とみるのが最も自然である
- その 2 値は現時点では  
  - `"shared"` = actor-local shared/default provenance  
  - `"candidate"` = PTR-specific candidate provenance  
  と読むのが safest である
- したがって `pointerFlavor` の exact battle-side meaning も、first-line では「target を決める値」ではなく **pointer-side provenance discriminator** として持つのがもっとも整合的である

## 1. Why Provenance Is The Best Exact-Bias

既報では `pointerFlavor` を

- second-line reopening の中心
- `target` の upstream
- `postBranchTargetSource` より強い PTR-specific carrier

として整理してきた。

この 3 点を同時に満たす最も軽い読みは、
`pointerFlavor`
を
**pointer/materialization provenance discriminator**
とみることである。

つまり current best reading では、
`pointerFlavor`
は pointer path が

- shared/default 系なのか
- candidate/PTR 系なのか

を区別する field である。

## 2. Why `"shared"` And `"candidate"` Read Naturally This Way

`"candidate"` は既報どおり、

- `candidateOffset`
- `branchVariant`
- PTR second-line reopening

へつながる path-specific provenance を表すと読むのが自然である。

いっぽう `"shared"` も、
単なる残余カテゴリではなく
ATK 側を含む default pointer/materialization reopening
として正に読むのが軽い。

このため 2 値は current best bias では:

```ts
"shared"    => shared/default provenance
"candidate" => candidate/PTR provenance
```

という provenance 対になっている。

## 3. What It Is Not

current safest reading では、
`pointerFlavor`
は次のものではない。

- final target そのもの
- targetSource の別名
- branchVariant の単なる mirror

もちろんこれらと関係はあるが、
field-level semantics としては
それらの **前段** にある provenance class とみるほうが自然である。

つまり:

- `branchVariant` は PTR-specific refinement
- `pointerFlavor` はその second-line provenance reopening
- `target` はその downstream result

という順で読むのが safest になる。

## 4. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
type PointerFlavor = "shared" | "candidate"
```

そして exact-bias は:

```ts
pointerFlavor marks pointer/materialization provenance
```

である。

もう少し具体化すると:

```ts
"shared"    => shared/default pointer provenance
"candidate" => candidate-derived pointer provenance
```

という 2 値である。

## implication for step 6

この整理を採ると、step 6 の current code / debug shape で
`pointerFlavor`
を first target にしているのはかなり妥当だと言える。

つまり next analysis では、
`pointerFlavor`
の exact ROM-side origin をもう少し押さえれば、
second-line reopening の meaning はかなり強くなる。

ここから先は shape の議論より、
**provenance semantics の sharpening**
が中心になる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `"candidate"` が battle-side でどの candidate-entry family に結びつくか
2. `"shared"` がどの default pointer/materialization family に結びつくか
3. `target` の差分がこの provenance class の違いでどこまで説明できるか

ここが取れれば、`pointerFlavor` の field-level semantics はかなり recovered semantics に近づく。
