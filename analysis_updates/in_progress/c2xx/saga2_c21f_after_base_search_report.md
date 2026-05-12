# SaGa2 `C21F` After-Base Search Report

## Summary
- `5B95`, `60E2`, `10CC` を caller 文脈で見直しても、現時点で確実に取れているのは **`HL = C21F + 16*n` を作るところまで** で、その直後に `+1..+F` を読む強い証拠はまだ出ていない。
- したがって次の探索単位は `C21F` helper 本体ではなく、**“base を返したあとの caller 直後”** に固定するのが正しい。
- 現段階では `C21F` を rich 16byte struct と決めるより、`block-base/index table` として一段弱く持つほうが安全である。

## 1. `5B95` caller の時点で見えていること

既報 `5B70-5B91` では:

```asm
5B80: SWAP A
5B82: DEC A
5B83: PUSH HL
5B84: CALL $5B95
5B87: LD (HL),C
5B88: POP HL
```

ここで `5B95` の返り値 `HL` は
そのまま `LD (HL),C` にしか使われていない。

つまりこの path から高確度で言えるのは:

- block base を得る
- block `+0` に `sourceIndex C` を書く

までであり、`+1..+F` はまだ見えていない。

## 2. `60E2` caller の時点で見えていること

既報 `60C0-60E1` では:

```asm
60CE: SWAP A
60D0: DEC A
60D1: PUSH HL
60D2: CALL $60E2
60D5: LD (HL),C
60D6: POP HL
```

ここでも `60E2` の返り値 `HL` は
そのまま `LD (HL),C` にしか使われていない。

したがってこの path も、

- block base
- block `+0`

までしかまだ確定させていない。

## 3. `10CC` が教えてくれること / 教えてくれないこと

`10CC` には:

```asm
10CC: CALL $004C
10CF: LD HL,$C21F
10D2: RET
```

があるが、既報どおりこの帯全体は
high-range selector dispatcher として読むほうが自然である。

重要なのは、現時点の report 群では

- `10CC` が `C21F` block base を返す可能性

は見えていても、

- その base に対して `INC HL`, `LDI A,(HL)`, `ADD HL,offset`
  のように `+1..+F` を読む path

まではまだ強く取れていないこと。

つまり `10CC` は `C21F` block 全体の reader というより、
**selector dispatch 層で block-base/reference を正規化する helper**
に留まっている可能性が高い。

## 4. What A Real `+1..+F` Consumer Would Look Like

次に探すべき evidence は、たとえば次のような形。

```asm
CALL $5B95 / CALL $60E2 / CALL $10CC
INC HL
LD A,(HL)
```

あるいは:

```asm
CALL ...
LD DE,$0003
ADD HL,DE
LD A,(HL)
```

のように、
**block base 取得後に offset を進めて読む path**
である。

これが出るまでは、`C21F` を rich struct と言い切らないほうが安全。

## 5. Safe Current Model

```ts
type C21fBlock = {
  sourceIndex0: number | null
  rest: Uint8Array // unknown
}

function getC21fBlockBase(index: number): number
```

という分離で十分。

## 6. Updated Search Plan
1. `5B95/60E2/10CC` caller の直後を重点的に洗う  
2. `HL` が `C21F + 16*n` になったあと `INC/LDI/offset add` が続く path を優先する  
3. それが見つからなければ、`C21F` は rich struct より block-head/index table である可能性を上げる

## Implication
- `C7E0` は shared sparse remap/list としてかなり進んでいる
- `C21F` はまだ richer state の証拠が足りない
- したがって `60C0` shared builder を一段強めるには、今後の決め手は `C21F` after-base read path になる
