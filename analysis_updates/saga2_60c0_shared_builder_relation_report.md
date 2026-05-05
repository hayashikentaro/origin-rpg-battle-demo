# SaGa2 `60C0` Shared-Builder Relation Report

## Summary
- `60C0-60E1` は依然として `C2F6` direct producer とは言えないが、`611C` local gate と `0198/C2F6` shared predicate の **共通前段 shared builder 候補** として持つのが最も安全になった。
- 理由は、`60C0` が `C2DA` packed entry を走査して `C21F` block head と `C7E0..C7ED` sentinel list を構築する一方、`611C` も `0198` もその後段の candidate/presence 判定層に属しているからである。
- 現時点では `60C0 -> 611C`、`60C0 -> 0198/C2F6` の direct dataflow は未確定だが、少なくとも **両者のさらに前段で shared candidate universe を整える builder** という位置づけはかなり自然。

## What `60C0` Clearly Does
既報から、`60C0-60E1` は:

- `HL = C2DA`
- `DE = C7E0`
- `B = 0x0E`
- 14 件 2 byte entry 走査

のもとで、

1. `C21F + 16*block` の `+0` に `sourceIndex`
2. `C7E0..C7ED` に `FF` sentinel

を並行構築する。

つまり high-level には:

```ts
buildSharedCandidateBlocksAndSentinels(c2daEntries)
```

に近い。

## Why It Sits Before Both `611C` And `0198`

### `611C` side
`611C` は:

- `C20F` local candidate workspace
- `C73D` local seed/remap
- `FF8C -> 5F07 -> 019E`

を使う local gate である。

この helper 自体は player-local だが、
何を candidate universe として扱うかは
さらに前段の shared builder が必要になる。

`60C0` の `C2DA -> C21F/C7E0` 構築は、
ちょうどその **shared candidate universe**
を整える側にいると読むのが自然。

### `0198/C2F6` side
`0198` は:

- `C2F6` 系 table を読む
- optional entry presence だけを返す

shared predicate である。

これも player-local の選択処理ではなく、
shared optional state を見る層にある。

`60C0` が shared candidate/bucket/sentinel を作る builder なら、
`0198/C2F6` と同じく **shared side** に属していると考えるのが自然。

## What Is Still Missing
ただし、現時点では次の 2 本はまだ取れていない。

1. `C21F/C7E0` を `611C` が直接または間接に読む証拠
2. `C21F/C7E0` と `C2F6` が同じ larger hidden block に属する direct 証拠

そのため `60C0` を
「`C2F6` を作る helper」
と言い切るのはまだ危険。

安全な言い方は、

**`611C` local gate と `0198/C2F6` shared predicate のさらに前段で shared candidate state を整える builder 候補**

である。

## Safe Architectural Reading
現時点で最も安全な高位構造は次のようになる。

```ts
function buildSharedCandidateState(entries) {   // 60C0
  buildBlockHeads(C21F, entries)
  buildFlatSentinels(C7E0, entries)
}

function hasOptionalEntry(): boolean {          // 0198
  return readSharedOptionalState(C2F6)
}

function seedAndValidatePlayerLocalCandidate(player: number): boolean { // 611C
  resetLocalCandidateBuffer(player)
  initLocalSeedTable(player)
  return resolveAndCommitSelectionForPlayer(player)
}
```

この形なら、
`60C0` は shared builder、
`0198` は shared predicate、
`611C` は local gate
として衝突せずに並べられる。

## Updated Priority
この整理を反映すると、次の優先順位が妥当。

1. `60C0-60E1` の `C21F/C7E0` consumer を探し、shared builder 性を補強する
2. `611C-6156` を local gate として維持し、`60C0` 前提入力との接続を探る
3. `0198/C2F6` を shared predicate として維持し、shared builder との block-level 近接を探る

## Next Steps
1. `C21F` block の `+1..+F` consumer を優先して洗い、`shared candidate state` の実体を増やす。
2. `C7E0..C7ED` consumer を battle/item setup 文脈で再確認し、flat sentinel list の生存期間を切る。
3. `C2F6` が `C21F/C7E0` と同じ larger hidden-init phase に属するか、bulk init / import 側から再検証する。
