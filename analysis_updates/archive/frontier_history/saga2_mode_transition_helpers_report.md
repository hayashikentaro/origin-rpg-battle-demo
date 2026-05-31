# SaGa2 mode-transition helper report

## 1. 目的

- `5E0D/5E31/5E35/5E40/5E5A/5E77` 周辺を shared mode-transition helper 群として整理する
- `0198 -> 0608 -> C2F6` の immediate caller より前段にある wider setup として、どこまで `C2F6` producer 候補から外せるかを確認する

## 2. 結論

今回の確認で、`5E0D-5E77` はかなり自然に
**UI / selector / mode-transition 用の shared helper family**
としてまとまるようになった。

確度高く言えるのは次の 4 点。

1. `5E0D` は frame sync, OAM flush, local UI state refresh を束ねる高位 mode-transition entry 候補  
2. `5E31/5E35/5E40` は `C797/C798`, `C7A6`, `CC00`, `C796`, `C7DA` を初期化する shared reset family 候補  
3. `5E5A-5E76` は `FF9B`, `C796`, `C34A`, `DE=$0504` などを使う UI/selector dispatch 前段に見える  
4. この範囲では **`C2F6` を direct に埋める clear/copy/write はまだ見えていない**

したがって `0198` の caller 直前 wider setup を見ても、
`C2F6` backing state はこの helper family 自身ではなく、
さらに前段の shared init / overlay reload / hidden-state import で準備される可能性が高い。

## 3. `5E0D` の位置づけ

観測済み flow:

```text
5E0D: XOR A
5E0E: LDH ($FF96),A
5E10: CALL $5E31
5E13: RST $10
5E14: LD A,$CC
5E16: RST $18
5E17: CALL $5F2B
5E1A: CALL $5F44
5E1D: CALL $5F0E
5E20: LD A,$03
5E22: LDH ($FF96),A
5E24: RET
```

ここでは:

- `FF96` の mode/state byte を一時的に `0` へ
- `5E31` で local reset
- `RST $10` で frame sync
- `RST $18` で OAM DMA
- `5F2B/5F44/5F0E` で後段 refresh
- 最後に `FF96=03`

という流れが見える。

したがって `5E0D` は `C2F6` hidden state builder というより、
**画面・入力・selector 周辺の mode transition 入口**
とみるのが自然。

## 4. `5E31/5E35/5E40` reset family

### `5E31`

```text
5E31: XOR A
5E32: LD ($C798),A
5E35: CALL $5E40
5E38: LD HL,$C797
5E3B: LDI (HL),A
5E3C: LD (HL),A
5E3D: JP $01B3
```

### `5E35`

```text
5E35: CALL $5E40
5E38: LD HL,$C797
5E3B: LDI (HL),A
5E3C: LD (HL),A
5E3D: JP $01B3
```

### `5E40`

```text
5E40: CALL $01B0
5E43: LD HL,$C7A6
5E46: LD B,$20
5E48: CALL $006C
5E4B: LD HL,$CC00
5E4E: LD B,$A0
5E50: CALL $006C
5E53: LD ($C796),A
5E56: LD ($C7DA),A
5E59: RET
```

ここでかなり素直に見えるのは:

- `C7A6` から 0x20 byte clear
- `CC00` から 0xA0 byte clear
- `C796`, `C7DA` clear
- caller に応じて `C797/C798` を揃えて reset

という shared reset 動作である。

つまりこの family は
**visible UI/render/scratch state を初期化する helper**
としては強いが、
`C2F6` 付近の hidden optional-entry state を準備する線にはまだ見えない。

## 5. `5E5A-5E76` dispatch 前段

観測済み flow:

```text
5E5A: LD HL,$C34A
5E5D: LD B,$0A
5E5F: CALL $006C
5E62: LD DE,$0504
5E65: XOR A
5E66: LDH ($FF9B),A
5E68: XOR A
5E69: LD ($C796),A
5E6C: CALL $01B6
5E6F: RST $08
5E70: CALL $0198
5E73: RET Z
5E74: LD E,D
5E75: RST $08
5E76: RET
```

ここでは:

- `C34A` 10byte clear
- `FF9B`, `C796` clear
- `DE=$0504`
- `01B6` / `RST $08` で selector/UI side setup
- その後 `0198` で optional entry presence を確認

という流れが見える。

これは既報 `saga2_0198_immediate_caller_cluster_report.md` の
`5E70` caller 整理ともきれいにつながる。

したがって `5E5A-5E76` は
**dispatch 直前の local visible state 調整**
であって、`C2F6` producer そのものではない。

## 6. `5E77` の位置づけ

別 caller 文脈では `60EB: CALL $5E77` が見えている。

この helper は:

- `FF8B` を条件に分岐
- `00AC`, `0177`, `0080`, `017A`, `00CA` を通る
- VRAM/window/OAM 反映寄りの copy/update を伴う

という点から、
**mode transition 後の render/update helper**
として読むほうが自然である。

少なくともここも `C2F6` hidden state の builder というより、
visible screen-side update に属する。

## 7. `C2F6` 探索への意味

この helper family をまとめて見ると、
今回さらに強くなったのは次の点である。

1. `0198` の caller より前段を見ても、見えてくるのは `C797/C798`, `C7A6`, `CC00`, `C796`, `C7DA`, `FF9B`, `C34A` などの visible/runtime scratch 初期化である  
2. `C2F6` を base にした point write, clear, block copy はまだここでは出ない  
3. したがって `C2F6` backing state は、この family より **さらに前段の shared init / overlay reload / hidden import** に属する可能性が高い

つまり `5E0D-5E77` は
`C2F6` producer 探索においては
「候補入口」より **除外根拠を強める helper family**
として扱うのが安全である。

## 8. 現時点の擬似コード

安全な高位擬似コードは次の程度。

```ts
function resetSharedUiSelectorState(): void {
  clear(C7A6, 0x20)
  clear(CC00, 0xA0)
  C796 = 0
  C7DA = 0
  C797 = 0
  C798 = 0
}

function dispatchOptionalSelectorEntry(): void {
  clear(C34A, 0x0a)
  FF9B = 0
  C796 = 0
  setupSelectorDispatch()
  if (!checkOptionalEntryPresence()) return
  dispatchResolvedOptionalEntry()
}
```

重要なのは、ここにまだ `C2F6` producer が入っていないことだ。

## 9. 次の一手

1. `5F2B/5F44/5F0E` を切って `5E0D` 後段 refresh の責務を固める  
2. `01B0/01B3/01B6` を切って shared reset / selector setup family を contract 化する  
3. `C2F6` producer 探索は、この family より前段の bulk init / overlay reload / banked import 側へさらに寄せる
