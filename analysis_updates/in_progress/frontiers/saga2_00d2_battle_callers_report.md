# SaGa2 00D2 battle callers report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_bank_switch_helper_callers_report.md`
- 既存 `saga2_actors_loop_report.md`
- 既存 `saga2_battle_state_helpers_report.md`

## 目的

- `CALL $00D2` のうち battle 側 caller を抽出する
- battle descriptor read の主線を item/script 側から分離する

## 結論

`CALL $00D2` の battle 側 caller は、
現時点では大きく 2 群に分けられる。

1. **bank `0D:42D4-442A` cluster**  
   `C1A5-C1AC` 周辺の 3 byte / 4 byte work を組み立てる descriptor read 群
2. **bank `0D:523B` と `0D:5F7D` cluster**  
   battle 中ではあるが、別用途の banked data read 群

最も重要なのは前者で、
これは `actors` queue / `4361` state helper の近傍にあり、
**battle action kind や target/parameter 風の small descriptor を banked ROM から引いて `C1A5-C1AC` へ展開する cluster**
として読むのが自然。

したがって、
今後 `SaGa2` の battle core を詰めるなら
**`42D4-442A` cluster を `00D2` caller 主線として追う**
のがよい。

## 1. battle 側 caller 一覧

静的列挙した `CALL $00D2` のうち、
battle 側とみなせる bank `0D` の callsite は次の 15 箇所。

```text
0D:42D4
0D:42E4
0D:42ED
0D:42FE
0D:4309
0D:4310
0D:4329
0D:4341
0D:436C
0D:4373
0D:4417
0D:442A
0D:4552
0D:523B
0D:5F7D
```

ただし `4552/523B/5F7D` は現時点で周辺 bytes が code 断片として弱く、
まずは `42D4-442A` を主線に置くのが安全。

## 2. `42D4-4309` cluster

この帯は `42B9` 以降の流れの続きで、
既報どおり:

- `transformation_flag/result/index`
- `state 09`
- `C1A5-C1A9` work

と隣接している。

実際の断片を見ると:

```text
42D4: ... CD 5F 01
42DB: LD E,$00
42DD: LD A,($C1AB)
42E0: AND $80
42E2: JR Z,...
42E4: LD E,$FF
...
42FE: ...
4309: ...
```

ここでは `00D2` で引いた値を:

- `C1A5`
- `C1A6`
- `C1A7`
- `C1AB`

へ反映しているように見える。

したがってこの cluster は、
**battle action parameter / pointer / flags を一時 work へ展開する**
段だと読むのが自然。

## 3. `4329-4373` cluster

この帯はさらに分かりやすく、
`00D2` そのものより上位 helper 群と一緒にまとまっている。

断片:

```text
4329: ... 11 A5 C1 21 A8 C1 CD 62 01 ...
4341: ... 11 A5 C1 21 A8 C1 CD 65 01 ...
436C: ... 21 A5 C1 11 A8 C1 1A A6 22 13 1A A6 22 ...
4373: ... 21 A5 C1 11 A8 C1 1A B6 22 13 1A B6 22 ...
```

ここから見えること:

- `C1A5-C1A7` と `C1A8-C1AA` が 2 組の small work buffer
- `0162/0165` helper を通して何らかの比較/変換を行う
- `436C/4373` では `A6/B6` による OR 合成をして 3 byte を作る

つまり battle 側の `00D2` 読みは、
単に ROM byte を返すだけでなく
**small battle descriptor を 2 系統から読み、比較・合成して正規化**
する前処理の一部だと見える。

## 4. `4417-442A` cluster

この帯は特に action kind 解決に近そうな形を持つ。

断片:

```text
4417: ... LD HL,$C1AC
441B: LD BC,$C1A5
441E: LD A,(BC)
4422: LD (HL+),A
...
442A: ... AND $1F
442D: CP $13
4431: CP $12
4437: LD C,A
443B: ...
443F: LD E,$00
4441: LD A,$05
4443: CALL $016B
```

重要なのは後半で:

- `C1A5...` から 3 byte を `C1AC...` へコピー
- low 5bit を見て `0x12/0x13` と比較
- その結果に応じて `CALL $016B`、つまり `JP $043E` に入る

つまり
**battle 側で `043E` RNG helper に届く最初の強い主線候補**
がここにある。

しかも直前まで `00D2` cluster が `C1A5-C1AC` を作っているので、
流れは:

1. `00D2` で battle descriptor read
2. `C1A5-C1AC` へ正規化
3. action low5bit / class を判定
4. 必要なら `016B -> 043E` で RNG を使う

と読むのがかなり自然。

## 5. `4552/523B/5F7D` について

今回の静的 dump だけでは、
この 3 箇所は周辺 bytes が code/data 境界としてまだ弱い。

したがって現段階では:

- battle bank に属する `00D2` caller
- ただし priority は低い

として保留するのが安全。

今は `42D4-442A` を先に切るほうが、
battle core RNG と action kind 解決に直結しやすい。

## 現時点の整理

### 確度が高いこと

- battle 側 `00D2` caller は bank `0D` に集中している
- `42D4-442A` cluster は `C1A5-C1AC` の small descriptor/work 構築に見える
- `4417-442A` では action low5bit 判定のあと `CALL $016B` が現れる
- したがってここは battle core RNG へ届く強い主線候補

### まだ未確定なこと

- `C1A5-C1AC` 各 byte の正式な意味
- `0x12/0x13` 比較の意味
- `0162/0165/015F` helper 群の契約
- `4552/523B/5F7D` の役割

## 次の一手

1. `4417-4443` を擬似コード化する
2. `CALL $016B` の直前 `A/$DE` 契約を battle 文脈で確定する
3. `C1A5-C1AC` を action descriptor struct として仮ラベル化する
