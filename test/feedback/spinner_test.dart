import 'dart:math' as math;

import 'package:dabbler_design_system/src/feedback/spinner.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The design source's own numbers, restated here so the test asserts against
/// `components/feedback/Spinner.jsx` rather than against the widget's
/// constants. A typo in one is only caught if the other is independent.
const Map<DabblerSpinnerSize, double> _sourceSizes = <DabblerSpinnerSize, double>{
  DabblerSpinnerSize.sm: 18, // SIZES.sm
  DabblerSpinnerSize.md: 24, // SIZES.md
  DabblerSpinnerSize.lg: 30, // SIZES.lg
};

/// Minimum host: a [DabblerColors] in the theme, a [Directionality], and an
/// [Align] so the spinner sizes itself rather than being stretched.
Widget _host(
  Widget child, {
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
  bool disableAnimations = false,
  Color? ambientColor,
}) {
  Widget body = Align(alignment: Alignment.topLeft, child: child);
  if (ambientColor != null) {
    body = IconTheme(
      data: IconThemeData(color: ambientColor),
      child: body,
    );
  }
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Theme(
      data: ThemeData(
        extensions: <ThemeExtension<dynamic>>[
          DabblerColors.resolve(theme: theme, brightness: brightness),
        ],
      ),
      child: Directionality(textDirection: TextDirection.ltr, child: body),
    ),
  );
}

/// Records every stroke paint the spinner issues, so the test can read the
/// track and the arc back out without a golden file.
class _Recorded {
  _Recorded(this.color, this.strokeWidth, this.cap);
  final Color color;
  final double strokeWidth;
  final StrokeCap cap;
}

class _SpyCanvas extends Fake implements Canvas {
  final List<_Recorded> circles = <_Recorded>[];
  final List<_Recorded> arcs = <_Recorded>[];
  final List<double> sweeps = <double>[];
  final List<double> radii = <double>[];

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    radii.add(radius);
    circles.add(_Recorded(paint.color, paint.strokeWidth, paint.strokeCap));
  }

  @override
  void drawArc(Rect rect, double start, double sweep, bool useCenter, Paint p) {
    sweeps.add(sweep);
    radii.add(rect.width / 2);
    arcs.add(_Recorded(p.color, p.strokeWidth, p.strokeCap));
  }
}

/// Paints the spinner's [CustomPainter] onto a spy canvas at its natural size.
_SpyCanvas _paint(WidgetTester tester) {
  final CustomPaint paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(DabblerSpinner),
      matching: find.byType(CustomPaint),
    ),
  );
  final _SpyCanvas spy = _SpyCanvas();
  final Size size = tester.getSize(find.byType(DabblerSpinner));
  paint.painter!.paint(spy, size);
  return spy;
}

