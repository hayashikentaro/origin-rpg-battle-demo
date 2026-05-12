# SaGa2 `RST $18` report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_rng_wait_io_report.md`

## 目的

- `RST $18` の実体を確定する
- `00:068F` 末尾の `RST $18` が何をしているかを整理する

## 結論

`RST $18` は **`A` に入った上位アドレス page を `DMA ($FF46)` へ書き込み、OAM DMA を起動する helper** とみるのが自然。

したがって `00:068F` 末尾の

```text
06AB: LD A,C
06AC: RST $18
```

は乱数や戻り値処理ではなく、**そのフレームで使う OAM staging region を OAM へ転送する処理** 候補。

## 1. vector

ROM 先頭:

```text
0018: JP $FF80
```

実バイト:

```text
00000018: c3 80 ff
```

`RST $18` は HRAM `$FF80` に飛ぶ。

## 2. HRAM stub の本体

ROM `00F0` 付近には次の 5 byte stub がある:

```text
00F0: LDH ($FF46),A
00F2: LD A,$28
00F4: DEC A
00F5: JR NZ,$00F4
00F7: RET
```

実バイト:

```text
000000f0: e0 46 3e 28 3d 20 fd c9
```

`common.i` では:

- `DMA = $FF46`
- `hram.program_oam_dma = $FF80`

と定義されているため、この stub が HRAM `$FF80` に配置されて `RST $18` の飛び先になると読むのが自然。

擬似コード:

```ts
function rst18(page: number): void {
  DMA = page;
  let delay = 0x28;
  while (--delay !== 0) {
    // busy wait during OAM DMA
  }
}
```

## 3. `00:068F` との対応

`00:068F`:

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
06A1: RRCA
06A2: JR C,$06AB
06A4: RRCA
06A5: JR C,$06AB
06A7: LD A,($C7DF)
06AA: LD C,A
06AB: LD A,C
06AC: RST $18
06AD: POP BC
06AE: POP AF
06AF: RET
```

`common.i` の対応ラベル:

- `hram.battle_flag = $FF8B`
- `window_enabled = $C764`
- `hram.window_sprite_mode = $FF96`
- `oam_staging_region = $C7DF`
- `oam_staging_cc = $CC00`

よって `068F` の後半は

1. まず既定値として `C = $CC`
2. battle / window / sprite mode の条件によってはそのまま使う
3. 条件を満たさない通常経路では `C = oam_staging_region`
4. `RST $18` で page `C` から OAM DMA を起動

と読むのが最も自然。

## 4. 解釈

`RST $18` は戻り値を返す API ではなく、
**OAM staging buffer をハードウェア OAM へ反映する出力 primitive** 候補。

そのため `068F` は

- `RST $10` で 1 フレーム進行
- battle / window 状態を見る
- 適切な OAM staging page を選ぶ
- `RST $18` で DMA 転送

という、**frame update + OAM flush** の共通 helper とみなせる。

## 5. 現時点の整理

### 確度が高いこと

- `RST $18` vector は `0018: JP $FF80`
- `$FF80` は OAM DMA 用 HRAM stub の飛び先候補
- stub は `LDH (DMA),A` から始まる
- `068F` の `LD A,C; RST $18` は page 指定付き OAM DMA 起動として自然
- `C7DF` は `oam_staging_region`、`CC00` は `oam_staging_cc`

### まだ未確定なこと

- `C7DF` に入る page 値の完全な生成元
- `FF96` bit0/bit1 の厳密な意味
- `setup_oam_dma` がいつ `FF80` へ stub を転送するか

## 次の一手

1. slot 番号ごとの RNG 用途差を分類する
2. `C7DF/C7DE` の更新箇所を追って OAM staging 選択規則を固める
3. `043E` の callsite を battle / field / script で分類する
