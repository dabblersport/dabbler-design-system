import 'dart:io';

import 'package:dabbler_design_system/src/surfaces/surface.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hosts [child] under a [DabblerColors] resolved for [theme] at [brightness],
/// which is the only wiring a [DabblerSurface] needs.
Widget _host(
  Widget child, {
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
}) {
  final DabblerColors colors =
      DabblerColors.resolve(theme: theme, brightness: brightness);
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
    home: Directionality(
      textDirection: textDirection,
      child: Align(alignment: Alignment.topLeft, child: child),
    ),
  );
}

/// The decoration the surface paints. There is exactly one under a
/// [DabblerSurface] in these tests.
BoxDecoration _decoration(WidgetTester tester) {
  final Iterable<DecoratedBox> boxes = tester
      .widgetList<DecoratedBox>(find.descendant(
    of: find.byType(DabblerSurface),
    matching: find.byType(DecoratedBox),
  ));
  expect(boxes, hasLength(1), reason: 'a surface paints one decoration');
  return boxes.single.decoration as BoxDecoration;
}

DabblerColors _colors(
  DabblerTheme theme,
  Brightness brightness,
) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

void main() {
  group('AC1 — flat opaque fill, 1px hairline, nothing else', () {
    testWidgets('card paints an opaque fill and a 1px hairline',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSurface(child: Text('x'))));
      final BoxDecoration d = _decoration(tester);
      final DabblerColors c = _colors(DabblerTheme.main, Brightness.light);

      expect(d.color, c.surfaceCard);
      expect(d.color!.a, 1.0, reason: 'the fill is opaque, never translucent');
      expect(d.border, Border.all(color: c.borderDefault, width: 1));
      expect(DabblerSizing.borderDefault, 1);
    });

    testWidgets('no shadow, no gradient, no blur on any variant',
        (WidgetTester tester) async {
      for (final DabblerSurfaceVariant variant in DabblerSurfaceVariant.values) {
        for (final Brightness brightness in Brightness.values) {
          await tester.pumpWidget(_host(
            DabblerSurface(variant: variant, child: const Text('x')),
            brightness: brightness,
          ));
          await tester.pumpAndSettle();
          final BoxDecoration d = _decoration(tester);
          expect(d.boxShadow, anyOf(isNull, isEmpty),
              reason: '$variant/$brightness must cast no shadow');
          expect(d.gradient, isNull, reason: '$variant/$brightness: no sheen');
          expect(d.backgroundBlendMode, isNull);
          expect(d.image, isNull);
          expect(d.color!.a, 1.0,
              reason: '$variant/$brightness: opaque fill only');
        }
      }
      // A backdrop blur would arrive as a BackdropFilter in the tree.
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.byType(ImageFiltered), findsNothing);
    });

    testWidgets('the fill steps are the four the specimen renders, plus grey',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const SizedBox.shrink()));
      final DabblerColors c = _colors(DabblerTheme.main, Brightness.light);

      expect(DabblerSurface.fillOf(c, DabblerSurfaceVariant.card),
          c.surfaceCard); // --surface-flat
      expect(DabblerSurface.fillOf(c, DabblerSurfaceVariant.sunken),
          c.bgPrimary); // --surface-flat-sunken
      expect(DabblerSurface.fillOf(c, DabblerSurfaceVariant.grey),
          c.surfaceGrey);
      expect(DabblerSurface.fillOf(c, DabblerSurfaceVariant.selected),
          c.brandPrimary); // --glass-selected-fill, post-FLAT

      // Only the hairline-bearing steps carry a border.
      expect(DabblerSurface.borderOf(c, DabblerSurfaceVariant.card),
          c.borderDefault);
      expect(DabblerSurface.borderOf(c, DabblerSurfaceVariant.brandTint),
          c.borderDefault);
      for (final DabblerSurfaceVariant v in <DabblerSurfaceVariant>[
        DabblerSurfaceVariant.sunken,
        DabblerSurfaceVariant.grey,
        DabblerSurfaceVariant.selected,
      ]) {
        expect(DabblerSurface.borderOf(c, v), isNull, reason: '$v is a step');
      }
    });

    testWidgets('the brand tint is the source color-mix, opaque, per brightness',
        (WidgetTester tester) async {
      for (final DabblerTheme theme in DabblerTheme.values) {
        final DabblerColors light = _colors(theme, Brightness.light);
        final DabblerColors dark = _colors(theme, Brightness.dark);
        // color-mix(in srgb, brand 8%, white) / (… 22%, black).
        expect(DabblerSurface.brandTintFill(light),
            Color.lerp(Colors.white, light.brandPrimary, 0.08));
        expect(DabblerSurface.brandTintFill(dark),
            Color.lerp(Colors.black, dark.brandPrimary, 0.22));
        expect(DabblerSurface.brandTintFill(light).a, 1.0);
        expect(DabblerSurface.brandTintFill(dark).a, 1.0);
      }
    });

    testWidgets('the default radius is --radius-xl (18)',
        (WidgetTester tester) async {
      expect(DabblerSurface.defaultRadius, DabblerRadius.xl);
      expect(DabblerRadius.xl, 18);
      await tester.pumpWidget(_host(const DabblerSurface(child: Text('x'))));
      expect(_decoration(tester).borderRadius, DabblerRadius.xlAll);
    });

    testWidgets('each variant resolves per theme and per brightness',
        (WidgetTester tester) async {
      for (final DabblerTheme theme in DabblerTheme.values) {
        for (final Brightness brightness in Brightness.values) {
          await tester.pumpWidget(_host(
            const DabblerSurface.selected(child: Text('x')),
            theme: theme,
            brightness: brightness,
          ));
          // MaterialApp animates a ThemeData change, and DabblerColors.lerp
          // snaps at t == 0.5 — settle so the assertion reads the destination
          // theme rather than the outgoing one.
          await tester.pumpAndSettle();
          expect(
              _decoration(tester).color, _colors(theme, brightness).brandPrimary);
        }
      }
    });
  });

  group('overrides and layout', () {
    testWidgets('fill, borderColor and borderWidth override the variant',
        (WidgetTester tester) async {
      final DabblerColors c = _colors(DabblerTheme.main, Brightness.light);
      await tester.pumpWidget(_host(DabblerSurface.sunken(
        fill: c.surfaceCard,
        borderColor: c.borderStrong,
        borderWidth: DabblerSizing.borderDefault,
        child: const Text('x'),
      )));
      final BoxDecoration d = _decoration(tester);
      expect(d.color, c.surfaceCard);
      expect(d.border, Border.all(color: c.borderStrong, width: 1));
    });

    testWidgets('borderWidth 0 drops the hairline',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          _host(const DabblerSurface(borderWidth: 0, child: Text('x'))));
      expect(_decoration(tester).border, isNull);
    });

    testWidgets('padding, size and centring are applied',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSurface(
        width: 200,
        height: 120,
        center: true,
        padding: EdgeInsetsDirectional.all(DabblerSpacing.cardPadding),
        child: SizedBox(width: 20, height: 20),
      )));
      expect(tester.getSize(find.byType(DabblerSurface)), const Size(200, 120));
      expect(find.byType(Center), findsOneWidget);
      final Padding p = tester.widget<Padding>(find.descendant(
        of: find.byType(DabblerSurface),
        matching: find.byType(Padding),
      ));
      expect(p.padding,
          const EdgeInsetsDirectional.all(DabblerSpacing.cardPadding));
    });

    testWidgets('directional padding flips under RTL',
        (WidgetTester tester) async {
      const EdgeInsetsGeometry pad =
          EdgeInsetsDirectional.only(start: DabblerSpacing.space8);
      expect(pad.resolve(TextDirection.ltr),
          const EdgeInsets.only(left: DabblerSpacing.space8));
      expect(pad.resolve(TextDirection.rtl),
          const EdgeInsets.only(right: DabblerSpacing.space8));

      await tester.pumpWidget(_host(
        const DabblerSurface(padding: pad, child: Text('x')),
        textDirection: TextDirection.rtl,
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a childless surface still paints its step',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          _host(const DabblerSurface.grey(width: 60, height: 60)));
      expect(_decoration(tester).color,
          _colors(DabblerTheme.main, Brightness.light).surfaceGrey);
    });

    testWidgets('content is clipped to the radius by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerSurface(child: Text('x'))));
      final ClipRRect clip = tester.widget<ClipRRect>(find.descendant(
        of: find.byType(DabblerSurface),
        matching: find.byType(ClipRRect),
      ));
      expect(clip.clipBehavior, Clip.antiAlias);
      expect(clip.borderRadius, DabblerRadius.xlAll);
    });
  });

  group('AC2 — the retired layer is not ported', () {
    test('surface.dart declares no symbol carrying the retired name', () {
      final String body = File('lib/src/surfaces/surface.dart')
          .readAsLinesSync()
          .where((String l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      expect(RegExp('glass', caseSensitive: false).hasMatch(body), isFalse,
          reason: 'tokens/glass.css is deliberately not ported');
    });

    test('no public symbol of this file is blur-, sheen- or shadow-shaped', () {
      final String body = File('lib/src/surfaces/surface.dart')
          .readAsLinesSync()
          .where((String l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      for (final String banned in <String>[
        'BackdropFilter',
        'ImageFilter',
        'BoxShadow',
        'boxShadow:',
        'LinearGradient',
        'gradient:',
        'blur',
      ]) {
        expect(body.contains(banned), isFalse,
            reason: 'a flat surface cannot mention $banned');
      }
    });
  });
}
