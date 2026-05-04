# SaGa2 C7E0 shared scratch report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_c21f_flat_list_destination_report.md`

## 目的

- `C7E0..C7ED` が battle 専用 scratch か、より広い共有 scratch かを切る
- `5B64-5B90` と `60B8-60E1` の関係を整理する

## 結論

今回の大きい修正点は、
`C7E0..C7ED` を **battle 専用 flat sentinel list** と決め打ちしないほうが安全になったこと。

理由は 2 つある。

1. `01:5B64-5B90` に `60B8-60E1` とほぼ同型の `C7E0` builder がある  
2. bank0 の `1237-124B` / `10B2-10C2` では `HL=$C7E0` を item / magi / script-arg selector 側の table として読んでいる

したがって `C7E0..C7ED` は、
少なくとも battle だけでなく
**item / price / selection setup でも共有される 14-byte scratch / lookup list**
とみるのが現時点で最も安全。

## 1. `5B64-5B90` は `60B8-60E1` の強い同型

実バイト:

```text
5B64: LD HL,$C7E0
5B67: PUSH HL
5B68: LD A,$FF
5B6A: LD B,$0E
5B6C: CALL $006D
5B6F: POP DE
5B70: LD HL,$C2DA
5B73: LD BC,$0E00
5B76: LD A,(HL)
5B77: AND $0F
5B79: JR Z,$5B8E
5B7B: LD A,(HL)
5B7C: AND $F0
5B7E: JR Z,$5B8B
5B80: SWAP A
5B82: DEC A
5B83: PUSH HL
5B84: CALL $5B95
5B87: LD (HL),C
5B88: POP HL
5B89: JR $5B8E
5B8B: LD A,C
5B8C: LD (DE),A
5B8D: INC DE
5B8E: INC HL
5B8F: INC HL
5B90: INC C
...
```

ここでは:

- まず `C7E0..C7ED` を `FF` 埋め
- 続いて `C2DA` 14 件を走査
- high nibble 非 0なら `C21F + 16*block` の `+0` へ index
- high nibble 0 なら `C7E0` 側へ flat index を詰める

と読める。

つまり `60B8-60E1` と違い、
こちらは `DE` 側へ常に `FF` を書くのではなく、
**high nibble 0 entry の source index を flat list へ実際に格納**
している可能性が高い。

## 2. `60B8-60E1` との違い

既報 `60B8-60E1` は:

```text
HL = C2DA
DE = C7E0
B  = 0x0E
C  = 0
...
LD A,$FF
LD (DE),A
INC DE
```

なので、battle 側では同じ `C7E0` を
**14 件全部 `FF` sentinel 初期化する phase**
として使っている。

よって safest reading は:

- `5B64-5B90`: shared builder の populate 版
- `60B8-60E1`: shared builder の clear/sentinel 版

という **共有 14-byte list に対する phase 違い**
である。

## 3. bank0 `1237-124B` の read path

実バイト:

```text
1237: RST $30
1238: CP $10
123A: JR C,$1244
123C: LD A,($C709)
123F: CALL $10CC
1242: JR $1248
1244: LD HL,$C7E0
1247: RST $00
1248: LD B,$01
124A: LD A,(HL)
124B: CP $FF
```

ここでは `A < 0x10` の場合、
`HL = C7E0 + A`
を読んで `CP $FF` している。

つまり `C7E0` は bank0 caller から見ても
**indexable 14-byte candidate/lookup list**
として使われている。

## 4. bank0 `10B2-10C2` の read path

同様に:

```text
10B2: LD HL,$C7E0
10B5: RST $00
10B6: JR ...
10BB: LD A,($C709)
10BE: CALL $10CC
10C1: LD A,(HL)
10C2: CP $FF
```

が見えており、
やはり `C7E0 + index` を見て
`FF` sentinel 判定している。

したがって `C7E0` は battle ローカル一時領域というより、
少なくとも複数 subsystem が共有する
**“最大 14 件の候補/存在フラグ list”**
として扱うほうが自然。

## 5. `common.i` 名との関係

`common.i` では:

```text
.define script_arg_magi $c7e0
```

となっている。

この名前は bank0 の `1237-124B` と整合する部分もあるが、
`5B64-5B90` / `60B8-60E1` まで考えると、
少なくとも実装上は
**single-purpose な “magi slot” より広い共有 scratch/list**
として使われている。

移植では意味名を 1 つに固定しすぎないほうがよい。

## 6. 暫定整理

現時点で一番安全なのは:

```ts
type SharedEntryList14 = Uint8Array // 0..13, FF = none
```

として持ち、
用途ごとに

- magi candidate list
- item/price candidate list
- battle prepass flat list

のような view を与える設計。

## 移植への意味

TypeScript 側では `C7E0` を battle モジュールの private state に閉じず、
shared selection workspace として切っておくほうが後で整合しやすい。

`rng` / `battle` だけでなく、
item/price 側の共通 setup scratch として再利用される前提を置いたほうが安全。

## 次の一手

1. `1237-124B` と `10B2-10C2` が何の selector で `C7E0` を読むかを切る
2. `5B64-5B90` caller 文脈を追って high nibble 0 entry の意味を確定する
3. `C7E0` を consumer 観点で `candidate list` / `sparse slot list` のどちらに寄せるかを決める
