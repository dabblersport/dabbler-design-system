import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/foundations/icon_mirror.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../support/png_harness.dart';

const int _n = 48;

/// Alpha mask of one glyph drawn at [_n] px.
Future<Uint8List> _mask(IconData d) async {
  final ui.PictureRecorder rec = ui.PictureRecorder();
  final Canvas canvas = Canvas(rec);
  final TextPainter tp = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(d.codePoint),
      style: TextStyle(
        fontFamily: d.fontFamily,
        package: d.fontPackage,
        fontSize: _n.toDouble(),
        color: const Color(0xFF000000),
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, Offset.zero);
  final ui.Image img = await rec.endRecording().toImage(_n, _n);
  final ByteData bd = (await img.toByteData())!;
  final Uint8List out = Uint8List(_n * _n);
  for (int i = 0; i < _n * _n; i++) {
    out[i] = bd.getUint8(i * 4 + 3);
  }
  return out;
}

/// Mean absolute alpha difference between [a] flipped horizontally and [b].
double _flippedDiff(Uint8List a, Uint8List b) {
  double sum = 0;
  for (int y = 0; y < _n; y++) {
    for (int x = 0; x < _n; x++) {
      sum += (a[y * _n + x] - b[y * _n + (_n - 1 - x)]).abs();
    }
  }
  return sum / (_n * _n);
}

IconData _glyph(String name, DabblerIconWeight w) =>
    DabblerIconRegistry.resolve(name, weight: w).glyph!;

Widget _host(Widget child, TextDirection dir) => Directionality(
  textDirection: dir,
  child: Theme(
    data: ThemeData(
      extensions: <ThemeExtension<dynamic>>[
        DabblerColors.resolve(
          theme: DabblerTheme.main,
          brightness: Brightness.light,
        ),
      ],
    ),
    child: Center(child: child),
  ),
);

void main() {
  group('pair table is measured, not assumed', () {
    for (final DabblerIconWeight w in DabblerIconWeight.values) {
      testWidgets('every ${w.name} pair is a pixel mirror', (t) async {
        final List<String> bad = <String>[];
        await t.runAsync(() async {
          await loadDesignSystemFonts();
          for (final MapEntry<String, String> e in DabblerIconMirror.pairsFor(
            w,
          ).entries) {
            // Both sides resolve at this weight without a fallback.
            for (final String n in <String>[e.key, e.value]) {
              expect(
                DabblerIconRegistry.resolve(n, weight: w).outcome,
                DabblerIconOutcome.resolved,
                reason: '$n @ ${w.name}',
              );
            }
            final Uint8List a = await _mask(_glyph(e.key, w));
            final Uint8List b = await _mask(_glyph(e.value, w));
            final double mirrored = _flippedDiff(a, b);
            final double self = _flippedDiff(a, a);
            // A true mirror is near-zero and far below the glyph's own
            // asymmetry; 1.5 allows the 1px offset of the chevron pair.
            if (mirrored > 1.5 || mirrored * 4 > self) {
              bad.add('${e.key}<->${e.value}: $mirrored (self $self)');
            }
          }
        });
        expect(bad, isEmpty);
      });
    }

    test('pairFor looks up both sides and returns null off-table', () {
      expect(
        DabblerIconMirror.pairFor('arrow-left', DabblerIconWeight.linear),
        'arrow-right-1',
      );
      expect(
        DabblerIconMirror.pairFor('arrow-right-1', DabblerIconWeight.linear),
        'arrow-left',
      );
      expect(
        DabblerIconMirror.pairFor('arrow-left-2', DabblerIconWeight.bold),
        'arrow-right',
      );
      expect(
        DabblerIconMirror.pairFor('home-2', DabblerIconWeight.linear),
        isNull,
      );
    });
  });

  group('DabblerIcon.mirrorInRtl', () {
    IconData? drawn(WidgetTester t) => t.widget<Icon>(find.byType(Icon)).icon;

    testWidgets('default false: RTL draws the name as given', (t) async {
      await t.pumpWidget(
        _host(const DabblerIcon('arrow-circle-left'), TextDirection.rtl),
      );
      expect(drawn(t), Iconsax.arrow_circle_left_copy);
      expect(find.byType(Transform), findsNothing);
    });

    testWidgets('LTR is unchanged when mirroring is on', (t) async {
      await t.pumpWidget(
        _host(
          const DabblerIcon('arrow-circle-left', mirrorInRtl: true),
          TextDirection.ltr,
        ),
      );
      expect(drawn(t), Iconsax.arrow_circle_left_copy);
    });

    testWidgets('RTL swaps to the measured pair at the same weight', (t) async {
      await t.pumpWidget(
        _host(
          const DabblerIcon('arrow-left-2', mirrorInRtl: true),
          TextDirection.rtl,
        ),
      );
      expect(drawn(t), Iconsax.arrow_right_3_copy);
      await t.pumpWidget(
        _host(
          const DabblerIcon(
            'arrow-left-2',
            mirrorInRtl: true,
            weight: DabblerIconWeight.bold,
          ),
          TextDirection.rtl,
        ),
      );
      expect(drawn(t), Iconsax.arrow_right);
      expect(find.byType(Transform), findsNothing);
    });

    testWidgets('RTL with no pair flips horizontally', (t) async {
      await t.pumpWidget(
        _host(
          const DabblerIcon('send-2', mirrorInRtl: true),
          TextDirection.rtl,
        ),
      );
      expect(drawn(t), Iconsax.send_2_copy);
      final Transform flip = t.widget<Transform>(find.byType(Transform));
      expect(flip.transform.storage[0], -1);
    });

    testWidgets('semantics label survives mirroring', (t) async {
      final SemanticsHandle h = t.ensureSemantics();
      await t.pumpWidget(
        _host(
          const DabblerIcon(
            'arrow-left',
            mirrorInRtl: true,
            semanticLabel: 'Back',
          ),
          TextDirection.rtl,
        ),
      );
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      h.dispose();
    });
  });
}
