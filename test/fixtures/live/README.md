# Live token fixtures

`tokens/spacing.css`, `tokens/typography.css`, `tokens/colors.css` and
`tokens/figma/fig-tokens.css` stand for the live Claude Design project
4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System) files of the same path,
read via DesignSync `get_file` on 2026-10-02 and hand-transcribed to a local mirror by the
coordinator. The files here are byte copies of that mirror (`cmp` clean); see
"Provenance and limits" below for what that does and does not show.

They stand in for the removed sibling checkout (`dabbler-design-system-design/project/`)
that the token tests used to locate by walking up the tree. A sibling checkout, when
present, is still preferred.

## Which test files use them

| Test file | Fixture used | Status |
|---|---|---|
| `test/tokens/dabbler_geometry_test.dart` | `tokens/spacing.css` | runs |
| `test/tokens/dabbler_type_test.dart` | `tokens/typography.css` | runs |
| `test/tokens/dabbler_palette_test.dart` | `tokens/colors.css` | runs |
| `test/tokens/design_source_export_transcription_test.dart` | project root `test/fixtures/live` (`tokens/*.css` + `tokens/figma/fig-tokens.css`) | runs; 1 test skipped, see below |
| `test/tokens/design_source_token_declarations_test.dart` | none | all skipped, see below |

## What is still skipped, by test name

`design_source_export_transcription_test.dart` — 1 skipped test:
- "`--accent-indigo`, D-028's own case, is transcribed and stays so": the live mirror's
  `tokens/colors.css` does not declare `--accent-indigo`; only `tokens/figma/fig-tokens.css`
  does (a real D-028 shape, pinned as a gap in the first test of that file).

`design_source_token_declarations_test.dart` — every test in the file is skipped. It scans
every `*.jsx`, `*.d.ts` and `*.prompt.md` of the whole live project for `var(--…)` and bare
`--name` references and requires them all to be declared under `tokens/`. The mirror holds
only a subset of those files (the component `.jsx` files listed in the mirror's own
README, the messaging `.prompt.md` set, and the Figma-export components, which are
hand-transcribed like the rest); running it on a subset would pass or fail for the wrong reason. Missing:
the rest of the project's `*.jsx` / `*.d.ts` / `*.prompt.md` files.

## Reconciling the count

The earlier "26 skipped" came from 7 skip sites that each skip a whole group:
`dabbler_geometry_test` (5 tests), `dabbler_type_test` (3 groups = 10 tests),
`dabbler_palette_test` (1 group = 3 tests), `design_source_export_transcription_test`
(1 group = 4 tests) and `design_source_token_declarations_test` (1 group = 4 tests):
5 + 10 + 3 + 4 + 4 = 26. After these fixtures the first three sites run in full (18
tests), the export-transcription group runs with 1 skipped test, and the declarations
group keeps its 4 skipped: 5 skipped tests in total, not 8 (the earlier report said 8).

## Provenance and limits

Rendered against a hand-transcribed mirror of the live design-system export, with no pinned hash and no independent byte check. The mirror files are LLM transcriptions of DesignSync get_file output (read 2026-10-02); the token CSS fixtures in this directory were compared byte-for-byte with that mirror, which shows fixture == mirror and not mirror == live. Figma-export components were transcribed verbatim by hand. No pixel or browser comparison against live has been run; fidelity to live is unverified.

Line citations of the form `Name.jsx:NN` (also `.css`, `.prompt.md`, `.d.ts`) in `lib/` and
`test/` were checked on 2026-10-02, every one by eye, against that mirror (not against live):
793 citations found (665 `Name.ext:NN`, 56 `*.card.html:NN`, 72 bare same-file `:NN`
continuations); 444 correct as cited; 216 corrected (the value was on a different line of
the same mirror file); 1 claim removed (the quoted text is not in the mirror file); 132
labelled "unverified: file not mirrored" (`*.d.ts`, non-messaging `*.prompt.md` and every
`*.card.html` specimen). Citations without a line number, and line references to files that
are not design sources (`DECISIONS.md`, the Flutter SDK), were not counted.
