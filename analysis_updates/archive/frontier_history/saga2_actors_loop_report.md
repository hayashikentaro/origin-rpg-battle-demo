# SaGa2 actors loop report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_battle_runtime_entry_report.md`
- 既存 `saga2_battle_state_helpers_report.md`
- 既存 `reports/saga2_damage_candidate_functions_pass19.csv`

## 目的

- bank `0D:4178` 以降の `actors` ループを擬似コード化する
- 通常攻撃 / action resolve 探索の起点を `actors` queue 処理へ固定する

## 結論

今回の局所解析で、
`0D:4178` 以降は
**`actors ($D803)` を 2 byte entry の queue として順に処理する battle action resolve ループ候補**
とみるのがかなり自然になった。

少なくともここでは:

- `actors` を `0xFF` sentinel まで走査する
- 各 entry から 2 つの byte を読む
- その片方で `D0xx` actor page を選ぶ
- もう片方で `D84D` 近辺の battle controller work を引く
- 条件に応じて state `04/05/06/07` を `4361` へ渡す
- `435A` による actor-page 集計値を見て次 state へ遷移する

という流れが見える。

したがって、
通常攻撃 entry を探す次の主線は
`damage writeback` ではなく
**この `actors` queue loop の各分岐先**
に置くのがよい。

## 1. 入口の形

`4178` 以降の実バイト:

```text
4178: CALL $4361
417B: LD HL,$D803
417E: PUSH HL
417F: LD A,(HL+)
4180: CP $FF
4182: JR NZ,$4188
4184: POP HL
4185: JP $4217
```

ここから確度高く言えるのは 2 点。

1. `actors ($D803)` は `0xFF` sentinel 終端
2. ループ先頭で `LD A,(HL+)` を行い、`POP HL / INC HL / INC HL` で次へ進むため、entry は 2 byte 幅

つまり `actors` は
**2 byte record の可変長 queue**
として読むのが自然。

## 2. entry の 2 byte が何に使われるか

先頭側:

```text
417F: LD A,(HL+)
...
4188: ADD A,A
4189: ADD A,A
418A: ADD A,A
418B: ADD A,$40
418D: LD C,A
418E: LD A,(HL+)
418F: LD L,A
4190: ADD A,$D0
4192: LD D,A
4193: LD E,$01
4195: LD A,L
4196: ADD A,A
4197: ADD A,$4D
4199: LD L,A
419A: LD H,$D8
```

ここからの自然な解釈は:

- entry byte0 は `*8 + $40` の形で変換される queue/order side index
- entry byte1 は `+$D0` され、`D0xx/D1xx/...` の actor page 選択に使われる
- 同じ byte1 から `D84D + 2*byte1` も引いている

つまり各 entry は少なくとも
**queue/order 用の index と actor page id の pair**
にかなり近い。

名前はまだ未確定だが、
少なくとも単一の actor id 1 byte 配列ではない。

## 3. ループ中盤の構造

`419A` 以降:

```text
419A: LD A,(DE)
419B: OR A
419C: JR Z,$4203
419E: LD C,A
419F: LD A,(DE)
41A0: AND $90
41A2: JR NZ,$4203
41A4: BIT 3,C
41A6: JR Z,$41B0
41A8: PUSH DE
41A9: PUSH HL
41AA: LD A,$04
41AC: CALL $4361
...
41B0: PUSH DE
41B1: PUSH HL
41B2: LD A,$05
41B4: CALL $4361
...
41B9: INC E
41BA: INC E
41BB: INC E
41BC: LD A,(DE)
41BD: LD (HL+),A
41BE: LD C,A
41BF: INC E
41C0: LD A,(DE)
41C1: LD (HL),A
41C2: LD H,A
41C3: LD L,C
```

ここでは:

- actor page offset `+1` の byte をチェック
- `0x90` mask を見て entry を弾く
- `BIT 3` 条件で state `04` を出す場合がある
- その後 state `05` を出す
- actor page のさらに後ろから 2 byte を読み、`HL` pointer 候補として扱う

と読める。

この流れは、
乱数や単純な status 合計ではなく
**queue entry から actor/action descriptor を引く action resolve 前処理**
としてかなり自然。

## 4. 中盤の pointer/record 検証

続き:

```text
41C4: LD A,C
41C5: CP $FF
41C7: JR Z,$41F1
41C9: CP $0E
41CB: JR Z,$41D5
41CD: CP $0F
41CF: JR NZ,$41D9
41D1: LD A,H
41D2: OR A
41D3: JR Z,$41D9
41D5: LD A,H
41D6: DEC A
41D7: JR Z,$41F1
41D9: INC E
41DA: INC E
41DB: LD A,(DE)
41DC: CP $FF
41DE: JR Z,$41F1
41E0: LD E,A
41E1: ADD A,A
41E2: ADD A,E
41E3: ADD A,$14
41E5: LD E,A
41E6: LD A,(DE)
41E7: CP $FE
41E9: JR Z,$41ED
41EB: DEC A
41EC: LD (DE),A
```

