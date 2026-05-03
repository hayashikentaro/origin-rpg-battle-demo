# SaGa2 437E contract report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_actors_loop_report.md`
- 既存 `saga2_01e3_wrapper_report.md`

## 目的

- `0D:437E` の入出力契約を queue/action resolve 文脈で切る
- 通常攻撃本線へ降りる前の前処理かどうかを判断する

## 結論

`0D:437E` は現時点では、
**`D0xx` actor page 群を 5 回走査して、`C206` ベースの battle work buffer へ要約レコードを書き出す前処理 helper**
とみるのがかなり自然。

少なくとも:

- `D0xx` から始めて `D1xx..D4xx` へ page を進める
- 1 actor ごとに `C206 + 6*n` 付近へ数 byte 書く
- `FF` / `80` / `02` などの sentinel を使う
- 条件に応じて `C2DB + index` へ 1 byte を反映する

という構造が見える。

したがって `437E` は
通常攻撃やダメージ本体というより、
**battle actor state / command candidate の正規化・展開**
に近い helper 候補。

## 1. 実バイト

```text
437E: AF          XOR A
437F: 16 D0       LD D,$D0
4381: 06 05       LD B,$05
4383: F5          PUSH AF
4384: C5          PUSH BC
4385: D5          PUSH DE
4386: 21 06 C2    LD HL,$C206
4389: CD 18 19    CALL $1918
438C: 1E 40       LD E,$40
438E: 1A          LD A,(DE)
438F: E6 F0       AND $F0
4391: 77          LD (HL),A
4392: CB 7F       BIT 7,A
4394: 28 0E       JR Z,$43A4
4396: E6 70       AND $70
4398: 77          LD (HL),A
4399: 1C          INC E
439A: 3E 01       LD A,$01
439C: 12          LD (DE),A
439D: 1C          INC E
439E: 3D          DEC A
439F: 12          LD (DE),A
43A0: 1D          DEC E
43A1: 1D          DEC E
43A2: 18 0A       JR $43AE
43A4: 1C          INC E
43A5: 1A          LD A,(DE)
43A6: 47          LD B,A
43A7: 1C          INC E
43A8: 1A          LD A,(DE)
43A9: 1D          DEC E
43AA: 1D          DEC E
43AB: B0          OR B
43AC: 28 EB       JR Z,$4399
43AE: 2C          INC L
43AF: 13          INC DE
43B0: 1A          LD A,(DE)
43B1: 22          LD (HL+),A
43B2: 13          INC DE
43B3: 1A          LD A,(DE)
43B4: 22          LD (HL+),A
43B5: 1E 12       LD E,$12
43B7: 7D          LD A,L
43B8: C6 06       ADD A,$06
43BA: 6F          LD L,A
43BB: 06 08       LD B,$08
43BD: 1A          LD A,(DE)
43BE: 4F          LD C,A
43BF: 13          INC DE
43C0: 13          INC DE
43C1: 1A          LD A,(DE)
43C2: B7          OR A
43C3: 20 12       JR NZ,$43D7
43C5: D5          PUSH DE
43C6: 1E 0B       LD E,$0B
43C8: 1A          LD A,(DE)
43C9: D1          POP DE
43CA: FE 02       CP $02
43CC: 30 09       JR NC,$43D7
43CE: 79          LD A,C
43CF: FE 80       CP $80
43D1: 30 04       JR NC,$43D7
43D3: 0E FF       LD C,$FF
43D5: 79          LD A,C
43D6: 12          LD (DE),A
43D7: 79          LD A,C
43D8: 22          LD (HL+),A
43D9: 1A          LD A,(DE)
43DA: 22          LD (HL+),A
43DB: 13          INC DE
43DC: 05          DEC B
43DD: 20 DE       JR NZ,$43BD
43DF: 1A          LD A,(DE)
43E0: FE FF       CP $FF
43E2: 28 0D       JR Z,$43F1
43E4: 87          ADD A,A
43E5: C6 DB       ADD A,$DB
43E7: 6F          LD L,A
43E8: 3E C2       LD A,$C2
43EA: CE 00       ADC A,$00
43EC: 67          LD H,A
43ED: 1C          INC E
43EE: 1C          INC E
43EF: 1A          LD A,(DE)
43F0: 77          LD (HL),A
43F1: D1          POP DE
43F2: 14          INC D
43F3: C1          POP BC
43F4: F1          POP AF
43F5: 3C          INC A
43F6: 05          DEC B
43F7: 20 8A       JR NZ,$4383
43F9: C9          RET
```

## 2. ループ骨格

入口だけを見ると:

