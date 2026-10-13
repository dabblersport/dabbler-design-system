# 01 - Report-reason sheet (KAN-503, AC1)

Status: design spec, light and RTL. Dark is `@provisional` (see README). Closes the gap that frame 22 (Block only) left: no frame shows a reason picker over the `report_reason` enum, a confirm step, or a submitted or failed state.

Rulings this spec follows: **D13** (CEO is the first moderation reviewer, no agent reads content, no response-time promise anywhere). Recommendation, **not approved**: **D29** strip list (nothing from it appears in this sheet).

## 0. Prior art found in the design source (read this before reusing it)

`Messaging.dc.html` lines 738-810 hold an interactive `report` sheet that is not one of the 24 numbered frames: four reasons ("Harassment or abuse", "Spam or scam", "Fake or no-show game", "Something else"), each of which submits on tap with no confirm step, then a "Report sent" sheet that promises review "within 24 hours" and offers "Also block this player". **That sketch must not be built from:** its four reasons are not the ten `report_reason` enum values ("Fake or no-show game" has no enum value), it has no confirm, no failed state and no AR copy, and its "24 hours" line is stripped by D13 and D29. This spec replaces it. The source file is read-only for this ticket and was not edited.

## 1. What the sheet is

A bottom sheet opened from a message's action sheet ("Report message", `Messaging.dc.html:757`), owner of the target message id. The reporter picks **exactly one** of ten reasons, then confirms. Nothing is sent on a row tap.

Entry is gated by the CPO's canonical flag `enableMessagingReporting` (flags stay false; not this ticket's files).

## 2. The ten reasons (AC1)

Source of truth: `CREATE TYPE "public"."report_reason" AS ENUM (...)` in `supabase/migrations/20260829080500_baseline_schema.sql` lines 327-338 of the app repo (worktree `kan-456-habu`). All migrations in that folder were searched for `ALTER TYPE ... report_reason` / `ADD VALUE`: **none found** (the only other `report_reason` line is `OWNER TO "postgres"`). The count is **ten**. No reason is added, removed or renamed. Row order below is the enum order, with `other` last as the enum has it.

The labels are neutral wording derived from each enum value. They are **proposed**; `content-manager` owns the final copy. `abuse` and `harassment` are deliberately worded apart so the two rows cannot be mistaken for each other.

| # | enum value (sent to the API, never shown) | EN label | AR label |
|---|---|---|---|
| 1 | `spam` | Spam | محتوى مزعج (سبام) |
| 2 | `abuse` | Abusive language | ألفاظ مسيئة |
| 3 | `hate` | Hate speech | خطاب كراهية |
| 4 | `harassment` | Harassment or bullying | مضايقة أو تنمر |
| 5 | `nudity` | Nudity or sexual content | عُري أو محتوى جنسي |
| 6 | `illegal` | Illegal activity | نشاط غير قانوني |
| 7 | `danger` | Threat or dangerous behaviour | تهديد أو سلوك خطير |
| 8 | `scam` | Scam or fraud | احتيال |
| 9 | `impersonation` | Pretending to be someone else | انتحال هوية شخص آخر |
| 10 | `other` | Something else | سبب آخر |

The submitted value is the enum string, taken from the row's data and **never parsed back from the label**. The label is display only.

## 3. No free-text field (decision, stated)

**Not included.** Reasons:

1. **D13 / D21 (message content stays out of Supabase).** A free-text box invites the reporter to paste the offending message into the report, which is the copy of message text into `moderation_reports` that the recommended `content_snapshot = NULL` rule exists to prevent. The enum alone is sufficient for the CEO-as-first-reviewer flow.
2. The enum is the typed contract the CPO and CTO reports name ("reasons enum `report_reason` (10 values) feeds the report sheet", CPO 6.1). A single optional text field would need a column or a convention nobody has specified. **Not verified:** whether `moderation_reports` has a details column; the database was not read (not allowed for this ticket).
3. One decision per sheet is the shortest path for a person who is upset.

The CXO's earlier sketch ("reason list, optional details, confirm, done") is therefore **narrowed**. If the CEO wants details later, it is a separate, explicit addition: a multi-line `DabblerTextField` under the list, with a D21 ruling first. Nothing in this spec blocks it.

## 4. Components (all exist, verified in `lib/src`)

