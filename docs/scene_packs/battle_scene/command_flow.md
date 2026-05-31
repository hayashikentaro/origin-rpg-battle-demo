# Battle Scene Command Flow

## Status

in_progress

## Current Model

The current implementation-facing command/effect work should be driven by ROM record surfaces and battle descriptor paths, not invented action scripts.

Important surfaces:

- `0C:6F80`: item/action records, 8 bytes each.
- `0F:6640`: display/name text records.
- `0F:4000`: `data_rng` table.
- `CFF0`: selected item/action record id in the current working model.
- `CFF1`: source/class or consume-policy flag, still unresolved.
- `CF23`: phase05 action selector from `record[3]`.
- `CF24`: secondary field from `record[4]`.
- `CF25`: bound/value field currently bridged from `record[5]` for S00.

## S00 Working Model

For S00 target `0C:658A`:

```txt
phase05 record[4] -> CF24
0C:65EE advances record cursor
record[5] -> CF25
0C:65F5: CFB5/CFB6 = rng_slot_05(CF25) + CF24
0C:65BA: CF32/CF33 = $C207 + CF94
0C:65C2: ptr(CF32/CF33) += CFB5/CFB6
```

For `ケアルのしょ`:

- `CFF0=24`
- record `0C:70A0 = 83 00 00 00 04 00 A3 33`
- expected `CF23=00`, `CF24=04`, `CF25=00`
- amount is raw `data_rng[(seed05 + 1) & FF] + 4`

## No-Emulator Approach

When runtime capture is unavailable, treat these as scenario inputs:

- selected `CFF0`
- target token / `CFF3`
- `$C2A0`
- seed05
- HP before at the destination

Then enumerate outcomes rather than claiming a live playthrough.

## Open Questions

- Final `CFF1` semantics.
- Visible command label to selected `CFF0` runtime join.
- Normal attack entry and `S31 -> 0C:50CC` interpretation.
- Concrete branch choices for the phase descriptor VM.

## Historical References

- `../../../analysis_updates/in_progress/frontiers/saga2_battle_action_class_prepass_report.md`
- `../../../analysis_updates/in_progress/normal_attack/saga2_normal_attack_entry_gap_report.md`
- `../../../analysis_updates/confirmed/descriptors/saga2_battle_descriptor_field_mapping_report.md`
