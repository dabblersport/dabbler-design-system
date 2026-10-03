import 'dart:math' as math;

import 'package:dabbler_design_system/src/feedback/ring.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

final DabblerColors _colors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(Widget child, {TextDirection dir = TextDirection.ltr}) => Theme(
  data: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors]),
  child: Directionality(
    textDirection: dir,
    child: Align(alignment: Alignment.topLeft, child: child),
  ),
);

int _argb(Color c) => c.toARGB32();

class _Line {
  _Line(this.p1, this.p2, this.paint);
  final Offset p1;
  final Offset p2;
  final Paint paint;
}

class _Arc {
  _Arc(this.rect, this.start, this.sweep, this.paint);
  final Rect rect;
  final double start;
  final double sweep;
  final Paint paint;
}

class _SpyCanvas extends Fake implements Canvas {
  final List<_Line> lines = <_Line>[];
  final List<_Arc> arcs = <_Arc>[];
  final List<(double, Paint)> circles = <(double, Paint)>[];

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) =>
      lines.add(_Line(p1, p2, paint));

  @override
  void drawArc(Rect r, double s, double sw, bool c, Paint p) =>
      arcs.add(_Arc(r, s, sw, p));

  @override
  void drawCircle(Offset c, double r, Paint p) => circles.add((r, p));
}

_SpyCanvas _paint(WidgetTester tester) {
  final CustomPaint cp = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(DabblerRing),
      matching: find.byType(CustomPaint),
    ),
  );
  final _SpyCanvas spy = _SpyCanvas();
  cp.painter!.paint(spy, tester.getSize(find.byType(DabblerRing)));
  return spy;
}

