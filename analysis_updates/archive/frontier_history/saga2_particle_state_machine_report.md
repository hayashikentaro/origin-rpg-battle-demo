# SaGa2 particle state machine report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_rng_battle_slot33_report.md`

## 目的

- `57E0-589B` 周辺を particle 系 state machine として整理する
- slot `33` が battle damage 本体ではなく演出側 RNG かを確認する

## 結論

`common.i` の RAM ラベルから見て、

- `C800 = window_buffer_1.particle_delay`
- `C828 = window_buffer_1.particle_alive`
- `C850 = window_buffer_1.particle_position`
- `C8A0 = window_buffer_1.particle_user_array_1`
- `C940 = window_buffer_1.particle_velocity`
- `C992 = window_buffer_1.particle_update`
- `C994 = window_buffer_1.particle_count`

である。

したがって `56C0` クラスタは **battle particle system** とみるのが自然で、
slot `33` も最終ダメージ乱数というより **particle 初期配置の index RNG** 候補に下がる。

## 1. RAM ラベル

`common.i`:

```text
window_buffer_1.particle_delay       = $C800
window_buffer_1.particle_alive       = $C828
window_buffer_1.particle_position    = $C850
window_buffer_1.particle_user_array_1= $C8A0
window_buffer_1.particle_oam_type    = $C8C8
window_buffer_1.particle_velocity    = $C940
window_buffer_1.particle_oam_ptr     = $C990
window_buffer_1.particle_update      = $C992
window_buffer_1.particle_global_update = $C993
window_buffer_1.particle_count       = $C994
```

これだけで `C850/C8A0/C940/C994` は battle particle work area と読める。

## 2. `5741` の位置づけ

既報:

- `A=$33`
- `DE=$1300`
- `CALL $016B`
- result を `*8` して `C850` へ保存

これは particle position table の初期 index を作っていると読むのが自然。

## 3. `57D8-57F6`

`damage_hp_write_narrow_pass20.csv` の断片:

```text
57D8: LD HL,$D933
57DB: RST $00
57DC: LD C,(HL)
57DD: LDH A,($FF91)
57DF: ADD A,A
57E0: LD HL,$C850
57E3: RST $00
57E4: LD A,C
57E5: SUB $02
57E7: ADD A,A
57E8: ADD A,A
57E9: ADD A,A
57EA: LD (HL+),A
57EB: LD (HL),$10
57ED: LD HL,$FF91
57F0: INC (HL)
57F1: LDH A,($FF90)
57F3: CP $02
57F5: RET NC
57F6: INC A
```

解釈:

- `FF91` を particle index として使う
- `C850 + index*2` に position を置く
- X 側は `(D933[index] - 2) * 8`
- Y 側は固定 `0x10`

つまりここは particle 1 個ぶんの初期位置生成。

## 4. `5854-5880`

```text
5854: LD HL,$C8A0
5857: RST $00
5858: LD A,(HL)
5859: AND A
585A: JR NZ,$5883
585C: LDH A,($FF90)
585E: LD HL,$C851
5861: ADD A,A
5862: RST $00
5863: LD A,(HL)
5864: SUB $04
5866: JP C,$604E
5869: LD (HL),A
586A: LDH A,($FF90)
586C: ADD A,A
586D: LD HL,$C940
5870: RST $00
5871: LD A,(HL)
5872: ADD A,$02
5874: LD (HL),A
5875: CP $89
5877: RET C
5878: LD (HL),$88
587A: LDH A,($FF90)
587C: LD HL,$C8A0
587F: RST $00
5880: LD (HL),$01
```

解釈:

- `C8A0[index] == 0` のときは phase 0
- `C851[index*2]` を 4 減算
- `C940[index*2]` を 2 加算、`0x88` で clamp
- 閾値に達したら `C8A0[index] = 1`

これは **falling / accelerating phase** から次 phase へ移る更新と読むのが自然。

## 5. `5883-58A7`

```text
5883: LDH A,($FF90)
5885: LD HL,$C851
5888: ADD A,A
5889: RST $00
588A: LD A,(HL)
588B: SUB $04
588D: JP C,$604E
5890: LD (HL),A
5891: LDH A,($FF90)
5893: ADD A,A
5894: LD HL,$C940
5897: RST $00
5898: LD A,(HL)
5899: SUB $02
589B: LD (HL),A
589C: CP $78
589E: RET NC
589F: LD (HL),$78
58A1: LDH A,($FF90)
58A3: LD HL,$C8A0
58A6: RST $00
58A7: LD (HL),$00
```

解釈:

- `C8A0[index] != 0` のときは phase 1
- 位置は引き続き上方向へ 4 移動
- 速度は今度は 2 減算、`0x78` で floor
- 閾値を割ると `C8A0[index] = 0`

つまり phase 0 / phase 1 を往復する **simple oscillation / bounce-like update** に見える。

## 6. state machine の暫定擬似コード

```ts
for (let i = 0; i < particleCount; i++) {
  if (!particleAlive[i]) continue;

  if (user1[i] === 0) {
    y[i] -= 4;
    if (y[i] < 0) return earlyExit();
    velocity[i] = min(velocity[i] + 2, 0x88);
    if (velocity[i] >= 0x89) user1[i] = 1;
  } else {
    y[i] -= 4;
    if (y[i] < 0) return earlyExit();
    velocity[i] = max(velocity[i] - 2, 0x78);
    if (velocity[i] < 0x78) user1[i] = 0;
  }
}
```

初期化側では slot `33` で選ばれた candidate から X 位置を入れ、Y を `0x10` にしている。

## 7. RNG への影響

この整理により、slot `33` は

- battle 中に使われる
- しかし damage / hit 本体ではなく
- particle position 初期化の index 選択

とみるのが最も自然。

したがって battle RNG でも、
**演出 RNG とロジック RNG を区別して整理する必要がある**。

## 8. 現時点の整理

### 確度が高いこと

- `56C0` クラスタは particle system
- `C850/C851` は particle position の 2byte 対
- `C8A0` は phase/state flag
- `C940` は velocity 風配列
- slot `33` は particle 初期化 RNG 候補

### まだ未確定なこと

- `D933` の正体
- `C850` 初期 X 値がどの見た目候補に対応するか
- particle_alive / particle_delay / particle_oam_ptr 全体の連携

## 次の一手

1. `D933` の生成元を追って particle 初期 X 候補を確定する
2. `5FBC/60D3` を見て particle 初期化 API 全体を切る
3. damage / hit 本体で使う slot を別系統で探す
