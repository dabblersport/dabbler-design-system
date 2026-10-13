import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

// KAN-519: a blank `place` (null, '' or whitespace) hides the location glyph,
// its gap and the text; with place and meta both blank the row is not built.
//
// Golden heights captured on the code BEFORE the change, place 'Al Maryah
// Island' / Arabic 'جزيرة المارية', meta '0/10 spots': LTR 91, RTL 92 (Arabic
// type metrics). Both blank used to be 72 (LTR) / 73 (RTL) only for null.
const double _goldenLtr = 91;
const double _goldenRtl = 92;
const double _bothBlankLtr = 72;
const double _bothBlankRtl = 73;
const List<String?> _blanks = <String?>[null, '', '   ', '\t\n '];

Finder _glyph() => find.byWidgetPredicate(
  (Widget w) => w is DabblerIcon && w.name == 'location',
);

Finder _emptyText() => find.byWidgetPredicate(
  (Widget w) => w is Text && (w.data ?? '').trim().isEmpty,
);

Widget _card({String? place, String? meta}) => DabblerCardEventResult(
  month: 'Aug',
  day: '18',
  kind: 'Game',
  kindIcon: 'game',
  time: 'Today',
  title: 'Dabbler Night',
  place: place,
  meta: meta,
);

Widget _scaled(Widget child, TextDirection d, double scale) => MediaQuery(
  data: MediaQueryData(textScaler: TextScaler.linear(scale)),
  child: host(child, direction: d),
);

Finder _placeMetaRow(String anchor) =>
    find.ancestor(of: find.text(anchor), matching: find.byType(Row)).first;

void main() {
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('event result: tile, kind, action (${dir.name})', (t) async {
      int taps = 0;
      await t.pumpWidget(
        host(
          DabblerCardEventResult(
            month: 'Aug',
            day: '18',
            kind: 'Game',
            kindIcon: 'game',
            time: 'Today',
            title: 'Dabbler Night',
            query: 'dabbler',
            place: 'Marina',
            meta: '0/10 spots',
            actionLabel: 'Join',
            onAction: () => taps++,
          ),
          direction: dir,
        ),
      );
      expect(find.text('AUG'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('Game'), findsOneWidget);
      final double tileX = t.getCenter(find.text('18')).dx;
      final double btnX = t.getCenter(find.text('Join')).dx;
      expect(dir == TextDirection.ltr ? tileX < btnX : tileX > btnX, isTrue);
      await t.tap(find.text('Join'));
      expect(taps, 1);
    });
  }
  testWidgets('no action label draws no button', (t) async {
    await t.pumpWidget(
      host(
        const DabblerCardEventResult(
          month: 'Aug',
          day: '2',
          kind: 'Meet-up',
          time: 'x',
          title: 'y',
        ),
      ),
    );
    expect(find.byType(DabblerButton), findsNothing);
  });

  for (final TextDirection dir in TextDirection.values) {
    final bool rtl = dir == TextDirection.rtl;
    final String real = rtl ? 'جزيرة المارية' : 'Al Maryah Island';
    final double golden = rtl ? _goldenRtl : _goldenLtr;
    final double bothBlank = rtl ? _bothBlankRtl : _bothBlankLtr;
    group('place rule — ${dir.name}', () {
      testWidgets('real place with meta: glyph, text and golden height', (
        t,
      ) async {
        await t.pumpWidget(
          host(
            _card(place: real, meta: '0/10 spots'),
            direction: dir,
          ),
        );
        expect(_glyph(), findsOneWidget);
        expect(find.text(real), findsOneWidget);
        expect(find.text('0/10 spots'), findsOneWidget);
        expect(t.getSize(find.byType(DabblerCardEventResult)).height, golden);
        expect(_emptyText(), findsNothing);
      });

      for (final String? blank in _blanks) {
        testWidgets('blank place ${blank?.codeUnits} with meta: meta only', (
          t,
        ) async {
          await t.pumpWidget(
            host(
              _card(place: blank, meta: '0/10 spots'),
              direction: dir,
            ),
          );
          expect(_glyph(), findsNothing);
          expect(find.text('0/10 spots'), findsOneWidget);
          expect(_emptyText(), findsNothing);
          final Row row = t.widget<Row>(_placeMetaRow('0/10 spots'));
          expect(row.children.length, 1, reason: 'no glyph, no gap');
          expect(t.getSize(find.byType(DabblerCardEventResult)).height, golden);
        });

        testWidgets('place ${blank?.codeUnits} and meta blank: no row', (
          t,
        ) async {
          for (final String? meta in _blanks) {
            await t.pumpWidget(
              host(
                _card(place: blank, meta: meta),
                direction: dir,
              ),
            );
            expect(_glyph(), findsNothing);
            expect(_emptyText(), findsNothing);
            expect(
              t.getSize(find.byType(DabblerCardEventResult)).height,
              bothBlank,
              reason: 'meta ${meta?.codeUnits}',
            );
          }
        });

        testWidgets(
          'blank place ${blank?.codeUnits}, no meta given: no glyph',
          (t) async {
            await t.pumpWidget(host(_card(place: blank), direction: dir));
            expect(_glyph(), findsNothing);
          },
        );
      }

      testWidgets('real place, no meta: glyph and text, no meta text', (
        t,
      ) async {
        await t.pumpWidget(
          host(
            _card(place: real, meta: '  '),
            direction: dir,
          ),
        );
        expect(_glyph(), findsOneWidget);
        expect(find.text(real), findsOneWidget);
        expect(_emptyText(), findsNothing);
      });

      testWidgets(
        '200 percent text: no overflow (blank place and real place)',
        (t) async {
          for (final String? place in <String?>[null, '   ', real]) {
            await t.pumpWidget(
              _scaled(_card(place: place, meta: '0/10 spots'), dir, 2),
            );
            expect(t.takeException(), isNull, reason: 'place $place');
          }
          await t.pumpWidget(_scaled(_card(place: '  ', meta: ' '), dir, 2));
          expect(t.takeException(), isNull);
        },
      );
    });
  }
}
