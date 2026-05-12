# SaGa2 `C20F` / `C7E0` / `C2F6` Connection Gap Report

## Summary
- 現時点では、`C20F`, `C7E0`, `C2F6` は同じ selector/runtime 周辺に属していても、**役割はかなり分かれて見えている**。
- `C20F` は player-local selector/candidate work、`C7E0` は shared sparse remap/list、`C2F6` は shared optional-entry presence backing state とみるのが最も整合する。
- ただしこの 3 つが **どこで直接交わるか** はまだ見えていないため、次の主戦場は `C20F/C7E0` 側ではなく、`C2F6` producer を hidden/shared init 側から再度詰める線に戻すのが自然。

## 1. What Looks Stable Now

### `C20F`
- `playerIndex -> C20F + 16*player`
- `611C` 冒頭で `FF` clear
- seeded candidate gate の前提
- `10CC` high-range selector でも player-local source 候補

つまり:

```ts
type PlayerLocalSelectorWork = Uint8Array // 16 bytes
```

### `C7E0`
- `5B64-5B90` で populate
- `60B8-60E1` で sentinel clear
- bank0 `1237/109F` で `A=(HL); CP $FF`

つまり:

```ts
type SharedSparseRemap14 = Array<number | null>
```

### `C2F6`
- `0198 -> 0608 -> 0661` で読む
- optional entry presence predicate の backing state
- direct writer 未発見

つまり:

```ts
type SharedOptionalPresenceState = Uint8Array // exact shape unknown
```

## 2. What Is Missing

いま欠けているのは、次の direct connection。

1. `C20F` local work から `C2F6` presence state へ落ちる path  
2. `C7E0` shared remap が `C2F6` optional state と交わる path  
3. あるいはその両方をまとめて準備する hidden/shared init path

このどれも、静的高確度の既報ではまだ取れていない。

## 3. Why This Matters

`611C` と `0198` は近い層にいるが、

- `611C` = local seed/selection gate
- `0198` = shared optional presence predicate

としてはかなり整理できている。

それでも direct bridge が見えない以上、
ここで `C20F -> C2F6` や `C7E0 -> C2F6` を無理に仮定すると
誤差が大きい。

だから今必要なのは、
local/shared runtime をこれ以上横に読むことより
**shared optional backing state (`C2F6`) の producer を縦に掘ること**
である。

## 4. Safe Current Architecture

```ts
type PlayerLocalSelectorWork = Uint8Array     // C20F
type SharedSparseRemap14 = Array<number|null> // C7E0
type SharedOptionalPresenceState = Uint8Array // C2F6

function seedAndValidatePlayerLocalCandidate(player): boolean // 611C
function resolveSharedSelection(logicalIndex): number | null  // C7E0 path
function hasOptionalEntry(): boolean                          // 0198/C2F6
```

この 3 本は近接するが、
現段階ではまだ別 API として持つのが安全。

## 5. Updated Next Step
したがって次の優先順位は次のように戻すのが自然。

1. `C2F6` producer を hidden/shared init 側から再探索  
2. `C20F/C7E0` は現状の high-confidence role で固定  
3. 新しい evidence が出たときだけ local/shared bridge を再評価

## Implication
- `C21F` は一旦 block-head/index table 寄りに弱める
- `C20F` と `C7E0` は role が固まりつつある
- 本当に詰めるべきギャップは **`C2F6` backing state がいつどこで準備されるか** に戻った

## Next Steps
1. `C2F6` を含む larger hidden block init / import / overlay reload 候補へ再フォーカスする。
2. `0198` caller 直前ではなく、そのさらに前段の mode-entry / hidden init cluster を再抽出する。
3. `C20F/C7E0` は support evidence として維持し、bridge 仮説は保留する。
