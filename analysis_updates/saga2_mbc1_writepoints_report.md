# SaGa2 MBC1 writepoints report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_043e_contract_report.md`
- Mesen2 `GbMbc1` を読む前提整理

## 目的

- `SaGa2` ROM 側で MBC1 制御書き込みがどこに現れるかを静的に整理する
- Mesen2 の `GbMbc1` 実装と突き合わせるための高確度 writepoint を先に固める

## 結論

現時点の静的探索では、
`SaGa2` の高確度 MBC1 制御書き込みはまず
**`$2100` への bank select write**
として見えている。

特に:

- `00:04B9  LD ($2100),A`
- `00:1700  LD ($2100),A`
- `00:1708  LD ($2100),A`

は実コードとしてかなり自然。

いっぽう、
`$4000-5FFF` への direct write は
生バイト走査では誤検出が多く、
**今のところ高確度な実コード writepoint は未確定**。

これは `SaGa2` が
`0x03 - MBC1 RAM BATTERY` でありつつも
ROM サイズが 16 bank 規模なので、
実運用上は `2000-3FFF` の low bank select だけで足りている可能性と整合する。

## 1. 前提

既知ヘッダ情報では
`SaGa2 / Final Fantasy Legend II` は:

- cartridge type `0x03` = `MBC1 RAM BATTERY`
- ROM size `0x03` = 16 banks

とされる。

16 bank 規模なら、
MBC1 の high bank bits / mode select をほぼ使わずに
`2000-3FFF` だけで全 ROM bank を切り替えられる。

したがって、
`$2100` への write が主線でも不自然ではない。

## 2. `00:04B9`

既報 `saga2_043e_contract_report.md` でも確認済み:

```text
04B5: LDH A,($FF88)
04B7: LD B,A
04B8: LD A,C
04B9: LD ($2100),A
04BC: LD A,B
04BD: RET
```

これは `RST $28 -> 04B1` の bank swap helper の中核で、
**現在 bank を退避しつつ、新 bank を `2100h` へ書く helper**
として非常に自然。

つまり `SaGa2` の bank 切替は、
少なくとも一般的な table/data access では
この helper を通っている可能性が高い。

## 3. `00:1700` と `00:1708`

実バイト断片:

```text
16FC: 3E 01       LD A,$01
16FE: EA 00 21    LD ($2100),A
1701: CD 2D 50    CALL $502D
1704: F0 88       LDH A,($FF88)
1706: EA 00 21    LD ($2100),A
1709: AF          XOR A
170A: E0 45       LDH ($FF45),A
170C: E0 0F       LDH ($FF0F),A
```

ここでは:

1. bank `01` を選ぶ
2. banked routine `502D` を呼ぶ
3. `FF88` に保存されている元 bank を `2100h` へ戻す

という形に見える。

したがって `1700/1708` は
**固定 bank 呼び出し wrapper の save/restore**
として読むのが自然。

`04B9` の一般 helper とは別に、
IRQ/boot/UI 寄りの局所 wrapper が直書きしている例とみなせる。

## 4. 生バイト走査の限界

ROM 全体で `EA lo hi` を機械的に拾うと、
`2000-5FFF` に見える値は多数出る。

ただしその多くは:

- data を code と誤認
- banked region 側の非コード列
- 即値並びの偶然一致

で説明できる。

今回の静的走査で自然に読めたのは
ほぼ bank0 の `2100h` 書き込みだけだった。

なので MBC1 追跡では、
まず
**`04B1/04B9` helper を経由する bank switch 呼び出し元列挙**
を優先するのが効率的。

## 5. `$4000-5FFF` がまだ薄い理由

MBC1 では本来:

- `4000-5FFF`: RAM bank or ROM high bits
- `6000-7FFF`: mode select

もある。

ただし `SaGa2` は 16 bank ROM なので、
ROM bank high bits を使わずとも全 bank に届く。

そのため今のところ:

- direct high-bit writes がそもそも少ない
- 使っていても限られた初期化/特殊ルーチンだけ

のどちらかだと考えるのが自然。

## 6. Mesen2 観点での読む順

`SaGa2` を Mesen2 で追うなら、
この順がよい。

1. `GbCartFactory` で `0x03 -> GbMbc1` を確認
2. `GbMbc1` で `2000-3FFF` write の ROM bank low-bit 処理を見る
3. `GbMemoryManager` でそれが `4000-7FFF` 読みへどう反映されるか確認
4. `SaGa2` 側では `04B1/04B9` helper caller を列挙する

## 現時点の整理

### 確度が高いこと

- `SaGa2` は MBC1 RAM BATTERY 前提でよい
- `00:04B9` は高確度の `LD ($2100),A`
- `00:1700/1708` も高確度の `LD ($2100),A`
- `SaGa2` の bank 切替主線は `2100h` 書き込み中心の可能性が高い

### まだ未確定なこと

- `4000-5FFF` への高確度 direct writepoint
- `6000-7FFF` mode select 使用有無
- `04B1` helper の全 caller cluster

## 次の一手

1. `04B1/04B9` helper caller を列挙する
2. `RST $28` caller から data/table access 系 bank switch を分類する
3. `4000-5FFF` / `6000-7FFF` は caller 文脈つきで再探索する
