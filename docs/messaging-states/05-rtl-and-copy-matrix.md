# 05 - RTL and copy matrix (KAN-503, AC5 / C4)

Status: light and RTL. Dark is `@provisional` (see README). All copy is **proposed**; `content-manager` owns final wording.

## 1. The D29 strip list (recommended, NOT yet CEO-approved)

D29 says the following design copy is stripped from what ships: any 7-day retention line; the refund notice; every price or settlement line; "within 24 hours" (and any response-time promise, D13, approved); read or delivered ticks; the typing bubble; online presence; message search; and the block-sheet line "or see the games you organise".

How each string below was checked: (a) it is read against every item of that list; (b) the EN and AR cells of the table were extracted by script and searched for the English words price, refund, 7-day, 24 hours, online, typing, receipt, tick, delivered, search and the Arabic stems for price (سعر), refund (استرداد), online (متصل), typing (يكتب), read/seen (قرأ, شوهد), delivered (تسليم), search (بحث), "24" and "٢٤". The result is in the README verification statement. The column below records the outcome per string.

## 2. Every string of the four states (29)

State codes: R = report-reason sheet (`01`), U = unavailable (`02`), X = removed (`03`), I = inbox no-preview row (`04`).

| State | Key | EN | AR | D29 check |
|---|---|---|---|---|
| R | `report.title` | Report message | الإبلاغ عن الرسالة | pass |
| R | `report.prompt` | Choose the reason that fits best. | اختر السبب الأنسب. | pass |
| R | `report.reason.spam` | Spam | محتوى مزعج (سبام) | pass |
| R | `report.reason.abuse` | Abusive language | ألفاظ مسيئة | pass |
| R | `report.reason.hate` | Hate speech | خطاب كراهية | pass |
| R | `report.reason.harassment` | Harassment or bullying | مضايقة أو تنمر | pass |
| R | `report.reason.nudity` | Nudity or sexual content | عُري أو محتوى جنسي | pass |
| R | `report.reason.illegal` | Illegal activity | نشاط غير قانوني | pass |
| R | `report.reason.danger` | Threat or dangerous behaviour | تهديد أو سلوك خطير | pass |
| R | `report.reason.scam` | Scam or fraud | احتيال | pass |
| R | `report.reason.impersonation` | Pretending to be someone else | انتحال هوية شخص آخر | pass |
| R | `report.reason.other` | Something else | سبب آخر | pass |
| R | `report.send` | Send report | إرسال البلاغ | pass |
| R | `report.cancel` | Cancel | إلغاء | pass |
| R | `report.sending` | Sending... | جارٍ الإرسال... | pass |
| R | `report.close` | Close | إغلاق | pass |
| R | `report.dismiss` | Dismiss | تجاهل | pass |
| R | `report.submitted.title` | Report sent | تم إرسال البلاغ | pass (no response time, no "also block") |
| R | `report.submitted.body` | Thank you for letting us know. | شكرًا لإبلاغنا. | pass |
| R | `report.done` | Done | تم | pass |
| R | `report.failed` | Your report was not sent. Try again. | لم يتم إرسال بلاغك. حاول مرة أخرى. | pass |
| R | `report.retry` | Try again | حاول مرة أخرى | pass |
| U | `unavailable.line` | This chat isn't available right now. | هذه المحادثة غير متاحة حاليًا. | pass |
| U | `unavailable.action` | Go back | رجوع | pass |
| U | `unavailable.back` | Back | رجوع | pass |
| X | `removed.line` | You can no longer view this chat. | لم يعد بإمكانك عرض هذه المحادثة. | pass (no reason, no actor) |
| X | `removed.action` | Go back | رجوع | pass |
| X | `removed.back` | Back | رجوع | pass |
| I | `inbox.loading` | Loading chats | جارٍ تحميل المحادثات | pass |

Notes:
- The ten reason rows are the ten values of the Postgres enum `report_reason` (baseline migration lines 327-338; no later `ALTER TYPE ... report_reason` in any migration of the app repo worktree). The mapping table with the enum value for each row is in `01-report-reason-sheet.md` section 2.
- Strings deliberately **not** present anywhere in these specs: refund, any price or settlement, "7 days", "24 hours" or any review time, online or presence, typing, read or delivered marks, message search, "or see the games you organise", "also block this player" (it carried the block consequence copy), "confidential", "we will not tell them".
- `rtl-arabic-checklist` items applied: no string embeds a Latin token or a numeral, so there is no mixed-direction run to isolate; the layouts wrap rather than clip (by construction; expansion not measured, not run on a device); no date, number or currency is formatted by these strings.

## 3. RTL layout per state

