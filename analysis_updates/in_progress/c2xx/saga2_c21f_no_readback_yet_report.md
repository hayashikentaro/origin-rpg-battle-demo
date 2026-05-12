# SaGa2 `C21F` No-Readback-Yet Report

## Summary
- 既存 report 群を突き合わせた結果、現時点では **`C21F + 16*n` の `+1..+F` を読む高確度 path はまだ確認できていない**。
- `5B95` / `60E2` caller は block `+0` writer に閉じ、`10CC` は selector dispatcher として `C20F/C71D/C2B9/C7E0` 側を深くするが、`C21F` richer field の直接証拠にはまだ届いていない。
- したがって次の実探索は、`C21F` 周辺全体を読むのでなく、**after-base read の痕跡が出る caller だけを新規に抽出する** 方針でよい。

## 1. Confirmed Non-Consumers

### `5B95` caller
```asm
5B84: CALL $5B95
5B87: LD (HL),C
```

### `60E2` caller
```asm
60D2: CALL $60E2
60D5: LD (HL),C
```

この 2 本は、どちらも
**block base 取得 -> block `+0` write**
で終わる。

## 2. Why `10CC` Still Falls Short

`10CC` は:

- `LD HL,$C21F` を持つ
- しかし全体としては high-range selector dispatcher
- 後段で粒度が上がるのは `C20F/C71D/C2B9/C7E0`
- 共通終点は `A=(HL); CP $FF` か terminal helper

という構造だった。

このため `10CC` は
**`C21F` block の中身を読む reader**
より
**selector source を正規化する dispatcher**
とみるほうが安全で、
`C21F` richer field の証拠としてはまだ弱い。

## 3. Current Strongest Negative Result

いま強く言えるのは次の点。

1. `C21F` の高確度 usage で見えているのは block base 生成と block `+0` write が中心  
2. `C7E0` 側は populate/read path がかなり進んでいるのに対し、`C21F` 側だけ richer readback が出ていない  
3. したがって `C21F` は現段階では rich candidate-state struct より、**block-head/index table** の可能性が相対的に上がっている

## 4. What Would Change The Picture

次のどれかが見つかれば、`C21F` richer struct 仮説は一段強くなる。

- `CALL $5B95/$60E2/$10CC` 後に `INC HL ; LD A,(HL)`
- block base に `ADD HL,offset`
- `LDI A,(HL)` を複数回まわす path
- `C21F + 16*n + k` (`k>0`) を読んだあと意味のある分岐や lookup に使う path

逆に、これが引き続き出ないなら、
`C21F` は shared builder の副産物でも
**block `+0` 中心の薄い table**
に留まる可能性が高い。

## 5. Updated Practical Focus

次の探索対象は:

1. `C21F` after-base read を持つ新規 caller
2. `HL=$C21F` を直接作る未整理断片
3. `C21F` ではなく `C20F/C7E0/C2F6` の接続補強

の順でよい。

## Implication
- `C7E0` は shared sparse remap/list として先に固めてよい
- `C21F` は rich struct と決めず、block-head/index table として保留するのが安全
- `60C0` shared builder も、現時点では `C21F` 側より `C7E0` 側のほうが実体が進んでいる

## Next Steps
1. `C21F` rich consumer が出るまでは、`C21F` 仮説を一段弱く保つ。
2. 代わりに `C20F/C7E0/C2F6` の接続面を進める。
3. 新しい raw 断片が取れたら、その時点で `C21F` after-base read の有無を再判定する。
