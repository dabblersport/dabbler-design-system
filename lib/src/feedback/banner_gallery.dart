/// Gallery entries for [DabblerBanner] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'banner.dart';

/// Banner's specimens.
const List<GalleryEntry> bannerGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Banner — tones',
    description: 'Every DabblerBannerTone, plus an action and a dismiss.',
    builder: _banners,
  ),
];

Widget _banners(BuildContext context) => GalleryStack(
  children: <Widget>[
    for (final DabblerBannerTone tone in DabblerBannerTone.values)
      GallerySpecimen(
        label: tone.name,
        child: DabblerBanner(
          tone: tone,
          title: 'Heads up',
          message: 'Your game starts in 20 minutes.',
        ),
      ),
    GallerySpecimen(
      label: 'with action and dismiss',
      child: DabblerBanner(
        message: 'Payment failed.',
        action: DabblerBannerAction(label: 'Retry', onPressed: _noop),
        onDismiss: _noop,
      ),
    ),
  ],
);

void _noop() {}
