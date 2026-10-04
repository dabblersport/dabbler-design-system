import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/forms/input_row.dart';
import 'package:dabbler_design_system/src/forms/input_row_parts.dart';
import 'package:dabbler_design_system/src/forms/toggle.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

const List<TextDirection> _dirs = <TextDirection>[
  TextDirection.ltr,
  TextDirection.rtl,
];

DabblerIcon _icon(WidgetTester tester, String name) => tester
    .widgetList<DabblerIcon>(find.byType(DabblerIcon))
    .firstWhere((DabblerIcon i) => i.name == name);

void main() {
  final DabblerColors colors = testColors();

  for (final TextDirection dir in _dirs) {
    group('DS gaps 5 InputRow additions (${dir.name})', () {
      testWidgets('titleSpan renders rich text and reads as its plain text', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle h = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            DabblerInputRow(
              titleSpan: DabblerInputRow.highlightSpan(
                'Padel night',
                'pad',
                colors,
              ),
              onTap: () {},
            ),
            direction: dir,
          ),
        );
        final RichText rt = tester
            .widgetList<RichText>(find.byType(RichText))
            .firstWhere((RichText r) => r.text.toPlainText() == 'Padel night');
        TextSpan? hit;
        rt.text.visitChildren((InlineSpan span) {
          if (span is TextSpan && span.text == 'Pad') {
            hit = span;
          }
          return hit == null;
        });
        expect(hit, isNotNull);
        expect(hit!.style!.fontWeight, DabblerType.semibold);
        expect(hit!.style!.color, colors.brandPrimary);
        expect(find.bySemanticsLabel('Padel night'), findsOneWidget);
        h.dispose();
      });

      testWidgets('verified draws the bold verify mark with a label', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const DabblerInputRow(title: 'Dabbler', verified: true),
            direction: dir,
          ),
        );
        final DabblerIcon mark = _icon(tester, 'verify');
        expect(mark.weight, DabblerIconWeight.bold);
        expect(mark.color, colors.brandPrimary);
        expect(mark.semanticLabel, DabblerInputRow.verifiedSemanticLabel);
        // The mark sits inline-end of the title.
        final double titleX = tester.getCenter(find.text('Dabbler')).dx;
        final double markX = tester.getCenter(find.byWidget(mark)).dx;
        expect(
          dir == TextDirection.ltr ? markX > titleX : markX < titleX,
          isTrue,
        );
      });

      testWidgets('titleBadge wins over verified', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const DabblerInputRow(
              title: 'x',
              verified: true,
              titleBadge: Text('PRO'),
            ),
            direction: dir,
          ),
        );
        expect(find.text('PRO'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (Widget w) => w is DabblerIcon && w.name == 'verify',
          ),
          findsNothing,
        );
      });

      testWidgets('value shows before an implied chevron when tappable', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            DabblerInputRow(title: 'Language', value: 'English', onTap: () {}),
            direction: dir,
          ),
        );
        expect(find.byType(DabblerChevron), findsOneWidget);
        final double v = tester.getCenter(find.text('English')).dx;
        final double c = tester.getCenter(find.byType(DabblerChevron)).dx;
        expect(dir == TextDirection.ltr ? v < c : v > c, isTrue);
        final Text t = tester.widget<Text>(find.text('English'));
        expect(t.style!.color, colors.textSecondary);
        expect(t.maxLines, 1);
      });

      testWidgets('value without onTap draws no chevron', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const DabblerInputRow(title: 'Version', value: '2.0'),
            direction: dir,
          ),
        );
        expect(find.byType(DabblerChevron), findsNothing);
        expect(find.text('2.0'), findsOneWidget);
      });

      testWidgets(
        'destructive colours title, icon and chevron; subtitle stays secondary',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            host(
              DabblerInputRow(
                title: 'Sign out',
                subtitle: 'Leave this device',
                leading: const DabblerIcon('logout'),
                trailing: const DabblerChevron(),
                tone: DabblerInputRowTone.destructive,
                onTap: () {},
              ),
              direction: dir,
            ),
          );
          final Color danger = colors.error.strong;
          final Text title = tester.widget<Text>(find.text('Sign out'));
          expect(title.style!.color, danger);
          expect(title.style!.fontWeight, DabblerType.semibold);
          expect(
            tester.widget<Text>(find.text('Leave this device')).style!.color,
            colors.textSecondary,
          );
          expect(
            tester.widget<DabblerChevron>(find.byType(DabblerChevron)).color,
            danger,
          );
          final BuildContext iconCtx = tester.element(
            find.byWidgetPredicate(
              (Widget w) => w is DabblerIcon && w.name == 'logout',
            ),
          );
          expect(IconTheme.of(iconCtx).color, danger);
        },
      );

      testWidgets('selected draws the bold tick and selected semantics', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle h = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            Column(
              children: <Widget>[
                DabblerInputRow(title: 'On', selected: true, onTap: () {}),
                DabblerInputRow(title: 'Off', selected: false, onTap: () {}),
              ],
            ),
            direction: dir,
          ),
        );
        final DabblerIcon tick = _icon(tester, 'tick-circle');
        expect(tick.weight, DabblerIconWeight.bold);
        expect(tick.color, colors.brandPrimary);
        expect(
          find.byWidgetPredicate(
            (Widget w) => w is DabblerIcon && w.name == 'tick-circle',
          ),
          findsOneWidget,
        );
        expect(
          tester.getSemantics(find.text('On')),
          matchesSemantics(
            label: 'On',
            isButton: true,
            hasSelectedState: true,
            isSelected: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
            isFocusable: true,
            hasFocusAction: true,
          ),
        );
        expect(
          tester.getSemantics(find.text('Off')),
          matchesSemantics(
            label: 'Off',
            isButton: true,
            hasSelectedState: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
            isFocusable: true,
            hasFocusAction: true,
          ),
        );
        h.dispose();
      });

      testWidgets(
        'toggle helper: info button and toggle are separate controls',
        (WidgetTester tester) async {
          final SemanticsHandle h = tester.ensureSemantics();
          int info = 0;
          bool? flipped;
          await tester.pumpWidget(
            host(
              DabblerInputRow.toggle(
                title: 'Show activity',
                checked: false,
                onChanged: (bool v) => flipped = v,
                onInfo: () => info++,
              ),
              direction: dir,
            ),
          );
          expect(find.byType(DabblerToggle), findsOneWidget);
          expect(find.bySemanticsLabel('More info'), findsOneWidget);
          await tester.tap(find.byType(DabblerInputRowInfoButton));
          expect(info, 1);
          await tester.tap(find.byType(DabblerToggle));
          expect(flipped, isTrue);
          final double i = tester
              .getCenter(find.byType(DabblerInputRowInfoButton))
              .dx;
          final double t = tester.getCenter(find.byType(DabblerToggle)).dx;
          expect(dir == TextDirection.ltr ? i < t : i > t, isTrue);
          h.dispose();
        },
      );

      testWidgets('toggle helper without onInfo has no info button', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            DabblerInputRow.toggle(title: 'x', checked: true),
            direction: dir,
          ),
        );
        expect(find.byType(DabblerInputRowInfoButton), findsNothing);
      });

      testWidgets('trailing chips stay on one line at a narrow width', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            DabblerInputRow(
              title: 'Sports',
              trailingChips: <Widget>[
                for (final String s in <String>[
                  'Padel',
                  'Football',
                  'Tennis',
                  'Basketball',
                  'Squash',
                ])
                  Text(s),
              ],
            ),
            direction: dir,
            width: 200,
          ),
        );
        expect(tester.takeException(), isNull);
        final double y0 = tester.getTopLeft(find.text('Padel')).dy;
        final double y1 = tester.getTopLeft(find.text('Squash')).dy;
        expect(y1, y0, reason: 'chips must not wrap');
        final Rect strip = tester.getRect(
          find.byType(DabblerInputRowChipStrip),
        );
        final Rect row = tester.getRect(find.byType(DabblerInputRow));
        expect(strip.left >= row.left && strip.right <= row.right, isTrue);
        final Rect first = tester.getRect(find.text('Padel'));
        // RTL starts at the right edge of the strip.
        if (dir == TextDirection.ltr) {
          expect(first.left, closeTo(strip.left, 0.01));
        } else {
          expect(first.right, closeTo(strip.right, 0.01));
        }
      });
    });
  }

  test('title and titleSpan are exclusive', () {
    expect(
      () => DabblerInputRow(
        title: 'a',
        titleSpan: TextSpan(text: 'b'),
      ),
      throwsAssertionError,
    );
  });

  test('highlightSpan without a match is plain text', () {
    final TextSpan s = DabblerInputRow.highlightSpan('abc', 'z', colors);
    expect(s.text, 'abc');
    expect(s.children, isNull);
  });
}
