import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Scans DS-603's own sources for values that belong to another file.
///
/// The system's rule is composition, not restatement: motion, press and focus
/// values live in `lib/src/interaction/`, colour in the palette, geometry in
/// `dabbler_geometry.dart`. A control that re-declares one of them looks right
/// until the token moves. Several landed tickets carry a scan like this one;
/// it is the standard here, and this is DS-603's.
void main() {
  const List<String> files = <String>[
    'lib/src/forms/toggle.dart',
    'lib/src/forms/checkbox.dart',
    'lib/src/forms/radio.dart',
    'lib/src/forms/stepper.dart',
    'lib/src/forms/slider.dart',
  ];

  /// Code only: the dartdocs quote the source's CSS, so a scan that read them
  /// would fail on the very citations that prove the values are transcribed.
  String codeOf(String path) => File(path)
      .readAsLinesSync()
      .where((String line) => !line.trimLeft().startsWith('//'))
      .join('\n');

  for (final String path in files) {
    group(path, () {
      test('declares no colour of its own', () {
        final String code = codeOf(path);
        expect(
          RegExp(r'Color\(0x').hasMatch(code),
          isFalse,
          reason: 'colour comes from DabblerColors, never a literal',
        );
        expect(
          RegExp(r'\bColors\.[a-z]').hasMatch(code),
          isFalse,
          reason: "Material's palette is not this system's",
        );
      });

      test('restates no motion or press value', () {
        final String code = codeOf(path);
        expect(
          RegExp(r'Duration\(milliseconds:').hasMatch(code),
          isFalse,
          reason: 'durations are DabblerMotion.fast / base / slow',
        );
        expect(
          RegExp(r'Cubic\(').hasMatch(code),
          isFalse,
          reason: 'the one curve is DabblerMotion.easeOut',
        );
        expect(
          code.contains('0.98'),
          isFalse,
          reason: 'the press transform is DabblerMotion.pressScale',
        );
      });

      test('draws no shadow, gradient or blur — the flat system', () {
        final String code = codeOf(path);
        for (final String banned in <String>[
          'BoxShadow',
          'Gradient',
          'ImageFilter',
          'BackdropFilter',
          'elevation:',
        ]) {
          expect(
            code.contains(banned),
            isFalse,
            reason: '$banned has no place in a flat control',
          );
        }
      });

      test('is RTL-safe: no physical edge anywhere', () {
        final String code = codeOf(path);
        for (final String banned in <String>[
          'EdgeInsets.only(left',
          'EdgeInsets.only(right',
          'EdgeInsets.fromLTRB',
          'Alignment.centerLeft',
          'Alignment.centerRight',
          'Positioned(left',
          'Positioned(right',
          'TextAlign.left',
          'TextAlign.right',
        ]) {
          expect(
            code.contains(banned),
            isFalse,
            reason: '$banned is physical; the directional form mirrors',
          );
        }
      });

      test('paints its own focus indicator through the shared ring', () {
        final String code = codeOf(path);
        expect(
          code.contains('DabblerFocusRing'),
          isTrue,
          reason: 'cpo §5.2 Principle 3 — one visible focus indicator, shared',
        );
        expect(
          RegExp(r'focusRing(Width|Offset)\s*=').hasMatch(code),
          isFalse,
          reason: 'the ring owns its own width and offset',
        );
      });
    });
  }
}
