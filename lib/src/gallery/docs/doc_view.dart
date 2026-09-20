/// Renders a parsed [DabblerDocPage] with the gallery's existing widgets.
///
/// This **composes** `GallerySections`, `GallerySectionLabel`, `GalleryUsage`,
/// `GalleryRule` and `GalleryGroup` and restyles none of them — `D-041`(c)4.
/// Every type treatment, colour and measure on screen here is one the gallery
/// already owned; nothing in this file decides an appearance.
///
/// The one thing it does own is the **interior spacing rhythm** of a section,
/// and it does not decide that either: the ramp is `D-050`(c), ruled, and every
/// value is an existing [DabblerSpacing] step. See [_DocSection].
///
/// No Material chrome: no `Scaffold`, no `AppBar`, no `ListTile`, no `Card`
/// (`D-017` — Material is a mechanism, never an appearance).
library;

import 'package:flutter/widgets.dart';

import '../../tokens/dabbler_geometry.dart';
import '../gallery_entry.dart';
import '../gallery_page.dart';
import 'doc_page.dart';
import 'doc_specimen_resolver.dart';

/// Lays out one documentation page.
class DabblerDocPageView extends StatelessWidget {
  /// Creates a view over an already-parsed [page].
  const DabblerDocPageView({
    super.key,
    required this.page,
    required this.resolver,
  });

  /// The parsed page. An unavailable page renders its "not available" section
  /// like any other — the failure is visible in place, not a blank screen.
  final DabblerDocPage page;

  /// Resolves `@specimen` ids to live specimens.
  final DabblerDocSpecimenResolver resolver;

  @override
  Widget build(BuildContext context) {
    return GallerySections(
      ruled: true,
      children: <Widget>[
        if (page.lead.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final DabblerDocProse prose in page.lead)
                GalleryUsage(prose.markup),
            ],
          ),
        for (final DabblerDocSection section in page.sections)
          _DocSection(section: section, resolver: resolver),
      ],
    );
  }
}

/// One `## ` section, with the interior spacing ramp `D-050`(c) rules.
///
/// The section used to be a bare [Column]: the label was welded to its first
/// paragraph and consecutive prose abutted with no air at all. The only gap in
/// the whole render path was `GallerySections`' 24 **between** sections.
///
/// | Gap | Token | Value |
/// |---|---|---|
/// | Between sections (owned by `GallerySections`, untouched) | `space8` | 24 |
/// | Before a `### ` sub-heading | `space6` | 18 |
/// | Before a specimen block | `space6` | 18 |
/// | Between sibling prose | `space4` | 12 |
/// | After the `## ` section label | `space4` | 12 |
/// | After a `### ` sub-heading | `space2` | 6 |
///
/// **One gap between any two blocks, never a sum.** [_gapBefore] picks a
/// single value by precedence, so a `### ` sitting between two paragraphs gets
/// 18 above and 6 below rather than 18+12 above and 6+12 below. Air decreases
/// strictly outward-in: section 24 → sub-heading 18 → paragraph 12 → a
/// heading and its own prose 6.
///
/// **The first block takes 12 even when it is a `### `.** After the `## `
/// label there is no preceding prose for the 18 to separate the heading from,
/// and the label already carries the section break; spending 18 there would
/// put more air between a section and its first sub-heading than the ramp
/// gives a sub-heading mid-section, which is the ordering this ramp exists to
/// hold. `assets/documentation/patterns/nothing-to-show.md:27-29` is that case.
///
/// A `### ` is not styled here — that is `KAN-330`, deliberately a separate
/// ticket. This file only decides how much air goes around one.
class _DocSection extends StatelessWidget {
  const _DocSection({required this.section, required this.resolver});

  final DabblerDocSection section;
  final DabblerDocSpecimenResolver resolver;

  /// A `### ` sub-heading is not its own block type: the splitter breaks prose
  /// on blank lines, so an authored `### ` on its own line arrives as a
  /// [DabblerDocProse] whose markup starts with it.
  static bool _isSubHeading(DabblerDocBlock block) =>
      block is DabblerDocProse && block.markup.trimLeft().startsWith('### ');

  /// The single gap above `section.blocks[i]`.
  double _gapBefore(int i) {
    final DabblerDocBlock block = section.blocks[i];
    // Straight after the `## ` label — see the class doc for why this is 12
    // even for a sub-heading.
    if (i == 0) {
      return DabblerSpacing.space4;
    }
    if (_isSubHeading(block) || block is DabblerDocSpecimen) {
      return DabblerSpacing.space6;
    }
    if (_isSubHeading(section.blocks[i - 1])) {
      return DabblerSpacing.space2;
    }
    return DabblerSpacing.space4;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GallerySectionLabel(section.heading),
        for (int i = 0; i < section.blocks.length; i++) ...<Widget>[
          SizedBox(height: _gapBefore(i)),
          _block(context, section.blocks[i]),
        ],
      ],
    );
  }

  Widget _block(BuildContext context, DabblerDocBlock block) {
    switch (block) {
      case DabblerDocProse(:final String markup):
        return GalleryUsage(markup);
      case DabblerDocSpecimen(:final String id):
        final GalleryEntry? entry = resolver.resolve(id);
        if (entry == null) {
          // Visible, never a throw. The same string the KAN-324 gate asserts on.
          return GalleryUsage(
            DabblerDocSpecimenResolver.missingSpecimenMessage(id),
          );
        }
        return GalleryGroup(
          name: entry.title,
          wrap: false,
          children: <Widget>[entry.builder(context)],
        );
    }
  }
}
