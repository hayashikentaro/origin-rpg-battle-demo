# Saga2 BranchVariant Code-vs-Qualifier Bias Report

## 要点

- current best reading では、`branchVariant 0/1` の compressed split は **qualifier 差だけ** より、まず **code/qualifier の合成差** に依るとみるのが最も自然である
- ただし重みづけとしては、`0E/0F` の family variant 差が first-line で見えやすく、qualifier はその variant の内側で split を調整する **secondary contributor** とみるのが safest である
- したがって current best bias は、`branchVariant` は  
  - primary = `0E/0F` family variant 差  
  - secondary = qualifier class 差  
 から作られる compressed binary refinement として持つのが自然である

## 1. Why Not Pure Qualifier

もし `branchVariant` が qualifier 差だけを写すなら、
既報でかなり強く見えている

- `0E` strict variant
- `0F` zero-fast-path variant

という family 非対称性が first-line refinement に十分反映されないことになる。

しかし current best reading では、
`branchVariant`
は PTR-specific first-line refinement の中心にかなり寄っている。

このため safest reading は、
qualifier だけでなく
**family variant (`0E/0F`) 差**
も split の主要因に入るとみることである。

## 2. Why Not Pure Code Either

逆に `branchVariant` が `0E/0F` だけをそのまま写すとみるのも強すぎる。

既報では qualifier についても

- `0` = allowed zero
- `1` = blocked ordinal
- `2+` = consumable nonzero class

というかなり強い local gate semantics が見えている。

したがって safest reading は、

- code variant が primary axis
- qualifier class が secondary correction

として binary refinement に圧縮される、
というものである。

つまり current best bias は
pure code / pure qualifier
のどちらかではなく、
**code-led compressed split**
にある。

## 3. Safest Current Reading

現時点の safest reading は次のように要約できる。

```ts
branchVariant in {0, 1}
```

は:

```ts
compressed split derived primarily from 0E/0F family variant
and secondarily from qualifier class
```

にかなり近い。

この reading は、

- `0E/0F` family 非対称性
- qualifier 0/1/2+ semantics
- PTR candidate reopening

の 3 本を最小の仮説でつなぎやすい。

## implication for step 6

この整理を採ると、step 6 の provisional code で
`branchVariant?: 0 | 1`
を維持しつつ、
debug / docs の説明では

- primary: code variant
- secondary: qualifier class

という 2 層で意味づけしていくのが自然になる。

つまり field shape は変えずに、
exact semantics の sharpening だけを進めればよい。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `branchVariant` の 0/1 が `0E/0F` family 差に最も強く対応するか
2. qualifier class が binary split のどこで補正として効くか
3. second-line の `pointerFlavor="candidate"` がこの code-led split をどこまで保持するか

ここが取れれば、`branchVariant` の exact semantics はかなり recovered semantics に近づく。
