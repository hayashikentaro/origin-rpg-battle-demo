# Battle Scene Pack

## Goal

Reconstruct and eventually simulate the SaGa2 battle scene with traceable ROM-derived behavior.

## Read First

1. `needed_rom_offsets.md`
2. `graphics.md`
3. `text_window.md`
4. `command_flow.md`
5. `runtime_state.md`
6. `open_questions.md`

## Current Status

- ROM header/common structure: confirmed enough for offset work.
- Static enemy graphics preload/draw: working_model.
- Window/font/text pipeline: working_model.
- Battle command/effect execution: in_progress.
- Runtime-exact battle simulation: blocked on scenario state or a fuller no-emulator VM/state model.

## Do Not Read By Default

- `analysis_updates/archive/`
- unrelated map/music reports
- broad frontier reports unless linked from this pack

## Useful Entrypoints

- ROM binary package: `../../binary_analysis/saga2_rom_binary_analysis_package.md`
- Current scene artifacts: `generated_artifacts.md`
- Current blockers: `open_questions.md`

## Maintenance Rule

If battle-scene files, generated artifacts, offsets, or open questions change, update this scene pack and then refresh directory indexes:

```bash
python3 -B tools/update_directory_indexes.py
```
