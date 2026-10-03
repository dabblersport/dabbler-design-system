/// Gallery entry for [DabblerCalendar]'s per-day availability marks (Alpha DS
/// gaps 6, item 10). No design frame draws this; see
/// [DabblerCalendarDayStatus].
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'calendar.dart';
import 'calendar_day_status.dart';

/// Day-status specimens.
const List<GalleryEntry> calendarStatusGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'calendar/day-status',
    page: 'components/calendar',
    group: GalleryPurpose.dateAndTime,
    title: 'Calendar — per-day availability',
    description:
        'dayStatus: available (dot), limited (ring), full (bar, struck '
        'number); the 12th selected keeps its brand pill.',
    builder: _statuses,
  ),
];

DabblerCalendarDayStatus _status(DateTime day) => switch (day.day % 4) {
  0 => DabblerCalendarDayStatus.available,
  1 => DabblerCalendarDayStatus.limited,
  2 => DabblerCalendarDayStatus.full,
  _ => DabblerCalendarDayStatus.none,
};

Widget _statuses(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'availability marks',
      child: SizedBox(
        width: 320,
        child: DabblerCalendar(
          month: DateTime(2026, 9),
          selected: <DateTime>{DateTime(2026, 9, 12)},
          onSelect: (_) {},
          showActions: false,
          dayStatus: _status,
        ),
      ),
    ),
  ],
);