| Part | Component | File |
|---|---|---|
| Sheet frame (handle, title, close, pinned footer) | `showDabblerSheet` / `DabblerSheet`, `detent: DabblerSheetDetent.content` | `lib/src/overlays/sheet.dart`, `sheet_route.dart`, `sheet_detent.dart` |
| Scrolling reason list (bounded) | `DabblerSheetList` | `lib/src/overlays/sheet_list.dart` |
| One reason row (single-select, tick when chosen) | `DabblerInputRow.option(...)` | `lib/src/forms/input_row.dart` (+ `input_row_option.dart`) |
| Confirm and Cancel stack | `DabblerSheetActions` + two `DabblerButton` | `lib/src/overlays/sheet_body.dart`, `lib/src/controls/button.dart` |
| Failed message | `DabblerInlineMessage` (tone `error`) | `lib/src/feedback/inline_message.dart` |
| Submitted body | `DabblerEmptyState` (`size: plain`) | `lib/src/cards/empty_state.dart` |

**Nothing new is proposed.** This is a composition of existing parts; it is the "action-sheet / report recipe" that the CPO plan counts at about 4 h, and it stays an app composition (design class D), not a DS addition.

## 5. Anatomy (top to bottom)

```
showDabblerSheet<void>(
  context: context,
  title: <sheet title>,                       // DabblerType.title3 (20/25), display face
  detent: DabblerSheetDetent.content,         // as tall as content, cap 0.8 of viewport
  showCloseButton: true,
  closeLabel: <close label>, scrimLabel: <dismiss label>,
  dismissible: !submitting,
  builder: (_) => Column(
    message line,                             // DabblerType.footnote, colors.textSecondary
    SizedBox(height: DabblerSpacing.space4),  // 12
    DabblerSheetList(itemCount: 10, itemBuilder: DabblerInputRow.option(...)),
    failed ? DabblerInlineMessage(<failed copy>) : nothing,
  ),
  footerBuilder: (_) => DabblerSheetActions(children: [
    DabblerButton(label: <send>, size: DabblerButtonSize.block, tone: DabblerButtonTone.primary),
    DabblerButton(label: <cancel>, size: DabblerButtonSize.block, tone: DabblerButtonTone.text),
  ]),
)
```

| Element | Spec | Token / constant |
|---|---|---|
| Panel | top corners 18 | `DabblerRadius.xl` (sheet_panel.dart) |
| Body inset | 18 on every side | `DabblerSpacing.space6` (sheet_body.dart) |
| Title | 20/25, weight 400, display face (Gloock / Wingx) | `DabblerType.title3`, `colors.textPrimary` |
| Message line | 13/18, regular | `DabblerType.footnote`, `colors.textSecondary` |
| Gap message to list | 12 | `DabblerSpacing.space4` |
| Reason row | content min 52, padding 9 block / 3 inline, plus 1 hairline = **71 tall**; last row `showDivider: false` | `DabblerInputRow.optionMinHeight`, `optionPadding`, `colors.bgTertiary` hairline |
| Reason title | 16/22, regular; semibold when selected | `DabblerType.bodyRelaxed`, `colors.textPrimary` |
| Selected mark | `tick-circle` bold, 22, at the inline end, 12 after the title | `DabblerInputRow.selectedIconName`, `optionTickSize`, `colors.brandPrimary` |
| List height | at most half the viewport; ten rows (709) scroll, the cut-off row shows there is more | `DabblerSheetList.defaultMaxHeightFraction` 0.5 |
| Failed message | 13/18 medium, error ink, bold `danger` glyph 15, 6 gap | `DabblerInlineMessage`, `DabblerSizing.iconInline`, `DabblerSpacing.iconGap` |
| Footer gap list to buttons | 12 top, 9 between buttons | `DabblerSheetActions` (`space4`, `space3`) |
| Send button | primary, block, 45 tall, radius 9, 15/600 label | `DabblerButtonSize.block`, `DabblerSizing.touchTargetMin` |
| Cancel button | text tone, block. Allowed because it is the secondary half of a pair (D-023(c)); never alone | `DabblerButtonTone.text` |
| Submitted glyph | `tick-circle`, 42, `textTertiary`, no well | `DabblerEmptyStateSize.plain` |

No hex values appear in this spec. Colours are `DabblerColors` roles resolved from the active theme.

## 6. States

