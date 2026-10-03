import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

final DateTime _month = DateTime(2026, 9);

DabblerCalendarDayStatus _status(DateTime d) => switch (d.day) {
  10 => DabblerCalendarDayStatus.available,
  11 => DabblerCalendarDayStatus.limited,
  12 => DabblerCalendarDayStatus.full,
  _ => DabblerCalendarDayStatus.none,
};

Finder _markIn(int day) => find.descendant(
  of: find.byKey(DabblerCalendar.dayKey(DateTime(2026, 9, day))),
  matching: find.byType(DabblerCalendarDayStatusMark),
);

Text _numberIn(WidgetTester t, int day) => t.widget<Text>(
  find.descendant(
    of: find.byKey(DabblerCalendar.dayKey(DateTime(2026, 9, day))),
    matching: find.text('$day'),
  ),
);

void main() {
  group('mapping', () {
    test('status → existing status tones', () {
      expect(
        DabblerCalendarDayStatusStyle.toneFor(
          DabblerCalendarDayStatus.available,
        ),
        DabblerStatusTone.success,
      );
      expect(
        DabblerCalendarDayStatusStyle.toneFor(DabblerCalendarDayStatus.limited),
        DabblerStatusTone.warning,
      );
      expect(
        DabblerCalendarDayStatusStyle.toneFor(DabblerCalendarDayStatus.full),
        DabblerStatusTone.error,
      );
      expect(
        DabblerCalendarDayStatusStyle.toneFor(DabblerCalendarDayStatus.none),
        isNull,
      );
    });

    test('colour is base, or onBrand when selected', () {
      final DabblerColors c = colorsFor();
      expect(
        DabblerCalendarDayStatusStyle.colorFor(
          c,
          DabblerCalendarDayStatus.full,
        ),
        c.error.base,
      );
      expect(
        DabblerCalendarDayStatusStyle.colorFor(
          c,
          DabblerCalendarDayStatus.full,
          selected: true,
        ),
        c.onBrand,
      );
    });

    test('labels: override, then default, none has none', () {
      expect(
        DabblerCalendarDayStatusStyle.labelFor(
          DabblerCalendarDayStatus.full,
          <DabblerCalendarDayStatus, String>{
            DabblerCalendarDayStatus.full: 'محجوز',
          },
        ),
        'محجوز',
      );
      expect(
        DabblerCalendarDayStatusStyle.labelFor(
          DabblerCalendarDayStatus.limited,
        ),
        'Limited availability',
      );
      expect(
        DabblerCalendarDayStatusStyle.labelFor(DabblerCalendarDayStatus.none),
        isNull,
      );
    });
  });

  for (final TextDirection dir in TextDirection.values) {
    testWidgets('marks, strike-through and semantics (${dir.name})', (
      WidgetTester t,
    ) async {
      final SemanticsHandle h = t.ensureSemantics();
      await t.pumpWidget(
        host(
          DabblerCalendar(
            month: _month,
            onSelect: (_) {},
            showActions: false,
            dayStatus: _status,
          ),
          direction: dir,
        ),
      );
      expect(t.takeException(), isNull);
      expect(_markIn(10), findsOneWidget);
      expect(_markIn(11), findsOneWidget);
      expect(_markIn(12), findsOneWidget);
      expect(_markIn(13), findsNothing);

      expect(_numberIn(t, 12).style!.decoration, TextDecoration.lineThrough);
      expect(
        _numberIn(t, 10).style!.decoration,
        isNot(TextDecoration.lineThrough),
      );

      // Shapes differ — a non-colour cue.
      expect(t.getSize(_markIn(10)), t.getSize(_markIn(11)));
      expect(
        t.getSize(_markIn(12)).width,
        greaterThan(t.getSize(_markIn(10)).width),
      );

      expect(find.bySemanticsLabel('10, Available'), findsOneWidget);
      expect(find.bySemanticsLabel('12, Fully booked'), findsOneWidget);
      expect(find.bySemanticsLabel('13'), findsOneWidget);
      h.dispose();
    });
  }

  testWidgets('selection visuals kept; mark goes onBrand', (
    WidgetTester t,
  ) async {
    DateTime? picked;
    await t.pumpWidget(
      host(
        DabblerCalendar(
          month: _month,
          selected: <DateTime>{DateTime(2026, 9, 11)},
          onSelect: (DateTime d) => picked = d,
          showActions: false,
          dayStatus: _status,
        ),
      ),
    );
    final DabblerCalendarDayStatusMark mark = t.widget(_markIn(11));
    expect(mark.color, colorsFor().onBrand);
    expect(_numberIn(t, 11).style!.color, colorsFor().onBrand);
    await t.tap(find.byKey(DabblerCalendar.dayKey(DateTime(2026, 9, 12))));
    expect(picked, DateTime(2026, 9, 12));
  });

  testWidgets('without dayStatus nothing is drawn', (WidgetTester t) async {
    await t.pumpWidget(host(DabblerCalendar(month: _month)));
    expect(find.byType(DabblerCalendarDayStatusMark), findsNothing);
  });

  testWidgets('outside days are never asked', (WidgetTester t) async {
    final List<DateTime> asked = <DateTime>[];
    await t.pumpWidget(
      host(
        DabblerCalendar(
          month: _month,
          dayStatus: (DateTime d) {
            asked.add(d);
            return DabblerCalendarDayStatus.available;
          },
        ),
      ),
    );
    expect(asked.every((DateTime d) => d.month == 9), isTrue);
    expect(asked.length, 30);
  });
}
