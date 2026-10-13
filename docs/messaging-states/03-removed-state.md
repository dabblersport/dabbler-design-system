# 03 - Removed state (KAN-503, AC3)

Status: design spec, light and RTL. Dark is `@provisional` (see README).

**Basis: D7 is a recommendation, NOT approved.** Recommended roster read rule: `active` reads and sends; `left` reads up to `left_at_seq`; `kicked` and any other non-active status read nothing. This spec covers the "reads nothing" outcome only. It does not design the `left` member's read-only view (that is the existing closed-composer notice, `lib/src/messaging/chat_composer_notice.dart`, and a thread; a different screen).

## 1. When it shows

A member who was removed from the game, or is otherwise not an active member, **makes their next API call** (open the chat, load older messages, send, refresh). The API answers with the typed reason `removed`. The screen then replaces the thread and the composer with this state.

- The trigger is the typed reason `removed`, not the wording of an error message and not a status code alone.
- It can appear while the person is already inside the thread, so the swap must remove the message list and the composer completely, and drop any cached message content from the screen. (Behaviour for the frontend seat; not a visual rule.)
- It shows **nothing about why or by whom**: no organiser name, no "removed by", no "kicked", no date, no game name, no member count. The wording must be identical whether the person was removed, the game changed, or the status is some other non-active one, because the client must not be able to tell them apart and neither may the person.

## 2. Layout

Identical structure to the unavailable state, with a different glyph and line. **Everything exists; nothing new is proposed.**

| Part | Component | File |
|---|---|---|
| Top bar, back only, no title (no conversation identity) | `DabblerNavigationTopBar.titled(onBack: ..., title: null)` | `lib/src/navigation/top_bar.dart` |
| Body | `DabblerEmptyState(size: DabblerEmptyStateSize.page)` | `lib/src/cards/empty_state.dart` |
| One action | `DabblerButton(tone: DabblerButtonTone.secondary)` as the empty state's `action` | `lib/src/controls/button.dart` |

```
DabblerEmptyState(
  size: DabblerEmptyStateSize.page,
  icon: 'lock',
  title: <the one line>,
  action: DabblerButton(label: <action>, tone: DabblerButtonTone.secondary, onPressed: goBack),
)
```

Token table: **same as `02-unavailable-state.md` section 2** (page padding 36/18, 60 per cent minimum height, 45 well radius 9, title `DabblerType.title3`, gaps 12 and 18, secondary medium button 45 tall). The only differences:

| | Unavailable | Removed |
|---|---|---|
| Glyph | `info-circle` | `lock` (resolves in the icon registry, checked; the vocabulary already holds it) |
| Meaning | not for you, never was | access ended |

`lock` is acceptable here because the state is about access, and it does not say why. It is not a person-removal glyph: `user-remove`, `slash`, `forbidden` and `danger` were rejected because each implies a decision or a fault by someone.

## 3. States

Single static state, no retry, no loading. The action is the only way out; there is **no** "rejoin", "ask to join", "contact the organiser" or "report" action. None is specified and each would reveal or imply a cause.

## 4. Copy (EN / AR)

Proposed, for `content-manager` to confirm. One neutral line, one action.

| Key | EN | AR |
|---|---|---|
| `removed.line` | You can no longer view this chat. | لم يعد بإمكانك عرض هذه المحادثة. |
| `removed.action` | Go back | رجوع |
| `removed.back` (top-bar back semantics) | Back | رجوع |

Rules the copy follows: passive and impersonal ("can no longer view"), no "removed", "kicked", "blocked", "banned", no "by the organiser", no time, no reason, no next step that implies a fix.

## 5. Behaviour (for the frontend seat)

- The action pops to the screen the chat was opened from (the game screen when opened from a game), or home if there is no history.
- After this state has shown, further calls for the same conversation are not retried automatically.
- Announce on entry: wrap the body in `Semantics(container: true, liveRegion: true)` in the app composition, because the state can replace a live thread under a screen-reader user.

## 6. Accessibility

- Reading order: back, the line, the action. Glyph decorative.
- Targets 45 minimum (back button: 40 disc in a 45 x 45 hit box; action button 45 tall).
- The line is primary ink (`textPrimary`); it does not rely on secondary ink, whose contrast is unmeasured.
- Text scale 200 per cent: wraps; page layout grows. **Not run on a device here.**

## 7. RTL

- **App-bar back glyph points right in RTL**: `DabblerNavigationTopBar.titled` selects `arrow-circle-right` under RTL and places the button at the inline start (right edge). See `05-rtl-and-copy-matrix.md` for the explicit requirement and its verification status.
- Body centred; nothing flips. Title in Wingx at the Latin size less 0.9, Arabic leading 25.
- No Latin or numerals in the line, so no bidi isolation.
- `lock` is not a directional glyph; it is not mirrored.
