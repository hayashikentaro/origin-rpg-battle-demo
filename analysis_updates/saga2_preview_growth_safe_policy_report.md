# saga2 preview growth-safe policy

## Summary

- preview matrix が `ATK / ATKX / ATKS / DEF / PTR / ABLX0 / ABL...` まで広がったことで、front 側も **growth-safe** な参照方針が必要になった
- current safest policy は、preview を **fixed index** で読むのではなく **stable label** で引くことである
- これにより matrix coverage を増やしても `ATK` / `PTR` などの canonical probe 表示が壊れない

## Why fixed index became unsafe

preview matrix が小さい段階では、

- index `0` = `ATK`
- index `2` = `PTR`

のような仮定でも動いていた。

しかし matrix が

- `ATKX`
- `ATKS`
- `ABLX0`

のような probe を含むようになると、index 依存は **coverage expansion に弱い UI contract** になる。

つまり growth のたびに

- displayed probe
- meaning of the slot
- UI/debug expectation

がズレる危険がある。

## Current safest policy

したがって current front policy は、

- canonical previews (`ATK`, `PTR`, ほか必要なもの)
- optional expansion previews (`ATKX`, `ATKS`, `ABLX0`, `ABL...`)

を **label-based lookup** で分けて扱うのが safest である。

この policy なら、

- matrix ordering を拡張しても
- canonical probe display は壊れず
- expansion probe はそのまま log/matrix 側へ足せる

という形で front contract を保てる。

## Practical consequence

current preview growth-safe policy を一言で書くなら、

**matrix may grow by inserting new probes, but canonical display points must be selected by stable labels, not by positional indices.**

である。

## Why this matches the wider contract

これは単なる UI hygiene ではない。  
current frontier では preview matrix 自体が

- deferred-binding policy
- semantic debug ordering
- operational coverage surface

の一部になっている。

したがって front 側の参照方法も、coverage widening を前提に **contract-preserving** である必要がある。
