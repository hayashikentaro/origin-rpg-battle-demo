# SaGa2 `FF8C` Token-Domain Comparison Report

## Summary
- `611C`, `6621`, `62BE` を並べると、`FF8C` は **final local index ではなく、caller ごとに追加 resolve を必要とする current-selection token** とみるのが最も自然。
- 3 系統すべてで `01B9 -> FF8C` の直後に `CP $FF` による無効判定が入り、その後で `5F07` か追加 gate が走るため、`FF8C` は「有効/無効の一次判定ができる token」であって、「そのまま最終 index として使える値」ではない。
- したがって `019E` に渡る前に確定しているのは `FF8C` そのものではなく、**`5F07` を通過した後の local index と、それで引いた `C73D[index]` の seed byte** である。

## 1. Shared Skeleton

3 系統の共通骨格は次のとおり。

```text
dispatch/context setup
CALL $01B9
LDH A,($FF8C)
CP $FF
... optional extra gate ...
CALL $5F07
... caller-specific use ...
```

ここから少なくとも次は安全に言える。

1. `01B9` は `FF8C` を materialize する  
2. `FF8C == $FF` は共通の invalid / no-selection sentinel  
3. `FF8C != $FF` でも、そのまま最終採用とは限らない  
4. 後段で `5F07` か同等の gate を通して local domain へ落とす必要がある  

## 2. Caller A: `611C`

```text
6142: CALL $01B9
6145: LDH A,($FF8C)
6147: CP $FF
6149: RET Z
614A: CALL $5F07
614D: LD HL,$C73D
6150: RST $00
6151: LD A,(HL)
6152: CALL $019E
```

ここでの意味は最も明瞭で、
`FF8C` は最終 seed index ではなく、
**`5F07` を通って初めて `C73D` を引ける local index になる token**
である。

つまり `019E` へ渡る時点で確定しているのは `FF8C` ではなく、
`C73D[ remap(FF8C) ]` の 1byte seed である。

## 3. Caller B: `6621`

```text
6621: CALL $01B9
6624: LDH A,($FF8C)
6626: CP $FF
6628: JP Z,$65A3
662B: CALL $5F07
662E: AND A
662F: JP NZ,$65A3
```

ここでは `5F07` 後に `A == 0` を要求している。

したがってこの caller では:

- `FF8C != $FF` で token 有効
- さらに `5F07(FF8C) == 0` で採用

という 2 段 gate になっている。

これは `FF8C` が final index なら不要な構造なので、
やはり token とみるほうが自然。

## 4. Caller C: `62BE`

```text
62BE: CALL $01B9
62C3: LDH A,($FF8C)
62C5: CP $FF
62C7: JR Z,$62F9
62C9: AND A
62CA: CALL NZ,$5F07
62CD: JR NZ,$62F9
```

ここでは `FF8C == 0` を fast-path として扱い、
非 0 のときだけ `5F07` を追加で呼んでいる。

この差分は domain 条件の違いを示すが、
本質は同じである。

- `FF8C == $FF`: invalid
- `FF8C == 0`: caller-local fast-path
- それ以外: `5F07` を通した resolve が必要

つまり `FF8C` は、
caller に応じて「0 がすでに特別扱いされる token 空間」を持つ。

## 5. Safe Model

現時点での安全な抽象モデルは次の程度。

```ts
type CurrentSelectionToken = number | 0xff

function resolveCurrentSelectionToken(): CurrentSelectionToken
function remapTokenToLocalIndex(token: number): number // 5F07
```

ここで:

- `0xff` は invalid / no selection
- `0` は一部 caller では fast-path を持つ valid token
- それ以外の token は caller 条件に応じて `5F07` resolve が必要

## 6. Meaning For `019E`

この比較で重要なのは、
`019E` の直前で確定している値空間を一段きれいに切れること。

`019E` の入力 `A` は:

- `FF8C` token ではない
- `5F07` 後の local index でもない
- **`C73D[localIndex]` から読んだ resolved seed byte**

したがって `019E` を追うときは、
「selection token の意味」をこれ以上掘るより、
**local index 以降の commit 先**
に焦点を置くのが効率的である。

## Implication
- `FF8C` は current-selection token storage として固定してよい
- final local index は `5F07` 後に初めて得られる
- `019E` が受け取るのは token ではなく resolved seed byte
- 次の主戦場は引き続き `019E` writeback destination でよい
