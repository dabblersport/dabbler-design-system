/// Gallery entry for [DabblerCalendar]'s opt-in year picker (Alpha DS gaps 5,
/// item 10).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'calendar.dart';

/// Year-picker specimens.
const List<GalleryEntry> calendarYearGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'calendar/year-picker',
    page: 'components/calendar',
    group: GalleryPurpose.dateAndTime,
    title: 'Calendar — built-in year picker',
    description:
        'yearPicker: true — tap the year chip to jump years; the year grid '
        'on its own.',
    builder: _years,
  ),
];

Widget _years(BuildContext context) => GalleryStack(
  children: <Widget>[
    const GallerySpecimen(
      label: 'interactive — tap the year chip',
      child: SizedBox(width: 320, child: _LiveCalendar()),
    ),
    GallerySpecimen(
      label: 'the year grid',
      child: SizedBox(
        width: 290,
        child: DabblerCalendarYearGrid(
          firstYear: 2020,
          lastYear: 2032,
          selectedYear: 2026,
          onYearSelected: (_) {},
        ),
      ),
    ),
  ],
);

class _LiveCalendar extends StatefulWidget {
  const _LiveCalendar();

  @override
  State<_LiveCalendar> createState() => _LiveCalendarState();
}

class _LiveCalendarState extends State<_LiveCalendar> {
  DateTime _month = DateTime(2026, 9);

  @override
  Widget build(BuildContext context) => DabblerCalendar(
    month: _month,
    yearPicker: true,
    showActions: false,
    onMonthChanged: (DateTime m) => setState(() => _month = m),
  );
}
