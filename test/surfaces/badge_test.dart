import 'package:dabbler_design_system/src/surfaces/badge.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The resolved tokens the badge is checked against, for [theme] at
/// [brightness].
DabblerColors _colors({
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

/// Wraps a badge in the minimum it needs: a [ThemeData] carrying the
/// [DabblerColors] extension, and a direction.
Widget _host(
  Widget child, {
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
  TextDirection direction = TextDirection.ltr,
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
      child: Align(alignment: Alignment.topCenter, child: child),
    ),
  );
}

BoxDecoration _decorationOf(WidgetTester tester) =>
    tester.widget<DecoratedBox>(find.byType(DecoratedBox).first).decoration
        as BoxDecoration;

TextStyle _labelStyleOf(WidgetTester tester) =>
    tester.widget<Text>(find.text('label')).style!;

void main() {
  group('AC1 — tone is decorative, status is semantic, status wins', () {
    testWidgets('status wins when tone and status are both set',
        (WidgetTester tester) async {
      final DabblerColors colors = _colors();
      await tester.pumpWidget(_host(
        DabblerBadge(
          label: 'label',
          // A decorative tone that would paint brand purple on card ink…
          tone: DabblerBadgeTone.error,
          // …and a semantic status that must override it completely.
          status: colors.success,
        ),
      ));

      final BoxDecoration decoration = _decorationOf(tester);
      expect(decoration.color, colors.success.surface,
          reason: 'the fill must come from the status, not the tone');
      expect(decoration.color, isNot(colors.brandPrimary),
          reason: 'the decorative tone must not survive a set status');
      expect(_labelStyleOf(tester).color, colors.success.strong);
      // Decorative tones carry no border; a semantic badge always does.
      expect(decoration.border, isNotNull);
    });

    testWidgets('every one of the eight tones paints its source pair',
        (WidgetTester tester) async {
      final DabblerColors colors = _colors();
      expect(DabblerBadgeTone.values, hasLength(8));

      for (final DabblerBadgeTone tone in DabblerBadgeTone.values) {
        await tester.pumpWidget(
          _host(DabblerBadge(label: 'label', tone: tone)),
        );
        expect(_decorationOf(tester).color,
            DabblerBadge.backgroundOf(tone, colors),
            reason: '$tone fill');
        expect(_labelStyleOf(tester).color,
            DabblerBadge.foregroundOf(tone, colors),
            reason: '$tone ink');
        expect(_decorationOf(tester).border, isNull,
            reason: '$tone is decorative and draws no hairline');
      }
    });

    test('the decorative names are the Figma kit\'s, not semantic ones', () {
      final DabblerColors colors = _colors();
      // `error` is PURPLE — the brand primary, shared with `default`.
      expect(DabblerBadge.backgroundOf(DabblerBadgeTone.error, colors),
          colors.brandPrimary);
      expect(DabblerBadge.backgroundOf(DabblerBadgeTone.error, colors),
          DabblerBadge.backgroundOf(DabblerBadgeTone.defaultTone, colors));
      expect(DabblerBadge.backgroundOf(DabblerBadgeTone.error, colors),
          isNot(colors.error.base));
      // `success` is BLACK — the ink ramp, not the success ramp.
      expect(DabblerBadge.backgroundOf(DabblerBadgeTone.success, colors),
          colors.textPrimary);
      expect(DabblerBadge.backgroundOf(DabblerBadgeTone.success, colors),
          isNot(colors.success.base));
      // `warning` is a NEUTRAL TINT — faint fill, muted ink.
      expect(DabblerBadge.backgroundOf(DabblerBadgeTone.warning, colors),
          colors.bgTertiary);
      expect(DabblerBadge.foregroundOf(DabblerBadgeTone.warning, colors),
          colors.textSecondary);
      expect(DabblerBadge.backgroundOf(DabblerBadgeTone.warning, colors),
          isNot(colors.warning.base));
      // `pill` duplicates `primary`, `withIcon` duplicates `warning`.
      expect(DabblerBadge.backgroundOf(DabblerBadgeTone.pill, colors),
          DabblerBadge.backgroundOf(DabblerBadgeTone.primary, colors));
      expect(DabblerBadge.backgroundOf(DabblerBadgeTone.withIcon, colors),
          DabblerBadge.backgroundOf(DabblerBadgeTone.warning, colors));
    });

    testWidgets('all five status values paint surface + strong + hairline',
        (WidgetTester tester) async {
      final DabblerColors colors = _colors();
      final List<DabblerStatusColor> five = <DabblerStatusColor>[
        DabblerBadge.neutralStatusOf(colors),
        for (final DabblerStatusTone tone in DabblerStatusTone.values)
          colors.status(tone),
      ];
      expect(five, hasLength(5));

      for (final DabblerStatusColor status in five) {
        await tester.pumpWidget(
          _host(DabblerBadge(label: 'label', status: status)),
        );
        final BoxDecoration decoration = _decorationOf(tester);
        expect(decoration.color, status.surface);
        expect(_labelStyleOf(tester).color, status.strong);
        expect((decoration.border! as Border).top.color,
            DabblerBadge.hairlineFor(status, colors));
        expect((decoration.border! as Border).top.width,
            DabblerSizing.borderDefault);
      }
    });

    test('the hairline is strong at 20%, and outline-card for neutral', () {
      final DabblerColors colors = _colors();
      expect(DabblerBadge.hairlineOpacity, 0.20);
      expect(
        DabblerBadge.hairlineFor(colors.error, colors),
        colors.error.strong.withValues(alpha: 0.20),
      );
      // `overlay.jsx:171` returns the bare `--outline-card` for neutral.
      expect(
        DabblerBadge.hairlineFor(DabblerBadge.neutralStatusOf(colors), colors),
        colors.borderDefault,
      );
    });

    test('neutral is built from the paper ramp, per overlay.jsx:161', () {
      final DabblerColors colors = _colors();
      final DabblerStatusColor neutral = DabblerBadge.neutralStatusOf(colors);
      expect(neutral.surface, colors.surfaceCard);
      expect(neutral.strong, colors.textPrimary);
      expect(neutral.base, colors.borderDefault);
      // It is not one of the four --color-status-* tones.
      for (final DabblerStatusTone tone in DabblerStatusTone.values) {
        expect(neutral, isNot(colors.status(tone)));
      }
    });
  });

  group('AC2 — status is a DabblerStatusColor, not a Color', () {
    test('the declared type is DabblerStatusColor', () {
      final DabblerColors colors = _colors();
      const DabblerBadge decorative = DabblerBadge(label: 'label');
      expect(decorative.status, isNull);

      final DabblerBadge semantic =
          DabblerBadge(label: 'label', status: colors.info);
      expect(semantic.status, isA<DabblerStatusColor>());
      // A Color cannot stand in for one: the runtime check mirrors the
      // compile-time guarantee, since `status: colors.info.base` — a Color —
      // does not compile.
      expect(semantic.status, isNot(isA<Color>()));
      expect(semantic.status, isNot(colors.info.base));
    });

    test('a DabblerStatusColor is never equal to any of its own roles', () {
      final DabblerColors colors = _colors();
      final DabblerStatusColor status = colors.warning;
      for (final Color role in <Color>[
        status.base,
        status.surface,
        status.strong,
        status.solid,
      ]) {
        expect(status, isNot(role));
      }
    });
  });

  group('geometry, type and flatness', () {
    testWidgets('pill radius, 4/10 padding, no shadow and no gradient',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerBadge(label: 'label')));
      final BoxDecoration decoration = _decorationOf(tester);
      expect(decoration.borderRadius, DabblerRadius.pillAll);
      expect(decoration.boxShadow, isNull);
      expect(decoration.gradient, isNull);

      final Padding padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(DecoratedBox).first,
          matching: find.byType(Padding),
        ).first,
      );
      expect(
        padding.padding,
        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      );
      expect(DabblerBadge.verticalPadding, 4);
      expect(DabblerBadge.horizontalPadding, 10);
    });

    testWidgets('label is 11px bold at 1.5 leading',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerBadge(label: 'label')));
      final TextStyle style = _labelStyleOf(tester);
      expect(style.fontSize, 11);
      expect(style.fontSize, DabblerType.caption2.fontSize);
      expect(style.fontWeight, DabblerType.bold);
      expect(style.height, 1.5);
    });

    testWidgets('the icon gap is 4 and appears only with an icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerBadge(label: 'label')));
      expect(find.byType(SizedBox), findsNothing);

      await tester.pumpWidget(_host(
        const DabblerBadge(
          label: 'label',
          icon: SizedBox.square(dimension: 12, key: ValueKey<String>('glyph')),
        ),
      ));
      final SizedBox gap = tester.widget<SizedBox>(
        find.byWidgetPredicate(
          (Widget w) => w is SizedBox && w.width == DabblerBadge.iconGap,
        ),
      );
      expect(gap.width, 4);
    });

    testWidgets('the glyph leads in LTR and trails in RTL',
        (WidgetTester tester) async {
      const Widget glyph =
          SizedBox.square(dimension: 12, key: ValueKey<String>('glyph'));

      await tester.pumpWidget(
        _host(const DabblerBadge(label: 'label', icon: glyph)),
      );
      expect(
        tester.getCenter(find.byKey(const ValueKey<String>('glyph'))).dx,
        lessThan(tester.getCenter(find.text('label')).dx),
      );

      await tester.pumpWidget(_host(
        const DabblerBadge(label: 'label', icon: glyph),
        direction: TextDirection.rtl,
      ));
      expect(
        tester.getCenter(find.byKey(const ValueKey<String>('glyph'))).dx,
        greaterThan(tester.getCenter(find.text('label')).dx),
      );
    });

    testWidgets('resolves against the enclosing theme and brightness',
        (WidgetTester tester) async {
      for (final DabblerTheme theme in DabblerTheme.values) {
        for (final Brightness brightness in Brightness.values) {
          final DabblerColors colors =
              _colors(theme: theme, brightness: brightness);
          await tester.pumpWidget(_host(
            DabblerBadge(label: 'label', status: colors.info),
            theme: theme,
            brightness: brightness,
          ));
          expect(_decorationOf(tester).color, colors.info.surface,
              reason: '$theme/$brightness');
        }
      }
    });
  });
}
