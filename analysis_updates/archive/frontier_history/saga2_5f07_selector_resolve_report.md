# SaGa2 `5F07` selector-resolve report

## 1. 目的

- `5F07` の契約を、現時点で見えている caller 文脈から整理する
- `611C` と `662B` に共通する gate helper として、返る `A` の意味をどこまで安全に言えるかをまとめる

## 2. 結論

現時点で `5F07` は、
かなり自然に
**current selection validate/remap helper**
として読める。

今回強く言えるのは次の 4 点。

1. `5F07` は少なくとも `611C` と `662B` の両方で、`01B9 -> FF8C` の直後に呼ばれている  
2. `662B` 側では返り値 `A` を `AND A` して failure gate に使っている  
3. `611C` 側では返り値 `A` を `C73D + A` の index に使っている  
4. したがって `5F07` は、`FF8C` current selection を受けて **成否付きの remap index** を返す helper とみるのがもっとも自然

つまり `5F07` は visible event helper ではなく、
`current pick -> usable local index`
への変換点に近い。

## 3. caller 1: `611C`

`611C` 後段:

```text
6142: CALL $01B9
6145: LDH A,($FF8C)
6147: CP $FF
6149: RET Z
614A: CALL $5F07
614D: LD HL,$C73D
6150: RST $00
6151: LD A,(HL)
6152: CALL $019E
```

ここでは:

1. `01B9` が current selection を `FF8C` に resolve
2. `FF8C == $FF` なら失敗
3. それ以外は `5F07`
4. 戻った `A` を `C73D` seed table index に使う

このため `5F07` の返り値 `A` は、
少なくとも `611C` では
**0..7 近辺の local seed index**
に近いものだと考えるのが自然である。

厳密な上限はまだ断定しないほうが安全だが、
`C73D..C744` が 8 要素である以上、
最終的にはその range に収まっているはずである。

## 4. caller 2: `662B`

`6621-662F`:

```text
6621: CALL $01B9
6624: LDH A,($FF8C)
6626: CP $FF
6628: JP Z,$65A3
662B: CALL $5F07
662E: AND A
662F: JP NZ,$65A3
```

ここでは `5F07` の返り値を
**ゼロなら通過、非ゼロなら失敗**
として使っている。

この使い方は 2 通りに読める。

1. `5F07` が boolean-like status を返す  
2. `5F07` が remap index を返し、`0` だけが adoptable case

ただし `611C` では同じ `5F07` の返り値を index に使っているため、
今のところ安全なのは後者寄りの読みである。

つまり `5F07` は:

- selection を検証し
- domain ごとの local index へ正規化し
- caller によっては `0` 以外を reject とみなす

helper と考えるのが自然。

## 5. `FF8C` との関係

`5F07` はどちらの caller でも、
必ず `01B9 -> FF8C` のあとに現れる。

したがって契約はかなり安全に:

```ts
function resolveSelectionToLocalIndex(currentSelectionFromFF8C): number
```

方向で持てる。

少なくとも:

- `FF8C` を書く helperではない
- `FF8C` sentinel 判定の前には来ない
- current selection が存在する前提でのみ呼ばれる

ので、`5F07` 自体は
**selection existence check** ではなく
**selection normalization/remap**
の担当とみるのが妥当である。

## 6. 安全な契約

現時点の安全な抽象契約は次の程度。

```ts
function validateOrResolveSelection(): number
```

ここでの返り値は:

- caller `611C` では local seed index
- caller `662B` では gate status を兼ねる remap result

として使われている。

つまり value 空間は未確定でも、
少なくとも `FF8C` raw value そのものではなく、
**caller-local domain へ一段変換された値**
とみるのが自然。

## 7. 高位擬似コード

安全な高位擬似コードは次の程度。

```ts
resolveCurrentSelection()          // 01B9 -> FF8C
if (FF8C === 0xFF) fail

const localIndex = validateOrResolveSelection() // 5F07
```

`611C` では:

```ts
seedByte = C73D[localIndex]
consumeResolvedSeedByte(seedByte)
```

`662B` では:

```ts
if (localIndex !== 0) fail
```

とみるのがいまは安全。

## 8. `C2F6` 探索への意味

`5F07` が重要なのは、
`611C` における
`current pick -> local seed index -> seed byte -> commit`
の真ん中にあるからである。

これで `611C` の chain は:

1. `01B9 -> FF8C`
2. `5F07 -> local index`
3. `C73D + index -> seed byte`
4. `019E -> consume/commit`

とかなり明確になった。

したがって次に `01B9` を切ると、
hidden-local seed helper の入口側もかなり閉じる。

## 9. 次の一手

1. `01B9` を `FF8C` writer / current selection resolver として整理する  
2. `611C` と `6621` の共通 gate をまとめて、selection domain 差を比べる  
3. 可能なら `5F07` direct body を追って local index 値空間を確定する
