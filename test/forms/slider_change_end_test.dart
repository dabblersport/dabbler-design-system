import 'package:dabbler_design_system/src/forms/slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

/// DS gaps 6 item 3 — `onChangeEnd` fires once per committed interaction.
class _Single extends StatefulWidget {
  const _Single({required this.ends, required this.changes});
  final List<double> ends;
  final List<double> changes;
  @override
  State<_Single> createState() => _SingleState();
}

class _SingleState extends State<_Single> {
  double v = 50;
  @override
  Widget build(BuildContext context) => DabblerSlider(
    label: 'distance',
    value: v,
    onChanged: (double n) {
      widget.changes.add(n);
      setState(() => v = n);
    },
    onChangeEnd: widget.ends.add,
  );
}

class _Range extends StatefulWidget {
  const _Range({required this.ends});
  final List<DabblerSliderRange> ends;
  @override
  State<_Range> createState() => _RangeState();
}

class _RangeState extends State<_Range> {
  DabblerSliderRange v = const DabblerSliderRange(20, 80);
  @override
  Widget build(BuildContext context) => DabblerSlider.range(
    label: 'price',
    values: v,
    onChanged: (DabblerSliderRange n) => setState(() => v = n),
    onChangeEnd: widget.ends.add,
  );
}

Finder get _track => find.byType(GestureDetector).first;

void main() {
  for (final TextDirection direction in TextDirection.values) {
    final bool rtl = direction == TextDirection.rtl;
    group('DabblerSlider.onChangeEnd ($direction)', () {
      testWidgets('a tap fires onChanged then one onChangeEnd on release', (
        WidgetTester tester,
      ) async {
        final List<double> ends = <double>[];
        final List<double> changes = <double>[];
        await tester.pumpWidget(
          host(
            _Single(ends: ends, changes: changes),
            direction: direction,
          ),
        );
        final Rect r = tester.getRect(_track);
        // A quarter along the inline axis from the inline start.
        final double x = rtl ? r.right - r.width / 4 : r.left + r.width / 4;
        await tester.tapAt(Offset(x, r.center.dy));
        await tester.pump();
        expect(changes, isNotEmpty);
        expect(ends, <double>[changes.last]);
        expect(ends.single, closeTo(25, 1));
      });

      testWidgets('a drag fires onChangeEnd once, with the final value', (
        WidgetTester tester,
      ) async {
        final List<double> ends = <double>[];
        final List<double> changes = <double>[];
        await tester.pumpWidget(
          host(
            _Single(ends: ends, changes: changes),
            direction: direction,
          ),
        );
        final Rect r = tester.getRect(_track);
        final Offset from = r.center;
        final double dx = rtl ? -r.width / 4 : r.width / 4;
        await tester.dragFrom(from, Offset(dx, 0));
        await tester.pump();
        expect(changes.length, greaterThan(1));
        expect(ends, <double>[changes.last]);
        expect(ends.single, greaterThan(50));
      });

      testWidgets('each arrow key is its own commit', (
        WidgetTester tester,
      ) async {
        final List<double> ends = <double>[];
        final List<double> changes = <double>[];
        await tester.pumpWidget(
          host(
            _Single(ends: ends, changes: changes),
            direction: direction,
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        // The key that grows the fill under this direction.
        await tester.sendKeyEvent(
          rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight,
        );
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();
        expect(ends, <double>[51, 100]);
      });

      testWidgets('a semantics increase commits and ends', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        final List<double> ends = <double>[];
        final List<double> changes = <double>[];
        await tester.pumpWidget(
          host(
            _Single(ends: ends, changes: changes),
            direction: direction,
          ),
        );
        final SemanticsNode node = tester.getSemantics(
          find.bySemanticsLabel('distance'),
        );
        tester.binding.pipelineOwner.semanticsOwner!.performAction(
          node.id,
          SemanticsAction.increase,
        );
        await tester.pump();
        expect(ends, <double>[51]);
        handle.dispose();
      });

      testWidgets('range: release reports the ordered pair', (
        WidgetTester tester,
      ) async {
        final List<DabblerSliderRange> ends = <DabblerSliderRange>[];
        await tester.pumpWidget(host(_Range(ends: ends), direction: direction));
        final Rect r = tester.getRect(_track);
        // Near the inline end: the high thumb moves.
        final double x = rtl ? r.left + r.width * 0.1 : r.right - r.width * 0.1;
        await tester.tapAt(Offset(x, r.center.dy));
        await tester.pump();
        expect(ends.length, 1);
        expect(ends.single.low, 20);
        expect(ends.single.high, closeTo(90, 1));
      });
    });
  }

  testWidgets('a disabled slider never fires onChangeEnd', (
    WidgetTester tester,
  ) async {
    final List<double> ends = <double>[];
    await tester.pumpWidget(
      host(
        DabblerSlider(
          value: 10,
          disabled: true,
          onChanged: (_) {},
          onChangeEnd: ends.add,
        ),
      ),
    );
    await tester.tap(_track);
    await tester.pump();
    expect(ends, isEmpty);
  });

  testWidgets('onChanged alone keeps working (no onChangeEnd)', (
    WidgetTester tester,
  ) async {
    double? got;
    await tester.pumpWidget(
      host(DabblerSlider(value: 10, onChanged: (double v) => got = v)),
    );
    await tester.tap(_track);
    await tester.pump();
    expect(got, isNotNull);
  });
}
