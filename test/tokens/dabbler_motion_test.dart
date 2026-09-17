import 'package:dabbler_design_system/src/tokens/dabbler_motion.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The design source's own numbers, restated here so the test asserts against
/// `tokens/spacing.css:58-74` rather than against the token class. A typo in
/// one is only caught if the other is independent.
const int _sourceFastMs = 80;
const int _sourceBaseMs = 120;
const int _sourceSlowMs = 200;
const Cubic _sourceEaseOut = Cubic(0.2, 0, 0.2, 1);
const double _sourcePressScale = 0.98;

/// Reads [DabblerMotion.reduceMotion] out of a real element, with the platform
/// flag set the way the platform would set it.
Widget _probe({required bool disableAnimations, required void Function(bool) sink}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Builder(
      builder: (BuildContext context) {
        sink(DabblerMotion.reduceMotion(context));
        return const SizedBox.shrink();
      },
    ),
  );
}

void main() {
  group('AC1 — the five constants are the source values', () {
    test('--motion-fast: 80ms', () {
      expect(DabblerMotion.fast, const Duration(milliseconds: _sourceFastMs));
    });

    test('--motion-base: 120ms', () {
      expect(DabblerMotion.base, const Duration(milliseconds: _sourceBaseMs));
    });

    test('--motion-slow: 200ms', () {
      expect(DabblerMotion.slow, const Duration(milliseconds: _sourceSlowMs));
    });

    test('--ease-out: cubic-bezier(.2, 0, .2, 1)', () {
      expect(DabblerMotion.easeOut, _sourceEaseOut);
    });

    test('--press-scale: .98', () {
      expect(DabblerMotion.pressScale, _sourcePressScale);
    });

    test('the scale is ordered fast < base < slow', () {
      expect(DabblerMotion.fast, lessThan(DabblerMotion.base));
      expect(DabblerMotion.base, lessThan(DabblerMotion.slow));
    });
  });

  group('reduceMotion reads MediaQuery.maybeDisableAnimationsOf', () {
    testWidgets('false when the platform has not asked for it',
        (WidgetTester tester) async {
      bool? seen;
      await tester.pumpWidget(
        _probe(disableAnimations: false, sink: (bool v) => seen = v),
      );
      expect(seen, isFalse);
    });

    testWidgets('true when the platform has', (WidgetTester tester) async {
      bool? seen;
      await tester.pumpWidget(
        _probe(disableAnimations: true, sink: (bool v) => seen = v),
      );
      expect(seen, isTrue);
    });

    testWidgets('false — never an exception — with no MediaQuery in scope',
        (WidgetTester tester) async {
      bool? seen;
      await tester.pumpWidget(
        Builder(
          builder: (BuildContext context) {
            seen = DabblerMotion.reduceMotion(context);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(seen, isFalse);
    });
  });

  group('AC4 — one pulse curve for the whole system', () {
    test('@keyframes dbl-pulse: 1 → min → 1 over one cycle', () {
      double at(double t) => DabblerMotion.pulseOpacityAt(t, minOpacity: 0.55);
      expect(at(0), closeTo(1, 1e-9));
      expect(at(0.5), closeTo(0.55, 1e-9));
      expect(at(1), closeTo(1, 1e-9));
    });

    test('it is symmetric, it wraps, and it stays in range', () {
      double at(double t) => DabblerMotion.pulseOpacityAt(t, minOpacity: 0.55);
      expect(at(0.25), closeTo(at(0.75), 1e-9));
      expect(at(1.25), closeTo(at(0.25), 1e-9));
      for (double t = -2; t < 3; t += 0.017) {
        expect(at(t), inInclusiveRange(0.55 - 1e-9, 1 + 1e-9));
      }
    });

    test('the floor is the caller\'s, not the curve\'s', () {
      expect(
        DabblerMotion.pulseOpacityAt(0.5, minOpacity: 0.2),
        closeTo(0.2, 1e-9),
      );
      expect(
        DabblerMotion.pulseOpacityAt(0, minOpacity: 0.2),
        closeTo(1, 1e-9),
      );
    });
  });
}
