import 'package:dabbler_design_system/src/forms/input_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

/// KAN-478 — the optional leading emoji (`Home Feed.dc.html:742`): 20px glyph,
/// 25px line, 26 wide, before the title in reading direction, never changing
/// the row's height.
Widget _row({String? emoji, bool flat = true}) => DabblerInputRow(
  title: 'Football',
  emoji: emoji,
  flat: flat,
  showDivider: false,
  onTap: () {},
);

void main() {
  for (final TextDirection dir in TextDirection.values) {
    for (final Brightness b in Brightness.values) {
      for (final bool flat in <bool>[true, false]) {
        testWidgets('emoji sits before the title, 26 wide, row height '
            'unchanged (${dir.name}, ${b.name}, flat: $flat)', (
          WidgetTester tester,
        ) async {
          Future<double> rowHeight(String? emoji) async {
            await tester.pumpWidget(
              host(
                _row(emoji: emoji, flat: flat),
                direction: dir,
                brightness: b,
              ),
            );
            return tester.getSize(find.byType(DabblerInputRow)).height;
          }

          final double plain = await rowHeight(null);
          // Default: no emoji slot exists at all.
          expect(find.text('⚽'), findsNothing);
          final double withEmoji = await rowHeight('⚽');
          expect(withEmoji, plain, reason: 'an emoji never grows the row');

          final Text glyph = tester.widget<Text>(find.text('⚽'));
          expect(glyph.style!.fontSize, 20);
          expect(
            glyph.style!.height! * glyph.style!.fontSize!,
            closeTo(25, 0.01),
          );
          final Finder slot = find.ancestor(
            of: find.text('⚽'),
            matching: find.byWidgetPredicate(
              (Widget w) => w is SizedBox && w.width == 26,
            ),
          );
          expect(tester.getSize(slot.first).width, 26);

          final Rect e = tester.getRect(find.text('⚽'));
          final Rect t = tester.getRect(find.text('Football'));
          if (dir == TextDirection.ltr) {
            expect(
              e.right,
              lessThanOrEqualTo(t.left),
              reason: 'LTR: left of title',
            );
          } else {
            expect(
              e.left,
              greaterThanOrEqualTo(t.right),
              reason: 'RTL: right of title',
            );
          }
          // Centred on the row's content.
          expect(
            (e.center.dy -
                    tester.getRect(find.byType(DabblerInputRow)).center.dy)
                .abs(),
            lessThan(2),
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('with both leading and emoji: leading, emoji, title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(
        const DabblerInputRow(
          title: 'Football',
          emoji: '⚽',
          leading: SizedBox(key: Key('lead'), width: 20, height: 20),
        ),
      ),
    );
    final double l = tester.getRect(find.byKey(const Key('lead'))).right;
    final Rect e = tester.getRect(find.text('⚽'));
    final double t = tester.getRect(find.text('Football')).left;
    expect(l, lessThanOrEqualTo(e.left));
    expect(e.right, lessThanOrEqualTo(t));
  });

  testWidgets('the emoji is decorative: the title is the accessible name', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle h = tester.ensureSemantics();
    await tester.pumpWidget(host(_row(emoji: '⚽')));
    expect(find.bySemanticsLabel(RegExp('⚽')), findsNothing);
    h.dispose();
  });
}
