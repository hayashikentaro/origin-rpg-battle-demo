# SaGa2 `01B9` selection-resolver report

## 1. 目的

- `01B9` を `FF8C` writer / current selection resolver として整理する
- `611C`, `6621`, `62BE` に共通する gate 入口として、どこまで安全に契約化できるかをまとめる

## 2. 結論

現時点で `01B9` は、
かなり強く
**current selection resolver that writes `FF8C`**
とみるのが自然である。

今回強く言えるのは次の 4 点。

1. `01B9` は少なくとも `611C`, `6621`, `62BE` の 3 系統で共通して使われている  
2. いずれも直後に `LDH A,($FF8C)` が続き、`CP $FF` や `AND A` による gate へ入る  
3. その後は `5F07` による validate/remap か、budget/seed 側の後段へ進む  
4. したがって `01B9` 自体は validate/remap や event dispatch ではなく、**現在の候補/選択を 1byte current-selection token として `FF8C` へ解決する helper**

つまり `01B9` を切ることで、
`611C` の chain は
`RST $08(E=$15) -> 01B9 -> FF8C -> 5F07 -> C73D[index] -> 019E`
としてほぼ入口から出口までつながる。

## 3. caller 1: `611C`

```text
613E: CALL $5F0E
6141: XOR A
6142: CALL $01B9
6145: LDH A,($FF8C)
6147: CP $FF
6149: RET Z
614A: CALL $5F07
```

ここでは:

- `01B9` が current selection を出す
- `FF8C == $FF` なら失敗
- それ以外なら `5F07` で local index へ resolve

したがって `01B9` は
**seeded candidate layer に対する current pick resolve**
として使われている。

## 4. caller 2: `6621`

```text
661D: LD E,$28
661F: RST $08
6620: XOR A
6621: CALL $01B9
6624: LDH A,($FF8C)
6626: CP $FF
6628: JP Z,$65A3
662B: CALL $5F07
662E: AND A
662F: JP NZ,$65A3
```

ここでも構造は同じで、
違うのは `RST $08(E=$28)` の前段 dispatch code だけである。

つまり `01B9` は subsystem ごとの前段 dispatch に依存しつつも、
後段契約は共通で:

1. `FF8C` に current selection token を置く  
2. `FF8C == $FF` なら no valid selection  
3. それ以外なら `5F07` へ渡せる

とみるのが自然。

## 5. caller 3: `62BE`

selector-budget cluster では:

```text
62BA: LD E,$1E
62BC: RST $08
62BD: XOR A
62BE: CALL $01B9
62C1: LD E,$2A
62C3: LDH A,($FF8C)
62C5: CP $FF
62C7: JR Z,$62F9
62C9: AND A
62CA: CALL NZ,$5F07
62CD: JR NZ,$62F9
```

ここは少しだけ使い方が違い、
`FF8C` を見たあと `AND A ; CALL NZ,$5F07` となっている。

ただしこの差は、
selection domain が違うために
「0 は直通、非 0 は追加 resolve」
という前段条件があるだけで、
`01B9` 自体の契約を崩すものではない。

依然として安全に言えるのは、
`01B9` が
**current candidate/selection を `FF8C` token へ resolve**
する helperだという点である。

## 6. `FF8C` の意味

`FF8C` はここまでの共通性から、
かなり安全に:

```ts
type CurrentSelectionToken = number | 0xFF
```

として持てる。

ここで:

- `0xFF` = no selection / invalid / unavailable
- それ以外 = `5F07` で local domain に変換可能な token

とみるのが自然である。

重要なのは、
`FF8C` が final local index そのものではなく、
**ひとつ前段の current selection token**
である可能性が高い点だ。

## 7. `01B9` の安全な契約

現時点の安全な抽象契約は次の程度。

```ts
function resolveCurrentSelection(): void
// side effect: writes FF8C
```

戻り値より side effect が主で、
後段 caller が必ず `FF8C` を読む構造になっている。

したがって `01B9` は、
`FF8C` を外部観測点にした
**selection-state materializer**
として持つのが安全である。

## 8. 高位擬似コード

共通 gate の骨格は次の程度。

```ts
dispatchByCode(E)
resolveCurrentSelection()   // 01B9 -> FF8C
if (FF8C === 0xFF) fail

const localIndex = validateOrResolveSelection() // 5F07
```

`611C` ではその後:

```ts
seedByte = C73D[localIndex]
consumeResolvedSeedByte(seedByte)
```

`6621` では:

```ts
if (localIndex !== 0) fail
```

`62BE` では:

```ts
if (FF8C !== 0) {
  if (validateOrResolveSelection() !== 0) fail
}
```

程度の違いがあるとみるのがいまは安全。

## 9. `C2F6` 探索への意味

これで `611C` の入口側は、

1. `RST $08(E=$15)` で seeded candidate を出す  
2. `01B9` で current selection token を `FF8C` へ materialize  
3. `5F07` で local index へ remap  
4. `C73D[index]` を `019E` へ commit

と整理できる。

つまり `C2F6` backing state に近い hidden-local seed helper の入口・中間・出口が、
かなり一本の chain として見えてきた。

## 10. 次の一手

1. `611C` / `6621` / `62BE` の selection domain 差を比較して、`FF8C` token 空間の違いを整理する  
2. 可能なら `01B9` direct body を追って `FF8C` 以外の副作用先を確認する  
3. `C2F6` 探索としては、この chain のさらに前段、`RST $08(E=$15)` が見る seeded candidate source を詰める
