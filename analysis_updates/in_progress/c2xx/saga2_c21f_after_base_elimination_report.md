# SaGa2 `C21F` After-Base Elimination Report

## Summary
- 既知の high-confidence path を並べると、`C21F` は現時点では **block base / selector reference を返す層** に留まっている可能性が高く、`+1..+F` consumer の有力候補だった `10CC` 後半も決め手にはなっていない。
- いっぽう `10CC` 後半で実際に粒度が上がっているのは `C21F` より `C20F/C71D/C2B9/C7E0` など selector source 側であり、`C21F` richer field の証拠にはまだ届いていない。
- したがって次に優先すべきなのは、`10CC` 全体を掘り続けることではなく、**`C21F` base を返したあとで本当に offset read が起きる caller だけを別途抽出すること** である。

## 1. `5B95` は除外

`5B95` caller:

```asm
5B83: PUSH HL
5B84: CALL $5B95
5B87: LD (HL),C
5B88: POP HL
```

ここでは block base 取得後に
即 `LD (HL),C` して終わる。

したがってこの path は
**block `+0` writer**
であり、`+1..+F` reader 候補から外してよい。

## 2. `60E2` も除外

`60E2` caller:

```asm
60D1: PUSH HL
60D2: CALL $60E2
60D5: LD (HL),C
60D6: POP HL
```

ここもやはり block base 取得後に
即 `LD (HL),C`。

したがって `60E2` path も
**block `+0` writer**
に留まる。

## 3. `10CC` 後半は現時点で決め手不足

`10CC` には:

```asm
10CC: CALL $004C
10CF: LD HL,$C21F
10D2: RET
```

が見える一方、既報の高位 contract では
その後段 `10D4+` は range-dispatch によって

- `C71D`
- `C2B9`
- `C20F`
- `D906`
- `C7E0`

など別 source へ振り分け、
最終的に `A=(HL); CP $FF`
へ正規化している。

重要なのは、いま見えている report 群では
`10CC` の `C21F` path について

- block base を返したあと
- `INC HL` / `LDI A,(HL)` / `ADD HL,offset`

で `+1..+F` を読む強い evidence が
まだ取れていないこと。

したがって `10CC` は現段階では
**`C21F` richer struct の reader**
より
**selector dispatch 層**
として持つほうが安全。

## 4. What Actually Gets Richer In `10CC`

既報を合わせると、`10CC` 後半で粒度が上がっているのは:

- `C20F` = player-local selector work
- `C71D/C2B9/C7E0` = resolved source index family
- `6640/6EC0` = terminal name table

であって、`C21F` 自体ではない。

つまり `10CC` を追うことで深くなるのは
**shared selector infrastructure**
のほうであり、
`C21F` block struct の field 解読には直結しない可能性が高い。

## 5. Safe Current Reading

現時点の safest reading は:

```ts
function getC21fBlockBase(index: number): number
```

まで。

`C21F` は少なくとも:

- block `+0` に sourceIndex/head 類を持つ
- selector/builder から block base として参照される

が、
それ以上の field はまだ未確定。

## 6. Updated Search Focus

したがって次の探索単位は:

1. `10CC` 全体ではなく **`C21F` path に限定した caller-after-base**
2. `CALL $5B95 / $60E2 / $10CC` のあと `HL` に対して offset read を行う path
3. 見つからなければ `C21F` richer struct 仮説を一段弱める

## Implication
- `C7E0` は shared sparse remap/list としてかなり進んでいる
- `C20F` は player-local selector work として粒度が上がっている
- `C21F` はそのどちらよりも一段抽象度の高い block-base/index table に留まっている可能性がある

## Next Steps
1. `10CC` 後半ではなく `C21F` path caller の直後に search を絞る。
2. `1149/1153/115A` 系で `C20F/C2B9/C71D` source 差を整理し、`C21F` を無理にそこへ重ねない。
3. `C21F` に rich consumer が見つからない場合、shared candidate-state builder 仮説を「block-head/index builder」へ一段弱める。
