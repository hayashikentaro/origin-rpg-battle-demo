# SaGa2 `611C` Core-vs-Visible Boundary Report

## Summary
- `611C` は一枚岩ではなく、`C2F6` に近い **core seed/selection gate** と、visible side に寄る **presentation/refresh edge** に分けて持つほうが整理しやすい。
- 現時点で最も安全なのは、`RST $08(E=$15)` と `CALL $5F0E` を outer edge、`01B9 -> FF8C -> 5F07 -> C73D[index] -> 019E` を inner core とみる分け方である。
- この境界を引くことで、`C2F6` producer 探索は `611C` 全体より **inner core chain** に重点を置ける。

## 1. `611C` Whole Shape

```asm
611C: CALL $5DF8
611F: LD A,($C709)
6122: LD HL,$C20F
6125: CALL $019B
6128: LD A,$FF
612A: LD B,$10
612C: CALL $006D
612F: LD HL,$C73D
6132: LD B,$08
6134: LD A,$F0
6136: LDI (HL),A
6137: INC A
6138: DEC B
6139: JR NZ,$6136
613B: LD E,$15
613D: RST $08
613E: CALL $5F0E
6141: XOR A
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

## 2. Outer Edge

### `RST $08(E=$15)`
既報では:

- seeded candidate presentation/selection dispatch
- `C20F` と `C73D` 初期化後にだけ現れる

つまり `611C` の入口ではあるが、
役割としては **candidate set を selection chain へ露出させる presentation-side edge**
とみるのが自然。

### `CALL $5F0E`
既報 `5F` refresh family から、
`5F0E` は visible refresh/finalize 寄りの helper と読むのが安全だった。

したがって `613E: CALL $5F0E` は、
`01B9` 以降の local token/seed 処理そのものより
**selection resolve 前の visible sync edge**
として外縁に置ける。

## 3. Inner Core

### `01B9 -> FF8C`
- current selection token materialize
- `0xFF` sentinel で失敗

### `5F07`
- token を local index へ validate/remap

### `C73D[index]`
- resolved local index に対応する seed byte

### `019E`
- resolved seed byte consumer / commit

この 4 段は、
visible refresh より
**current pick -> local index -> seed byte -> commit**
という hidden-local state transition そのものに近い。

## 4. Why This Boundary Helps

`611C` を丸ごと `C2F6` 近傍と見ると、
visible dispatch / refresh のノイズが混ざる。

しかし次のように切ると見通しがよい。

```ts
prepareLocalSeedWorkspace(player)      // C20F, C73D
dispatchSeededCandidateSet()           // RST $08(E=$15)
refreshVisibleSelectionState()         // 5F0E

resolveCurrentSelectionToken()         // 01B9 -> FF8C
if (tokenInvalid()) return false
const localIndex = remapSelectionToken() // 5F07
const seedByte = readSeedByte(localIndex) // C73D[index]
commitResolvedSeedByte(seedByte)         // 019E
```

このうち `C2F6` に最も近いのは、
下半分の **inner core chain** である可能性が高い。

## 5. Updated Focus Inside `611C`

優先順位は次のように寄せられる。

1. `019E` の commit 先
2. `5F07` の local index domain
3. `FF8C` token 空間
4. そのあとで `RST $08(E=$15)` と `5F0E` の outer edge を補助的に見る

## 6. Implication For `C2F6`
- `C2F6` producer が `611C` 近傍にあるとしても、
  それは `RST $08` や `5F0E` の visible edge より、
  `01B9/FF8C/5F07/019E` の local core chain に近い可能性が高い。
- したがって `611C` を次に詰めるなら、
  visible side effect をこれ以上広げるより
  core chain の side effect 先を狙うほうが効率がよい。

## Next Steps
1. `019E` の direct body / writeback 先を最優先で探る。
2. `FF8C` token 空間の domain 差を `611C/6621/62BE` で比較する。
3. `5F07` の戻り index が `C73D` 以外へ落ちる caller があるか確認する。
