# SaGa2 `0198 -> 0608` predicate report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_6332_success_rebuild_report.md`
- 既存 `saga2_019b_indexing_report.md`

## 目的

- `0198 -> 0608` の契約を切る
- `6332` の追加 `636C` 条件を安全な範囲で整理する

## 結論

`0198 -> 0608` は現時点では、
**`E=0` を固定入力にして `C2F6` 系 table を見る 1byte predicate helper**
とみるのが最も自然。

強く言えるのは次の 3 点。

1. `0198` は `0608` への wrapper  
2. `0608` は `DE` を退避したうえで `E=0` を設定し、`063E -> 0661` を通して `A` を返す  
3. caller ではその `A` を `AND A` / `JR Z` で見ており、**真偽判定 helper** として使われている

したがって `6332` の

```text
633F: CALL $0198
6342: JR Z,$6347
6344: CALL $636C
```

は、
「通常の `0..3` loop に加えて、predicate が真のときだけ追加でもう 1 件 `636C` を回す」
と読むのが安全。

ただしその predicate が
「extra player」
「5th logical slot」
「別 page/bank mode」
のどれかは、まだ断定しないほうがよい。

## 1. wrapper

```text
0198: JP $0608
```

## 2. `0608` の骨格

```text
0608: LDH ($FF90),A
060A: PUSH DE
060B: LD E,$00
060D: CALL $063E
0610: AND A
0611: POP DE
0612: LDH A,($FF90)
0614: RET
```

ここから見えるのは:

- caller の `A` は `FF90` に退避して復元
- 実入力は `E=0`
- `063E` の戻り値に対して `AND A` で flags だけ整える

なので、`0198` は非常に典型的な
**predicate / condition check**
と読むのが自然。

## 3. `063E -> 0661`

`063E`:

```text
063E: PUSH HL
063F: CALL $0661
0642: JR C,$0646
0644: SWAP A
0645: AND $0F
0647: POP HL
0648: RET
```

`0661`:

```text
0661: LD A,E
0662: AND $1F
0664: SRL A
0666: PUSH AF
0667: LD HL,$C2F6
066A: RST $00
066B: POP AF
066C: LD A,(HL)
066D: RET
```

`E=0` 固定で入るため、
少なくとも `0198` 文脈では
`C2F6` base の先頭近辺を見ている。

この helper は carry 次第で:

- nibble 変換
- table 値そのまま

のどちらかを返しているが、
いずれにしても caller では真偽値としてしか使われていない。

## 4. `6332` への反映

`6332` 先頭:

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

- `A=0,1,2,3` の 4 回で `636C`
- `0198` が nonzero ならもう 1 回 `636C`

なので、高位には

```ts
for (let i = 0; i < 4; i++) rebuild(i)
if (predicate0198()) rebuild(extraIndexOrCurrent)
```

と表現するのが安全。

## 5. 他 caller との整合

既報どおり `0198` は:

- `62B4`
- `633F`
- `405C`
- `60EE` 近辺

など複数 cluster で分岐判定に使われている。

この共通性からも、
`0198` を subsystem 固有の heavy helper とみるより
**layout / slot availability / mode presence を返す predicate**
と持つほうが整合する。

## 6. 移植上の意味

TypeScript 側では、まだ意味を言い切らず

```ts
function checkOptionalSlotOrMode(): boolean
```

のような仮 API で持つのが安全。

その上で `6332` 側では
「追加 rebuild の有無を返す predicate」
として接続すれば、現段階の知見を壊さずに実装できる。

## 7. まだ未確定な点

- `C2F6` table の内容
- carry が立つ条件
- `0198` が “extra player” なのか “optional slot” なのか
- `405C` や `62B4` での predicate の意味差

## 次の一手

1. `C2F6` を producer/caller ごとに追って table のドメインを切る
2. `405C` と `633F` を比べて `0198` の subsystem 共通意味を整理する
3. `643A` caller 文脈を追って `C785` 更新の意味を切る
