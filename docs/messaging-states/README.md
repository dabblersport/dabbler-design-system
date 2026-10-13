# Messaging states - design specs (KAN-503)

Four states that none of the 24 messaging frames cover, specified so the P2 and P3 chat UI is not built from an improvised sheet. Docs only: no Flutter code, no new component, no database access, no tokens or frames edited.

| File | State | Acceptance criterion |
|---|---|---|
| `01-report-reason-sheet.md` | report-reason sheet (ten `report_reason` values, confirm, submitted, failed) | AC1 |
| `02-unavailable-state.md` | deep link opened by a user outside the pilot | AC2 |
| `03-removed-state.md` | member whose next API call returns the typed reason `removed` | AC3 |
| `04-no-preview-inbox-row.md` | inbox row and skeleton with no message preview | AC4 |
| `05-rtl-and-copy-matrix.md` | every string in EN and AR with the strip-list check, RTL per state, the back-chevron requirement, the verification record | AC5, C4 |

No gallery page and no test were added, so C1 (`flutter analyze lib/src/messaging`) and C2 (`flutter test test/messaging`) ran on the existing code only.

## Status of what the specs rest on

| Item | Status |
|---|---|
| D1 messaging in MVP 1+, game chat first | **CEO-approved** 2026-10-13 |
| D13 CEO is the first moderation reviewer; no agent reads message content; no "24 hours" promise anywhere | **CEO-approved** 2026-10-13 |
| D18 per-user private Realtime topics with polling fallback; no typing indicator; no revocation window | **CEO-approved** 2026-10-13 |
| D19 non-pilot users: entry points hidden, deep link shows "unavailable" | **recommended, not approved** (spec `02`) |
| D7 roster read rule (active reads and sends; `left` reads to `left_at_seq`; `kicked` and other non-active read nothing) | **recommended, not approved** (spec `03`) |
| D16 previews: none in the MVP | **recommended, not approved** (spec `04`) |
| D8 receipts: sent and failed only, no ticks | **recommended, not approved** (nothing here draws a receipt) |
| D29 strip list | **recommended, not approved**; every string here passes it (`05`) |
| Dark mode | **@provisional**: the DS dark block is an inferred inversion, not signed off, and no messaging frame is dark. Specs are light and RTL only. |

## Sources

Report: `Dabbler-Alpha-Plan/kan496-messaging/KAN-496_CONSOLIDATED_REPORT.md` (sections 4 to 7), `CXO_496.md`, `CXO_SIGNOFF_496.md`, `CPO_496.md` 6.1, `CTO_496.md`, `LIVE_EVIDENCE.md`, `REMOTE_DESIGN_READ.md`, `COMMON_BRIEF_496.md`. Frames: `Dabbler/alpha-plan/design/Messaging.dc.html` and the PNGs `design/full/frames/Messaging.dc.html/01.png`, `23.png`, `24.png` (viewed; the others were read through the report's matrix, not re-viewed). DS: `lib/src/messaging/`, `lib/src/overlays/`, `lib/src/cards/`, `lib/src/forms/`, `lib/src/feedback/`, `lib/src/navigation/` at the `alpha-ds` base `393f9464`. Enum: `supabase/migrations/20260829080500_baseline_schema.sql` in the app repo worktree `kan-456-habu`, lines 327-338.

## How to read the specs

Each spec has: when the state shows, components (with the file each lives in; "new" is said out loud when something is proposed), anatomy with token names (no hex values), states, copy in EN and AR, accessibility, RTL. Token names are the DS's own (`DabblerSpacing.space4`, `DabblerType.title3`, `DabblerColors.textSecondary`, `DabblerRadius.xl`, `DabblerSizing.touchTargetMin`). Copy is proposed for `content-manager`. Numbers marked "derived" were computed from measured parts and not rendered.

## Reuse at a glance

| State | Existing components |
|---|---|
| Report sheet | `showDabblerSheet` (`overlays/sheet.dart`, `sheet_route.dart`), `DabblerSheetList` (`overlays/sheet_list.dart`), `DabblerInputRow.option` (`forms/input_row.dart`), `DabblerSheetActions` (`overlays/sheet_body.dart`), `DabblerButton` (`controls/button.dart`), `DabblerInlineMessage` (`feedback/inline_message.dart`), `DabblerEmptyState` (`cards/empty_state.dart`) |
| Unavailable, removed | `DabblerNavigationTopBar.titled` (`navigation/top_bar.dart`), `DabblerEmptyState` (`cards/empty_state.dart`), `DabblerButton` |
| No-preview row | `DabblerConversationRow` (`messaging/conversation_row.dart`), `DabblerBadge` (`surfaces/badge.dart`), `DabblerConversationAvatar` (`messaging/messaging_atoms.dart`), `DabblerSkeleton` (`feedback/skeleton.dart`) |

**One new thing is proposed, and it is not made here:** a `hidePreview` option on `DabblerConversationRow` (spec `04`, section 5). It needs the DS owner's go-ahead. Everything else is a composition of existing parts.

## Findings worth a decision

1. **The design source already holds a four-reason report sketch** (`Messaging.dc.html:738-810`) that submits on tap and promises review "within 24 hours". It conflicts with D13, D29 and the enum. Spec `01` replaces it; the source file was not touched.
2. **`DabblerConversationRow` with `preview: null` still draws an empty second line** (measured), so the existing widget cannot render the no-preview row on its own.
3. `DabblerInputRow.option` does not mark itself as a member of a mutually exclusive group for screen readers (`01` section 8). A DS follow-up question, not changed here.

## Verification statement

- **Run:** `flutter pub get`; C1 `flutter analyze lib/src/messaging`; C2 `flutter test test/messaging`; two throwaway widget tests (row heights at 360 wide in LTR and RTL; back glyph in `DabblerNavigationTopBar.titled` in LTR and RTL) and one icon-registry check, all deleted before the commit; a search of every migration in the app worktree for `report_reason` changes; a script search of the copy cells for the strip-list words. Results are in the commit report.
- **Not run:** the DS gallery in RTL or LTR, any simulator or device, any screenshot of the new states, text-scale 200 per cent, contrast measurement, dark mode. No database was touched, no network write was made, nothing was pushed.
- RTL back-chevron mirroring is **verified only for what two widget tests cover** (`DabblerConversationHeader`, `DabblerNavigationTopBar.titled`: glyph name and position). DS gallery mirroring remains **UNVERIFIED** (`05`, section 5).
