# Live token fixtures

`tokens/spacing.css`, `tokens/typography.css` and `tokens/colors.css` are the live
Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System)
files of the same path, read via DesignSync `get_file` on 2026-10-02 and transcribed
to a local mirror by the coordinator; the files here are byte copies of that mirror.

They stand in for the removed sibling checkout (`dabbler-design-system-design/project/`)
that `test/tokens/dabbler_{geometry,type,palette}_test.dart` used to locate by walking
up the tree. A sibling checkout, when present, is still preferred.

Not replaced (still skipped, 8 tests): `design_source_export_transcription_test.dart`
(needs `tokens/figma/fig-tokens.css` and the Figma export) and
`design_source_token_declarations_test.dart` (scans every JSX/CSS file of the whole
project for `var(--…)` references). Neither can be reconstructed from the mirror.
