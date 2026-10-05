import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// KAN-434 — the one sheet convention: the sheet owns surface and padding, the
/// content (a [DabblerSheetBody] with [DabblerSheetActions]) passes widgets
/// only. LTR and RTL, English and Arabic.
Widget _host(Widget child, TextDirection direction) {
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
      child: Directionality(
        textDirection: direction,
        child: Align(alignment: Alignment.bottomCenter, child: child),
      ),
    ),
  );
}

/// Panel-sized surfaces: a filled, rounded box over 100 logical px each way.
/// Handles, buttons and tiles are filled and rounded too and never that big.
int _surfaces(WidgetTester tester, Finder root) {
  int count = 0;
  for (final Element e
      in find
          .descendant(of: root, matching: find.byType(DecoratedBox))
          .evaluate()) {
    final Decoration d = (e.widget as DecoratedBox).decoration;
    if (d is BoxDecoration && d.color != null && d.borderRadius != null) {
      final Size s = tester.getSize(find.byWidget(e.widget));
      if (s.width > 100 && s.height > 100) count++;
    }
  }
  return count;
}

Widget _sheet(String title, String text, String primary, String secondary) =>
    DabblerSheet(
      presentation: DabblerSheetPresentation.inline,
      onClose: () {},
      detent: DabblerSheetDetent.content,
      child: DabblerSheetBody(
        spacing: DabblerSpacing.space2,
        actions: DabblerSheetActions(
          children: <Widget>[
            DabblerButton(label: primary, fullWidth: true, onPressed: () {}),
            DabblerButton(
              label: secondary,
              tone: DabblerButtonTone.neutral,
              fullWidth: true,
              onPressed: () {},
            ),
          ],
        ),
        children: <Widget>[Text(title), Text(text)],
      ),
    );

void main() {
  const Map<TextDirection, List<String>> copy = <TextDirection, List<String>>{
    TextDirection.ltr: <String>['Stay updated', 'Get notified', 'Enable', 'No'],
    TextDirection.rtl: <String>[
      'ابقَ على اطلاع',
      'احصل على إشعارات الدعوات',
      'تفعيل',
      'لا شكرا',
    ],
  };

  for (final TextDirection direction in TextDirection.values) {
    final List<String> t = copy[direction]!;
    group('sheet convention ($direction)', () {
      testWidgets('draws exactly one surface; the content adds none', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(_sheet(t[0], t[1], t[2], t[3]), direction),
        );
        expect(_surfaces(tester, find.byType(DabblerSheet)), 1);
        expect(_surfaces(tester, find.byType(DabblerSheetBody)), 0);
        for (final Type type in <Type>[Card, Material, PhysicalModel, Ink]) {
          expect(
            find.descendant(
              of: find.byType(DabblerSheetBody),
              matching: find.byType(type),
            ),
            findsNothing,
          );
        }
        expect(tester.takeException(), isNull);
      });

      testWidgets('content starts at the sheet inset, once', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(_sheet(t[0], t[1], t[2], t[3]), direction),
        );
        final Rect panel = tester.getRect(find.byType(ClipRRect).first);
        final Rect first = tester.getRect(find.text(t[0]));
        final double inset = direction == TextDirection.ltr
            ? first.left - panel.left
            : panel.right - first.right;
        // The sheet's `space6` body padding and nothing else.
        expect(inset, DabblerSpacing.space6);
      });

      testWidgets('actions stack at the design-system gap', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(_sheet(t[0], t[1], t[2], t[3]), direction),
        );
        final Rect body = tester.getRect(find.text(t[1]));
        final Rect a = tester.getRect(find.byType(DabblerButton).at(0));
        final Rect b = tester.getRect(find.byType(DabblerButton).at(1));
        expect(a.top - body.bottom, DabblerSpacing.space4);
        expect(b.top - a.bottom, DabblerSpacing.space3);
        expect(a.width, b.width);
      });
    });
  }

  testWidgets('DabblerSheetBody spaces its children uniformly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DabblerSheetBody(
          children: <Widget>[Text('one'), Text('two'), Text('three')],
        ),
        TextDirection.ltr,
      ),
    );
    final Rect one = tester.getRect(find.text('one'));
    final Rect two = tester.getRect(find.text('two'));
    final Rect three = tester.getRect(find.text('three'));
    expect(two.top - one.bottom, DabblerSpacing.space4);
    expect(three.top - two.bottom, DabblerSpacing.space4);
  });
}
