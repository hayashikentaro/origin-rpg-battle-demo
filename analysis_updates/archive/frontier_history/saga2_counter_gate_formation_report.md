# Saga2 Counter Gate Formation Report

## 要点

- `41E7-41E9 -> 41EB-41EC` の consume belt 自体はかなり deterministic に見える
- したがって next frontier は、その belt の内部ではなく **`41C4-41D8` にある pre-gate 条件形成** に置くのが自然である
- 特に `C` に入っている値に対する
  - `FF`
  - `0E`
  - `0F`
  と、`H` を使う分岐群が、後段 `41D9-41EC` を開くかどうかの local path gate を形成している可能性が高い

## relevant flow

```text
41C4: LD A,C
41C5: CP $FF
41C7: JR Z,$41F1
41C9: CP $0E
41CB: JR Z,$41D5
41CD: CP $0F
41CF: JR NZ,$41D9
41D1: LD A,H
41D2: OR A
41D3: JR Z,$41D9
41D5: LD A,H
41D6: DEC A
41D7: JR Z,$41F1
41D9: INC E
41DA: INC E
...
41E6: LD A,(DE)
41E7: CP $FE
41E9: JR Z,$41ED
41EB: DEC A
41EC: LD (DE),A
```

## 読み

この flow を意味順で読むと、少なくとも 2 段に分けられる。

1. `41C4-41D8`  
   local candidate / special-code pre-gate
2. `41D9-41EC`  
   entry resolution + counter consume belt

前段 `41C4-41D8` は `C` と `H` の内容によって

- 即時離脱 (`JR Z,$41F1`)
- `41D9` 進入
- `41D5` を経る特別経路

を切り替えている。

## なぜここが重要か

current `combatDecision` は `41E7-41E9 -> 41EB-41EC` に対応づけているが、
exact flow を見る限り、

- `41E7-41E9`

そのものは `counter == FE` sentinel を見る gate に近い。

いっぽうで battle-side の「consume path に入るかどうか」を大きく決めているのは、その前段にある

- `C == FF`
- `C == 0E`
- `C == 0F`
- `H == 0`
- `H == 1`

の special/sentinel 条件群である可能性が高い。

つまり `combatDecision.shouldConsumeCounter` 仮説の source を探うとき、

- `41EB-41EC` の deterministic writeback
- `41E7-41E9` の `FE` gate単独

だけを見るより、

- **`41C4-41D8` がどの local path を `41D9-41EC` へ送り込むか**

を first-line にしたほうが battle semantics に近い。

## implication for current skeleton

current skeleton の provisional labels

- `local_counter_gate`
- `candidate_counter_gate`

はまだ有効だが、次の refinement では

- `pre_counter_special_gate`
- `counter_sentinel_gate`

の 2 段に分けて持つ必要が出る可能性がある。

現時点ではそこまで断定せず、少なくとも

- `combatDecision` の本当の source は `41E7-41E9` 単独より広い
- 最低でも `41C4-41D8 -> 41D9-41EC` の連結で見るべき

というところまでを current best reading とするのが安全である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `C` の `FF / 0E / 0F` が何の candidate/type code なのか
2. `H` の `0 / 1+` が何の secondary qualifier なのか
3. この pre-gate 群のどこかに raw/small-range RNG source が流入しているか

ここが取れれば、`combatDecision` は単なる counter gate から、
**special-code aware local action gate**
へ一段具体化できる。
