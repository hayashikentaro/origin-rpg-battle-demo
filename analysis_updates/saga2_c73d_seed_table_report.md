# SaGa2 `C73D..C744` seed-table report

## 1. 目的

- `C73D..C744` を 8要素 seed/remap table として整理する
- 他 caller が薄いことも含めて、`611C` 専用性がどこまで強いかを明確にする

## 2. 結論

現時点で `C73D..C744` は、
もっとも自然に
**`611C` 内で構築され、そのまま `5F07 -> index -> 019E` へ流れる 8要素 local seed table**
として扱える。

今回安全に言えるのは次の 4 点。

1. `611C` では `C73D..C744` を毎回 `F0..F7` で初期化している  
2. その後 `5F07` の返す index `A` で `C73D + A` を引き、1 byte seed を `019E` に渡している  
3. 現在の高確度観測では、`C73D..C744` の役割が明確に出ているのはこの `611C` chain が中心である  
4. したがって少なくとも現段階では、`C73D..C744` を global shared table より **`611C` local seeded candidate gate 用の remap/seed table**
   とみるほうが安全

つまり `C73D..C744` は、
`C20F` player-local work と組みで使われる
**局所的な 8-entry seed source**
として持つのがいまはもっとも整合する。

## 3. 構築部

`611C` 前半:

```text
612F: LD HL,$C73D
6132: LD B,$08
6134: LD A,$F0
6136: LDI (HL),A
6137: INC A
6138: DEC B
6139: JR NZ,$6136
```

このため `C73D..C744` は毎回:

```text
F0 F1 F2 F3 F4 F5 F6 F7
```

へ初期化される。

固定 ROM table を読むのでなく、
**WRAM 上の一時 seed table**
としてその場で組まれているのが重要である。

## 4. 消費部

`611C` 後半:

```text
614A: CALL $5F07
614D: LD HL,$C73D
6150: RST $00
6151: LD A,(HL)
6152: CALL $019E
```

ここでは:

1. `5F07` が current selection を local index に remap
2. その index を `C73D` へ足す
3. `C73D[index]` の 1byte seed を取る
4. `019E` が consume/commit

という流れになっている。

したがって `C73D..C744` の役割は、
少なくともこの文脈では
**selection result から 1byte seed を引くための local remap table**
とみるのが自然である。

## 5. なぜ「局所 table」とみるか

`C73D..C744` が global subsystem table でなく
局所 table に見える理由は 3 つある。

1. `611C` のたびに `F0..F7` へ再初期化される  
2. その後すぐ同じ helper 内で index 解決と consume が完結する  
3. 現状の高確度観測では、同等に明示的な他 caller がほぼ出ていない

これにより、
`C73D` は少なくとも今の段階では
**persistent shared state** としてより
**current pass の seeded candidate gate 専用 table**
として扱うのが安全になる。

## 6. `C20F` との関係

`611C` では:

- `C20F + 16*player` を `FF` clear
- `C73D..C744` を `F0..F7` seed
- `RST $08(E=$15)` で candidate dispatch
- `01B9 -> FF8C -> 5F07 -> C73D[index] -> 019E`

という順に進む。

したがって `C20F` と `C73D` は独立した無関係の table ではなく、
**同じ seeded candidate gate の local work + local seed**
としてセットで扱うほうが整合する。

## 7. 安全な抽象化

現時点では次の程度の抽象化が安全。

```ts
type SeededCandidateGate = {
  work16: Uint8Array
  seed8: Uint8Array
}
```

ここで:

- `work16` = `C20F + 16*player`
- `seed8` = `C73D..C744`

とみなせる。

## 8. `C2F6` 探索への意味

`C73D..C744` を局所 seed table として置けると、
`611C` はさらに明確に
**hidden-local seeded candidate gate**
として読める。

これは `C2F6` producer そのものを直接示すものではないが、
`0198` backing state に近い layer が

- global visible state
- generic UI dispatch

ではなく、
**player-local work + local seed**
の組として存在することを強く示す。

## 9. 次の一手

1. `60E8-611B` を `C20F/C73D/FF8C` を束ねる parent setup として再整理する  
2. `10CC` 側の `C20F` reader を切って、player-local work の field 粒度を上げる  
3. `C2F6` producer 探索では、この local gate を作るさらに前段の hidden/shared init を引き続き探す
