# SaGa2 `019E` Seed-vs-Outcome Mapping Report

## Summary
- `019E` の immediate target を `outcome byte` first line で持つなら、次に見るべき差は **resolved seed をそのまま保持するのか、local outcome value へ写像するのか** である。
- 現時点では、`019E` が `611C` 成功境界の commit frontier にいることを考えると、**単なる pass-through byte** より **local outcome semantics を帯びた byte** へ落とす読みのほうがやや自然である。
- ただし direct write をまだ見ていない以上、`seed == stored value` の identity 仮説も切らずに残すのが安全である。

## 1. Two Candidate Shapes

### A. Identity storage

```ts
stored = resolvedSeedByte
```

この読みでは `019E` は、
resolved seed を local settled-state にそのまま残す。

### B. Outcome mapping

```ts
stored = mapResolvedSeedToOutcome(resolvedSeedByte)
```

この読みでは `019E` は、
resolved seed を local meaning を持つ outcome/value へ落として保持する。

## 2. Why Outcome Mapping Is Slightly More Natural

今ある evidence では、`019E` は:

- `FF8C` token 解決の後ろにある
- `C73D[index]` source のさらに後ろにある
- `CALL $019E` の直後に `SCF ; RET` で success を成立させる

つまり raw 値を運ぶだけの helper より、
**gate 成功に必要な local result を確定する helper**
と読むほうが自然である。

そのため、保存される byte も
単なる seed 値そのものより
**seed から導かれた local outcome semantics**
を持つ可能性がやや高い。

## 3. Why Identity Storage Still Remains

ただし direct body / writeback 先が未確認なので、
次の可能性は依然残る。

- seed byte 自体がすでに十分意味を持つ
- `019E` は mapping せず settle だけ行う
- 後段がその byte を outcome として解釈する

したがって今の段階で
「必ず mapping する」と断言するのは早い。

## 4. Safe Current Ranking

現時点の安全な優先順位:

1. mapped outcome byte
2. identity-stored resolved seed byte
3. marker + byte の short pair
4. marker only

## Implication
- 次の主戦場は `resolved seed == stored byte` かどうかではなく、`stored byte` が local outcome semantics を帯びるかどうか
- ただし identity 仮説も保留しておくのが安全
