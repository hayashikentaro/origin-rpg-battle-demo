# SaGa2 `outcomeLikeByte` First-Consumer Semantics Report

## Summary
- `6157` を player-scoped outcome relay とみるなら、次に必要なのは **`outcomeLikeByte` が battle 側で最初にどの意味として読まれるか** の整理である。
- 現時点では、最初の consumer 意味は page-wide record ではなく、**action resolve を進めるための 1player 分の局所 outcome / adopted result / selected branch code** のいずれかに寄るとみるのが自然である。
- したがって次の探索では、「どのページに落ちるか」より、**branch/input meaning として何を表す 1byte か** を first line に置くのが安全である。

## 1. What The First Consumer Probably Does Not Need

`6157` entry 直後の narrow bridge で本当に必要なのは、
まだ page-wide staging の全貌ではない。

最初の consumer が直ちに必要としないもの:

- `D400/D500` 全 field
- `C200` visible record 全体
- `C7EE` scratch header の完全意味

これらは relay 後に構築される battle-side staging として後段へ回せる。

## 2. What The First Consumer Most Likely Needs

`outcomeLikeByte` の最初の consumer が必要としそうなのは、
次のどれかにかなり絞れる。

1. adopted local outcome  
   「今回採用された結果」
2. selected branch code  
   「この player が次に入る action path」
3. success-qualified local result  
   「成功時のみ有効な 1byte decision/result」

共通点はどれも、
**1player 分の action resolve を前へ進めるための branch/input meaning**
だということ。

## 3. Why This Is Better Than Thinking In Storage First

いまの段階で storage だけを追うと、

- `C200` か
- `C7EE` か
- `D400/D500` か

のように wide page 側へ意識が散りやすい。

しかし移植で本当に欲しいのは:

```ts
battle.applyResolvedOutcome(playerIndex, outcomeLikeByte)
```

の `outcomeLikeByte` が
**何の意味を持つ入力なのか**
である。

この意味が分かれば、storage 完全確定前でも
中間 API を立てやすい。

## 4. Safe Current Bias

現時点の安全な重み付けは:

1. branch/input meaning を持つ outcome byte
2. adopted result を示す local result byte
3. success marker を兼ねた short code

である。

## Implication
- `outcomeLikeByte` の first consumer は branch/input meaning を読む可能性が高い
- 次の主戦場は storage 位置より、その 1byte の battle-side 意味
- これが取れると `battle.resolveAction(...)` の入力意味がかなり具体化する
