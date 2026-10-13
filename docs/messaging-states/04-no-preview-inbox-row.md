# 04 - No-preview inbox row and its skeleton (KAN-503, AC4)

Status: design spec, light and RTL. Dark is `@provisional` (see README).

**Basis: D16 is a recommendation, NOT approved**: no message previews in the MVP. The sources also say the inbox moves to P3 (CPO 1(b), CXO sign-off statement 2), so this row is a P3 prerequisite; it is specified now so it is not improvised later.

Frames 01, 02 and 23 draw every row with a last-message preview line (frame 04 as well). None draws a row without one.

## 1. How it was measured (and what was not)

- **Source of the numbers:** the Dart widget `DabblerConversationRow` (`lib/src/messaging/conversation_row.dart`), laid out under `flutter test` at 360 logical px wide, light theme `main`, in LTR and RTL (a throwaway measuring test, deleted before the commit; nothing was added to `test/`). Fonts in `flutter test` are the test fallback, so **line heights follow the declared leadings** (which is what sets row height) but glyph widths are not the real faces.
- **Cross-checks:** the design source `ds-components/messaging/messaging.jsx` lines 1089-1170 (`ConversationRow`): padding `space-6` inline and `space-4` block, avatar 48, column gap `space-1`, `minHeight: touch-target-min`, badge `minWidth: 24, minHeight: 24`. The Dart widget is a transcription of it and the numbers agree. Frame 01 PNG (`design/full/frames/Messaging.dc.html/01.png`): a plain row (Sara Haddad) spans about 146 px, which is 73 at the 2x export scale. **The 2x scale is assumed, not confirmed.** Frames were viewed as PNG, not rendered live.
- **Not measured:** the proposed layout in section 4 was **not rendered**; its numbers are arithmetic on the measured parts (listed as "derived").

## 2. Existing row, measured

Tokens: padding `DabblerConversationRow.paddingInline` 18 (`space6`) and `paddingBlock` 12 (`space4`); avatar 48 (`avatarSize`), 12 between avatar and text (`space4`); hairline 1 in `colors.bgTertiary`; minimum 45.

| Line | Content | Type | Height LTR / RTL |
|---|---|---|---|
| 1 | title (700 unread, 600 read), mute glyph 14, time | `subheadline` 15/20 (AR leading 23); time `caption1` 12/16 | 20 / 23 |
| gap | | `space1` | 3 |
| 2 | preview (one line, ellipsis) and unread badge | `footnote` 13/18; badge min 24 wide | 18, or **25 / 23 with a badge** |
| 3 (optional) | state badge and kind label | state badge | 3 + 3 gap, then **25 / 23** |

Row heights (px, including the 1 px hairline):

| Case | LTR | RTL |
|---|---|---|
| preview, read | 73 | 73 |
| preview, unread (badge 3) | 73 | 74 |
| preview, unread, state badge ("Cancelled") | 104 | 103 |
| `preview: null`, read (what the widget does today) | 73 | 73 |
| `preview: null`, unread | 73 | 74 |
| `preview: null`, unread, state badge | 104 | 103 |

Position inside a 73 row, LTR, unread: title top 12, bottom 32; time top 14, bottom 30; badge top 35, bottom 60 (24 wide, 25 tall); title left edge 78; time right edge 342 of 360. Rows without a state line are **avatar-governed**: 48 + 12 + 12 + 1 = 73.

**Finding: passing `preview: null` does not remove the line.** Today the widget still builds line 2 (an empty text of the same height, plus the badge). The measured heights are identical to the with-preview rows, and the title stays top-aligned over an empty gap. The visible result of "no preview" with today's widget is a title floating above blank space. That is the hierarchy defect AC4 exists to fix.

## 3. What changes when the preview goes

| | Frames 01, 02, 23 (with preview) | No-preview row (proposed) |
|---|---|---|
| Text lines | title, preview, optional state line | title, optional state line |
| Row height, no state line | 73 | **73** (unchanged: the avatar already sets it) |
| Row height, unread, no state line (RTL) | 74 | **73** (one pixel less) |
| Row height, with state line | 104 LTR / 103 RTL | **LTR 76 read, 81 unread; RTL 77** (derived: 23-28 less) |
| Title typography | `subheadline` 15/20, 700 unread / 600 read | **unchanged** (no new type step; the system forbids inventing one) |
| Title vertical position | top-aligned (y 12) | **centred on the avatar's centre line** (y 36 from the row top) |
| Unread badge | line 2, trailing, below the time | **line 1, trailing, after the time** |
| Time | line 1, trailing | line 1, trailing, unchanged position in x |
| Mute glyph | line 1, before the time | line 1, before the time (unchanged) |
| Unread cue | bold title, brand time, badge | **unchanged** (the same three cues) |
| Preview ink cue (read versus unread) | `textSecondary` for both (D-003(a)) | gone; it was already identical |
| Accessible name | title, `sender: preview`, time, "N unread", state, kind | title, time, "N unread", state, kind |

## 4. Layout (proposed)

One horizontal row, vertically **centred** against the 48 avatar:

```
[ avatar 48 ] 12 [ text block ........................ ] 
                    line 1: title (flex) · mute 14 · time · unread badge
                    line 2 (only if a state badge / kind label exists): state badge · kind label
```

