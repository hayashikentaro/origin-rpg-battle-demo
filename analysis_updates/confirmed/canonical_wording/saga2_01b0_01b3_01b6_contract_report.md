# SaGa2 `01B0/01B3/01B6` contract report

## 1. 目的

- `01B0`, `01B3`, `01B6` を shared reset / selector setup family として切る
- `5E0D-5E77` helper 群の前後関係を contract レベルで整理する
- `C2F6` producer 探索からどこまで除外できるかを明確にする

## 2. 結論

現時点の caller 文脈を合わせると、
`01B0/01B3/01B6` はかなり自然に次のように分かれる。

1. `01B0` は **shared reset / wait-ready 前段 helper** 候補  
2. `01B3` は **`5E31/5E35` reset family の tail exit** 候補  
3. `01B6` は **selector/UI dispatch 直前 setup helper** 候補

重要なのは、この family が触っているのが
`C797/C798`, `C7A6`, `CC00`, `C796`, `C7DA`, `FF9B` などの
visible runtime state に偏っていることだ。

したがって `0198 -> C2F6` の immediate caller より前段を見ても、
この contract family 自身は
**`C2F6` hidden backing state の producer ではなく consumer-side setup**
とみるのが安全である。

## 3. `01B0`: reset family の共通前段

もっとも強い caller は `5E40`:

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

ここでは `01B0` の直後に:

- `C7A6` clear
- `CC00` clear
- `C796`, `C7DA` clear

が続く。

別 caller では `62F9`:

```text
62F9: CALL $01B0
62FC: RST $08
62FD: CALL $0174
6300: CALL $01A7
6303: AND A
6304: JR Z,$62FC
```

ここでは event/message 後の post-event wait loop 入口として使われている。

この 2 つを合わせると、`01B0` は

- 自前で大きい table を構築する helper ではなく
- **後続 reset / wait / dispatch を安全に始める共通前段**

として読むのが自然である。

現時点の安全な抽象名は:

```text
beginSharedUiTransition()
```

程度が妥当。

## 4. `01B3`: reset family の tail exit

`01B3` は direct body 未確定だが、
`5E31/5E35` がどちらもここへ tail jump している。

```text
5E31: XOR A
5E32: LD ($C798),A
5E35: CALL $5E40
5E38: LD HL,$C797
5E3B: LDI (HL),A
5E3C: LD (HL),A
5E3D: JP $01B3
```

```text
5E35: CALL $5E40
5E38: LD HL,$C797
5E3B: LDI (HL),A
5E3C: LD (HL),A
5E3D: JP $01B3
```

この構造から少なくとも言えるのは:

- `01B3` は reset family の continuation
- `5E31/5E35` で caller-local reset 値を `C797/C798` に揃えたあと入る
- `5E40` が visible scratch clear を終えたのちの **共通 exit / finalize**

であることだ。

したがって `01B3` は `C2F6` producer としてより、
**shared reset 終了処理**
として持つのが安全である。

## 5. `01B6`: dispatch 前段 setup

もっとも強い caller は `5E6C`:

```text
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

- local visible scratch (`FF9B`, `C796`) を初期化
- `DE=$0504`
- `01B6`
- `RST $08`
- `0198` presence gate

という順になっている。

つまり `01B6` は:

- hidden optional-entry state を作るのでなく
- **`RST $08` dispatch と `0198` gate の前に必要な selector/UI setup**

として挟まっている可能性が高い。

現時点の安全な抽象名は:

```text
prepareSelectorDispatch()
```

程度。

## 6. 3 本の関係

caller 構造から見える高位の関係は次のようになる。

```ts
function resetSharedUiSelectorState() {
  beginSharedUiTransition()   // 01B0
  clearVisibleBuffers()       // 5E40 body
  finalizeSharedReset()       // 01B3
}

function dispatchOptionalSelectorEntry() {
  resetLocalDispatchScratch()
  prepareSelectorDispatch()   // 01B6
  dispatchBaseEntry()         // RST $08
  if (!checkOptionalEntryPresence()) return
  dispatchResolvedOptionalEntry()
}
```

これで `5E0D-5E77` family は、
少なくとも contract レベルでは
`reset`, `dispatch-prepare`, `dispatch-gate`
の 3 段にきれいに分けられる。

## 7. `C2F6` 探索への意味

今回この family を切ったことで、さらに安全に言えるのは:

1. `01B0/01B3/01B6` は visible runtime state の reset / setup / finalize に寄っている  
2. immediate caller 前段をここまで掘っても、`C2F6` を direct に埋める clear/copy/write は出ていない  
3. したがって `C2F6` backing state は、この family と同層ではなく、さらに前段の hidden/shared init にある可能性が高い

つまり `C2F6` producer 探索は、
`5E` family や `01B0/01B3/01B6` family から
**shared hidden-state import / overlay reload**
側へ寄せるのが筋になる。

## 8. 次の一手

1. `5F2B/5F44/5F0E` を切って `5E0D` 後段 refresh を固める  
2. `RST $08` 側 caller family を切って `01B6` 後段 dispatch の返り値契約を詰める  
3. `C2F6` producer 探索は、`01B0/01B3/01B6` より前段の bulk init / overlay reload / banked import 側に絞る
