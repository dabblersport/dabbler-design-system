import 'dart:io';
import 'dart:math' as math;

import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dabbler_palette_test.dart' show liveParityExceptions;

/// WCAG 2.x relative luminance of an opaque colour.
double _luminance(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double _contrast(Color a, Color b) {
  final double la = _luminance(a);
  final double lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// `--tag-pending-ink` is a named targeted override of live: live `#B4530E`
/// is 4.40:1 on `#FDEDE3` ("a real defect"), the package ships `#A34A08`
/// (5.20:1). Authority: `Dabbler/dabbler-docs/DECISIONS.md:11914-11919`,
/// ruling cdispatch-d92eff45 (reaffirmed cdispatch-5e71152a).
void main() {
  test('tagPendingInk is exactly #A34A08', () {
    expect(DabblerPalette.tagPendingInk, const Color(0xFFA34A08));
    expect(DabblerColors.tagPending.ink, DabblerPalette.tagPendingInk);
  });

  test('tagPendingInk clears AA (>= 4.5:1, ~5.20) on tagPendingSurface', () {
    final double ratio = _contrast(
      DabblerPalette.tagPendingInk,
      DabblerPalette.tagPendingSurface,
    );
    expect(ratio, greaterThanOrEqualTo(4.5));
    expect(ratio, closeTo(5.20, 0.02));
  });

  test(
    'the live value it replaces fails AA (4.40:1) — why the override exists',
    () {
      const Color live = Color(0xFFB4530E);
      expect(
        _contrast(live, DabblerPalette.tagPendingSurface),
        closeTo(4.40, 0.02),
      );
    },
  );

  test(
    'the live fixture still mirrors live #B4530E; divergence is deliberate',
    () {
      final String css = File(
        'test/fixtures/live/tokens/colors.css',
      ).readAsStringSync();
      expect(css, contains('--tag-pending-ink:#B4530E;'));
      expect(liveParityExceptions['tag-pending-ink'], (
        live: 'B4530E',
        package: 'A34A08',
      ));
    },
  );
}
