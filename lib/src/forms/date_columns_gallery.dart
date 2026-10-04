/// Gallery entries for [DabblerDateColumns].
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'date_columns.dart';

/// DateColumns specimens.
const List<GalleryEntry> dateColumnsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'date-columns',
    page: 'components/date-columns',
    group: GalleryPurpose.dateAndTime,
    title: 'DateColumns — day, month and year in three lists',
    description:
        'Nothing chosen, then a full date; the chosen option is brand-filled.',
    builder: _columns,
  ),
];

const double _width = 320;

const List<String> _months = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

Widget _columns(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'empty — tap to choose',
      child: SizedBox(width: _width, child: _Demo()),
    ),
    GallerySpecimen(
      label: 'chosen',
      child: SizedBox(
        width: _width,
        child: _Demo(day: 3, month: 3, year: 2010),
      ),
    ),
  ],
);

class _Demo extends StatefulWidget {
  const _Demo({this.day, this.month, this.year});

  final int? day;
  final int? month;
  final int? year;

  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  late int? _day = widget.day;
  late int? _month = widget.month;
  late int? _year = widget.year;

  @override
  Widget build(BuildContext context) => DabblerDateColumns(
    dayLabel: 'Day',
    monthLabel: 'Month',
    yearLabel: 'Year',
    monthNames: _months,
    firstYear: 1950,
    lastYear: 2010,
    day: _day,
    month: _month,
    year: _year,
    onDayChanged: (int d) => setState(() => _day = d),
    onMonthChanged: (int m) => setState(() => _month = m),
    onYearChanged: (int y) => setState(() => _year = y),
  );
}
