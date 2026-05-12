# SaGa2 `611C` Inner-Core Priority Report

## Summary
- `611C` inner core を `01B9 -> FF8C -> 5F07 -> C73D[index] -> 019E` と分けたうえで見ると、**`C2F6` producer/commit に最も近い本命は `019E`** とみるのが自然。
- `01B9` は current-selection token materializer、`5F07` は local-index remap、`C73D` は seed byte source であり、実際に state を変える可能性が最も高いのは末尾の `019E` だからである。
- したがって `611C` を次に詰める優先順位は、`019E` writeback 先、次に `FF8C` token domain、最後に `5F07` index domain、の順に置くのが効率的。

## 1. Inner Core Chain Restated

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

高位には:

1. `01B9`  
   current selection token を `FF8C` に materialize
2. `5F07`  
   token を local index へ remap/validate
3. `C73D[index]`  
   resolved seed byte を与える
4. `019E`  
   resolved seed byte を consume/commit

## 2. Why `019E` Is Closest To The Producer Question

### `01B9`
- token を置く
- side effect はあるが、役割は selection materialization

### `5F07`
- validate/remap
- index domain 変換

### `C73D`
- data source

### `019E`
- resolved seed byte を受け取る終端 helper
- `611C` はその直後に `SCF ; RET`
- caller 文脈上、ここが成功 commit 点

この比較から、
**state mutation の主効果が最も集中しているのは `019E`**
とみるのが自然。

## 3. Practical Priority Inside `611C`

### Priority 1: `019E`
狙うもの:

- direct body
- writeback 先
- hidden-local commit state

### Priority 2: `FF8C`
狙うもの:

- token domain 差
- `611C / 6621 / 62BE` の比較

### Priority 3: `5F07`
狙うもの:

- local index range
- `C73D` 以外への接続有無

この順なら、
「selection domain を理解してから commit 先を探す」
より、
**まず commit 先を押さえる**
ほうが `C2F6` に早く近づける。

## 4. What This Means For `C2F6`

`C2F6` が `0198` の backing state だとして、
`611C` がその近傍にいるなら、
最もあり得る接点は:

- `019E` が hidden-local state を更新し
- その結果が別 phase で `C2F6` availability/presence として見える

という形である。

もちろん direct write はまだ未確認だが、
現時点で最も plausible な接続面はここ。

## 5. Safe Current Model

```ts
resolveCurrentSelection()         // 01B9 -> FF8C
const localIndex = remapToken()   // 5F07
const seedByte = C73D[localIndex]
commitResolvedSeedByte(seedByte)  // 019E
```

ここで最も “stateful” なのは最後だけである。

## 6. Updated Next Step
1. `019E` の direct body / writeback 先を最優先で探る  
2. `FF8C` token 空間の比較はその次  
3. `5F07` index domain は補助線として維持

## Implication
- `611C` inner core の中でも、全部を同じ重さで追う必要はない
- `019E` は commit point、`01B9/5F07` は前段変換層
- 次に `C2F6` へ近づく最短線は `019E`
