import 'package:dabbler_design_system/src/layout/divider.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const double hostWidth = 320;

DabblerColors _colors({
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) {
  return MaterialApp(
    theme: ThemeData(
      brightness: brightness,
      extensions: <ThemeExtension<dynamic>>[
        _colors(theme: theme, brightness: brightness),
      ],
    ),
    home: Directionality(
      textDirection: direction,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: hostWidth, child: child),
      ),
    ),
  );
}

/// The colour of the rule(s) a divider drew.
List<Color> _ruleColors(WidgetTester tester) => tester
    .widgetList<ColoredBox>(
      find.descendant(
        of: find.byType(DabblerDivider),
        matching: find.byType(ColoredBox),
      ),
    )
    .map((ColoredBox b) => b.color)
    .toList();

void main() {
  group('DabblerDivider weights map to the design source', () {
    testWidgets('default is the faint paper step (bgTertiary)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerDivider()));
      expect(_ruleColors(tester), <Color>[_colors().bgTertiary]);
    });

    testWidgets('strong is the card outline (borderDefault)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerDivider(strong: true)));
      expect(_ruleColors(tester), <Color>[_colors().borderDefault]);
    });

    testWidgets('both weights step with the theme, in dark too', (
      WidgetTester tester,
    ) async {
      for (final Brightness brightness in Brightness.values) {
        for (final DabblerTheme theme in DabblerTheme.values) {
          await tester.pumpWidget(
            _host(
              // A distinct key per pump: two `const DabblerDivider()`s are the
              // same canonicalised instance, and an identical widget short-
              // circuits the rebuild, so the previous theme's colour would
              // stick and the loop would prove nothing.
              DabblerDivider(key: ValueKey<String>('$theme-$brightness')),
              theme: theme,
              brightness: brightness,
            ),
          );
          // MaterialApp cross-fades a ThemeData change through AnimatedTheme,
          // so one frame still carries the previous theme's colour.
          await tester.pumpAndSettle();
          expect(
            _ruleColors(tester),
            <Color>[_colors(theme: theme, brightness: brightness).bgTertiary],
            reason: '$theme/$brightness',
          );
        }
      }
    });
  });

  group('DabblerDivider geometry uses DS-104 tokens', () {
    testWidgets('a horizontal rule is exactly borderDefault thick and fills '
        'the width', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerDivider()));
      final Rect rule = tester.getRect(
        find.descendant(
          of: find.byType(DabblerDivider),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(rule.height, DabblerSizing.borderDefault);
      expect(rule.height, 1);
      expect(rule.width, hostWidth);
    });

    testWidgets('a vertical rule is borderDefault wide with a space8 floor', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[DabblerDivider.vertical()],
          ),
        ),
      );
      final Rect rule = tester.getRect(
        find.descendant(
          of: find.byType(DabblerDivider),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(rule.width, DabblerSizing.borderDefault);
      // Divider.jsx:25 — `min-height: var(--space-8)`.
      expect(rule.height, DabblerSpacing.space8);
    });

    testWidgets('a vertical rule stretches past its floor when the parent '
        'gives it height', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            height: 90,
            child: Row(
              // `align-self: stretch` is the parent's to grant.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[DabblerDivider.vertical()],
            ),
          ),
        ),
      );
      expect(
        tester
            .getRect(
              find.descendant(
                of: find.byType(DabblerDivider),
                matching: find.byType(ColoredBox),
              ),
            )
            .height,
        90,
      );
    });

    testWidgets('the labelled variant gaps its rules with space4', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerDivider(label: 'or')));
      final Iterable<double> gaps = tester
          .widgetList<SizedBox>(
            find.descendant(
              of: find.byType(DabblerDivider),
              matching: find.byType(SizedBox),
            ),
          )
          .where((SizedBox b) => b.width != null && b.height == null)
          .map((SizedBox b) => b.width!);
      expect(gaps, <double>[DabblerSpacing.space4, DabblerSpacing.space4]);

      final Rect label = tester.getRect(find.text('or'));
      final Rect divider = tester.getRect(find.byType(DabblerDivider));
      // Symmetric: the two rules flex equally, so the label is centred.
      expect(
        label.center.dx,
        moreOrLessEquals(divider.center.dx, epsilon: 0.01),
      );
    });

    testWidgets('the label is caption1 at textSecondary (D-003(a))', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerDivider(label: 'or')));
      final TextStyle style = tester.widget<Text>(find.text('or')).style!;
      expect(style.fontSize, DabblerType.caption1.fontSize);
      // caption1 is 11px — body-sized, not large text — so D-003(a) puts it
      // on the ink-soft-backed secondary role, not on `--muted`.
      expect(style.color, _colors().textSecondary);
    });
  });

  group('DabblerDivider inset is directional', () {
    /// The inset applied on each side, as (leading, trailing).
    Future<(double, double)> insets(
      WidgetTester tester,
      TextDirection direction,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerDivider(inset: DabblerSpacing.cardPadding),
          direction: direction,
        ),
      );
      final Rect divider = tester.getRect(find.byType(DabblerDivider));
      final Rect rule = tester.getRect(
        find.descendant(
          of: find.byType(DabblerDivider),
          matching: find.byType(ColoredBox),
        ),
      );
      return direction == TextDirection.ltr
          ? (rule.left - divider.left, divider.right - rule.right)
          : (divider.right - rule.right, rule.left - divider.left);
    }

    testWidgets('a symmetric inset is equal on both sides in both directions', (
      WidgetTester tester,
    ) async {
      for (final TextDirection direction in TextDirection.values) {
        final (double leading, double trailing) =
            await insets(tester, direction);
        expect(leading, DabblerSpacing.cardPadding, reason: '$direction');
        expect(trailing, DabblerSpacing.cardPadding, reason: '$direction');
      }
    });

    testWidgets('inset 0 lets the rule run edge to edge', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerDivider()));
      expect(
        tester
            .getRect(
              find.descendant(
                of: find.byType(DabblerDivider),
                matching: find.byType(ColoredBox),
              ),
            )
            .width,
        hostWidth,
      );
    });

    testWidgets('a vertical inset applies on the block axis', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DabblerDivider.vertical(inset: DabblerSpacing.space1),
              ],
            ),
          ),
        ),
      );
      expect(
        tester
            .getRect(
              find.descendant(
                of: find.byType(DabblerDivider),
                matching: find.byType(ColoredBox),
              ),
            )
            .height,
        90 - 2 * DabblerSpacing.space1,
      );
    });
  });

  group('DabblerDivider semantics', () {
    testWidgets('a plain rule is decorative', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerDivider()));
      expect(
        find.descendant(
          of: find.byType(DabblerDivider),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a labelled rule keeps its label in the tree', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerDivider(label: 'or')));
      expect(
        find.descendant(
          of: find.byType(DabblerDivider),
          matching: find.byType(ExcludeSemantics),
        ),
        findsNothing,
      );
      expect(
        tester.getSemantics(find.text('or')).label,
        'or',
      );
    });
  });
}
