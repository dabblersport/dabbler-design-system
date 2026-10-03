/// Gallery entry for [DabblerSwipeAction] (KAN-410 item a).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'swipe_action.dart';

/// SwipeAction's specimens.
const List<GalleryEntry> swipeActionGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'swipe-action',
    page: 'components/swipe-action',
    group: GalleryPurpose.actions,
    title: 'SwipeAction — swipe to reveal',
    description:
        'Drag a row toward the start to reveal its actions; tap one to '
        'fire it, or tap the row to close.',
    builder: _swipe,
  ),
];

Widget _row(BuildContext context, String text) {
  final DabblerColors colors = DabblerColors.of(context);
  return SizedBox(
    height: DabblerSpacing.space11 + DabblerSpacing.space4,
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: DabblerSpacing.space4),
        child: Text(
          text,
          style: DabblerType.body
              .resolveForDirection(Directionality.of(context))
              .copyWith(color: colors.textPrimary),
        ),
      ),
    ),
  );
}

Widget _swipe(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'one destructive action',
      child: DabblerSwipeAction(
        actions: <DabblerSwipeActionItem>[
          DabblerSwipeActionItem(
            label: 'Hide',
            icon: 'eye-slash',
            tone: DabblerSwipeActionTone.destructive,
            onPressed: () {},
          ),
        ],
        child: _row(context, 'Swipe me toward the start'),
      ),
    ),
    GallerySpecimen(
      label: 'neutral and brand',
      child: DabblerSwipeAction(
        actions: <DabblerSwipeActionItem>[
          DabblerSwipeActionItem(
            label: 'Notify',
            icon: 'notification',
            onPressed: () {},
          ),
          DabblerSwipeActionItem(
            label: 'Edit',
            icon: 'edit',
            tone: DabblerSwipeActionTone.brand,
            onPressed: () {},
          ),
        ],
        child: _row(context, 'Two actions'),
      ),
    ),
  ],
);
