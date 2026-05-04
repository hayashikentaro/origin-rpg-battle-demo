# SaGa2 `019B -> 05D9` indexing report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_6332_success_rebuild_report.md`
- 既存 `saga2_c21f_stride_helper_report.md`

## 目的

- `019B -> 05D9` の contract を切る
- `C206/C204/C20F` がどう index されるかを整理する

## 結論

`019B -> 05D9` は、
**mode に応じて stride を切り替える index-to-address helper**
とみるのが最も自然。

現時点で強く言えるのは次の 3 点。

1. `FF8B == 0` の通常経路では、`A` を `party_order ($C2A0)` 経由で正規化したうえで **`HL += 16 * index`** している  
2. `FF8B != 0` の別経路では、`A` をそのまま使って **`H += A`**、つまり **page-stride (`+0x100 * A`)** で進めている  
3. したがって `019B` は単一の `base + stride*A` ではなく、**party/local layout と page layout を切り替える address helper**

このため `6332` の `C206/C204/C20F` は、
少なくともこの文脈では
**`playerIndex -> base + 16*slot`**
の 16byte record 群として見るのが自然。

## 1. wrapper

```text
019B: JP $05D9
```

## 2. `05D9` の実体

```text
05D9: PUSH BC
05DA: LD B,A
05DB: LDH A,($FF8B)
05DD: AND A
05DE: JR Z,$05E5
05E0: LD A,B
05E1: ADD H
05E2: LD H,A
05E3: JR $05EE
05E5: LD A,B
05E6: CALL $05EF
05E9: CALL $004C
05EC: RST $00
05ED: POP BC
05EE: RET
```

ここから読めるのは 2 モード。

### mode A: `FF8B != 0`

```text
LD A,B
ADD H
LD H,A
```

なので:

```ts
HL = HL + (A << 8)
```

に相当する page-stride。

### mode B: `FF8B == 0`

```text
LD A,B
CALL $05EF
CALL $004C
RST $00
```

で、`004C` は既報どおり multiply-by-16 helper。

したがって通常経路では:

```ts
HL = HL + 16 * normalizeIndex(A)
```

と読むのが自然。

## 3. `05EF` の意味

`05EF-0607`:

```text
05EF: PUSH BC
05F0: CP $04
05F2: JR C,$05F8
05F4: LD A,$04
05F6: JR $0606
05F8: LD B,A
05F9: INC B
05FA: LD A,($C2A0)
05FD: RLCA
05FE: RLCA
05FF: RRCA
0600: RRCA
0601: DEC B
0602: JR NZ,$05FD
0604: AND $03
0606: POP BC
0607: RET
```

これは `C2A0` の 2bit field 群から
`A` 番目の値を取り出す helper と読むのがかなり自然。

つまり通常経路では、
入力 `A` をそのまま使うのでなく、
**party order / remap order**
で正規化してから `*16` している。

この読みは既報の `1918` / `1B99` 系
`party_order ($C2A0)` helper ともよく整合する。

## 4. `6332` への反映

`636C` worker では:

```text
636F: LD HL,$C206
6372: CALL $019B
...
63DB: LD HL,$C204
63DE: CALL $019B
...
641A: LD A,($C709)
641D: CALL $019B
```

なので、この文脈の `C206/C204/C20F` は
**16byte stride の player-local record base**
とみるのが自然。

特に `C20F` は既報の `611C` でも
`CALL $019B` とセットで使われていたため、
同じ indexing 規則で解釈できる。

## 5. `60E2` との関係

`60E2: LD HL,$C21F ; JP $019B`
も既報で見えている。

この場合、

- 通常経路では `C21F + 16*index`
- 別経路では `C21F + 0x100*index`

の両方が理論上ありうるが、
`C21F` 文脈は通常経路の 16byte block と読むのが最も整合する。

つまり `019B` は
**base を決める helperではなく、base に対する layout-aware index helper**
として共通利用されている。

## 6. 移植上の意味

TypeScript 側では、`019B` 相当を

```ts
function indexByLayout(base: number, index: number, mode: "party16" | "page256"): number
```

のように抽象化しておくと安全。

`6332` / `611C` など selector-runtime では
まず `party16` だけ実装し、
必要に応じて `page256` を battle/別 subsystem 用に分けるのがよい。

## 7. まだ未確定な点

- `FF8B` の正式な mode 意味
- `A >= 4 -> 4` clamp のドメイン
- `page256` 側 caller が battle 専用かどうか

## 次の一手

1. `643A` caller 文脈を追って `C785` への書き込み意味を切る
2. `0198 -> 0608` もあわせて切って `6332` の extra-player 条件を確定する
3. `6332` と `611C/6157` を横並びにして `C20F/C206/C204` の record 役割差を整理する
