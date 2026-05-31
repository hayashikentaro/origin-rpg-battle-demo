# Battle Scene Text And Window

## Status

working_model

## Current Model

The battle scene uses the common window and text pipeline rather than a battle-only text renderer.

Important anchors:

- `00:0E8B`: generic window overlay entry candidate.
- `00:0A44`: bordered rectangle builder.
- `00:070C`: text byte dispatcher.
- `00:1570`: `C785` text-buffer wrapper.
- `00:15B1`: fixed-width record to `C785` display-buffer helper.
- `00:15CE-15F1`: numeric formatter to `C785`.
- `0F:6640`: text records used for item/name labels.

## Encoding Notes

- Bytes `80-FF` are direct font tile ids in the currently traced dispatcher model.
- Bytes `4E-75` use the dakuten compound table at `0F:7AA0`.
- Bytes `76-7F` use the handakuten compound table at `0F:7AC8`.
- `FF` appears as padding/terminator in fixed-width name records.

## Implementation Relevance

- The renderer should support fixed-width 8-byte text records.
- Dakuten/handakuten should be composed through the traced compound tables, not treated as plain glyph bytes.
- Window frame and text rendering should be reusable across battle, menu, and map overlays.

## Open Questions

- Exact visible battle text stream ownership for every battle message.
- Full semantics of low control bytes dispatched by `00:070C`.
- Whether some battle messages bypass `C785` and dispatch directly from bank0F stream pointers.

## Historical References

- `../../../analysis_updates/in_progress/frontiers/saga2_1551_selector_terminal_report.md`
- `../../../analysis_updates/in_progress/frontiers/saga2_name_table_caller_classification_report.md`
