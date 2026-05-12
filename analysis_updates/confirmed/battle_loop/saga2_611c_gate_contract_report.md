# SaGa2 `611C` gate contract report

## 1. 目的

- `611C-6156` の gate 部、特に `RST $08(E=$15)` / `CALL $01B9` / `CALL $019E` の契約を整理する
- `0198` backing state に近い hidden seed helper 候補として、どこまで安全に言えるかをまとめる

## 2. 結論

現時点で `611C-6156` の gate 部は、
かなり自然に次の 4 段として読める。

1. `RST $08(E=$15)`  
   **candidate/selector UI dispatch**
2. `CALL $01B9`  
   **current selection resolve/refresh**
3. `FF8C` / `CALL $5F07`  
   **selection validity gate**
4. `C73D + A -> CALL $019E`  
   **resolved seed byte の反映/commit**

重要なのは、この流れが
visible event/message そのものより
**player-local seed と current pick を結びつける gate**
として整合する点である。

したがって `611C` は、
いまのところ `C2F6` producer そのものとはまだ言えないが、
`0198` backing state に近い **hidden-local seed helper**
候補として最上位に置いてよい。

## 3. 対象コード

```text
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

## 4. `RST $08(E=$15)` の意味

既報 `saga2_rst08_dispatch_contract_report.md` の整理では、
`RST $08` は `E` code 付き visible dispatch primitive だった。

そのうえで `611C` では:

```text
613B: LD E,$15
613D: RST $08
```

と固定 code を使っている。

ここから安全に言えるのは、
`E=$15` が:

- generic event wait ではなく
- `611C` 専用の candidate/selectable state を扱う dispatch

である可能性が高いことだ。

少なくとも `611C` の前半で
`C20F` fill と `C73D` seed 初期化を済ませてから呼んでいるため、
**seeded candidate state を可視/選択可能にする dispatch**
とみるのが自然である。

## 5. `CALL $01B9` と `FF8C`

`611C` 後半は:

```text
613E: CALL $5F0E
6141: XOR A
6142: CALL $01B9
6145: LDH A,($FF8C)
6147: CP $FF
6149: RET Z
```

同系の並びは既報 `6621-662B` にもある。

```text
6621: CALL $01B9
6624: LDH A,($FF8C)
6626: CP $FF
6628: JP Z,$65A3
662B: CALL $5F07
```

この共通性から、
`01B9` はかなり強く:

- current selector/candidate を resolve し
- 結果を `FF8C` へ置く

helper とみるのが自然である。

つまり `FF8C == $FF` は
**no selection / invalid selection / no adoptable entry**
のいずれかを表す sentinel 候補であり、
`611C` ではその場合 carry を立てずに失敗返ししている。

## 6. `CALL $5F07`

`5F07` も `611C` と `662B` の両方で gate として使われている。

```text
614A: CALL $5F07
```

```text
662B: CALL $5F07
662E: AND A
662F: JP NZ,$65A3
```

後者では明示的に
**`5F07` の返り値を `AND A` で失敗判定**
している。

したがって `611C` においても `5F07` は:

- `FF8C` で指された current selection を検証/正規化し
- 何らかの index `A` を返す

helper とみるのがもっとも自然である。

ここで重要なのは、
`5F07` が visible event helper より
**selection gate / resolve helper**
として振る舞っている点である。

## 7. `C73D + A -> CALL $019E`

`5F07` のあと:

```text
614D: LD HL,$C73D
6150: RST $00
6151: LD A,(HL)
6152: CALL $019E
6155: SCF
6156: RET
```

ここでは `A` を index にして `C73D..C744` から 1 byte seed を引き、
それを `019E` へ渡している。

安全に言えるのは次の 2 点。

1. `019E` の入力は `C73D` seed table の current resolved byte  
2. `611C` 成功返しは、その byte を `019E` が受理したあとにだけ起きる

したがって `019E` は:

- current resolved seed byte の commit
- current player-local candidate state への反映

のどちらかに近い helper とみるのが自然である。

厳密な書き込み先は未確定だが、
少なくとも message helper ではなく
**resolved seed byte consumer**
である可能性が高い。

## 8. 安全な高位擬似コード

現時点の安全な高位擬似コードは次の程度。

```ts
function seedAndValidatePlayerLocalCandidate(player: number): boolean {
  resetPlayerLocalCandidateBuffer(player)   // C20F + 16*player = FF
  initSeedTable(C73D, [0xF0..0xF7])

  dispatchByCode(0x15)
  refreshVisibleState()

  resolveCurrentSelection()                 // 01B9 -> FF8C
  if (FF8C === 0xFF) return false

  const remapIndex = validateOrResolveSelection() // 5F07 -> A
  const seedByte = C73D[remapIndex]
  consumeResolvedSeedByte(seedByte)         // 019E
  return true
}
```

ここで `consumeResolvedSeedByte()` の副作用先が、
今後 `C2F6` とつながる可能性を持つ。

## 9. `C2F6` 探索への意味

この整理でさらに強くなったのは、
`611C` がただの visible validator ではなく、
**current pick を seed byte へ落として次段へ渡す gate**
だという点である。

そのため `0198` backing state に最も近い候補は、
引き続き `611C` 周辺でよい。

特に次に見るべき接点は:

1. `019E` の書き込み先  
2. `5F07` が返す index の値空間  
3. `FF8C` がどの selection domain を持つか

である。

## 10. 次の一手

1. `019E` の contract を切って、resolved seed byte の反映先を探る  
2. `5F07` を selector resolve helper として切り、`A` の値域を固める  
3. `01B9` を `FF8C` writer として整理し、`611C` と `6621` の共通 gate をまとめる
