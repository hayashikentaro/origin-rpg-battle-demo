# SaGa2 `019E` Writeback-Candidate Ranking Report

## Summary
- `019E` の direct body が未確認でも、既存 evidence だけで **「どの state 群を先に疑うべきか」** はかなり整理できる。
- 現時点で最も自然なのは、`019E` が `611C` の inner core 内で **player-local hidden seed/selection state** か **`C2F6` に近い shared optional-entry backing state** へ寄る writeback を持つ、という線である。
- 逆に、`C7EE`, `C200`, `D400/D500` のような `6157` 以降の apply/staging 層や、`C7E0` sparse remap table へ直接書く線は優先度を下げてよい。

## 1. Boundary That Matters

既報の 4 層モデル:

1. `5F22`: global precondition  
2. `5E77`: visible precondition  
3. `611C`: local seed/selection gate  
4. `6157`: per-player apply/staging  

ここで重要なのは、
`019E` が明示的に見えているのは **3 層目の `611C` 内だけ** であり、
`6157` はその成功後にだけ走る後段だという点。

したがって `019E` writeback を疑う順序は:

- まず `611C` 内側の local/hidden state
- 次に `0198/C2F6` 系 shared backing state
- 最後に `6157` 以降の apply/staging state

の順になる。

## 2. High-Priority Candidates

### A. player-local hidden seed/selection state

理由:

- `611C` は `C20F + 16*player` clear と `C73D` seed table init を前提に動く
- `01B9 -> FF8C -> 5F07 -> C73D[index] -> 019E` の chain は完全に local gate の中に閉じている
- `CALL $019E` の直後に `SCF ; RET` するため、成功 commit はまず local gate の完了を意味すると読むのが自然

このため、
`019E` 最初の writeback は
**current player の hidden-local selection/seed result**
である可能性が最も高い。

### B. `C2F6` に近い shared optional-entry backing state

理由:

- `0198` は `C2F6` 系を読む shared optional-entry presence predicate
- `611C` はその近傍にある local seed/selection gate として最上位候補
- `019E` はその gate の commit frontier

つまり direct `C2F6` write はまだ未確認でも、
**`019E` -> hidden-local update -> 後 phase で `C2F6` availability に反映**
という形は十分 plausible である。

## 3. Medium-Priority Candidates

### C. `C20F` player-local selector workspace

`C20F` は `611C` 入口で 16 byte 全消去される
player-local selector/candidate work record である。

ただし現時点の evidence では:

- `C20F` は gate の前提 workspace としては強い
- `019E` がその一部 byte を直接更新する証拠はまだない

したがって完全除外ではないが、
**local hidden result field が `C20F` 内にある** と断言するにはまだ弱い。

## 4. Low-Priority Candidates

### D. `C7E0` shared sparse remap/list

`C7E0` は low-range selector で読む shared sparse remap table としてはかなり強いが、
`019E` に渡る resolved seed byte と役割が遠い。

`C7E0` は:

- `logicalIndex -> physicalSlot/sourceIndex`
- `FF` sentinel

という selector infrastructure 側の table であり、
seed byte commit の直受け先としては優先度を下げてよい。

### E. `C7EE`, `C200`, `D400/D500`

これらは `6157` 後段で初めて強く見える。

- `C7EE`: player-local scratch header
- `C200`: visible/main local record
- `D400/D500`: battle-side apply/staging/init

`019E` は `6157` より前にあり、
しかも `6157` は `611C` 成功後にだけ走る。

よって `019E` の最初の writeback が
**いきなりこの apply/staging 層へ落ちる**
と考える必要は薄い。

## 5. Practical Search Order

次に `019E` を詰めるときの観測順序は次でよい。

1. `611C` 内側 local hidden state 候補  
2. `0198/C2F6` に近い shared backing state 候補  
3. `C20F` local workspace 内 hidden field 仮説  
4. `6157` 以降の apply/staging 群  

この順なら、`019E` を early commit helper として読む現在の evidence と整合する。

## Implication
- `019E` の writeback 候補は「local hidden -> shared backing -> visible/apply」の順で疑うのが自然
- `6157` 以降の state は後段すぎるため、初手の疑い先から外してよい
- 次の主戦場は依然 `611C` 近傍と `C2F6` 近傍である
