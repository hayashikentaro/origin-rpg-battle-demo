# Saga2 Special Code `FF / 0E / 0F` Report

## 要点

- current best reading では、`D?12..` entry の low byte に現れる `FF / 0E / 0F` は同列の sentinel ではない
- もっとも自然な読み分けは次のとおり
  - `FF` = empty / end / invalid candidate
  - `0E` = qualifier-aware special candidate subtype A
  - `0F` = qualifier-aware special candidate subtype B
- とくに `0E / 0F` は `41C4-41D8` で **special handling を受けたうえで** 後段 `41D9-41EC` へ進入しうるため、単なる empty sentinel とみなすのは不自然である

## 根拠 1: `FF` だけ即時離脱する

`41C4-41D8` では最初に:

```text
41C4: LD A,C
41C5: CP $FF
41C7: JR Z,$41F1
```

となっている。

ここで `FF` は他条件を見ずに直ちに離脱するため、
これはかなり自然に

- empty
- invalid
- end-of-candidate

系 sentinel と読める。

## 根拠 2: `0E / 0F` は special path を持つ

同じ block では:

```text
41C9: CP $0E
41CB: JR Z,$41D5
41CD: CP $0F
41CF: JR NZ,$41D9
41D1: LD A,H
41D2: OR A
41D3: JR Z,$41D9
41D5: LD A,H
41D6: DEC A
41D7: JR Z,$41F1
```

となっている。

ここで重要なのは、

- `0E` は必ず `41D5` special path へ入る
- `0F` は `H == 0` なら `41D9` へ進みうる
- `0F` でも `H == 1` 相当なら `41F1` 側へ落ちうる

という点である。

つまり `0E / 0F` は

- ただの空値

ではなく、

- **qualifier 付き special code**

として扱われているとみるのが自然である。

## 根拠 3: 後段で table index 化される

`41D9-41E5` では primary code から:

```text
41E0: LD E,A
41E1: ADD A,A
41E2: ADD A,E
41E3: ADD A,$14
```

を作っている。

これは `code * 3 + 0x14` に相当するため、
`0E / 0F` も少なくとも一部経路では

- local 3byte record table の index
- あるいはその近傍へ進む candidate subtype

として扱われている可能性が高い。

empty sentinel であれば、ここまで special handling を入れる必要が薄い。

## current best reading

現時点の safest provisional reading はこう置ける。

```ts
type CandidateCode =
  | { kind: "empty"; code: 0xff }
  | { kind: "special"; code: 0x0e | 0x0f; qualifier: number }
  | { kind: "normal"; code: number; qualifier: number }
```

もちろん `0E / 0F` の battle-side meaning 自体は未確定だが、
少なくとも

- `FF`
- `0E / 0F`

を同じ「special値」とまとめるより、
**`FF` と `0E/0F` を分ける**
ほうが evidence に合う。

## implication for `combatDecision`

この整理を採ると、current `combatDecision` は

- `empty sentinel gate`
- `special candidate gate`
- `normal candidate gate`

のうち、少なくとも後ろ 2 つに関わる unresolved hook とみるのが自然になる。

とくに `PTR` や candidate-selection path は、
`0E / 0F` のような special code を経由する local gate と相性がよい可能性がある。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `0E` と `0F` が別 subtype か、同じ family の variant か
2. `H == 0` と `H == 1+` がその subtype の所有者/残数/有効性のどれを切るか
3. `0E / 0F` entry に達するまでの path に raw/small-range RNG が流入しているか

ここが取れれば、`combatDecision` は
`special candidate gate`
としてさらに具体化できる。
