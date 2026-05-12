# SaGa2 battle state helpers report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_battle_runtime_entry_report.md`
- 既存 `reports/saga2_damage_candidate_functions_pass19.csv`
- 既存 `reports/saga2_item_usage_code_contexts_pass25.csv`

## 目的

- bank `0D:435A` と `0D:4361` の局所契約を切る
- battle runtime 入口から見える helper 群を RNG から分離する

## 結論

今回の再確認で、
`0D:435A` と `0D:4361` はどちらも
**battle state/controller 側の helper**
とみるのがかなり自然になった。

- `435A` は `HL` の同一 low offset を、`H` だけ進めながら `B` 回合計する小 helper 候補
- `4361` は `A` を index にして bank `0C:4680` の 2 byte table を引き、その結果を `DE` に入れて `JP $017D -> JP $04BF` へ渡す dispatch helper 候補

したがって、
この 2 本は少なくとも現時点では
**RNG API 本体ではなく、battle phase / descriptor / script-like dispatch 側**
として整理するのが安全。

## 1. `0D:435A` 実バイト

```text
435A: AF          XOR A
435B: 86          ADD A,(HL)
435C: 24          INC H
435D: 05          DEC B
435E: 20 FB       JR NZ,$435B
4360: C9          RET
```

最も自然な読みは:

```text
A = 0
do {
  A += [HL]
  H++
  B--
} while (B != 0)
return A
```

ここで `INC H` だけを行うので、
`HL = $D0xx` なら
`$D0xx, $D1xx, $D2xx ...`
のように page をまたいで同じ offset をなめる形になる。

つまり `435A` は
**actor page 群の同一 field を合計する helper**
とみるのが自然。

## 2. `0D:435A` が battle loop にある意味

`saga2_battle_runtime_entry_report.md` で見えていた
`0D:4178` 以降の `actors` ループでは、
`CALL $435A` が複数回出る。

`saga2_damage_candidate_functions_pass19.csv` の断片でも:

```text
41F9: CALL $435A
4201: CALL $435A
421C: CALL $435A
4224: CALL $435A
4237: CALL $435A
423F: CALL $435A
```

が見えている。

これは、
per-actor page をまたいだ集計値を作ってから
次の battle state へ進める構造と整合する。

少なくとも `435A` は
「乱数を引く helper」より
**battle party / actor aggregate を作る helper**
として読むほうが自然。

## 3. `0D:4361` 実バイト

```text
4361: 87          ADD A,A
4362: C6 80       ADD A,$80
4364: 6F          LD L,A
4365: 3E 46       LD A,$46
4367: CE 00       ADC A,$00
4369: 67          LD H,A
436A: 3E 0C       LD A,$0C
436C: CD D2 00    CALL $00D2
436F: 5F          LD E,A
4370: 23          INC HL
4371: 3E 0C       LD A,$0C
4373: CD D2 00    CALL $00D2
4376: 57          LD D,A
4377: CD 7D 01    CALL $017D
437A: 00 40 0C    inline bytes for callee
437D: C9          RET
```

ここから見えることは 3 つある。

1. `ADD A,A` しているので index は 2 byte entry 前提
2. `HL = $4680 + A*2` を作っている
3. `CALL $00D2` を 2 回行い、bank `0C` の 2 byte を `E`,`D` へ読む

したがって `4361` は、
**bank `0C:4680` の 2 byte descriptor/pointer table を index で引く helper**
とみるのがかなり自然。

## 4. `00:00D2` と `00:017D` の役割

`00:00D2` 実バイト:

```text
00D2: C5          PUSH BC
00D3: EF          RST $28
00D4: 4E          LD C,(HL)
00D5: EF          RST $28
00D6: 79          LD A,C
00D7: C1          POP BC
00D8: C9          RET
```

これは既報どおり
**bank 指定 `A` と `HL` で ROM 1 byte を読む banked-read helper**
として整合する。

`00:017D` は `JP $04BF`。
既存 `saga2_opcode_pass5_report.md` の整理では、
`04BF` は call site の直後に置かれた inline 3 byte を使う helper と読める。

なので `4361` の末尾:

```text
4377: CALL $017D
437A: 00 40 0C
```

は、
`DE` に入れた table entry と
inline operand `00 40 0C`
を組み合わせて何かの state/descriptor/script 処理へ渡している形に見える。

完全な意味はまだ未確定だが、
少なくともこれは `043E` 型 RNG helper とはかなり別系統。

## 5. bank `0C:4680` table

ROM 実データ先頭:

```text
0C:4680
96 46 73 47 18 48 E5 49
CF 4A 32 52 98 4B 43 4C
08 4D 5A 4E 6B 4F 00 00
CC 00 1F 00 01 CC 04 1F
```

最初の数 entry を 16bit little-endian として見ると:

- `4696`
- `4773`
- `4818`
- `49E5`
- `4ACF`
- `5232`
- `4B98`
- `4C43`

のようになり、
code/data descriptor table としてかなり自然。

少なくとも、
`043E` の `data_rng` のような 256 byte permutation table と
同種には見えない。

## 6. callsite 文脈

`saga2_damage_candidate_functions_pass19.csv` では
battle runtime 周辺から次の literal call が見える:

```text
40E0: LD A,$00
40E2: CALL $4361

416D: LD A,$02
416F: CALL $4361

4176: LD A,$03
4178: CALL $4361

4226: LD A,$06
4228: CALL $4361

4245: LD A,$07
4247: CALL $4361

42B3: LD A,$09
42B5: CALL $4361

4349: LD A,$0A
434B: CALL $4361
```

この使われ方は、
乱数 slot や range を渡す形ではなく、
**小さい状態番号で phase / subroutine / descriptor を選ぶ**
使い方に見える。

## 7. 現時点の整理

### 確度が高いこと

- `435A` は page をまたいだ同 offset byte 合計 helper 候補
- `4361` は bank `0C:4680 + index*2` を引く table dispatch helper 候補
- `4361` の caller は `00/02/03/06/07/09/0A` のような小 state 値を渡す
- したがって `435A/4361` は battle runtime state machine 側の helper とみるのが自然

### まだ未確定なこと

- `435A` が合計している actor field の意味
- `4361` が引いた `DE` pointer の最終的な消費先
- `00 40 0C` inline operand を含む `04BF` 側の完全契約
- 各 state 値 `00/02/03/06/07/09/0A` の具体的意味

## 次の一手

1. `0D:4178` 以降の `actors` ループを擬似コード化する
2. `4361` の後に実行される `437E` / `4579` / `1915` の役割を切る
3. battle action resolve の branch から通常攻撃本線を固定する
