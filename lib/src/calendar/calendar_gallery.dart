/// Gallery entries for [DabblerCalendar] and [DabblerTimePicker] (KAN-259 AC2).
library;

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'calendar.dart';
import 'time_picker.dart';

/// Calendar's specimens.
const List<GalleryEntry> calendarGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Calendar — month grid',
    description: 'A fixed month so the specimen does not change under review, '
        'with and without the confirm/cancel actions.',
    builder: _calendars,
  ),
  GalleryEntry(
    title: 'TimePicker — hour, minute, period',
    description: 'The three wheels at the default minute step.',
    builder: _timePickers,
  ),
];

/// A fixed month, so the gallery renders the same grid on every run rather
/// than drifting with the clock.
final DateTime _month = DateTime(2026, 9);

Widget _calendars(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'with actions',
      child: DabblerCalendar(
        month: _month,
        selected: <DateTime>{DateTime(2026, 9, 17)},
      ),
    ),
    GallerySpecimen(
      label: 'without actions',
      child: DabblerCalendar(month: _month, showActions: false),
    ),
  ],
);

Widget _timePickers(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'default',
      child: SizedBox(
        height: 340,
        child: DabblerTimePicker(value: const TimeOfDay(hour: 18, minute: 30)),
      ),
    ),
  ],
);
