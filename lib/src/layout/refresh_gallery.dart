/// Gallery entries for [DabblerRefresh] and [DabblerTabPager] (KAN-409 item 3).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'refresh.dart';
import 'tab_pager.dart';
import 'tabs.dart';

/// Refresh's and TabPager's specimens.
const List<GalleryEntry> refreshGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'refresh',
    page: 'components/refresh',
    group: GalleryPurpose.statusAndFeedback,
    title: 'Refresh — pull to refresh',
    description:
        'Pull the list down: the brand Spinner draws while the pull '
        'is armed and while the refresh runs.',
    builder: _refresh,
  ),
  GalleryEntry(
    id: 'tab-pager',
    page: 'components/tab-pager',
    group: GalleryPurpose.navigation,
    title: 'TabPager — tabs over swipeable pages',
    description:
        'Tap a tab or swipe the body; each page keeps its own scroll '
        'position.',
    builder: _pager,
  ),
];

/// The specimens' fixed body height — five rows of [DabblerSpacing.space11].
const double _height = DabblerSpacing.space11 * 5;

Widget _rows(BuildContext context, String prefix) {
  final DabblerColors colors = DabblerColors.of(context);
  return ListView.builder(
    itemCount: 20,
    itemBuilder: (BuildContext context, int i) => SizedBox(
      height: DabblerSpacing.space11,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: DabblerSpacing.space4,
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            '$prefix ${i + 1}',
            style: DabblerType.body
                .resolveForDirection(Directionality.of(context))
                .copyWith(color: colors.textPrimary),
          ),
        ),
      ),
    ),
  );
}

Widget _refresh(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'pull down',
      child: SizedBox(
        height: _height,
        child: DabblerRefresh(
          onRefresh: () => Future<void>.delayed(const Duration(seconds: 1)),
          child: _rows(context, 'Row'),
        ),
      ),
    ),
  ],
);

const List<DabblerTabItem> _tabs = <DabblerTabItem>[
  DabblerTabItem(id: 'for-you', label: 'For you'),
  DabblerTabItem(id: 'following', label: 'Following'),
  DabblerTabItem(id: 'nearby', label: 'Nearby'),
];

Widget _pager(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'underline',
      child: SizedBox(
        height: _height,
        child: DabblerTabPager(
          items: _tabs,
          pages: <Widget>[
            for (final DabblerTabItem t in _tabs) _rows(context, t.label),
          ],
        ),
      ),
    ),
  ],
);
