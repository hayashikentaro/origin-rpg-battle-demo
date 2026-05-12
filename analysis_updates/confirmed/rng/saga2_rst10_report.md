# SaGa2 `RST $10` report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_rng_wait_io_report.md`

## 目的

- `RST $10` の実体を確定する
- `068F` などの入力/待機 helper における役割を整理する

## 結論

`RST $10` は **1フレーム分の更新を行ったうえで、VBlank 近辺まで待つ frame sync helper** とみるのが自然。

流れは:

1. `00:00D9` へ飛ぶ
2. `CALL $06B0`
3. `HALT`
4. `LY ($FF44) >= $90` になるまで待つ
5. return

したがって `RST $10` は RNG helper ではなく、
**描画/入力/UI 進行の共通フレーム進行 primitive** 候補。

## 1. vector

`RST $10` vector:

```text
0010: JP $00D9
```

## 2. `00:00D9`

```text
00D9: PUSH AF
00DA: CALL $06B0
00DD: HALT
00DE: LDH A,($FF44)
00E0: CP $90
00E2: JR C,$00DD
00E4: POP AF
00E5: RET
```

擬似コード:

```ts
function rst10(): void {
  pushAF();
  stepFrameCore();
  do {
    halt();
  } while (LY < 0x90);
  popAF();
}
```

`LY >= 0x90` は VBlank 期に入った後と読むのが自然。

## 3. `06B0` の役割

先頭:

```text
06B0: PUSH BC
06B1: PUSH DE
06B2: PUSH HL
06B3: LD HL,$C4FF
06B6: INC (HL)
06B7: LD A,(HL)
06B8: LD HL,$C000
06BB: AND $10
06BD: SWAP A
06BF: OR H
06C0: LD H,A
06C1: LD ($C7DF),A
...
```

ここでは少なくとも

- frame counter 風 RAM (`C4FF`) を進める
- `C7DF` に状態値を作る
- 条件に応じて VRAM/OAM 転送っぽい処理を進める

ように見える。

完全な命名はまだ早いが、`RST $10` に対しては
**フレーム更新コア** と見て十分整合する。

## 4. `068F` との関係

`068F` 先頭:

```text
068F: PUSH AF
0690: PUSH BC
0691: RST $10
0692: LD C,$CC
...
06AB: LD A,C
06AC: RST $18
06AD: POP BC
06AE: POP AF
06AF: RET
```

つまり `068F` は

- `RST $10` で 1 フレーム進める
- その後 `FF8B/C764/FF96/C7DF` を見て状態選択
- `RST $18` で何らかの反映

という構造で、`RST $10` は `068F` の下位 primitive。

## 5. callsite との整合

代表例:

- `049D`: 入力が消えるまで `RST $10` を回す
- `068F`: frame update + 状態判定
- `5F0E`: palette/VRAM 更新前の同期
- `68C7/68D2/68F0`: rendering/menu loop 内の同期点

これらはすべて、乱数よりも
**UI / rendering / frame progression** の文脈に属している。

## 6. 現時点の整理

### 確度が高いこと

- `RST $10` は `00D9` を呼ぶ
- `00D9` は `06B0` 実行後に VBlank 近辺まで待つ
- `RST $10` は frame sync helper と読むのが自然
- `068F` は `RST $10` を土台にした高位 wait/update routine

### まだ未確定なこと

- `06B0` の完全な責務名
- `C7DF` のビット/値の意味
- `RST $18` が反映/出力/dispatch のどれか

## 次の一手

1. `RST $18` を契約化する
2. `06B0` の中核 RAM (`C4FF/C7DF/C7DE`) を切る
3. slot 番号ごとの RNG 用途差を分類する
