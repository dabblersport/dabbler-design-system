import 'package:dabbler_design_system/src/controls/fab.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hosts [child] under a [DabblerColors] resolved for [theme] at [brightness].
Widget _host(
  Widget child, {
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) {
  final DabblerColors colors =
      DabblerColors.resolve(theme: theme, brightness: brightness);
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
    home: Directionality(
      textDirection: TextDirection.ltr,
      child: Align(alignment: Alignment.topLeft, child: child),
    ),
  );
}

/// The FAB's own painted box — the one with a [BoxDecoration.boxShadow].
BoxDecoration _fabDecoration(WidgetTester tester) {
  final Iterable<Container> boxes = tester
      .widgetList<Container>(find.descendant(
        of: find.byType(DabblerFab),
        matching: find.byType(Container),
      ))
      .where((Container c) =>
          c.decoration is BoxDecoration &&
          (c.decoration! as BoxDecoration).color != null);
  expect(boxes.length, 1, reason: 'exactly one painted FAB body');
  return boxes.single.decoration! as BoxDecoration;
}

void main() {
  group('AC1 — 56×56, four tones from the merged Figma symbols', () {
    testWidgets('lays out at exactly 56×56', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerFab(onPressed: () {}, child: const Text('+')),
      ));
      final Size size = tester.getSize(find.descendant(
        of: find.byType(DabblerFab),
        matching: find.byType(Container).last,
      ));
      expect(size, const Size(DabblerFab.size, DabblerFab.size));
      expect(DabblerFab.size, 56);
    });

    test('clears the touch-target floor', () {
      expect(DabblerFab.size, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
    });

    test('the tone enum collapses exactly the kit\'s four FAB symbols', () {
      expect(DabblerFabTone.values, hasLength(4));
      expect(
        DabblerFabTone.values.map((DabblerFabTone t) => t.source),
        <String>['default', 'primary', 'accent', 'dark'],
      );
    });

    test('primary is the default tone, as in FAB.jsx', () {
      expect(
        const DabblerFab(child: SizedBox.shrink()).tone,
        DabblerFabTone.primary,
      );
    });

    testWidgets('each tone paints its source fill', (WidgetTester tester) async {
      final DabblerColors colors = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      // `FAB.jsx` TONES: default -> --accent-indigo,
      // primary -> --color-brand-primary, accent -> --color-accent,
      // dark -> --surface-sunken.
      final Map<DabblerFabTone, Color> expected = <DabblerFabTone, Color>{
        DabblerFabTone.indigo: DabblerPalette.accentIndigo,
        DabblerFabTone.primary: colors.brandPrimary,
        DabblerFabTone.accent: colors.accent,
        DabblerFabTone.dark: colors.surfaceSunken,
      };
      for (final MapEntry<DabblerFabTone, Color> e in expected.entries) {
        await tester.pumpWidget(_host(
          DabblerFab(tone: e.key, onPressed: () {}, child: const Text('+')),
        ));
        expect(_fabDecoration(tester).color, e.value, reason: e.key.name);
      }
    });

    testWidgets('the three light tones carry --surface-card ink and dark carries --ink',
        (WidgetTester tester) async {
      final DabblerColors colors = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      for (final DabblerFabTone tone in <DabblerFabTone>[
        DabblerFabTone.indigo,
        DabblerFabTone.primary,
        DabblerFabTone.accent,
      ]) {
        expect(DabblerFab.foregroundOf(tone, colors), colors.surfaceCard,
            reason: tone.name);
      }
      expect(DabblerFab.foregroundOf(DabblerFabTone.dark, colors),
          colors.textPrimary);
    });

    testWidgets('the fill tracks the enclosing section theme',
        (WidgetTester tester) async {
      for (final DabblerTheme theme in DabblerTheme.values) {
        await tester.pumpWidget(_host(
          DabblerFab(onPressed: () {}, child: const Text('+')),
          theme: theme,
        ));
        // MaterialApp animates a ThemeData change through AnimatedTheme.
        await tester.pumpAndSettle();
        final DabblerColors colors = DabblerColors.resolve(
          theme: theme,
          brightness: Brightness.light,
        );
        expect(_fabDecoration(tester).color, colors.brandPrimary,
            reason: theme.name);
      }
    });
  });

  group('AC2 — the one deliberate drop shadow, and it is NOT the Dialog token',
      () {
    testWidgets('the FAB paints a shadow at all', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerFab(onPressed: () {}, child: const Text('+')),
      ));
      expect(_fabDecoration(tester).boxShadow, isNotEmpty);
      expect(_fabDecoration(tester).boxShadow, DabblerFab.shadow);
    });

    test('it transcribes FAB.jsx layer for layer', () {
      // `0px 10px 15px -3px rgba(0,0,0,0.1), 0px 4px 6px -4px rgba(0,0,0,0.1)`
      expect(DabblerFab.shadow, hasLength(2));

      final BoxShadow first = DabblerFab.shadow[0];
      expect(first.offset, const Offset(0, 10));
      expect(first.blurRadius, 15);
      expect(first.spreadRadius, -3);
      expect(first.color.a, closeTo(0.1, 0.001));

      final BoxShadow second = DabblerFab.shadow[1];
      expect(second.offset, const Offset(0, 4));
      expect(second.blurRadius, 6);
      expect(second.spreadRadius, -4);
      expect(second.color.a, closeTo(0.1, 0.001));

      // Pure black in both layers — the source writes rgba(0,0,0,.1).
      for (final BoxShadow s in DabblerFab.shadow) {
        expect(<double>[s.color.r, s.color.g, s.color.b], <double>[0, 0, 0]);
      }
    });

    test('it is NOT DabblerElevation.dialogFor, in either mode', () {
      expect(DabblerFab.shadow,
          isNot(equals(DabblerElevation.dialogFor(Brightness.light))));
      expect(DabblerFab.shadow,
          isNot(equals(DabblerElevation.dialogFor(Brightness.dark))));
      expect(DabblerFab.shadow, isNot(equals(DabblerElevation.dialogLight)));
      expect(DabblerFab.shadow, isNot(equals(DabblerElevation.dialogDark)));
    });

    testWidgets('the same shadow is drawn in dark mode — the source declares it once',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerFab(onPressed: () {}, child: const Text('+')),
        brightness: Brightness.dark,
      ));
      expect(_fabDecoration(tester).boxShadow, DabblerFab.shadow);
    });

    test('the shadow list is unmodifiable', () {
      expect(
        () => DabblerFab.shadow.add(const BoxShadow()),
        throwsUnsupportedError,
      );
    });
  });

  group('geometry and state', () {
    testWidgets('draws the source\'s 21px corner, not a pill',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerFab(onPressed: () {}, child: const Text('+')),
      ));
      expect(
        _fabDecoration(tester).borderRadius,
        const BorderRadius.all(Radius.circular(DabblerSpacing.space7)),
      );
      expect(DabblerFab.cornerRadius, 21);
      expect(DabblerFab.cornerRadius, isNot(DabblerRadius.pill));
    });

    testWidgets('fires onPressed when tapped', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(_host(
        DabblerFab(onPressed: () => taps++, child: const Text('+')),
      ));
      await tester.tap(find.byType(DabblerFab));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('a null onPressed disables it: 0.45 opacity and no gestures',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerFab(child: Text('+')),
      ));
      final Opacity opacity = tester.widget<Opacity>(find.descendant(
        of: find.byType(DabblerFab),
        matching: find.byType(Opacity),
      ));
      expect(opacity.opacity, DabblerFab.disabledOpacity);
      expect(
        find.descendant(
          of: find.byType(DabblerFab),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
    });

    testWidgets('an enabled FAB is at full opacity', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerFab(onPressed: () {}, child: const Text('+')),
      ));
      final Opacity opacity = tester.widget<Opacity>(find.descendant(
        of: find.byType(DabblerFab),
        matching: find.byType(Opacity),
      ));
      expect(opacity.opacity, 1);
    });

    testWidgets('press scales to 0.96 and releases back to 1',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerFab(onPressed: () {}, child: const Text('+')),
      ));
      AnimatedScale scale() => tester.widget<AnimatedScale>(
          find.byType(AnimatedScale));
      expect(scale().scale, 1);

      final TestGesture gesture =
          await tester.startGesture(tester.getCenter(find.byType(DabblerFab)));
      await tester.pump();
      expect(scale().scale, DabblerFab.pressedScale);
      expect(scale().duration, DabblerFab.pressDuration);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(scale().scale, 1);
    });

    testWidgets('announces itself as a labelled button',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        DabblerFab(
          onPressed: () {},
          semanticLabel: 'Create game',
          child: const Text('+'),
        ),
      ));
      expect(
        tester.getSemantics(find.byType(DabblerFab)),
        matchesSemantics(
          label: 'Create game',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });
}
