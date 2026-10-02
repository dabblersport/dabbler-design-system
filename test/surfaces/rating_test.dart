import 'package:dabbler_design_system/src/surfaces/rating.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) {
  final DabblerColors colors = DabblerColors.resolve(
    theme: DabblerTheme.main,
    brightness: Brightness.light,
  );
  return MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(body: Align(alignment: Alignment.topLeft, child: child)),
    ),
  );
}

Future<void> _focus(WidgetTester tester) async {
  final BuildContext inside = tester.element(
    find
        .descendant(
          of: find.byType(DabblerRating),
          matching: find.byType(Row),
        )
        .first,
  );
  Focus.of(inside).requestFocus();
  await tester.pump();
}

void main() {
  group('DabblerRating — Rating.jsx', () {
    testWidgets('read-only announces one labelled image, not five stars', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const DabblerRating(value: 4.2)));
      expect(find.bySemanticsLabel('Rating: 4.2 of 5'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a whole value prints without a decimal in the label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const DabblerRating(value: 4)));
      expect(find.bySemanticsLabel('Rating: 4 of 5'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('showValue prints toFixed(1) and count prints (n)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerRating(value: 4, count: 128, showValue: true)),
      );
      expect(find.text('4.0 (128)'), findsOneWidget);
      await tester.pumpWidget(
        _host(const DabblerRating(value: 4.2, count: 128)),
      );
      expect(find.text('(128)'), findsOneWidget);
      await tester.pumpWidget(_host(const DabblerRating(value: 3.5)));
      expect(find.textContaining('('), findsNothing);
    });

    testWidgets('star sizes are the 18/24/30 icon grid', (
      WidgetTester tester,
    ) async {
      expect(DabblerRatingSize.sm.starSize, DabblerSizing.iconSm);
      expect(DabblerRatingSize.md.starSize, DabblerSizing.iconMd);
      expect(DabblerRatingSize.lg.starSize, DabblerSizing.iconLg);
    });

    testWidgets('read-only gap is space-1 (3) between stars', (
      WidgetTester tester,
    ) async {
      expect(DabblerRating.readOnlyGap, DabblerSpacing.space1);
      expect(DabblerRating.trailingGap, DabblerSpacing.space2);
      await tester.pumpWidget(_host(const DabblerRating(value: 5, max: 3)));
      final double width = tester.getSize(find.byType(DabblerRating)).width;
      final double star = DabblerRatingSize.md.starSize;
      expect(width, 3 * star + 2 * DabblerRating.readOnlyGap);
    });

    testWidgets('a half star clips the filled glyph to half its width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerRating(value: 2.5)));
      // Two whole stars (bold only), one clipped, two empty: exactly one
      // ClipRect carries the fraction.
      expect(find.byType(ClipRect), findsWidgets);
      final Iterable<ClipRect> clips = tester
          .widgetList<ClipRect>(find.byType(ClipRect))
          .where((ClipRect c) => c.clipper != null);
      expect(clips.length, 1);
    });

    testWidgets('interactive: tapping a star reports its 1-based value', (
      WidgetTester tester,
    ) async {
      final List<int> picked = <int>[];
      await tester.pumpWidget(
        _host(DabblerRating(value: 1, onChanged: picked.add)),
      );
      await tester.tap(find.bySemanticsLabel('4'));
      expect(picked, <int>[4]);
    });

    testWidgets('interactive: every star is a 45px target', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(DabblerRating(value: 1, onChanged: (_) {})),
      );
      final Size size = tester.getSize(find.byType(DabblerRating));
      expect(size.height, DabblerSizing.touchTargetMin);
      expect(size.width, 5 * DabblerSizing.touchTargetMin);
    });

    testWidgets('interactive: arrows change by one, space selects 1 when '
        'unset', (WidgetTester tester) async {
      final List<int> picked = <int>[];
      await tester.pumpWidget(
        _host(DabblerRating(value: 3, onChanged: picked.add)),
      );
      await _focus(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(picked, <int>[4, 2, 4, 2]);

      picked.clear();
      await tester.pumpWidget(
        _host(DabblerRating(value: 0, onChanged: picked.add)),
      );
      await _focus(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(picked, <int>[1]);
    });

    testWidgets('arrow past the ends clamps to 1..max', (
      WidgetTester tester,
    ) async {
      final List<int> picked = <int>[];
      await tester.pumpWidget(
        _host(DabblerRating(value: 5, onChanged: picked.add)),
      );
      await _focus(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(picked, <int>[5]);
    });

    testWidgets('RTL renders without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerRating(value: 2.5), direction: TextDirection.rtl),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
