/// Gallery entries for the foundations — [DabblerIcon], [DabblerSportIcon] and
/// [DabblerSportBackground] (KAN-259 AC2).
///
/// The rows mirror the design specimens
/// `components/foundations/foundations.card.html` (consolidated into
/// `icons-system.card.html`) and
/// `components/foundations/sport-backgrounds.card.html`.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'icon.dart';
import 'sport_background.dart';
import 'sport_icon.dart';
import 'sports.dart';

/// The foundations' specimens.
const List<GalleryEntry> foundationsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Icon — the app vocabulary',
    description: 'The specimen\'s sixteen names in both weights — linear in '
        'ink, bold in brand — then the three sizes and the full vocabulary.',
    builder: _icons,
  ),
  GalleryEntry(
    title: 'SportIcon — every sport',
    description: 'DabblerSport.values in both weights, each on its documented '
        'Iconsax fallback until the licensed set is registered.',
    builder: _sportIcons,
  ),
  GalleryEntry(
    title: 'SportBackground — every variant',
    description: 'The 160×284 artwork frame per sport. Nothing is registered '
        'in this package, so every frame is the "not registered" state.',
    builder: _sportBackgrounds,
  ),
];

/// `const NAMES = [...]` from the specimen, in its order.
const List<String> _specimenNames = <String>[
  'home-2', 'search-normal', 'add-circle', 'user', 'people',
  'notification-bing', 'calendar', 'location', 'game', 'cup', 'clock', 'star',
  'heart', 'sms', 'setting-2', 'filter',
];

Widget _icons(BuildContext context) {
  final DabblerColors colors = DabblerColors.of(context);
  return GalleryStack(
    children: <Widget>[
      // `linear — the default weight`, drawn in `color: var(--ink)`.
      GalleryWrap(
        children: <Widget>[
          for (final String name in _specimenNames)
            GallerySpecimen(
              label: name,
              child: DabblerIcon(
                name,
                size: DabblerSizing.iconMd,
                color: colors.textPrimary,
              ),
            ),
        ],
      ),
      // `bold — active tabs and primary actions`, in
      // `color: var(--color-brand-primary)`. The previous entry drew no bold
      // row at all, so half of what the specimen shows was missing.
      GalleryWrap(
        children: <Widget>[
          for (final String name in _specimenNames)
            GallerySpecimen(
              label: name,
              child: DabblerIcon(
                name,
                weight: DabblerIconWeight.bold,
                size: DabblerSizing.iconMd,
                color: colors.brandPrimary,
              ),
            ),
        ],
      ),
      // `Sizes: 18 small, 24 default, 30 large.`
      GalleryWrap(
        children: <Widget>[
          for (final double size in <double>[
            DabblerSizing.iconSm,
            DabblerSizing.iconMd,
            DabblerSizing.iconLg,
          ])
            GallerySpecimen(
              label: '${size.toInt()}',
              child: DabblerIcon('calendar', size: size),
            ),
        ],
      ),
      GalleryWrap(
        children: <Widget>[
          for (final String name in DabblerIconRegistry.vocabulary)
            GallerySpecimen(label: name, child: DabblerIcon(name)),
        ],
      ),
    ],
  );
}

Widget _sportIcons(BuildContext context) => GalleryStack(
  children: <Widget>[
    for (final DabblerIconWeight weight in DabblerIconWeight.values)
      GalleryWrap(
        children: <Widget>[
          for (final DabblerSport sport in DabblerSport.values)
            GallerySpecimen(
              label: sport.key,
              child: DabblerSportIcon(
                sport,
                weight: weight,
                size: DabblerSizing.iconMd,
              ),
            ),
        ],
      ),
  ],
);

/// `.tile .frame { width:160px; height:284px; … }` from the specimen's own CSS.
const double _frameWidth = 160;

/// The 9:16 frame the ~941×1672 artwork is composed for.
const double _frameHeight = 284;

Widget _sportBackgrounds(BuildContext context) => GalleryStack(
  children: <Widget>[
    for (final DabblerSportBackgroundVariant variant
        in DabblerSportBackgroundVariant.values)
      GalleryWrap(
        children: <Widget>[
          for (final DabblerSport sport in DabblerSport.values)
            GallerySpecimen(
              label: '${sport.key} · ${variant.key}',
              child: _Frame(sport: sport, variant: variant),
            ),
        ],
      ),
  ],
);

/// One specimen tile: the artwork inside the 160×284 hairline frame, or the
/// specimen's own dashed "no artwork registered yet" placeholder.
///
/// Both states are drawn because both are drawn on the design page — it shows
/// eleven populated frames and two placeholders. **This package registers no
/// artwork at all**, so every frame here is the placeholder. That is the
/// component behaving correctly (an unpopulated sport returns null and never
/// substitutes another sport's art), not a rendering failure; the delta is that
/// the design's own bundle ships the PNGs and this one does not.
class _Frame extends StatelessWidget {
  const _Frame({required this.sport, required this.variant});

  final DabblerSport sport;
  final DabblerSportBackgroundVariant variant;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool registered =
        DabblerSportBackgroundRegistry.resolve(sport, variant: variant) != null;
    return SizedBox(
      width: _frameWidth,
      height: _frameHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: DabblerRadius.lgAll,
          border: Border.all(color: colors.borderDefault),
        ),
        child: ClipRRect(
          borderRadius: DabblerRadius.lgAll,
          child: registered
              ? DabblerSportBackground(sport, variant: variant)
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(DabblerSpacing.space4),
                    child: Text(
                      'no ${variant.key} artwork registered yet\n'
                      'sport="${sport.key}"',
                      textAlign: TextAlign.center,
                      style: DabblerType.caption2
                          .resolveForDirection(Directionality.of(context))
                          .copyWith(color: colors.textTertiary),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
