# SaGa2 battle RNG prepass report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_battle_rng_bridge_report.md`

## 目的

- `43FB-443A` を `443B-4499` とは別 helper として切り出す
- `443B` 直前に何が前計算されているかを整理する

## 結論

`43FB-443A` は slot RNG caller ではなく、
**9 個の 16bit entry を走査して 2 byte の集約フラグを作る prepass helper**
と読むのが自然。

処理の中心は:

- `H:2D` と `H:2E` を 0 初期化
- `HL` が指す 9 個の 16bit entry を走査
- 各 entry から `0C:6F82 + entry*8` の record を引く
- record byte0 の `0x30` を class 判定に使う
- record byte3 を `H:2D` または `H:2E` に OR 蓄積する

したがってこれは
`443B-4499` の pointer builder より一段前にある
**battle descriptor flag fold / category fold**
候補とみるのが安全。

## 1. 実コード

```text
43FB: LD E,$2D
43FD: LD D,H
43FE: XOR A
43FF: LD (DE),A
4400: INC E
4401: LD (DE),A
4402: DEC E
4403: LD B,$09
4405: PUSH BC
4406: LD A,(HL+)
4407: CP $FF
4409: JR Z,$4434
440B: PUSH HL
440C: LD H,(HL)
440D: LD L,A
440E: PUSH DE
440F: ADD HL,HL
4410: ADD HL,HL
4411: ADD HL,HL
4412: LD DE,$6F82
4415: ADD HL,DE
4416: LD A,$0C
4418: CALL $00D2
441B: AND $30
441D: JR Z,$4432
441F: POP DE
4420: PUSH DE
4421: CP $10
4423: JR Z,$4426
4425: INC DE
4426: INC HL
4427: INC HL
4428: INC HL
4429: LD A,$0C
442B: CALL $00D2
442E: LD L,A
442F: LD A,(DE)
4430: OR L
4431: LD (DE),A
4432: POP DE
4433: POP HL
4434: INC HL
4435: INC HL
4436: POP BC
4437: DEC B
4438: JR NZ,$4405
443A: RET
```

## 2. 何をしているか

最初に `DE = H:2D` を作って、
`H:2D` と `H:2E` を 0 クリアしている。

そのあと `B=9` で 9 回まわし、
`HL` が指す 16bit entry 群を 1 個ずつ処理する。

`entry != FFFF` のときだけ:

1. `entry` を 8 倍して `0C:6F82` ベースへ足す
2. record byte0 を読む
3. `byte0 & 0x30` が 0 なら無視
4. `0x10` なら `H:2D`、それ以外なら `H:2E`
5. record byte3 を読み、対象 byte に OR 蓄積

つまり
**9 entry -> 2 category bytes**
への畳み込みに見える。

## 3. `443B-4499` との関係

この helper 自体は `CALL $016B` を持たない。
したがって RNG bridge そのものではなく、
`443B-4499` より前で使われる
battle descriptor 正規化の一部とみるのが自然。

重要なのは、
同じ `43FB-4499` 近辺でも

- `43FB-443A`: flag fold / prepass
- `443B-4499`: slot `07/08` を使う pointer builder

に分けて考えたほうが整合すること。

## 4. 現時点の仮説

- `H:2D/H:2E` は category ごとの集約 flag
- `0C:6F82 + entry*8` は action/target/variant descriptor table 候補
- `byte0 & 0x30` は 2 系統への分類ビット
- `byte3` は OR 蓄積可能な capability/flag byte 候補

## 次の一手

1. `43FB` caller を追って `H` page の実体を確定する
2. `0C:6F82` table の 8 byte record を別解析する
3. `H:2D/H:2E` を読む後続箇所を逆引きする
