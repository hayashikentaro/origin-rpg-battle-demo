# SaGa2 battle prepare helpers report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_battle_rng_phase_switch_report.md`
- 既存 `saga2_437e_contract_report.md`

## 目的

- `0D:4048-405A` loop で呼ばれる `CALL $1918` と `CALL $449A` の局所契約を切る
- battle prepare cluster の `D0xx` 5-page loop の意味を一段固める

## 結論

今回の整理で、`0D:4048-405A` の 2 本はかなり分けて読めるようになった。

- `1918` は実体として **`JP $1B99`** の thin wrapper
- `1B99` は `party_order ($C2A0)` から 2-bit field を抜いて
  **`HL += 0x20 * slot`** を作る address helper 候補
- `449A-44EE` は `HL` source から `D?00-20` 付近へ
  **固定レイアウトの page-local staging record** を組む expander helper 候補

したがって `4048-405A` は、
`D0xx..D4xx` を 5 page 回しながら
「`C200` ベースの source record を選ぶ -> それを page-local work へ展開する」
段とみるのが自然。

## 1. `1918` は wrapper

`0x1918` 実バイト:

```text
1918: C3 99 1B    JP $1B99
```

なので `CALL $1918` の実体は
`1B99` へ飛ぶ thin wrapper とみてよい。

## 2. `1B99` の骨格

`1B99` 実バイト:

```text
1B99: FE 04       CP $04
1B9B: 28 17       JR Z,$1BB4
1B9D: 3C          INC A
1B9E: C5          PUSH BC
1B9F: 47          LD B,A
1BA0: FA A0 C2    LD A,($C2A0)
1BA3: 07          RLCA
1BA4: 07          RLCA
1BA5: 0F          RRCA
1BA6: 0F          RRCA
1BA7: 05          DEC B
1BA8: 20 FB       JR NZ,$1BA5
1BAA: C1          POP BC
1BAB: E6 03       AND $03
1BAD: CB 37       SWAP A
1BAF: CB 27       SLA A
1BB1: 85          ADD A,L
1BB2: 6F          LD L,A
1BB3: C9          RET
1BB4: 7D          LD A,L
1BB5: C6 80       ADD A,$80
1BB7: 6F          LD L,A
1BB8: C9          RET
```

`common.i` では
`$C2A0 = party_order`。

このことと bit 操作を合わせると、
`1B99` はかなり強く
**`party_order` packed byte から 2-bit slot id を抜き、
`HL += 0x20 * slot` を作る helper**
と読める。

特に:

- `AND $03`
- `SWAP A`
- `SLA A`

で最終的に `0x00 / 0x20 / 0x40 / 0x60`
の 4 通りを作っている。

したがって通常ケースは:

```ts
slot = extract2BitField(partyOrder, index)
HL += slot * 0x20
```

にかなり近い。

## 3. `A == 4` の特別分岐

`CP $04 ; JR Z,$1BB4`
で特別分岐がある。

この分岐先は:

```text
1BB4: LD A,L
1BB5: ADD A,$80
1BB7: LD L,A
1BB8: RET
```

つまり special case では
**`HL += 0x80`**
を行う。

`party_order` は 2-bit x4 の packed byte とみるのが自然なので、
この special case は
「packed order の外にある 5 番目の固定 slot」
を指している可能性が高い。

少なくとも `4048-405A` の 5-page loopで
`A` が `0..4` と増えていたことと整合する。

## 4. `449A` の骨格

`449A` 実バイト先頭:

```text
449A: 3E 01       LD A,$01
449C: 1E 00       LD E,$00
449E: 12          LD (DE),A
449F: 1E 02       LD E,$02
44A1: 06 04       LD B,$04
44A3: 2A          LDI A,(HL)
44A4: 12          LD (DE),A
44A5: 1C          INC E
44A6: 05          DEC B
44A7: 20 FA       JR NZ,$44A3
44A9: 06 04       LD B,$04
44AB: 3E FF       LD A,$FF
44AD: 12          LD (DE),A
44AE: 1C          INC E
44AF: 05          DEC B
44B0: 20 F9       JR NZ,$44AB
44B2: 2A          LDI A,(HL)
44B3: 12          LD (DE),A
44B4: 1C          INC E
44B5: 2A          LDI A,(HL)
44B6: 12          LD (DE),A
```