| Element | Spec | Token / constant |
|---|---|---|
| Row inset | 18 inline, 12 block | `paddingInline`, `paddingBlock` |
| Row minimum | 45 | `DabblerSizing.touchTargetMin` |
| Hairline | 1, block end | `colors.bgTertiary`, `DabblerSizing.borderDefault` |
| Cross-axis alignment | **centre** (the existing row uses start) | |
| Line 1 | title expands, single line, ellipsis; gaps 6 between title, mute, time and badge | `DabblerSpacing.space2` |
| Time | `caption1`; semibold in `colors.brandPrimary` when unread, regular in `colors.textSecondary` when read | |
| Unread badge | min width 24, inline padding 6, tone default (warning when muted) | `DabblerBadge`, `DabblerConversationRow.unreadMinWidth` |
| Line 1 to line 2 | 3 gap + 3 top padding = 6 (as today) | `space1` twice |
| State badge / kind label | unchanged | `DabblerConversationState`, `caption2` |
| Pressed / focus | `surfaceSunken` fill, 80 ms ease-out; focus ring | unchanged |

**Why the badge moves to line 1:** with no line 2 the badge has no line to sit on. Putting it after the time keeps both trailing items in one cluster, keeps the time's horizontal position (right edge at the inset), and avoids a second trailing line that would pull the title off the avatar's centre.

**Rejected:** a two-line trailing column (time over badge) because it fights a centred title; enlarging the title (a new type step is not allowed without a ruling); keeping an empty line 2 for height consistency (it is the defect in section 2).

Row heights above: LTR line 1 is 20 (25 with a badge); the state line is 25; 6 between. 48 governs unless a state line is present: 20 + 6 + 25 = 51, plus 24 inset and 1 hairline = **76** (read); 25 + 6 + 25 = 56 + 25 = **81** (unread). RTL: 23 + 6 + 23 = 52 + 25 = **77** (both). **Derived, not rendered.**

## 5. Which component renders it

| Option | Verdict |
|---|---|
| `DabblerConversationRow` as it is, `preview: null` | **Not enough.** Line 2 stays (section 2). |
| `DabblerListRow` (`lib/src/cards/list_row.dart`) with avatar `leading` and time and badge in `trailing` | Possible as an app composition, but it loses the row's unread weight switch, mute glyph, press and focus treatment, the composed accessible name, and uses a 15 inline inset instead of 18, so it would not match frames 01, 02 and 23. **Not recommended.** |
| **`DabblerConversationRow` with a new `hidePreview` option** | **Recommended. PROPOSED, NOT EXISTING.** |

**Proposal (new, stated explicitly):** add an optional `bool hidePreview = false` to `DabblerConversationRow`. When true: no preview line and no typing line (even if `preview`, `sender` or `typing` are passed); cross-axis alignment centre; the unread badge renders on line 1 after the time; the composed accessible name omits the preview. Default behaviour is unchanged, so no existing caller or test changes. This is the "no-preview ConversationRow variant" the CXO sign-off counts at about 3 h of DS work (P3). It is a **DS API addition**, so it needs the DS owner's go-ahead; this ticket does not make it (existing components are read-only here).

Props the app must not pass in the MVP, whatever `hidePreview` does: `online` (presence stripped by D29, would draw the green dot on the avatar), `typing` and `typingLabel` (typing stripped), `preview`, `sender`.

## 6. Skeleton

`ConversationRowSkeleton` is a design-class D composition that stays in the app (it is a `Skeleton` arrangement, `messaging.jsx` 1558-1575), not a DS part. Spec for the no-preview version:

| Element | Spec | Component |
|---|---|---|
| Row | same inset as the row: 18 inline, 12 block; centre aligned; 1 hairline | `DabblerSpacing.space6`, `space4`, `colors.bgTertiary` |
| Avatar | circle 48 | `DabblerSkeleton.circle(width: 48)` |
| Gap | 12 | `DabblerSpacing.space4` |
| Text | **one** bar, 12 tall, alternating 60 per cent and 44 per cent of the text width, anchored at the inline start | `DabblerSkeleton.text(lines: 1)` inside a `FractionallySizedBox(alignment: AlignmentDirectional.centerStart)` |
| Rows | 5 on first load (the design's own example uses `rows="5"`, `Messaging.dc.html:162`) | |
| Height | 48 + 24 + 1 = **73**, equal to a populated read row, so nothing jumps when data arrives | |
| Motion | flat fill, opacity pulse only; static under reduced motion | `DabblerSkeleton` (own rules) |
| Accessibility | skeleton blocks are excluded from semantics; announce once on the container | `Semantics(label: <loading label>, liveRegion: true)` |

The design's skeleton draws two bars (title and preview). One bar is the no-preview analogue. `DabblerSkeleton` is in `lib/src/feedback/skeleton.dart`; its `width` is absolute, hence the `FractionallySizedBox`.

## 7. Copy and RTL

Only one string: the skeleton container's loading label.

| Key | EN | AR |
|---|---|---|
| `inbox.loading` | Loading chats | جارٍ تحميل المحادثات |

Row text (titles, times, state labels) is data and formatting, not designed copy.

RTL:
- The avatar leads at the inline start (right) and the time and badge trail at the inline end (left). All insets are directional (`EdgeInsetsDirectional`), so the same layout mirrors with no extra rule, exactly as frame 23 shows for the preview rows.
- Order on line 1 in Arabic, right to left: title, mute glyph, time, badge. The badge ends up at the far left edge.
- Arabic title leading is 23 (versus 20), so the unread row is 74 today and 73 here, and a state line row is 77. Numerals stay Western (`3`, `99+`); time strings are formatted by the app.
- Titles with mixed Arabic and Latin names are start-aligned in the ambient direction, as in the existing row.
- The skeleton bar anchors at the right edge in Arabic.
- The mute glyph (`volume-slash`) is not directional; not mirrored.
