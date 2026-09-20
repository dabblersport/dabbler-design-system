<!--
Component page, D-033 ten-part template. Internal primitive — D-033(b) still
lists it as its own page under Selection and input, and D-033(c) names it
explicitly as "real composition machinery" whose rules belong on the
component contract rather than a Patterns page, which is this page.

Group    : Selection and input
Sources  : lib/src/forms/field_shell.dart (read in full through the
           DabblerFieldShell class doc and constructor/field declarations)
           lib/src/forms/forms_gallery.dart:140-144 (specimen contents)
           DECISIONS.md — grepped "FieldShell": no ruling on the component
           itself; the one hit is D-033's own text, about the documentation
           architecture, not FieldShell's behaviour. D-003 is cited inside
           field_shell.dart's own dartdoc but the dartdoc states outright
           that D-003 "costs this file nothing" (the forms source never puts
           helper text on --muted/--subtle) — so not linked in Change log,
           since D-003 doesn't actually rule anything about this file.

Direction section REMOVED 2026-09-18 per D-036: both paddings are
EdgeInsetsDirectional — uniform mirroring, no exception, no semantic
consequence.
-->

# FieldShell
### `DabblerFieldShell`

FieldShell is the chrome every field in this system paints from — the label, the bordered box, and
the helper or error line beneath it.

It's an internal composition primitive, not a public control: `TextField`, `Select`, `DateField`,
`TimeField`, `Stepper` and every other field import and wrap it, but it is not exported from the
package for a screen to place directly. Its job is exactly what its one-line design-source rule
states — every field paints from it, so no picker can drift into a visual fork of the plain text
input.

## Specimen

The rest / filled / helper / error / disabled state matrix, shown directly over the raw shell — see
`forms_gallery.dart`'s *Fields* section.

## Using it

**Never place a bare `DabblerFieldShell` in a screen.** It holds no state of its own — every field
that wraps it owns the state that drives it. A bare shell in a screen is a field with nothing
behind it.

**Disabled always wins the border colour, even over an error.** A disabled field with `errorText`
still shows the plain disabled hairline, not the error colour — this isn't a severity ranking, it's
transcribed exactly as the source tests it, and building a field that expects error to show through
disabled will be surprised by this.

**Only a real button gets the system focus ring in addition to the border swap.** Every field shows
focus through its own border colour change; the additional outline ring is reserved for a shell
that is actually a button underneath, like `Select`'s. A plain text field's focus ring is the
border alone, in the source and here.

## Axes

### Border state
Rest (surface hairline), focused (2px focus-ring colour), error (1px error status colour),
disabled (1px surface hairline) — checked in that precedence, disabled first.

### Label alignment
Centred (the default, vertically centred against the box) or start-aligned (multiline fields only,
so the label sits against the first line rather than floating mid-box).

@figure 2px lib/src/interaction/focus_ring.dart#ringWidth
@figure 1px lib/src/tokens/dabbler_geometry.dart#borderDefault
@figure 1px lib/src/tokens/dabbler_geometry.dart#borderDefault


## Tokens used

Label: `textSecondary` at rest, `brandPrimary` while focused. Border: the surface hairline at rest
and disabled, the focus-ring role while focused, the error status tone's role on error. Helper
text: `textSecondary`. Error text: the error status tone. Touch-target minimum is the same shared
token every field control reads.

## Source

`lib/src/forms/field_shell.dart`, `lib/src/interaction/focus_ring.dart`
