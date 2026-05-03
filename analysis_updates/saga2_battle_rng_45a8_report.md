# SaGa2 battle RNG 45A8 report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_battle_rng_byte49_gap_report.md`

## 目的

- `0D:45A8` の契約を切る
- `D849` family readback 探索の中で、この helper が何者かを整理する

## 結論

`0D:45A8` はかなり短い helper で、
**`DE` から 2 byte pair を読み、`HL` 側へ page-stride で書く copier**
と読むのが自然。

実コード:

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
45B1: JR NZ,$45A8
45B3: RET
```

ここから言えるのは次の 3 点。

1. `DE` 側は逐次 2 byte を供給する source
2. `HL` 側は low を 2 進め、高位 page を `INC H` で進める destination
3. `C` は反復回数

したがって `45A8` は
`D849/D949/DA49` を直接読む readback helper ではなく、
**generic な 2-byte pair scatter writer**
として扱うのが安全。

## 1. `D849` 探索への意味

今回の目的は byte49 の readback だったが、
`45A8` 自体には:

- `LD A,($D849)` のような direct read
- `LD H,$D8 / LD L,$49` のような固定参照

が見えない。

なので少なくとも
**`45A8` そのものを byte49 consumer とみなす根拠は弱い**。

## 2. helper としての形

このルーチンは、
1 回の反復で:

- source 2 byte を読む
- destination の同 page に 2 byte 書く
- 次は `H++` で 0x100 離れた page へ進む

という形。

擬似コードにすると:

```ts
while (count-- > 0) {
  L += 2
  memory[HL++] = memory[DE++]
  memory[HL] = memory[DE]
  H += 1
}
```

destination を page ごとに縦方向に散らす copier と見るのが自然。

## 3. 何が分かったか

今回の readback 探索で確定したのは、

- `D849` family の write は既知
- `D84D` family の read は既知
- `45A8` は direct `D849` consumer ではなさそう

という境界。

したがって byte49 の意味づけはまだ保留だが、
少なくとも `45A8` を候補から外してよい。

## 次の一手

1. `4361` dispatch 先で `D849` family が現れるか確認する
2. `449A-44F3` が `D849` / `DE00` を触るか追う
3. `4053` で書かれた byte49 が後の phase で比較・分岐に使われるか再探索する
