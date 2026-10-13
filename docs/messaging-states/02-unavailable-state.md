# 02 - Unavailable state (KAN-503, AC2)

Status: design spec, light and RTL. Dark is `@provisional` (see README).

**Basis: D19 is a recommendation, NOT approved.** Recommended rule: non-pilot users get no messaging entry points; if they open a chat deep link they see an "unavailable" state. This spec lets the P2 build be written against it; if the CEO rules differently, only the trigger changes, not the layout.

## 1. When it shows

A signed-in user who is **not** in the messaging pilot opens a chat deep link (push or shared link). The screen shows this state instead of a thread, a composer, or an error. It shows **no conversation name, no game name, no member names, no counts**: the user is not entitled to see anything about the conversation, so the screen must not echo anything from the link.

It is not the "removed" state (`03-removed-state.md`): the user was never in this chat. Which typed code from the API selects which state is the CTO contract's to name; this ticket only fixes the design for each. The typed reason for removal is `removed`. The code name for the non-pilot case is **not specified in any source read for this ticket** and is not invented here.

## 2. Layout

One screen, three parts. **Everything is an existing component; nothing new is proposed.**

| Part | Component | File |
|---|---|---|
| Top bar, back only, no title | `DabblerNavigationTopBar.titled(onBack: ..., title: null)` | `lib/src/navigation/top_bar.dart` |
| Body | `DabblerEmptyState(size: DabblerEmptyStateSize.page)` | `lib/src/cards/empty_state.dart` |
| One action | `DabblerButton(tone: DabblerButtonTone.secondary)` passed as the empty state's `action` | `lib/src/controls/button.dart` |

```
DabblerEmptyState(
  size: DabblerEmptyStateSize.page,
  icon: 'info-circle',
  title: <the one line>,         // no `text`
  action: DabblerButton(label: <action>, tone: DabblerButtonTone.secondary, onPressed: goBack),
)
```

`DabblerEmptyState` is the system's only empty state ("Do not build a screen-specific empty state", its own class doc), takes at most one action, and has no illustration hook, which is what this state wants. The one line goes in `title` (a statement of fact, as the component's accessibility note asks) and `text` is left null, so there is exactly one line.

| Element | Spec | Token / constant |
|---|---|---|
| Layout | content centred in the viewport, min height 60 per cent of the viewport, padding 36 block and 18 inline | `DabblerEmptyState.pagePadding`, `pageMinHeightFraction` |
| Icon well | 45 x 45, radius 9, neutral tone (page-surface fill, hairline, subtle ink) | `DabblerEmptyState.wellSide`, `wellRadius`, `DabblerEmptyStateTone.neutral` |
| Glyph | `info-circle` (resolves in the icon registry, checked), size 24 | `DabblerSizing.iconMd` |
| The one line | 20/25, weight 400, display face, centred, `textPrimary` | `DabblerType.title3` (page size) |
| Well to line | 12 | `DabblerEmptyState.gap` (`DabblerSpacing.stackDefault`) |
| Line to action | 18 (12 + 6) | `gap + actionGap` |
| Action | secondary tone, medium size, pill, 45 minimum height | `DabblerButtonSize.medium`, `DabblerSizing.touchTargetMin` |
| Screen background | page surface | `colors.bgPrimary` |

Why `info-circle` and not `lock`: a lock says "you are not allowed", which blames the user. `info-circle` says only "this is not available". The removed state uses a different glyph so the two cannot be confused (`03`).

Why `secondary` for the action: that is the tone the component's own error variant gives its single retry button; the action is a way out, not a conversion.

## 3. States

| State | Notes |
|---|---|
| Default | the only state. Static, no loading and no retry: nothing about it can be retried by the user. |
| Action pressed / focused | shared press scale and focus ring of `DabblerButton`. |

The state is final for that link. There is no secondary link, no "request access", no contact route (none is specified; do not add one).

## 4. Copy (EN / AR)

Proposed, for `content-manager` to confirm. One neutral line, one action.

| Key | EN | AR |
|---|---|---|
| `unavailable.line` | This chat isn't available right now. | هذه المحادثة غير متاحة حاليًا. |
| `unavailable.action` | Go back | رجوع |
| `unavailable.back` (top-bar back semantics) | Back | رجوع |

Rules the copy follows: no reason why, no mention of a pilot, an allowlist, an account, a feature flag or "coming soon" (that would announce a launch nobody has ruled), no apology, no second sentence.

## 5. Behaviour (for the frontend seat, not a visual rule)

- The action pops to where the link was opened from, or to the app's home route if there is no history. Not designed here.
- The screen reads nothing from the link except what it needs to route; it does not fetch the conversation.
- On entering the screen, focus goes to the line (screen-reader announcement of the one line, then the action). The empty state has no built-in announcement wrapper; wrap the body in `Semantics(container: true, liveRegion: true)` in the app composition.

## 6. Accessibility

- Reading order: back button, the line, the action. The glyph is decorative (excluded from semantics by the component).
- Targets: back button is a 40 disc inside a 45 x 45 hit box with a 20 glyph (`DabblerNavigationTopBar.backButtonSide`, `backGlyphSize`); the action button is at least 45 tall.
- Text scale 200 per cent: the line wraps (title is not clamped); the page layout is a minimum height, so it grows. **Not run on a device here.**
- Secondary-text contrast is not measured; this screen uses primary ink for its only line, so it does not depend on the secondary ink.

## 7. RTL

- The app-bar **back glyph must point right in RTL.** `DabblerNavigationTopBar.titled` draws `arrow-circle-left` in LTR and `arrow-circle-right` in RTL (the glyph is selected by name through `DabblerIcon.mirrorInRtl`; `top_bar.dart` lines 233-240 and 292-295), and the back button sits at the inline start, which is the right edge in Arabic. This is the correction frame 24 needed (see `05-rtl-and-copy-matrix.md`).
- Body is centred, so nothing flips. Title swaps to Wingx, size less 0.9 and Arabic leading 25.
- Direction is the ambient `Directionality`; the screen sets no `left` or `right`.
- The line is a single Arabic sentence with no embedded Latin or numerals, so no bidi isolation is needed.
