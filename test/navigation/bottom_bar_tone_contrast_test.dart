import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The create-menu glyph against its plate, every tone, light and dark.
///
/// The glyph is [DabblerColors.textPrimary] on
/// [dabblerNavigationIconPlateFor]. The `info` and `accent` plates used to be
/// the light pastels in dark mode too, which put the light dark-mode glyph at
/// about 1.2:1 ("Create post" unreadable). Every plate must now give the glyph
/// at least 3:1 (WCAG 1.4.11, non-text), and in dark mode the info and accent
/// tiles must be at least as legible as the success ("Create game") tile.
///
/// `--dart-define=PRINT_TONE_CONTRAST=1` prints the table.
double _ratio(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double hi = la > lb ? la : lb;
  final double lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  const double minimum = 3;
  for (final DabblerTheme theme in DabblerTheme.values) {
    for (final Brightness brightness in Brightness.values) {
      test(
        'glyph contrast on every plate — ${theme.name} ${brightness.name}',
        () {
          final DabblerColors c = DabblerColors.resolve(
            theme: theme,
            brightness: brightness,
          );
          final Map<DabblerNavigationIconTone, double> r =
              <DabblerNavigationIconTone, double>{
                for (final DabblerNavigationIconTone t
                    in DabblerNavigationIconTone.values)
                  t: _ratio(c.textPrimary, dabblerNavigationIconPlateFor(t, c)),
              };
          if (const String.fromEnvironment('PRINT_TONE_CONTRAST') == '1') {
            // ignore: avoid_print
            print(
              '${theme.name} ${brightness.name}: '
              '${r.entries.map((e) => '${e.key.name} ${e.value.toStringAsFixed(2)}').join(', ')}',
            );
          }
          for (final MapEntry<DabblerNavigationIconTone, double> e
              in r.entries) {
            expect(
              e.value,
              greaterThanOrEqualTo(minimum),
              reason: '${e.key.name} plate, ${theme.name} ${brightness.name}',
            );
          }
          if (brightness == Brightness.dark) {
            final double game = r[DabblerNavigationIconTone.success]!;
            for (final DabblerNavigationIconTone t
                in <DabblerNavigationIconTone>[
                  DabblerNavigationIconTone.info,
                  DabblerNavigationIconTone.accent,
                ]) {
              expect(
                r[t]!,
                greaterThanOrEqualTo(game),
                reason: '${t.name} vs the Create game (success) plate, dark',
              );
            }
          }
        },
      );
    }
  }
}
