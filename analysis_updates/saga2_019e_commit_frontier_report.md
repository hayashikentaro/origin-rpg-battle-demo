# SaGa2 `019E` Commit-Frontier Report

## Summary
- `611C` inner core を `01B9 -> FF8C -> 5F07 -> C73D[index] -> 019E` と分けて見ると、**`019E` は selection/resolve 層の外にある最初の state-mutation frontier** とみるのが自然。
- `01B9`, `FF8C`, `5F07`, `C73D` はいずれも token/materialize/remap/source の前段であり、`611C` が `CALL $019E` の直後に `SCF ; RET` することからも、成功 commit の主効果は `019E` 側へ寄っている可能性が高い。
- したがって `C2F6` producer を `611C` 近傍で追うなら、次に観測すべき境界は `019E` 自体であって、`FF8C` や `5F07` はその補助線として扱うのが効率的である。

## 1. Inner-Core Restatement

```asm
6142: CALL $01B9
6145: LDH A,($FF8C)
6147: CP $FF
6149: RET Z
614A: CALL $5F07
614D: LD HL,$C73D
6150: RST $00
6151: LD A,(HL)
6152: CALL $019E
6155: SCF
6156: RET
```

この流れを高位で言い直すと:

1. `01B9`: current selection token materialize  
2. `FF8C`: token storage / no-selection sentinel (`FF`)  
3. `5F07`: token -> local index remap  
4. `C73D[index]`: resolved seed byte source  
5. `019E`: resolved seed byte consume/commit  

## 2. Why `019E` Is The Frontier

前段 4 要素の役割は現時点でかなり分かれている。

- `01B9`: 選択状態を token 化する
- `FF8C`: token を保持する
- `5F07`: token を local domain へ写像する
- `C73D`: local seed byte を供給する

これに対して `019E` だけは、
caller 文脈上 **入力 byte を受け取った先で何かを確定させる**
位置にある。

`611C` が `CALL $019E` の戻り直後に `SCF ; RET` する以上、
`019E` の成否や副作用が gate 成功の本体である可能性が高い。

## 3. Safe Negative Claims

現時点で `019E` について安全に除外できること:

- `RST $08` 系の visible dispatch ではない
- `01B9` のような selection resolver ではない
- `5F07` のような remap/validate helper ではない
- `C73D` の builder や table init ではない

つまり `019E` は、seed byte を作る側ではなく、
**作られた seed byte を state に反映する側**
として持つのが自然。

## 4. What To Observe Next

`019E` から取りたい情報は 3 つに絞れる。

1. direct body  
   bank0 wrapper なのか、別本体へ飛ぶ thin wrapper なのか
2. writeback destination  
   player-local scratch, hidden-local buffer, shared presence state のどれに近いか
3. success contract  
   carry/zero などを caller が本当に見ているのか、それとも side effect-only か

この 3 点が埋まれば、`611C` と `C2F6` の距離をかなり短くできる。

## 5. Updated Priority

`611C` inner core の優先順位は次の順で固定してよい。

1. `019E` direct body / writeback destination  
2. `FF8C` token domain comparison (`611C`, `6621`, `62BE`)  
3. `5F07` local index domain  

要するに、いま必要なのは selection semantics の深掘りより、
**commit 先の観測** である。

## Implication
- `611C` は outer edge と inner core に分けて持つのが安全
- inner core の中でも `019E` だけが commit frontier に立っている
- `C2F6` producer 探索を続けるなら、次の主戦場は `019E` writeback 側である
