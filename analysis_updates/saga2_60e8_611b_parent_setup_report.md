# SaGa2 60E8-611B Parent Setup Report

## Summary
- `60E8-611B` は `player_index ($C709)` を 1..3 で回しながら `611C` と `6157` を結ぶ、player-by-player の parent setup / orchestration loop とみるのが自然。
- これにより `611C` の seeded candidate gate は孤立 helper ではなく、親ループから各 player ごとに起動される local seed pipeline として整理できる。
- `C20F`, `C73D`, `FF8C` は `611C` 内だけの局所 scratch ではなく、この parent loop が毎周回ごとに準備して consume する player-local seed state とみるほうが整合する。

## Code Shape
```asm
60E8: CALL $5F22
60EB: CALL $5E77
60EE: LD A,$01
60F0: LD ($C709),A
60F3: CALL $611C
60F6: JR NC,$610F
60F8: CALL $6157
60FB: JR NC,$60F3
60FD: LD A,($C709)
6100: INC A
6101: CP $04
6103: JR C,$60F0
6105: LD HL,$C700
6108: XOR A
6109: LDI (HL),A
610A: LDI (HL),A
610B: LD (HL),A
610C: JP $5EB4
610F: LD A,($C709)
6112: CP $02
6114: JR C,$60F3
6116: DEC A
6117: LD ($C709),A
611A: JR $60F8
```

## Reading
- `5F22` と `5E77` は parent loop 前段の pre-refresh / setup helper 群とみるのが自然で、ここで global visible state を整えたあとに player-local seeded gate へ入っている。
- `60EE-6103` は `C709=1..3` を正方向に回しながら `611C` を呼び、carry 成功時のみ `6157` へ進める main pass と読める。
- `610F-611A` は `611C` が carry 失敗したときの local retry/rollback 分岐で、`player_index` 条件を見て同じ parent loop 内で `6157` 側へ戻している可能性が高い。
- `6105-610C` は loop completion 後の final clear + tail jump で、seeded candidate selection を終えた parent setup の出口とみるのが自然。

## Implication For Hidden Seed State
- `611C` 単体では `C20F + 16*player` の `FF` clear、`C73D..C744 = F0..F7` seed table 初期化、`RST $08(E=$15) -> 01B9 -> FF8C -> 5F07 -> C73D[index] -> 019E` までが見えていたが、`60E8-611B` を上位に置くとそれらは player-by-player に再生成される local seed pipeline としてまとまる。
- したがって `0198` backing state や `C2F6` hidden shadow state を探すときも、`611C` 単体 caller より `60E8-611B` の親文脈で `5F22/5E77/6157` を含めて追うほうが筋がよい。

## Next Steps
1. `5F22` の contract を切って、parent setup 開始時の visible/global side effect を確定する。
2. `5E77` を parent setup 文脈で再評価して、単なる refresh helper か seeded loop 前提の mode transition かを切り分ける。
3. `611C` local gate と `60E8` parent loop をまとめて `C2F6` hidden-state search line へ再接続する。
