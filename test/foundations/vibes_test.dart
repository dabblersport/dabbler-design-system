import 'dart:io';
import 'dart:math' as math;

import 'package:dabbler_design_system/src/foundations/vibes.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// One design vibe: its hex in `Post.dc.html` and the palette constant it maps
/// to. The hex is a string, never a `Color` — the design value is evidence,
/// not a token.
class _Row {
  const _Row(this.vibe, this.designHex, this.palette);
  final DabblerVibe vibe;
  final String designHex;
  final Color palette;
}

const List<_Row> _rows = <_Row>[
  _Row(DabblerVibe.supportive, '#6AC47E', DabblerPalette.sportS600),
  _Row(DabblerVibe.caring, '#F7A6C5', DabblerPalette.activeP300),
  _Row(DabblerVibe.loving, '#E94F4F', DabblerPalette.activeError),
  _Row(DabblerVibe.inspired, '#FFD166', DabblerPalette.tileAmberSurface),
  _Row(DabblerVibe.proud, '#F4A261', DabblerPalette.brightP600),
  _Row(DabblerVibe.hopeful, '#FFB703', DabblerPalette.warning500),
  _Row(DabblerVibe.nostalgic, '#A8A8FF', DabblerPalette.socialP300),
  _Row(DabblerVibe.positive, '#57CC99', DabblerPalette.sportS400),
  _Row(DabblerVibe.loved, '#F28482', DabblerPalette.activeError),
  _Row(DabblerVibe.supported, '#80ED99', DabblerPalette.sportS400),
  _Row(DabblerVibe.amazed, '#FFD166', DabblerPalette.tileAmberSurface),
  _Row(DabblerVibe.happy, '#FFE066', DabblerPalette.tileAmberSurface),
  _Row(DabblerVibe.calm, '#4EA8DE', DabblerPalette.socialS600),
  _Row(DabblerVibe.relaxed, '#A2D2FF', DabblerPalette.socialS400),
  _Row(DabblerVibe.thankful, '#FFE45C', DabblerPalette.tileAmberSurface),
  _Row(DabblerVibe.surprised, '#F3722C', DabblerPalette.spotlight500),
  _Row(DabblerVibe.energetic, '#F94144', DabblerPalette.error500),
  _Row(DabblerVibe.determined, '#F3722C', DabblerPalette.spotlight500),
  _Row(DabblerVibe.motivated, '#E76F51', DabblerPalette.spotlight500),
  _Row(DabblerVibe.focused, '#118AB2', DabblerPalette.socialS700),
  _Row(DabblerVibe.excited, '#FB8500', DabblerPalette.warning500),
  _Row(DabblerVibe.empowered, '#FF7E67', DabblerPalette.spotlight500),
  _Row(DabblerVibe.heroic, '#E63946', DabblerPalette.activeError),
  _Row(DabblerVibe.brave, '#F77F00', DabblerPalette.warning500),
  _Row(DabblerVibe.recognized, '#FFD700', DabblerPalette.tileAmberSurface),
  _Row(DabblerVibe.kind, '#FFB5A7', DabblerPalette.error100),
  _Row(DabblerVibe.sympathetic, '#A2D2FF', DabblerPalette.socialS400),
  _Row(DabblerVibe.together, '#70E000', DabblerPalette.success500),
  _Row(DabblerVibe.free, '#ADE8F4', DabblerPalette.tagProgressSurface),
  _Row(DabblerVibe.reflective, '#9D4EDD', DabblerPalette.mainP400),
  _Row(DabblerVibe.grateful, '#FFD166', DabblerPalette.tileAmberSurface),
  _Row(DabblerVibe.longing, '#C0A9BD', DabblerPalette.ink300),
  _Row(DabblerVibe.broken, '#8D99AE', DabblerPalette.ink400),
  _Row(DabblerVibe.unique, '#FFAFCC', DabblerPalette.activeP300),
  _Row(DabblerVibe.heard, '#84A59D', DabblerPalette.sportP300),
  _Row(DabblerVibe.grounded, '#588157', DabblerPalette.sportS700),
  _Row(DabblerVibe.awake, '#F9C74F', DabblerPalette.tileAmberSurface),
  _Row(DabblerVibe.jittery, '#F8961E', DabblerPalette.warning500),
  _Row(DabblerVibe.exploring, '#06D6A0', DabblerPalette.success500),
  _Row(DabblerVibe.orbiting, '#577590', DabblerPalette.socialP600),
  _Row(DabblerVibe.aligned, '#90BE6D', DabblerPalette.sportS600),
  _Row(DabblerVibe.stellar, '#FFD166', DabblerPalette.tileAmberSurface),
  _Row(DabblerVibe.celestial, '#6D597A', DabblerPalette.ink600),
  _Row(DabblerVibe.solar, '#FFB703', DabblerPalette.warning500),
  _Row(DabblerVibe.lunar, '#CDB4DB', DabblerPalette.ink300),
  _Row(DabblerVibe.unearthly, '#8338EC', DabblerPalette.tagSubmittedInk),
  _Row(DabblerVibe.blessed, '#F9C74F', DabblerPalette.tileAmberSurface),
  _Row(DabblerVibe.fortunate, '#90EE90', DabblerPalette.sportS400),
  _Row(DabblerVibe.wishing, '#A29BFE', DabblerPalette.mainP300),
  _Row(DabblerVibe.manifesting, '#FF9F1C', DabblerPalette.warning500),
  _Row(DabblerVibe.resplendent, '#7209B7', DabblerPalette.mainP700),
  _Row(DabblerVibe.mistyEyed, '#CDB4DB', DabblerPalette.ink300),
  _Row(DabblerVibe.still, '#BDE0FE', DabblerPalette.info100),
  _Row(DabblerVibe.muted, '#DEE2E6', DabblerPalette.tagExpiredSurface),
  _Row(DabblerVibe.wilting, '#9D8189', DabblerPalette.ink400),
  _Row(DabblerVibe.fading, '#A5A58D', DabblerPalette.sportP300),
  _Row(DabblerVibe.restless, '#FF8C42', DabblerPalette.brightP600),
  _Row(DabblerVibe.regretful, '#8E9AAF', DabblerPalette.ink400),
  _Row(DabblerVibe.rusty, '#B08968', DabblerPalette.brightP700),
  _Row(DabblerVibe.layered, '#CDB4DB', DabblerPalette.ink300),
  _Row(DabblerVibe.creative, '#FF70A6', DabblerPalette.activeP400),
  _Row(DabblerVibe.innovative, '#118AB2', DabblerPalette.socialS700),
  _Row(DabblerVibe.gameOn, '#F94144', DabblerPalette.error500),
  _Row(DabblerVibe.lastCall, '#FF7B00', DabblerPalette.spotlight500),
  _Row(DabblerVibe.kickoffReady, '#43AA8B', DabblerPalette.sportP400),
  _Row(DabblerVibe.almostFull, '#F9C74F', DabblerPalette.tileAmberSurface),
  _Row(DabblerVibe.joinFast, '#E76F51', DabblerPalette.spotlight500),
  _Row(DabblerVibe.finalWhistle, '#F8961E', DabblerPalette.warning500),
  _Row(DabblerVibe.warmingUp, '#F3722C', DabblerPalette.spotlight500),
  _Row(DabblerVibe.getMoving, '#00B4D8', DabblerPalette.socialS400),
  _Row(DabblerVibe.letsRally, '#90BE6D', DabblerPalette.sportS600),
  _Row(DabblerVibe.squadAssemble, '#7209B7', DabblerPalette.mainP700),
  _Row(DabblerVibe.gameTime, '#FFD166', DabblerPalette.tileAmberSurface),
  _Row(DabblerVibe.openSlot, '#4CC9F0', DabblerPalette.socialS400),
  _Row(DabblerVibe.lateEntry, '#F8961E', DabblerPalette.warning500),
  _Row(DabblerVibe.countdown, '#FB5607', DabblerPalette.spotlight500),
  _Row(DabblerVibe.hustleUp, '#E63946', DabblerPalette.activeError),
  _Row(DabblerVibe.letsGo, '#FF006E', DabblerPalette.activeS600),
  _Row(DabblerVibe.allIn, '#3A86FF', DabblerPalette.info500),
  _Row(DabblerVibe.bringItOn, '#F72585', DabblerPalette.activeS400),
  _Row(DabblerVibe.underway, '#FFB703', DabblerPalette.warning500),
  _Row(DabblerVibe.lockingIn, '#577590', DabblerPalette.socialP600),
  _Row(DabblerVibe.drained, '#9CA3AF', DabblerPalette.ink400),
  _Row(DabblerVibe.heavy, '#4B5563', DabblerPalette.tagExpiredInk),
  _Row(DabblerVibe.offDay, '#94A3B8', DabblerPalette.ink400),
  _Row(DabblerVibe.underPressure, '#F59E0B', DabblerPalette.warning500),
  _Row(DabblerVibe.tense, '#E56B6F', DabblerPalette.activeError),
  _Row(DabblerVibe.shaky, '#CBD5F5', DabblerPalette.info100),
  _Row(DabblerVibe.disconnected, '#6C757D', DabblerPalette.ink500),
  _Row(DabblerVibe.leftOut, '#A27B9D', DabblerPalette.activeP400),
  _Row(DabblerVibe.lonely, '#5C677D', DabblerPalette.tagExpiredInk),
  _Row(DabblerVibe.disappointed, '#9E768F', DabblerPalette.activeP400),
  _Row(DabblerVibe.uncertain, '#B5C3D9', DabblerPalette.ink300),
  _Row(DabblerVibe.sluggish, '#C9ADA7', DabblerPalette.ink300),
  _Row(DabblerVibe.flat, '#B0BEC5', DabblerPalette.ink300),
  _Row(DabblerVibe.numb, '#7F8C99', DabblerPalette.ink400),
  _Row(DabblerVibe.overthinking, '#C77DFF', DabblerPalette.mainP300),
  _Row(DabblerVibe.benched, '#8D99AE', DabblerPalette.ink400),
  _Row(DabblerVibe.slipping, '#F77F81', DabblerPalette.activeError),
  _Row(DabblerVibe.burnedOut, '#CC7A7A', DabblerPalette.activeError),
  _Row(DabblerVibe.frustrated, '#EF4444', DabblerPalette.error500),
  _Row(DabblerVibe.annoyed, '#E07A5F', DabblerPalette.spotlight500),
  _Row(DabblerVibe.angry, '#D7263D', DabblerPalette.tagFailedInk),
  _Row(DabblerVibe.irritated, '#F4A259', DabblerPalette.brightP600),
  _Row(DabblerVibe.salty, '#F9844A', DabblerPalette.spotlight500),
  _Row(DabblerVibe.rattled, '#F97316', DabblerPalette.spotlight500),
  _Row(DabblerVibe.onEdge, '#F59E0B', DabblerPalette.warning500),
  _Row(DabblerVibe.heated, '#E63946', DabblerPalette.activeError),
  _Row(DabblerVibe.clashing, '#9D4EDD', DabblerPalette.mainP400),
  _Row(DabblerVibe.snappy, '#FB5607', DabblerPalette.spotlight500),
  _Row(DabblerVibe.boilingOver, '#D00000', DabblerPalette.tagFailedInk),
  _Row(DabblerVibe.resentful, '#6B7280', DabblerPalette.ink500),
  _Row(DabblerVibe.tilted, '#C1121F', DabblerPalette.tagFailedInk),
  _Row(DabblerVibe.shortFused, '#F97373', DabblerPalette.activeError),
  _Row(DabblerVibe.fedUp, '#8D99AE', DabblerPalette.ink400),
  _Row(DabblerVibe.overloaded, '#BC6C25', DabblerPalette.tagPendingInk),
  _Row(DabblerVibe.stressed, '#F2A2A2', DabblerPalette.activeP300),
  _Row(DabblerVibe.boomerangThoughts, '#9A8C98', DabblerPalette.ink400),
  _Row(DabblerVibe.neutral, '#000000', DabblerPalette.ink),
];

