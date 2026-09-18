/// Renders a parsed [DabblerDocPage] with the gallery's existing widgets.
///
/// This **composes** `GallerySections`, `GallerySectionLabel`, `GalleryUsage`,
/// `GalleryRule` and `GalleryGroup` and restyles none of them — `D-041`(c)4.
/// Every type treatment, colour and measure on screen here is one the gallery
/// already owned; nothing in this file decides an appearance.
///
/// No Material chrome: no `Scaffold`, no `AppBar`, no `ListTile`, no `Card`
/// (`D-017` — Material is a mechanism, never an appearance).
library;

import 'package:flutter/widgets.dart';

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

class _DocSection extends StatelessWidget {
  const _DocSection({required this.section, required this.resolver});

  final DabblerDocSection section;
  final DabblerDocSpecimenResolver resolver;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GallerySectionLabel(section.heading),
        for (final DabblerDocBlock block in section.blocks)
          _block(context, block),
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
