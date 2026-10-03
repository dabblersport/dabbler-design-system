import 'package:dabbler_design_system/src/layout/tabs.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// DS gaps 6 item 8 — segmented labels never truncate under
/// [DabblerTabsLabelFit.fit]. The test font draws every glyph one em wide,
/// so the widths below are exact: Arabic at 14.1 / Latin at 15 per glyph.

// Short enough to fit by scaling down (4 glyphs each).
const List<DabblerTabItem> _arShort = <DabblerTabItem>[
  DabblerTabItem(id: 'a', label: 'الكل'),
  DabblerTabItem(id: 'b', label: 'قادم'),
  DabblerTabItem(id: 'c', label: 'سابق'),
];

// Too long even at the footnote floor (9+ glyphs): must scroll.
const List<DabblerTabItem> _arLong = <DabblerTabItem>[
  DabblerTabItem(id: 'a', label: 'المباريات'),
  DabblerTabItem(id: 'b', label: 'اللقاءات القادمة'),
  DabblerTabItem(id: 'c', label: 'الملاعب'),
];

const List<DabblerTabItem> _enShort = <DabblerTabItem>[
  DabblerTabItem(id: 'a', label: 'Game'),
  DabblerTabItem(id: 'b', label: 'Meet'),
  DabblerTabItem(id: 'c', label: 'Park'),
];

const List<DabblerTabItem> _enLong = <DabblerTabItem>[
  DabblerTabItem(id: 'a', label: 'Games nearby'),
  DabblerTabItem(id: 'b', label: 'Meetups this week'),
  DabblerTabItem(id: 'c', label: 'Venues'),
];

Widget _host(Widget child, TextDirection direction, {double width = 300}) =>
    MediaQuery(
      data: const MediaQueryData(),
      child: Directionality(
        textDirection: direction,
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
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    );

Widget _tabs(
  List<DabblerTabItem> items, {
  DabblerTabsLabelFit fit = DabblerTabsLabelFit.fit,
  ValueChanged<String>? onChanged,
  String value = 'a',
}) => DabblerTabs(
  variant: DabblerTabsVariant.segmented,
  items: items,
  value: value,
  onChanged: onChanged ?? (_) {},
  labelFit: fit,
);

bool _truncated(WidgetTester tester, String label) =>
    tester.renderObject<RenderParagraph>(find.text(label)).didExceedMaxLines;

double _fontSize(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style!.fontSize!;

void main() {
  for (final TextDirection direction in TextDirection.values) {
    final bool rtl = direction == TextDirection.rtl;
    final List<DabblerTabItem> short = rtl ? _arShort : _enShort;
    final List<DabblerTabItem> long = rtl ? _arLong : _enLong;
    final double base = DabblerType.subheadline
        .resolveForDirection(direction)
        .fontSize!;
    final double floor = DabblerType.footnote
        .resolveForDirection(direction)
        .fontSize!;

    group('segmented label fit ($direction)', () {
      testWidgets('reproduction: the default ellipsis truncates a long label', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(_tabs(long, fit: DabblerTabsLabelFit.ellipsis), direction),
        );
        expect(_truncated(tester, long[1].label), isTrue);
      });

      testWidgets('fit scales a slightly long set down, uniformly, above the '
          'floor, with no truncation', (WidgetTester tester) async {
        await tester.pumpWidget(_host(_tabs(short), direction, width: 270));
        final double size = _fontSize(tester, short[0].label);
        expect(size, lessThan(base));
        expect(size, greaterThanOrEqualTo(floor));
        for (final DabblerTabItem item in short) {
          expect(_fontSize(tester, item.label), size);
          expect(_truncated(tester, item.label), isFalse);
        }
        expect(find.byType(SingleChildScrollView), findsNothing);
      });

      testWidgets('fit leaves labels that fit at full size', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_host(_tabs(short), direction, width: 400));
        expect(_fontSize(tester, short[0].label), base);
      });

      testWidgets('below the floor the track scrolls instead of truncating', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_host(_tabs(long), direction));
        expect(find.byType(SingleChildScrollView), findsOneWidget);
        for (final DabblerTabItem item in long) {
          expect(_fontSize(tester, item.label), closeTo(floor, 0.001));
          expect(_truncated(tester, item.label), isFalse);
        }
        expect(tester.takeException(), isNull);
        // The first segment starts at the inline start of the track.
        final Rect strip = tester.getRect(find.byType(DabblerTabs));
        final Rect first = tester.getRect(find.text(long[0].label));
        if (rtl) {
          expect(first.right, lessThanOrEqualTo(strip.right));
          expect(first.right, greaterThan(strip.center.dx));
        } else {
          expect(first.left, lessThan(strip.center.dx));
        }
      });

      testWidgets('scrolling mode keeps the selected segment in view and keys '
          'still move', (WidgetTester tester) async {
        String value = 'a';
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => _host(
              _tabs(
                long,
                value: value,
                onChanged: (String v) => setState(() => value = v),
              ),
              direction,
            ),
          ),
        );
        await tester.tap(find.text(long[0].label));
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pumpAndSettle();
        expect(value, 'c');
        final Rect strip = tester.getRect(find.byType(DabblerTabs));
        final Rect last = tester.getRect(find.text(long[2].label));
        expect(last.left, greaterThanOrEqualTo(strip.left - 0.5));
        expect(last.right, lessThanOrEqualTo(strip.right + 0.5));
      });

      testWidgets('tabs keep their semantics under fit', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        await tester.pumpWidget(_host(_tabs(long), direction));
        expect(
          tester.getSemantics(find.bySemanticsLabel(long[1].label)),
          matchesSemantics(
            label: long[1].label,
            hasSelectedState: true,
            hasTapAction: true,
          ),
        );
        handle.dispose();
      });
    });
  }

  test('dabblerTabsFit is a no-op for an empty list or unbounded width', () {
    expect(
      dabblerTabsFit(
        labels: const <String>[],
        width: 100,
        direction: TextDirection.ltr,
        textScaler: TextScaler.noScaling,
      ).scale,
      1,
    );
    expect(
      dabblerTabsFit(
        labels: const <String>['a'],
        width: double.infinity,
        direction: TextDirection.ltr,
        textScaler: TextScaler.noScaling,
      ).scroll,
      isFalse,
    );
  });
}
