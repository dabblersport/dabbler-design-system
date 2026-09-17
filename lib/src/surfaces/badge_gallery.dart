/// Gallery entries for [DabblerBadge] (KAN-259 AC2).
///
/// The rows mirror the design specimen
/// `components/surfaces/identity-status.card.html` → *"Badges — status &
/// labels"*: the eight decorative tones labelled with **their own names**, and
/// the five semantic statuses with the specimen's own words. The previous
/// entry showed the tones only, every one reading "Upcoming", and omitted the
/// `status` row entirely — the half of the component that carries meaning.
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'badge.dart';

/// Badge's specimens.
const List<GalleryEntry> badgeGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Badge — tones and statuses',
    description: 'tone — decorative, the kit\'s own non-semantic names. '
        'status — semantic, overrides tone.',
    builder: _badges,
  ),
];

Widget _badges(BuildContext context) => GalleryStack(
  children: <Widget>[
    GalleryWrap(
      children: <Widget>[
        for (final DabblerBadgeTone tone in DabblerBadgeTone.values)
          GallerySpecimen(
            label: tone.name,
            // The specimen labels each decorative badge with its own tone
            // name, which is the point of keeping the Figma vocabulary.
            child: _decorative(tone),
          ),
      ],
    ),
    GalleryWrap(
      children: <Widget>[
        for (final (String label, String name, DabblerStatusTone? tone,
                String? icon) in _statuses)
          GallerySpecimen(
            label: name,
            child: Builder(
              builder: (BuildContext context) {
                final DabblerColors colors = DabblerColors.of(context);
                return DabblerBadge(
                  label: label,
                  // `neutral` is the source's fifth status and is deliberately
                  // outside the `--color-status-*` API, so it comes from
                  // Badge's own accessor rather than from the enum.
                  status: tone == null
                      ? DabblerBadge.neutralStatusOf(colors)
                      : colors.status(tone),
                  icon: icon == null
                      ? null
                      : DabblerIcon(icon, size: _statusIconSize),
                );
              },
            ),
          ),
      ],
    ),
  ],
);

/// `<Icon … size={12} />` on both icon-bearing badges in the specimen.
const double _statusIconSize = 12;

/// `<Badge status="…">…</Badge>`, in the specimen's order and wording.
const List<(String, String, DabblerStatusTone?, String?)> _statuses =
    <(String, String, DabblerStatusTone?, String?)>[
  ('draft', 'neutral', null, null),
  ('confirmed', 'success', DabblerStatusTone.success, 'tick-circle'),
  ('2 spots left', 'warning', DabblerStatusTone.warning, null),
  ('cancelled', 'error', DabblerStatusTone.error, null),
  ('waitlist', 'info', DabblerStatusTone.info, null),
];

/// One decorative badge, reproducing the specimen's two special cases: `pill`
/// carries a 6px `currentColor` dot, `withIcon` a bold 12px `star`.
Widget _decorative(DabblerBadgeTone tone) => switch (tone) {
      DabblerBadgeTone.pill => DabblerBadge(
          label: 'live',
          tone: tone,
          icon: const _Dot(),
        ),
      DabblerBadgeTone.withIcon => DabblerBadge(
          label: 'withIcon',
          tone: tone,
          icon: const DabblerIcon(
            'star',
            weight: DabblerIconWeight.bold,
            size: _statusIconSize,
          ),
        ),
      _ => DabblerBadge(label: tone.name, tone: tone),
    };

/// The specimen's inline `live` dot: `width:6, height:6, borderRadius:9999,
/// background: currentColor` — so it takes the badge's own ink.
class _Dot extends StatelessWidget {
  const _Dot();

  /// `width: 6, height: 6` — [DabblerSpacing.space2].
  static const double diameter = DabblerSpacing.space2;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: diameter,
        height: diameter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            // `currentColor` — the badge sets the icon theme to its own ink.
            color: IconTheme.of(context).color,
            borderRadius: DabblerRadius.pillAll,
          ),
        ),
      );
}
