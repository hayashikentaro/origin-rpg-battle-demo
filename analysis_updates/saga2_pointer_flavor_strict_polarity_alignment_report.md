# Saga2 PointerFlavor Strict-Polarity Alignment Report

## 要点

- current best reading では、`pointerFlavor="candidate"` は generic candidate reopening ではなく、**first-line の strict-side polarity を保った candidate provenance reopening** とみるのが最も自然である
- したがって `branchVariant` と `pointerFlavor="candidate"` の対応は、単に同じ `D?12..` family 由来というだけでなく、**strict-leaning side が second-line でも candidate provenance として reopening する** と読むのが safest である
- このため current frontier では、`branchVariant 0/1` の numeric naming より先に、**strict-side polarity と `pointerFlavor="candidate"` の alignment** を fixed point にするのが battle-side evidence に最も合う

## 1. Why The Alignment Matters

既報では:

- `branchVariant`
  = `0E/0F` 主軸の first-line compressed split
- blocked ordinal shadow
  = strict/non-fast-path 側へ寄る
- `pointerFlavor="candidate"`
  = code-led candidate provenance carry

と整理している。

この 3 本を合わせると、
`pointerFlavor="candidate"`
は単なる PTR marker ではなく、
**strict-side に寄った first-line refinement が second-line で provenance reopening した結果**
と読むのが最も自然になる。

つまり alignment の核心は:

- first-line の strict-side polarity
- second-line の candidate provenance

が同じ差分の上下流である、という点にある。

## 2. Why Candidate Reopening Fits The Strict Side Better

既報では `target` より `pointerFlavor`
のほうが PTR-specific reopening の中心であり、
`postBranchTargetSource`
はその前段 marker に過ぎないと整理している。

この前提を採ると、
strict-side polarity が second-line に carry される場所も、
target ラベルより
**pointer/materialization provenance**
のほうが自然である。

つまり:

- fast/shortcut 側なら second-line reopening が薄い
- strict/non-fast-path 側なら second-line reopening が candidate provenance として強く残る

とみるのが safest になる。

## 3. Why This Still Does Not Force `0` Or `1`

この alignment は、
`branchVariant=0`
と `1`
のどちらが strict-side かをまだ決めなくても成立する。

current best reading では、
必要なのは

- one side = strict-leaning
- that side aligns with `pointerFlavor="candidate"`

という polarity relation であって、
numeric side naming 自体ではない。

したがって safest reading は、
まず
**strict-side polarity <-> candidate provenance reopening**
の対応を固定し、
`0/1` の名前付けは second-order issue として保留することである。

## 4. Relation To `target`

既報では final `target`
は `pointerFlavor`
の downstream result と読むのが current best である。

このため strict-side polarity の carry も、
まずは `pointerFlavor="candidate"`
に現れ、
その結果として downstream で target 差分が出る、
という順序で持つのが最も自然になる。

つまり current safest role split は:

- `branchVariant`
  = first-line strict-side refinement
- `pointerFlavor="candidate"`
  = second-line strict-side provenance reopening
- `target`
  =その downstream result

である。

## 5. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
branchVariant?: 0 | 1
pointerFlavor: "shared" | "candidate"
```

の関係について、

```ts
strict-side branchVariant polarity
  aligns with
pointerFlavor === "candidate"
```

にかなり近い。

つまり current frontier では、
`pointerFlavor="candidate"`
は generic candidate class ではなく、
**strict-leaning candidate provenance reopening**
として持つのが safest である。

## implication for step 6

この整理を採ると、
step 6 の provisional API は shape をいじらずに semantics だけを強められる。

- `branchVariant?: 0 | 1`
  は据え置き
- `pointerFlavor`
  も `"shared" | "candidate"` のまま
- ただし docs / debug では `"candidate"` を strict-side carry として読む

で十分だからである。

つまり next analysis は、
`pointerFlavor="candidate"`
を generic PTR class としてではなく、
**strict-side aligned provenance class**
として sharpen するほうが安全である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `accepted=true` と `accepted=false` の両側で、この strict-side alignment が同じ向きで保たれるか
2. `pointerFlavor="candidate"` の strict-side reopening が final `target` 差分へどこまで素直に流れるか
3. `pointerFlavor="shared"` 側が fast/shortcut 側の default reopening class とどこまで対になるか

ここが取れれば、first-line と second-line の接続はかなり recovered semantics に近づく。
