# SaGa2 `6157` Apply/Staging Context Report

## Summary
- `6157` は `60E8-611B` 親ループの中で、`611C` の seeded gate 成功後にだけ起動される per-player 後段 helper とみるのが自然。
- 実バイト上、`C200 + 16*player -> C7EE` の 4 byte scratch copy、`C7EE -> C200 + 16*player` の逆向き copy、さらに `D400/D500` family 初期化と `RST $08(E=$2C/$2D)` を含むため、**player-local apply/staging helper** としてかなり強い。
- これにより `5F22 -> 5E77 -> 611C -> 6157` は、`global precondition -> visible precondition -> local seed/validate -> per-player apply/staging` の 4 段として持てる。

## Evidence

### 1. Parent-loop placement
```asm
60F3: CALL $611C
60F6: JR NC,$610F
60F8: CALL $6157
60FB: JR NC,$60F3
```

- `6157` は `611C` 成功後にだけ呼ばれる。
- `60FB` の分岐から、`6157` 自身も continue/retry 判定を返す高位 helper とみるのが自然。
- したがって `6157` は local seed/gate 本体ではなく、**gate 成功結果を battle-side state へ反映する後段** と読むのが最も整合する。

### 2. Scratch header copy
```asm
6157: LD A,($C709)
615A: LD HL,$C200
615D: CALL $019B
6160: LD DE,$C7EE
6163: LD B,$04
6165: CALL $0080
```

- `C200 + 16*player -> C7EE` の 4 byte copy が見える。
- 後半では:

```asm
61EB: LD A,($C709)
61EE: LD HL,$C200
61F1: CALL $019B
61F4: LD E,L
61F5: LD D,H
61F6: LD HL,$C7EE
61F9: LD B,$04
61FB: CALL $0080
```

- `C7EE -> C200 + 16*player` の逆向き copy が見える。

この対称性から、`C7EE` は flat list より **player-local scratch header** とみるのが自然。

### 3. Battle-side staging
```asm
6168: CALL $5DF8
616B: LD E,$2C
616D: RST $08
616E: LD E,$2D
6170: LD A,$02
6172: CALL $01C5
6175: LD HL,$D400
6178: LD B,$00
617A: CALL $006C
617D: LD ($C7D6),A
6180: LD HL,$D500
6183: LD BC,$0170
6186: LD A,$FF
6188: CALL $0073
```

- `RST $08(E=$2C/$2D)` による dispatch/event 的な段
- `D400/D500` family 初期化

が続くため、`6157` は scratch copy だけでなく、**battle-side apply/staging/init** をまとめて担う高位 routine とみるのが安全。

## Safe Contract
現時点で安全に言える `6157` の契約は次の程度。

- 入力: `611C` で gate 成功した current player
- 処理:
  - `C200 + 16*player` の一部を `C7EE` へ退避
  - dispatch / apply 用の side effect を実行
  - `D400/D500` family を初期化
  - 必要なら `C7EE` から player record へ書き戻す
- 出力: 次の player へ進めるかどうかの continue/retry 状態

## Relation To The 4-Layer Model
- `5F22`: one-shot global precondition
- `5E77`: one-shot visible/render precondition
- `611C`: player-local seed/validate gate
- `6157`: player-local apply/staging

この分け方なら、`60E8-611B` 親ループは
local seed を作る段と、それを battle-side state へ反映する段を
明確に分離して扱える。

## Implication For `C2F6`
- `6157` は hidden producer 本体というより、すでに前段で決まった candidate/selection 結果を battle-side staging へ落とす後段 helper とみるのが自然。
- したがって `C2F6` 探索では、`6157` は producer 候補より **後段 apply layer** として優先度を下げてよい。

## Next Steps
1. `6157` 後半の `D400/D500` field をもう一段細かく切る。
2. `611C` と `6157` の carry/NC 契約差を parent-loop 全体で整理する。
3. `60E8-611B` を 4 層 parent setup として `C2F6` 探索線へ正式に再接続する。
