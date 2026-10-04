import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

double _luminance(Color c) => c.computeLuminance();

void main() {
  group('DabblerHueTone', () {
    test('the four roles step from pale to deep', () {
      final DabblerHueTone t = DabblerHueTone.hue(152);
      expect(_luminance(t.surface), greaterThan(_luminance(t.edge)));
      expect(_luminance(t.edge), greaterThan(_luminance(t.solid)));
      expect(_luminance(t.solid), greaterThanOrEqualTo(_luminance(t.deep)));
    });

    test('known sports use the source hue, unknown sports the fallback', () {
      expect(
        DabblerHueTone.forSportKey('football'),
        DabblerHueTone.hue(DabblerHueTone.sportHues['football']!),
      );
      expect(
        DabblerHueTone.forSportKey('handball'),
        DabblerHueTone.hue(DabblerHueTone.fallbackHue),
      );
      expect(
        DabblerHueTone.forSportKey(null),
        DabblerHueTone.hue(DabblerHueTone.fallbackHue),
      );
    });

    test('different hues give different tones', () {
      expect(
        DabblerHueTone.hue(152).solid,
        isNot(DabblerHueTone.hue(350).solid),
      );
    });

    test('every colour is opaque', () {
      final DabblerHueTone t = DabblerHueTone.gender(DabblerHueTone.maleHue);
      for (final Color c in <Color>[t.surface, t.edge, t.solid, t.deep]) {
        expect(c.a, 1);
      }
    });

    test('gender surfaces are paler than sport surfaces of the same hue', () {
      final DabblerHueTone gender = DabblerHueTone.gender(233);
      final DabblerHueTone sport = DabblerHueTone.hue(233);
      expect(
        _luminance(gender.surface),
        greaterThan(_luminance(sport.surface)),
      );
    });

    test('a ramp tone mixes the base over the card', () {
      const Color card = Color(0xFFFFFFFF);
      final DabblerHueTone t = DabblerHueTone.ramp(
        base: DabblerPalette.sportP600,
        deep: DabblerPalette.sportP700,
        card: card,
      );
      expect(t.solid, DabblerPalette.sportP700);
      expect(
        t.surface,
        Color.alphaBlend(
          DabblerPalette.sportP600.withValues(alpha: 0.12),
          card,
        ),
      );
      expect(_luminance(t.surface), greaterThan(_luminance(t.edge)));
      expect(_luminance(t.edge), greaterThan(_luminance(t.idle)));
    });
  });
}
