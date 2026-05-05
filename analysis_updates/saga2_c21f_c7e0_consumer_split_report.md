# SaGa2 `C21F` / `C7E0` Consumer Split Report

## Summary
- `60C0` shared builder の 2 つの出力のうち、**`C7E0..C7ED` 側は consumer がかなり見えている** のに対し、**`C21F + 16*block` の `+1..+F` 側は依然として空白が大きい**。
- このため次の優先順位は、`C7E0` の意味論をさらに深掘りするより、`C21F` block の残り field consumer を優先するほうが探索効率がよい。
- いっぽうで `C7E0` が shared selection workspace であること自体はかなり強く、`60C0` を shared builder とみる根拠としては十分強い。

## 1. `C7E0` 側で既に見えていること

既報から `C7E0..C7ED` は:

- `60B8-60E1` で 14 byte `FF` sentinel list として clear
- `5B64-5B90` で high nibble 0 entry の `sourceIndex` を flat に populate
- bank0 `1237-124B` / `109F-10C2` で `HL = C7E0 + index ; A=(HL) ; CP $FF`

という read/write 両面が見えている。

したがって `C7E0` は、
少なくとも現時点ではかなり安全に

```ts
logicalIndex -> physicalSlotIndex | 0xFF
```

型の **shared sparse remap / candidate list**
として持てる。

## 2. `C21F` 側で見えていること

`C21F` について high-confidence で言えるのは今のところ:

- `5B95` / `60E2` は `C21F + 16 * index`
- `60C0-60E1` は block `+0` に `sourceIndex`
- `6087-60A2` は block head の packed normalize
- `60AA-60B7` は block head clear

までである。

つまり **`+0` の block head / sourceIndex0**
はかなり強いが、
`+1..+F` が何を持つかは
まだ direct consumer が不足している。

## 3. 非対称性の意味

この非対称性は重要。

### `C7E0`
- 既に複数 subsystem から読む consumer がある
- shared selection workspace として実用的な意味づけが可能

### `C21F`
- builder 側 evidence はある
- しかし consumer 側が block `+0` 以外で薄い
- struct 全体を決めるにはまだ材料不足

つまり `60C0` の shared builder 性は
`C7E0` 側だけでもかなり支えられているが、
**shared candidate universe の richer structure** を詰めるには
`C21F` consumer 側の追加 evidence が必要である。

## 4. `611C/0198` との関係

`60C0` を `611C` local gate と `0198/C2F6` shared predicate の
共通前段に置く読みは維持できる。

ただし今後その読みを一段強めるには:

- `C7E0` をさらに読むより
- `C21F` の richer field を読む consumer を見つけて
- shared builder が単なる sparse remap 以上の情報を持つか

を確かめるほうが効果的。

## 5. Updated Priority
1. `C21F + 16*block` の `+1..+F` consumer を優先して洗う  
2. `C7E0..C7ED` は shared sparse remap/list として現状維持  
3. そのうえで `C2F6` が `C21F/C7E0` と同じ larger hidden-init phase に属するかを再確認する

## Safe Porting Implication
- `C7E0` は先に shared selection workspace として切り出してよい
- `C21F` は block struct を `+0` 既知、`+1..+F` unknown のまま保持するほうが安全

```ts
type SharedEntryList14 = Array<number | null>

type C21fBlock = {
  sourceIndex0: number | null
  rest: Uint8Array // unknown
}
```

## Next Steps
1. `C21F` consumer を `10CC` 周辺や `5B95/60E2` caller 文脈から再度逆引きする。
2. `C7E0` は新 evidence が出るまで shared sparse remap/list として固定し、深掘り優先度を一段下げる。
3. `C21F` richer field が見えたら、`60C0` を shared builder から shared candidate-state builder へ一段引き上げる。
