// DabblerPostRow place line: a blank `place` hides the spacer after the time,
// the location glyph, its gap and the place text together. The 'global' glyph
// and the time stay; the row height does not change.
//
// Golden heights were captured on the code BEFORE the change (place 'Nad Al
// Sheba' and 'ند الشبا'): LTR touch 146, drawn 175; RTL (Arabic type metrics)
// touch 152, drawn 181.
import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'thread_host.dart';

const String _arPlace = 'ند الشبا';
const Map<TextDirection, Map<DabblerFeedMetrics, double>> _golden =
    <TextDirection, Map<DabblerFeedMetrics, double>>{
      TextDirection.ltr: <DabblerFeedMetrics, double>{
        DabblerFeedMetrics.touch: 146,
        DabblerFeedMetrics.drawn: 175,
      },
      TextDirection.rtl: <DabblerFeedMetrics, double>{
        DabblerFeedMetrics.touch: 152,
        DabblerFeedMetrics.drawn: 181,
      },
    };

DabblerPostRow _post({
  required String place,
  String time = '2h',
  DabblerFeedMetrics metrics = DabblerFeedMetrics.touch,
}) => DabblerPostRow(
  metrics: metrics,
  name: 'Suraj Mehta',
  time: time,
  place: place,
  body: 'Anyone playing?',
  sportLabel: 'Cricket',
);

Finder _glyph(String name) =>
    find.byWidgetPredicate((Widget w) => w is DabblerIcon && w.name == name);

Finder _metaRow(String time) =>
    find.ancestor(of: find.text(time), matching: find.byType(Row)).first;

Future<void> _pump(
  WidgetTester tester,
  DabblerPostRow row,
  TextDirection dir,
) => tester.pumpWidget(threadHost(row, direction: dir));

void main() {
  setUp(() => DabblerAvatar.portrait = const DabblerPlaceholderPortrait());
  tearDown(() => DabblerAvatar.portrait = const DabblerRandomAvatarPortrait());

  for (final TextDirection dir in TextDirection.values) {
    final bool rtl = dir == TextDirection.rtl;
    final String real = rtl ? _arPlace : 'Nad Al Sheba';

    group('PostRow place — $dir', () {
      for (final String blank in <String>['', '   ', '\t\n ', ' \n']) {
        testWidgets('blank place ${blank.codeUnits} hides glyph, gap, text', (
          WidgetTester tester,
        ) async {
          await _pump(tester, _post(place: blank), dir);
          expect(_glyph('location'), findsNothing);
          expect(_glyph('global'), findsOneWidget);
          expect(find.text('2h'), findsOneWidget);
          // The meta row is exactly: global glyph, gap, time. Nothing after.
          final Row meta = tester.widget<Row>(_metaRow('2h'));
          expect(meta.children.length, 3);
          expect(meta.children.last, isA<Text>());
          expect((meta.children.last as Text).data, '2h');
          // [glyph, gap, time]: no trailing spacer, glyph or gap.
          expect(meta.children[0], isA<ExcludeSemantics>());
          expect(meta.children[1], isA<SizedBox>());
          expect((meta.children[1] as SizedBox).width, 6);
        });
      }

      testWidgets('a real place shows glyph, gap and text', (
        WidgetTester tester,
      ) async {
        await _pump(tester, _post(place: real), dir);
        expect(_glyph('location'), findsOneWidget);
        expect(_glyph('global'), findsOneWidget);
        expect(find.text(real), findsOneWidget);
        final Row meta = tester.widget<Row>(_metaRow('2h'));
        // global, gap, time, spacer, spacer, location, gap, place.
        expect(meta.children.length, 8);
        expect(meta.children.last, isA<Flexible>());
      });

      testWidgets('a name with outer blanks is shown as given', (
        WidgetTester tester,
      ) async {
        await _pump(tester, _post(place: ' $real '), dir);
        expect(_glyph('location'), findsOneWidget);
        expect(find.text(' $real '), findsOneWidget);
      });

      testWidgets('the global glyph and the time are unchanged by the rule', (
        WidgetTester tester,
      ) async {
        await _pump(tester, _post(place: real), dir);
        final Rect globalWith = tester.getRect(_glyph('global'));
        final Rect timeWith = tester.getRect(find.text('2h'));
        await _pump(tester, _post(place: ''), dir);
        expect(tester.getRect(_glyph('global')), globalWith);
        expect(tester.getRect(find.text('2h')), timeWith);
        expect(tester.getSize(_glyph('global')), const Size(13, 13));
      });

      testWidgets('nothing sits after the time when the place is blank', (
        WidgetTester tester,
      ) async {
        await _pump(tester, _post(place: ''), dir);
        final Finder inMeta = find.descendant(
          of: _metaRow('2h'),
          matching: find.byType(DabblerIcon),
        );
        expect(inMeta, findsOneWidget, reason: 'only the global glyph');
        expect(
          find.descendant(of: _metaRow('2h'), matching: find.byType(Text)),
          findsOneWidget,
          reason: 'the time is the only text in the line',
        );
      });

      for (final DabblerFeedMetrics m in DabblerFeedMetrics.values) {
        final double golden = _golden[dir]![m]!;
        testWidgets('row height is unchanged, blank or named — $m', (
          WidgetTester tester,
        ) async {
          await _pump(tester, _post(place: real, metrics: m), dir);
          expect(tester.getSize(find.byType(DabblerPostRow)).height, golden);
          final double metaWith = tester.getSize(_metaRow('2h')).height;
          await _pump(tester, _post(place: '', metrics: m), dir);
          expect(tester.getSize(find.byType(DabblerPostRow)).height, golden);
          expect(tester.getSize(_metaRow('2h')).height, metaWith);
        });
      }
    });
  }

  testWidgets('Arabic time with a blank place keeps only the time', (
    WidgetTester tester,
  ) async {
    await _pump(tester, _post(place: ' ', time: '٢س'), TextDirection.rtl);
    expect(find.text('2س'), findsOneWidget);
    expect(_glyph('location'), findsNothing);
    expect(_glyph('global'), findsOneWidget);
  });
}
