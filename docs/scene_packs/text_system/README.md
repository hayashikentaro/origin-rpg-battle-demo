# Text System Pack

## Status

working_model

## Purpose

Keep text encoding, font, dakuten/handakuten composition, and window text rendering separate from battle command execution.

## Read First

1. `open_questions.md`
2. `resource_offsets.md`
3. `../battle_scene/text_window.md`

## Current Model

- `80-FF` direct font tile ids are used for many text glyphs.
- `4E-75` dakuten compound table is currently modeled at `0F:7AA0`.
- `76-7F` handakuten compound table is currently modeled at `0F:7AC8`.
- `FF` is used as padding/terminator in fixed-width records.
- Current implementation-facing offsets are summarized in `resource_offsets.md`.

## Implementation Relevance

- Text renderers should implement custom SaGa2 text decoding separately from battle command logic.
- Battle-scene text should reference this pack once text-specific facts are promoted.
