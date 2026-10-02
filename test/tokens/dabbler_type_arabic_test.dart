import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The live design project's `tokens/typography.css` (design system 1.2.0).
///
/// `(latinSize, arabicSize, latinLeading, arabicLeading)` per style, copied from
/// the `.t-*` rules and from the `[dir="rtl"] .t-* { font-size; line-height }`
/// block that follows them. The RTL block's header comment reads *"size =
/// Latin size − 0.9px at every step … Four text styles also take extra leading
/// (headline, body, callout, subheadline)"*. The file's own top comment says
/// the sizes are the same in Arabic; the declarations are what render and they
/// govern (cxo ruling, D-004). This table is pinned here so the check does not
/// depend on any file outside the package.
const Map<String, (double, double, double, double)> _live =
    <String, (double, double, double, double)>{
      'largeTitle': (34, 33.1, 41, 41),
      'title1': (28, 27.1, 34, 34),
      'title2': (22, 21.1, 28, 28),
      'title3': (20, 19.1, 25, 25),
      'headline': (17, 16.1, 22, 25),
      'body': (16, 15.1, 21, 24),
      'callout': (17, 16.1, 22, 25),
      'subheadline': (15, 14.1, 20, 23),
      'footnote': (13, 12.1, 18, 18),
      'caption1': (12, 11.1, 16, 16),
      'caption2': (11, 10.1, 13, 13),
      'label': (17, 16.1, 22, 22),
    };

void main() {
  group('Arabic size — live typography.css 1.2.0 RTL declarations', () {
    test('all twelve styles are pinned', () {
      expect(DabblerType.styles.length, 12);
      expect(
        DabblerType.styles.map((DabblerTypeStyle s) => s.name).toSet(),
        _live.keys.toSet(),
      );
    });

    test('latin size, arabic size and both leadings match the transcribed live table (mirror, no byte check)', () {
      for (final DabblerTypeStyle s in DabblerType.styles) {
        final (double ls, double ars, double ll, double al) = _live[s.name]!;
        expect(s.fontSize, ls, reason: '${s.name} latin size');
        expect(s.arabicFontSize, ars, reason: '${s.name} arabic size');
        expect(s.latinLeading, ll, reason: '${s.name} latin leading');
        expect(s.arabicLeading, al, reason: '${s.name} arabic leading');
      }
    });

    test('Arabic size is Latin less 0.9 on every style', () {
      for (final DabblerTypeStyle s in DabblerType.styles) {
        expect(
          s.fontSize - s.arabicFontSize,
          closeTo(0.9, 1e-9),
          reason: s.name,
        );
      }
    });

    test('resolve(script) carries the per-script size and leading', () {
      for (final DabblerTypeStyle s in DabblerType.styles) {
        final TextStyle lat = s.resolve(DabblerTypeScript.latin);
        final TextStyle ar = s.resolve(DabblerTypeScript.arabic);
        expect(lat.fontSize, s.fontSize, reason: '${s.name} latin');
        expect(ar.fontSize, s.arabicFontSize, reason: '${s.name} arabic');
        expect(lat.height! * lat.fontSize!, closeTo(s.latinLeading, 1e-6));
        expect(
          ar.height! * ar.fontSize!,
          closeTo(s.arabicLeading, 1e-6),
          reason: '${s.name} arabic leading stays the declared px',
        );
      }
    });

    test('direction selects the script: rtl is Arabic, ltr is Latin', () {
      for (final DabblerTypeStyle s in DabblerType.styles) {
        expect(
          s.resolveForDirection(TextDirection.rtl).fontSize,
          s.arabicFontSize,
        );
        expect(s.resolveForDirection(TextDirection.ltr).fontSize, s.fontSize);
      }
    });

    test('sizeFor and leadingFor agree with the fields', () {
      final DabblerTypeStyle b = DabblerType.body;
      expect(b.sizeFor(DabblerTypeScript.arabic), 15.1);
      expect(b.sizeFor(DabblerTypeScript.latin), 16);
      expect(b.leadingFor(DabblerTypeScript.arabic), 24);
    });

    test('Latin is unchanged from before the Arabic offset', () {
      const List<double> latin = <double>[
        34,
        28,
        22,
        20,
        17,
        16,
        17,
        15,
        13,
        12,
        11,
        17,
      ];
      expect(
        DabblerType.styles.map((DabblerTypeStyle s) => s.fontSize).toList(),
        latin,
      );
    });

    test('tracking stays 0 and numerals stay Western in both scripts', () {
      for (final DabblerTypeStyle s in DabblerType.styles) {
        for (final DabblerTypeScript sc in DabblerTypeScript.values) {
          final TextStyle t = s.resolve(sc);
          expect(t.letterSpacing, 0);
          expect(t.fontFeatures, DabblerType.numeralFeatures);
        }
      }
    });
  });
}
