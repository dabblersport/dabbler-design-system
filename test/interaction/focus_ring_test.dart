import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'interaction_host.dart';

const Widget _child = SizedBox(key: Key('child'), width: 100, height: 50);

/// Whether a ring is currently being painted — the primitive installs a
/// foreground painter only when it means to draw one.
bool _ringPainted(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .any((CustomPaint p) => p.foregroundPainter != null);

void main() {
  group('tokens transcribed from tokens/spacing.css:65-66', () {
    test('--focus-ring-width is 2px', () {
      expect(DabblerFocusRing.ringWidth, 2);
    });

    test('--focus-ring-offset is 2px', () {
      expect(DabblerFocusRing.ringOffset, 2);
    });
  });

  group('DabblerFocusRing.visible (caller-driven)', () {
    testWidgets('paints nothing when not visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const DabblerFocusRing.visible(visible: false, child: _child)),
      );
      expect(_ringPainted(tester), isFalse);
    });

    testWidgets('paints a ring when visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const DabblerFocusRing.visible(visible: true, child: _child)),
      );
      expect(_ringPainted(tester), isTrue);
    });

    testWidgets('a disabled control never rings', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const DabblerFocusRing.visible(
          visible: true,
          enabled: false,
          child: _child,
        )),
      );
      expect(_ringPainted(tester), isFalse);
    });

    testWidgets('showing the ring does not move or resize the child',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const DabblerFocusRing.visible(visible: false, child: _child)),
      );
      final Rect before = tester.getRect(find.byKey(const Key('child')));
      await tester.pumpWidget(
        host(const DabblerFocusRing.visible(visible: true, child: _child)),
      );
      expect(tester.getRect(find.byKey(const Key('child'))), before);
    });

    testWidgets('the ring colour is the theme focus-ring role, per theme',
        (WidgetTester tester) async {
      for (final DabblerTheme theme in DabblerTheme.values) {
        await tester.pumpWidget(
          host(
            const DabblerFocusRing.visible(visible: true, child: _child),
            theme: theme,
          ),
        );
        final Color expected =
            DabblerColors.resolve(theme: theme, brightness: Brightness.light)
                .focusRing;
        // The painter is the only thing that knows the colour; painting it and
        // reading the recorded stroke proves it reached the canvas.
        expect(
          find.byType(CustomPaint),
          paints..rrect(color: expected, strokeWidth: DabblerFocusRing.ringWidth),
        );
      }
    });

    testWidgets('the ring sits offset + half its width outside the child',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const DabblerFocusRing.visible(visible: true, child: _child)),
      );
      const double grow =
          DabblerFocusRing.ringOffset + DabblerFocusRing.ringWidth / 2;
      expect(
        find.byType(CustomPaint),
        paints
          ..rrect(
            rrect: RRect.fromRectAndRadius(
              const Rect.fromLTWH(0, 0, 100, 50).inflate(grow),
              const Radius.circular(grow),
            ),
          ),
      );
    });
  });

  group('DabblerFocusRing (self-driven, :focus-visible equivalent)', () {
    testWidgets('keyboard focus raises the ring; blur drops it',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      final FocusNode elsewhere = FocusNode();
      addTearDown(node.dispose);
      addTearDown(elsewhere.dispose);
      await tester.pumpWidget(
        host(Column(
          children: <Widget>[
            DabblerFocusRing(focusNode: node, child: _child),
            Focus(focusNode: elsewhere, child: const SizedBox()),
          ],
        )),
      );
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic);
      node.requestFocus();
      await tester.pump();
      expect(_ringPainted(tester), isTrue);

      // Focus moving away is the blur that matters — a real control loses the
      // ring because something else took focus.
      elsewhere.requestFocus();
      // Two frames: FocusManager applies a focus change at the end of the
      // frame it was requested in, so the dependent repaint lands on the next.
      await tester.pumpAndSettle();
      expect(_ringPainted(tester), isFalse);
    });

    testWidgets('a pointer press does not raise a ring',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        host(DabblerFocusRing(focusNode: node, child: _child)),
      );
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTouch;
      node.requestFocus();
      await tester.pump();
      expect(_ringPainted(tester), isFalse);
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic;
    });

    testWidgets('reports focus changes to the composing control',
        (WidgetTester tester) async {
      final List<bool> changes = <bool>[];
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        host(DabblerFocusRing(
          focusNode: node,
          onFocusChange: changes.add,
          child: _child,
        )),
      );
      node.requestFocus();
      await tester.pump();
      node.unfocus();
      await tester.pump();
      expect(changes, <bool>[true, false]);
    });

    testWidgets('a disabled control cannot take focus',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        host(DabblerFocusRing(focusNode: node, enabled: false, child: _child)),
      );
      node.requestFocus();
      await tester.pump();
      expect(_ringPainted(tester), isFalse);
    });
  });
}
