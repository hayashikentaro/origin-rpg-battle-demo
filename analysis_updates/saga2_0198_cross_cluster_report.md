# SaGa2 `0198` cross-cluster report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_0198_predicate_report.md`
- 既存 `saga2_battle_rng_phase_switch_report.md`
- 既存 `saga2_6332_success_rebuild_report.md`

## 目的

- `405C` 側と `633F` 側の `CALL $0198` を比較する
- `0198` の subsystem 共通意味を安全な範囲で整理する

## 結論

`0198` は現時点では、
**「追加 page/slot/entry が有効かどうか」を返す predicate**
とみるのが最も整合する。

理由は単純で、battle 側 `405C` と selector 側 `633F` のどちらでも、
`0198` の結果が

- 追加処理を行うか
- 0 埋め/skip するか

という **phase expansion の分岐** に使われているからである。

したがって、以前より一段具体的に

```ts
checkOptionalEntryPresence(): boolean
```

くらいまで寄せてよい。

ただしその entry が

- 5th member
- optional slot
- alternate page

のどれかは、まだ保留したほうが安全。

## 1. selector 側 `633F`

`6332` 冒頭:

```text
6332: LD A,($C709)
6335: PUSH AF
6336: XOR A
6337: CALL $636C
633A: INC A
633B: CP $04
633D: JR C,$6337
633F: CALL $0198
6342: JR Z,$6347
6344: CALL $636C
```

ここでは:

- 4 回の既定 loop
- `0198` が真なら追加でもう 1 回

となる。

つまり selector/runtime rebuild 文脈では、
`0198` は **optional extra iteration の有無** を返している。

## 2. battle 側 `405C`

既報の `0D:405C-4066`:

```text
405C: CALL $0198
405F: JR NZ,$4067
4061: LD HL,$D400
4064: XOR A
4065: LDI (HL),A
4066: LD (HL),A
4067: LD BC,$D500
...
```

ここでは:

- `0198 != 0` ならそのまま次 phase
- `0198 == 0` なら `D400/D401` を clear

となる。

これは selector 側と同じく、
「optional な page/entry が存在しない場合に default clear を入れる」
読み方とよく合う。

## 3. 共通して見えるもの

2 つの caller を並べると、
`0198` はどちらでも

- 重い計算の起点ではない
- 既定 loop/count を変える
- optional state の有無で zero-clear / extra-iteration を切り替える

という使われ方になっている。

したがって subsystem を跨いでも、
かなり安全に

**availability / presence predicate**

と表現できる。

## 4. `C2F6` との接続

`0608 -> 063E -> 0661` は
`C2F6 + ((E & 0x1f) >> 1)` 近辺を読む小 helper だった。

`0198` 自体は `E=0` 固定で入るので、
少なくともこの entry point では
`C2F6[0]` 系の先頭状態だけを使って presence を見ている可能性が高い。

これも「固定の optional slot state」読みと整合する。

## 5. 移植上の意味

TypeScript 側では、いまの段階なら

```ts
function hasOptionalEntry(): boolean
```

か

```ts
function checkOptionalEntryPresence(): boolean
```

のような抽象名で置くのが一番安全。

battle 側でも selector 側でも、
この predicate は

- extra loop を回す
- clear を省略する

という branch point にだけ使えばよい。

## 6. まだ未確定な点

- optional entry の実体
- `C2F6` の producer
- `62B4` / `60EE` caller での意味差

## 次の一手

1. `C2F6` の producer を追って optional entry の正体を確定する
2. `643A` caller 文脈を追って `C785` 更新の意味を切る
3. `62B4` caller をこの新解釈で読み直して selector-budget cluster の gate 条件を詰める
