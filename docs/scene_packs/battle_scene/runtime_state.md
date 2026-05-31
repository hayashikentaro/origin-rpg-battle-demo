# Battle Scene Runtime State

## Status

in_progress

## State Needed For One Concrete Replay

To simulate one concrete battle action, a scenario file or capture must supply:

- party actor records / HP/status fields
- enemy pages and present enemy groups
- selected command or item id (`CFF0`)
- source/class flag (`CFF1`) if needed
- target token (`CFF3`) or equivalent selected target
- `$C2A0` lane byte
- relevant RNG seed slots, especially seed05 for S00
- HP before at the resolved destination pointer

## Current Lane Model

The current target-lane working model is:

```txt
CF12 = CFF3 * 2
CFD0 = (([$C2A0] >> CF12) & 3) * $20
if CF12 == 08: CFD0 = 80
CF94 = CFD0
destination for S00 = $C207 + CF94
```

Default `$C2A0=E4` maps target tokens `00/01/02/03/04` to `CF94=00/20/40/60/80`.

## Implementation Relevance

- Replay code should accept explicit scenario state.
- Scenario state should follow `scenario_state_format.md`.
- Static ROM analysis can enumerate possible outcomes, but must not pretend to know the user's exact target/RNG state without inputs.
- Runtime state should be isolated from ROM constants.

## Open Questions

- Concrete `$C2A0` owner path in battle contexts.
- Entry-time RNG seed for each scenario.
- Which actor/enemy page owns each command route.
- Whether phase0A `CF94/CF95` writes can feed later S00 commands.
