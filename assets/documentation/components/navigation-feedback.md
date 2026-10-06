<!--
Component page, D-033 ten-part template.

Group    : Status and feedback
Sources  : lib/src/feedback/navigation_feedback.dart (class dartdoc in full —
           presentations, lifecycle table, when to use it;
           DabblerNavigationFeedbackData)
           lib/src/feedback/action_area_gallery.dart (specimen titles:
           "NavigationFeedback — toast", "— banner", "— interaction preview")
           Design: components/feedback/status-feedback.card.html, sections
           "Toast", "Banner", "Navigation interaction preview"
-->

# NavigationFeedback
### `DabblerNavigationFeedback`

NavigationFeedback presents a Toast or a Banner from the bottom navigation: the action footprint becomes the tone glyph, then grows along the bar into the message.

It is the same Toast and the same Banner — the same tone colours, hairline, type and action
button — with only the container changed, so the feedback reads as coming from the shell rather
than floating over it. The toast is a single row along the bar; the banner grows up and along from
the action, bottom-anchored on the bar's baseline. Both are built on `ActionArea`.

## Specimen

The five toast tones, expanded — see `action_area_gallery.dart`'s *NavigationFeedback — toast*
section.

@specimen navigation-feedback/toast

The five banner tones, expanded, with the glyph at the top-leading corner, the outlined action and
the dismiss at the top-trailing corner.

@specimen navigation-feedback/banner

The sequence: the bar alone, the collapsed tone circle, looping expansions, and a live pair in both
directions — fire one and watch the toast hold and leave, or the banner stay until dismissed.

@specimen navigation-feedback/sequence

## Using it

**Use it for a direct consequence of the user's action on this screen.** Joined, copied, failed to
join — when the screen has the bottom bar. Standard `Toast` and `Banner` stay the default; never use
this while the create menu is open, over a `Dialog` or `Sheet`, or on a screen without the bar.

**Keep a toast to one line.** The geometry is the bar's, so the message never wraps; anything longer
is a banner.

**Use the banner for a condition that arrives while the user is here and should be acknowledged.**
One that must survive navigation is still the inline `Banner`.

**Let it run its own sequence, and clear the feedback in `onDone`.** Hand it a feedback payload and
it holds the tone circle briefly, grows, stays readable, contracts and returns to idle, then calls
`onDone`. Hover and focus pause the toast's timer. The action and the dismiss button start the
contraction at once. Pin `phase` only for a specimen.

## Axes

### Presentation
`toast` (a pill row along the bar) or `banner` (grown to content).

### Tone
`neutral` (the default — card surface and ink), `success`, `warning`, `error`, `info` — the same
five Toast and Banner take, resolved through the same status tones.

### Duration
A toast holds for the toast's default lifetime; a banner is sticky. Pass a duration to override, or
zero for sticky.

### Action and dismiss
Zero or one action — a text button on a toast, an outlined button on a banner. A banner draws its
dismiss target only when it is dismissible.

## Direction

**Glyph, message, action and dismiss follow the ambient direction.** In Arabic the surface
originates on the left and grows rightward, the glyph leads on the right and the action sits on the
left — the same mirroring the standard Toast and Banner follow.

## Tokens used

No colours, radii or type of its own. Surface, ink and hairline are the status tones Toast and
Banner read — the status surface, its strong ink, and that ink at a fifth for the hairline;
`neutral` takes the card surface, primary ink and card outline. The message is the subheadline
step; a banner's title the headline step. Action and dismiss targets keep the touch-target minimum.

## Source

`lib/src/feedback/navigation_feedback.dart`
