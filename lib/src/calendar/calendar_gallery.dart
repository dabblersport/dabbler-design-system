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
    id: 'calendar',
    page: 'components/calendar',
    group: GalleryPurpose.dateAndTime,
    title: 'Calendar — month grid',
    description:
        'A fixed month so the specimen does not change under review, '
        'with and without the confirm/cancel actions.',
    builder: _calendars,
  ),
  GalleryEntry(
    id: 'time-picker',
    page: 'components/time-picker',
    group: GalleryPurpose.dateAndTime,
    title: 'TimePicker — hour, minute, period',
    description:
        'The D-030 listbox: hour and minute columns and a meridiem pill at '
        'the default minute step.',
    builder: _timePickers,
  ),
  GalleryEntry(
    id: 'time-picker/ruler',
    page: 'components/time-picker',
    group: GalleryPurpose.dateAndTime,
    title: 'TimeRuler — opt-in drag ruler',
    description:
        'Opt-in only, not the D-030 component: the live TimePicker.jsx '
        'Ruler geometry, fidelity unverified.',
    builder: _timeRulers,
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

Widget _timeRulers(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'opt-in ruler (not the D-030 component)',
      child: DabblerTimeRuler(value: const TimeOfDay(hour: 18, minute: 30)),
    ),
  ],
);
