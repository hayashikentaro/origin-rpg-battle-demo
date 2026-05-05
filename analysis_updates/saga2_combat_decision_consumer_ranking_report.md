# Saga2 Combat Decision Consumer Ranking Report

## 要点

- current best reading では、`combatDecision` の first consumer は **next local phase selector** より **candidate accept/reject branch** に一段重みを置くのが最も自然である
- 理由は、`combatDecision` の current shape 自体が already
  - blocked ordinal
  - zero-fast-path privilege
  - consumable nonzero class
  という **accept policy 寄りの semantics** を持っているからである
- したがって first consumer は actor-local opener の中でも、「この candidate を通すか」「strict path に乗せるか」「shortcut へ進めるか」を決める narrow branch にあるとみるのが safest である

## 1. Two Close Readings

ここまでの consumer 仮説には、かなり近い 2 本がある。

1. next local phase selector  
   次に進む局所段階を決める
2. candidate accept/reject branch  
   current candidate entry を通すか、blocked とするか、shortcut へ乗せるかを決める

どちらも actor-local opener 内の narrow branch だが、
`combatDecision` の current shape を考えると後者に少し重みが乗る。

## 2. Why Accept/Reject Gets Priority

current `combatDecision` はすでに

- `0E/0F` family
- `qualifier == 1` blocked ordinal
- `0F + 0` zero-fast-path privilege
- `2+` consumable nonzero class

まで持っている。

これは phase 名よりむしろ、

- allow / block
- strict / shortcut
- consumable / non-consumable

といった **candidate policy** の語彙で理解しやすい。

したがって first consumer も、
wide phase へ進む selector というより
**candidate policy を確定する branch**
に置くほうが自然になる。

## 3. Why Phase Selector Still Remains

もちろん second line としては、
その accept/reject 結果がすぐ

- next local phase
- next local sub-path

へ変換される可能性も高い。

つまり safest ranking は:

1. candidate accept/reject branch
2. next local phase selector

であり、完全に別物として切るより
**accept policy が phase 進行に投影される**
とみるのが実装上も扱いやすい。

## 4. Practical Consumer Shape

現時点では次のような consumer を first-line に置くのが自然である。

```ts
function consumeCombatDecisionInLocalOpener(
  playerIndex: number,
  localPath: number,
  candidate: Candidate | null,
  combatDecision: CombatDecision
): {
  accepted: boolean
  branch: number
}
```

ここで `accepted` が先に決まり、
`branch` はその結果を local phase へ写した second output とみるのが current best reading である。

## implication for step 6

この整理を採ると、step 6 で次に battle 本線から取りたいものは

- `combatDecision` がどの wide page を書くか

より、

- `combatDecision` が current candidate / local path を accept するか reject するか
- その結果どの narrow branch に落ちるか

になる。

つまり next frontier は
**actor-local opener の accept-policy branch**
を押さえることにかなり収束している。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `combatDecision` first consumer が accept/reject を first output に持つか
2. その結果が直ちに next local phase へ写るか
3. `07/08` candidate-selection path と special-candidate family gate が同じ accept branch に流れ込むか

ここが取れれば、`combatDecision` は
source semantics だけでなく
**accept-policy consumer**
までかなり具体化できる。
