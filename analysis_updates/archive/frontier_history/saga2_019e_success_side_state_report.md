# SaGa2 `019E` Success-Side State Report

## Summary
- `result marker` と `resolved local outcome byte` のどちらを採るにしても、`019E` の immediate target は **`611C` 成功を成立させる success-side short state** とみるのが最も自然である。
- つまり次に観測すべきものは、「どこへ書いたか」だけでなく、**その short state が success / adopted / selected outcome のどれを表すか** である。
- この整理により、`marker vs outcome` は対立仮説というより、**どちらも success-side settled state の下位バリエーション** として扱える。

## 1. Shared Semantic Core

`marker` 仮説でも `outcome` 仮説でも、
共通して言えることは次の 3 点。

1. `019E` は resolved seed byte を受け取る  
2. `CALL $019E` の直後に `SCF ; RET` する  
3. 後段 `6157` や `C2F6` reflection に渡る前の local state を確定する  

したがって immediate target の中心的意味は、
まず **success-side settled state**
として持つのが自然である。

## 2. Marker And Outcome As Variants

### marker 寄り
- commit succeeded
- candidate adopted
- valid resolved selection

### outcome 寄り
- selected local outcome id
- resolved local result code
- seed-derived adopted outcome

違いはあるが、
どちらも `611C` 成功側でのみ意味を持つ short state という点では同じである。

## 3. Why This Framing Helps

この framing を使うと、
次に探すべき観測対象がかなり単純になる。

探すべきもの:

- success marker byte
- adopted/outcome byte
- success + outcome の short pair

今は積極的に疑わなくてよいもの:

- raw seed cache
- large workspace mutation
- battle-side apply record

## 4. Updated Search Model

```ts
const token = resolveSelection()
const localIndex = remap(token)
const seedByte = C73D[localIndex]
const successState = commitResolvedSelection(seedByte) // 019E
if (!successState) fail()
applyLater(successState)
```

ここで `successState` は:

- boolean-only よりは意味が濃い
- full record よりは小さい
- marker か outcome か、あるいはその short pair

として持てる。

## Implication
- `019E` immediate target は success-side short state として見るのが最も安定する
- `marker vs outcome` は今後の意味論差分であって、探索の主線自体は共通でよい
- 次の主戦場は success marker / adopted outcome / short success pair の local hidden state である
