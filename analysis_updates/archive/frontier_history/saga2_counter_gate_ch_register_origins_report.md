# Saga2 Counter Gate C/H Register Origins Report

## 要点

- `41C4-41D8` の gate を読むうえで重要なのは、`C` と `H` がこの場で新しく計算された値ではなく、直前 `41BC-41C3` で **actor page から 2 byte 連続で読み出した pair** だという点である
- したがって current best reading では
  - `C` = low-byte 側の local entry / candidate code
  - `H` = その隣接 byte にある qualifier / owner / high-byte 風値
  と置くのが最も自然である
- まだ完全確定ではないが、少なくとも `C` と `H` は independent random state ではなく、**同じ actor-local 2byte record 由来** と見てよい

## direct setup

`actors_loop` 既報から、`41C4` に入る直前の relevant flow は次のとおり。

```text
41B9: INC E
41BA: INC E
41BB: INC E
41BC: LD A,(DE)
41BD: LD (HL+),A
41BE: LD C,A
41BF: INC E
41C0: LD A,(DE)
41C1: LD (HL),A
41C2: LD H,A
41C3: LD L,C
41C4: LD A,C
```

## 何が言えるか

この setup から少なくとも次が言える。

1. `C` は `41BC` で読んだ byte のコピー  
2. `H` は `41C0` で読んだ隣接 byte のコピー  
3. `HL` は `H = second byte`, `L = first byte` として組み立てられている  

つまり `41C4-41D8` が見ている `C` と `H` は、抽象的な flag register ではなく
**actor-local 2byte pair をそのまま register 化したもの**
とみるのが最も自然である。

## gate への効き方

この前提で gate 部を読み直すと、意味はかなり整理しやすい。

```text
41C4: LD A,C
41C5: CP $FF
41C7: JR Z,$41F1
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

これをいまの best reading で言い換えると、

- `C` が primary candidate/type code
- `H` がその code に付随する qualifier / count / owner / high-side byte

という 2 段判定に見える。

特に

- `C == FF` なら無効 / end / empty
- `C == 0E / 0F` なら special handling
- `H == 0` や `H == 1` 相当で further gate

と読むと、後段 `41D9-41EC` に進む条件としてかなり自然になる。

## `HL` の意味について

`41C2-41C3` で `HL` を `H:first adjacent byte, L:first byte` として組んでいることから、これは単なる pair 比較のためではなく、

- 後段で pointer 的にも使える 16bit pair
- ただし `41C4-41D8` ではまず `C/H` として code/qualifier 判定に使う

という二重用途の可能性が高い。

したがって current best reading では、

- `C/H` は「pointer の low/high」だけでは足りない
- かといって純粋な abstract state code でもない
- **code + qualifier を持つ actor-local 2byte record**

として扱うのが最も安全である。

## implication for `combatDecision`

この整理を入れると、`combatDecision` の source はさらに明確になる。

- `41E7-41E9` 単独の counter sentinel

より前に、

- `C` primary code
- `H` secondary qualifier

の組で local path がかなり分岐している。

したがって next frontier は

1. `C` の `FF / 0E / 0F` の意味
2. `H` の `0 / 1+` の意味
3. この 2byte record の生成元に RNG が入るか

へさらに絞ってよい。

## まとめ

- `C` と `H` は `41BC-41C3` で actor page から読まれた隣接 2byte pair
- current best reading では `C = primary code`, `H = secondary qualifier`
- `combatDecision` の真の source は、この pair を使う pre-gate 群にある可能性が高い
