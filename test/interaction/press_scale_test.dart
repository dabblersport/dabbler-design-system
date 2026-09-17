import 'package:dabbler_design_system/src/interaction/press_scale.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'interaction_host.dart';

/// The scale the child is actually being drawn at, read off the transform the
/// primitive produced rather than off its own state.
double _scaleOf(WidgetTester tester) {
  final Matrix4 m = tester
      .widget<Transform>(
        find.ancestor(
          of: find.byKey(const Key('child')),
          matching: find.byType(Transform),
        ).first,
      )
      .transform;
  return m.storage[0];
}

const Widget _child = SizedBox(key: Key('child'), width: 100, height: 50);

void main() {
  group('tokens transcribed from tokens/spacing.css:58-62', () {
    test('--motion-fast is 80ms', () {
      expect(DabblerMotion.fast, const Duration(milliseconds: 80));
    });

    test('--motion-base is 120ms', () {
      expect(DabblerMotion.base, const Duration(milliseconds: 120));
    });

    test('--motion-slow is 200ms', () {
      expect(DabblerMotion.slow, const Duration(milliseconds: 200));
    });

    test('--ease-out is cubic-bezier(.2, 0, .2, 1)', () {
      expect(DabblerMotion.easeOut, const Cubic(0.2, 0, 0.2, 1));
    });

    test('--press-scale is .98', () {
      expect(DabblerMotion.pressScale, 0.98);
    });
  });

  group('DabblerPressScale (caller-driven)', () {
    testWidgets('is unscaled when not pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const DabblerPressScale(pressed: false, child: _child)),
      );
      expect(_scaleOf(tester), 1);
    });

    testWidgets('settles at the press-scale token when pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const DabblerPressScale(pressed: true, child: _child)),
      );
      await tester.pumpAndSettle();
      expect(_scaleOf(tester), closeTo(DabblerMotion.pressScale, 0.0001));
    });

    testWidgets('takes --motion-fast to get there', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const DabblerPressScale(pressed: false, child: _child)),
      );
      await tester.pumpWidget(
        host(const DabblerPressScale(pressed: true, child: _child)),
      );
      // One millisecond short of the token, the transition is still running.
      await tester.pump(const Duration(milliseconds: 79));
      expect(_scaleOf(tester), greaterThan(DabblerMotion.pressScale));
      await tester.pump(const Duration(milliseconds: 1));
      expect(_scaleOf(tester), closeTo(DabblerMotion.pressScale, 0.0001));
    });

    testWidgets('a disabled control never scales', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const DabblerPressScale(
          pressed: true,
          enabled: false,
          child: _child,
        )),
      );
      await tester.pumpAndSettle();
      expect(_scaleOf(tester), 1);
    });

    testWidgets('reduced motion keeps the scale but drops the transition',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const DabblerPressScale(pressed: false, child: _child),
          disableAnimations: true,
        ),
      );
      await tester.pumpWidget(
        host(
          const DabblerPressScale(pressed: true, child: _child),
          disableAnimations: true,
        ),
      );
      // No pump past zero: it is already there.
      await tester.pump();
      expect(_scaleOf(tester), closeTo(DabblerMotion.pressScale, 0.0001));
    });
  });

  group('DabblerPressScale.gesture (self-driven)', () {
    testWidgets('scales while the pointer is down and releases after',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const DabblerPressScale.gesture(child: _child)),
      );

      final TestGesture gesture =
          await tester.startGesture(tester.getCenter(find.byKey(const Key('child'))));
      await tester.pumpAndSettle();
      expect(_scaleOf(tester), closeTo(DabblerMotion.pressScale, 0.0001));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(_scaleOf(tester), 1);
    });

    testWidgets('does not steal the tap from a child gesture recogniser',
        (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        host(
          DabblerPressScale.gesture(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => taps++,
              child: _child,
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('child')));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('a disabled control ignores the pointer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const DabblerPressScale.gesture(enabled: false, child: _child)),
      );
      final TestGesture gesture =
          await tester.startGesture(tester.getCenter(find.byKey(const Key('child'))));
      await tester.pumpAndSettle();
      expect(_scaleOf(tester), 1);
      await gesture.up();
    });
  });
}
