# SaGa2 battle prepass orchestration report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_c21f_block_builder_report.md`
- 既存 `saga2_battle_prepass_page_seed_report.md`

## 目的

- `01:60E8-611B` と `611C / 6157` の契約を切る
- `60C0` 近辺の builder 群が battle prepass のどの段を担っているかを整理する
- `C7EE` / `C73D` / `C20F` が `C21F` 系と同一責務かどうかを分離する

## 結論

今回の整理で、`01:60E8-611B` は
**`player_index ($C709)` を回しながら `611C` と `6157` を使う player-by-player orchestration loop**
とみるのが自然になった。

特に強い確定点は 3 つある。

1. `6157` は `C200 + 16*player` と `C7EE` の **4 byte scratch copy** を含む  
2. `61EB-61FB` に逆向き copy があり、`C7EE` は battle prepass の flat list ではなく **player-local scratch buffer** とみるほうが自然  
3. `611C` は `C20F + 16*player` を `FF` 埋めし、`C73D..C744` を `F0..F7` で初期化する **candidate/selector seed helper** 候補

したがって、`60C0-60E1` が生成する `DE` 側 `FF` list を
そのまま `C7EE` とみなす根拠は弱くなった。
`C21F` block table / `DE` sentinel list と、
`611C/6157` が使う `C7EE/C73D/C20F` は
**同じ大きな battle/item setup cluster には属するが、別の中間表レイヤ**
として分けて扱うほうが安全。

## 1. `60E8-611B` の骨格

実バイト:

```text
60E8: CALL $5F22
60EB: CALL $5E77
60EE: LD A,$01
60F0: LD ($C709),A
60F3: CALL $611C
60F6: JR NC,$610F
60F8: CALL $6157
60FB: JR NC,$60F3
60FD: LD A,($C709)
6100: INC A
6101: CP $04
6103: JR C,$60F0
6105: LD HL,$C700
6108: XOR A
6109: LDI (HL),A
610A: LDI (HL),A
610B: LD (HL),A
610C: JP $5EB4
610F: LD A,($C709)
6112: CP $02
6114: JR C,$60F3
6116: DEC A
6117: LD ($C709),A
611A: JR $60F8
```

ここから見えるのは:

- `C709` を `1,2,3` と進める player loop
- `611C` が gate / validator
- `6157` が apply / update 側
- 失敗時には `610F-611A` で index 調整して再試行

つまり `60C0` の直後にある `60E8+` は、
単なる builder continuation ではなく
**battle/item setup の高位オーケストレータ**
として読むほうが自然。

## 2. `611C` の局所契約

実バイト:

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

強く言える範囲では:

- `CALL $019B` により `HL = C20F + 16*player` へ進む
- `CALL $006D` はそこで **16 byte を `FF` 埋め** している可能性が高い
- `C73D..C744` は `F0,F1,...,F7` で初期化される
- `FF8C` が `FF` なら失敗返し
- 非 `FF` なら `CALL $5F07` の戻り値を `C73D + A` で引き、その値を `CALL $019E` へ渡している

したがって `611C` は、
`C20F` / `C73D` を使う
**candidate list / selector remap の初期化 + 1件選択可否判定**
に近い helper 候補で、
`C21F` block builder そのものとは役割が別とみるほうが安全。

## 3. `6157` は `C7EE` scratch copy を含む

実バイト先頭:

```text
6157: LD A,($C709)
615A: LD HL,$C200
615D: CALL $019B
6160: LD DE,$C7EE
6163: LD B,$04
6165: CALL $0080
```

ここでは `C200 + 16*player` から `C7EE` へ
**4 byte copy**
が走っていると読むのが自然。

`common.i` では `C7EE = name_buffer` だが、
少なくとも battle/item setup 中では
**4 byte player-local scratch header**
として使われている可能性が高い。

## 4. `61EB-61FB` に逆向き copy がある

後半:

```text
61EB: LD A,($C709)
61EE: LD HL,$C200
61F1: CALL $019B
61F4: LD E,L
61F5: LD D,H
61F6: LD HL,$C7EE
61F9: LD B,$04
61FB: CALL $0080
61FE: AND A
61FF: RET
```

ここでは今度は
`C7EE -> C200 + 16*player`
の **逆向き 4 byte copy** が見えている。

この対称性から、
`C7EE` は `60C0` builder の `DE` destination ではなく、
player 単位で一時退避・再書き戻しする
**scratch header buffer**
として扱うほうが自然。

## 5. `6157` の後段

`6157` 以降には:

```text
6168: CALL $5DF8
616B: LD E,$2C
616D: RST $08
616E: LD E,$2D
6170: LD A,$02
6172: CALL $01C5
6175: LD HL,$D400
6178: LD B,$00
617A: CALL $006C
617D: LD ($C7D6),A
6180: LD HL,$D500
6183: LD BC,$0170
6186: LD A,$FF
6188: CALL $0073
```

などが続く。

細部は未確定だが、
少なくとも `6157` は単なる `C7EE` copy helper ではなく、
**`D400/D500` family を含む battle-side staging / init**
まで担っている高位 routine とみるのが自然。

## 6. `60C0` builder との関係

今回の範囲で分かったのは、
`60C0-60E1` と `60E8+` が隣接していても、
その責務は分けて読むほうが安全ということ。

- `60C0-60E1`
  - 14件 2byte entry を走査
  - `C21F + 16*block` の `+0` に `sourceIndex`
  - `DE` 側へ `FF` sentinel list
- `611C`
  - `C20F + 16*player` を `FF` 埋め
  - `C73D..C744 = F0..F7`
  - `FF8C` 選択値ベースの validator
- `6157`
  - `C200 <-> C7EE` の 4 byte scratch copy
  - `D400/D500` を含む後段 staging

したがって `60C0` の `DE` destination を追うにしても、
候補は `C7EE` より
**別の flat list / sentinel buffer**
を優先したほうがよい。

## 移植への意味

TypeScript / Godot 側では、battle prepass を最初から 1 本の巨大 routine とせず、
少なくとも次の 3 層に分けておくのが安全。

```ts
buildBlockIndexFromPackedEntries()
validateOrPickPlayerLocalCandidate()
applyPlayerLocalBattleStaging()
```

`C21F` block table と `C7EE` scratch header は
同じ battle prepare phase に属していても、
同一 struct に潰さないほうが整理しやすい。

## 次の一手

1. `60C0` caller 文脈で `DE` destination 実体を固定する
2. `611C` 内の `RST $08 (E=$15)` と `CALL $01B9` の契約を切る
3. `6157` 後半の `D400/D500` 初期化を `battle page staging` として field 化する
