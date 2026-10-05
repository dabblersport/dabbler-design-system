import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// KAN-433 — `DabblerTabsVariant.feed`, the Home Feed's tab rail
/// (`home-design-measure.md` section 5): label-width tabs 21 apart, every
/// label at the regular weight, 10 under the label and a 3px brand underline
/// over the 1px `--faint` rail, edge to edge.
final DabblerColors _colors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

// The Arabic frame's own tab labels (`Home Feed.dc.html` dictionary).
const List<String> _arabic = <String>[
  'لك',
  'أتابعهم',
  'بالقرب',
  'نشط',
  'أخبار',
];
const List<String> _latin = <String>[
  'For you',
  'Following',
  'Nearby',
  'Active',
  'News',
];

Widget _host(
  List<String> labels, {
  required TextDirection direction,
  String? value,
  ValueChanged<String>? onChanged,
  DabblerTabsVariant variant = DabblerTabsVariant.feed,
  double width = 393,
}) => MediaQuery(
  data: const MediaQueryData(disableAnimations: true),
  child: Directionality(
    textDirection: direction,
    child: Theme(
      data: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors]),
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: DabblerTabs(
            variant: variant,
            scrollable: true,
            padding: DabblerInsets.feedScreen,
            value: value ?? 't0',
            onChanged: onChanged,
            items: <DabblerTabItem>[
              for (var i = 0; i < labels.length; i++)
                DabblerTabItem(id: 't$i', label: labels[i]),
            ],
          ),
        ),
      ),
    ),
  ),
);

void main() {
  for (final TextDirection dir in TextDirection.values) {
    final bool rtl = dir == TextDirection.rtl;
    final List<String> labels = rtl ? _arabic : _latin;

    group('feed — $dir', () {
      testWidgets('tabs are label-wide and 21 apart; the strip is 33 high '
          '(Latin) / 36 (Arabic leading 23)', (WidgetTester tester) async {
        await tester.pumpWidget(_host(labels, direction: dir));
        final Finder tabs = find.byType(DabblerExpandedHitArea);
        expect(tabs, findsNWidgets(5));
        for (var i = 0; i < 4; i++) {
          final Rect a = tester.getRect(tabs.at(i));
          final Rect b = tester.getRect(tabs.at(i + 1));
          expect(rtl ? a.left - b.right : b.left - a.right, closeTo(21, 0.01));
        }
        expect(tester.getSize(find.byType(DabblerTabs)).height, rtl ? 36 : 33);
      });

      testWidgets('the first tab starts at the 18 gutter, the rail does not', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_host(labels, direction: dir));
        final Rect first = tester.getRect(
          find.byType(DabblerExpandedHitArea).first,
        );
        final Rect strip = tester.getRect(find.byType(DabblerTabs));
        expect(strip.width, 393);
        if (rtl) {
          expect(393 - first.right, DabblerSpacing.space6);
        } else {
          expect(first.left, DabblerSpacing.space6);
        }
      });

      testWidgets('active and inactive differ by ink and underline only, not '
          'weight; the underline is 3px', (WidgetTester tester) async {
        await tester.pumpWidget(_host(labels, direction: dir, value: 't2'));
        await tester.pump();
        final Finder texts = find.descendant(
          of: find.byType(DabblerTabs),
          matching: find.byType(Text),
        );
        final List<FontWeight?> weights = <FontWeight?>[
          for (var i = 0; i < 5; i++)
            tester.widget<Text>(texts.at(i)).style!.fontWeight,
        ];
        expect(weights.toSet(), <FontWeight?>{DabblerType.regular});
        final Color active = tester.widget<Text>(texts.at(2)).style!.color!;
        final Color inactive = tester.widget<Text>(texts.at(0)).style!.color!;
        expect(active, _colors.textPrimary);
        expect(inactive, _colors.textSecondary);
        final Rect underline = tester.getRect(
          find.byType(AnimatedPositionedDirectional),
        );
        expect(underline.height, 3);
        final Rect tab = tester.getRect(
          find.byType(DabblerExpandedHitArea).at(2),
        );
        expect(underline.width, tab.width);
        expect(underline.bottom, tab.bottom);
      });

      testWidgets('a tap in the 45 target beside a narrow label selects it', (
        WidgetTester tester,
      ) async {
        String? picked;
        // Single glyphs: narrower than the 45 target in any face.
        await tester.pumpWidget(
          _host(
            rtl ? <String>['ل', 'ك', 'ن'] : <String>['A', 'B', 'N'],
            direction: dir,
            onChanged: (String id) => picked = id,
          ),
        );
        final Rect middle = tester.getRect(
          find.byType(DabblerExpandedHitArea).at(1),
        );
        // 4px past the end of the middle label, in the gap to the next tab,
        // is inside its 45 target.
        await tester.tapAt(
          Offset(rtl ? middle.left - 4 : middle.right + 4, middle.center.dy),
        );
        expect(picked, 't1');
      });
    });
  }

  testWidgets('underline stays exactly as it was (2px, 15 apart, 45 high)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        _latin,
        direction: TextDirection.ltr,
        variant: DabblerTabsVariant.underline,
      ),
    );
    await tester.pump();
    expect(tester.getSize(find.byType(DabblerTabs)).height, 45);
    expect(
      tester.getSize(find.byType(AnimatedPositionedDirectional)).height,
      2,
    );
  });
}
