# SaGa2 bulk copy/fill helper report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c2f6_state_gap_report.md`

## 目的

- `006D / 0080 / 0089` の契約を整理する
- `C2F6` producer 探索を point write から block-level 探索へ切り替える根拠を残す

## 結論

今回の整理で、bank0 の低位 helper 群はかなり素直に次のように読める。

1. `006D` は **`A` byte で `HL` から `B` byte を fill** する helper  
2. `0080` は **`HL -> DE` へ `B` byte copy** する helper  
3. `0089` は **`HL -> DE` へ `BC` byte copy** する helper  

したがって `C2F6` の producer が見つからない現状では、
今後は direct `LD (C2F6),A` を探すより
**これらの bulk helper を通じて `C2E0-C2FF` をまとめて埋める caller**
を探すほうが筋がよい。

## 1. `006D`

実体:

```text
006D: XOR A
006E: LDI (HL),A
006F: DEC B
0070: JR NZ,$006E
0072: RET
```

今回の caller では `A` を事前に積んでから使うパターンも見えていたが、
実コード上は `XOR A` 始まりなので、
少なくとも entry `006D` は **zero-fill helper** として読むのが自然。

ただし実際の caller 文脈では `CD 6D 00` の前に `A=$FF` が置かれる例もあり、
周辺 wrapper 経由で fill byte を変える系統が別にある可能性は残る。

安全には:

- `006D` 本体: zero-fill
- 周辺 wrapper を通すと generic fill として見える箇所がある

と分けて持つのがよい。

## 2. `0080`

実体:

```text
0080: PUSH AF
0081: LDI A,(HL)
0082: LD (DE),A
0083: INC DE
0084: DEC B
0085: JR NZ,$0081
0087: POP AF
0088: RET
```

これはかなりそのまま:

```ts
copyBytesB(srcHL, dstDE, countB)
```

である。

既報どおり `C7EE <-> C200+16*player` の 4 byte copy や、
`C760` 周辺 scratch の移送文脈とも整合する。

## 3. `0089`

実体:

```text
0089: PUSH AF
008A: LDI A,(HL)
008B: LD (DE),A
008C: INC DE
008D: DEC BC
008E: LD A,C
008F: OR B
0090: JR NZ,$008A
0092: POP AF
0093: RET
```

なので:

```ts
copyBytesBC(srcHL, dstDE, countBC)
```

と読むのが自然。

`67F8-6803` のように `HL=$C200`, `DE=$A600`, `BC=$0180` で使う caller は、
大きめの block copy とかなり整合する。

## 4. `C2F6` 探索への影響

今回改めて見た範囲では、
`C2F6` への

- direct load
- direct store
- `HL/DE/BC = C2F6` base

はほぼ見えなかった。

よって `C2F6` は
point update で組まれるのでなく、
どこかで larger block の一部として更新される可能性が高い。

つまり探索方針としては:

```text
find "who writes C2F6"
```

より

```text
find "who copies/fills a block that covers C2F6"
```

へ切り替えるのが自然。

## 5. 次の一手

1. `0080/0089` caller のうち `HL/DE` が `C2xx` 近辺に来る cluster を抽出する
2. `C2E0-C2FF` を含む larger WRAM block の初期化パスを探す
3. `67F8-6803` などの block copy caller を、selector/runtime state dump 文脈として読み直す
