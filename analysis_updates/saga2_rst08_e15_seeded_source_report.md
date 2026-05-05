# SaGa2 `RST $08 (E=$15)` seeded-source report

## 1. 目的

- `611C` における `RST $08(E=$15)` が何を seeded candidate source として見ているかを整理する
- `611C` の入口契約を、`C20F` / `C73D` / `FF8C` の関係から高位で固定する

## 2. 結論

現時点で `RST $08(E=$15)` は、
**`C20F + 16*player` と `C73D..C744` を前置きした seeded candidate presentation/selection dispatch**
とみるのがもっとも自然である。

今回安全に言えるのは次の 4 点。

1. `RST $08(E=$15)` は `C20F + 16*player = FF..FF` と `C73D..C744 = F0..F7` の直後にだけ呼ばれている  
2. その直後に `01B9 -> FF8C -> 5F07 -> C73D[index] -> 019E` の chain が続く  
3. したがって `E=$15` は raw event code というより、**seeded local candidate set を current selection token に materialize させる前段 dispatch** として読むのが自然  
4. この入口は `C2F6` producer そのものではないが、`0198` backing state に最も近い hidden-local seed helper の入口点としてはかなり有力

要するに `611C` は:

```text
C20F local buffer init
-> C73D seed table init
-> RST $08(E=$15) で candidate を出す
-> 01B9/5F07/019E で 1件を resolve/commit
```

という 1 本の seeded candidate gate として持つのがいまは安全である。

## 3. 対象コード

```text
611F: LD A,($C709)
6122: LD HL,$C20F
6125: CALL $019B
6128: LD A,$FF
612A: LD B,$10
612C: CALL $006D
612F: LD HL,$C73D
6132: LD B,$08
6134: LD A,$F0
6136: LDI (HL),A
6137: INC A
6138: DEC B
6139: JR NZ,$6136
613B: LD E,$15
613D: RST $08
613E: CALL $5F0E
6141: XOR A
6142: CALL $01B9
```

この並びで重要なのは、
`RST $08(E=$15)` の前に caller-local seed/state が明示的に初期化されていることだ。

## 4. `C20F + 16*player` の意味

`6122: LD HL,$C20F ; CALL $019B` のあと、
`612C: CALL $006D` で 16 byte `FF` fill が走る。

ここから少なくとも:

- `C20F + 16*player` は player-local な candidate/selector work
- `RST $08(E=$15)` の前提として reset される

とみるのが自然である。

つまり `E=$15` dispatch は、
**空の player-local work buffer**
を前提に candidate を出している可能性が高い。

## 5. `C73D..C744` の意味

続いて:

```text
612F: LD HL,$C73D
6132: LD B,$08
6134: LD A,$F0
6136: LDI (HL),A
6137: INC A
6138: DEC B
6139: JR NZ,$6136
```

で `F0..F7` の 8 要素 seed table を置いている。

後段では `5F07` の返す index を使って
この table から 1 byte を引いて `019E` へ渡すので、
`RST $08(E=$15)` は少なくともこの 8 要素を参照可能な状態を前提にしている。

したがって `E=$15` は:

- free-form UI message ではなく
- **8 candidate seed を持つ local selection set**

に対する dispatch code とみるのが妥当である。

## 6. `FF8C` との接続

`RST $08(E=$15)` 自体は `FF8C` を直接書いているとはまだ断言しないが、
直後の chain は:

```text
CALL $01B9
LDH A,($FF8C)
CP $FF
RET Z
CALL $5F07
```

で固定されている。

つまり `E=$15` dispatch の役目は、
少なくとも高位では
**`01B9` が解決できる current selection source を提示すること**
だと読める。

これで `RST $08(E=$15)` は、
selection chain の外側ではなく
**その入口**
として位置づけられる。

## 7. 安全な入口契約

現時点の安全な抽象契約は次の程度。

```ts
function dispatchSeededCandidateSetForPlayer(player: number): void
```

前提:

- `playerLocalBuffer(C20F + 16*player)` は `FF` 初期化済み
- `seedTable(C73D..C744)` は `F0..F7` 初期化済み

後段:

- `resolveCurrentSelection()` が `FF8C` を materialize できる
- `validateOrResolveSelection()` が local index を返せる

この意味で `E=$15` は、
単なる message code より
**seeded candidate source dispatcher**
として持つほうが安全である。

## 8. 高位擬似コード

```ts
function seedAndValidatePlayerLocalCandidate(player: number): boolean {
  clearPlayerLocalCandidateBuffer(player) // C20F + 16*player
  initSeedTable(C73D, [0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0xF7])

  dispatchSeededCandidateSetForPlayer(player) // RST $08(E=$15)
  refreshVisibleState()

  resolveCurrentSelection() // 01B9 -> FF8C
  if (FF8C === 0xFF) return false

  const index = validateOrResolveSelection() // 5F07
  const seed = C73D[index]
  consumeResolvedSeedByte(seed) // 019E
  return true
}
```

## 9. `C2F6` 探索への意味

これで `611C` の入口側はかなり閉じた。

特に重要なのは、
`RST $08(E=$15)` が
visible event code そのものではなく、
**hidden-local seed set を current selection chain に接続する dispatch**
として見えてきた点である。

したがって `C2F6` producer 探索で次に見るべきは、

1. `C20F + 16*player` の実 field 意味  
2. `C73D..C744` がどの subsystem 共通 seed 空間なのか  
3. `611C` より前段でこれらを有効化する parent setup

になる。

## 10. 次の一手

1. `C20F` の field 役割を `611C` / `6332` / `10CC` 系と並べて切る  
2. `C73D..C744` を 8要素 seed/remap table として他 caller があるか確認する  
3. `60E8-611B` を `seeded candidate set` の parent setup として再整理する
