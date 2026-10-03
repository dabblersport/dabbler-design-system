import 'package:dabbler_design_system/src/controls/button.dart';
import 'package:dabbler_design_system/src/overlays/sheet.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// DS gaps 6 item 2 — the sheet header's rich title and trailing action
/// (`Listings.dc.html:286-289`).
Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) {
  return MaterialApp(
    theme: ThemeData(
      extensions: <ThemeExtension<dynamic>>[
        DabblerColors.resolve(
          theme: DabblerTheme.main,
          brightness: Brightness.light,
        ),
      ],
    ),
    home: MediaQuery(
      data: const MediaQueryData(size: Size(400, 800)),
      child: Directionality(textDirection: direction, child: child),
    ),
  );
}

Widget _sheet({
  String? title,
  InlineSpan? titleSpan,
  Widget? titleWidget,
  Widget? action,
  VoidCallback? onClose,
}) => DabblerSheet(
  presentation: DabblerSheetPresentation.inline,
  title: title,
  titleSpan: titleSpan,
  titleWidget: titleWidget,
  headerAction: action,
  onClose: onClose,
  child: const Text('body'),
);

void main() {
  for (final TextDirection direction in TextDirection.values) {
    group('DabblerSheet header ($direction)', () {
      testWidgets('the action sits at the inline end, after the title', (
        WidgetTester tester,
      ) async {
        int resets = 0;
        await tester.pumpWidget(
          _host(
            _sheet(
              title: 'Filters',
              action: DabblerButton(
                label: 'Reset',
                tone: DabblerButtonTone.neutral,
                size: DabblerButtonSize.small,
                onPressed: () => resets++,
              ),
            ),
            direction: direction,
          ),
        );
        final Rect title = tester.getRect(find.text('Filters'));
        final Rect action = tester.getRect(find.byType(DabblerButton));
        if (direction == TextDirection.ltr) {
          expect(action.left, greaterThan(title.right));
        } else {
          expect(action.right, lessThan(title.left));
        }
        await tester.tap(find.byType(DabblerButton));
        await tester.pump();
        expect(resets, 1);
      });

      testWidgets('with a close affordance, the action comes before it', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(
            _sheet(
              title: 'Filters',
              onClose: () {},
              action: const DabblerButton(label: 'Reset'),
            ),
            direction: direction,
          ),
        );
        final Rect action = tester.getRect(find.byType(DabblerButton));
        final Rect close = tester.getRect(find.bySemanticsLabel('Close'));
        if (direction == TextDirection.ltr) {
          expect(close.left, greaterThanOrEqualTo(action.right));
        } else {
          expect(close.right, lessThanOrEqualTo(action.left));
        }
      });

      testWidgets('titleSpan renders rich text and names the sheet', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        await tester.pumpWidget(
          _host(
            _sheet(
              titleSpan: const TextSpan(
                text: 'Filters ',
                children: <InlineSpan>[TextSpan(text: '3')],
              ),
            ),
            direction: direction,
          ),
        );
        expect(find.text('Filters 3', findRichText: true), findsOneWidget);
        expect(
          tester.getSemantics(find.byType(DabblerSheet)),
          isA<SemanticsNode>(),
        );
        expect(find.bySemanticsLabel(RegExp('Filters 3')), findsWidgets);
        handle.dispose();
      });

      testWidgets('titleWidget replaces the text title', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(
            _sheet(
              title: 'ignored visually',
              titleWidget: const Text('custom'),
            ),
            direction: direction,
          ),
        );
        expect(find.text('custom'), findsOneWidget);
        expect(find.text('ignored visually'), findsNothing);
      });
    });
  }

  testWidgets('without the new params the header is unchanged', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(_sheet(title: 'Plain')));
    expect(find.text('Plain'), findsOneWidget);
    expect(find.byType(DabblerButton), findsNothing);
  });

  testWidgets('showDabblerSheet passes the action builder through', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (BuildContext context) => GestureDetector(
            onTap: () => showDabblerSheet<void>(
              context: context,
              titleSpan: const TextSpan(text: 'Filters'),
              headerActionBuilder: (BuildContext context) =>
                  const DabblerButton(label: 'Reset'),
              builder: (BuildContext context) => const Text('body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('Filters', findRichText: true), findsOneWidget);
  });
}
