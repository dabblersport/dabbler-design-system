import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dabbler_design_system/src/controls/button.dart';
import 'package:dabbler_design_system/src/navigation/top_bar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';

const int _n = 64;

/// Which way a circle-chevron glyph points, read from pixels: the chevron's
/// vertex row (the vertical middle) sits further toward the pointing side
/// than its arms do.
Future<AxisDirection> _pointing(IconData d) async {
  final ui.PictureRecorder rec = ui.PictureRecorder();
  final Canvas canvas = Canvas(rec);
  (TextPainter(
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
  )..layout()).paint(canvas, Offset.zero);
  final ui.Image img = await rec.endRecording().toImage(_n, _n);
  final ByteData bd = (await img.toByteData())!;
  double rowMeanX(int y) {
    double sx = 0, sw = 0;
    for (int x = 0; x < _n; x++) {
      final double dx = x - _n / 2, dy = y - _n / 2;
      if (dx * dx + dy * dy > (_n * 0.3) * (_n * 0.3)) continue; // inside ring
      final int a = bd.getUint8((y * _n + x) * 4 + 3);
      sx += a * x;
      sw += a;
    }
    return sw == 0 ? _n / 2 : sx / sw;
  }

  final double mid = rowMeanX(_n ~/ 2);
  final double arms =
      (rowMeanX((_n * 0.38).round()) + rowMeanX((_n * 0.62).round())) / 2;
  return mid < arms ? AxisDirection.left : AxisDirection.right;
}

Widget _host(Widget child, {TextDirection dir = TextDirection.ltr}) =>
    MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Directionality(
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
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: 390, child: child),
          ),
        ),
      ),
    );

void main() {
  group('titled back glyph direction', () {
    for (final TextDirection dir in TextDirection.values) {
      testWidgets('${dir.name}: points toward the inline start', (t) async {
        await t.pumpWidget(
          _host(
            DabblerNavigationTopBar.titled(
              title: 'Settings',
              onBack: () {},
              safeArea: false,
            ),
            dir: dir,
          ),
        );
        final Finder icon = find.byType(Icon);
        final IconData glyph = t.widget<Icon>(icon).icon!;
        late AxisDirection points;
        await t.runAsync(() async {
          await loadDesignSystemFonts();
          points = await _pointing(glyph);
        });
        // The button sits at the inline start; back points at that edge.
        final double iconX = t.getCenter(icon).dx;
        final double titleX = t.getCenter(find.text('Settings')).dx;
        if (dir == TextDirection.rtl) {
          expect(iconX, greaterThan(titleX));
          expect(points, AxisDirection.right);
        } else {
          expect(iconX, lessThan(titleX));
          expect(points, AxisDirection.left);
        }
      });
    }
  });

  group('DabblerNavigationAction.text', () {
    testWidgets('renders a text-tone button and fires', (t) async {
      int taps = 0;
      await t.pumpWidget(
        _host(
          DabblerNavigationTopBar.titled(
            title: 'Edit',
            onBack: () {},
            safeArea: false,
            actions: <DabblerNavigationAction>[
              DabblerNavigationAction.text(
                label: 'Save',
                onPressed: () => taps++,
              ),
            ],
          ),
        ),
      );
      final DabblerButton b = t.widget<DabblerButton>(
        find.byType(DabblerButton),
      );
      expect(b.tone, DabblerButtonTone.text);
      expect(find.text('Save'), findsOneWidget);
      await t.tap(find.text('Save'));
      expect(taps, 1);
      expect(
        t.getSize(find.byType(DabblerButton)).height,
        greaterThanOrEqualTo(DabblerSizing.touchTargetMin),
      );
    });

    testWidgets('a11y: button with the label, override and disabled', (
      t,
    ) async {
      final SemanticsHandle h = t.ensureSemantics();
      await t.pumpWidget(
        _host(
          DabblerNavigationTopBar.titled(
            title: 'Edit',
            safeArea: false,
            actions: <DabblerNavigationAction>[
              DabblerNavigationAction.text(
                label: 'Save',
                semanticLabel: 'Save profile',
                onPressed: () {},
              ),
              const DabblerNavigationAction.text(label: 'Done'),
            ],
          ),
        ),
      );
      final SemanticsData save = t
          .getSemantics(find.bySemanticsLabel('Save profile'))
          .getSemanticsData();
      expect(save.flagsCollection.isButton, isTrue);
      expect(save.hasAction(SemanticsAction.tap), isTrue);
      expect(find.bySemanticsLabel('Save'), findsNothing);
      final SemanticsData done = t
          .getSemantics(find.bySemanticsLabel('Done'))
          .getSemanticsData();
      expect(done.flagsCollection.isButton, isTrue);
      expect(done.flagsCollection.isEnabled.toBoolOrNull(), isFalse);
      expect(done.flagsCollection.isEnabled.toBoolOrNull(), isNotNull);
      h.dispose();
    });

    testWidgets('RTL: sits at the inline end, after the title', (t) async {
      await t.pumpWidget(
        _host(
          DabblerNavigationTopBar.titled(
            title: 'تعديل',
            onBack: () {},
            safeArea: false,
            actions: const <DabblerNavigationAction>[
              DabblerNavigationAction.text(label: 'حفظ'),
            ],
          ),
          dir: TextDirection.rtl,
        ),
      );
      expect(
        t.getCenter(find.text('حفظ')).dx,
        lessThan(t.getCenter(find.text('تعديل')).dx),
      );
    });

    test('equality and toString include the variant', () {
      const DabblerNavigationAction a = DabblerNavigationAction.text(
        label: 'Save',
      );
      expect(a, const DabblerNavigationAction.text(label: 'Save'));
      expect(
        a == const DabblerNavigationAction(icon: '', label: 'Save'),
        isFalse,
      );
      expect(a.toString(), 'DabblerNavigationAction.text(Save)');
    });
  });
}
