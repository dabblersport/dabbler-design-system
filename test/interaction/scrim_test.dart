import 'package:dabbler_design_system/src/tokens/dabbler_motion.dart';
import 'package:dabbler_design_system/src/interaction/scrim.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_palette.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'interaction_host.dart';

Color _washColour(WidgetTester tester) =>
    tester.widget<ColoredBox>(find.byType(ColoredBox)).color;

double _opacity(WidgetTester tester) =>
    tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity.value;

Widget _sized(Widget child) => SizedBox(width: 200, height: 200, child: child);

void main() {
  group('the wash is --color-scrim and nothing else', () {
    testWidgets('light is ink at 45% (tokens/colors.css:157)',
        (WidgetTester tester) async {
      await tester.pumpWidget(host(_sized(const DabblerScrim())));
      expect(_washColour(tester), DabblerPalette.ink.withValues(alpha: 0.45));
      expect(
        _washColour(tester),
        DabblerColors.resolve(
          theme: DabblerTheme.main,
          brightness: Brightness.light,
        ).scrim,
      );
    });

    testWidgets('dark is ink-950 at 65% (tokens/colors.css:203)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        host(_sized(const DabblerScrim()), brightness: Brightness.dark),
      );
      expect(_washColour(tester), DabblerPalette.ink950.withValues(alpha: 0.65));
    });

    testWidgets('every theme gets the same scrim — it is not brand-tinted',
        (WidgetTester tester) async {
      for (final DabblerTheme theme in DabblerTheme.values) {
        await tester.pumpWidget(host(_sized(const DabblerScrim()), theme: theme));
        expect(_washColour(tester), DabblerPalette.ink.withValues(alpha: 0.45));
      }
    });
  });

  group('fade', () {
    testWidgets('fades in over --motion-base', (WidgetTester tester) async {
      await tester.pumpWidget(host(_sized(const DabblerScrim(visible: false))));
      await tester.pumpWidget(host(_sized(const DabblerScrim())));
      await tester.pump(const Duration(milliseconds: 60));
      final double midway = _opacity(tester);
      expect(midway, greaterThan(0));
      expect(midway, lessThan(1));
      await tester.pump(DabblerMotion.base);
      expect(_opacity(tester), 1);
    });

    testWidgets('reduced motion appears at once', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(_sized(const DabblerScrim(visible: false)), disableAnimations: true),
      );
      await tester.pumpWidget(
        host(_sized(const DabblerScrim()), disableAnimations: true),
      );
      await tester.pump();
      expect(_opacity(tester), 1);
    });
  });

  group('dismissal', () {
    testWidgets('is inert and lets pointers through with no onDismiss',
        (WidgetTester tester) async {
      int beneath = 0;
      await tester.pumpWidget(
        host(_sized(
          Stack(
            children: <Widget>[
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => beneath++,
                ),
              ),
              const Positioned.fill(child: DabblerScrim()),
            ],
          ),
        )),
      );
      await tester.tapAt(const Offset(100, 100));
      await tester.pump();
      expect(beneath, 1);
    });

    testWidgets('a press on the scrim dismisses when onDismiss is set',
        (WidgetTester tester) async {
      int dismissed = 0;
      await tester.pumpWidget(
        host(_sized(DabblerScrim(onDismiss: () => dismissed++))),
      );
      await tester.tapAt(const Offset(100, 100));
      await tester.pump();
      expect(dismissed, 1);
    });

    testWidgets('a hidden scrim no longer absorbs pointers',
        (WidgetTester tester) async {
      int dismissed = 0;
      await tester.pumpWidget(
        host(_sized(
          DabblerScrim(visible: false, onDismiss: () => dismissed++),
        )),
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(100, 100));
      await tester.pump();
      expect(dismissed, 0);
    });
  });

  group('semantics', () {
    testWidgets('the bare wash announces nothing', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(host(_sized(const DabblerScrim())));
      expect(find.bySemanticsLabel('anything'), findsNothing);
      expect(
        tester.getSemantics(find.byType(DabblerScrim)).label,
        isEmpty,
      );
      handle.dispose();
    });

    testWidgets('the dismiss affordance carries the label it was given',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(_sized(DabblerScrim(
          dismissLabel: 'Close',
          onDismiss: () {},
        ))),
      );
      expect(find.bySemanticsLabel('Close'), findsOneWidget);
      handle.dispose();
    });
  });
}