```text
D = $D0
B = 5
repeat 5 times:
  push actor_index
  push loop_count
  push actor_page_base
  HL = $C206
  CALL $1918
  ...
  D++
  restore loop_count
  restore actor_index
  actor_index++
```

`D` を `D0 -> D1 -> D2 -> D3 -> D4` と進めるので、
`437E` は 5 actor page を順に処理する helper と見るのが自然。

`CALL $1918` は `HL=$C206` と組み合わせて使われているため、
`A` で与えた actor index に応じて
`C206` 側の actor work record 先頭を計算する scale/address helper 候補。

## 3. 書き込み先は `C206 + 6*n` 系の work

`HL` への書き込みパターンは:

- 先頭 1 byte: `D?40` の high nibble / masked status
- 続く 2 byte: `D?43`, `D?44` 風の 2 byte
- さらに `L += 6`
- そこへ 8 回ぶん 2 byte pair を書く

少なくとも
`C206` から始まる battle work record に
actor ごとの要約を詰めている構造が見える。

`common.i` では `player.1.status = $C206` とあるため、
元の命名は player 寄りだが、
この文脈では
**battle 中の actor-visible state buffer**
として再利用されている可能性が高い。

## 4. `D?40` と `D?41/42` の扱い

前半:

```text
E = $40
A = [DE]
A &= $F0
[HL] = A
if bit7(A):
  A &= $70
  [HL] = A
  [D?41] = 1
  [D?42] = 0
else:
  B = [D?41]
  A = [D?42]
  if (B|A)==0:
    loop until nonzero
```

ここはまだ完全には断定できないが、
少なくとも `D?40-42` は
actor page 内の command/status staging 領域として読める。

特に `bit7` を見て
`[D?41]=1`, `[D?42]=0` に書き換える動きは、
flag 正規化や pending state の初期化に近い。

## 5. `D?43/44` の反映

```text
INC L
INC DE
A = [DE]   ; D?43
[HL+] = A
INC DE
A = [DE]   ; D?44
[HL+] = A
```

これは `actors` loop 側で見えていた
`D000` page の `+43`, `+44` 初期化とも整合しやすい。

つまり `437E` は、
actor page にある command/result/status bytes を
`C206` 側の compact work へ写す helper の可能性が高い。

## 6. `D?12` 起点の 8 回ループ

後半の 8 回ループは:

```text
E = $12
L += 6
repeat 8 times:
  C = [D?12 + 2*i]
  A = [D?13 + 2*i]
  if A == 0:
    if [D?0B] < 2 and C < $80:
      C = $FF
      [D?13 + 2*i] = $FF
  [HL++] = C
  [HL++] = [D?13 + 2*i]
```

という形に近い。

したがって `D?12..` は
actor ごとの 8 要素 candidate array、
`C206` 側はその mirror / normalized copy
とみるのが自然。

この 8 要素が attack target なのか command slot なのかは未確定だが、
少なくとも **通常攻撃の最終ダメージ式そのものではない**。

## 7. `C2DB + index*2` への 1 byte 反映

末尾:

```text
A = [DE]
if A != $FF:
  HL = $C2DB + A*2
  E += 2
  A = [DE]
  [HL] = A
```

ここは
`actors` loop report でも見えていた `C2DB` 近辺 table 参照と整合する。

少なくとも `437E` は
actor page から `C2DB` 系の補助表も同期している。

これもやはり
action 実行本体ではなく
**battle state staging / normalization**
の性格を補強する。

## 8. queue/action resolve 文脈での意味

`4146: CALL $437E` の直後は:

```text
4149: CALL $1915
414C: LD A,($C31A)
414F: LDH ($FFB0),A
4151: RET
```

つまり `437E` は、
`4152` の入力待ちのあとに一度まとめて呼ばれ、
その後の battle state 表示/処理へつながっている。

これは
通常攻撃 branch の深部というより、
**battle round 開始時の actor state 展開**
として読むのが自然。

## 現時点の整理

### 確度が高いこと

- `437E` は `D0xx..D4xx` の 5 actor page を走査する
- `C206` ベースの work buffer に actor ごとの要約を書き出す
- `D?12..` の 8 要素配列を正規化して mirror している
- `C2DB` 系補助表にも 1 byte 同期を書いている
- したがって `437E` は action 実行本体ではなく state staging helper 候補

### まだ未確定なこと

- `C206` work record の完全なレイアウト
- `D?12..` 8 要素配列の意味
- `C2DB` 系補助表の役割
- `1918` の正確な scale/address 契約

## 次の一手

1. `4579` を action resolve branch selector として切る
2. `1918` の契約を確認して `C206` record stride を固める
3. `437E` 後段の `1915` / `C31A -> FFB0` を battle state update として整理する