ここまでで少なくとも:

- `D?00 = 01`
- `D?02..05` に source 4 byte copy
- `D?06..09` を `FF` 埋め
- `D?0A..0B` に source 2 byte copy

と読める。

## 5. `449A` 後半の staging

続き:

```text
44B7: D5          PUSH DE
44B8: 1E 40       LD E,$40
44BA: 2A          LDI A,(HL)
44BB: 12          LD (DE),A
44BC: 1C          INC E
44BD: D5          PUSH DE
44BE: E6 10       AND $10
44C0: CB 37       SWAP A
44C2: EE 01       XOR $01
44C4: 1E 01       LD E,$01
44C6: 12          LD (DE),A
44C7: D1          POP DE
44C8: 2A          LDI A,(HL)
44C9: 12          LD (DE),A
44CA: 1C          INC E
44CB: 2A          LDI A,(HL)
44CC: 12          LD (DE),A
44CD: D1          POP DE
44CE: 06 06       LD B,$06
44D0: 2A          LDI A,(HL)
44D1: 12          LD (DE),A
44D2: 1C          INC E
44D3: 05          DEC B
44D4: 20 FA       JR NZ,$44D0
44D6: 06 08       LD B,$08
44D8: 2A          LDI A,(HL)
44D9: 12          LD (DE),A
44DA: 1C          INC E
44DB: AF          XOR A
44DC: 12          LD (DE),A
44DD: 1C          INC E
44DE: 2A          LDI A,(HL)
44DF: 12          LD (DE),A
44E0: 1C          INC E
44E1: 05          DEC B
44E2: 20 F4       JR NZ,$44D8
44E4: 3E FF       LD A,$FF
44E6: 12          LD (DE),A
44E7: 3C          INC A
44E8: 12          LD (DE),A
44E9: 3D          DEC A
44EA: 1C          INC E
44EB: 12          LD (DE),A
44EC: 1C          INC E
44ED: AF          XOR A
44EE: 12          LD (DE),A
44EF: 12          LD (DE),A
44F0: C9          RET
```

ここからは:

- `D?40` に 1 byte copy
- その bit4 を使って `D?01` に 0/1 flag 化
- さらに 2 byte copy
- `D?0C..11` に 6 byte copy
- 8 回の `value,0` pair を展開
- 末尾に `FF/00/FF/00/00` 風の sentinel/terminator を置く

と読むのが自然。

したがって `449A` は
**variable-length source を page-local battle work layout へ正規化展開する deterministic expander**
候補としてかなり強い。

## 6. `4048-405A` loop での意味

既報の loop:

```text
4043: XOR A
4044: LD D,$D0
4046: LD B,$05
4048: PUSH BC
4049: PUSH AF
404A: LD HL,$C200
404D: CALL $1918
4050: PUSH DE
4051: CALL $449A
4054: POP DE
4055: INC D
4056: POP AF
4057: INC A
4058: POP BC
4059: DEC B
405A: JR NZ,$4048
```

この流れは、
かなり自然に次のように読める。

1. `A=0..4` を index にする
2. `HL=$C200` を `party_order` に従って 0x20-byte record へ解決する (`1918`)
3. その record を現在の `D0xx..D4xx` page に staging 展開する (`449A`)

つまりこの 5-page loop は、
**battle 用に actor/party record を `D0xx` family へ展開する準備段**
とみるのが自然。

## 移植への意味

TypeScript 側では、この 2 本を battle controller prepare の deterministic helper として切り出せる可能性が高い。

```ts
resolvePartyOrderedRecord(base: number, index: number, partyOrder: number): number
expandBattlePageRecord(srcPtr: number, dstPage: number): void
```

少なくともこの段には RNG は直接出ていない。

## 残る不明点

- `449A` source record の正式テーブル名
- `D?00..20` / `D?40` の各 field の意味
- `A==4` special case の正確な意味
- `1915`, `1918`, `1B99`, `1F1A` 近辺 wrapper 群の関係

## 次の一手

1. `449A` が展開している `D0xx` page fields を `437E` / `4178` 側 read path と照合する
2. `443A` が `D500/D600/D700` page のどこを読むかを切る
3. `battle` モジュール側で `prepareBattleControllerCluster()` の仮 API を起こす
