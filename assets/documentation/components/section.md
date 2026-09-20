<!--
Component page, D-033 ten-part template.

Group    : Content containers
Sources  : lib/src/layout/section.dart (read in full through the type and
           header-action portions of the class dartdoc, plus the `action`
           field's own doc comment)
           lib/src/layout/section_gallery.dart:14 (specimen title: "Section
           — title, subtitle and action")
           DECISIONS.md D-013 (read in full, prior session); D-023 mentions
           Section.prompt.md's drift toward a `Button` `text` tone for this
           trailing action — noted in Using it, not linked in Change log
           since D-023 rules Button's tone, not anything in this file.
-->

# Section
### `DabblerSection`

Section is a titled group of content — an optional title with an optional trailing action, an
optional subtitle, then a stack of children.

It's layout only: no surface, no border, no rule of its own. A decorative divider under a heading
is deliberately not this component's job — Section already carries that visual structure through
spacing alone, and adding a rule would duplicate what the gap between header and children already
does. It's also careful about the gaps it doesn't own: the space between sections and the screen's
own gutter both belong to whatever places the Section, not to the Section itself.

## Specimen

Title with a trailing action, and title with a subtitle — see `section_gallery.dart`'s *Section*
section.

## Using it

**Pass the trailing action as a `Button` at the `text` tone once that tone exists — not as a
`variant="text"` prop, which `Section` doesn't have.** The design source's own composition guidance
for this slot is drifted toward an API this system doesn't carry; a bare `Button` is the correct
shape today regardless of which tone the button itself ends up using.

**Don't add your own gap between two stacked Sections.** That space belongs to whatever is stacking
them — a `ListView`'s separator, a `Column`'s own spacing — not to either Section, so it can be
tuned in one place rather than per section.

**Give `title` its default styling; don't override the weight.** A one-off lighter title was tried
and rejected — every other title-bearing component in this system reaches the same style through
the same path, and a Section styled differently stops looking like it belongs to the same set the
instant it sits beside one that wasn't.

## Axes

### Header
None, title only, title with a trailing action, title with a subtitle — subtitle alone (no title)
does not open the header-to-children gap the way a title does.

## Tokens used

Title: `textPrimary` at the title3 type style. Subtitle: `textSecondary` at the footnote style. No
fill, border or radius of its own — Section draws no surface at all.

## Change log

- D-013 (cxo) — the title's type style and weight, correcting
  a one-off inline style in the design source that no other title-bearing component in the system
  followed.

## Source

`lib/src/layout/section.dart`
