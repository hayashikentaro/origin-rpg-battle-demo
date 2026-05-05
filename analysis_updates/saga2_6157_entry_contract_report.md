# SaGa2 `6157` Entry Contract Report

## Summary
- `611C success -> 6157 entry` の handoff を移植観点で見ると、`6157` 入口でまず確定しているとみてよいのは、**current player (`C709`)** と **`611C` が返した success-side local state** の 2 本である。
- 逆に、`C200/C7EE/D400/D500` は `6157` の内部で初めて大きく触られるため、entry 契約の一部として先に仮定しないほうが安全である。
- したがって次の consumer 探索は、「`6157` が何を読むか」を page 全体で広く考えるより、**current player に結びついた local success state をどう受け取るか** に絞るのが最短になる。

## 1. Minimum Guaranteed Inputs At Entry

親ループ上の形:

```asm
60F0: LD ($C709),A
60F3: CALL $611C
60F6: JR NC,$610F
60F8: CALL $6157
```

この構造から、`6157` entry で安全に前提できるものは:

1. `C709` が current player を指している  
2. `611C` が carry success を返している  
3. その success を成立させた local success-side state が直前に確定している  

である。

## 2. Why Large State Should Not Be Assumed Yet

`6157` の本体ではすぐに:

- `C200 + 16*player`
- `C7EE`
- `D400/D500`

を触り始める。

ただしこれは、
**entry 時点の入力** というより
`6157` がこれから作る/更新する battle-side staging state
と読むほうが自然である。

つまり今ほしい契約は:

```ts
applyFromLocalSuccessState(player, localSuccessState)
```

であって、

```ts
applyFromAlreadyPreparedBattlePages(...)
```

ではない。

## 3. Practical Consequence

次に battle-side consumer を見るときは、
まず確認すべきなのは:

- `current player`
- `just-committed local success state`

が narrow bridge の入力として十分かどうかである。

ここが取れれば、
`6157` の大きな page side effect は
その後段の派生として整理できる。

## Implication
- `6157` entry 契約は current player + local success state とみるのが安全
- `C200/C7EE/D400/D500` は entry 入力より後段 staging 生成物として扱うのが自然
- 次の主戦場は `6157` 入口で受け取る local success state の形そのもの
