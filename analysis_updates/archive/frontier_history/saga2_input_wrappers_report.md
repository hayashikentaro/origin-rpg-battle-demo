# SaGa2 input wrapper report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_0469_state_machine_report.md`

## 目的

- `00:049D` / `00:04A6` / `00:0CC4` 周辺 wrapper を整理する
- `0469` を含む高位入力 API の構造を切る

## 結論

`00:049D` と `00:04A6` はどちらも **入力 release 待ち wrapper** とみるのが自然。
これにより `00:0CC4` 付近は

1. まず入力が離されるまで待つ
2. フレーム更新を回す
3. `0469` で新入力 / repeat 発火を待つ

という高位入力待ち API として読める。

## 1. `00:049D`

実コード:

```text
049D: PUSH AF
049E: RST $10
049F: LDH A,($FF89)
04A1: AND A
04A2: JR NZ,$049E
04A4: POP AF
04A5: RET
```

擬似コード:

```ts
function waitUntilNoInputFast(): void {
  pushAF();
  do {
    updateCoreFast();
  } while (FF89 !== 0);
  popAF();
}
```

観察点:

- `RST $10` のあと `FF89` を直読み
- `FF89 != 0` のあいだ回り続ける

したがって、これは **ボタンが離されるまで busy-wait する軽量 wrapper** 候補。

## 2. `00:04A6`

実コード:

```text
04A6: PUSH AF
04A7: CALL $068F
04AA: LDH A,($FF89)
04AC: AND A
04AD: JR NZ,$04A7
04AF: POP AF
04B0: RET
```

擬似コード:

```ts
function waitUntilNoInputFrame(): void {
  pushAF();
  do {
    frameWaitAndPollInput();
  } while (FF89 !== 0);
  popAF();
}
```

`049D` との違い:

- `049D` は `RST $10` ベース
- `04A6` は `CALL 068F` ベース

つまり前者は軽量更新、後者は UI/スクリプト文脈で安全なフレーム待ち付き release wait の可能性が高い。

## 3. `00:0CC4` 周辺

実コード:

```text
0CC4: CALL $04A6
0CC7: CALL $068F
0CCA: CALL $0469
0CCD: LDH A,($FF8A)
0CCF: AND A
0CD0: JR Z,$0CC7
0CD2: JP $04A6
```

擬似コード:

```ts
function waitForFreshInput(): void {
  waitUntilNoInputFrame();

  do {
    frameWaitAndPollInput();
    step0469();
  } while (FF8A === 0);

  waitUntilNoInputFrame();
}
```

## 4. 解釈

この構造は典型的な UI 入力ハンドラ:

- 前フレームから押しっぱなしの入力をまず捨てる
- 新しい押下、または repeat 発火まで待つ
- 消費後、必要なら再び release まで待つ

特に `0469` が key repeat 状態機械だと分かったことで、`0CC4` は RNG や script random ではなく
**メニュー/会話/戦闘共通の確定入力待ち** に見える。

## 5. `0493` との役割分担

### `0493`

```text
call 0469
call 068F
return FF8A
```

1 フレーム進めて「今有効だった入力」を返す単発 API。

### `0CC4`

release wait と新入力 wait を含む、より高位のブロッキング API。

### `049D` / `04A6`

どちらも release wait だが、更新ルーチンが異なる。

## 6. 現時点の整理

### 確度が高いこと

- `049D` は `FF89 == 0` になるまで回す release wait 候補
- `04A6` も `FF89 == 0` になるまで回す frame-based release wait 候補
- `0CC4` 周辺は fresh input を待つ高位 API として自然
- `0469` はこの API 群の一部であり、RNG 本体とは責務が違う

### まだ未確定なこと

- `RST $10` の厳密な副作用
- `0CD2` の `JP 04A6` が API 契約として必須か、呼び出し側文脈依存か
- `FF89 = 0` が truly no-input かどうか

## 次の一手

1. `RST $10` の正体を切る
2. `0440` 側を battle / damage 利用から逆引きする
3. `FF89` 書き込み元から joypad bit 配置を確定する