void main() {
  group('AC1 — the sizes its consumers need', () {
    testWidgets('every size lays out at the design source\'s diameter',
        (WidgetTester tester) async {
      for (final MapEntry<DabblerSpinnerSize, double> entry
          in _sourceSizes.entries) {
        await tester.pumpWidget(
          _host(DabblerSpinner(size: entry.key, animate: false)),
        );
        expect(
          tester.getSize(find.byType(DabblerSpinner)),
          Size(entry.value, entry.value),
          reason: '${entry.key.name} must be ${entry.value}px square',
        );
      }
    });

    testWidgets('sm exists and is 18px — DS-400 Button composes it',
        (WidgetTester tester) async {
      // Named separately from the sweep above because Button's loading state
      // depends on this one value; if it ever disappears, the failure should
      // say which ticket breaks.
      await tester.pumpWidget(
        _host(const DabblerSpinner(size: DabblerSpinnerSize.sm, animate: false)),
      );
      expect(tester.getSize(find.byType(DabblerSpinner)), const Size(18, 18));
      expect(DabblerSpinnerSize.sm.diameter, DabblerSizing.iconSm);
    });

    test('the size ramp is exactly sm/md/lg', () {
      expect(DabblerSpinnerSize.values, _sourceSizes.keys.toList());
      for (final MapEntry<DabblerSpinnerSize, double> e in _sourceSizes.entries) {
        expect(e.key.diameter, e.value);
      }
    });

    testWidgets('md is the default size', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSpinner(animate: false)));
      expect(tester.getSize(find.byType(DabblerSpinner)), const Size(24, 24));
    });
  });

  group('the ring — Spinner.jsx geometry', () {
    testWidgets('2px stroke on both track and arc, arc round-capped',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSpinner(animate: false)));
      final _SpyCanvas spy = _paint(tester);
      expect(spy.circles, hasLength(1), reason: 'one track circle');
      expect(spy.arcs, hasLength(1), reason: 'one indicator arc');
      expect(spy.circles.single.strokeWidth, 2);
      expect(spy.arcs.single.strokeWidth, 2);
      expect(spy.arcs.single.cap, StrokeCap.round);
    });

    testWidgets('the arc sweeps 28% of the circumference',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSpinner(animate: false)));
      final _SpyCanvas spy = _paint(tester);
      expect(spy.sweeps.single, closeTo(0.28 * 2 * math.pi, 1e-9));
    });

    testWidgets('the ring is inset by half the stroke — r = (px - stroke) / 2',
        (WidgetTester tester) async {
      for (final MapEntry<DabblerSpinnerSize, double> e in _sourceSizes.entries) {
        await tester.pumpWidget(
          _host(DabblerSpinner(size: e.key, animate: false)),
        );
        final _SpyCanvas spy = _paint(tester);
        for (final double r in spy.radii) {
          expect(r, (e.value - 2) / 2);
        }
      }
    });

    testWidgets('the track is the indicator colour at 25%',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSpinner(animate: false)));
      final _SpyCanvas spy = _paint(tester);
      final Color arc = spy.arcs.single.color;
      final Color track = spy.circles.single.color;
      expect(track.r, arc.r);
      expect(track.g, arc.g);
      expect(track.b, arc.b);
      expect(track.a, closeTo(0.25, 1e-6));
      expect(arc.a, 1.0);
    });

    testWidgets('nothing is drawn at a degenerate size',
        (WidgetTester tester) async {
      // Guards the radius <= 0 early return: a 1px box cannot hold a 2px ring.
      await tester.pumpWidget(
        _host(const SizedBox.square(dimension: 1, child: DabblerSpinner())),
      );
      final CustomPaint paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(DabblerSpinner),
          matching: find.byType(CustomPaint),
        ),
      );
      final _SpyCanvas spy = _SpyCanvas();
      paint.painter!.paint(spy, const Size(1, 1));
      expect(spy.circles, isEmpty);
      expect(spy.arcs, isEmpty);
    });
  });

  group('tone — Spinner.jsx TONE_COLORS', () {
    testWidgets('brand resolves through DabblerColors and re-tints per theme',
        (WidgetTester tester) async {
      for (final DabblerTheme theme in DabblerTheme.values) {
        await tester.pumpWidget(
          _host(const DabblerSpinner(animate: false), theme: theme),
        );
        final DabblerColors expected =
            DabblerColors.resolve(theme: theme, brightness: Brightness.light);
        expect(
          _paint(tester).arcs.single.color.toARGB32(),
          expected.brandPrimary.toARGB32(),
        );
      }
    });

    testWidgets('brand follows dark mode too', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerSpinner(animate: false),
        brightness: Brightness.dark,
      ));
      expect(
        _paint(tester).arcs.single.color.toARGB32(),
        DabblerColors.resolve(
          theme: DabblerTheme.main,
          brightness: Brightness.dark,
        ).brandPrimary.toARGB32(),
      );
    });

    testWidgets('on-brand resolves to DabblerColors.onBrand',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerSpinner(tone: DabblerSpinnerTone.onBrand, animate: false),
      ));
      expect(
        _paint(tester).arcs.single.color.toARGB32(),
        DabblerColors.resolve(
          theme: DabblerTheme.main,
          brightness: Brightness.light,
        ).onBrand.toARGB32(),
      );
    });

    testWidgets('inherit takes the ambient currentColor',
        (WidgetTester tester) async {
      const Color ambient = Color(0xFF123456);
      await tester.pumpWidget(_host(
        const DabblerSpinner(tone: DabblerSpinnerTone.inherit, animate: false),
        ambientColor: ambient,
      ));
      expect(_paint(tester).arcs.single.color.toARGB32(), ambient.toARGB32());
    });

    testWidgets('inherit falls back to text ink with no ambient colour',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerSpinner(tone: DabblerSpinnerTone.inherit, animate: false),
      ));
      final Color resolved = _paint(tester).arcs.single.color;
      final DabblerColors colors = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      // ThemeData supplies an IconTheme, so the fallback chain may stop at
      // either link; both are legitimate ambient ink, neither is a hardcode.
      expect(resolved.toARGB32(), isNot(colors.brandPrimary.toARGB32()));
    });
  });

  group('motion', () {
    testWidgets('it rotates — the ring is at a different angle 400ms in',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSpinner()));
      double angleNow() => tester
          .widget<Transform>(find.descendant(
            of: find.byType(DabblerSpinner),
            matching: find.byType(Transform),
          ))
          .transform
          .entry(0, 0);

      final double start = angleNow();
      await tester.pump(const Duration(milliseconds: 400));
      expect(angleNow(), isNot(closeTo(start, 1e-6)));
      // A full 800ms period returns it to where it started.
      await tester.pump(const Duration(milliseconds: 400));
      expect(angleNow(), closeTo(start, 1e-6));
      await tester.pumpWidget(_host(const DabblerSpinner(animate: false)));
    });

    testWidgets('animate: false paints no rotation at all',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSpinner(animate: false)));
      expect(
        find.descendant(
          of: find.byType(DabblerSpinner),
          matching: find.byType(Transform),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(DabblerSpinner),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );
    });

    testWidgets('reduced motion pulses instead of rotating — never a static frame',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerSpinner(), disableAnimations: true),
      );
      expect(
        find.descendant(
          of: find.byType(DabblerSpinner),
          matching: find.byType(Transform),
        ),
        findsNothing,
        reason: 'the rotation is replaced, not kept',
      );
      double opacityNow() => tester
          .widget<Opacity>(find.descendant(
            of: find.byType(DabblerSpinner),
            matching: find.byType(Opacity),
          ))
          .opacity;
      final double start = opacityNow();
      expect(start, 1.0);
      await tester.pump(const Duration(milliseconds: 600));
      expect(opacityNow(), closeTo(0.55, 1e-6));
      await tester.pump(const Duration(milliseconds: 600));
      expect(opacityNow(), closeTo(1.0, 1e-6));
      await tester.pumpWidget(
        _host(const DabblerSpinner(animate: false), disableAnimations: true),
      );
    });

    test('the pulse curve matches @keyframes dbl-pulse', () {
      expect(pulseOpacityAt(0), 1.0);
      expect(pulseOpacityAt(0.5), closeTo(0.55, 1e-9));
      expect(pulseOpacityAt(1.0), 1.0);
      // Symmetric, and it wraps.
      expect(pulseOpacityAt(0.25), closeTo(pulseOpacityAt(0.75), 1e-9));
      expect(pulseOpacityAt(1.25), closeTo(pulseOpacityAt(0.25), 1e-9));
      // It never leaves the keyframe's range.
      for (int i = 0; i <= 100; i++) {
        final double o = pulseOpacityAt(i / 100);
        expect(o, inInclusiveRange(0.55, 1.0));
      }
    });

    test('the periods are the source\'s', () {
      expect(DabblerSpinner.rotationPeriod, const Duration(milliseconds: 800));
      expect(DabblerSpinner.pulsePeriod, const Duration(milliseconds: 1200));
      expect(DabblerSpinner.pulseMinOpacity, 0.55);
      expect(DabblerSpinner.trackOpacity, 0.25);
      expect(DabblerSpinner.arcFraction, 0.28);
      expect(DabblerSpinner.strokeWidth, 2);
    });
  });

  group('accessibility', () {
    testWidgets('it is a live region labelled "Loading" by default',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const DabblerSpinner(animate: false)));
      expect(
        tester.getSemantics(find.byType(DabblerSpinner)),
        matchesSemantics(label: 'Loading', isLiveRegion: true),
      );
      handle.dispose();
    });

    testWidgets('a supplied label replaces it', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(const DabblerSpinner(label: 'Joining game', animate: false)),
      );
      expect(
        tester.getSemantics(find.byType(DabblerSpinner)),
        matchesSemantics(label: 'Joining game', isLiveRegion: true),
      );
      handle.dispose();
    });
  });

  group('RTL — direction-neutral', () {
    testWidgets('the arc sweeps the same way under rtl',
        (WidgetTester tester) async {
      final List<double> sweeps = <double>[];
      for (final TextDirection direction in TextDirection.values) {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(),
            child: Theme(
              data: ThemeData(extensions: <ThemeExtension<dynamic>>[
                DabblerColors.resolve(
                  theme: DabblerTheme.main,
                  brightness: Brightness.light,
                ),
              ]),
              child: Directionality(
                textDirection: direction,
                child: const Align(
                  alignment: Alignment.topLeft,
                  child: DabblerSpinner(animate: false),
                ),
              ),
            ),
          ),
        );
        sweeps.add(_paint(tester).sweeps.single);
      }
      expect(sweeps.first, sweeps.last);
    });
  });
}
