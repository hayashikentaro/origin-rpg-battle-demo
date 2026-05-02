# SaGa2 RNG battle slot33 report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_rng_slot_classification_report.md`

## 目的

- `bank 0D:5741 -> CALL $016B` の caller 文脈を確認する
- battle 本体で使われる slot を追加で確定する

## 結論

`bank 0D:5741` の caller は

- `A = $33`
- `DE = $1300`

で `CALL $016B` を呼んでいる。

したがってこの箇所は **slot `33` を使って `0..19` の範囲乱数を取る battle-side caller** とみるのが自然。

返り値 `A` は直後に `ADD A,A` を 3 回通して `*8` され、`C850` 台へ書かれるため、
**20 候補のいずれかを 8 byte 単位で選ぶ index / offset 生成** の可能性が高い。

## 1. 実コード

bank `0D:5723` 以降:

```text
5723: LD B,$01
5725: CALL $60D3
5728: XOR A
5729: LDH ($FF91),A
572B: LD HL,$C800
572E: INC (HL)
572F: DEC (HL)
5730: JR NZ,$5752
5732: LD HL,$C8A0
5735: INC (HL)
5736: LD A,(HL)
5737: AND A
5738: JR NZ,$5751
573A: LD A,$33
573C: LD DE,$1300
5741: CALL $016B
5744: ADD A,A
5745: ADD A,A
5746: ADD A,A
5747: LD C,A
5748: LDH A,($FF91)
574A: ADD A,A
574B: LD HL,$C850
574E: LD (HL),C
574F: INC HL
5750: LD (HL),$00
5752: LD A,($C994)
5755: LD B,A
5756: LDH A,($FF91)
5758: INC A
5759: CP B
575A: JP C,$5729
575D: RST $00
575E: RET
```

## 2. `043E` 呼び出し契約への当てはめ

既存確定契約:

- `A` = slot
- `E` = lower
- `D` = upper

なので `5741` は

- slot = `33`
- lower = `00`
- upper = `13`

を意味する。

返り値は **`0..19`**。

## 3. 返り値の使われ方

call 後:

```text
5744: ADD A,A
5745: ADD A,A
5746: ADD A,A
5747: LD C,A
...
574B: LD HL,$C850
574E: LD (HL),C
574F: INC HL
5750: LD (HL),$00
```

つまり返り値は `A * 8` に変換され、16bit 値の下位 byte として `C850` へ保存される。

`0..19` を `*8` すると

- `0x00`
- `0x08`
- `0x10`
- ...
- `0x98`

になるため、**8 byte record が 20 個並ぶテーブルの index** を作っていると読むのが自然。

## 4. battle 側での意味

この caller は `C800/C8A0/C850/C994` を触っており、field/input 側ではなく
**battle-side work buffer / candidate table 構築** の文脈に見える。

少なくともここから言えるのは:

- battle 本体でも `043E` が使われる
- slot `33` は battle 用途の専用 or 半専用 slot 候補
- 範囲は raw 0..255 ではなく `0..19`

ということ。

## 5. 現時点の整理

### 確度が高いこと

- `5741` は battle 本体 caller として有力
- ここで使う slot は `33`
- range は `0..19`
- 返り値は `*8` されて `C850` 台へ入る

### まだ未確定なこと

- 20 候補の実体が何か
- `C850` が何のテーブル pointer/offset か
- slot `33` が battle 専用か、他文脈にも現れるか

## 次の一手

1. `C850` の消費先を追って、20 候補テーブルの実体を切る
2. `CALL $60D3` と `C800/C8A0` の役割を確認する
3. slot `33` の他 callsite を探索する
