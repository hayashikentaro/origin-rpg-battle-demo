# SaGa2 `019E` Identity-As-Degenerate-Outcome Report

## Summary
- `resolved seed` の identity storage 仮説は、`outcome semantics` 仮説の対立物というより、**outcome mapping が恒等写像だった場合の特例** としてまとめて持てる。
- つまり今後の観測軸は `identity vs outcome` の二項対立より、**`019E` が success-side local meaning を持つ 1byte state を確定する** という一本線で十分になる。
- この整理により、次の探索では「保存された byte が raw に見えるか」より、**それが success-side local outcome として使われるか** を見ればよくなる。

## 1. Unified Reading

高位では次の 2 つは同じ枠に入れられる。

```ts
stored = resolvedSeedByte
```

```ts
stored = mapResolvedSeedToOutcome(resolvedSeedByte)
```

違いは mapping が:

- 恒等写像か
- 非自明な写像か

だけであり、どちらも
**success-side local outcome byte**
として扱える。

## 2. Why This Is Better

`019E` は:

- `FF8C` token の後ろ
- `5F07` remap の後ろ
- `C73D[index]` source の後ろ
- `SCF ; RET` 成功境界の直前

にある。

この位置関係から、
本質は「どの写像か」より
**成功側の local 意味値を settle すること**
にある。

## 3. Updated Search Question

したがって次の観測で問うべきことは:

1. 保存された byte は success-side local meaning を持つか  
2. その meaning は adopted/selected outcome に読めるか  
3. raw seed と一致しているのは恒等写像だからか  

であって、
「identity か mapping か」を先に二者択一する必要は薄い。

## Implication
- identity 仮説は outcome semantics 仮説の特例として吸収できる
- 次の主戦場は引き続き `success-side local meaning` を持つ 1byte state の観測でよい
