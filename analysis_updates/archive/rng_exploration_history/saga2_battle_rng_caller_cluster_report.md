# SaGa2 battle RNG caller cluster report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_battle_rng_bc_page_report.md`
- 既存 `saga2_battle_rng_de00_consumers_report.md`
- 既存 `saga2_battle_rng_byte49_gap_report.md`

## 目的

- `0D:4040-408E` を helper 群の caller cluster として整理する
- `D849/D949/DA49` と `443A/443B` の関係を一段固める

## 結論

実バイトの再取得により、
この cluster は以前の単純化より複雑だとはっきりした。

`0D:4024-4075` は
**3つの page family をつなぐ battle prepare cluster**
として読むのが自然。

1. `D5xx` 3-page loopで `44F4` を呼び、`DE10` を `D8xx` family low offset `$49+` へ返す
2. `D0xx` 5-page loopで `CALL $1918` と `CALL $449A` を回す
3. `D500/D600/D700` に対して `CALL $443A` を 3 回回す

したがって以前の
「`443A` caller = `D849/D949/DA49` family」
という見立ては修正が必要で、
`D849` family はむしろ cluster 中の metadata writeback 側として分けて扱うのが安全。

## 1. 既知の caller 断片を 1 本にまとめる

実バイトを並べると、
`4024-4075` は次の流れになる。

```text
4024: PUSH BC
4025: PUSH DE
...
402C: CALL $44F4
...
403B: LD A,($DE10)
403E: LD (BC),A
4040: DEC B
4041: JR NZ,$4024
4043: XOR A
4044: LD D,$D0
4046: LD B,$05
4048: ...
404D: CALL $1918
4051: CALL $449A
...
4059: DEC B
405A: JR NZ,$4048
405C: CALL $0198
405F: JR NZ,$4067
4061: LD HL,$D400
4064: XOR A
4065: LDI (HL),A
4066: LD (HL),A
4067: LD BC,$D500
406A: LD A,$03
406C: ...
406E: CALL $443A
4072: INC B
4074: DEC A
4075: JR NZ,$406C
```

ここから少なくとも:

- 前半 loop は `D5xx` source page 側 (`D` を `INC`) を回す
- 中盤で `DE10 -> D8xx` metadata writeback を行う
- 次に `D0xx` 5-page loop がある
- 後半 loop は `D500/D600/D700` を回して `443A` を呼ぶ

という 3 段構造が見える。

## 2. `D849` family の位置づけ

`DE10` writeback は既報どおり:

```text
4053: LD A,($DE10)
4056: LD (BC),A
```

で、前半 loop の式から
`BC` low offset は `$49 + (3-B)` を取る。

したがって絶対値は
`D849`, `D84A`, `D84B`
寄りに見える。

ここはまだ direct consumer 未発見だが、
少なくとも `443A` caller と同一 page familyではなかった。

よって `D849` family は
**cluster 内 metadata sink**
として独立に持つのが安全。

## 3. `443A/443B` との関係

既報では:

- `43FB-443A`: 9 個の 16bit entry を走査して `H:2D/H:2E` を集約する flag fold
- `443B-4499`: slot `07/08` を使って pointer record を build する RNG bridge

と読めている。

今回の caller cluster を重ねると、
`4024-4075` はこれら helper 群の前段にある
**multi-family prepare cluster**
と見るのが自然になる。

特に重要なのは、
`44F4` source は `D5xx`、
中間 staging は `D0xx`、
`443A` caller は `D5xx-D7xx`
と分かれたこと。

これは battle prepare が
単一 family の in-place 更新ではないことを強く示す。

## 4. `D84D` 系との違い

`actors` loop では
`D84D + 2*id`
の active read path がかなり明確に見えていた。

それに対して `D849` family は、
この caller cluster では writeback だけが見えている。

ただし今回の整理で、
この差は単に「未解析」ではなく
**責務の違い**
として読むほうが自然になった。

- `D84D + 2*n`: queue/actor-page 解決に使う active lookup
- `D849+`: prepass 前に積まれる compact metadata sink

つまり両者は近接アドレスでも、
同じ lookup table の連続フィールドとは急いで決めないほうが安全。

## 5. `common.i` ラベルへの注意

`common.i` では `D849` に
`enemy_inventory_sizes`
というラベルが付いているが、
今回見えている access pattern は
かなり staged metadata 的で、
**ラベル名どおりの単純な「敵所持数」配列と断定するには弱い**。

少なくとも移植資料では、
このラベルは暫定名として扱うのが安全。

## 6. 移植への意味

TypeScript 側では `D849` family を、
今のところ battle controller page の未命名 metadata field として持つのが安全。

```ts
type BattlePrepareCluster = {
  d5SourcePages: unknown[]
  d0StagePages: unknown[]
  d8Metadata: number[]
}
```

重要なのは、
`battle -> rng` の橋が actor stat に直接刺さるのではなく、
**controller prepass を一段経由して pointer record を組む**
構造で見えてきていること。

## 現時点の整理

### 確度が高いこと

- `4040-408E` は helper 群の caller cluster としてまとまっている
- 前半は source page を回して `44F4` を呼ぶ
- `DE10` は `D849/D949/DA49` へ書き戻される
- 後半は同じ 3 page family に `CALL $443A` を回す
- よって `D849` family は controller prepass の一部とみるのが自然

### まだ未確定なこと

- `443A/443B` が `D849` family を実際に参照しているか
- `byte49` の意味が category/id/count のどれに近いか
- source 側 `D` page の正式所属
- cluster 全体の入口アドレスと loop count 初期値

## 次の一手

1. `1918` と `449A` の契約を切って `D0xx` 5-page loop の意味を確定する
2. `443A` 本体が `D500/D600/D700` のどこを読むかを追う
3. `D84D` と `D849+` を同一 struct とみなさず、別責務として仮置きする
