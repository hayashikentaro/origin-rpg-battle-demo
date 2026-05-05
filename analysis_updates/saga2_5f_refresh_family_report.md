# SaGa2 `5F2B/5F44/5F0E` refresh-family report

## 1. 目的

- `5E0D` 後段の `5F2B/5F44/5F0E` を refresh helper family として整理する
- mode-transition helper 群の後半責務を切り分ける
- `C2F6` producer 探索からどこまで除外できるかを確認する

## 2. 結論

現時点で direct body すべてを取り切れているわけではないが、
caller 文脈と既報 `RST $10` 整理を合わせると、
`5F2B/5F44/5F0E` はかなり自然に
**mode-transition 後段の visible refresh family**
としてまとめられる。

今回確度高く言えるのは次の 3 点。

1. `5F0E` は既報どおり **palette/VRAM 更新前の同期点** 候補  
2. `5F2B/5F44/5F0E` は `5E0D` の `RST $10` / `RST $18` 直後に並び、reset 済み visible state を画面側へ反映する後段 refresh とみるのが自然  
3. この family についても現時点で **`C2F6` を direct に埋める clear/copy/write は見えていない**

したがって `5E0D` は:

- 前半で local reset
- 中盤で frame sync と OAM flush
- 後半で `5F` refresh family

という visible transition 3 段として読むのが安全であり、
`C2F6` backing state はこの family より前段の hidden/shared init にある可能性が維持される。

## 3. `5E0D` の後半構造

既報 flow:

```text
5E0D: XOR A
5E0E: LDH ($FF96),A
5E10: CALL $5E31
5E13: RST $10
5E14: LD A,$CC
5E16: RST $18
5E17: CALL $5F2B
5E1A: CALL $5F44
5E1D: CALL $5F0E
5E20: LD A,$03
5E22: LDH ($FF96),A
5E24: RET
```

ここで前半 `5E31` が local reset、
`RST $10` が frame sync、
`RST $18` が OAM flush と読める以上、
後続の `5F2B/5F44/5F0E` を
別系統の hidden-state builder とみるより、
**表示・反映・更新の finishing pass**
とみるほうが整合する。

## 4. `5F0E` の位置づけ

既報 `saga2_rst10_report.md` では、
`5F0E` は代表 callsite として
**palette/VRAM 更新前の同期**
に属すると整理していた。

さらに battle 側でも:

```text
613E: CALL $5F0E
```

が見えており、
これは `60E8-611B` の battle prepass orchestration 内にある。

つまり `5F0E` は:

- selector-only の hidden helper ではなく
- subsystem をまたいで使われる
- **visible update 直前の sync/refresh primitive**

である可能性が高い。

## 5. `5F2B` / `5F44` の位置づけ

`5F2B` と `5F44` は現時点で body 未確定だが、
少なくとも `5E0D` では:

```text
RST $10
RST $18
CALL $5F2B
CALL $5F44
CALL $5F0E
```

の順で固定して呼ばれている。

この並びから言える安全なことは:

1. `5F2B/5F44` は `RST $10` / `RST $18` の前段条件作りではない  
2. `5F0E` と同じ visible refresh cluster に置かれている  
3. `5E31/5E40` の clear 済み visible scratch を前提にした後処理である可能性が高い

したがって現段階では:

```text
5F2B = refresh step A
5F44 = refresh step B
5F0E = sync/finalize step
```

程度の contract で持つのが安全である。

## 6. 高位擬似コード

現時点での安全な高位擬似コードは次の程度。

```ts
function runModeTransition(): void {
  FF96 = 0
  resetSharedUiSelectorState()
  waitNextFrame()   // RST $10
  flushOam()        // RST $18
  refreshStepA()    // 5F2B
  refreshStepB()    // 5F44
  finalizeVisibleRefresh() // 5F0E
  FF96 = 3
}
```

ここでは hidden optional-entry backing state の構築はまだ見えていない。

## 7. `C2F6` 探索への意味

この整理でさらに強くなったのは次の点である。

1. `5E0D` の前半 `5E31/5E40` は visible reset  
2. 中盤 `RST $10` / `RST $18` は frame/OAM sync  
3. 後半 `5F2B/5F44/5F0E` は visible refresh

つまり `5E0D` 全体がかなり一貫して
**画面・UI・selector 可視状態の transition routine**
として閉じており、
この高位入口自体を `C2F6` producer 候補として見る必要はさらに薄くなった。

## 8. 次の一手

1. `RST $08` caller family を切って `01B6` 後段 dispatch 契約を詰める  
2. `5F2B/5F44` の body を直接取って refresh step A/B の差を確定する  
3. `C2F6` producer 探索は、mode-transition visible family よりさらに前段の hidden/shared init 側へ寄せる
