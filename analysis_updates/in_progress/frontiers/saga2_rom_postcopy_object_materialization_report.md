# SaGa2 ROM Post-Copy Object Materialization Report

Date: 2026-05-06

## Summary

Current strongest reading is that `338D` opens a preload-backed path with two distinct stages:

1. `363F -> 00AC` stages graphics-like payload into `$8100-$86FF`
2. `339A+` continues by materializing object-facing records into `DE = $C600`

This matters because it sharpens the remaining image-extraction gap:

> the missing proof is not about post-copy object formatting, but about which source payload the preload selector feeds into the copy bridge before object materialization resumes

## Key local split at `338D`

From bank00 bytes:

```text
338A: 11 00 c6 LD DE,$C600
338D: fa 52 c4 LD A,($C452)
3390: b7       OR A
3391: ca 3d 34 JP Z,$343D
3394: cd 3f 36 CALL $363F
3397: 11 00 c6 LD DE,$C600
339A: 2a       LD A,(HL+)
339B: fe ff    CP $FF
339D: ca 3d 34 JP Z,$343D
...
```

Two important details:

- `DE` is set to `$C600` both before and immediately after `CALL $363F`
- this means the `$8100` graphics staging destination used inside `363F` is a temporary copy destination, not the final object-facing output surface for the surrounding routine

## What `339A+` looks like

Immediately after the copy bridge, the code resumes reading from `HL` and writing structured bytes to `DE=$C600`.

Representative snippets:

```text
33A0: fe 80    CP $80
33A2: 20 12    JR NZ,$+18
33A4: 2a       LD A,(HL+)
33A5: 4f       LD C,A
33A6: cd 8c 01 CALL $018C
...
33B2: 79       LD A,C
33B3: 12       LD (DE),A
...
33B6: d5       PUSH DE
33B7: e6 1f    AND $1F
33B9: 5f       LD E,A
33BA: cd 92 01 CALL $0192
...
33C0: 2a       LD A,(HL+)
33C1: 47       LD B,A
33C2: cb 37    SWAP A
33C4: e6 0f    AND $0F
...
```

This strongly suggests:

- `339A+` is parsing object-stream flavored records
- it uses the already-established graphics staging as background state
- it is not itself the place where preload byte `0x25` is decoded into a graphics payload

## Strongest practical conclusion

The preload-backed path should now be split like this:

```text
header preload metadata (`0x25`)
  -> pre-copy selector stage (still unresolved)
  -> 363F/00AC graphics staging into $8100-$86FF
  -> 339A+ object-facing materialization into $C600
```

This is useful because it removes one more false target:

- `339A+` is probably **not** where the exact preload selector-to-payload mapping is decided
- it is downstream consumer/materializer logic that resumes after staging

## Best current wording

Current safest wording is:

> `363F` is the graphics staging bridge, while `339A+` is the post-copy object materialization stage. The unresolved image-extraction gap therefore remains on the pre-copy selector side, not in the post-copy record formatter.

## Practical next target

The narrowest next proof target is still:

> identify how preload selector byte `07:63BE = 0x25` is reduced into the exact source-side payload that `363F -> 00AC` stages at `$8100-$86FF`

The post-copy path no longer needs to be treated as part of that selector gap.