| State | Rows | Send | Cancel / close / scrim | Other |
|---|---|---|---|---|
| **Default** | none selected, all regular weight | **disabled** | enabled | message line shown |
| **Row pressed / focused** | shared press and focus ring (`DabblerFocusRing`) | unchanged | enabled | |
| **Selected** | chosen row semibold + `tick-circle`; picking another row moves the mark (single-select; tapping the chosen row does not deselect) | **enabled** | enabled | |
| **Submitting** | inert (`onTap: null`), selection kept | `loading: true`, label = sending copy | **inert**, sheet `dismissible: false` | the request is in flight; no double submit |
| **Submitted** | list replaced by the plain empty state (glyph, title, one line) | footer becomes one **Done** button (primary, block) | close and scrim enabled | no response time, no "also block" action |
| **Failed** | list stays, **selection kept** | enabled, label = try-again copy | enabled | `DabblerInlineMessage` error above the footer, announced as a live region |

Submitting must end in Submitted or Failed; the app owns the timeout (not designed here).

## 7. Copy (EN / AR)

All copy is proposed, for `content-manager` to confirm. Every string is neutral, makes no promise of a response time, and none is in the D29 strip list (checked in `05-rtl-and-copy-matrix.md`).

| Key | EN | AR |
|---|---|---|
| `report.title` | Report message | الإبلاغ عن الرسالة |
| `report.prompt` | Choose the reason that fits best. | اختر السبب الأنسب. |
| `report.send` | Send report | إرسال البلاغ |
| `report.cancel` | Cancel | إلغاء |
| `report.sending` | Sending... | جارٍ الإرسال... |
| `report.close` (close glyph semantics) | Close | إغلاق |
| `report.dismiss` (scrim semantics) | Dismiss | تجاهل |
| `report.submitted.title` | Report sent | تم إرسال البلاغ |
| `report.submitted.body` | Thank you for letting us know. | شكرًا لإبلاغنا. |
| `report.done` | Done | تم |
| `report.failed` | Your report was not sent. Try again. | لم يتم إرسال بلاغك. حاول مرة أخرى. |
| `report.retry` (Send label after a failure) | Try again | حاول مرة أخرى |

Deliberately absent: "confidential", "we will not tell them who reported", any review time, any promise that action will be taken. None of those is a ruling; the design source's versions are not carried over.

## 8. Accessibility

- Every row is one button with `selected` set (`DabblerInputRow.option` sets `Semantics(button, selected)`). Its accessible name is the label. **Recommendation:** pass `semanticLabel` as "<label>, <n> of 10" in the app string table if the platform does not announce position; the DS does not set `inMutuallyExclusiveGroup` on this row, so the list is not announced as a radio group. Not changed here (DS files are read-only). Flagged as a DS follow-up question, not assumed.
- Targets: reason rows 71 tall (floor 45), buttons 45 tall (`DabblerSizing.touchTargetMin`), close glyph target 45.
- Meaning is never colour alone: the chosen row is semibold plus a glyph, not just brand colour.
- Send disabled: the button is inert and removed from the focus order (`DabblerButton` doc: a disabled button leaves the traversal order). The prompt line says what to do, so a disabled button is not a mystery.
- Failure is a live region (`DabblerInlineMessage` wraps `Semantics(liveRegion:)` for an interrupting tone); submitting announces `report.sending` through the button's loading label.
- Reduced motion: nothing is added; the existing components' own motion rules apply.
- Text scale 200 per cent: rows grow (min height, not fixed); long Arabic labels wrap onto two lines inside the 52-minimum row. **Not run on a device in this ticket.**
- Contrast of secondary text on the sheet surface is **not measured** (open item shared with the whole messaging kit).

## 9. RTL

Everything is directional; the part adds no left or right paint (`DabblerSheetList`: "Rows lay out in the ambient direction").

- Title and prompt: start-aligned, so right-aligned in Arabic. Title swaps to Wingx, text to Meral Sans; Arabic size is the Latin size less 0.9 and leading comes from the Arabic columns (title3 25, bodyRelaxed 24, footnote 18).
- Reason row: label at the inline start (right), the selected `tick-circle` at the inline end (left). The tick is not a directional glyph and is not mirrored.
- Close button: at the header's inline end (left in Arabic), as the sheet lays it out. Not a back arrow, so no glyph swap.
- Buttons: full width, labels centred, order unchanged (Send above Cancel).
- Failed message: glyph at the inline start (right), text start-aligned.
- Submitted: centred, direction-neutral.
- Arabic labels keep Arabic punctuation inside the label; the `...` in `report.sending` is the same character in both scripts. Western numerals only (no numerals are used here).
- Enum values stay Latin and are never rendered, so there is no bidi mixing in the sheet.
