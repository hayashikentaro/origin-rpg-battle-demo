# Saga2 BranchVariant Code/Qualifier Mapping Report

## 要点

- current best reading では、`branchVariant 0/1` は generic binary switch というより、**`D?12..` entry の code/qualifier 差を first-line へ要約した refinement** とみるのが最も自然である
- 理由は、既報で  
  - `D?12..` repeated candidate-entry family  
  - `0E/0F` special-candidate family  
  - qualifier `0 / 1 / 2+`  
  - PTR-side `candidateOffset -> 2-way bucket -> branchVariant`  
  をそれぞれ狭めてきており、これらを最も軽くつなぐ読みが「`branchVariant` は code/qualifier 差の first-line image」であるからである
- したがって current best bias は、`branchVariant 0/1` は **`D?12..` candidate-entry の code/qualifier structure を actor-local branch refinement へ畳んだ値** として持つのが safest である

## 1. Why `branchVariant` Should Be Read Against `D?12..`

既報では `D?12..` entry を

- low byte = candidate/type code
- high byte = qualifier / owner / count-like byte

と読むのが current best であり、
`0E/0F` special-candidate family と qualifier class
も battle-side local gate にかなり近い位置で整理されている。

いっぽう `branchVariant`
も current frontier では:

- PTR-only refinement
- `candidateOffset` 2-way bucket
- shared `0 | 1` value
- second-line carry

としてかなり narrowed されている。

この 2 本を最も軽くつなぐ読みは、
`branchVariant`
を
**`D?12..` entry の code/qualifier 差を first-line へ圧縮した値**
とみることである。

## 2. Why This Fits Better Than A Pure Offset-Only Reading

もちろん code 上の immediate source は
`candidateOffset`
として持っている。

しかし current best reading では、
その `candidateOffset`
自体が PTR candidate provenance の first-line image にすぎず、
battle-side semantics の元をたどると
`D?12..` family へ戻っていく。

したがって safest reading は、

- code layer: `candidateOffset -> branchVariant`
- battle semantics layer: `D?12.. code/qualifier -> branchVariant`

という二重対応を置くことである。

つまり `branchVariant`
は offset-only artifact ではなく、
candidate-entry structure の compressed branch value
とみるのが自然になる。

## 3. What The 0/1 Split Most Likely Represents

現時点の safest bias では、
`branchVariant 0/1` が直接に

- `0E` vs `0F`
または
- qualifier `0` vs nonzero

のどちらか一方だけをそのまま写している、
とまではまだ言い切らないほうが安全である。

むしろ current best reading は、
これらの code/qualifier 差が local gate で binary refinement へ畳まれた
**compressed split**
とみることである。

つまり:

- source semantics は richer
- `branchVariant` はその compressed binary image

という関係で持つのが safest になる。

## 4. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
branchVariant in {0, 1}
```

は:

```ts
compressed first-line refinement derived from D?12.. code/qualifier structure
```

にかなり近い。

つまり field-level では shared `0 | 1` の値を保ちつつ、
battle-side meaning では `D?12..` candidate-entry family の差分を圧縮したもの
と読むのが自然である。

## implication for step 6

この整理を採ると、step 6 の provisional code はいまのままでもかなり妥当である。

- shape は `branchVariant?: 0 | 1`
- code source は `candidateOffset`
- semantics anchor は `D?12.. code/qualifier`

という 3 層を分けて持てるからである。

つまり next analysis は、
`branchVariant`
を別 field に作り直すのではなく、
その semantics を `D?12..` family に向かって sharpen すればよい。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `branchVariant 0/1` が `0E/0F` 差に強く寄るのか、qualifier 差に強く寄るのか
2. binary compression の主要因が code なのか qualifier なのか
3. second-line reopening で見える `pointerFlavor="candidate"` がこの compressed split をどこまで保持するか

ここが取れれば、`branchVariant` の field-level semantics はかなり recovered semantics に近づく。
