/// Gallery entries for [DabblerRating].
///
/// The rows mirror the design specimen
/// `components/surfaces/identity-status.card.html` → *"Ratings — evaluation"*
/// value for value, so a reviewer sees what that page shows.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'rating.dart';

/// Rating's specimens.
const List<GalleryEntry> ratingGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'rating',
    page: 'components/rating',
    group: GalleryPurpose.identityAndStatus,
    title: 'Rating — evaluation',
    description: 'Read-only (value, halves, count, sizes) and the interactive '
        'radio group, as the identity specimen draws them.',
    builder: _ratings,
  ),
];

Widget _ratings(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GalleryWrap(
      children: <Widget>[
        // `<Rating value={4.2} count={128} showValue size="sm" />`
        GallerySpecimen(
          label: '4.2 · count · sm',
          child: DabblerRating(
            value: 4.2,
            count: 128,
            showValue: true,
            size: DabblerRatingSize.sm,
          ),
        ),
        // `<Rating value={3.5} />` — the clipped half.
        GallerySpecimen(
          label: '3.5 — half',
          child: DabblerRating(value: 3.5),
        ),
        // `<Rating value={5} size="lg" />`
        GallerySpecimen(
          label: '5 · lg',
          child: DabblerRating(value: 5, size: DabblerRatingSize.lg),
        ),
        // `<Rating value={0} />`
        GallerySpecimen(label: '0 — empty', child: DabblerRating()),
      ],
    ),
    GalleryWrap(
      children: <Widget>[
        GallerySpecimen(
          label: 'interactive — a real radio group',
          child: _InteractiveRating(),
        ),
      ],
    ),
  ],
);

/// The specimen's interactive row: an `lg` rating plus the live `current: N`
/// readout beside it.
class _InteractiveRating extends StatefulWidget {
  const _InteractiveRating();

  @override
  State<_InteractiveRating> createState() => _InteractiveRatingState();
}

class _InteractiveRatingState extends State<_InteractiveRating> {
  int _rating = 4;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        DabblerRating(
          value: _rating.toDouble(),
          size: DabblerRatingSize.lg,
          label: 'rate this game',
          onChanged: (int next) => setState(() => _rating = next),
        ),
        const SizedBox(width: DabblerSpacing.space4),
        Text(
          'current: $_rating',
          style: DabblerType.caption1
              .resolveForDirection(Directionality.of(context))
              .copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
