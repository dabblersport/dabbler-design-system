import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DabblerColors c(Brightness b) =>
      DabblerColors.resolve(theme: DabblerTheme.sport, brightness: b);

  group('detail tile tones — light is the existing static tones', () {
    test('amber, info, accent', () {
      final DabblerColors l = c(Brightness.light);
      expect(l.tileAmberTone, DabblerColors.tileAmber);
      expect(l.tileInfoTone, DabblerColors.tileInfo);
      expect(l.tileAccentTone, DabblerColors.tileAccent);
    });
  });

  group('detail tile tones — dark follows Details.dc.html 2026-10-08', () {
    final DabblerColors d = c(Brightness.dark);
    test('info is navy on pale blue', () {
      expect(d.tileInfoTone.surface, const Color(0xFF16243F));
      expect(d.tileInfoTone.ink, const Color(0xFFBFDBFE));
    });
    test('accent is maroon on pink', () {
      expect(d.tileAccentTone.surface, const Color(0xFF3A1A2A));
      expect(d.tileAccentTone.ink, const Color(0xFFF9C2DB));
    });
    test('ink is lifted grey on cream', () {
      expect(d.tileInkTone.surface, const Color(0xFF3A3A3A));
      expect(d.tileInkTone.ink, const Color(0xFFF5F0E6));
    });
    test('amber stays bright with dark ink', () {
      expect(d.tileAmberTone.surface, DabblerColors.tileAmber.surface);
      expect(d.tileAmberTone.ink, DabblerColors.tileAmber.ink);
    });
    test('sub ink is cream at 72%', () {
      expect(d.tileSubInk.a, closeTo(0.72, 0.01));
    });
  });
}
