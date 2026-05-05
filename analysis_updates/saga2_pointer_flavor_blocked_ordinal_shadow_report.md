# Saga2 PointerFlavor Blocked-Ordinal Shadow Report

## 要点

- current best reading では、`pointerFlavor="candidate"` の second-line reopening に qualifier `1` blocked ordinal が **主軸としてではなく、弱い shadow / modifier として残る** とみるのが最も自然である
- 主軸は引き続き **`0E/0F` special-candidate family difference** にあり、qualifier `1` は `pointerFlavor="candidate"` の exact semantics を少し陰らせる **secondary blocked-ordinal shadow** として扱うのが safest である
- したがって second-line の `"candidate"` provenance class は pure code carry でも pure qualifier carry でもなく、**code-led carry with blocked-ordinal shadow** とみるのが current best reading である

## 1. Why Blocked Ordinal Does Not Become The Primary Axis In Second-Line

既報では
`qualifier == 1`
は family 共通の
**blocked ordinal**
と読むのが current best である。

しかし既報 `branchVariant primary axis`
および `pointerFlavor code-led carry`
では、
first-line と second-line の主軸はともに
**`0E/0F` family difference**
にあると整理している。

この 2 本を合わせると、
qualifier `1`
を second-line reopening の主軸まで引き上げるより、
**code-led carry の上に薄く残る modifier**
として扱うほうが自然になる。

## 2. Why A Shadow Reading Fits Better Than A Full Carry

もし qualifier `1`
が second-line でも primary axis なら、
`pointerFlavor="candidate"`
自体が blocked/non-blocked の強い再分岐を持つはずだが、
current best reading では second-line の中心は

- candidate provenance reopening
- pointer/materialization class difference

にあり、
blocked ordinal 自体が second-line field を新しく要求するほど前景化していない。

このため safest bias は、
qualifier `1`
は

- first-line では local gate / reject source
- second-line では candidate provenance に薄く残る shadow

として持つことである。

## 3. Relation To `branchVariant`

既報では `branchVariant`
は
**`0E/0F` family difference を主軸**
に qualifier class を secondary modifier として畳んだ値
と読んでいる。

この前提を延長すると、
second-line の `pointerFlavor="candidate"`
も

- primary = `0E/0F` family difference
- secondary = qualifier shadow

という layered reading をとるのが最も自然になる。

つまり:

- `branchVariant`
  = first-line compressed split with secondary qualifier contribution
- `pointerFlavor="candidate"`
  = second-line code-led carry with blocked-ordinal shadow

という対応になる。

## 4. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
pointerFlavor === "candidate"
```

は:

```ts
candidate pointer provenance class
// primary axis: 0E/0F family difference
// secondary shadow: qualifier==1 blocked ordinal
```

にかなり近い。

つまり `"candidate"`
の exact semantics は pure code carry でも pure qualifier carry でもなく、
**code-led provenance carry with blocked-ordinal shadow**
として持つのが current best である。

## 5. Why This Matters For Step 6

この整理を採ると、
step 6 の provisional API は field を増やさずに意味だけを強められる。

- `pointerFlavor` 自体は `"shared" | "candidate"` の 2 値のまま
- blocked ordinal は新しい field に出さず
- semantics layer で `"candidate"` 側の weak shadow として読む

ことで、
current code shape と battle-side evidence を両立できるからである。

つまり next analysis は、
second-line に `blocked` 専用 field を足す方向ではなく、
`pointerFlavor="candidate"` の exact semantics を
**code-led + blocked-shadow**
としてさらに sharpen すればよい。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. qualifier `1` shadow が `pointerFlavor` より downstream の `target` 差分にどこまで影響するか
2. qualifier `1` shadow が `branchVariant 0/1` のどちらにより強く片寄るか
3. `0E` と `0F` で second-line reopening 時の blocked shadow の濃さに差があるか

ここが取れれば、`pointerFlavor="candidate"` の exact semantics はかなり recovered semantics に近づく。
