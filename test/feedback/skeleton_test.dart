import 'package:dabbler_design_system/src/feedback/skeleton.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_palette.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps a skeleton in the minimum a widget test needs, with reduced motion
/// optionally forced on the way the platform would force it.
///
/// The skeleton sits in a 300px-wide slot. [tightWidth] chooses whether that
/// slot is imposed on it (the fluid `width: 100%` case) or merely available to
/// it (the case where the skeleton sizes itself).
Widget _host(
  Widget child, {
  bool disableAnimations = false,
  bool tightWidth = true,
}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 300,
          child: tightWidth
              ? child
              : Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    ),
  );
}

/// The decorations of the placeholder blocks themselves — the card variant also
/// paints a shell, which is not a block.
List<BoxDecoration> _blocks(WidgetTester tester) => _decorations(tester)
    .where((BoxDecoration d) => d.color == DabblerPalette.surfaceSunken)
    .toList();

/// Every [BoxDecoration] the skeleton paints.
List<BoxDecoration> _decorations(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(find.byType(DecoratedBox))
    .map((DecoratedBox d) => d.decoration)
    .whereType<BoxDecoration>()
    .toList();

void main() {
  group('the placeholder is flat — the acceptance criterion', () {
    testWidgets('no block carries a gradient, in any variant', (WidgetTester tester) async {
      for (final Widget skeleton in <Widget>[
        const DabblerSkeleton.text(),
        const DabblerSkeleton.rect(),
        const DabblerSkeleton.circle(),
        const DabblerSkeleton.card(),
      ]) {
        await tester.pumpWidget(_host(skeleton));
        final List<BoxDecoration> decorations = _decorations(tester);
        expect(decorations, isNotEmpty);
        for (final BoxDecoration decoration in decorations) {
          expect(decoration.gradient, isNull, reason: 'a shimmer is a gradient by another name');
          expect(decoration.image, isNull);
        }
      }
    });

    testWidgets('no block carries a shadow', (WidgetTester tester) async {
      for (final Widget skeleton in <Widget>[
        const DabblerSkeleton.text(),
        const DabblerSkeleton.rect(),
        const DabblerSkeleton.circle(),
        const DabblerSkeleton.card(),
      ]) {
        await tester.pumpWidget(_host(skeleton));
        for (final BoxDecoration decoration in _decorations(tester)) {
          expect(decoration.boxShadow, anyOf(isNull, isEmpty));
        }
      }
    });

    testWidgets('the fill is the flat --surface-sunken token', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSkeleton.rect()));
      expect(_decorations(tester).single.color, DabblerPalette.surfaceSunken);
      expect(DabblerSkeleton.fill, DabblerPalette.surfaceSunken);
    });

    testWidgets('the only animated property is opacity — nothing travels across the block',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSkeleton.text(lines: 3)));
      // Sample across a full cycle: the decoration is identical at every frame,
      // so no colour, size or position is moving. Only Opacity changes.
      final List<Color?> colours = <Color?>[];
      final Set<double> opacities = <double>{};
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        colours.addAll(_decorations(tester).map((BoxDecoration d) => d.color));
        opacities.addAll(
          tester.widgetList<Opacity>(find.byType(Opacity)).map((Opacity o) => o.opacity),
        );
        for (final BoxDecoration decoration in _decorations(tester)) {
          expect(decoration.gradient, isNull);
        }
      }
      expect(colours.toSet(), <Color>{DabblerPalette.surfaceSunken});
      expect(opacities.length, greaterThan(1), reason: 'the pulse should actually run');
    });
  });

  group('the pulse curve matches the source keyframe', () {
    test('1 → 0.55 → 1 over one cycle', () {
      expect(pulseOpacityAt(0), closeTo(1, 1e-9));
      expect(pulseOpacityAt(0.5), closeTo(DabblerSkeleton.pulseMinOpacity, 1e-9));
      expect(pulseOpacityAt(1), closeTo(1, 1e-9));
    });

    test('it wraps, and never leaves [0.55, 1]', () {
      for (double t = -2; t < 3; t += 0.017) {
        final double value = pulseOpacityAt(t);
        expect(value, greaterThanOrEqualTo(DabblerSkeleton.pulseMinOpacity - 1e-9));
        expect(value, lessThanOrEqualTo(1 + 1e-9));
      }
      expect(pulseOpacityAt(1.25), closeTo(pulseOpacityAt(0.25), 1e-9));
    });

    test('the timings are the source values', () {
      expect(DabblerSkeleton.pulsePeriod, const Duration(milliseconds: 1200));
      expect(DabblerSkeleton.pulseStagger, const Duration(milliseconds: 80));
      expect(DabblerSkeleton.pulseMinOpacity, 0.55);
      expect(DabblerSkeleton.reducedMotionOpacity, 0.72);
    });
  });

  group('motion can be switched off entirely', () {
    testWidgets('animate: false renders one static frame at full opacity',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSkeleton.rect(animate: false)));
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
      // No pending frames — nothing is scheduled.
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('reduced motion holds the source flat opacity of 0.72',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerSkeleton.text(lines: 3), disableAnimations: true),
      );
      for (final Opacity opacity in tester.widgetList<Opacity>(find.byType(Opacity))) {
        expect(opacity.opacity, DabblerSkeleton.reducedMotionOpacity);
      }
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });

  group('geometry comes from DS-104, not from literals', () {
    testWidgets('text bars are 12 high with a --space-3 gap and a sm radius',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSkeleton.text(lines: 3)));
      final List<BoxDecoration> decorations = _decorations(tester);
      expect(decorations, hasLength(3));
      for (final BoxDecoration decoration in decorations) {
        expect(
          decoration.borderRadius,
          BorderRadius.all(Radius.circular(DabblerRadius.sm)),
        );
      }
      final List<SizedBox> gaps = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where((SizedBox s) => s.height == DabblerSpacing.space3)
          .toList();
      expect(gaps, hasLength(2), reason: 'one gap between each pair of bars');
      expect(
        tester.getSize(find.byType(DecoratedBox).first).height,
        DabblerSkeleton.lineHeight,
      );
    });

    testWidgets('the last bar of a multi-line stack is 60% wide',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSkeleton.text(lines: 3)));
      final double full = tester.getSize(find.byType(DecoratedBox).first).width;
      final double last = tester.getSize(find.byType(DecoratedBox).last).width;
      expect(full, 300);
      expect(last, closeTo(full * 0.6, 0.5));
    });

    testWidgets('a single-line stack is not shortened', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSkeleton.text(lines: 1)));
      expect(_decorations(tester), hasLength(1));
      expect(tester.getSize(find.byType(DecoratedBox)).width, 300);
    });

    testWidgets('rect defaults to the 45px touch target and honours overrides',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSkeleton.rect()));
      expect(
        tester.getSize(find.byType(DecoratedBox)).height,
        DabblerSizing.touchTargetMin,
      );

      await tester.pumpWidget(
        _host(
          const DabblerSkeleton.rect(width: 120, height: 30, radius: DabblerRadius.xxl),
          tightWidth: false,
        ),
      );
      expect(tester.getSize(find.byType(DecoratedBox)), const Size(120, 30));
      expect(
        _decorations(tester).single.borderRadius,
        BorderRadius.all(Radius.circular(DabblerRadius.xxl)),
      );
    });

    testWidgets('circle is a pill-radius square, 45 by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerSkeleton.circle(), tightWidth: false),
      );
      expect(
        tester.getSize(find.byType(DecoratedBox)),
        const Size(DabblerSizing.touchTargetMin, DabblerSizing.touchTargetMin),
      );
      expect(
        _decorations(tester).single.borderRadius,
        BorderRadius.all(Radius.circular(DabblerRadius.pill)),
      );

      await tester.pumpWidget(
        _host(const DabblerSkeleton.circle(width: 30), tightWidth: false),
      );
      expect(tester.getSize(find.byType(DecoratedBox)), const Size(30, 30));
    });

    testWidgets('card is a hairline shell around a 16:9 media block and two bars',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSkeleton.card()));

      final BoxDecoration shell = tester
          .widget<Container>(find.byType(Container))
          .decoration! as BoxDecoration;
      expect(shell.color, DabblerPalette.surfaceCard);
      expect(shell.gradient, isNull);
      expect(shell.boxShadow, anyOf(isNull, isEmpty));
      expect(
        shell.border,
        Border.all(
          color: DabblerPalette.outlineCard,
          width: DabblerSizing.borderDefault,
        ),
      );
      expect(
        shell.borderRadius,
        BorderRadius.all(Radius.circular(DabblerRadius.lg)),
      );

      // Three blocks: media, title, meta — the shell is not one of them.
      expect(_blocks(tester), hasLength(3));
      final Size media = tester.getSize(find.byType(AspectRatio));
      expect(media.width / media.height, closeTo(16 / 9, 0.01));
    });
  });

  group('the skeleton is decorative', () {
    testWidgets('it is excluded from the semantics tree', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const DabblerSkeleton.card()));
      expect(find.byType(ExcludeSemantics), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(DabblerSkeleton)).childrenCount,
        0,
      );
      handle.dispose();
    });
  });
}
