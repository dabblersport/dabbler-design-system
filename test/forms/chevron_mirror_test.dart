import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dabbler_design_system/src/forms/input_row.dart';
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/foundations/icon_mirror.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';

const int _n = 48;

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

double _flippedDiff(Uint8List a, Uint8List b) {
  double sum = 0;
  for (int y = 0; y < _n; y++) {
    for (int x = 0; x < _n; x++) {
      sum += (a[y * _n + x] - b[y * _n + (_n - 1 - x)]).abs();
    }
  }
  return sum / (_n * _n);
}

Widget _host(TextDirection dir) => Directionality(
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
    child: const Center(child: DabblerChevron()),
  ),
);

Future<IconData> _drawn(WidgetTester t, TextDirection dir) async {
  await t.pumpWidget(_host(dir));
  return t.widget<Icon>(find.byType(Icon)).icon!;
}

void main() {
  testWidgets('the RTL chevron is a pixel mirror of the LTR chevron', (
    WidgetTester t,
  ) async {
    final IconData ltr = await _drawn(t, TextDirection.ltr);
    final IconData rtl = await _drawn(t, TextDirection.rtl);
    expect(ltr, isNot(rtl));
    expect(find.byType(Transform), findsNothing);
    late double mirrored;
    late double self;
    await t.runAsync(() async {
      await loadDesignSystemFonts();
      final Uint8List a = await _mask(ltr);
      final Uint8List b = await _mask(rtl);
      mirrored = _flippedDiff(a, b);
      self = _flippedDiff(a, a);
    });
    // Same bound as icon_mirror_test: near-zero, far below the glyph's own
    // left/right asymmetry.
    expect(mirrored, lessThan(1.5));
    expect(mirrored * 4, lessThan(self));
  });

  testWidgets('the LTR chevron points to the inline end', (
    WidgetTester t,
  ) async {
    final IconData ltr = await _drawn(t, TextDirection.ltr);
    late Uint8List m;
    await t.runAsync(() async {
      await loadDesignSystemFonts();
      m = await _mask(ltr);
    });
    // A `>` has its tip (rightmost ink) at mid-height.
    int rightmost(int y) {
      for (int x = _n - 1; x >= 0; x--) {
        if (m[y * _n + x] > 100) return x;
      }
      return -1;
    }

    final int mid = rightmost(_n ~/ 2);
    expect(mid, greaterThan(rightmost(_n ~/ 5)));
    expect(mid, greaterThan(rightmost(_n * 4 ~/ 5)));
  });

  test('the pair is the measured linear mirror pair', () {
    expect(DabblerChevron.forwardIconName, 'arrow-right-3');
    expect(DabblerChevron.backwardIconName, 'arrow-left-2');
    expect(
      DabblerIconMirror.pairFor(
        DabblerChevron.forwardIconName,
        DabblerIconWeight.linear,
      ),
      DabblerChevron.backwardIconName,
    );
  });
}
