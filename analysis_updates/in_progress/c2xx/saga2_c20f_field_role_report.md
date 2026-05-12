# SaGa2 `C20F` field-role report

## 1. 目的

- `C20F` の役割を `611C` / `6332` / `10CC` 系で横並びに整理する
- player-local record なのか selector-local work なのかを、現時点で安全に言える範囲まで固定する

## 2. 結論

現時点で `C20F` は、
かなり自然に
**`playerIndex -> C20F + 16*player` で引く player-local selector/candidate work record**
とみるのが安全である。

今回強く言えるのは次の 4 点。

1. `611C` では `C20F + 16*player` を `FF` で 16 byte clear した直後に seeded candidate gate を回している  
2. `6332` でも `C206/C204/C20F` は同じ `019B` indexing helper で `base + 16*player` 扱いされている  
3. `10CC` 系でも `HL=$C20F` を起点に high-range selector dispatcher が player-local source を読む線が見えている  
4. したがって `C20F` は visible `C200` main record そのものではなく、**selector/battle prepass 用の 16byte local work family**

つまり `C20F` は、
`611C` の入口で空にされ、
そのあと `RST $08(E=$15) -> 01B9 -> FF8C -> 5F07 -> C73D[index] -> 019E`
という chain の前提になる
**player-local seeded candidate workspace**
として持つのがもっとも整合する。

## 3. `611C` での使われ方

既報:

```text
611F: LD A,($C709)
6122: LD HL,$C20F
6125: CALL $019B
6128: LD A,$FF
612A: LD B,$10
612C: CALL $006D
```

ここでは:

- `019B` により `HL = C20F + 16*player`
- その 16 byte 全体を `FF` fill
- その直後に `C73D` seed と `E=$15` dispatch

となっている。

この流れから、
`C20F` は static table ではなく
**player-local working set**
とみるのが自然である。

## 4. `6332` との比較

既報 `6332` worker では:

```text
636F: LD HL,$C206
6372: CALL $019B
...
63DB: LD HL,$C204
63DE: CALL $019B
...
6417: LD HL,$C20F
641A: LD A,($C709)
641D: CALL $019B
```

ここで `C206/C204/C20F` はいずれも
`019B` 経由で同じ 16byte stride の player-local family として扱われている。

したがって少なくとも構造上は:

- `C204`
- `C206`
- `C20F`

が同じ layout family に属することはかなり強い。

ただし役割は同一ではなく、
`611C` 文脈では `C20F` だけが明示的に `FF` clear されるため、
この field family の中でも
**candidate/selector work 色が最も強い base**
とみるのが安全である。

## 5. `10CC` 系との接続

既報 `10CC` selector contract では、
少なくとも次の hit がある。

- `10D4: LD HL,$C20F`
- `1149: LD HL,$C20F`

`10CC` は high-range selector dispatcher 本体候補だったので、
この接続は重要である。

つまり `C20F` は battle prepass 専用の一時バッファに留まらず、
**selector family が読む player-local source/work**
としても再利用されている可能性が高い。

これで `611C` の seeded candidate gate と、
selector-runtime 側の high-range reader が
同じ局所レコード族の上に乗っている線がかなり強くなる。

## 6. `C200` との違い

`C200` 系は別報で:

- `A600 <-> C200` large transport
- `C200 <-> C7EE` scratch header copy

など、visible main record として使われる姿が強い。

それに対し `C20F` は:

- `FF` で全消去される
- `019B` で 16byte stride 参照される
- `611C` の seeded candidate gate の入口になる
- `10CC` selector high-range の source 候補にも見える

という点で、
visible main record というより
**selection/prepass layer の local work record**
に近い。

## 7. 安全な struct 仮説

まだ byte-level field は未確定だが、
高位では次の程度に持つのが安全。

```ts
type PlayerLocalSelectorWork = Uint8Array // 16 bytes
```

少なくとも `611C` では:

```ts
clear(work)
seedCandidateSet(work, C73D)
dispatchAndResolve(work)
```

という役割で使われている可能性が高い。

## 8. `C2F6` 探索への意味

`C20F` の位置づけが見えてくると、
`611C` はより明確に
**player-local selector work を空にし、seed table と current selection chain を通して 1件を commit する helper**
と読める。

これは `C2F6` producer そのものではないが、
`0198` backing state に近い hidden-local seed layer の
かなり内側まで来ていることを意味する。

## 9. 次の一手

1. `C73D..C744` の他 caller を探して、8要素 seed/remap table の共通性を確認する  
2. `10D4/1149` 側で `C20F` のどの byte を読むかを切って field 粒度を上げる  
3. `60E8-611B` を `C20F` / `C73D` / `FF8C` を束ねる parent setup として再整理する
