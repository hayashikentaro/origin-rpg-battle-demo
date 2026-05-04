# SaGa2 `6332` success rebuild report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_62a2_6330_cluster_report.md`

## 目的

- `62DD: CALL $6332` の success-side helper を切る
- 成功時にどの workspace が更新されるかを整理する

## 結論

`6332` は単なる success 演出 helper ではなく、
**`player_index ($C709)` を軸に `C2DA` packed table と `C206` 系 record 群を走査/再構築する post-success rebuild helper**
候補とみるのが最も自然。

今回確度高く言えるのは次の 4 点。

1. `6332` は `C709` を退避しつつ、`0..3` を回して内部 helper `636C` を反復している  
2. その中で `HL=$C2DA`, `BC=$0E00` の 14件 loop があり、low nibble 非 0 entry だけを処理している  
3. 後半では `HL=$C206` / `HL=$C204` を起点に `019B` helper を通し、`0C:7F80` banked table 参照や `C785` 更新を伴っている  
4. したがって success path の本体は「メッセージを出す」より、**selection/runtime table の状態更新** にある可能性が高い

つまり `62DD-62F0` は

- budget spend
- success-side rebuild (`6332`)
- UI/event helper (`5E35`, `5E65`, `RST $08`)

の 3 段とみるのが安全。

## 1. entry

success path:

```text
62DD: LD A,$33
62DF: LDH ($FFB2),A
62E1: CALL $6332
62E4: CALL $5E35
62E7: LD DE,$1C1B
62EA: CALL $5E65
62ED: LD E,$1D
62EF: RST $08
```

`6332` は success path からの唯一の direct caller である。

## 2. `6332` の高位構造

先頭:

```text
6332: LD A,($C709)
6335: PUSH AF
6336: XOR A
6337: CALL $636C
633A: INC A
633B: CP $04
633D: JR C,$6337
633F: CALL $0198
6342: JR Z,$6347
6344: CALL $636C
6347: LD BC,$0E00
634A: LD HL,$C2DA
```

ここから、

- 元の `C709` を保存
- `A=0..3` で `636C` を反復
- 追加条件付きでもう一度 `636C`
- その後 `C2DA` 14件 loop

という構造が見える。

したがって `6332` は 1件処理 helper ではなく、
success 後の **cluster-wide rebuild** に近い。

## 3. `C2DA` 14件 loop

中盤:

```text
6347: LD BC,$0E00
634A: LD HL,$C2DA
634D: PUSH HL
634E: LDI A,(HL)
634F: AND $0F
6351: JR Z,$6360
6353: LD E,L
6354: LD D,H
6355: LD HL,$7F80
6358: LD A,C
6359: RST $00
635A: LD A,$0C
635C: CALL $00D2
635F: LD (DE),A
6360: POP HL
6361: INC HL
6362: INC HL
6363: INC C
6364: DEC B
6365: JR NZ,$634D
6367: POP AF
6368: LD ($C709),A
636B: RET
```

これはかなり素直に、
`C2DA` 各 entry の low nibble 非 0 なものについて
`0C:7F80 + index` 由来 byte を current entry へ書き戻す pass
と読める。

つまり success 後には
**`C2DA` packed seed table の byte0/byte1 が再正規化される**
可能性が高い。

## 4. `636C` helper

`636C` 以降:

```text
636C: LD ($C709),A
636F: LD HL,$C206
6372: CALL $019B
6375: LDI A,(HL)
6376: AND $90
6378: JP NZ,$6436
...
63D8: LD A,($C709)
63DB: LD HL,$C204
63DE: CALL $019B
...
63F8: LD H,A
63F9: LD L,B
63FA: LD DE,$C785
...
6417: LD HL,$C20F
641A: LD A,($C709)
641D: CALL $019B
...
6430: CALL $643A
6433: DEC B
6434: JR NZ,$6416
6436: LD A,($C709)
6439: RET
```

確定できるのは、

- `C206`
- `C204`
- `C20F`
- `C785`

を巻き込み、
さらに `0C:7F80` banked lookup と `643A` local helper を使っていること。

これだけで、
`636C` が単なる message helper ではなく
**player/actor-local selection records を更新する worker**
だと言える。

## 5. `643A` の位置づけ

`643A` は:

```text
643A: PUSH DE
643B: PUSH HL
643C: LD HL,$7E80
643F: LD A,$0C
6441: CALL $00D2
6444: POP HL
6445: POP DE
6446: RET
```

なので、
**`0C:7E80` lookup を 1 byte 返す local helper**
である可能性が高い。

`636C` ではこれを通して `C785` 付近へ書く path が見えるため、
success 後に selector/display-side の補助表を更新している可能性が高い。

## 6. 現時点の擬似コード

安全な高位擬似コードは:

```ts
function onSuccessRebuild(savedPlayerIndex: number) {
  for (let player = 0; player < 4; player++) {
    rebuildPlayerSelectionState(player);
  }

  if (extraPlayerExists()) {
    rebuildPlayerSelectionState(currentPlayer);
  }

  for (let i = 0; i < 14; i++) {
    if ((C2DA[i].byte0 & 0x0f) !== 0) {
      C2DA[i].byte1 = table7F80[i];
    }
  }

  C709 = savedPlayerIndex;
}
```

ここで `rebuildPlayerSelectionState` の内部では、
`C206/C204/C20F/C785` を更新しているとみるのが自然。

## 7. 移植上の意味

TypeScript 側では、success path を

```ts
spendBudget()
rebuildSelectorStateAfterSuccess()
emitUiEvent()
```

に分けるほうがよい。

特に `6332` は `battle` や `rng` 本体へ入れず、
selector-runtime / inventory-selection 側の post-success rebuild として
分離したほうが安全。

## 8. まだ未確定な点

- `C206/C204/C20F` の厳密な field 意味
- `0198` と `019B` の契約
- `643A` 戻り値が `C785` に何として入るか
- success が具体的に item/shop/script のどのドメインか

## 次の一手

1. `019B -> 05D9` を切って `C206/C204/C20F` の indexing 規則を確定する
2. `643A` caller 文脈を追って `C785` 更新の意味を整理する
3. `6332` と `64B0` の前後関係を caller cluster 単位で固定する
