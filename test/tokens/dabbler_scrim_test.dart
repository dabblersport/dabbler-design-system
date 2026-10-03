import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DabblerScrimColors', () {
    for (final DabblerTheme t in DabblerTheme.values) {
      for (final Brightness b in Brightness.values) {
        test('colorFor equals the resolved scrim (${t.name}, ${b.name})', () {
          final Color resolved =
              DabblerColors.resolve(theme: t, brightness: b).scrim;
          expect(DabblerScrimColors.colorFor(b), resolved);
          expect(DabblerScrim.colorFor(b), resolved);
          expect(
            b == Brightness.dark ? DabblerScrimColors.dark : DabblerScrimColors.light,
            resolved,
          );
        });
      }
    }

    test('light and dark are the palette values', () {
      expect(DabblerScrimColors.light, DabblerPalette.ink.withValues(alpha: 0.45));
      expect(DabblerScrimColors.dark, DabblerPalette.ink950.withValues(alpha: 0.65));
    });

    test('none and transparent are fully transparent', () {
      expect(DabblerScrimColors.none.a, 0);
      expect(DabblerScrimColors.transparent, DabblerScrimColors.none);
      expect(DabblerScrim.none, DabblerScrimColors.none);
      expect(DabblerScrim.transparent.a, 0);
    });
  });
}
