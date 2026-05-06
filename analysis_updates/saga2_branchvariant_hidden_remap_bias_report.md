# saga2 branchVariant hidden remap bias

## Summary

- `41E3-41E9` を **single-side carry candidate cluster** とみる current best reading では、次の decisive point はこの carry に hidden remap が挟まるかどうかである
- current frontier では、**large hidden remap を挟むより remap-free carry を仮定するほうが自然** だ、という bias まで上がっている
- ただしこれは still bias であり、numeric binding lock を許す direct proof ではない

## Why hidden remap matters

もし `41E3-41E9` の間に hidden remap が強く入るなら、

- `41E3-41E5` で見えている retained refinement side
- `41E7-41E9` で見えている same-side visibility

のあいだに、未観測の再符号化段があることになる。

その場合、current frontier で強く見えている side-level correspondence は

- true carry
ではなく
- remap 後 coincidence

の可能性を残す。

逆に hidden remap が薄いなら、`41E3-41E9` は **single-side carry cluster** としてかなり強く読める。

## Current safest bias

current best reading で remap-free bias が強い理由は次の通りである。

1. `41E3-41E5` は already **retained refinement handoff edge** として読めている  
2. `41E6` は **reopening / consume halo entry** であり、新しい semantic axis を強く生成する地点としては読みにくい  
3. `41E7-41E9` は **first effective same-side visibility slot** であり、ここで first-line から second-line へ visible になるのは pair alignment そのものと読むのが自然  

この 3 点を重ねると、chain の中で

- large hidden remap が入る

より、

- retained side がそのまま second-line visibility へ carry される

と読むほうが current frontier でははるかに自然である。

## Safe wording

したがって current safest wording は、

- `41E3-41E9` = single-side carry candidate cluster  
- same cluster では **hidden remap より remap-free carry に bias**  
- ただし raw `0/1` binding lock にはまだ stronger local evidence が必要

である。

## Practical consequence

今後 `branchVariant` の numeric binding を詰めるなら、次に必要なのは semantic polarity の再定義ではない。  
必要なのは、

- `41E3-41E9` で remap-free carry をより強く言えるか
- その carry が raw `0/1` と named side を stronger に結ぶか

の 2 点である。

つまり current best policy では、

- **same-side visibility** は `41E7-41E9`
- **single-side carry candidate cluster** は `41E3-41E9`
- **remap-free carry bias** はこの chain 全体の current safest interpretation

と分けて持つのがよい。
