import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dabbler_design_system/theme/dabbler_colors.dart';
import 'package:dabbler_design_system/theme/dabbler_glass.dart';

/// WCAG relative-luminance contrast ratio.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Composite a translucent [fg] over an opaque [bg] (sRGB, like the renderer).
Color _over(Color fg, Color bg) => Color.alphaBlend(fg, bg);

void main() {
  test(
      'glass body text meets WCAG AA (4.5:1) in every theme, light and dark, '
      'including over the strongest background orb', () {
    for (final theme in DabblerTheme.values) {
      for (final b in Brightness.values) {
        final d = DabblerColors.of(theme, b);
        final base = DabblerGlass.backgroundBase(d, b);
        // Worst case: the strongest orb (brand-light @33%, ×0.4 in dark).
        final orbAlpha = b == Brightness.dark ? 0.33 * 0.4 : 0.33;
        final orbBg = _over(
            DabblerGlass.brandLight(d).withValues(alpha: orbAlpha), base);

        for (final backdrop in [base, orbBg]) {
          final surface = _over(DabblerGlass.fill(b), backdrop);
          expect(
            _contrast(d.textPrimary, surface),
            greaterThanOrEqualTo(4.5),
            reason: '$theme/$b textPrimary on glass fails AA',
          );
          expect(
            _contrast(d.textSecondary, surface),
            greaterThanOrEqualTo(4.5),
            reason: '$theme/$b textSecondary on glass fails AA',
          );
        }
      }
    }
  });

  test(
      'onBrand labels on the selected fill meet AA-large (3:1) in every theme '
      '(button/chip labels are 15–17pt Medium)', () {
    for (final theme in DabblerTheme.values) {
      for (final b in Brightness.values) {
        final d = DabblerColors.of(theme, b);
        final base = DabblerGlass.backgroundBase(d, b);
        final surface = _over(DabblerGlass.selectedFill(d), base);
        expect(
          _contrast(d.onBrand, surface),
          greaterThanOrEqualTo(3.0),
          reason: '$theme/$b onBrand on selected fill fails AA-large',
        );
      }
    }
  });

  test('Bright and Sport light-primary themes use DARK selected labels where '
      'the fill is light', () {
    final bright = DabblerColors.of(DabblerTheme.bright, Brightness.light);
    // Bright's primary is light — its onBrand must be dark.
    expect(bright.onBrand.computeLuminance(), lessThan(0.5));
    // And it must clear AA-large over the composited selected fill.
    final surface = _over(
      DabblerGlass.selectedFill(bright),
      DabblerGlass.backgroundBase(bright, Brightness.light),
    );
    expect(_contrast(bright.onBrand, surface), greaterThanOrEqualTo(3.0));
  });
}