double _rgbDistance(String hex, Color c) {
  final int v = int.parse(hex.substring(1), radix: 16);
  final double dr = ((v >> 16) & 0xFF) - c.r * 255;
  final double dg = ((v >> 8) & 0xFF) - c.g * 255;
  final double db = (v & 0xFF) - c.b * 255;
  return math.sqrt(dr * dr + dg * dg + db * db);
}

void main() {
  test('the table covers every enum value exactly once', () {
    expect(_rows.length, DabblerVibe.values.length);
    expect(_rows.map((_Row r) => r.vibe).toSet(), DabblerVibe.values.toSet());
    expect(DabblerVibe.values.length, 119);
  });

  test('every vibe accent equals its chosen palette constant', () {
    for (final _Row r in _rows) {
      expect(r.vibe.accent, r.palette, reason: r.vibe.key);
    }
  });

  test('every accent is a DabblerPalette value, not a free colour', () {
    final String source = File(
      'lib/src/tokens/dabbler_palette.dart',
    ).readAsStringSync();
    final Set<int> palette = RegExp(r'Color\(0xFF([0-9A-Fa-f]{6})\)')
        .allMatches(source)
        .map((RegExpMatch m) => 0xFF000000 | int.parse(m.group(1)!, radix: 16))
        .toSet();
    for (final DabblerVibe v in DabblerVibe.values) {
      expect(palette, contains(v.accent.toARGB32()), reason: v.key);
    }
  });

  test('every mapping stays within the documented distance of the design', () {
    // The worst case is Get Moving (#00B4D8), RGB distance 146.7, ΔE2000 16.6.
    for (final _Row r in _rows) {
      expect(
        _rgbDistance(r.designHex, r.palette),
        lessThan(150),
        reason: r.vibe.key,
      );
    }
  });

  test('vibes.dart declares no colour literal', () {
    final String code = File('lib/src/foundations/vibes.dart')
        .readAsLinesSync()
        .where((String l) => !l.trimLeft().startsWith('//'))
        .join('\n');
    expect(code.contains('Color(0x'), isFalse);
    expect(RegExp(r'(?<![A-Za-z])Colors\.').hasMatch(code), isFalse);
  });

  test('keys are unique kebab-case and round-trip', () {
    final Set<String> seen = <String>{};
    for (final DabblerVibe v in DabblerVibe.values) {
      expect(RegExp(r'^[a-z]+(-[a-z]+)*$').hasMatch(v.key), isTrue);
      expect(seen.add(v.key), isTrue, reason: v.key);
      expect(DabblerVibe.fromKey(v.key), v);
    }
    expect(DabblerVibe.fromKey('nope'), isNull);
  });

  test('context counts match the design', () {
    expect(DabblerVibe.forContext(DabblerVibeContext.dab).isNotEmpty, isTrue);
    expect(
      DabblerVibe.forContext(
        DabblerVibeContext.dab,
      ).every((DabblerVibe v) => v.contexts.contains(DabblerVibeContext.dab)),
      isTrue,
    );
  });

  group('resolve', () {
    for (final Brightness b in Brightness.values) {
      test('is built from the card surface and ink in $b', () {
        final DabblerColors c = DabblerColors.resolve(
          theme: DabblerTheme.main,
          brightness: b,
        );
        for (final DabblerVibe v in DabblerVibe.values) {
          final DabblerVibeColors t = v.resolve(c);
          expect(t.accent, v.accent);
          expect(t.ink, c.textPrimary);
          expect(
            t.surface,
            Color.alphaBlend(v.accent.withValues(alpha: 0.16), c.surfaceCard),
          );
          expect(t.selectedSurface == t.surface, isFalse, reason: v.key);
        }
      });
    }

    test('dark and light differ only through the card surface', () {
      final DabblerColors l = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      final DabblerColors d = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.dark,
      );
      final DabblerVibeColors a = DabblerVibe.angry.resolve(l);
      final DabblerVibeColors b = DabblerVibe.angry.resolve(d);
      expect(a.accent, b.accent);
      expect(a.surface == b.surface, isFalse);
    });
  });
}
