# SaGa2 `C2F6` Search Reprioritization Report

## Summary
- `C20F`, `C7E0`, `C21F` の role 整理が進んだ結果、`C2F6` producer 探索の実務順は少し更新したほうが自然になった。
- 以前は `60C0-60E1`, `60E8-611B`, `611C-6156` を横並び Aランクに置いていたが、現在は **`611C` を最上位、`60E8` をその上位 orchestration、`60C0` を shared builder 補助線** と見るほうが整合する。
- つまり今いちばん有力なのは「`611C` に近い hidden-local seed 層をさらに詰めつつ、その前段として `60E8/60C0` を参照する」線であって、`60C0` 単体を最初に掘る優先度は相対的に下がった。

## 1. Why The Priority Changed

### `611C`
いま最も強いのは:

- `C20F + 16*player` clear
- `C73D..C744` seed/remap
- `FF8C -> 5F07 -> 019E`

が 1 本に束ねられている点。

これは `0198` backing state に最も近い
**hidden-local seed/selection gate**
として読める。

### `60E8`
`60E8-611B` は:

- `5F22`
- `5E77`
- `611C`
- `6157`

を結ぶ parent orchestration loop であり、
`611C` を per-player に起動する上位 entry として重要。

ただし `C2F6` direct producer を示す場所としては、
`611C` 本体より一段抽象度が高い。

### `60C0`
`60C0-60E1` は:

- `C21F` block head
- `C7E0` sentinel/remap list

を作る shared builder としては有力だが、
現時点では `C21F` richer field の readback がなく、
`C2F6` との direct bridge も見えていない。

したがって `C2F6` producer の主線というより、
**shared前段を補強する補助線**
として置くほうが安全になった。

## 2. Updated Priority Tiers

### Aランク
1. `611C-6156`  
   hidden-local seed / selection gate 本命
2. `60E8-611B`  
   `611C` を起動する parent orchestration / subsystem entry

### Bランク
3. `60C0-60E1`  
   shared builder 補助線
4. `6157-61FF`  
   apply/staging 後段
5. banked import/export residuals

### Cランク
6. overlay alias 仮説

## 3. What This Means Practically

次のターン以降は、

1. `611C` と `0198/C2F6` の距離をさらに詰める  
2. その前段として `60E8` を参照する  
3. `60C0` は shared builder 補助線として必要時だけ使う

という順にしたほうが、
探索コストに対して得られる情報量が大きい。

## 4. Safe Current Picture

```ts
// closest to hidden/local optional-seed logic
seedAndValidatePlayerLocalCandidate(player) // 611C

// parent entry that launches per-player local gate
prepareParentSelectionLoop() // 60E8

// shared candidate/remap builder, useful but one step farther
buildSharedCandidateState() // 60C0
```

この 3 段のうち、
`C2F6` producer に最も近いのは今のところ `611C` である。

## 5. Why This Does Not Contradict Earlier Work
以前 `60C0-6156` を 3 段 hidden/shared seed layerとしてまとめた整理は、
層の並びとしては依然正しい。

今回変わるのは
**実務上どこから当てるのが最も効率がよいか**
であり、
構造図そのものを否定するわけではない。

## Next Steps
1. `611C` を `0198/C2F6` との近接観点で再度絞る。
2. `60E8` は `611C` 前提の one-shot entry として補助的に参照する。
3. `60C0` は `C2F6` direct 主線より shared-builder 補強線として扱う。
