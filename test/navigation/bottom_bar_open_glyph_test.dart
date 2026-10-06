import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// `actionOpenIcon` — the action's open-state glyph.
///
/// The Home Feed design shows the open create menu with `close-circle` on the
/// action (`fabIcon: createMenuOpen ? 'close-circle' : 'add'`): a bold,
/// onBrand disc with the ✕ cut out, so the ✕ reads in the brand fill. Unset,
/// the action keeps [DabblerNavigationBottomBar.actionIcon] in both states.
///
/// `--dart-define=PRINT_OPEN_GLYPH_CONTRAST=1` prints the ✕-on-disc ratios.
double _ratio(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double hi = la > lb ? la : lb;
  final double lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

DabblerColors _colors(Brightness b) =>
    DabblerColors.resolve(theme: DabblerTheme.main, brightness: b);

Widget _host(
  Widget child, {
  required TextDirection direction,
  required Brightness brightness,
  bool disableAnimations = true,
}) => MediaQuery(
  data: MediaQueryData(disableAnimations: disableAnimations),
  child: Directionality(
    textDirection: direction,
    child: Theme(
      data: ThemeData(
        extensions: <ThemeExtension<dynamic>>[_colors(brightness)],
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(width: 393, child: child),
      ),
    ),
  ),
);

/// The glyphs the action is drawing (more than one mid cross-fade).
List<DabblerIcon> _actionGlyphs(WidgetTester t) => t
    .widgetList<DabblerIcon>(
      find.descendant(
        of: find.byType(AnimatedRotation),
        matching: find.byType(DabblerIcon),
      ),
    )
    .toList();

void main() {
  test('defaults to null: existing callers keep one glyph', () {
    expect(const DabblerNavigationBottomBar().actionOpenIcon, isNull);
  });

  for (final Brightness brightness in Brightness.values) {
    for (final TextDirection dir in TextDirection.values) {
      final String tag = '${dir.name} ${brightness.name}';

      testWidgets('unset: the action draws actionIcon open and closed - $tag', (
        WidgetTester t,
      ) async {
        for (final bool open in <bool>[false, true]) {
          await t.pumpWidget(
            _host(
              DabblerNavigationBottomBar(
                key: ValueKey<bool>(open),
                safeArea: false,
                menuOpen: open,
                rotateActionOnOpen: false,
              ),
              direction: dir,
              brightness: brightness,
            ),
          );
          await t.pumpAndSettle();
          final List<DabblerIcon> g = _actionGlyphs(t);
          expect(g, hasLength(1));
          expect(g.single.name, 'add');
        }
      });

      testWidgets('set: add closed, close-circle open, bold onBrand 26 - $tag', (
        WidgetTester t,
      ) async {
        final DabblerColors c = _colors(brightness);
        Future<void> pump(bool open) async {
          await t.pumpWidget(
            _host(
              DabblerNavigationBottomBar(
                safeArea: false,
                menuOpen: open,
                rotateActionOnOpen: false,
                actionOpenIcon: 'close-circle',
              ),
              direction: dir,
              brightness: brightness,
            ),
          );
          await t.pumpAndSettle();
        }

        await pump(false);
        expect(_actionGlyphs(t).single.name, 'add');

        await pump(true);
        final DabblerIcon open = _actionGlyphs(t).single;
        expect(open.name, 'close-circle');
        expect(open.weight, DabblerIconWeight.bold);
        expect(open.color, c.onBrand);
        expect(open.size, DabblerNavigationBottomBar.glyph26);
        // Held upright, as the design draws it.
        expect(
          t.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
          0,
        );
        // The glyph resolves to a real Iconsax glyph, never the placeholder.
        expect(
          DabblerIconRegistry.resolve(
            'close-circle',
            weight: DabblerIconWeight.bold,
          ).outcome,
          DabblerIconOutcome.resolved,
        );
        // The disc stays centred on the 56 action in both directions.
        final Rect action = t.getRect(find.byType(AnimatedRotation));
        final Rect glyph = t.getRect(
          find.descendant(
            of: find.byType(AnimatedRotation),
            matching: find.byType(DabblerIcon),
          ),
        );
        expect(glyph.center.dx, closeTo(action.center.dx, 0.01));
        expect(glyph.center.dy, closeTo(action.center.dy, 0.01));
        expect(t.takeException(), isNull);
      });

      test('the brand ✕ on the onBrand disc clears 3:1 - $tag', () {
        final DabblerColors c = _colors(brightness);
        final double r = _ratio(c.brandPrimary, c.onBrand);
        if (const String.fromEnvironment('PRINT_OPEN_GLYPH_CONTRAST') ==
            '1') {
          // ignore: avoid_print
          print('${brightness.name}: x on disc ${r.toStringAsFixed(2)}');
        }
        expect(r, greaterThanOrEqualTo(3));
      });
    }
  }

  testWidgets('the swap cross-fades on the slow motion step', (
    WidgetTester t,
  ) async {
    Future<void> pump(bool open) => t.pumpWidget(
      _host(
        DabblerNavigationBottomBar(
          safeArea: false,
          menuOpen: open,
          rotateActionOnOpen: false,
          actionOpenIcon: 'close-circle',
        ),
        direction: TextDirection.ltr,
        brightness: Brightness.light,
        disableAnimations: false,
      ),
    );
    await pump(false);
    await t.pumpAndSettle();
    await pump(true);
    await t.pump(DabblerMotion.slow ~/ 2);
    // Mid-way both glyphs are on screen, each partly faded.
    final List<String> mid = _actionGlyphs(t).map((g) => g.name).toList();
    expect(mid, containsAll(<String>['add', 'close-circle']));
    final Iterable<double> fades = t
        .widgetList<FadeTransition>(
          find.descendant(
            of: find.byType(AnimatedRotation),
            matching: find.byType(FadeTransition),
          ),
        )
        .map((f) => f.opacity.value);
    expect(fades.every((o) => o > 0 && o < 1), isTrue, reason: '$fades');
    await t.pump(DabblerMotion.slow);
    await t.pumpAndSettle();
    expect(_actionGlyphs(t).single.name, 'close-circle');

    // And back.
    await pump(false);
    await t.pump(DabblerMotion.slow ~/ 2);
    expect(
      _actionGlyphs(t).map((g) => g.name),
      containsAll(<String>['add', 'close-circle']),
    );
    await t.pumpAndSettle();
    expect(_actionGlyphs(t).single.name, 'add');
  });

  testWidgets('reduced motion swaps at once', (WidgetTester t) async {
    Future<void> pump(bool open) => t.pumpWidget(
      _host(
        DabblerNavigationBottomBar(
          safeArea: false,
          menuOpen: open,
          rotateActionOnOpen: false,
          actionOpenIcon: 'close-circle',
        ),
        direction: TextDirection.ltr,
        brightness: Brightness.light,
      ),
    );
    await pump(false);
    await t.pumpAndSettle();
    await pump(true);
    await t.pump();
    expect(_actionGlyphs(t).single.name, 'close-circle');
  });
}
