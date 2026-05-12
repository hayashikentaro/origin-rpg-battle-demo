# SaGa2 `6157` Player-Scoped Handoff Report

## Summary
- `6157` entry 契約をもう一段絞ると、ここで受け取られる `local success state` は **global/shared state ではなく current player に束縛された player-scoped handoff** とみるのが最も自然である。
- 理由は、`60F0` で `C709` を設定し、その player ごとに `611C` と `6157` を直列実行しているため、成功結果もまずはその player に属する局所 state として受け渡されるほうが整合するからである。
- したがって次の consumer 探索は、shared page 全体より **`player -> local success state -> battle apply`** の 1 player 分の narrow bridge に集中するのが最短になる。

## 1. Why Player Scope Is The Safe Default

親ループの骨格:

```asm
60EE: LD A,$01
60F0: LD ($C709),A
60F3: CALL $611C
60F6: JR NC,$610F
60F8: CALL $6157
60FD: LD A,($C709)
6100: INC A
```

この構造では、

1. `C709` に current player を入れる  
2. その player について `611C` を回す  
3. success のときだけ `6157` へ渡す  

となっている。

したがって `6157` entry で意味を持つ success-side state も、
まずは **その current player に属する局所結果**
とみるのが自然である。

## 2. Why Shared/Global Is A Worse First Guess

もちろん後段で shared state に反映される可能性はある。

ただし entry 契約の最小形としては、

- global shared page
- whole battle page family
- subsystem-wide optional state

を最初から前提にすると広すぎる。

いま移植に必要なのは、
`6157` が battle 側へ受け渡す入力の最小単位であり、
それは current player に束縛された
**player-scoped local success handoff**
で十分説明できる。

## 3. Best Current High-Level Contract

```ts
type PlayerScopedSuccessHandoff = {
  playerIndex: number
  localSuccessState: unknown
}
```

ここで `localSuccessState` の詳細はまだ未確定だが、
少なくとも:

- global ではない
- page-wide battle staging そのものでもない
- `611C` の success でだけ生成される

という条件はかなり強い。

## 4. Search Consequence

次に battle-side consumer を見るときは、
次の観測順が自然になる。

1. `C709` で束縛された 1 player 分の入力
2. その player に属する local success-side state
3. `6157` がそれをどの battle-side staging へ落とすか

要するに、
`6157` の入力は **player-scoped handoff** として扱うのが安全。

## Implication
- `6157` entry は shared/global より player-scoped handoff とみるのが自然
- 次の主戦場は 1 player 分の local success state を battle 側へ渡す narrow bridge
- これで consumer 探索をさらに狭い単位で進められる
