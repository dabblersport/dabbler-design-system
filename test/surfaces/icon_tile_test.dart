import 'dart:io';

import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/interaction/press_scale.dart';
import 'package:dabbler_design_system/src/surfaces/icon_tile.dart';
import 'package:dabbler_design_system/src/surfaces/surface.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hosts [child] under a [DabblerColors] resolved for [theme] at [brightness].
Widget _host(
  Widget child, {
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
}) {
  final DabblerColors colors = DabblerColors.resolve(
    theme: theme,
    brightness: brightness,
  );
  return MediaQuery(
    data: const MediaQueryData(),
    child: Directionality(
      textDirection: textDirection,
      child: Theme(
        data: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
        child: Shortcuts(
          shortcuts: WidgetsApp.defaultShortcuts,
          child: DefaultTextEditingShortcuts(
            child: Align(alignment: Alignment.topLeft, child: child),
          ),
        ),
      ),
    ),
  );
}

/// The one [DabblerSurface] the tile paints.
DabblerSurface _box(WidgetTester tester) => tester.widget<DabblerSurface>(
  find.descendant(
    of: find.byType(DabblerIconTile),
    matching: find.byType(DabblerSurface),
  ),
);

/// The source of the component under test, with comment lines removed: the file
/// is allowed to *explain* what it composes, only not to reimplement it.
String _code() => File('lib/src/surfaces/icon_tile.dart')
    .readAsStringSync()
    .split('\n')
    .where((String l) => !l.trimLeft().startsWith('///'))
    .where((String l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  group('AC1 — IconTile composes DS-300\'s Icon inside DS-500\'s Surface', () {
    testWidgets('the box is a DabblerSurface and there is exactly one', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerIconTile.named('game')));
      expect(
        find.descendant(
          of: find.byType(DabblerIconTile),
          matching: find.byType(DabblerSurface),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the glyph is a DabblerIcon', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerIconTile.named('location')));
      final DabblerIcon icon = tester.widget<DabblerIcon>(
        find.descendant(
          of: find.byType(DabblerIconTile),
          matching: find.byType(DabblerIcon),
        ),
      );
      expect(icon.name, 'location');
      expect(icon.weight, DabblerIconWeight.linear);
    });

    testWidgets('the default constructor hosts an arbitrary glyph widget', (
      WidgetTester tester,
    ) async {
      // The specimen fills the slot with a SportIcon as well as an Icon
      // (`components/surfaces/surfaces.card.html:29` (unverified: file not mirrored)), so the slot must take
      // any widget, not only a name.
      const Widget slot = SizedBox.shrink(key: ValueKey<String>('slot'));
      await tester.pumpWidget(_host(const DabblerIconTile(slot)));
      expect(find.byKey(const ValueKey<String>('slot')), findsOneWidget);
      expect(find.byType(DabblerIcon), findsNothing);
    });

    test('icon_tile.dart restates neither component\'s geometry or paint', () {
      final String code = _code();
      for (final String forbidden in <String>[
        // DS-500's job: the flat box, its fill, its hairline, its radius.
        'BoxDecoration',
        'Border.all',
        'Radius.circular',
        'BorderRadius.all',
        'DecoratedBox',
        'Color.lerp',
        'color-mix',
        'withValues',
        'withOpacity',
        // DS-300's job: the Iconsax lookup and the placeholder.
        'IconData',
        'Iconsax',
        'iconsax',
        'CustomPaint',
        // DS-200's job: press and focus geometry.
        'AnimatedScale',
        'Transform.scale',
        'Curves.',
        'Cubic(',
        'Duration(',
        'milliseconds',
        'ringWidth',
        'ringOffset',
        'strokeWidth',
      ]) {
        expect(
          code.contains(forbidden),
          isFalse,
          reason: '$forbidden is not IconTile\'s to state',
        );
      }
    });

    test('every geometry value in icon_tile.dart is a token', () {
      final String code = _code();
      // The three numbers the tile states are 45, 12 and 24, and each must
      // appear as its token, never as a literal. `0` is allowed: it is the
      // "no hairline" borderWidth, a flag rather than a measurement.
      expect(code.contains('DabblerSizing.touchTargetMin'), isTrue);
      expect(code.contains('DabblerRadius.lg'), isTrue);
      expect(code.contains('DabblerSizing.iconMd'), isTrue);
      final RegExp literal = RegExp(
        r'(?<![\w.])(?:45|12|24|10|28|18)(?![\w.])',
      );
      final Iterable<String> hits = literal
          .allMatches(code)
          .map((RegExpMatch m) => m.group(0)!);
      expect(
        hits,
        isEmpty,
        reason: 'raw geometry literals in icon_tile.dart: $hits',
      );
    });
  });

  group('tinted — the source\'s free `color` prop (IconTile.d.ts)', () {
    testWidgets('fill is the colour at 10% and stroke at 28% over the card', (
      WidgetTester tester,
    ) async {
      final DabblerColors colors = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      final Color tint = colors.success.base;
      await tester.pumpWidget(
        _host(DabblerIconTile.tinted(const SizedBox(), color: tint)),
      );
      final DabblerSurface box = _box(tester);
      expect(box.fill, Color.alphaBlend(tint.withValues(alpha: 0.10), colors.surfaceCard));
      expect(box.borderColor,
          Color.alphaBlend(tint.withValues(alpha: 0.28), colors.surfaceCard));
      expect(DabblerSurface.tintFillAlpha, 0.10);
      expect(DabblerSurface.tintBorderAlpha, 0.28);
      expect(box.borderWidth, isNull, reason: 'the variant\'s 1px hairline stays');
      expect(box.radius, DabblerRadius.lg);
    });

    testWidgets('the glyph takes the tint', (WidgetTester tester) async {
      final DabblerColors colors = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      final Color tint = colors.info.base;
      await tester.pumpWidget(
        _host(DabblerIconTile.tinted(const Icon(Icons.add), color: tint)),
      );
      expect(
        IconTheme.of(tester.element(find.byIcon(Icons.add))).color,
        tint,
      );
    });

    testWidgets('enum tones are unchanged by the new constructor', (
      WidgetTester tester,
    ) async {
      final DabblerColors colors = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      await tester.pumpWidget(
        _host(const DabblerIconTile.named('game', tone: DabblerIconTileTone.amber)),
      );
      final DabblerSurface box = _box(tester);
      expect(box.fill, DabblerIconTile.fillFor(colors, DabblerIconTileTone.amber));
      expect(box.borderWidth, 0);
      expect(box.borderColor, isNull);
    });
  });

  group('retained brand tone pin (ruling cdispatch-5e71152a item 3)', () {
    // Live `components/surfaces/IconTile.jsx`: fill color-mix(<color> 10%,
    // white), border color-mix(<color> 28%, white), color default
    // --color-brand-primary.
    for (final DabblerTheme theme in <DabblerTheme>[
      DabblerTheme.main,
      DabblerTheme.sport,
    ]) {
      testWidgets('default fill 10% / stroke 28% of brand under $theme', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(const DabblerIconTile.named('game'), theme: theme),
        );
        final DabblerColors colors = DabblerColors.resolve(
          theme: theme,
          brightness: Brightness.light,
        );
        final DabblerSurface box = _box(tester);
        expect(
          box.fill,
          Color.alphaBlend(
            colors.brandPrimary.withValues(alpha: 0.10),
            colors.surfaceCard,
          ),
        );
        expect(
          box.borderColor,
          Color.alphaBlend(
            colors.brandPrimary.withValues(alpha: 0.28),
            colors.surfaceCard,
          ),
        );
      });
    }

    testWidgets('the two categories really differ (not a constant)', (
      WidgetTester tester,
    ) async {
      final List<Color?> fills = <Color?>[];
      for (final DabblerTheme theme in <DabblerTheme>[
        DabblerTheme.main,
        DabblerTheme.sport,
      ]) {
        await tester.pumpWidget(
          _host(const DabblerIconTile.named('game'), theme: theme),
        );
        fills.add(_box(tester).fill);
      }
      expect(fills[0], isNot(fills[1]));
    });

    testWidgets('an explicit tint wins over the default brand tone', (
      WidgetTester tester,
    ) async {
      final DabblerColors colors = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      final Color tint = colors.success.base;
      await tester.pumpWidget(
        _host(DabblerIconTile.tinted(const Icon(Icons.add), color: tint)),
      );
      final DabblerSurface box = _box(tester);
      expect(box.fill, DabblerSurface.tintedFillOf(colors, tint));
      expect(box.fill, isNot(DabblerSurface.tintedFillOf(colors, colors.brandPrimary)));
      expect(box.borderColor, DabblerSurface.tintedBorderOf(colors, tint));
      expect(IconTheme.of(tester.element(find.byIcon(Icons.add))).color, tint);
      // `.tinted` fixes `tone` to brand; the colour is what is painted.
      expect(
        tester.widget<DabblerIconTile>(find.byType(DabblerIconTile)).tone,
        DabblerIconTileTone.brand,
      );
    });
  });

  group('AC1 — the source\'s values', () {
    testWidgets('the tile is 45x45 — measurements.html:113', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerIconTile.named('game')));
      expect(
        tester.getSize(find.byType(DabblerIconTile)),
        const Size(DabblerSizing.touchTargetMin, DabblerSizing.touchTargetMin),
      );
      expect(DabblerSizing.touchTargetMin, 45);
    });

    testWidgets('size overrides the square side', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerIconTile.named(
            'game',
            size: DabblerSizing.touchTargetMin * 2,
          ),
        ),
      );
      expect(_box(tester).width, DabblerSizing.touchTargetMin * 2);
      expect(_box(tester).height, DabblerSizing.touchTargetMin * 2);
    });

    testWidgets('the radius is --radius-lg (12), not Surface\'s own xl (18)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerIconTile.named('game')));
      expect(_box(tester).radius, DabblerRadius.lg);
      expect(DabblerRadius.lg, 12);
      // The token's gloss in `guidelines/measurements.html:73` — "cards, icon
      // tiles" — and `IconTile.jsx`'s own `radius="var(--radius-lg)"` agree.
      expect(_box(tester).radius, isNot(DabblerSurface.defaultRadius));
    });

    testWidgets('the glyph box is 24, the native Iconsax grid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerIconTile.named('game')));
      expect(
        tester.getSize(find.byType(DabblerIcon)),
        const Size(DabblerSizing.iconMd, DabblerSizing.iconMd),
      );
      expect(DabblerSizing.iconMd, 24);
    });
  });

  group('AC1 — the tint comes from the token layer', () {
    testWidgets('the brand tone is color-mix(brand 10% / 28%, white) as live', (
      WidgetTester tester,
    ) async {
      // Live `components/surfaces/IconTile.jsx`: fill `color-mix(in srgb,
      // <color> 10%, white)`, border `color-mix(in srgb, <color> 28%, white)`,
      // radius `--radius-lg`, size 45, `color` default `--color-brand-primary`.
      await tester.pumpWidget(_host(const DabblerIconTile.named('game')));
      final DabblerSurface box = _box(tester);
      final DabblerColors colors = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      Color mix(double a) => Color.alphaBlend(
        colors.brandPrimary.withValues(alpha: a),
        const Color(0xFFFFFFFF),
      );
      expect(box.fill, mix(0.10));
      expect(box.borderColor, mix(0.28));
      expect(box.radius, DabblerRadius.lg);
      expect(tester.getSize(find.byType(DabblerSurface)), const Size(45, 45));
    });

    testWidgets('the brand glyph is painted in the brand, per tone', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerIconTile.named('game')));
      final DabblerColors colors = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      final IconThemeData theme = IconTheme.of(
        tester.element(find.byType(DabblerIcon)),
      );
      expect(theme.color, colors.brandPrimary);
      expect(theme.size, DabblerSizing.iconMd);
      expect(
        DabblerIconTile.inkFor(colors, DabblerIconTileTone.brand),
        colors.brandPrimary,
      );
    });

    testWidgets('the brand tint follows the theme', (
      WidgetTester tester,
    ) async {
      for (final DabblerTheme theme in DabblerTheme.values) {
        await tester.pumpWidget(
          _host(const DabblerIconTile.named('game'), theme: theme),
        );
        final DabblerColors colors = DabblerColors.resolve(
          theme: theme,
          brightness: Brightness.light,
        );
        expect(
          IconTheme.of(tester.element(find.byType(DabblerIcon))).color,
          colors.brandPrimary,
          reason: 'theme $theme',
        );
      }
    });

    testWidgets('each decorative tone paints its DS-102 role, flat', (
      WidgetTester tester,
    ) async {
      final Map<DabblerIconTileTone, DabblerToneColor> roles =
          <DabblerIconTileTone, DabblerToneColor>{
            DabblerIconTileTone.amber: DabblerColors.tileAmber,
            DabblerIconTileTone.info: DabblerColors.tileInfo,
            DabblerIconTileTone.accent: DabblerColors.tileAccent,
          };
      final DabblerColors colors = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      for (final MapEntry<DabblerIconTileTone, DabblerToneColor> entry
          in roles.entries) {
        await tester.pumpWidget(
          _host(DabblerIconTile.named('game', tone: entry.key)),
        );
        final DabblerSurface box = _box(tester);
        expect(box.fill, entry.value.surface, reason: '${entry.key} fill');
        // Decorative fills carry no stroke: the source declares none.
        expect(box.borderWidth, 0, reason: '${entry.key} hairline');
        expect(
          IconTheme.of(tester.element(find.byType(DabblerIcon))).color,
          entry.value.ink,
          reason: '${entry.key} ink',
        );
        expect(DabblerIconTile.fillFor(colors, entry.key), entry.value.surface);
        expect(DabblerIconTile.inkFor(colors, entry.key), entry.value.ink);
      }
    });

    test('the tone list matches the source\'s tile roles exactly', () {
      // `tokens/colors.css:89-91` declares three decorative tile roles — amber,
      // info, accent — and DS-102 ports all three. The enum is those three plus
      // the source's own brand default; a tone the source paints and the token
      // layer lacks would show up here as a gap to report, not a colour to
      // invent.
      expect(DabblerIconTileTone.values, <DabblerIconTileTone>[
        DabblerIconTileTone.brand,
        DabblerIconTileTone.amber,
        DabblerIconTileTone.info,
        DabblerIconTileTone.accent,
      ]);
    });
  });

  group('AC1 — decorative by default, a button only when asked', () {
    testWidgets('a plain tile has no gesture, focus or press', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerIconTile.named('game')));
      expect(find.byType(FocusableActionDetector), findsNothing);
      expect(find.byType(DabblerPressScale), findsNothing);
      expect(find.byType(DabblerFocusRing), findsNothing);
    });

    testWidgets('a plain tile is invisible to assistive technology', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const DabblerIconTile.named('game')));
      expect(find.bySemanticsLabel('game'), findsNothing);
      handle.dispose();
    });

    testWidgets('semanticLabel names an otherwise decorative tile', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(const DabblerIconTile.named('game', semanticLabel: 'Padel')),
      );
      expect(find.bySemanticsLabel('Padel'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('onTap makes it a button that fires once', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(DabblerIconTile.named('game', onTap: () => taps++)),
      );
      await tester.tap(find.byType(DabblerIconTile));
      await tester.pump();
      expect(taps, 1);
      expect(find.byType(DabblerPressScale), findsOneWidget);
      expect(find.byType(DabblerFocusRing), findsOneWidget);
    });

    testWidgets('the focus ring follows the tile\'s own radius', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(DabblerIconTile.named('game', onTap: () {})),
      );
      expect(
        tester
            .widget<DabblerFocusRing>(find.byType(DabblerFocusRing))
            .borderRadius,
        DabblerRadius.lgAll,
      );
    });

    testWidgets('Enter activates a focused tile', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(DabblerIconTile.named('game', onTap: () => taps++)),
      );
      await tester.tap(find.byType(DabblerIconTile));
      await tester.pump();
      taps = 0;
      Focus.of(tester.element(find.byType(GestureDetector))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('a tappable tile clears the 45px touch target', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(DabblerIconTile.named('game', onTap: () {})),
      );
      final Size size = tester.getSize(find.byType(DabblerIconTile));
      expect(size.width, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
      expect(size.height, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
    });

    testWidgets('a tappable tile announces itself as a button', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          DabblerIconTile.named(
            'game',
            semanticLabel: 'Notifications',
            onTap: () {},
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(DabblerIconTile).first),
        matchesSemantics(
          label: 'Notifications',
          isButton: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });

  group('AC1 — RTL and dark mode', () {
    testWidgets('the tile is square and centred under RTL', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerIconTile.named('game'),
          textDirection: TextDirection.rtl,
        ),
      );
      final Rect tile = tester.getRect(find.byType(DabblerIconTile));
      final Rect glyph = tester.getRect(find.byType(DabblerIcon));
      expect(tile.center.dx, closeTo(glyph.center.dx, 0.01));
      expect(tile.center.dy, closeTo(glyph.center.dy, 0.01));
    });

    testWidgets('dark mode re-resolves the brand tint through Surface', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerIconTile.named('game'), brightness: Brightness.dark),
      );
      final DabblerColors dark = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.dark,
      );
      final DabblerColors light = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      expect(_box(tester).variant, DabblerSurfaceVariant.brandTint);
      expect(
        DabblerIconTile.fillFor(dark, DabblerIconTileTone.brand),
        isNot(DabblerIconTile.fillFor(light, DabblerIconTileTone.brand)),
      );
      expect(
        DabblerIconTile.fillFor(dark, DabblerIconTileTone.brand),
        DabblerSurface.fillOf(dark, DabblerSurfaceVariant.brandTint),
      );
    });
  });
}
