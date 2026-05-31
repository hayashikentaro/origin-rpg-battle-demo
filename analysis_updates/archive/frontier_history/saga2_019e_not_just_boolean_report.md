# SaGa2 `019E` Not-Just-Boolean Report

## Summary
- `019E` の immediate target を success-side short state とみるなら、現時点では **pure boolean success flag だけ** と考えるより、`meaning-bearing byte` を含む state とみるほうが自然である。
- 理由は、`019E` が入力として受けるのが単なる成否ではなく **resolved seed byte** だからである。
- したがって次に優先して観測すべきなのは、`success=true/false` だけの flag より、**adopted outcome byte** か **marker + byte** の形である。

## 1. Why Pure Boolean Is Too Weak

`611C` 後半は:

```asm
614A: CALL $5F07
614D: LD HL,$C73D
6150: RST $00
6151: LD A,(HL)
6152: CALL $019E
6155: SCF
6156: RET
```

ここで `019E` に渡るのは、
`C73D[index]` から引いた **resolved seed byte** である。

もし `019E` の immediate target が
`success / fail` だけの boolean flag なら、
この 1 byte の内容を受け取る意味が薄い。

そのため、
`019E` は success を立てるだけでなく、
**その byte に由来する何かを local state へ残す**
と考えるほうが自然になる。

## 2. Better Current Shapes

いま自然な候補は次の 2 つ。

1. adopted outcome byte  
   resolved seed から導かれた local outcome 値を 1 byte で保持
2. marker + outcome byte  
   success/adopted を示す marker と outcome 値の short pair

逆に優先度を下げてよいもの:

1. pure boolean success flag only
2. raw seed cache only
3. big struct / apply-side record

## 3. Why This Still Fits Previous Conclusions

この整理は、既報と矛盾しない。

- `019E` は inner core の post-resolve / pre-apply window にある
- immediate target は big struct ではなく short settled-state family
- `marker` と `outcome` は success-side state の下位バリエーション

ここに今回さらに足せるのは、
**`outcome` 成分のほうが pure boolean より重い**
という点である。

## 4. Updated Search Priority

次に `019E` の local hidden state を観測するときの優先順位:

1. single adopted/resolved outcome byte
2. success marker + outcome byte
3. marker only

## Implication
- `019E` target は pure success flag だけより meaning-bearing byte を含む形が自然
- 次の主戦場は `outcome byte` を first line、`marker + byte` を second line にした short local state 観測である
