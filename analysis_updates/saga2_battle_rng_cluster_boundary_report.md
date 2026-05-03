# SaGa2 battle RNG cluster boundary report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_battle_rng_caller_cluster_report.md`
- 既存 `saga2_battle_rng_de00_consumers_report.md`
- 既存 `saga2_battle_rng_bc_page_report.md`

## 目的

- `0D:4040-408E` cluster の入口/出口について、今ある断片から確定できる範囲を整理する
- 次にどこを切れば cluster 全体の制御構造が固まるかを明確にする

## 結論

実バイトを取り直した結果、
cluster 境界はかなり具体化した。

現時点で `0D:4024-4075` は
**3 段の battle prepare cluster**
として読むのが自然。

1. `4024-4041`  
   `D5xx` 3-page source deposition loop。`44F4` を呼び、`DE10 -> D849+` を行う
2. `4043-405A`  
   `D0xx` 5-page staging loop。`CALL $1918` と `CALL $449A` を回す
3. `405C-4075`  
   条件付き `D400/D401` clear のあと、`D500/D600/D700` に `CALL $443A` を回す

つまり以前の
「`405A-4083` は主に空白の phase switch」
という整理より一段進んで、
**切り替え部の実体が見えた**
段階に来た。

## 1. 前半 loop の境界

実バイト:

```text
4024: PUSH BC
4025: PUSH DE
4026: LD E,$00
4028: LD A,(DE)
4029: OR A
402A: JR Z,$402F
402C: CALL $44F4
402F: POP DE
4030: INC D
4031: POP BC
4032: PUSH BC
4033: LD A,$03
4035: SUB B
4036: ADD A,$49
4038: LD C,A
4039: LD B,$D8
403B: LD A,($DE10)
403E: LD (BC),A
403F: POP BC
4040: DEC B
4041: JR NZ,$4024
```

ここから言えること:

- loop 本体は `4024-4041`
- `B=3` 系の source loop である可能性が高い
- `D5xx` source page から `44F4` を引いて `DE10` を `D8xx` familyへ返している

このため前半 loop の境界は、以前よりかなり具体化できた。

## 2. 中間 5-page loop

`4043-405A` は独立した 5-page loop。

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

ここから、
`D0xx..D4xx` を 5 page 回しながら
`1918` と `449A` を呼ぶ staging 段が挟まっていると分かる。

## 3. 後半 prepass loop の境界

`405C-4075` は phase switch を含む後半 loop。

```text
405C: CALL $0198
405F: JR NZ,$4067
4061: LD HL,$D400
4064: XOR A
4065: LDI (HL),A
4066: LD (HL),A
4067: LD BC,$D500
406A: LD A,$03
406C: PUSH AF
406D: PUSH BC
406E: CALL $443A
4071: POP BC
4072: INC B
4073: POP AF
4074: DEC A
4075: JR NZ,$406C
```

ここから確定に近いこと:

- `CALL $0198` の条件で `D400/D401` clear がある
- `CALL $443A` は `D500/D600/D700` に対する 3-page loop
- `A=3` が明示されている
- `INC B` だけで次 page に移るので、low offset は固定

したがって cluster の出口側は
**少なくとも `4075` 直後**
まで絞れた。

## 5. 何がまだ欠けているか

いま欠けているのは主に 3 点。

1. `44F4` 前半 source loop の `D5xx` page 正式意味
2. `1918` と `449A` の契約
3. `443A` が `D500/D600/D700` page のどこを読むか

## 6. 擬似コードの暫定形

いま見えている範囲だけで書くと、
cluster は次の形に近い。

```ts
for each sourcePage in d5Pages[0..2] {
  if (sourcePage[0] != 0) {
    scratch = buildScratchRecord(sourcePage) // 44F4
  }
  d8Metadata[...] = scratch.de10
}

for each page in d0Pages[0..4] {
  stagePage(page) // 1918 + 449A
}

if (!check0198()) {
  d400[0] = 0
  d400[1] = 0
}

for each page in [D500, D600, D700] {
  prepassFlags(page) // 443A
}
```

もちろん意味論はまだ未確定だが、
**「D5 source -> D8 metadata -> D0 staging -> D5 prepass」**
という段構造はかなり強い。

## 移植への意味

TypeScript 側では、
この cluster を 1 本の prepare helper として仮置きすると設計しやすい。

```ts
prepareBattleControllerCluster(d5Pages, d0Pages, d8Meta, rng)
```

このうち現時点で RNG が直接出るのは `443B` 側だけで、
`44F4`, `1918/449A`, `443A` は deterministic prepare/staging 側として分離できる可能性が高い。

## 次の一手

1. `1918` と `449A` の契約を切って `D0xx` 5-page loop を解釈する
2. `443A` が `D500/D600/D700` page のどこを読むかを切る
3. `4024-4075` 全体を battle controller prepare cluster として擬似コード化する
