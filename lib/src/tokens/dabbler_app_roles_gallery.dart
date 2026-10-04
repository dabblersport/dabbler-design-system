/// Gallery entries for the app-role tokens added to [DabblerMotion],
/// [DabblerSizing] and [DabblerSpacing] in the zero-literal pass: each name
/// with its value, tabulated.
library;

import 'package:flutter/widgets.dart';

import '../foundations/text.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'dabbler_geometry.dart';
import 'dabbler_motion.dart';
import 'dabbler_type.dart';

/// The specimens.
const List<GalleryEntry> appRolesGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'motion/app-roles',
    page: 'foundations/motion',
    group: null,
    title: 'Motion — app roles',
    description: 'Every named duration the app uses, by purpose.',
    builder: _motion,
  ),
  GalleryEntry(
    id: 'spacing-geometry/app-roles',
    page: 'foundations/spacing-geometry',
    group: null,
    title: 'Sizing — app roles',
    description: 'Every named size and layout extent the app uses.',
    builder: _sizing,
  ),
];

/// The motion app roles, in declaration order.
const Map<String, Duration> motionAppRoles = <String, Duration>{
  'contentSwap': DabblerMotion.contentSwap,
  'scrollTo': DabblerMotion.scrollTo,
  'snapBack': DabblerMotion.snapBack,
  'pageTransition': DabblerMotion.pageTransition,
  'pageTransitionSlide': DabblerMotion.pageTransitionSlide,
  'pageTransitionModal': DabblerMotion.pageTransitionModal,
  'heroCrossfade': DabblerMotion.heroCrossfade,
  'screenEntrance': DabblerMotion.screenEntrance,
  'ambientLoop': DabblerMotion.ambientLoop,
  'toastBrief': DabblerMotion.toastBrief,
  'toastShort': DabblerMotion.toastShort,
  'toastLong': DabblerMotion.toastLong,
  'autoAdvance': DabblerMotion.autoAdvance,
  'autoAdvanceHero': DabblerMotion.autoAdvanceHero,
  'debounceSearch': DabblerMotion.debounceSearch,
  'debounceValidation': DabblerMotion.debounceValidation,
  'debounceSuggestion': DabblerMotion.debounceSuggestion,
  'timeoutShort': DabblerMotion.timeoutShort,
  'timeoutNetwork': DabblerMotion.timeoutNetwork,
  'pollInterval': DabblerMotion.pollInterval,
  'delayFrame': DabblerMotion.delayFrame,
  'delaySettle': DabblerMotion.delaySettle,
  'delayRetry': DabblerMotion.delayRetry,
  'delayRetryLong': DabblerMotion.delayRetryLong,
  'delayRetryMax': DabblerMotion.delayRetryMax,
};

/// Sizes the design draws **off** the base-3 grid, kept as named tokens
/// outside [sizingAppRoles] on purpose: `D-018` is the precedent that a
/// drawing overrides the grid, and the CXO ruled the Search result tile 40
/// (`Search.dc.html:262`). Every entry is pinned and is *not* a multiple of 3;
/// the `% 3` test over [sizingAppRoles] is unchanged.
const Map<String, double> sizingOffGridRulings = <String, double>{
  'resultTile': DabblerSizing.resultTile,
  'articleHeroHeight': DabblerSizing.articleHeroHeight,
  'mediaRailHeight': DabblerSizing.mediaRailHeight,
  'mediaRailAddWidth': DabblerSizing.mediaRailAddWidth,
  'mediaRailTileWidth': DabblerSizing.mediaRailTileWidth,
  'navItem': DabblerSizing.navItem,
  'navBarHeight': DabblerSizing.navBarHeight,
  'navGlyphLarge': DabblerSizing.navGlyphLarge,
  'navCreateTile': DabblerSizing.navCreateTile,
  'navFadeHeight': DabblerSizing.navFadeHeight,
};

/// The sizing and layout-extent app roles, in declaration order.
const Map<String, double> sizingAppRoles = <String, double>{
  'iconXs': DabblerSizing.iconXs,
  'iconInline': DabblerSizing.iconInline,
  'iconRow': DabblerSizing.iconRow,
  'iconXl': DabblerSizing.iconXl,
  'tileMd': DabblerSizing.tileMd,
  'tileLg': DabblerSizing.tileLg,
  'illustrationSm': DabblerSizing.illustrationSm,
  'illustrationMd': DabblerSizing.illustrationMd,
  'illustrationLg': DabblerSizing.illustrationLg,
  'dot': DabblerSizing.dot,
  'swatch': DabblerSizing.swatch,
  'indicatorThickness': DabblerSizing.indicatorThickness,
  'thumbnail': DabblerSizing.thumbnail,
  'optionTileHeight': DabblerSizing.optionTileHeight,
  'labelColumnWidth': DabblerSizing.labelColumnWidth,
  'heroCoverHeight': DabblerSizing.heroCoverHeight,
  'mediaPreviewHeight': DabblerSizing.mediaPreviewHeight,
  'mediaPreviewCompactHeight': DabblerSizing.mediaPreviewCompactHeight,
  'mediaRowHeight': DabblerSizing.mediaRowHeight,
  'loadingBlockHeight': DabblerSizing.loadingBlockHeight,
  'railCardWidth': DabblerSizing.railCardWidth,
  'railCardHeight': DabblerSizing.railCardHeight,
  'skeletonTitleHeight': DabblerSizing.skeletonTitleHeight,
  'skeletonLineHeight': DabblerSizing.skeletonLineHeight,
  'skeletonBlockHeight': DabblerSizing.skeletonBlockHeight,
  'skeletonWidthLong': DabblerSizing.skeletonWidthLong,
  'skeletonWidthMedium': DabblerSizing.skeletonWidthMedium,
  'skeletonWidthShort': DabblerSizing.skeletonWidthShort,
  'skeletonWidthMeta': DabblerSizing.skeletonWidthMeta,
  'listBottomInset': DabblerSpacing.listBottomInset,
  'floatingBarClearance': DabblerSpacing.floatingBarClearance,
  'stickyActionBarClearance': DabblerSpacing.stickyActionBarClearance,
};

Widget _table(List<MapEntry<String, String>> rows) => GallerySpecimen(
  label: 'name and value',
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      for (final MapEntry<String, String> row in rows)
        DabblerText(
          '${row.key}  ${row.value}',
          style: DabblerType.footnote,
          tone: DabblerTextTone.secondary,
        ),
    ],
  ),
);

Widget _motion(BuildContext context) => _table(<MapEntry<String, String>>[
  for (final MapEntry<String, Duration> e in motionAppRoles.entries)
    MapEntry<String, String>(e.key, '${e.value.inMilliseconds}ms'),
]);

Widget _sizing(BuildContext context) => _table(<MapEntry<String, String>>[
  for (final MapEntry<String, double> e in sizingAppRoles.entries)
    MapEntry<String, String>(e.key, e.value.toStringAsFixed(0)),
  for (final MapEntry<String, double> e in sizingOffGridRulings.entries)
    MapEntry<String, String>(
      '${e.key} (off-grid ruling)',
      e.value.toStringAsFixed(0),
    ),
]);
