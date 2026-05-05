# SaGa2 `019E` seed-consumer report

## 1. 目的

- `019E` の contract を、現時点で見えている caller 文脈から整理する
- `611C` の gate 後段で resolved seed byte がどのように扱われるかを明確にする

## 2. 結論

現時点で `019E` は、
かなり安全に
**resolved seed byte consumer / commit helper**
として扱える。

今回強く言えるのは次の 4 点。

1. 現在の高確度 caller は `611C: CALL $019E` が中心である  
2. 入力 `A` は `C73D + remapIndex` から引いた **1byte seed** である  
3. `611C` は `CALL $019E` の成功後にだけ `SCF ; RET` している  
4. したがって `019E` は message/render helper ではなく、**gate で解決した seed byte を次段 state へ反映する helper**

つまり `019E` は、
`C2F6` producer そのものと断言はまだできないものの、
`0198` backing state に近い hidden-local 反映点として重要である。

## 3. caller 文脈

対象コード:

```text
614A: CALL $5F07
614D: LD HL,$C73D
6150: RST $00
6151: LD A,(HL)
6152: CALL $019E
6155: SCF
6156: RET
```

ここでの流れは:

1. `5F07` が current selection を validate/remap して index `A` を返す  
2. `HL=$C73D ; RST $00` で seed table `C73D..C744` を index 解決  
3. `(HL)` の 1 byte seed を `A` に載せる  
4. `CALL $019E`  
5. 成功として carry を立てて return

この構造から、
`019E` は **resolved seed byte を受け取る終端 helper**
とみるのが自然。

## 4. 何ではなさそうか

この caller 文脈だけでも、`019E` について次はかなり言いやすい。

- `RST $08` のような visible dispatch ではない  
- `01B9` のような current selection resolver ではない  
- `5F07` のような validate/remap helper でもない  
- `C73D` seed table の builder でもない

つまり `019E` は、
**解決済み byte の消費先**
として 1 段後ろにいる。

## 5. 安全な契約

現時点の安全な抽象契約は次の程度。

```ts
function consumeResolvedSeedByte(seedByte: number): void
```

副作用先は未確定だが、
caller 構造から見る限り候補は次のどちらかに近い。

1. current player-local candidate state への commit  
2. hidden-local seed/result buffer への write

少なくとも「戻り値を使って分岐する helper」ではなく、
主効果は side effect 側にあるとみるのが自然である。

## 6. `C2F6` 探索への意味

`019E` が重要なのは、
`611C` の gate が最後にここへ落ちるからである。

`611C` は:

- `C20F` fill
- `C73D` seed
- `01B9 -> FF8C`
- `5F07` remap
- `019E` consume

という形で、
`current pick -> resolved seed byte -> commit`
までを 1 本で持っている。

したがって `019E` の書き込み先が見えれば、
`C2F6` backing state か、それに準ずる hidden-local state へかなり近づける。

## 7. 次の一手

1. `5F07` を selector resolve helper として切り、返る index `A` の値空間を固める  
2. `01B9 -> FF8C` を current selection resolver として整理し、`611C` と `6621` の共通 gate をまとめる  
3. `019E` の direct body / writeback 先を追って hidden-local commit 先を確定する