General rule for all four: every inset and alignment is directional (`EdgeInsetsDirectional`, `AlignmentDirectional`, `TextAlign.start`); nothing says left or right; the ambient `Directionality` is the only switch. The type face swaps with direction (display Gloock to Wingx, sans Glory to Meral Sans) and Arabic size is the Latin size less 0.9 with the Arabic leading column of `DabblerType` (title3 25, bodyRelaxed 24, subheadline 23, footnote 18, caption1 16).

| State | Mirrored layout (right-to-left) |
|---|---|
| **Report sheet** | Title and prompt start-aligned (right). Reason row: label at the inline start (right), selected `tick-circle` at the inline end (left). Close button at the header's inline end (left). Send above Cancel, full width, labels centred. Failed message: glyph at the right, text start-aligned. Submitted body centred. |
| **Unavailable** | Back button at the inline start (**right edge**) with the glyph pointing **right**. Body centred: glyph well, one line, one button, all centred; nothing else to mirror. |
| **Removed** | Same as unavailable. |
| **No-preview inbox row and skeleton** | Avatar at the inline start (right); title start-aligned beside it; time and then the unread badge at the inline end (left), so right to left on line 1: title, mute glyph, time, badge. State line under the title. Skeleton circle at the right, one bar anchored to the right. Same insets 18 / 12 as LTR. |

## 4. The back chevron (report 4, frame 24 defect) - requirement

**Defect, observed on the PNG** (`design/full/frames/Messaging.dc.html/24.png`, viewed for this ticket): in the Arabic frame the app-bar back button sits at the right edge but its glyph is the left-pointing circled arrow, pointing into the content. The live source passes `arrow-circle-left` in both directions (`ConversationHeader` in `ds-components/messaging/messaging.jsx`; the Dart doc comment in `conversation_header.dart` lines 51-57 says the same).

**Requirement (applies to every screen that carries a back arrow, including the unavailable and removed screens):**

| Direction | Back button position | Glyph | Points |
|---|---|---|---|
| LTR | inline start = left | `arrow-circle-left` | left |
| RTL | inline start = **right** | `arrow-circle-right` | **right** |

The glyph must be selected by direction (`DabblerIcon(..., mirrorInRtl: true)`, or `DabblerConversationHeader.backIconFor(direction)` in the conversation header), never reused unmirrored. The back arrow points toward the reading start in both scripts. Non-directional glyphs (`lock`, `info-circle`, `tick-circle`, `danger`, `volume-slash`) are **not** mirrored.

## 5. Verification record - what was and was not run

Checked statements are separated from assumed ones on purpose.

| Item | Status | Evidence |
|---|---|---|
| DS `DabblerConversationHeader` picks `arrow-circle-right` in RTL and places the back button at the inline start | **VERIFIED by an existing test, run in C2** | `test/messaging/conversation_header_test.dart` group `direction`: "RTL mirrors order and the back glyph by name" and "LTR keeps arrow-circle-left". It asserts the icon **name** and that the back glyph is laid out to the right of the overflow glyph. C2 passed. |
| DS `DabblerNavigationTopBar.titled` (the bar the unavailable and removed screens use) draws `arrow-circle-right` in RTL at the right side, `arrow-circle-left` at the left in LTR | **VERIFIED by an ad-hoc widget test, not committed** | Throwaway test (deleted before the commit) pumped the bar at 360 wide: RTL drew `Iconsax.arrow_circle_right_copy` at x 311.5-331.5; LTR drew `arrow_circle_left_copy` at x 28.5-48.5. It checks the `IconData` chosen and the layout position. Code basis: `top_bar.dart` lines 850-855 (`mirrorInRtl: true`). |
| The two glyphs are true pixel mirrors of each other | **Not re-verified by this ticket.** The DS records a measurement ("Measured 2026-10-03: arrow-circle-left and -right are true pixel mirrors in iconsax_flutter", `top_bar.dart` comment, `icon_mirror.dart`); it was relied on, not repeated. |
| Rendered pixels of any of the four states, in any direction | **NOT RUN.** No gallery page was added, the existing DS gallery was **not** launched in RTL, no device or simulator was used, no screenshot was taken of these states. |
| DS gallery chevron mirroring in RTL | **UNVERIFIED.** What is verified is the glyph choice by name in two widgets (rows above), not the DS gallery run in RTL. |
| Text-scale 200 per cent, Arabic wrapping | **NOT RUN.** |
| Contrast of secondary text | **NOT MEASURED** (open item for the whole messaging kit). |
| Dark mode | **@provisional**, not signed off, not specified here. |
| The proposed no-preview row | **Not rendered**; numbers derived from measured parts. |
