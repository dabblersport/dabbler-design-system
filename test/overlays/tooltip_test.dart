import 'package:dabbler_design_system/src/overlays/tooltip.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

Widget _target() => const ColoredBox(
  key: Key('target'),
  color: Color(0xFF888888),
  child: SizedBox(width: 60, height: 45),
);

Future<TestGesture> _hover(WidgetTester tester) async {
  final TestGesture mouse = await tester.createGesture(
    kind: PointerDeviceKind.mouse,
  );
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await mouse.moveTo(tester.getCenter(find.byKey(const Key('target'))));
  return mouse;
}

void main() {
  group('DabblerTooltip — Tooltip.jsx', () {
    test('the source constants', () {
      expect(DabblerTooltip.defaultDelay, const Duration(milliseconds: 400));
      expect(
        DabblerTooltip.defaultTouchDelay,
        const Duration(milliseconds: 450),
      );
      expect(DabblerTooltip.maxWidth, 220);
      expect(DabblerTooltip.gap, 6);
    });

    testWidgets('hidden until the hover delay elapses, then shown', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(DabblerTooltip(message: 'Share game', child: _target())),
      );
      expect(find.text('Share game'), findsNothing);

      await _hover(tester);
      await tester.pump(const Duration(milliseconds: 399));
      expect(find.text('Share game'), findsNothing);

      await tester.pump(const Duration(milliseconds: 2));
      expect(find.text('Share game'), findsOneWidget);
    });

    testWidgets('leaving the control hides it again', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(DabblerTooltip(message: 'Share game', child: _target())),
      );
      final TestGesture mouse = await _hover(tester);
      await tester.pump(const Duration(milliseconds: 450));
      expect(find.text('Share game'), findsOneWidget);
      await mouse.moveTo(const Offset(5, 5));
      await tester.pump();
      expect(find.text('Share game'), findsNothing);
    });

    testWidgets('a quick pass never shows it (the timer is cancelled)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(DabblerTooltip(message: 'Share game', child: _target())),
      );
      final TestGesture mouse = await _hover(tester);
      await tester.pump(const Duration(milliseconds: 100));
      await mouse.moveTo(const Offset(5, 5));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Share game'), findsNothing);
    });

    testWidgets('touch long-press opens after 450ms, release closes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(DabblerTooltip(message: 'Share game', child: _target())),
      );
      final TestGesture touch = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('target'))),
      );
      await tester.pump(const Duration(milliseconds: 449));
      expect(find.text('Share game'), findsNothing);
      await tester.pump(const Duration(milliseconds: 2));
      expect(find.text('Share game'), findsOneWidget);
      await touch.up();
      await tester.pump();
      expect(find.text('Share game'), findsNothing);
    });

    testWidgets('the panel is an ink fill, never intercepts pointers, and '
        'is capped at 220', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          DabblerTooltip(
            message: 'x ' * 120,
            delay: Duration.zero,
            child: _target(),
          ),
        ),
      );
      await _hover(tester);
      await tester.pump(const Duration(milliseconds: 10));
      final Finder panel = find.ancestor(
        of: find.textContaining('x x'),
        matching: find.byWidgetPredicate(
          (Widget w) =>
              w is Container &&
              w.constraints?.maxWidth == DabblerTooltip.maxWidth,
        ),
      );
      expect(panel, findsOneWidget);
      expect(
        tester.getSize(panel).width,
        lessThanOrEqualTo(DabblerTooltip.maxWidth),
      );
      final DabblerColors colors = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      final BoxDecoration deco =
          (tester.widget<Container>(panel).decoration! as BoxDecoration);
      expect(deco.color, colors.textPrimary);
      expect(
        find.ancestor(
          of: find.textContaining('x x'),
          matching: find.byType(IgnorePointer),
        ),
        findsWidgets,
      );
    });

    testWidgets('a short message sizes to its text, not to the overlay', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerTooltip(
            message: 'Tip',
            delay: Duration.zero,
            child: _target(),
          ),
        ),
      );
      await _hover(tester);
      await tester.pump(const Duration(milliseconds: 10));
      final Size text = tester.getSize(find.text('Tip'));
      final Size panel = tester.getSize(
        find.ancestor(
          of: find.text('Tip'),
          matching: find.byWidgetPredicate(
            (Widget w) =>
                w is Container &&
                w.constraints?.maxWidth == DabblerTooltip.maxWidth,
          ),
        ),
      );
      expect(panel.width, text.width + 2 * 9);
      expect(panel.height, text.height + 2 * 6);
    });

    testWidgets('the message is also the screen-reader tooltip', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(DabblerTooltip(message: 'Share game', child: _target())),
      );
      expect(
        tester.getSemantics(find.byKey(const Key('target'))).tooltip,
        'Share game',
      );
      handle.dispose();
    });

    for (final (DabblerTooltipPlacement, bool) c
        in <(DabblerTooltipPlacement, bool)>[
          (DabblerTooltipPlacement.top, true),
          (DabblerTooltipPlacement.bottom, false),
        ]) {
      testWidgets('placement ${c.$1.name} sits ${c.$2 ? 'above' : 'below'} '
          'the control', (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(
            DabblerTooltip(
              message: 'Tip',
              placement: c.$1,
              delay: Duration.zero,
              child: _target(),
            ),
          ),
        );
        final double controlY = tester
            .getCenter(find.byKey(const Key('target')))
            .dy;
        await _hover(tester);
        await tester.pump(const Duration(milliseconds: 10));
        final double panelY = tester.getCenter(find.text('Tip')).dy;
        if (c.$2) {
          expect(panelY, lessThan(controlY));
        } else {
          expect(panelY, greaterThan(controlY));
        }
      });
    }
  });
}
