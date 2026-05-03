# SaGa2 battle runtime entry report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_hp_ram_report.md`
- 既存 `saga2_normal_attack_entry_gap_report.md`

## 目的

- bank `0D:40E6` 周辺の battle runtime 入口を整理する
- 通常攻撃 command 探索の起点を `damage` 側ではなく `battle controller` 側へ移す

## 結論

bank `0D:40E6` は、
`common.i` の `D8xx` battle controller 変数と強く整合する
**battle runtime entry / round controller 候補** とみるのが自然。

少なくともここでは:

- `battle_turn ($D848)` の更新
- `actors ($D803)` 配列の `0xFF` 初期化
- `current_actor_index ($D802)` の初期化
- `D000` 台 actor buffer の走査

が見える。

したがって、
通常攻撃 entry を探す次の起点は
**bank `0D:40E6` から始まる battle state machine**
に置くのがよい。

## 1. 既知ラベル

`common.i`:

```text
ambush               = $D800
run_result           = $D801
current_actor_index  = $D802
actors               = $D803
battle.encounter_info= $D844
meat_flag            = $D845
transformation_flag  = $D846
transformation_result= $D847
battle_turn          = $D848
enemy_inventory_sizes= $D849
transformation_index = $D84C
last_used            = $D84D
defeated_flag        = $D85E
```

## 2. `0D:40E6` の冒頭

実バイト:

```text
40E6: EA 48 D8    LD ($D848),A
40E9: CD D7 01    CALL $01D7
40EC: FA 48 D8    LD A,($D848)
40EF: 3C          INC A
40F0: EA 48 D8    LD ($D848),A
40F3: 21 03 D8    LD HL,$D803
40F6: 06 41       LD B,$41
40F8: 3E FF       LD A,$FF
40FA: 22          LD (HL+),A
40FB: 05          DEC B
40FC: 20 FC       JR NZ,$40FA
40FE: AF          XOR A
40FF: EA 02 D8    LD ($D802),A
```

これだけで、

- `battle_turn++`
- `actors[0..0x40] = 0xFF`
- `current_actor_index = 0`

と読むのが自然。

## 3. `D000` actor buffer 走査

続き:

```text
4102: 21 00 D0    LD HL,$D000
4105: 0E 08       LD C,$08
4107: 7E          LD A,(HL)
4108: B7          OR A
4109: 28 0F       JR Z,$411A
410B: 47          LD B,A
410C: 2E 43       LD L,$43
410E: 36 FF       LD (HL),$FF
4110: 2C          INC L
4111: 36 00       LD (HL),$00
4113: 7D          LD A,L
4114: C6 07       ADD A,$07
4116: 6F          LD L,A
4117: 05          DEC B
4118: 20 F4       JR NZ,$410E
411A: 24          INC H
411B: 2E 00       LD L,$00
411D: 0D          DEC C
411E: 20 E7       JR NZ,$4107
```

解釈:

- `D000, D100, ...` の 8 actor page を順に見る
- page 先頭 byte が 0 なら空 actor
- 非 0 の場合、その値を count 的に使って
  page 内 `+0x43`, `+0x44`, `+0x4B`, ... のような stride を初期化している

完全な意味は未確定だが、
**battle actor work area の per-slot 初期化** とみるのが自然。

## 4. 入口後半の大枠

`4120` 以降では:

- `CALL $4579`
- `ambush ($D800)` を読む分岐
- `CALL $4361` で state 値 `01/02/03/06/07` を入れているように見える箇所
- `actors ($D803)` を舐めるループ

がある。

特に:

```text
4131: CD 61 43
...
416C: CD 61 43
...
4226: 3E 06
4228: CD 61 43
...
4242: 3E 07
4244: CD 61 43
```

なので `4361` は
**battle substate setter / phase transition helper**
の可能性が高い。

## 5. `actors ($D803)` 走査

`4178` 以降では:

```text
4178: 21 03 D8    LD HL,$D803
...
417B: 2A          LD A,(HL+)
417C: FE FF       CP $FF
417E: 20 04       JR NZ,$4184
4182: E1          POP HL
4183: C3 17 42    JP $4217
```

の形があり、
`actors` 配列を sentinel `0xFF` まで舐めていると読める。

その後ろでは:

- actor index 由来の address 計算
- `D8DB/C2DB` 近辺 table 参照っぽい動き
- `CALL $435A`

が見える。

したがって `actors[$D803...]` は
**このターンに処理すべき actor / action queue**
にかなり近い。

## 6. 通常攻撃探索への意味

ここから言える大事な点は、
通常攻撃 entry を探すなら

- `damage writeback`
- `particle/effect`
- `high-score battle routine`

ではなく、

- `0D:40E6` battle runtime entry
- `0D:4178` actors loop
- `CALL $435A / $4361 / $4579`

の chain を追うべきだということ。

## 7. 現時点の整理

### 確度が高いこと

- `0D:40E6` は battle runtime 入口候補
- `battle_turn ($D848)` を更新している
- `actors ($D803)` を `0xFF` 初期化している
- `current_actor_index ($D802)` を 0 初期化している
- `D000` 台 actor buffer の走査と初期化がある
- 後半に `actors` 配列ループがある

### まだ未確定なこと

- `actors[$D803...]` の要素が actor id か action id か priority queue か
- `CALL $435A` の契約
- `CALL $4361` の state 値 `01/02/03/06/07` の意味
- 通常攻撃 command がこの chain のどこで確定するか

## 次の一手

1. `0D:435A` と `0D:4361` の局所契約を切る
2. `0D:4178` 以降の `actors` ループを擬似コード化する
3. `actors` 要素から `D000` 台 actor page への写像を確定する
