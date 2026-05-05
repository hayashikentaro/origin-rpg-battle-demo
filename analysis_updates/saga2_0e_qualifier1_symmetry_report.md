# Saga2 `0E` Qualifier-1 Symmetry Report

## 要点

- current best reading では、`0E` でも `qualifier == 1` reject は **`0F` と同じ family rule の一部** とみるのが最も自然である
- 理由は単純で、`0E` は常に `41D5` に入り、`41D5-41D7` の `qualifier == 1` reject を必ず通るためである
- したがって safest provisional semantics は、`0E/0F` を同じ special-candidate family とし、その共通 rule に **`qualifier == 1` blocked ordinal** を置くことになる

## relevant flow

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

この flow をそのまま読むと:

- `0E` は必ず `41D5` に入る
- `0F` は `qualifier == 0` のときだけ `41D9` に直進できる
- `0F` でも `qualifier != 0` なら `41D5` に入る
- `41D5-41D7` では `qualifier == 1` だけ reject される

## 1. `0E` での意味

`0E` には `0F` のような fast-path がない。

したがって `0E` entry は qualifier を必ず評価され、
その中で

- `qualifier == 1` なら reject
- `qualifier == 0` または `2+` なら継続

という family 共通 rule に従うとみるのが最も自然である。

## 2. `0F` での意味

`0F` は

- `qualifier == 0` の場合だけ `41D9` に直進
- それ以外は `41D5` に落ちる

ので、`0E` と違うのは **entry condition** であって、
`41D5` に入った後の `qualifier == 1` reject 自体は同じ rule を共有している、
とみるのが安全である。

## 3. どこが対称で、どこが非対称か

### 対称

- `0E`
- `0F (qualifier != 0)`

はどちらも `41D5-41D7` を共有する。

したがって
**`qualifier == 1` blocked ordinal**
は family 共通 rule とみるのが最も整合する。

### 非対称

非対称なのは `0F` だけが持つ

- `qualifier == 0`
- fast-path to `41D9`

である。

つまり:

- `0E` = strict family variant
- `0F` = zero-fast-path family variant

という前回の整理は維持される。

## provisional semantics

現時点では次のように持つのがいちばん安全である。

```ts
type SpecialCandidateFamilyRule =
  | { qualifier: 1; meaning: "blocked-ordinal" }
  | { qualifier: 0; meaning: "family-allowed" }
  | { qualifier: number; meaning: "family-allowed-nonzero" } // 2+

type SpecialCandidateCode =
  | { code: 0x0e; variant: "strict" }
  | { code: 0x0f; variant: "zero-fast-path" }
```

ここで battle-side の実意味は未確定でも、

- blocked rule は family 共通
- fast-path は `0F` 特有

という 2 層構造にしておくのが safest である。

## implication for `combatDecision`

この整理を採ると、current `combatDecision` は

- `0E gate`
- `0F gate`

を別々の magic branch として持つより、

- **special-candidate family gate**
- その下に **blocked-ordinal rule**
- さらに `0F` だけの zero-fast-path

という階層で持つほうが battle semantics に近い。

これは TypeScript 側でも、
あとで `combatDecision.pendingMeaning` を増やすなら
`code-specific` より `family-rule + variant-rule` に寄せたほうが拡張しやすいことを示している。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `qualifier == 0` が `0E` と `0F` で後段同一意味かどうか
2. `qualifier >= 2` が truly 同一 class か、さらに ordinal を含むか
3. `0E/0F` family entry が inventory 由来か action-path 由来か

ここが取れれば、`combatDecision` は
**family-common blocked gate + `0F`-specific fast-path**
としてかなり実装寄りに固定できる。
