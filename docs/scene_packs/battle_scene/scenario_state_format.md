# Battle Scenario State Format

## Status

working_model

## Purpose

This format defines the smallest explicit input needed to replay or enumerate one battle-scene action without pretending that static ROM analysis knows the live runtime state.

Use this for no-emulator checks, unit tests, and implementation notes that need to separate:

- ROM constants and record surfaces
- chosen command / actor / target inputs
- RAM values that are normally produced by the battle engine
- expected observations from a concrete case

## File Placement

Recommended committed examples should live under a future scene-scoped data directory such as:

```txt
data/scene_packs/battle_scene/scenarios/
```

Generated or bulky captures should stay outside committed source unless promoted deliberately and referenced from `generated_artifacts.md`.

## JSON Shape

```json
{
  "schema": "saga2.battle_scene.scenario_state.v0",
  "status": "working_model",
  "case_id": "cure_book_seed05_unknown_target00",
  "source": {
    "rom": "SaGa 2 - Hihou Densetsu (J) (V1.1)",
    "notes": "Manual static-analysis scenario; not a live capture."
  },
  "command": {
    "selected_record_id_cff0": "0x24",
    "source_flag_cff1": "unknown",
    "record_offset": "0x032FA0",
    "record_bytes": "83 00 00 00 04 00 A3 33",
    "visible_label": "ケアルのしょ"
  },
  "targeting": {
    "target_token_cff3": "0x00",
    "lane_byte_c2a0": "0xE4",
    "resolved_cf94": "0x00",
    "destination_base": "0xC207",
    "destination_pointer": "0xC207"
  },
  "rng": {
    "seed05_entry": "unknown",
    "rng_table_bank_addr": "0F:4000",
    "rng_table_file_offset": "0x03C000"
  },
  "state_before": {
    "destination_hp": "unknown",
    "party_actor_records": "unknown",
    "enemy_pages": "unknown"
  },
  "expected_effect": {
    "route": "S00",
    "amount_expression": "data_rng[(seed05 + 1) & 0xFF] + 4",
    "write": "uint16(destination_pointer) += amount"
  },
  "open_questions": [
    "Confirm CFF1 semantics.",
    "Prove visible command label to CFF0 join.",
    "Supply concrete seed05 and destination HP from a real or modeled state."
  ]
}
```

## Field Rules

- Hex byte fields should use `0xNN`.
- Hex word fields should use `0xNNNN`.
- ROM file offsets should use `0xNNNNNN`.
- Banked ROM addresses should use `BB:AAAA`.
- Hex digits should be uppercase.
- Unknown runtime values must be the string `unknown`, not guessed zeroes.
- `status` must be one of `confirmed`, `working_model`, `in_progress`, `unknown`, or `rejected`.
- `record_offset` is a ROM file offset; `record_bytes` is the raw command/action record.
- `visible_label` is allowed only when the text-table join is documented or the value is explicitly marked as a display-side hypothesis.

Validate committed fixtures with:

```bash
python3 -B tools/validate_battle_scenarios.py
```

Evaluate the current S00 working fixture against the committed ROM hexdump with:

```bash
python3 -B tools/evaluate_battle_scenario.py
```

## Minimum Viable Scenario

A replay/enumeration tool can start with:

- `command.selected_record_id_cff0`
- `command.record_bytes`
- `targeting.target_token_cff3`
- `targeting.lane_byte_c2a0`
- `rng.seed05_entry`
- `state_before.destination_hp`

If `seed05_entry` or `destination_hp` is `unknown`, the tool should enumerate possible results or report that exact replay is not available.

## Cure Book Working Case

Current static-analysis case:

- `CFF0=0x24`
- command record at `0x032FA0`
- raw record `83 00 00 00 04 00 A3 33`
- route `S00`
- `CF24=0x04`
- `CF25=0x00`
- amount expression `data_rng[(seed05 + 1) & 0xFF] + 4`

This is enough to test the effect formula once `seed05_entry`, target lane, and destination HP are supplied.

A matching small fixture is stored at:

- `scenarios/cure_book_working_model.json`

## Related Files

- `command_flow.md`
- `runtime_state.md`
- `needed_rom_offsets.md`
- `open_questions.md`
