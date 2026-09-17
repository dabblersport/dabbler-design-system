import 'package:dabbler_design_system/src/feedback/progress_bar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_motion.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// The shared curve ([DabblerMotion.pulseOpacityAt]) bound to the bar's own
/// floor, so the assertions below read exactly as they did when the function
/// lived in `progress_bar.dart`. Only its home changed, not its output.
double progressPulseOpacityAt(double t) => DabblerMotion.pulseOpacityAt(
      t,
      minOpacity: DabblerProgressBar.pulseMinOpacity,
    );

/// The one theme the bar resolves its colours through. `main` is the `:root`
/// default of `tokens/colors.css`.
DabblerColors _colors([DabblerTheme theme = DabblerTheme.main]) =>
    DabblerColors.resolve(theme: theme, brightness: Brightness.light);

/// Hosts a bar in a 300px slot, with the [DabblerColors] extension installed
/// the way the app installs it.
Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  bool disableAnimations = false,
  DabblerTheme theme = DabblerTheme.main,
}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Directionality(
      textDirection: direction,
      child: Theme(
        data: ThemeData(
          extensions: <ThemeExtension<dynamic>>[_colors(theme)],
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 300, child: child),
        ),
      ),
    ),
  );
}

/// The rects of every [ColoredBox] the bar paints, in paint order: the track
/// first, then the fill.
List<(Color, Rect)> _bars(WidgetTester tester) {
  return tester
      .widgetList<ColoredBox>(find.byType(ColoredBox))
      .map((ColoredBox box) => (
            box.color,
            tester.getRect(find.byWidget(box)),
          ))
      .toList();
}

