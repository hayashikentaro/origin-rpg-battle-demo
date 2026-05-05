# Saga2 Pending Combat Decision Frontier Report

## 要点

- current `step 6` skeleton では、`combatDecision` はまだ recovered battle semantics ではない
- ただし unresolved hook の位置づけはかなり具体化できており、今は
  - `pendingWindow = 41E7-41E9 -> 41EB-41EC`
  - `pendingMeaning = local_counter_gate | candidate_counter_gate`
 という形で provisional に保持している
- これは「まだ本当の命中/ダメージ値ではないが、battle core が次に回収すべき smallest combat meaning」を front/core 両方で共有するための cut である

## どう読むべきか

### `pendingWindow`

`41E7-41E9 -> 41EB-41EC` は、battle/RNG narrowing の current first-line window をそのまま field 化したものと読むのが自然である。

- `41E7-41E9`: local decision slot 候補
- `41EB-41EC`: consume/writeback belt 候補

つまり `combatDecision` は、今のところ「この narrow window に対応する unresolved hook」を表している。

### `pendingMeaning`

`pendingMeaning` は本当の battle semantics 名ではなく、current skeleton を前に進めるための provisional label である。

- `local_counter_gate`
  - candidate-selection を踏まない local path での consume gate 候補
- `candidate_counter_gate`
  - slot `07/08` candidate-selection path を踏んだあとの consume gate 候補

この 2 分類により、front 上で `ATK` と `PTR` が同じ `combatDecision` stub ではなく、別 frontier を見ていることを確認できる。

## 実装側の意味

current core 実装では、`combatDecision` は最低限次を返す。

- `shouldConsumeCounter`
- `debugSource`
- `pendingWindow`
- `pendingMeaning`

したがって actor-local bridge は、単に `false` を返しているのではなく、

1. どの ROM window を見に行くべきか
2. その unresolved hook を current path 上ではどう分類しているか

を返しているとみてよい。

## front 側の意味

Godot の debug command matrix では、この provisional meaning をそのまま見せている。

- `ATK` は通常の local path 側
- `PTR` は slot `07/08` candidate path 側
- `ABL{index}` は `kindId/arg -> localPath` の差分側

つまり front 側の表示は、battle 演出や UI ではなく、**`combatDecision` の unresolved frontier を可視化する観測面** として機能している。

## 次の確認点

この provisional label を実意味へ置き換えるために必要なのは、やはり次の 2 点である。

1. `41E7-41E9` 相当の local decision slot に raw/small-range RNG が入るか
2. その返り値が `41EB-41EC` の consume/writeback 可否へつながるか

ここが取れれば、`pendingMeaning` は

- `local_counter_gate`
- `candidate_counter_gate`

のような仮名から、first recovered combat semantics へ昇格できる。
