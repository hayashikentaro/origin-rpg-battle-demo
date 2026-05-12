# SaGa2 C21F flat list destination report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_c21f_block_builder_report.md`
- 既存 `saga2_battle_prepass_orchestration_report.md`

## 目的

- `01:60C0-60E1` の `DE` destination を caller 文脈から固定する
- `607A-60BF` を `C21F` / `C2DA` 前処理として整理する

## 結論

今回の確定点はかなり強い。

`01:60B8` で

```text
LD HL,$C2DA
LD DE,$C7E0
LD BC,$0E00
```

を作ったあと、そのまま fallthrough で `60C0-60E1` に入っている。
したがって `60C0` が `LD (DE),$FF` で埋めている flat list の実体は
**`$C7E0..$C7ED` の 14 byte list**
とみてよい。

`common.i` では `C7E0 = script_arg_magi` だが、
少なくともこの battle/item setup 文脈では
**14件の flat sentinel scratch list**
として一時再利用されている可能性が高い。

さらに `607A-60A2` と `60AA-60B7` を合わせると、
`60C0` 単体ではなく
**`C2DA -> C21F[0..3] packed-head normalize -> C7E0 FF list build`**
という前段 3 ステップの一部として読むのが自然になった。

## 1. `60B8-60C0` の直接文脈

実バイト:

```text
60AA: LD B,$00
60AC: LD A,B
60AD: CALL $60E2
60B0: LD (HL),$FF
60B2: INC B
60B3: LD A,B
60B4: CP $04
60B6: JR C,$60AC
60B8: LD HL,$C2DA
60BB: LD DE,$C7E0
60BE: LD BC,$0E00
60C1: LD A,(HL)
...
```

`60C0` は label 上は `60C0` から始めていたが、
実際には `60B8-60BF` がその前置として直結している。

このため `60C0-60E1` の入力は:

- `HL = C2DA`
- `DE = C7E0`
- `B = 0x0E`
- `C = 0x00`

とかなり強く固定できる。

## 2. `DE` destination は `C7E0..C7ED`

loop 本体は 14 回まわり、
毎回

```text
LD A,$FF
LD (DE),A
INC DE
```

を実行する。

`DE` 初期値が `$C7E0`、
回数が `0x0E` なので、
構築される flat list は:

```text
C7E0..C7ED
```

の 14 byte とみてよい。

これは件数的にも `C2DA` の 14 entry と一致する。

## 3. `C7E0` の意味

`common.i` では:

```text
.define script_arg_magi $c7e0
```

となっている。

ただし今回見えているのは battle/item setup 側 bank `01` の局所文脈であり、
少なくともこの区間では `C7E0` が
**script 専用の永続変数ではなく scratch 再利用 RAM**
として使われている可能性が高い。

したがって移植側では、
名前に引きずられず

```ts
flatEntrySentinels14
```

のような battle prepass 中間表として別管理したほうが安全。

## 4. `607A-6087` は `C2DA` low nibble 正規化

実バイト:

```text
607A: LD HL,$C2DA
607D: LD B,$0E
607F: LD A,(HL)
6080: AND $0F
6082: LDI (HL),A
6083: INC HL
6084: DEC B
6085: JR NZ,$607F
```

ここでは 14 件の 2 byte entry に対し、
entry byte0 の **low nibble だけを残す** 形で
`C2DA` 先頭 byte を in-place 正規化していると読むのが自然。

つまりこの時点で high nibble 情報は一度落とされる。

## 5. `6087-60A2` は `C21F` block head 再構築

続き:

```text
6087: LD BC,$0400
608A: LD A,C
608B: CALL $60E2      ; HL = C21F + 16*C
608E: LD A,(HL)
608F: CP $FF
6091: JR Z,$609E
6093: CALL $60A3
6096: AND $0F
6098: LD E,C
6099: INC E
609A: SWAP E
609C: OR E
609D: LD (HL),A
609E: INC C
609F: DEC B
60A0: JR NZ,$608A
60A2: RET
```

補助 `60A3` は:

```text
60A3: ADD A,A
60A4: LD HL,$C2DA
60A7: RST $00
60A8: LD A,(HL)
60A9: RET
```

したがって `6087-60A2` は、
4 個の `C21F` block head を見て、
`C2DA[index]` の low nibble と
`(blockIndex+1)<<4` を合成し、
**packed head byte を `C21F + 16*block` の `+0` へ再構築**
する normalize pass とみるのが自然。

少なくとも:

```ts
if (c21f[block*16] != 0xff) {
  c21f[block*16] = ((block + 1) << 4) | (c2da[block*2] & 0x0f)
}
```

に近い処理まで上げられる。

## 6. `60AA-60B7` は block head clear

この直後の:

```text
60AA: LD B,$00
60AC: LD A,B
60AD: CALL $60E2
60B0: LD (HL),$FF
60B2: INC B
60B3: LD A,B
60B4: CP $04
60B6: JR C,$60AC
```

は `C21F` の最初の 4 block head を
`FF` へ clear している。

見かけ上は直前の構築と矛盾して見えるが、
少なくとも局所的には
`60AA-60B7` が **別 phase の reset**
として続いているのは確か。

このため safest reading は:

- `6087-60A2`: `C21F` block head の packed 化 helper
- `60AA-60B7`: `C21F` block head reset helper
- `60B8-60E1`: `C2DA -> C7E0 FF list build`

という **3 本の隣接 helper 群**
として切ること。

## 7. 移植への意味

これで battle prepass 中間表は少なくとも 3 本に分けられる。

```ts
type PackedSeedEntries = Uint8Array // C2DA, 14 * 2 bytes
type BlockTable = Uint8Array        // C21F, 16-byte stride blocks
type FlatSentinelList = Uint8Array  // C7E0..C7ED, 14 bytes
```

Godot / TypeScript 側では、
`C7E0` を `script_arg_magi` 的な名前で流用せず、
battle prepass 文脈専用の scratch list として切るほうが安全。

## 次の一手

1. `C7E0..C7ED` の consumer を逆引きして flat sentinel list の意味を確定する
2. `60AA-60B7` と `60B8-60E1` が同一 caller からどう使い分けられるかを見る
3. `C21F + 16*block` の offset `+1..+F` consumer を追って block struct を広げる