void main() {
  group('tokens — AC1: no literal colours, DS-102/DS-104 tokens only', () {
    testWidgets('track is bgTertiary and the brand fill is brandPrimary',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerProgressBar(value: 0.5)));
      await tester.pumpAndSettle();

      final List<Color> painted =
          _bars(tester).map(((Color, Rect) b) => b.$1).toList();
      expect(painted, <Color>[_colors().bgTertiary, _colors().brandPrimary]);
    });

    testWidgets('the brand fill re-tints per theme', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerProgressBar(value: 0.5),
        theme: DabblerTheme.sport,
      ));
      await tester.pumpAndSettle();

      expect(_bars(tester).last.$1, _colors(DabblerTheme.sport).brandPrimary);
      expect(
        _colors(DabblerTheme.sport).brandPrimary,
        isNot(_colors().brandPrimary),
        reason: 'the two themes must differ, or the assertion proves nothing',
      );
    });

    test('every status tone resolves to that status base, never a literal', () {
      final DabblerColors colors = _colors();
      expect(
        DabblerProgressBar.fillFor(DabblerProgressBarTone.success, colors),
        colors.success.base,
      );
      expect(
        DabblerProgressBar.fillFor(DabblerProgressBarTone.warning, colors),
        colors.warning.base,
      );
      expect(
        DabblerProgressBar.fillFor(DabblerProgressBarTone.error, colors),
        colors.error.base,
      );
      expect(
        DabblerProgressBar.fillFor(DabblerProgressBarTone.info, colors),
        colors.info.base,
      );
    });

    test('track heights are the source SIZES, and are on the base-3 grid', () {
      // `const SIZES = { sm: 3, md: 6 }` in ProgressBar.jsx.
      expect(DabblerProgressBar.trackHeightFor(DabblerProgressBarSize.sm), 3);
      expect(DabblerProgressBar.trackHeightFor(DabblerProgressBarSize.md), 6);
      expect(DabblerSpacing.scale,
          containsAll(<double>[DabblerProgressBar.trackHeightSm,
              DabblerProgressBar.trackHeightMd]));
    });

    testWidgets('the track is pill radius and md is 6px tall',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerProgressBar(value: 0.5)));
      await tester.pumpAndSettle();

      final ClipRRect clip = tester.widget(find.byType(ClipRRect));
      expect(clip.borderRadius, DabblerRadius.pillAll);
      expect(tester.getSize(find.byType(ClipRRect)).height,
          DabblerProgressBar.trackHeightMd);
    });

    testWidgets('sm renders a 3px track', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerProgressBar(
        value: 0.5,
        size: DabblerProgressBarSize.sm,
      )));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(ClipRRect)).height,
          DabblerProgressBar.trackHeightSm);
    });

    testWidgets('it paints no shadow and no gradient',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerProgressBar(
        value: 0.5,
        label: 'profile',
        showValue: true,
      )));
      await tester.pumpAndSettle();

      for (final BoxDecoration d in tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((DecoratedBox b) => b.decoration)
          .whereType<BoxDecoration>()) {
        expect(d.boxShadow, anyOf(isNull, isEmpty));
        expect(d.gradient, isNull);
      }
    });
  });

  group('value', () {
    test('is a fraction rounded to a percentage, and is clamped', () {
      expect(DabblerProgressBar.percentOf(0.6), 60);
      expect(DabblerProgressBar.percentOf(8 / 10), 80);
      expect(DabblerProgressBar.percentOf(0.005), 1);
      expect(DabblerProgressBar.percentOf(-1), 0);
      expect(DabblerProgressBar.percentOf(4), 100);
      expect(DabblerProgressBar.percentOf(null), isNull);
    });

    testWidgets('the fill occupies that fraction of the track',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerProgressBar(value: 0.6)));
      await tester.pumpAndSettle();

      final List<(Color, Rect)> bars = _bars(tester);
      expect(bars.last.$2.width, moreOrLessEquals(bars.first.$2.width * 0.6));
    });

    testWidgets('value 1 fills the track completely',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerProgressBar(value: 1)));
      await tester.pumpAndSettle();

      final List<(Color, Rect)> bars = _bars(tester);
      expect(bars.last.$2.width, moreOrLessEquals(bars.first.$2.width));
    });
  });

  group('RTL', () {
    testWidgets('LTR fills from the left edge', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerProgressBar(value: 0.5)));
      await tester.pumpAndSettle();

      final List<(Color, Rect)> bars = _bars(tester);
      expect(bars.last.$2.left, moreOrLessEquals(bars.first.$2.left),
          reason: 'the fill is anchored to the inline start');
      expect(bars.last.$2.right, lessThan(bars.first.$2.right));
    });

    testWidgets('RTL fills from the RIGHT edge — the start edge there',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerProgressBar(value: 0.5),
        direction: TextDirection.rtl,
      ));
      await tester.pumpAndSettle();

      final List<(Color, Rect)> bars = _bars(tester);
      expect(bars.last.$2.right, moreOrLessEquals(bars.first.$2.right),
          reason: 'inset-inline-start is the right edge under RTL');
      expect(bars.last.$2.left, greaterThan(bars.first.$2.left));
      expect(bars.last.$2.width, moreOrLessEquals(bars.first.$2.width * 0.5));
    });

    testWidgets('the label row puts the percentage at the inline end',
        (WidgetTester tester) async {
      const Widget bar = DabblerProgressBar(
        value: 0.6,
        label: 'profile',
        showValue: true,
      );

      await tester.pumpWidget(_host(bar));
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.text('60%')).dx,
          greaterThan(tester.getCenter(find.text('profile')).dx));

      await tester.pumpWidget(_host(bar, direction: TextDirection.rtl));
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.text('60%')).dx,
          lessThan(tester.getCenter(find.text('profile')).dx));
    });

    testWidgets('the sweep travels start → end in both directions',
        (WidgetTester tester) async {
      for (final TextDirection direction in TextDirection.values) {
        await tester.pumpWidget(_host(
          const DabblerProgressBar.indeterminate(),
          direction: direction,
        ));
        await tester.pump();
        final double startEdge = _bars(tester).last.$2.center.dx;
        await tester.pump(DabblerProgressBar.sweepPeriod ~/ 2);
        final double midEdge = _bars(tester).last.$2.center.dx;

        expect(
          direction == TextDirection.ltr
              ? midEdge > startEdge
              : midEdge < startEdge,
          isTrue,
          reason: 'the $direction sweep must move toward the end edge',
        );
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });
  });

  group('indeterminate', () {
    test('the sweep is the source keyframe, 33% wide over 1.4s', () {
      expect(DabblerProgressBar.indeterminateWidthFactor, 0.33);
      expect(DabblerProgressBar.sweepPeriod,
          const Duration(milliseconds: 1400));
      expect(progressSweepOffsetAt(0), DabblerProgressBar.sweepStart);
      expect(progressSweepOffsetAt(1), DabblerProgressBar.sweepEnd);
      expect(progressSweepOffsetAt(0.5),
          moreOrLessEquals(
              (DabblerProgressBar.sweepStart + DabblerProgressBar.sweepEnd) / 2));
    });

    testWidgets('the bar is 33% of the track and keeps moving',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(_host(const DabblerProgressBar.indeterminate()));
      await tester.pump();

      final List<(Color, Rect)> bars = _bars(tester);
      expect(bars.last.$2.width,
          moreOrLessEquals(bars.first.$2.width * 0.33, epsilon: 0.5));

      await tester.pump(const Duration(milliseconds: 200));
      expect(_bars(tester).last.$2.left, isNot(bars.last.$2.left));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('no percentage is rendered even with showValue',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerProgressBar.indeterminate(label: 'uploading'),
      ));
      await tester.pump();

      expect(find.text('uploading'), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('reduced motion', () {
    test('the pulse is dbl-pulse: 1 → .55 → 1 over 1.2s', () {
      expect(DabblerProgressBar.pulsePeriod,
          const Duration(milliseconds: 1200));
      expect(progressPulseOpacityAt(0), 1);
      expect(progressPulseOpacityAt(0.5),
          moreOrLessEquals(DabblerProgressBar.pulseMinOpacity));
      expect(progressPulseOpacityAt(1), 1);
    });

    testWidgets('the indeterminate sweep becomes a pulse in place',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerProgressBar.indeterminate(),
        disableAnimations: true,
      ));
      await tester.pump();

      final double left = _bars(tester).last.$2.left;
      final double opacity =
          tester.widget<Opacity>(find.byType(Opacity)).opacity;

      await tester.pump(DabblerProgressBar.pulsePeriod ~/ 2);
      expect(_bars(tester).last.$2.left, moreOrLessEquals(left),
          reason: 'transform:none — the bar must not travel');
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity,
          isNot(moreOrLessEquals(opacity)));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('the determinate fill snaps instead of animating',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerProgressBar(value: 0.2),
        disableAnimations: true,
      ));
      await tester.pump();

      await tester.pumpWidget(_host(
        const DabblerProgressBar(value: 0.8),
        disableAnimations: true,
      ));
      await tester.pump();

      final List<(Color, Rect)> bars = _bars(tester);
      expect(bars.last.$2.width, moreOrLessEquals(bars.first.$2.width * 0.8),
          reason: 'with motion off the new width is reached on the first frame');
      expect(find.byType(AnimatedFractionallySizedBox), findsNothing);
    });

    testWidgets('with motion on, the fill animates over --motion-base',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerProgressBar(value: 0.2)));
      await tester.pumpAndSettle();
      await tester.pumpWidget(_host(const DabblerProgressBar(value: 0.8)));
      await tester.pump();
      await tester.pump(DabblerProgressBar.valueTransition ~/ 2);

      final List<(Color, Rect)> bars = _bars(tester);
      final double factor = bars.last.$2.width / bars.first.$2.width;
      expect(factor, greaterThan(0.2));
      expect(factor, lessThan(0.8));

      await tester.pumpAndSettle();
      expect(_bars(tester).last.$2.width,
          moreOrLessEquals(bars.first.$2.width * 0.8));
    });
  });

  group('semantics', () {
    testWidgets('a determinate bar reports name, 0, 100 and the percentage',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const DabblerProgressBar(
        value: 0.6,
        label: 'profile',
      )));
      await tester.pumpAndSettle();

      final SemanticsNode node = tester.getSemantics(
          find.byType(DabblerProgressBar));
      expect(node.role, SemanticsRole.progressBar);
      expect(node.label, 'profile');
      expect(node.value, '60%');
      // The source's aria-valuemin / aria-valuemax.
      final SemanticsData data = node.getSemanticsData();
      expect(data.minValue, '0');
      expect(data.maxValue, '100');
      handle.dispose();
    });

    testWidgets('an indeterminate bar announces busy, not a number',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const DabblerProgressBar.indeterminate(label: 'uploading'),
      ));
      await tester.pump();

      final SemanticsNode node =
          tester.getSemantics(find.byType(DabblerProgressBar));
      expect(node.role, SemanticsRole.loadingSpinner);
      expect(node.label, 'uploading');
      expect(node.value, isEmpty,
          reason: 'aria-valuenow is deliberately omitted when indeterminate');

      await tester.pumpWidget(const SizedBox.shrink());
      handle.dispose();
    });
  });

  group('label row', () {
    testWidgets('is omitted entirely when there is nothing to put in it',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerProgressBar(value: 0.5)));
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsNothing);
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('caption and value are .t-caption-1 in the right inks',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerProgressBar(
        value: 0.6,
        label: 'profile',
        showValue: true,
      )));
      await tester.pumpAndSettle();

      final TextStyle base = DabblerType.caption1.resolve();
      final TextStyle label = tester.widget<Text>(find.text('profile')).style!;
      final TextStyle value = tester.widget<Text>(find.text('60%')).style!;

      expect(label.fontSize, base.fontSize);
      expect(value.fontSize, base.fontSize);
      expect(label.color, _colors().textSecondary);
      expect(value.color, _colors().textPrimary);
      // Western Arabic numerals with lining figures, per ProgressBar.prompt.md.
      expect(value.fontFeatures, DabblerType.numeralFeatures);
    });

    testWidgets('the Arabic resolution still renders Western digits',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerProgressBar(value: 0.6, label: 'الملف', showValue: true),
        direction: TextDirection.rtl,
      ));
      await tester.pumpAndSettle();

      expect(find.text('60%'), findsOneWidget);
      final TextStyle value = tester.widget<Text>(find.text('60%')).style!;
      expect(value.fontFeatures, contains(const FontFeature.disable('anum')));
    });

    testWidgets('the gap under the label row is --space-2',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerProgressBar(
        value: 0.5,
        label: 'profile',
      )));
      await tester.pumpAndSettle();

      final Rect labelRect = tester.getRect(find.byType(Row));
      final Rect trackRect = tester.getRect(find.byType(ClipRRect));
      expect(trackRect.top - labelRect.bottom,
          moreOrLessEquals(DabblerSpacing.space2));
    });
  });
}
