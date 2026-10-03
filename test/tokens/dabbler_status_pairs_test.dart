import 'dart:math' as math;

import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('DabblerStatusPairs', () {
    test('tint is exactly surface + strong (no new colour)', () {
      for (final DabblerTheme theme in DabblerTheme.values) {
        for (final Brightness b in Brightness.values) {
          final DabblerColors c = DabblerColors.resolve(
            theme: theme,
            brightness: b,
          );
          for (final DabblerStatusTone tone in DabblerStatusTone.values) {
            final DabblerStatusColor s = c.status(tone);
            expect(s.tint.surface, s.surface);
            expect(s.tint.ink, s.strong);
            expect(c.statusTint(tone), s.tint);
          }
        }
      }
    });

    test('strong on surface clears AA 4.5:1 in all 14 resolutions', () {
      final Map<DabblerStatusTone, double> lowest = <DabblerStatusTone, double>{
        for (final DabblerStatusTone t in DabblerStatusTone.values)
          t: double.infinity,
      };
      for (final DabblerTheme theme in DabblerTheme.values) {
        for (final Brightness b in Brightness.values) {
          final DabblerColors c = DabblerColors.resolve(
            theme: theme,
            brightness: b,
          );
          for (final DabblerStatusTone tone in DabblerStatusTone.values) {
            final DabblerToneColor p = c.statusTint(tone);
            final double r = _contrast(p.ink, p.surface);
            lowest[tone] = math.min(lowest[tone]!, r);
            expect(
              r,
              greaterThanOrEqualTo(4.5),
              reason: '${theme.name}/${b.name}/${tone.name}: $r',
            );
          }
        }
      }
      // Recorded figure, for the docs page.
      // ignore: avoid_print
      print(
        'lowest strong-on-surface: '
        '${lowest.map((DabblerStatusTone k, double v) => MapEntry<String, String>(k.name, v.toStringAsFixed(2)))}',
      );
    });
  });
}
