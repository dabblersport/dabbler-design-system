import 'dart:math' as math;

import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_dark_provisional.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Relative luminance, WCAG 2.1 §1.4.3 — the same formula the design source's
/// own measured table uses (`guidelines/colors-status-contrast.html`), so a
/// ratio computed here is comparable to the one published there.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) +
      0.7152 * channel(c.g) +
      0.0722 * channel(c.b);
}

double contrast(Color a, Color b) {
  final double la = _luminance(a);
  final double lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Every `(theme, brightness)` pair, as a readable label.
Iterable<(String, DabblerColors)> get _every sync* {
  for (final DabblerTheme t in DabblerTheme.values) {
    for (final Brightness b in Brightness.values) {
      yield ('${t.name}/${b.name}', DabblerColors.resolve(theme: t, brightness: b));
    }
  }
}

void main() {
  group('AC1 — 14 instances reachable through the theme', () {
    test('7 themes x 2 brightnesses resolve to 14 distinct instances', () {
      expect(DabblerColors.all, hasLength(14));
      final Set<(DabblerTheme, Brightness)> keys = <(DabblerTheme, Brightness)>{
        for (final DabblerColors c in DabblerColors.all) (c.theme, c.brightness),
      };
      expect(keys, hasLength(14));
    });

    test('no two instances paint the same set of brand roles at a brightness',
        () {
      for (final Brightness b in Brightness.values) {
        final Set<String> fingerprints = <String>{
          for (final DabblerTheme t in DabblerTheme.values)
            () {
              final DabblerColors c = DabblerColors.resolve(theme: t, brightness: b);
              return '${c.brandPrimary}|${c.accent}|${c.focusRing}';
            }(),
        };
        expect(fingerprints, hasLength(7), reason: 'brand collision in $b');
      }
    });

    testWidgets('Theme.of(context).extension<DabblerColors>() resolves each',
        (WidgetTester tester) async {
      for (final (String label, DabblerColors expected) in _every) {
        late DabblerColors seen;
        await tester.pumpWidget(
          MaterialApp(
            // A fresh key per instance: MaterialApp cross-fades a theme change
            // through AnimatedTheme, and this test is about resolution, not
            // about the transition (which `lerp` deliberately snaps).
            key: ValueKey<String>(label),
            theme: ThemeData(
              brightness: expected.brightness,
              extensions: <ThemeExtension<dynamic>>[expected],
            ),
            home: Builder(
              builder: (BuildContext context) {
                seen = DabblerColors.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(seen.theme, expected.theme, reason: label);
        expect(seen.brightness, expected.brightness, reason: label);
        expect(seen.brandPrimary, expected.brandPrimary, reason: label);
      }
    });

    test('copyWith re-resolves and lerp snaps rather than interpolating', () {
      final DabblerColors main = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      final DabblerColors sportDark =
          main.copyWith(theme: DabblerTheme.sport, brightness: Brightness.dark);
      expect(sportDark.brandPrimary, DabblerPalette.sportP400);
      expect(main.lerp(sportDark, 0.49), same(main));
      expect(main.lerp(sportDark, 0.5), same(sportDark));
    });
  });

  group('AC2 — paper shared, brand retinted', () {
    // Exhaustive over every unordered pair of the 7 themes, at each brightness:
    // 21 pairs x 2 = 42 comparisons.
    for (final Brightness b in Brightness.values) {
      for (int i = 0; i < DabblerTheme.values.length; i++) {
        for (int j = i + 1; j < DabblerTheme.values.length; j++) {
          final DabblerTheme a = DabblerTheme.values[i];
          final DabblerTheme z = DabblerTheme.values[j];
          test('${a.name} vs ${z.name} @ ${b.name}: paper identical', () {
            final DabblerColors x = DabblerColors.resolve(theme: a, brightness: b);
            final DabblerColors y = DabblerColors.resolve(theme: z, brightness: b);
            expect(x.bgPrimary, y.bgPrimary);
            expect(x.bgSecondary, y.bgSecondary);
            expect(x.bgTertiary, y.bgTertiary);
            expect(x.surfaceCard, y.surfaceCard);
            expect(x.surfaceSunken, y.surfaceSunken);
            expect(x.surfaceGrey, y.surfaceGrey);
            expect(x.textPrimary, y.textPrimary);
            expect(x.textSecondary, y.textSecondary);
            expect(x.textTertiary, y.textTertiary);
            expect(x.borderDefault, y.borderDefault);
            expect(x.borderStrong, y.borderStrong);
            expect(x.scrim, y.scrim);
            expect(x.spotlight, y.spotlight);
          });
        }
      }
    }

    test('brand roles differ for every pair of themes at both brightnesses', () {
      for (final Brightness b in Brightness.values) {
        for (int i = 0; i < DabblerTheme.values.length; i++) {
          for (int j = i + 1; j < DabblerTheme.values.length; j++) {
            final DabblerColors x =
                DabblerColors.resolve(theme: DabblerTheme.values[i], brightness: b);
            final DabblerColors y =
                DabblerColors.resolve(theme: DabblerTheme.values[j], brightness: b);
            expect(
              x.brandPrimary == y.brandPrimary && x.accent == y.accent,
              isFalse,
              reason: '${x.theme.name} and ${y.theme.name} share a brand @ $b',
            );
          }
        }
      }
    });

    test('only sport/social/active/bright override a status tone', () {
      const Map<DabblerTheme, DabblerStatusTone> overrides =
          <DabblerTheme, DabblerStatusTone>{
        DabblerTheme.sport: DabblerStatusTone.success,
        DabblerTheme.social: DabblerStatusTone.info,
        DabblerTheme.active: DabblerStatusTone.error,
        DabblerTheme.bright: DabblerStatusTone.warning,
      };
      for (final Brightness b in Brightness.values) {
        final DabblerColors base =
            DabblerColors.resolve(theme: DabblerTheme.main, brightness: b);
        for (final DabblerTheme t in DabblerTheme.values) {
          final DabblerColors c = DabblerColors.resolve(theme: t, brightness: b);
          for (final DabblerStatusTone tone in DabblerStatusTone.values) {
            final bool shouldDiffer = overrides[t] == tone;
            expect(
              c.status(tone) == base.status(tone),
              !shouldDiffer,
              reason: '${t.name} $tone @ $b',
            );
          }
        }
      }
    });
  });

  group('transcription fidelity against tokens/colors.css', () {
    test('main light resolves the :root generic theme layer', () {
      final DabblerColors c = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      expect(c.brandPrimary, DabblerPalette.mainP600);
      expect(c.brandPrimaryHover, DabblerPalette.mainP700);
      expect(c.onBrand, DabblerPalette.paper);
      expect(c.accent, DabblerPalette.mainS600);
      expect(c.focusRing, DabblerPalette.mainP400);
      expect(c.bgPrimary, DabblerPalette.surfacePage);
      expect(c.surfaceCard, DabblerPalette.surfaceCard);
      expect(c.textPrimary, DabblerPalette.ink);
      expect(c.borderDefault, DabblerPalette.outlineCard);
    });

    test('per-theme status overrides carry their own ramp', () {
      final DabblerColors sport = DabblerColors.resolve(
        theme: DabblerTheme.sport,
        brightness: Brightness.light,
      );
      expect(sport.success.base, DabblerPalette.sportSuccess);
      expect(sport.success.strong, DabblerThemeStatusTints.sportSuccessInk);

      final DabblerColors social = DabblerColors.resolve(
        theme: DabblerTheme.social,
        brightness: Brightness.dark,
      );
      expect(social.info.base, DabblerPalette.socialInfo);
      expect(social.info.surface, DabblerProvisionalDark.socialInfoSurface);

      final DabblerColors active = DabblerColors.resolve(
        theme: DabblerTheme.active,
        brightness: Brightness.light,
      );
      // `active` overrides the indicator only — the surface stays shared.
      expect(active.error.base, DabblerPalette.activeError);
      expect(active.error.surface, DabblerPalette.error100);
    });

    test('-solid is fixed at the 700 shade in both modes, every theme', () {
      for (final (String label, DabblerColors c) in _every) {
        expect(c.success.solid, DabblerPalette.success700, reason: label);
        expect(c.warning.solid, DabblerPalette.warning700, reason: label);
        expect(c.error.solid, DabblerPalette.error700, reason: label);
        expect(c.info.solid, DabblerPalette.info700, reason: label);
      }
    });

    test('scrim is ink @45% light, ink-950 @65% dark', () {
      for (final (String label, DabblerColors c) in _every) {
        final bool dark = c.brightness == Brightness.dark;
        expect(c.scrim.a, closeTo(dark ? 0.65 : 0.45, 0.004), reason: label);
      }
    });
  });

  group('AC5 — status and tone are types, not Colors', () {
    test('a DabblerStatusColor is never == a plain Color', () {
      final DabblerColors c = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      const Color sameValue = DabblerPalette.success500;
      expect(c.success.base, sameValue);
      // The tone carries that same value and is still not that value. The
      // `unrelated_type_equality_checks` info the analyser raises on these two
      // lines IS the acceptance criterion: the comparison is meaningless
      // because the types are unrelated, which is exactly what AC5 asks for.
      // ignore: unrelated_type_equality_checks
      expect(c.success == sameValue, isFalse);
      // ignore: unrelated_type_equality_checks
      expect(sameValue == c.success, isFalse);
      expect(c.success, isNot(isA<Color>()));
    });

    test('a DabblerToneColor is never == a plain Color', () {
      // ignore: unrelated_type_equality_checks
      expect(DabblerColors.tagPending == DabblerPalette.tagPendingSurface, isFalse);
      expect(DabblerColors.tileAmber, isNot(isA<Color>()));
    });

    test('equal-valued tones are equal to each other', () {
      expect(
        const DabblerToneColor(
          surface: DabblerPalette.tagPendingSurface,
          ink: DabblerPalette.tagPendingInk,
        ),
        DabblerColors.tagPending,
      );
    });
  });

  group('AC6 — measured contrast (WCAG 2.1 relative luminance)', () {
    // What clears AA (4.5:1) on the current ramp, asserted as a gate.
    test('textPrimary clears 4.5:1 on all six surfaces, all 14 instances', () {
      for (final (String label, DabblerColors c) in _every) {
        for (final (String name, Color s) in <(String, Color)>[
          ('bgPrimary', c.bgPrimary),
          ('bgSecondary', c.bgSecondary),
          ('bgTertiary', c.bgTertiary),
          ('surfaceCard', c.surfaceCard),
          ('surfaceSunken', c.surfaceSunken),
          ('surfaceGrey', c.surfaceGrey),
        ]) {
          expect(
            contrast(c.textPrimary, s),
            greaterThanOrEqualTo(4.5),
            reason: '$label textPrimary on $name',
          );
        }
      }
    });

    test('every status surface x strong pairing clears 4.5:1', () {
      for (final (String label, DabblerColors c) in _every) {
        for (final DabblerStatusTone tone in DabblerStatusTone.values) {
          final DabblerStatusColor s = c.status(tone);
          expect(
            contrast(s.strong, s.surface),
            greaterThanOrEqualTo(4.5),
            reason: '$label $tone surface x strong',
          );
          expect(
            contrast(s.strong, c.surfaceCard),
            greaterThanOrEqualTo(4.5),
            reason: '$label $tone strong on card',
          );
          expect(
            contrast(s.solid, DabblerPalette.paper),
            greaterThanOrEqualTo(4.5),
            reason: '$label $tone solid x white',
          );
        }
      }
    });

    test('decorative tile ink clears 4.5:1 on its own surface', () {
      for (final DabblerToneColor t in <DabblerToneColor>[
        DabblerColors.tileAmber,
        DabblerColors.tileInfo,
        DabblerColors.tileAccent,
      ]) {
        expect(contrast(t.ink, t.surface), greaterThanOrEqualTo(4.5));
      }
    });

    // What does NOT clear AA on the current ramp. These ratios are the design
    // source's own values, not this package's choices, so they are pinned to
    // the measured figure rather than asserted against 4.5:1 — a drift in
    // either direction fails the build and reaches cxo.
    //
    // OPEN AGAINST AC6: the six pairings below are ink-on-surface pairings that
    // do NOT reach 4.5:1 at light brightness. `--muted` (#8C8C8C) and
    // `--subtle` (#B8B0A0) on the warm paper ramp top out at 3.36:1 and 2.15:1
    // respectively. Both are inherited verbatim from "Dabbler Design UI.fig"
    // (`tokens/colors.css:34-45`). AA body text cannot be set in either role at
    // light brightness until the design source changes.
    //
    // KAN-260 / D-003(a) moved the SUBJECT of this pin, not one of its numbers.
    // The six measured ratios are unchanged to the hundredth, and every one is
    // still asserted below 4.5. What changed is that they are now measured
    // against [DabblerPalette.muted] and [DabblerPalette.subtle] directly
    // rather than through `textSecondary`/`textTertiary`: after the remap the
    // semantic fields no longer resolve to those tokens, so reading the pin
    // through them would have quietly stopped measuring the source. The pin
    // records `colors.css`, and `colors.css` has not moved.
    test('--muted and --subtle on the paper ramp are pinned below AA, '
        'as measured', () {
      final DabblerColors c = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      const Map<String, double> measured = <String, double>{
        'secondary/bgPrimary': 2.96,
        'secondary/surfaceCard': 3.36,
        'secondary/bgTertiary': 2.56,
        'tertiary/bgPrimary': 1.90,
        'tertiary/surfaceCard': 2.15,
        'tertiary/bgTertiary': 1.64,
      };
      const Color muted = DabblerPalette.muted;
      const Color subtle = DabblerPalette.subtle;
      final Map<String, double> actual = <String, double>{
        'secondary/bgPrimary': contrast(muted, c.bgPrimary),
        'secondary/surfaceCard': contrast(muted, c.surfaceCard),
        'secondary/bgTertiary': contrast(muted, c.bgTertiary),
        'tertiary/bgPrimary': contrast(subtle, c.bgPrimary),
        'tertiary/surfaceCard': contrast(subtle, c.surfaceCard),
        'tertiary/bgTertiary': contrast(subtle, c.bgTertiary),
      };
      for (final MapEntry<String, double> e in measured.entries) {
        expect(actual[e.key], closeTo(e.value, 0.01), reason: e.key);
        expect(e.value, lessThan(4.5), reason: '${e.key} is a known AA gap');
      }
    });

    // The other half of D-003(a): the ROLES that used to sit on those two
    // tokens now clear AA outright, which is the whole point of the remap.
    test('light textSecondary clears AA on every paper surface (D-003(a))', () {
      final DabblerColors c = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      for (final Color s in <Color>[
        c.bgPrimary,
        c.bgSecondary,
        c.bgTertiary,
        c.surfaceCard,
        c.surfaceSunken,
        c.surfaceGrey,
      ]) {
        expect(contrast(c.textSecondary, s), greaterThanOrEqualTo(4.5));
      }
    });

    test('dark textSecondary and textTertiary do clear 4.5:1', () {
      final DabblerColors c = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.dark,
      );
      for (final Color s in <Color>[
        c.bgPrimary,
        c.bgSecondary,
        c.bgTertiary,
        c.surfaceCard,
        c.surfaceSunken,
        c.surfaceGrey,
      ]) {
        expect(contrast(c.textSecondary, s), greaterThanOrEqualTo(4.5));
        expect(contrast(c.textTertiary, s), greaterThanOrEqualTo(4.5));
      }
    });

    // OPEN AGAINST AC6: on-brand ink. Five of the fourteen brand pairings sit
    // below 4.5:1 with the source's own ramp — shade/light (3.95) and
    // main/sport/social/active at dark brightness (4.19 / 2.92 / 2.95 / 3.12),
    // where `--t-primary` steps down to the 400 shade but `--t-on-brand` stays
    // white. Pinned, not asserted, for the same reason.
    test('on-brand contrast is pinned to the measured ramp', () {
      const Map<String, double> measured = <String, double>{
        'main/light': 7.18,
        'sport/light': 4.55,
        'social/light': 4.59,
        'active/light': 4.57,
        'bright/light': 8.84,
        'simple/light': 17.22,
        'shade/light': 3.95,
        'main/dark': 4.19,
        'sport/dark': 2.92,
        'social/dark': 2.95,
        'active/dark': 3.12,
        'bright/dark': 10.52,
        'simple/dark': 15.82,
        'shade/dark': 5.17,
      };
      for (final (String label, DabblerColors c) in _every) {
        expect(
          contrast(c.onBrand, c.brandPrimary),
          closeTo(measured[label]!, 0.01),
          reason: label,
        );
      }
    });
  });
}
