# SaGa2 `C2F6` copy-wrapper gap report

## 1. 目的

- `0072 / 0067 / 00B5 / 00BC` の helper 契約を整理する
- `C2F6` producer 探索で copy/read wrapper 線をどこまで除外できるかを確認する

## 2. 結論

今回の確認で、`C2F6` を直接またぐ hidden-state copy は
**この helper 群からもまだ見えていない**。

強く言えるのは次の 3 点:

1. `0072` は **`HL` base を `BC` byte zero-fill** する helper  
2. `00B5` / `00BC` は **`RST $28` を前後に挟む banked copy wrapper**  
3. 現在見えている caller は主に `C200`, `C785`, `C760`, `A600` 周辺で、  
   `C2E0-C2FF` hidden shadow state へ届く高確度 caller は未確認

## 3. helper 契約

### 3.1 `0072`

`usage_handlers_pass27.csv` の抽出から:

```text
0072: XOR A
0073: PUSH AF
0074: PUSH DE
0075: LD E,A
0076: LD (HL),E
0077: INC HL
0078: DEC BC
0079: LD A,C
007A: OR B
007B: JR NZ,$0076
007D: POP DE
007E: POP AF
007F: RET
```

これは自然に:

```text
fillZeroBC(HL, BC)
```

と読める。

`678D: LD HL,$C200 ; LD BC,$017C ; CALL $0072`
のような caller もあり、
現実の使い方とも整合する。

### 3.2 `0067`

`0067` は fill/copy helper ではなく:

```text
0063: ADD HL,HL
0064: ADD HL,HL
0065: ADD HL,HL
0066: ADD HL,HL
0067: ADD HL,HL
0068: ADD HL,HL
0069: ADD HL,HL
006A: ADD HL,DE
006B: RET
```

したがって実体は
**`HL = HL*128 + DE` 系の address/stride helper**
とみるのが自然で、`C2F6` backing bytes を準備する copy 本体ではない。

## 4. `00B5` / `00BC`

抽出された wrapper 本体は:

```text
00B5: RST $28
00B6: PUSH AF
00B7: CALL $0080
00BA: JR $00CF

00BC: RST $28
00BD: PUSH AF
00BE: CALL $0089
00C1: JR $00CF

00CF: POP AF
00D0: RST $28
00D1: RET
```

つまり:

- `00B5`: **banked `B` byte copy wrapper**
- `00BC`: **banked `BC` byte copy wrapper**

と読むのが自然。

`RST $28` は既報どおり bank swap helper 入口なので、
どちらも「banked source を一時切替して copy、復帰する wrapper」になっている。

## 5. caller 文脈

### 5.1 `00B5`

高確度 caller で見えているのは主に:

- `648F: CALL $00B5`
  - `DE=$C785`, `B=$08`
  - banked name/display record の 8 byte copy
- `6685: CALL $00B5`
  - `DE=$C760`, `B=$03`
  - `7860` の 3 byte value record copy
- battle 側 `450A`, `451F`
  - record/pointer builder 近辺だが、`C2F6` とはまだ未接続

どれも **small record copy** として読むのが自然で、
`C2E0-C2FF` hidden shadow block 全体を準備する使い方には見えない。

### 5.2 `00BC`

wrapper 本体は見えているが、
今回拾えた高確度 caller はまだ薄い。

ただし `00BC -> CALL $0089` なので、
役割は `00B5` の `BC` 長版だとみてよい。

### 5.3 `0072`

主な caller:

```text
678D: LD HL,$C200
6790: LD BC,$017C
6793: CALL $0072
```

これは明確に
**`C200` visible block の bulk clear**
であって、`C2F6` hidden shadow state 直結ではない。

## 6. `C2F6` 探索への意味

今回の helper 契約で、次のことがかなり安全になった。

- `0072` は visible/local block clear に偏る
- `00B5` は small banked record copy に偏る
- `00BC` も同系の banked bulk copy wrapper とみられる
- `0067` は copy helper ではなく address math helper

したがって `C2F6` producer 探索は、
この helper 群の **generic contract 自体** よりも、
「どの caller が `C2E0-C2FF` を base にしているか」をさらに広く見る段階に進める。

## 7. 次の一手

1. battle/item/script をまたいで `00BC` caller をもう少し拾う  
2. `RST $28` 前後で `HL/DE` が `C2E0-C2FF` に向く cluster を抽出する  
3. `0198` caller 直前に限定して hidden-state init の wider setup を探す
