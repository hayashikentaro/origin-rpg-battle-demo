# SaGa2 `00:0469` state machine report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_rng_wait_io_report.md`
- 既存 `saga2_ff89_behavior_report.md`

## 目的

- `00:0469` を擬似コード化する
- `C774` / `C775` / `FF89` / `FF8A` の関係を状態機械として整理する

## 結論

`00:0469` は RNG 本体ではなく、**入力状態 `FF89` の変化と継続時間を見て結果を返す repeat / debounce 系ルーチン** とみるのが自然。

特に重要なのは次の 2 点:

- `C774` は countdown / repeat delay 候補
- `C775` は 前回確定入力 候補

また、従来の仮説と違い、`FF8A` は `05` / `1E` を保持するのではなく、**多くの分岐で現在の `FF89` 値そのもの** を返している。

## 1. 実コード

```text
0469: LDH A,($FF89)
046B: LD C,A
046C: LD A,($C775)
046F: CP C
0470: JR NZ,$0488

0472: LD A,($C774)
0475: DEC A
0476: JR Z,$0480
0478: LD ($C774),A
047B: XOR A
047C: LDH ($FF8A),A
047E: RET

0480: LD A,$05
0482: LD ($C774),A
0485: LD A,C
0486: LDH ($FF8A),A
0488: RET

0488: LD A,$1E
048A: LD ($C774),A
048D: LD A,C
048E: LDH ($FF8A),A
0490: LD ($C775),A
0493: RET
```

## 2. 擬似コード

```ts
function step0469(): number {
  const current = FF89;

  if (current !== C775) {
    C774 = 0x1e;
    FF8A = current;
    C775 = current;
    return FF8A;
  }

  const next = (C774 - 1) & 0xff;

  if (next !== 0) {
    C774 = next;
    FF8A = 0;
    return 0;
  }

  C774 = 0x05;
  FF8A = current;
  return FF8A;
}
```

## 3. 状態解釈

### 入力が変わったとき

- `FF89 != C775`
- `C774 = 0x1E`
- `C775 = FF89`
- `FF8A = FF89`

これは「新しい入力を即座に 1 回返し、その後の repeat 用に初期待ち 30 フレーム前後を入れる」
挙動と読むと非常に自然。

### 同じ入力が続いているとき

- `C774` を減算
- まだ 0 でなければ `FF8A = 0`
- 0 になったら `C774 = 0x05`, `FF8A = FF89`

これは典型的な

- 初回入力は即時
- 長押し中はしばらく無反応
- 以後は短い間隔で repeat

という UI 入力処理に一致する。

## 4. `05` / `1E` の意味

従来は `FF8A` に `00/05/1E` が入ると見ていたが、実際には

- `1E` は `C774` に入る初回 repeat delay
- `05` は `C774` に入る連続 repeat 間隔
- `FF8A` は `0` または `FF89`

と読むのが正しい。

したがって `00:0493` の返り値は

- `0`: まだ repeat 発火していない
- `FF89`: 新入力または repeat 発火

という解釈になる。

## 5. wrapper との整合

### `00:0493`

```text
call 0469
call 068F
ldh  a,(FF8A)
ret
```

これは

- 入力 repeat 判定を進める
- 1 フレーム更新を回す
- 今フレームで有効だった入力だけ返す

という wrapper として自然。

### `00:0CC8`

既存解析どおり `068F` と `0469` を回し、`FF8A == 0` の間ループする構造なら、
これは「新入力または repeat 発火まで待つ」高位 wait API と解釈できる。

## 6. RNG との境界の見直し

`00:0469` 自体は、少なくともこの命令列だけを見る限り

- `random_seeds`
- `data_rng`
- bank 0F lookup

を直接触っていない。

よって、以前の
「`0469` が `0440` を内包する高位 RNG 入口」
という仮説は弱まり、

- `0440` は RNG / table lookup 本体
- `0469` は入力 repeat 制御

として分離して考えるほうが安全になった。

## 7. 現時点の整理

### 確度が高いこと

- `C774` は repeat countdown 候補
- `C775` は前回入力候補
- `FF8A` は result code というより「このフレームで有効な入力値」
- `00:0469` は key repeat / debounce 系ルーチンとして非常に自然

### まだ未確定なこと

- `FF89=0` が無入力か、別の特定入力か
- `FF89` の各 bit の具体的割当
- `0440` と `0469` の静的な隣接が、論理的な関数包含を意味するかどうか

## 次の一手

1. `00:049D` / `00:04A6` の wrapper を `0469` 解釈に合わせて再整理する
2. `FF89` の書き込み元から active-high / active-low を確定する
3. `0440` の返値と battle 側利用箇所を別系統で追う
