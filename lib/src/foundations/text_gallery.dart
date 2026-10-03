/// Gallery entries for [DabblerText], [DabblerInert] and [DabblerGap] — the
/// zero-literal additions.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../interaction/inert.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_layout.dart';
import '../tokens/dabbler_type.dart';
import 'text.dart';

/// The specimens.
const List<GalleryEntry> textGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'text',
    page: 'components/text',
    group: GalleryPurpose.contentContainers,
    title: 'Text — ramp, weight and tone roles',
    description:
        'Ramp steps with weight and tone roles, a rich run with a link, and '
        'the same text in Arabic, right to left.',
    builder: _text,
  ),
  GalleryEntry(
    id: 'inert',
    page: 'components/inert',
    group: GalleryPurpose.actions,
    title: 'Inert — a disabled block',
    description:
        'The same block live and inert, at the system disabled opacity.',
    builder: _inert,
  ),
  GalleryEntry(
    id: 'gap',
    page: 'components/gap',
    group: GalleryPurpose.structure,
    title: 'Gap — one spacing step',
    description: 'Vertical and horizontal gaps taken from the spacing scale.',
    builder: _gap,
  ),
];

Widget _text(BuildContext context) {
  return GalleryStack(
    children: <Widget>[
      const GallerySpecimen(
        label: 'roles',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DabblerText('Title two', style: DabblerType.title2),
            DabblerText(
              'Headline, heavy',
              style: DabblerType.headline,
              weight: DabblerTextWeight.heavy,
            ),
            DabblerText('Body, secondary', tone: DabblerTextTone.secondary),
            DabblerText(
              'Footnote, brand',
              style: DabblerType.footnote,
              tone: DabblerTextTone.brand,
            ),
            DabblerText(
              'Caption, error',
              style: DabblerType.caption1,
              tone: DabblerTextTone.error,
            ),
          ],
        ),
      ),
      GallerySpecimen(
        label: 'rich',
        child: DabblerText.rich(
          <DabblerTextSpan>[
            const DabblerTextSpan(
              '12 ',
              weight: DabblerTextWeight.heavy,
              tone: DabblerTextTone.primary,
            ),
            const DabblerTextSpan('results · '),
            DabblerTextSpan('clear', onTap: () {}),
          ],
          style: DabblerType.footnote,
          tone: DabblerTextTone.secondary,
        ),
      ),
      const GallerySpecimen(
        label: 'Arabic, RTL',
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: DabblerText('مرحبا ١٢٣', style: DabblerType.headline),
        ),
      ),
    ],
  );
}

Widget _block(BuildContext context) {
  final DabblerColors colors = DabblerColors.of(context);
  return SizedBox(
    width: DabblerSizing.railCardWidth,
    height: DabblerSizing.tileLg,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: DabblerRadius.lgAll,
        border: Border.all(color: colors.borderDefault),
      ),
      child: const Center(child: DabblerText('Section')),
    ),
  );
}

Widget _inert(BuildContext context) {
  return GalleryWrap(
    children: <Widget>[
      GallerySpecimen(
        label: 'live',
        child: DabblerInert(inert: false, child: _block(context)),
      ),
      GallerySpecimen(
        label: 'inert',
        child: DabblerInert(inert: true, child: _block(context)),
      ),
    ],
  );
}

Widget _gap(BuildContext context) {
  return GalleryStack(
    children: <Widget>[
      GallerySpecimen(
        label: 'v(space4) between blocks',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _block(context),
            const DabblerGap.v(DabblerSpacing.space4),
            _block(context),
          ],
        ),
      ),
      GallerySpecimen(
        label: 'h(space8) between blocks',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _block(context),
            const DabblerGap.h(DabblerSpacing.space8),
            _block(context),
          ],
        ),
      ),
    ],
  );
}
