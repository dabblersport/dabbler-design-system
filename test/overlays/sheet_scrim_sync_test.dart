import 'package:dabbler_design_system/src/interaction/scrim.dart';
import 'package:dabbler_design_system/src/overlays/sheet.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// KAN-619: the dim must leave over the same time as the drawer.

// The route page is built once, so `open` flips through a notifier.
final ValueNotifier<bool> _open = ValueNotifier<bool>(true);

Widget _host({required bool open}) {
  _open.value = open;
  return MediaQuery(
    data: const MediaQueryData(size: Size(800, 600)),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Theme(
        data: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            DabblerColors.resolve(
              theme: DabblerTheme.main,
              brightness: Brightness.light,
            ),
          ],
        ),
        child: Navigator(
          onGenerateRoute: (RouteSettings settings) => PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (_, _, _) => ValueListenableBuilder<bool>(
              valueListenable: _open,
              builder: (_, bool value, _) => DabblerSheet(
                open: value,
                onClose: () {},
                child: const Text('body'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

AnimatedOpacity _scrimFade(WidgetTester tester) =>
    tester.widget<AnimatedOpacity>(
      find.descendant(
        of: find.byType(DabblerScrim),
        matching: find.byType(AnimatedOpacity),
      ),
    );

AnimatedSlide _panelSlide(WidgetTester tester) => tester.widget<AnimatedSlide>(
  find.descendant(
    of: find.byType(DabblerSheet),
    matching: find.byType(AnimatedSlide),
  ),
);

double _scrimOpacity(WidgetTester tester) => tester
    .widget<FadeTransition>(
      find
          .descendant(
            of: find.byType(DabblerScrim),
            matching: find.byType(FadeTransition),
          )
          .first,
    )
    .opacity
    .value;

/// The panel's slide, as a fraction of its own height (1 is fully off).
double _panelOffsetY(WidgetTester tester) => tester
    .widget<SlideTransition>(
      find
          .descendant(
            of: find.byType(DabblerSheet),
            matching: find.byType(SlideTransition),
          )
          .first,
    )
    .position
    .value
    .dy;

void main() {
  testWidgets('scrim and panel share duration and curve', (tester) async {
    await tester.pumpWidget(_host(open: true));
    await tester.pumpAndSettle();
    final AnimatedOpacity fade = _scrimFade(tester);
    final AnimatedSlide slide = _panelSlide(tester);
    expect(fade.duration, slide.duration);
    expect(fade.duration, DabblerMotion.slow);
    expect(fade.curve, slide.curve);
  });

  testWidgets('closing: scrim reaches 0 exactly when the panel finishes', (
    tester,
  ) async {
    await tester.pumpWidget(_host(open: true));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_host(open: false));
    await tester.pump();

    // Just before the slide ends the dim is still visible (the old scrim
    // was already gone 80 ms earlier).
    await tester.pump(DabblerMotion.slow - const Duration(milliseconds: 10));
    expect(_panelOffsetY(tester), lessThan(1));
    final double mid = _scrimOpacity(tester);
    expect(mid, greaterThan(0));

    // Both finish together.
    await tester.pump(const Duration(milliseconds: 10));
    final double end = _scrimOpacity(tester);
    expect(end, 0);
    expect(_panelOffsetY(tester), 1);
  });

  testWidgets('opening: scrim reaches 1 when the panel arrives', (
    tester,
  ) async {
    await tester.pumpWidget(_host(open: false));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_host(open: true));
    await tester.pump();
    await tester.pump(DabblerMotion.slow);
    final double r = _scrimOpacity(tester);
    expect(r, 1);
    expect(_panelOffsetY(tester), 0);
  });

  testWidgets('a bare DabblerScrim keeps DabblerMotion.base', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Theme(
            data: ThemeData(
              extensions: <ThemeExtension<dynamic>>[
                DabblerColors.resolve(
                  theme: DabblerTheme.main,
                  brightness: Brightness.light,
                ),
              ],
            ),
            child: const DabblerScrim(),
          ),
        ),
      ),
    );
    expect(_scrimFade(tester).duration, DabblerMotion.base);
  });
}
