# Saga2 BranchVariant Primary Axis Report

## 要点

- current best reading では、`branchVariant 0/1` の primary axis は qualifier 単独ではなく、**`0E/0F` special-candidate family 差** にあるとみるのが最も自然である
- qualifier `0 / 1 / 2+` は無関係ではないが、first-line の binary refinement を直接決める主軸というより、**`0E/0F` family 差へ重ねて働く secondary modifier** として持つのが safest である
- したがって `branchVariant` は current frontier では、**code-led compressed split** として読むのがいちばん battle-side evidence と code skeleton の両方によく噛み合う

## 1. Why Code Is The Primary Axis

既報では `D?12..` repeated candidate-entry family を

- low byte = candidate/type code
- high byte = qualifier / owner / count-like byte

と読むのが current best である。

また `0E/0F` family については、

- `0E` = strict variant
- `0F` = zero-fast-path privilege を持つ variant

という非対称性がかなり強く narrowed されている。

この時点で first-line の `branchVariant`
が二値 refinement を持つなら、
qualifier 単独より
**`0E/0F` family 差**
を first axis に置くほうが自然である。

理由は、
binary refinement を要求する最も強い structural asymmetry が
qualifier class そのものより
`0E/0F` family 差のほうにあるからである。

## 2. Why Qualifier Still Matters

qualifier 側も既報では

- `0` = allowed zero
- `1` = blocked ordinal
- `2+` = consumable nonzero class

という small ordinal としてかなり narrowed されている。

しかしこの差は current best reading では、
first-line の binary split を直接に作るより、
**`0E/0F` family の内側で local gate を調整する副次要因**
として働くほうが自然である。

つまり safest bias は:

- primary = `0E/0F` family variant
- secondary = qualifier class

である。

## 3. Why This Fits Better Than A Qualifier-Led Reading

もし `branchVariant`
を qualifier-led binary split とみるなら、

- qualifier `0`
- qualifier `1`
- qualifier `2+`

という 3-way に近い ordinal 差から、
無理に 2-way split を直接作る説明が必要になる。

いっぽう code-led reading では、
もともと `0E/0F` に強い非対称性があり、
その上に qualifier が

- zero-fast-path を許すか
- blocked ordinal に落とすか
- strict/nonzero path に残すか

を重ねる、
という layered reading がかなり自然に作れる。

このため current best bias は、
qualifier-led より
**code-led compressed split**
のほうが evidence を少ない仮定でつなげられる。

## 4. Relation To `pointerFlavor="candidate"`

既報では
`pointerFlavor="candidate"`
は second-line で
`D?12..` family の candidate reopening を表す、
という current best reading に寄っている。

この前提を採ると、

- `branchVariant`
  = `D?12..` family 差の first-line compressed image
- `pointerFlavor="candidate"`
  = 同じ family 差の second-line reopening marker

という役割分担が最も自然になる。

つまり:

- first-line では `branchVariant` が `0E/0F` 主軸の差を圧縮して持つ
- second-line では `pointerFlavor="candidate"` が provenance reopen を持つ

という 2 層分離がかなりきれいに閉じる。

## 5. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
branchVariant?: 0 | 1
```

は battle-side semantics では:

```ts
code-led compressed refinement
// primary axis: 0E/0F family difference
// secondary modifier: qualifier class
```

にかなり近い。

つまり `branchVariant`
を pure qualifier split とみるより、
**`0E/0F` family 差を主軸に qualifier を副次要因として畳んだ first-line refinement**
と読むのが safest である。

## implication for step 6

この整理を採ると、
current provisional code は shape を変えずにそのまま意味を強められる。

- shape は `branchVariant?: 0 | 1`
- code source は `candidateOffset`
- battle-side anchor は `D?12..` family
- semantic primary axis は `0E/0F`

という 4 層を分けて持てるからである。

つまり next analysis は、
field を増やすのではなく
`branchVariant`
の label/consumer semantics を
`0E/0F` family 差へさらに寄せればよい。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `branchVariant 0/1` の 2 値が `0E/0F` 差のどちらを first-line で代表しているか
2. qualifier `1` の blocked ordinal が `branchVariant` のどこまで second-order effect として残るか
3. `pointerFlavor="candidate"` が second-line でこの code-led split をどこまで保持するか

ここが取れれば、`branchVariant` の exact semantics はかなり recovered semantics に近づく。
