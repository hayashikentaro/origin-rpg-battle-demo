# SaGa2 C21F stride helper report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c2da_producers_report.md`

## 目的

- `01:5B95` / `01:60E2` と `C21F` の関係を整理する
- `C2DA` producer が参照している stride table の役割を一段具体化する

## 結論

`01:5B95` と `01:60E2` は、
どちらも **`A * 16 + $C21F` を返す同型 helper** とみるのが自然。

実コードは:

```text
5B95: CALL $004C
5B98: LD HL,$C21F
5B9B: RST $00
5B9C: RET

60E2: LD HL,$C21F
60E5: JP $019B   ; -> JP $05D9
```

ここで:

- `004C` は `ADD A,A` を 4 回で `A *= 16`
- `RST $00` は既報どおり `HL += A`
- `019B -> 05D9` も battle flag off の通常経路では `05EF -> 004C -> RST $00`

となるため、どちらも本質は同じ。

したがって `C21F` は
**16byte stride の work/descriptor table base**
として扱うのが安全。

## 1. `5B95` の実体

```text
5B95: CALL $004C
5B98: LD HL,$C21F
5B9B: RST $00
5B9C: RET
```

`004C` は:

```text
004C: ADD A,A
004D: ADD A,A
004E: ADD A,A
004F: ADD A,A
0050: ADD A,A
0051: RET
```

ではなく、実際の entry point `004C` から使われるのは
先頭 4 回で十分で、周辺 helper 群から見ても
**`A << 4` を作る multiply-by-16 helper**
として読むのが自然。

その後 `HL=$C21F` へ `RST $00` しているので、

```ts
HL = 0xC21F + A * 16
```

の形になる。

## 2. `60E2` は同型 helper

`01:60C0-60E1` の文脈では:

```text
60CE: SWAP A
60D0: DEC A
60D1: PUSH HL
60D2: CALL $60E2
60D5: LD (HL),C
60D6: POP HL
...
60E2: LD HL,$C21F
60E5: JP $019B
```

`019B -> 05D9` は battle flag off なら:

```text
05E5: LD A,B
05E6: CALL $05EF
05E9: CALL $004C
05EC: RST $00
```

なので、ここも結局
**`C21F + 16 * normalizedA`**
へ飛ぶ helper とみるのが自然。

## 3. `C21F` は何者か

ここで大事なのは、
`C21F` そのものの内容より
**stride**
がかなり強く見えたこと。

`5B70-5B91` でも `60C0-60E1` でも、
高 nibble を `SWAP/DEC` して page-like index に変換し、
その index を `C21F + 16*n` へ対応付けている。

しかも書き込みは:

```text
LD (HL),C
```

だけなので、
少なくとも offset `+0` が
**page selector / source index / slot owner**
のような小さな metadata byte だと読むのが自然。

## 4. `C2DA` producer との関係

`5B70-5B91` の核心は:

```text
low nibble != 0
if high nibble != 0:
  A = highNibble(entry0)
  A = A - 1
  HL = C21F + 16*A
  [HL] = C
```

なので、
`C2DA` entry の high nibble は
**そのまま `C21F` の 16byte block selector**
としても再利用されている可能性が高い。

つまり `C2DA` と `C21F` は独立ではなく、
同じ page/category index を共有していると見るのが自然。

## 5. 今安全に言える仮説

現時点の一番安全な仮置きは:

```ts
type C21fBlock = {
  index0: number      // +0  at least written by 5B70 / 60C0 family
  rest: Uint8Array    // +1..+F unknown
}
```

そして:

```ts
blockIndex = highNibble(c2daEntry0) - 1
blockAddr = 0xC21F + blockIndex * 16
block[0] = sourceIndex
```

という関係。

## 6. 移植への意味

TypeScript 側では、
`C21F` を battle prepass 途中の 16byte-block table として分離して持つのが安全。

```ts
type PrepassBlockTable = Uint8Array // 16-byte blocks
```

ただし、現段階では `block[0]` 以外の意味は未確定。

## 次の一手

1. `60C0-60E1` 全体を切って、`C21F` block の offset `+0` 以外が使われるかを確認する
2. `C21F` を読む consumer を逆引きして 16byte block の実際の field を拾う
3. `C2DA` high nibble と `C21F` block index の対応を battle page (`D0..`) と照合する
