# SaGa2 battle RNG bridge followup report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_battle_rng_bridge_report.md`

## 目的

- `443B-4499` の終端を確定する
- `449A-44F3` が同一路の continuation かどうかを切り分ける

## 結論

生ROMを引き直すと、前回の
「`449A-44F3` は `443B-4499` の後続展開部」
という読みは誤りだった。

高確度に言えるのは次の 2 点。

1. `443B-4499` は `449A` で **`RET`** する独立 helper
2. `449A-44F3` は record expansion 風の **別 helper**

したがって battle と rng の接続部として
安全に使えるのは、
**slot `07/08` で 16bit offset を作り pointer record を書く**
ところまで。

## 1. `443B-4499` の終端

```text
4484: ADD HL,DE
4485: POP DE
4486: POP BC
4487: XOR A
4488: LD (BC),A
...
4495: POP HL
4496: POP AF
4497: DEC A
4498: JR NZ,$445E
449A: RET
```

ここで明確に `RET` しているので、
`449A-44F3` は fallthrough ではない。

## 2. `443B-4499` で確実に言えること

- base pointer `HL` を work record から読む
- slot `07/08` で 16bit signed offset を作る
- `HL += offset` した pointer を `BC` 側 record 配列へ書く
- `C` は 8 byte stride 風に進む

つまりこの helper は
**pointer candidate builder**
として読むのが自然。

## 3. `449A-44F3`

`449A` 以降は別入口として見ると、
`HL` からの逐次読みを
`DE` 低位 offset 群へ定型展開している。

見えている特徴は:

- `LDI A,(HL)` が多い
- `DE` の low byte を `00/01/02/40` などへ切り替える
- `FF` 埋めや flag 整形が混ざる

そのため
**battle-side normalized record expansion helper**
の可能性は高い。

ただし今の段階では
`443B-4499` が選んだ pointer を
この helper が直接受け取る証拠まではない。

## 4. 移植上の意味

この修正で TypeScript/Godot 側に残せる高確度部分は、

```ts
const hi = rng.next(0x07, 0x00, upperHi)
const lo = rng.next(0x08, 0x00, upperLo)
const offset = toSigned16(hi, lo)
const source = basePointer + offset
writePointerRecord(source)
```

という bridge まで。

`readActionRecord(source)` や `expandActionRecord(record)` を
同じ helper 直後と決め打ちするのは、まだ早い。

## 5. 残る不明点

- `443B` 入口時点の `BC` 実アドレス
- pointer record の正式レイアウト
- `449A-44F3` の caller
- `43FB-443A` と `443B-4499` の前後関係

## 次の一手

1. `443B` caller を追って `BC` の page を固定する
2. `43FB-443A` を別 helper として解析する
3. `449A-44F3` caller を追って destination work buffer を特定する
