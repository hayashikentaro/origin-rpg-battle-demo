# Saga2 Special Candidate Origin Bias Report

## 要点

- current best reading では、`0E/0F` special-candidate family は **inventory 生値そのもの** より、`branch/path` 展開後の **action-path candidate layer** に寄せて読むほうが自然である
- もちろん storage 上は `D?12..` repeated entry family に乗っているため inventory 起点の可能性は残るが、battle-side meaning としては「装備そのもの」より **action resolve が消費する candidate entry** として扱うのが safest である
- したがって `combatDecision` も `inventory rule` より、**action-path candidate accept policy** として持つほうが TypeScript API に近い

## 1. どこに格納されているか

既報では `41BC-41C3` の `C/H` pair は
`D?43-46` compact action head そのものより、
**`D?12..` repeated candidate entry family**
に寄せて読むのが最も整合的だった。

これは storage family の観点では、
少なくとも `0E/0F` も

- `D?12..`
- repeated entry
- actor page local

の上にあることを意味する。

## 2. それでも inventory 生値と断定しない理由

`D?12..` は既報でも

- inventory 起点
- action candidate list
- slot/candidate staging

の間でまだ完全確定ではない。

しかも `437E` や `43FA-443A` では、
この帯は単に保持されるだけでなく

- mirror
- fold
- class/special gate

の対象になる。

この profile は「所持品をそのまま見る」より、
**戦闘実行時に評価される candidate entry**
と読むほうが battle-side には自然である。

## 3. `0E/0F` family の battle-side 位置

`0E/0F` family は:

- `BattleActionHead` 直下ではない
- `41C4-41D8` の local gate に現れる
- `41D9-41EC` の consume belt 進入を切り替える

という位置にある。

これは inventory raw item ID より、
**local path が開いたあとに解決される candidate subtype**
として持つほうが整合しやすい。

## 4. safest provisional reading

現時点では、origin を 2 層に分けるのがいちばん安全である。

```ts
type CandidateEntryOrigin =
  | { storage: "battlePageD12"; semantic: "action-path-candidate" }
  | { storage: "battlePageD12"; semantic: "inventory-derived-candidate" }
```

そして current best bias は後者より前者、
つまり
**inventory-derived ではあっても battle-side では action-path candidate として消費される**
という形である。

## implication for `combatDecision`

この整理を採ると、current `combatDecision` は

- inventory count/use gate

より、

- `special-candidate family`
- `blocked ordinal`
- `zero-fast-path privilege`
- `consumable nonzero class`

を持つ **action-path candidate accept policy**
として持つのが最も自然になる。

これは current TypeScript skeleton の

- `BattleActionHead`
- `localPath`
- optional `07/08` candidate RNG
- `combatDecision`

という cut とかなりよく噛み合う。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `D?12..` が inventory raw mirror か、その後の staged candidate list か
2. `0E/0F` family entry が `437E`/`43FA` でどの変換を受けるか
3. `combatDecision` がこの candidate family に対する accept policy として battle 本線でどう読まれるか

ここが取れれば、`combatDecision` は
**inventory-like storage on top of action-path semantics**
としてかなり安定する。
