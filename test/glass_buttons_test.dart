import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dabbler_design_system/components/dabbler_button.dart';
import 'package:dabbler_design_system/debug/theme_gallery.dart';
import 'package:dabbler_design_system/theme/dabbler_colors.dart';
import 'package:dabbler_design_system/theme/dabbler_glass.dart';
import 'package:dabbler_design_system/theme/dabbler_theme_data.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

Color _over(Color fg, Color bg) => Color.alphaBlend(fg, bg);

Color _backgroundBase(DabblerColors d, Brightness b) => b == Brightness.dark
    ? Color.lerp(d.brandPrimary, Colors.black, 0.86)!
    : Color.lerp(d.brandPrimary, Colors.white, 0.92)!;

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
  bool highContrast = false,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dabblerThemeData(theme, brightness),
      home: MediaQuery(
        data: MediaQueryData(highContrast: highContrast),
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

void main() {
  setUp(() => DabblerGlassConfig.enabled = true);
  tearDown(() => DabblerGlassConfig.enabled = true);

  test('saturation boost matrix is luminance-preserving (rows sum to 1)', () {
    for (final s in [1.4, 1.8]) {
      final m = saturationMatrix(s);
      for (var row = 0; row < 3; row++) {
        final sum = m[row * 5] + m[row * 5 + 1] + m[row * 5 + 2];
        expect(sum, closeTo(1.0, 1e-9), reason: 'row $row of saturate($s)');
      }
    }
  });

  testWidgets('glass button = exactly one BackdropFilter WITH the saturation '
      'boost (composed filter, not a plain blur)', (tester) async {
    await _pump(
      tester,
      DabblerButton(
        label: 'Filter',
        variant: DabblerButtonVariant.glass,
        onPressed: () {},
      ),
    );

    final filters = tester.widgetList<BackdropFilter>(
      find.byType(BackdropFilter),
    );
    expect(filters.length, 1, reason: 'one blur layer per surface, never more');
    // ImageFilter.compose(blur, ColorFilter.matrix) — a plain blur is a FAIL.
    final desc = filters.first.filter.toString();
    expect(desc, contains('blur'));
    expect(desc.contains('ColorFilter') || desc.contains('matrix'), isTrue,
        reason: 'missing the saturation boost: $desc');
  });

  testWidgets('glass keeps the button metrics (height 45, radius from tokens)',
      (tester) async {
    await _pump(
      tester,
      DabblerButton(
        label: 'Glass',
        variant: DabblerButtonVariant.glass,
        onPressed: () {},
      ),
    );
    expect(tester.getSize(find.byKey(DabblerButton.surfaceKey)).height, 45);
  });

  testWidgets('Reduce Transparency (highContrast) → opaque bordered fallback',
      (tester) async {
    await _pump(
      tester,
      DabblerButton(
        label: 'Fallback',
        variant: DabblerButtonVariant.glass,
        onPressed: () {},
      ),
      highContrast: true,
    );
    expect(find.byType(BackdropFilter), findsNothing);
    // The fallback is an opaque surface with a real border.
    final boxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
    final bordered = boxes.any((b) =>
        b.decoration is BoxDecoration &&
        (b.decoration as BoxDecoration).border != null);
    expect(bordered, isTrue);
  });

  testWidgets('DabblerGlassConfig.enabled = false → opaque fallback',
      (tester) async {
    DabblerGlassConfig.enabled = false;
    await _pump(
      tester,
      DabblerButton(
        label: 'Off',
        variant: DabblerButtonVariant.glassActive,
        onPressed: () {},
      ),
    );
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.text('Off'), findsOneWidget);
  });

  testWidgets('glassActive label reads onBrand — DARK in Bright',
      (tester) async {
    await _pump(
      tester,
      DabblerButton(
        label: 'Go',
        variant: DabblerButtonVariant.glassActive,
        onPressed: () {},
      ),
      theme: DabblerTheme.bright,
    );
    final label = tester.widget<Text>(find.text('Go'));
    final d = tester.element(find.byType(DabblerButton)).dabbler;
    expect(label.style!.color, d.onBrand);
    expect(label.style!.color!.computeLuminance(), lessThan(0.5),
        reason: "Bright's primary is light — the label must be dark");
  });

  testWidgets('glassActive label reads onBrand and clears AA-large in Sport',
      (tester) async {
    await _pump(
      tester,
      DabblerButton(
        label: 'Go',
        variant: DabblerButtonVariant.glassActive,
        onPressed: () {},
      ),
      theme: DabblerTheme.sport,
    );
    final label = tester.widget<Text>(find.text('Go'));
    final d = tester.element(find.byType(DabblerButton)).dabbler;
    expect(label.style!.color, d.onBrand);
    // brand @85% composited over the glass background base.
    final fill = _over(
      d.brandPrimary.withValues(alpha: 0.85),
      _backgroundBase(d, Brightness.light),
    );
    expect(_contrast(d.onBrand, fill), greaterThanOrEqualTo(3.0));
  });

  testWidgets('glass shadows derive from the ACTIVE theme, never the violet',
      (tester) async {
    await _pump(
      tester,
      DabblerButton(
        label: 'Sporty',
        variant: DabblerButtonVariant.glass,
        onPressed: () {},
      ),
      theme: DabblerTheme.sport,
    );
    final d = tester.element(find.byType(DabblerButton)).dabbler;
    final boxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
    final casts = boxes
        .map((b) => b.decoration)
        .whereType<BoxDecoration>()
        .expand((dec) => dec.boxShadow ?? const <BoxShadow>[])
        .where((s) => s.color.a > 0 && s.color.a < 1 && s.offset.dy > 2);
    expect(casts, isNotEmpty);
    for (final s in casts) {
      // Cast colour is the Sport green, not the Main violet.
      expect(s.color.withValues(alpha: 1.0), d.brandPrimary.withValues(alpha: 1.0));
    }
  });

  testWidgets('gallery "Glass (test)" tab renders glass on the orb background '
      'and the enabled toggle demos the opaque fallback', (tester) async {
    tester.view.physicalSize = const Size(1700, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: ThemeGalleryScreen()));
    await tester.pumpAndSettle();

    // The view segments scroll horizontally — bring the last one into view.
    await tester.ensureVisible(find.text('Glass (test)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Glass (test)'));
    await tester.pumpAndSettle();

    // _SubHead uppercases its label.
    expect(find.text('FLOATING = GLASS'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsWidgets); // glass is on

    // Toggle DabblerGlassConfig.enabled off → opaque fallback everywhere.
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.byType(BackdropFilter), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('AA: textPrimary on the glass tint passes 4.5:1 in all 7 themes, light '
      'AND dark, including over the strongest background orb', () {
    for (final theme in DabblerTheme.values) {
      for (final b in Brightness.values) {
        final d = DabblerColors.of(theme, b);
        final dark = b == Brightness.dark;
        final base = _backgroundBase(d, b);
        final orbAlpha = dark ? 0.33 * 0.4 : 0.33;
        final orbBg =
            _over(dabblerBrandLight(d).withValues(alpha: orbAlpha), base);
        final tint = Colors.white.withValues(alpha: dark ? 0.12 : 0.45);

        for (final backdrop in [base, orbBg]) {
          final surface = _over(tint, backdrop);
          expect(
            _contrast(d.textPrimary, surface),
            greaterThanOrEqualTo(4.5),
            reason: '$theme/$b textPrimary on glass fails AA',
          );
        }
      }
    }
  });
}