ここでは:

- pointer/record 候補に対して sentinel `FF/FE` を見ている
- 特別値 `0E/0F` にも分岐がある
- `index * 3 + $14` の 3 byte stride table を触っている

よってこのブロックは、
通常攻撃そのものというより
**action candidate / target candidate / countdown record 風の補助表**
をいじっている可能性が高い。

## 5. `435A` による集計と state `06/07`

後半:

```text
41F1: CALL $01E3
41F4: LD HL,$D001
41F7: LD B,$05
41F9: CALL $435A
41FC: OR A
41FD: JR Z,$4250
41FF: LD B,$03
4201: CALL $435A
4204: OR A
4205: JR Z,$4273
4207: POP HL
4208: INC HL
4209: INC HL
420A: LD A,($D802)
420D: INC A
420E: LD ($D802),A
4211: LD A,(HL)
4212: CP $FF
4214: JP NZ,$417E
4217: LD HL,$D001
421A: LD B,$05
421C: CALL $435A
421F: OR A
4220: JR Z,$4251
4222: LD B,$03
4224: CALL $435A
4227: OR A
4228: JR Z,$4274
422A: LD A,$06
422C: CALL $4361
422F: CALL $01E3
4232: LD HL,$D001
4235: LD B,$05
4237: CALL $435A
423A: OR A
423B: JR Z,$4251
423D: LD B,$03
423F: CALL $435A
4242: OR A
4243: JR Z,$4274
4245: LD A,$07
4247: CALL $4361
424A: LD HL,$D803
424D: JP $40E9
```

ここはかなり重要で、
`actors` queue の全走査後に:

- `D001` を起点に `B=5` 集計
- `B=3` 集計
- その結果で state `06` / `07` に分岐
- 最後に `HL=$D803` へ戻して `40E9` 側へ返す

という構造が見える。

したがって `435A` は
**battle round 内の actor-side aggregate gate**
として機能しており、
`06/07` は queue 処理完了後の phase transition とみるのが自然。

## 6. 擬似コード

確度高めの部分だけ擬似コード化すると:

```text
setState(03)
hl = actors
while true:
  save = hl
  queueIndex = *hl++
  if queueIndex == 0xFF:
    break

  actorPageId = *hl++
  actorPage = 0xD000 + actorPageId * 0x100
  queueWork  = 0xD84D + actorPageId * 2

  if actorPage[1] == 0:
    goto next_entry
  if actorPage[1] & 0x90:
    goto next_entry

  if actorPage[1] has bit3:
    setState(04)
  setState(05)

  ptr = readWord(actorPage + 4)
  if ptr is invalid/sentinel:
    goto post_entry

  updateAuxiliary3ByteTable(...)

post_entry:
  call 01E3
  if sum_actor_field(offset=1, pages=5) == 0:
    goto failure_a
  if sum_actor_field(offset=1, pages=3) == 0:
    goto failure_b

next_entry:
  hl = save + 2
  current_actor_index++
  if *hl != 0xFF:
    continue
  break

if sums_ok:
  setState(06)
  call 01E3
  if sums_ok_again:
    setState(07)
    return to 40E9
```

細部はまだ仮説だが、
全体構造としてはかなり自然。

## 7. 通常攻撃探索への意味

この結果から大事なのは 3 点。

1. `actors` は単純 actor id 配列ではなく 2 byte queue entry 群
2. `4178-424D` は queue/action resolve 前処理ブロック候補
3. 通常攻撃本線は、この先の `01E3` / `437E` / `4579` 周辺 branch から探すほうが効率がよい

つまり battle core RNG の探索も、
以後は
**queue entry から実 action 実行へ降りる branch**
だけを優先して追うのがよい。

## 現時点の整理

### 確度が高いこと

- `actors ($D803)` は `0xFF` sentinel の 2 byte entry queue 候補
- entry 片方は `D0xx` actor page 選択に使われる
- `435A` は queue 後半の aggregate gate に使われる
- state `04/05/06/07` は queue 処理の phase transition に見える

### まだ未確定なこと

- entry byte0 / byte1 の正式な意味
- `41BC-41EC` で触る pointer/3byte table の正体
- `01E3` の契約
- どの branch が通常攻撃 command 実行に対応するか

## 次の一手

1. `01E3` の契約を切る
2. `437E` と `4579` を queue/action resolve 文脈で読み直す
3. `41BC-41EC` の pointer/3byte table を通常攻撃候補かどうかで分類する
