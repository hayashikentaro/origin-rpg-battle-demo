# SaGa2 `019E` Small-Family Hypothesis Report

## Summary
- `019E` の immediate target は「単一 byte の result marker」である可能性が高い一方、現時点では **small local family** として複数 byte をまたぐ settled-state を持つ可能性もまだ十分残っている。
- 重要なのは、これが大きな record や visible/apply 構造ではなく、**inner core の post-resolve / pre-apply window に属する小さな hidden family** だという点である。
- したがって次の探索では、単発 byte write だけを探すより、**result marker / outcome byte / short shadow tuple** の 3 通りを同じ優先度で持つのが安全である。

## 1. Why A Single Byte Is Plausible

`019E` が受け取るのは 1 byte の resolved seed である。

```asm
6151: LD A,(HL)
6152: CALL $019E
6155: SCF
6156: RET
```

この形だけ見れば、
最初の settled state が
1 byte marker である可能性は高い。

たとえば:

- selected local outcome id
- resolved seed marker
- adopted local candidate byte

のような形である。

## 2. Why A Small Family Still Fits Better Than A Big Record

ただし `019E` は `611C` 成功境界にいるため、
1 byte を置くだけでなく、

- result byte
- validity/adopted flag
- short local shadow tuple

のような **ごく小さい family**
を確定している可能性もある。

それでも大きな record ではなく small family と見るべき理由は:

- `C20F` 16byte workspace ほど大きい証拠がない
- `6157` の apply/staging record ほど後段でもない
- `C73D` / `FF8C` のような前段 family でもない

からである。

## 3. Best Current Shape

現時点の安全な幅は次の 3 段階。

1. single result byte  
2. result byte + status/flag  
3. short shadow tuple (very small local family)

逆に、今は優先度を下げてよいもの:

- full `C20F` record write
- visible `C200` record write
- `D400/D500` apply-state write

## 4. Search Consequence

次に local hidden state を観測するときは、
候補をこう持つのが安全。

```ts
type ImmediateLocalCommit =
  | { kind: "byte"; value: number }
  | { kind: "marker"; value: number; adopted: boolean }
  | { kind: "tuple"; values: number[] } // very small family
```

要するに探すべきものは
**big struct ではなく small settled-state family**
である。

## Implication
- `019E` immediate target は single byte か small family のどちらかで持つのが自然
- どちらにせよ inner core の short hidden state として扱うべきである
- 次の主戦場は result marker / outcome byte / short shadow tuple の観測である
