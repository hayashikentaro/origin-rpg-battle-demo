# SaGa2 `611C` / `0198` Proximity Report

## Summary
- `611C` は依然として `C2F6` producer に最も近い **hidden-local seed/validate gate** 候補だが、`0198` そのものと同一層ではない。
- `0198` は `C2F6` 系 table を読む **shared optional-entry presence predicate**、`611C` は `C20F/C73D/FF8C/5F07/019E` を束ねる **player-local seed/selection gate** とみるのが最も整合する。
- したがって両者の関係は「同一 helper family」ではなく、**`0198` が shared optional state を返し、`611C` がその手前または隣接層で local candidate state を作る** と整理するのが安全。

## What Is Shared

### `0198`
既報から、`0198` は:

- `E=0` 固定で `C2F6` 系 table を読む
- caller では `AND A` / `JR Z` の predicate としてだけ使われる
- battle 側 `405C` と selector 側 `633F` の両方で
  optional page/slot/entry の有無を返す

つまり high-level には:

```ts
checkOptionalEntryPresence(): boolean
```

に近い。

### `611C`
既報から、`611C` は:

- `C20F + 16*player` を `FF` clear
- `C73D..C744` を `F0..F7` で初期化
- `RST $08(E=$15) -> 01B9 -> FF8C -> 5F07 -> C73D[index] -> 019E`

を 1 本に束ねる。

つまり high-level には:

```ts
seedAndValidatePlayerLocalCandidate(player): boolean
```

に近い。

## Why They Feel Close
- どちらも heavy action routine ではなく、後段 phase を開くかどうかの gate に使われる
- どちらも candidate/optional state の存在や妥当性を見る
- どちらも visible event helper ではなく runtime state 寄り

このため、`611C` は `0198` backing state に近い、という評価自体は維持できる。

## Why They Are Not The Same Layer
ただし差もかなり明確。

### `0198` side
- input は実質 `E=0`
- source は `C2F6` shared state
- output は boolean-like predicate
- caller は extra iteration / zero-clear の分岐に使う

### `611C` side
- input は `player_index ($C709)` を含む player-local context
- source は `C20F`, `C73D`, `FF8C`, `5F07`
- output は selection 成功/失敗と resolved seed commit
- caller は `6157` apply/staging を開く gate に使う

したがって `611C` は `0198` と同じ predicate helper ではなく、
**predicate より一段厚い local seed/selection gate**
とみるのが自然。

## Safe Architectural Reading
現時点で最も安全な高位構造は次のようになる。

```ts
function hasOptionalEntry(): boolean {   // 0198
  return readSharedOptionalState(C2F6)
}

function seedAndValidatePlayerLocalCandidate(player: number): boolean { // 611C
  resetLocalCandidateBuffer(player)   // C20F
  initLocalSeedTable()                // C73D
  const selection = resolveSelection() // FF8C -> 5F07
  if (!selection) return false
  commitResolvedSeed(selection.seedByte) // 019E
  return true
}
```

この読み方なら、

- `0198` は shared optional-entry gate
- `611C` は player-local gate

として衝突せずに共存できる。

## Implication For `C2F6`
- `611C` 自体が `C2F6` を直接読む証拠はまだない
- それでも `611C` が最有力なのは、`C2F6` producer が必要とする hidden-local candidate state に最も近いから
- ただし今後の本命は「`611C` をさらに掘る」だけでなく、**`611C` の前段 shared builder (`60C0`) と shared predicate (`0198/C2F6`) をつなぐ線** にある

## Updated Priority
1. `611C-6156` を hidden-local gate として維持
2. `0198/C2F6` を shared optional gate として維持
3. `60C0-60E1` を両者の前段 shared builder 候補として再固定

## Next Steps
1. `60C0-60E1` の `DE` destination を再固定して、`611C` local gate と `0198/C2F6` shared gate の共通前段になり得るかを確認する。
2. `611C` と `405C` の caller 文脈差をもう一段比較し、`0198` が local seed 成否ではなく shared optional presence だけを見ることを補強する。
3. `019E` の副作用先が `C2F6` family と交わるかを引き続き監視する。
