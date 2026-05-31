# Text System Resource Offsets

## Status

working_model

## Common Text / Window Anchors

- `00:0E8B`: generic window overlay entry candidate.
- `00:0A44`: bordered rectangle builder.
- `00:070C`: text byte dispatcher.
- `00:1570`: `C785` text-buffer wrapper.
- `00:15B1`: fixed-width record to `C785` display-buffer helper.
- `00:15CE-15F1`: numeric formatter to `C785`.
- `0F:6640`: fixed-width text records used for item/name labels.
- `0F:7AA0`: dakuten compound table in the current model.
- `0F:7AC8`: handakuten compound table in the current model.

## Encoding Notes

- Bytes `80-FF` are direct font tile ids in the currently traced dispatcher model.
- Bytes `4E-75` use the dakuten compound table.
- Bytes `76-7F` use the handakuten compound table.
- `FF` appears as padding/terminator in fixed-width name records.

## Historical References

- `../../../analysis_updates/archive/frontier_history/saga2_1551_selector_terminal_report.md`
- `../../../analysis_updates/archive/frontier_history/saga2_name_table_caller_classification_report.md`
