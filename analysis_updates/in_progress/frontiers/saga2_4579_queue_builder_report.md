# SaGa2 4579 queue builder report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_battle_runtime_entry_report.md`
- 既存 `saga2_actors_loop_report.md`
- 既存 `saga2_437e_contract_report.md`

## 目的

- `0D:4579` の役割を切る
- `actors ($D803)` queue がどこで構築されるかを明らかにする

## 結論

`0D:4579` は現時点では、
**`D040` 付近の `battle.data.*.stat.*` を走査して、`actors ($D803)` に 2 byte entry を積む queue builder helper**
とみるのがかなり自然。

具体的には:

- `D001` を見て actor page が空かどうかを判定
- `D040` から始まる 7 個の status/slot bit を走査
- bit が立っているものだけ `D803` へ 2 byte entry を書く
- entry 内容は `template table @45A0` 由来の byte と、actor page id (`D0..D4`) の組

なので `4579` は
通常攻撃 branch selector そのものではなく、
**action resolve に入る前の queue 構築 helper**
として扱うのが安全。

## 1. `common.i` との整合

`common.i`:

```text
battle.data.1.current_stack = $D001
battle.data.1.stat.1.status = $D040
battle.data.1.stat.1.hp     = $D041
battle.data.1.stat.1.item_id= $D043
battle.data.1.stat.1.target = $D045
battle.data.1.stat.1.item_slot_index = $D046
battle.data.1.stat.2        = $D048
actors = $D803
```

`4579` の先頭は:

```text
4579: 26 D0       LD H,$D0
457B: 0E 05       LD C,$05
457D: 11 98 45    LD DE,$4598
4580: 2E 01       LD L,$01
4582: 7E          LD A,(HL)
4583: B7          OR A
4584: 3E 80       LD A,$80
4586: 2E 40       LD L,$40
4588: 06 07       LD B,$07
```

ここで `HL=$D001` を見たあと `L=$40` に飛ぶため、
`D001` と `D040` の両方を使う helper だと分かる。

これは battle actor page の
`current_stack` と `stat.1..7` 走査として非常に自然。

## 2. 空 actor page の扱い

冒頭:

```text
L = $01
A = [D?01]
OR A
A = $80
L = $40
B = 7
JR Z,$45AF
```

つまり `D?01 == 0` の actor page は特別扱いされる。

その場合でも後段 `45A8` へ進むが、
bit scan を飛ばして空/既定 entry を積む形に見える。

したがって `4579` は
「actor page が有効なら status bit を展開、無効なら既定値」
という queue builder と読むのが自然。

## 3. `D?40` から 7 bit を走査

中核部分:

```text
458C: 2A          LD A,(HL+)
458D: 0F          RRCA
458E: 38 18       JR C,$45A8
4590: 13          INC DE
4591: 13          INC DE
4592: 05          DEC B
4593: 20 F8       JR NZ,$458D
4595: C3 A8 45    JP $45A8
```

これは:

- `D040`, `D041`, ... ではなく `D040`, `D048`, ... のような 8 byte stride ではないか
- ただ少なくとも `L` は `40` から始まり `LD A,(HL+)` を繰り返す
- 各 byte の最下位 bit を `RRCA` で carry に出し、立っていれば queue entry を生成

と読める。

完全な stride はまだ未確定だが、
構造としては
**status/slot の bit scan -> active entry emit**
でかなり自然。

## 4. `45A0` 近辺の template table

`4598` 以降の実バイト:

```text
4598: 0F 01
459A: FF 00
459C: FF 00
459E: FF 00
45A0: FF 00
45A2: FF 00
45A4: FF 00
45A6: FF 00
45A8: 2C
45A9: 2C
45AA: 1A
45AB: 22
45AC: 13
45AD: 1A
45AE: 77
45AF: 24
45B0: 0D
45B1: 20 CA
45B3: C9
```

重要なのは、
`DE=$4598` から始まって `INC DE / INC DE` を繰り返すので、
`45A0` 前後にある 2 byte pair 群を参照している点。

`45A8` 以降はコードなので、
table 本体は実質

- `4598: 0F 01`
- `459A: FF 00`
- `459C: FF 00`
- `459E: FF 00`
- `45A0: FF 00`
- `45A2: FF 00`
- `45A4: FF 00`
- `45A6: FF 00`

の 7-8 組と見るのが自然。

`bit hit` 時の entry 書き込み部は:

```text
45A8: INC L
45A9: INC L
45AA: LD A,(DE)
45AB: LD (HL+),A
45AC: INC DE
45AD: LD A,(DE)
45AE: LD (HL),A
45AF: INC H
45B0: DEC C
45B1: JR NZ,$457D
45B3: RET
```

ここから、
**`[template_byte0, template_byte1]` を `D803` へ書き、次 actor page へ進む**
と読むのが一番自然。

## 5. `actors ($D803)` 構築としての読み

`battle_runtime_entry_report` では `40F3` で `D803` を `0xFF` 初期化したあと、
`4120` と `4164` で `CALL $4579` が見えていた。

今回の `4579` 自体を見ると、
各 actor page について
`status bit scan -> 2 byte pair emit`
をしているので、
これはちょうど
**`actors` queue の生成**
として整合する。

さらに `actors_loop_report` で見えた
`4178` 側の 2 byte entry 消費とも噛み合う。

したがって battle runtime の流れは、

1. `D803` を `FF` 初期化
2. `4579` で `actors` queue を構築
3. `4178` 以降でその 2 byte entry を消費

という 2 段階構造とみるのがかなり自然。

## 6. `4579` は branch selector ではなく queue builder

前は `4579` を action resolve branch selector と疑っていたが、
今回の局所解析ではむしろ
**selector より一段手前**
に見える。

理由:

- `D001` / `D040` / template table / `D803` という data movement が中心
- 分岐先は local な bit scan 制御だけ
- `CALL $016B` や `043E` 系 RNG は出てこない
- `4178` 側がこの生成結果を消費する構造と整合する

よって、
通常攻撃本線を探す次の主線は
`4579` の先ではなく、
**`4579` が埋めた `actors` queue を読む `4178` 側の deeper branch**
に戻すのがよい。

## 現時点の整理

### 確度が高いこと

- `4579` は `D001` と `D040` 付近を読む
- `45A0` 近辺の 2 byte pair template を参照する
- `D803` へ 2 byte entry を積む queue builder と読むのが自然
- `4178` 以降の `actors` loop と役割分担がきれいに繋がる

### まだ未確定なこと

- `D040` 以降の正確な bit/byte stride
- template pair 各値の意味
- `D001 == 0` のときに積む既定 entry の意味
- 通常攻撃 command が queue 消費後のどこで確定するか

## 次の一手

1. `4178` ループ内で queue entry から action kind を引く箇所を絞る
2. `41BC-41EC` の pointer/3byte table を action kind 解決として再確認する
3. `4178` 以降の deeper branch だけで `016B -> 043E` を再探索する