void main() {
  group('ticks', () {
    testWidgets('paints count ticks; first round(f*count) are brand', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerRing.ticks(fraction: 0.4, diameter: 54)),
      );
      final _SpyCanvas spy = _paint(tester);
      expect(spy.lines, hasLength(24));
      final int filled = (0.4 * 24).round(); // 10
      for (int i = 0; i < 24; i++) {
        expect(
          _argb(spy.lines[i].paint.color),
          _argb(i < filled ? _colors.brandPrimary : _colors.borderDefault),
          reason: 'tick $i',
        );
        expect(spy.lines[i].paint.strokeWidth, DabblerRing.tickWidth);
      }
    });

    testWidgets('32 ticks, faint track role', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerRing.ticks(
            fraction: 0.75,
            count: 32,
            diameter: 54,
            track: DabblerRingTrack.faint,
          ),
        ),
      );
      final _SpyCanvas spy = _paint(tester);
      expect(spy.lines, hasLength(32));
      expect(
        spy.lines
            .where((l) => _argb(l.paint.color) == _argb(_colors.brandPrimary))
            .length,
        24,
      );
      expect(
        spy.lines
            .where((l) => _argb(l.paint.color) == _argb(_colors.bgTertiary))
            .length,
        8,
      );
    });

    testWidgets('starts at twelve o\'clock and runs clockwise', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerRing.ticks(fraction: 1, diameter: 60, count: 4)),
      );
      final _SpyCanvas spy = _paint(tester);
      const Offset c = Offset(30, 30);
      // Tick 0 is straight up, tick 1 a quarter turn clockwise (3 o'clock).
      expect((spy.lines[0].p1 - c).dx.abs(), lessThan(1e-9));
      expect(spy.lines[0].p2.dy, lessThan(c.dy));
      expect(spy.lines[1].p2.dx, greaterThan(c.dx));
      expect((spy.lines[1].p2 - c).dy.abs(), lessThan(1e-9));
    });

    testWidgets('tick outer end sits on the diameter; length is tickLength', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerRing.ticks(fraction: 0, diameter: 60)),
      );
      final _Line l = _paint(tester).lines.first;
      const Offset c = Offset(30, 30);
      // Endpoints are inset by half the width for the round caps, so the
      // capped tick spans exactly [outer - tickLength, outer].
      expect(
        (l.p2 - c).distance + DabblerRing.tickWidth / 2,
        closeTo(30, 1e-9),
      );
      expect(
        (l.p2 - l.p1).distance + DabblerRing.tickWidth,
        closeTo(DabblerSpacing.space2, 1e-9),
      );
      expect(l.paint.strokeCap, StrokeCap.round);
    });

    testWidgets('fraction clamps and NaN is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerRing.ticks(fraction: 3, diameter: 54)),
      );
      expect(
        _paint(tester).lines.every(
          (l) => _argb(l.paint.color) == _argb(_colors.brandPrimary),
        ),
        isTrue,
      );
      await tester.pumpWidget(
        _host(const DabblerRing.ticks(fraction: double.nan, diameter: 54)),
      );
      expect(
        _paint(tester).lines.every(
          (l) => _argb(l.paint.color) == _argb(_colors.borderDefault),
        ),
        isTrue,
      );
    });

    testWidgets('RTL does not mirror by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerRing.ticks(fraction: 1, diameter: 60, count: 4)),
      );
      final _SpyCanvas ltr = _paint(tester);
      await tester.pumpWidget(
        _host(
          const DabblerRing.ticks(fraction: 1, diameter: 60, count: 4),
          dir: TextDirection.rtl,
        ),
      );
      final _SpyCanvas rtl = _paint(tester);
      for (int i = 0; i < 4; i++) {
        expect(rtl.lines[i].p1, ltr.lines[i].p1);
        expect(rtl.lines[i].p2, ltr.lines[i].p2);
      }
    });

    testWidgets('mirrorInRtl runs counter-clockwise in RTL only', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerRing.ticks(
            fraction: 1,
            diameter: 60,
            count: 4,
            mirrorInRtl: true,
          ),
          dir: TextDirection.rtl,
        ),
      );
      final _SpyCanvas spy = _paint(tester);
      const Offset c = Offset(30, 30);
      // Tick 1 is now a quarter turn counter-clockwise: 9 o'clock.
      expect(spy.lines[1].p2.dx, lessThan(c.dx));

      await tester.pumpWidget(
        _host(
          const DabblerRing.ticks(
            fraction: 1,
            diameter: 60,
            count: 4,
            mirrorInRtl: true,
          ),
        ),
      );
      expect(_paint(tester).lines[1].p2.dx, greaterThan(c.dx));
    });
  });

  group('arc', () {
    testWidgets('track circle in faint, round-capped brand arc from the top', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerRing.arc(fraction: 0.25)));
      expect(
        tester.getSize(find.byType(DabblerRing)),
        const Size.square(DabblerRing.arcDefaultDiameter),
      );
      final _SpyCanvas spy = _paint(tester);
      expect(spy.circles, hasLength(1));
      expect(_argb(spy.circles.single.$2.color), _argb(_colors.bgTertiary));
      expect(
        spy.circles.single.$2.strokeWidth,
        DabblerRing.arcDefaultStrokeWidth,
      );
      expect(
        spy.circles.single.$1,
        (DabblerRing.arcDefaultDiameter - DabblerRing.arcDefaultStrokeWidth) /
            2,
      );
      expect(spy.arcs, hasLength(1));
      expect(_argb(spy.arcs.single.paint.color), _argb(_colors.brandPrimary));
      expect(spy.arcs.single.paint.strokeCap, StrokeCap.round);
      expect(spy.arcs.single.start, -math.pi / 2);
      expect(spy.arcs.single.sweep, closeTo(math.pi / 2, 1e-9));
    });

    testWidgets('zero draws no arc; full sweeps the circle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerRing.arc(fraction: 0)));
      expect(_paint(tester).arcs, isEmpty);
      await tester.pumpWidget(_host(const DabblerRing.arc(fraction: 2)));
      expect(_paint(tester).arcs.single.sweep, closeTo(2 * math.pi, 1e-9));
    });

    testWidgets('custom diameter and stroke; outline track role', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerRing.arc(
            fraction: 0.5,
            diameter: 60,
            strokeWidth: 9,
            track: DabblerRingTrack.outline,
          ),
        ),
      );
      final _SpyCanvas spy = _paint(tester);
      expect(spy.circles.single.$1, (60 - 9) / 2);
      expect(_argb(spy.circles.single.$2.color), _argb(_colors.borderDefault));
      expect(spy.arcs.single.paint.strokeWidth, 9);
    });

    testWidgets('RTL keeps clockwise; mirrorInRtl negates the sweep', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerRing.arc(fraction: 0.25), dir: TextDirection.rtl),
      );
      expect(_paint(tester).arcs.single.sweep, greaterThan(0));
      await tester.pumpWidget(
        _host(
          const DabblerRing.arc(fraction: 0.25, mirrorInRtl: true),
          dir: TextDirection.rtl,
        ),
      );
      expect(_paint(tester).arcs.single.sweep, closeTo(-math.pi / 2, 1e-9));
      await tester.pumpWidget(
        _host(const DabblerRing.arc(fraction: 0.25, mirrorInRtl: true)),
      );
      expect(_paint(tester).arcs.single.sweep, closeTo(math.pi / 2, 1e-9));
    });
  });

  group('child and semantics', () {
    testWidgets('centre child is laid out in the middle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerRing.ticks(
            fraction: 0.5,
            diameter: 60,
            child: SizedBox(key: Key('c'), width: 10, height: 10),
          ),
          dir: TextDirection.rtl,
        ),
      );
      expect(
        tester.getCenter(find.byKey(const Key('c'))),
        const Offset(30, 30),
      );
    });

    testWidgets('announces a percentage, overridable', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(const DabblerRing.arc(fraction: 0.654, semanticLabel: 'Profile')),
      );
      SemanticsNode node = tester.getSemantics(find.byType(DabblerRing));
      expect(node.value, '65%');
      expect(node.label, 'Profile');

      await tester.pumpWidget(
        _host(
          const DabblerRing.ticks(
            fraction: 0.5,
            diameter: 54,
            semanticLabel: 'Game starts',
            semanticValue: '3 days left',
          ),
        ),
      );
      node = tester.getSemantics(find.byType(DabblerRing));
      expect(node.value, '3 days left');
      handle.dispose();
    });
  });
}
