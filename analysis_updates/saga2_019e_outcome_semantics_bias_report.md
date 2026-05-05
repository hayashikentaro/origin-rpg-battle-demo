# SaGa2 `019E` Outcome-Semantics Bias Report

## Summary
- `019E` の immediate target について、現時点では `resolved seed` の単純保持より **local outcome semantics を帯びた byte** とみるほうがやや自然、という重み付けを明示しておく価値がある。
- その理由は、`019E` が `611C` の **success-side commit frontier** に位置し、前段で token/source 解決が完了したあとに呼ばれるからである。
- つまり `019E` の仕事は「値を運ぶ」より **値に成功側の意味を与えて settle する** 側に寄る、というのが現在の safest bias である。

## 1. Why The Bias Exists

`611C` inner core は:

```asm
01B9 -> FF8C -> 5F07 -> C73D[index] -> 019E -> SCF ; RET
```

という順で進む。

ここで:

- `FF8C` は token
- `5F07` は remap
- `C73D[index]` は source

と、すでに各段の役割はかなり分かれている。

そのうえで `019E` が success を成立させる最後の境界にいる以上、
役割の重心は
**source byte の再保存** より
**success-side local outcome の確定**
にあるとみるほうが自然になる。

## 2. Identity Storage Is Still Possible

もちろん direct body 未確認なので、

```ts
stored = resolvedSeedByte
```

の identity 仮説はまだ残る。

ただしこの場合でも、
`019E` は単なるコピーではなく
**その値を「今回の成功側結果」として有効化する**
役割を負うことになる。

つまり identity 仮説でも、
意味論の重心は still success-side settle にある。

## 3. Safer Current Bias

以上から、いま最も安全な偏りは次のように置ける。

1. `stored byte` は success-side の意味を持つ  
2. その意味は local outcome 値である可能性がやや高い  
3. ただし outcome 値が raw seed と一致している可能性は残す  

## 4. Search Consequence

次に観測すべきものは:

- local outcome code のように読める 1byte state
- adopted/selected を示す short pair
- raw seed をそのまま outcome として扱っている痕跡

であって、
単に `A` がどこへ行くかの機械的追跡だけではない。

## Implication
- `019E` immediate target には outcome-semantics bias をかけてよい
- identity 仮説は残すが second line で十分
- 次の主戦場は `success-side local meaning` を持つ 1byte state の観測である
