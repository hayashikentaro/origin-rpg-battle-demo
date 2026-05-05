# SaGa2 `6157` Entry Preexisting-vs-Constructed Report

## Summary
- `6157` entry を詰めるうえで重要なのは、**entry 時点で既に存在する入力** と **`6157` の中で初めて構築される state** を分けることである。
- 現時点で最も自然なのは、entry 時点で既にあるのは **current player (`C709`)** と **`611C` が確定した local success-side state** だけであり、`C200/C7EE/D400/D500` は `6157` がこれから構築・更新する battle-side staging 側に置く読みである。
- したがって次の consumer 探索では、「`6157` が入った瞬間に何が手元にあるか」を narrow に持つほうが false positive を減らせる。

## 1. Preexisting At Entry

親ループ:

```asm
60F0: LD ($C709),A
60F3: CALL $611C
60F6: JR NC,$610F
60F8: CALL $6157
```

ここから `6157` entry で事前に成立しているとみてよいのは:

1. `C709` が current player を指す  
2. `611C` が success を返している  
3. その success を支える local success-side state が直前に確定している  

この 3 点である。

## 2. Constructed Inside `6157`

一方 `6157` の本体では:

```asm
615A: HL = C200 + 16*player
6160: DE = C7EE
6165: CALL $0080
...
6175: HL = D400
...
6180: HL = D500
```

と、`C200/C7EE/D400/D500` を明示的に触り始める。

この形は、これらが entry 入力というより
**`6157` が受け取った local success state を battle-side へ展開するための staging/constructed state**
と読むのが自然である。

## 3. Why This Matters For Porting

移植で先に必要なのは:

```ts
applyFromLocalSuccess(player, localSuccessState)
```

という narrow contract であって、

```ts
applyUsingPrepopulatedBattlePages(...)
```

ではない。

つまり `6157` の page side effect 全体を再現する前に、
**entry で何を入力として受けているか** を確定するだけで core API はかなり前に進む。

## 4. Updated Search Focus

次に確認すべきことは次の順になる。

1. `611C` success-side local state の最小形  
2. `6157` entry でそれをどう前提にしているか  
3. そのあとに `C200/C7EE/D400/D500` をどう構築するか  

## Implication
- `C200/C7EE/D400/D500` は entry 入力より constructed/staging state とみるのが自然
- `6157` entry 契約はかなり narrow に持てる
- 次の主戦場は、entry 前にすでに存在する local success-side state の形そのものである
