/// Gallery entries for [DabblerSheet] (KAN-259 AC2).
///
/// A sheet is a route, for the same reason the dialog's entries are triggers:
/// the detents, the drag and the scrim only exist on the real route.
library;

import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_geometry.dart';
import 'action_row.dart';
import 'sheet.dart';

/// Sheet's specimens.
const List<GalleryEntry> sheetGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'sheet/detents',
    page: 'components/sheet',
    group: GalleryPurpose.presentation,
    title: 'Sheet — detents and footer (trigger)',
    description: 'A half-height sheet, and a two-detent sheet with a footer.',
    builder: _sheets,
  ),
  GalleryEntry(
    id: 'sheet/content',
    page: 'components/sheet',
    group: GalleryPurpose.presentation,
    title: 'Sheet — content-sized (trigger)',
    description:
        'A short sheet that is only as tall as its content, and a long one '
        'that stops at the 80% cap and scrolls.',
    builder: _contentSheets,
  ),
  GalleryEntry(
    id: 'action-row',
    page: 'components/action-row',
    group: GalleryPurpose.presentation,
    title: 'ActionRow — one action in a sheet',
    description:
        'A default action with a note, a destructive action, one without a '
        'note, and an Arabic row in RTL.',
    builder: _actionRows,
  ),
];

void _noopAction() {}

Widget _actionRows(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'default with a note',
      child: SizedBox(
        width: 360,
        child: DabblerActionRow(
          icon: 'eye-slash',
          label: 'Hide post',
          note: 'You will see fewer posts like this',
          onTap: _noopAction,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'destructive',
      child: SizedBox(
        width: 360,
        child: DabblerActionRow(
          icon: 'danger',
          label: 'Report post',
          note: 'Tell us what is wrong with this post',
          destructive: true,
          onTap: _noopAction,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'selected',
      child: SizedBox(
        width: 360,
        child: DabblerActionRow(
          icon: 'tick-circle',
          label: 'Yes, I am going',
          selected: true,
          onTap: _noopAction,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'no note',
      child: SizedBox(
        width: 360,
        child: DabblerActionRow(
          icon: 'user-remove',
          label: 'Block user',
          destructive: true,
          onTap: _noopAction,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'Arabic, right-to-left',
      child: SizedBox(
        width: 360,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: DabblerActionRow(
            icon: 'eye-slash',
            label: 'إخفاء المنشور',
            note: 'سترى منشورات أقل من هذا النوع',
            onTap: _noopAction,
          ),
        ),
      ),
    ),
  ],
);

Widget _contentSheets(BuildContext context) => GalleryWrap(
  children: <Widget>[
    GallerySpecimen(
      label: 'short, content-sized',
      child: Builder(
        builder: (BuildContext context) => DabblerButton(
          label: 'Open short sheet',
          onPressed: () => showDabblerSheet<void>(
            context: context,
            title: 'Sort',
            detent: DabblerSheetDetent.content,
            builder: _body,
          ),
        ),
      ),
    ),
    GallerySpecimen(
      label: 'tall, capped and scrolling',
      child: Builder(
        builder: (BuildContext context) => DabblerButton(
          label: 'Open tall sheet',
          onPressed: () => showDabblerSheet<void>(
            context: context,
            title: 'Filters',
            detent: DabblerSheetDetent.content,
            builder: (BuildContext context) => Column(
              children: <Widget>[
                for (int i = 0; i < 30; i++) Text('Option $i'),
              ],
            ),
            footerBuilder: (BuildContext context) => DabblerButton(
              label: 'Apply',
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
    ),
  ],
);

Widget _sheets(BuildContext context) => GalleryWrap(
  children: <Widget>[
    GallerySpecimen(
      label: 'single detent',
      child: Builder(
        builder: (BuildContext context) => DabblerButton(
          label: 'Open sheet',
          onPressed: () => showDabblerSheet<void>(
            context: context,
            title: 'Filters',
            builder: _body,
          ),
        ),
      ),
    ),
    GallerySpecimen(
      label: 'header action — Reset (DS gaps 6)',
      child: Builder(
        builder: (BuildContext context) => DabblerButton(
          label: 'Open filters',
          onPressed: () => showDabblerSheet<void>(
            context: context,
            title: 'Filters',
            detent: DabblerSheetDetent.content,
            headerActionBuilder: (BuildContext context) => DabblerButton(
              label: 'Reset',
              tone: DabblerButtonTone.neutral,
              size: DabblerButtonSize.small,
              onPressed: () {},
            ),
            builder: _body,
          ),
        ),
      ),
    ),
    GallerySpecimen(
      label: 'two detents, with a footer',
      child: Builder(
        builder: (BuildContext context) => DabblerButton(
          label: 'Open tall sheet',
          onPressed: () => showDabblerSheet<void>(
            context: context,
            title: 'Pick a sport',
            detents: <double>[0.4, 0.9],
            builder: _body,
            footerBuilder: (BuildContext context) => DabblerButton(
              label: 'Apply',
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
    ),
  ],
);

Widget _body(BuildContext context) => const Padding(
  padding: EdgeInsets.all(DabblerSpacing.space6),
  child: Text('Sheet content.'),
);
