# SaGa2 RNG wait / IO report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 script opcode reports

## 目的

- `00:068F` の役割を切る
- `FF89` / `FF8A` が RNG wrapper 周辺で何を担っているかを整理する

## 結論

### `00:068F`

`00:068F` は RNG 専用ではなく、**`RST $10` を土台にした入力待ち / フレーム更新 / OAM DMA 反映の共通ルーチン** とみるのが自然。

### `FF89`

`FF89` は `00:0469` 周辺で読み出され、RNG 消費後の判定材料として使われる
**入力または状態フラグ系の一時値** 候補。

### `FF8A`

`FF8A` は `00:0469` 内部で設定され、`00:0493` や `00:0CC8` の戻り値 / 継続判定に使われる
**このフレームで有効になった入力値** 候補。

## 1. `00:068F` の実コード

先頭:

```text
068F: PUSH AF
0690: PUSH BC
0691: RST $10
0692: LD C,$CC
0694: LDH A,($FF8B)
0696: AND A
0697: JR NZ,$06AB
0699: LD A,($C764)
069C: AND A
069D: JR NZ,$06AB
069F: LDH A,($FF96)
06A1: RRCA/flag test
...
06A7: LD A,($C7DF)
06AA: LD C,A
06AB: LD A,C
06AC: RST $18
06AD: POP BC
06AE: POP AF
06AF: RET
```

ここで `RST $18` は `0018: JP $FF80` から HRAM OAM DMA stub へ飛ぶため、
`068F` の末尾は値返却ではなく **OAM staging page の DMA 転送** とみるのが自然。

## 2. `00:068F` の呼び出し文脈

direct call/jp 検出:

- `CALL 068F` at `00:0497`
- `CALL 068F` at `00:04A7`
- `CALL 068F` at `00:07A1`
- `CALL 068F` at `00:0913`
- `CALL 068F` at `00:0AEA`
- `CALL 068F` at `00:0CC5`
- `CALL 068F` at `00:0CDB`
- `CALL 068F` at `00:0CDE`
- `CALL 068F` at `00:0E6C`
- `JP 068F` at `00:0CD6`

既存解析との対応:

- `WAIT_INPUT_OR_PAUSE`
- `WAIT_OR_UPDATE_SCRIPT_INPUT`
- `WAIT_N_FRAMES_OR_REPEAT`

よって `068F` は

- `RST $10` ベースの frame wait
- input poll/update
- text/menu/battle 共通の進行更新
- 必要な OAM staging page の DMA 反映

に使われる共有ルーチンとみてよい。

## 3. `RST $18` の意味

`RST $18` vector:

```text
0018: JP $FF80
```

HRAM stub 元データ:

```text
00F0: LDH ($FF46),A
00F2: LD A,$28
00F4: DEC A
00F5: JR NZ,$00F4
00F7: RET
```

`common.i` では

- `DMA = $FF46`
- `oam_staging_region = $C7DF`
- `oam_staging_cc = $CC00`

と定義されている。

したがって `068F` 後半は

- 既定 page `C = $CC`
- battle / window 状態で条件分岐
- 通常経路では `C = (oam_staging_region)`
- `LD A,C; RST $18` で DMA 起動

と解釈できる。
## 4. `FF8A` の使われ方

### 書き込み

`00:0469` 近傍:

- `00:047C` `LDH ($FF8A),A`
- `00:0485` `LDH ($FF8A),A`
- `00:048E` `LDH ($FF8A),A`

このルーチンの実際の書き込みは

- 同一入力継続中かつ countdown 未満なら `FF8A = 00`
- 新入力検出時は `FF8A = FF89`
- repeat 発火時も `FF8A = FF89`

であり、`05` / `1E` は `FF8A` ではなく `C774` に入る repeat 間隔値。

### 読み出し

- `00:049A` `LDH A,($FF8A)`
- `00:0CCB` `LDH A,($FF8A)`

使われ方:

- `00:0493` wrapper の戻り値
- `00:0CC8` ループの継続判定

### 解釈

`FF8A` は乱数値そのものではなく、
**待機/入力制御を通った有効入力値** の可能性が高い。

## 5. `FF89` の使われ方

検出:

- `00:0469`
- `00:049F`
- `00:04AA`
- `00:1766`
- `00:29A3`
- `01:68B5`
- `01:68F5`

RNG 近傍のパターン:

```text
0469: LDH A,($FF89)
...
049F: LDH A,($FF89)
04AA: LDH A,($FF89)
```

`00:0469` 内部では `FF89` を前回値 `C775` と比較し、`C774` countdown を更新しながら `FF8A` を決めている。

### 解釈

`FF89` は

- 直近入力
- ボタン / 方向状態
- ある種の pending action flag

のいずれかで、`00:0469` の結果コード生成に使われる一時状態と見るのが自然。

## 6. `00:0469` / `00:0493` / `00:0CC8` の再解釈

### `00:0469`

- `FF89` と `C775` を比較
- `C774` を repeat countdown として更新
- `FF8A` に「このフレームで有効な入力」を書き込む

### `00:0493`

```text
call 0469
call 068F
return FF8A
```

これは「key repeat 状態を一歩進めて、待機更新を 1 回回し、有効入力を返す」wrapper 候補。

### `00:0CC8`

```text
call 068F
call 0469
if FF8A == 0: repeat
```

これは「入力または repeat 発火が有効になるまで待つ」ループ候補で、
RNG そのものより**待機制御 + 判定**の高位 API とみるのが安全。

### `00:049D` / `00:04A6`

- `00:049D` は `RST $10` を回しつつ `FF89 == 0` を待つ軽量 release wait 候補
- `00:04A6` は `068F` を回しつつ `FF89 == 0` を待つ frame-based release wait 候補

したがって `0CC4` 付近は

- release wait
- frame wait
- fresh input / repeat wait

を組み合わせた高位入力 API と読める。

## 7. 現時点の整理

### 確度が高いこと

- `068F` は `RST $10` を下位 primitive に持つ入力待ち/更新/OAM 反映系の共有ルーチン
- `FF8A` は wrapper の有効入力値
- `FF89` は `0469` の分岐条件に使う入力/状態フラグ系
- `0469` は key repeat / 入力待ち制御ルーチンとして自然
- `049D` / `04A6` は input release wait wrapper として自然
- `RST $18` は page 指定付き OAM DMA helper として自然

### まだ未確定なこと

- `FF89` のビット意味
- `FF89` の active-high / active-low
- `0440` と `0469` が本当に論理的に結合しているか

## 次の一手

1. slot 番号ごとの RNG 用途差を分類する
2. `C7DF/C7DE` の更新箇所を切って OAM staging 切替規則を固める
3. `0440` を battle 側から別系統で追う
