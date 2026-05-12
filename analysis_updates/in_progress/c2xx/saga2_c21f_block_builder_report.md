# SaGa2 C21F block builder report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c21f_stride_helper_report.md`
- 既存 `saga2_c2da_producers_report.md`

## 目的

- `01:60C0-60E1` を切って `C21F` block の実利用を一段具体化する
- `C21F` が単なる stride helper base 以上に何をしているかを整理する

## 結論

`01:60C0-60E1` は、
**2byte entry 列を走査して `C21F + 16*block` の先頭 byte に `source index C` を書き込みつつ、別の output list へ `FF` sentinel を並べる builder**
とみるのが自然。

見えている骨格は:

1. `B=14`, `C=0`
2. `HL` 上の 2byte entry 列を走査
3. low nibble が 0 なら skip
4. high nibble が 0 ならそのまま `A=C`
5. high nibble が非 0 なら `block = highNibble - 1` を計算し、`C21F + 16*block` の `+0` に `C` を書く
6. 各 entry に対応して `DE` 側へ `FF` を 1 byte 書く
7. `HL += 2`, `DE += 1`, `C++`

したがって `C21F` は、
少なくとも offset `+0` については
**source slot index を page/category block 単位に再配置する中間 table**
としてかなり強く読める。

## 1. 実コード

```text
60C0: LD C,$7E
60C2: AND $0F
60C4: JR Z,$60D7
60C6: LD A,(HL)
60C7: AND $F0
60C9: JR NZ,$60CE
60CB: LD A,C
60CC: JR $60D9
60CE: SWAP A
60D0: DEC A
60D1: PUSH HL
60D2: CALL $60E2
60D5: LD (HL),C
60D6: POP HL
60D7: LD A,$FF
60D9: LD (DE),A
60DA: INC DE
60DB: INC HL
60DC: INC HL
60DD: INC C
60DE: DEC B
60DF: JR NZ,$60C1
60E1: RET

60E2: LD HL,$C21F
60E5: JP $019B
```

## 2. loop 入力の形

`HL` は毎回 `INC HL` を 2 回受けるので、
ここでも入力は
**2byte entry 列**
と読むのが自然。

しかも最初に:

```text
LD A,(HL)
AND $0F
JR Z,skip
```

なので、
**entry byte0 の low nibble が 0 のものは無効**
と扱っている。

## 3. high nibble の意味

有効 entry では:

```text
LD A,(HL)
AND $F0
JR NZ,$60CE
LD A,C
JR $60D9
```

つまり high nibble が 0 なら
`A=C` のまま fallback し、
非 0 なら:

```text
SWAP A
DEC A
CALL $60E2  ; -> HL = C21F + 16*A
LD (HL),C
```

となる。

ここから、
high nibble は
**`C21F` block index selector**
として使われていると見るのが自然。

## 4. `C21F` の実利用

今回重要なのは、
`C21F` が単に「計算されたアドレス」として現れるだけでなく、
実際に

```text
LD (HL),C
```

で書き込まれていること。

しかも `HL` は `60E2` helper から返った block base のままなので、
書き込み先は
**block offset `+0`**
と読むのが自然。

したがって現時点では:

```ts
C21F[blockIndex * 16 + 0] = sourceIndex
```

までならかなり強く言える。

## 5. `DE` 側への `FF`

loop のたびに:

```text
LD A,$FF
LD (DE),A
INC DE
```

が走るため、
同時にもう 1 本の output list を
`FF` 初期化している。

ここはこの断片だけでは destination の正体がまだ弱いが、
少なくとも
`C21F` block table と並行して
**flat sentinel list**
を作っていると読める。

## 6. `C2DA` / `C21F` とのつながり

この block builder は既報 `5B70-5B91` とかなり近い。

- どちらも 14 件ループ
- low nibble 非 0だけ対象
- high nibble を `SWAP/DEC` して block selector にする
- `C21F + 16*block` の先頭へ index を書く

したがって `C21F` は battle 専用の偶発的 RAM ではなく、
**packed 2byte entry 群から page/category 別の lookup block を構築する中間 table**
とみるのがかなり自然。

## 7. 暫定 struct

```ts
type C21fBlock = {
  sourceIndex0: number  // +0
  rest: Uint8Array      // +1..+F unknown
}
```

まだ `rest` は未確定だが、
少なくとも `+0` の意味は以前より一段強くなった。

## 移植への意味

TypeScript 側では、
`C21F` を「page selector -> source index」写像を持つ block table として分離しておくと整理しやすい。

```ts
buildPrepassBlockIndex(entries)
```

## 次の一手

1. `DE` destination の caller 文脈を追って flat sentinel list の正体を確認する
2. `C21F` block の `+1..+F` を読む consumer を逆引きする
3. `5B70-5B91` と `60C0-60E1` の差分を比較して、battle 専用か共通 helper かを切る
