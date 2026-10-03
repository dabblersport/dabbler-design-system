// KAN-411 items 2, 3, 6: DSG-NEW-001 (create-menu iconTone + upright action),
// DSG-NEW-002 (ProgressBar onBrand tone), DSG-NEW-009 (Badge.dot).
import 'package:dabbler_design_system/src/feedback/progress_bar.dart';
import 'package:dabbler_design_system/src/navigation/bottom_bar.dart';
import 'package:dabbler_design_system/src/surfaces/badge.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DabblerColors _colors() => DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 390,
}) {
  return MediaQuery(
    data: const MediaQueryData(disableAnimations: true),
    child: Directionality(
      textDirection: direction,
      child: Theme(
        data: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors()]),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}

const List<DabblerNavigationCreateItem> _toned = <DabblerNavigationCreateItem>[
  DabblerNavigationCreateItem(
    id: 'a',
    icon: 'edit-2',
    label: 'A',
    iconTone: DabblerNavigationIconTone.info,
  ),
  DabblerNavigationCreateItem(
    id: 'b',
    icon: 'game',
    label: 'B',
    iconTone: DabblerNavigationIconTone.success,
  ),
  DabblerNavigationCreateItem(
    id: 'c',
    icon: 'people',
    label: 'C',
    iconTone: DabblerNavigationIconTone.accent,
  ),
];

/// Every BoxDecoration colour painted under the bar.
Set<Color?> _plateColors(WidgetTester tester) => tester
    .widgetList<Container>(find.byType(Container))
    .map((Container c) => (c.decoration as BoxDecoration?)?.color)
    .toSet();

double _actionTurns(WidgetTester tester) =>
    tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns;

void main() {
  group('DSG-NEW-001 — create-menu iconTone', () {
    test('each tone resolves to an existing colour role', () {
      final DabblerColors c = _colors();
      expect(
        dabblerNavigationIconPlateFor(DabblerNavigationIconTone.neutral, c),
        c.surfaceSunken,
      );
      expect(
        dabblerNavigationIconPlateFor(DabblerNavigationIconTone.info, c),
        DabblerColors.tileInfo.surface,
      );
      expect(
        dabblerNavigationIconPlateFor(DabblerNavigationIconTone.success, c),
        c.success.surface,
      );
      expect(
        dabblerNavigationIconPlateFor(DabblerNavigationIconTone.accent, c),
        DabblerColors.tileAccent.surface,
      );
      expect(
        dabblerNavigationIconPlateFor(DabblerNavigationIconTone.amber, c),
        DabblerColors.tileAmber.surface,
      );
    });

    test('default is neutral, and iconTone takes part in equality', () {
      const DabblerNavigationCreateItem a = DabblerNavigationCreateItem(
        id: 'x',
        icon: 'game',
        label: 'X',
      );
      expect(a.iconTone, DabblerNavigationIconTone.neutral);
      const DabblerNavigationCreateItem b = DabblerNavigationCreateItem(
        id: 'x',
        icon: 'game',
        label: 'X',
        iconTone: DabblerNavigationIconTone.info,
      );
      expect(a == b, isFalse);
    });

    testWidgets('default menu paints only the neutral plate (no change)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerNavigationBottomBar(
            safeArea: false,
            defaultMenuOpen: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final Set<Color?> plates = _plateColors(tester);
      expect(plates, contains(_colors().surfaceSunken));
      expect(plates, isNot(contains(DabblerColors.tileInfo.surface)));
    });

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('toned plates paint in ${dir.name}', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(
            const DabblerNavigationBottomBar(
              safeArea: false,
              defaultMenuOpen: true,
              createItems: _toned,
            ),
            direction: dir,
          ),
        );
        await tester.pumpAndSettle();
        final DabblerColors c = _colors();
        expect(
          _plateColors(tester),
          containsAll(<Color>[
            DabblerColors.tileInfo.surface,
            c.success.surface,
            DabblerColors.tileAccent.surface,
          ]),
        );
        // First tile sits at the inline start: left in LTR, right in RTL.
        final double a = tester.getCenter(find.text('A')).dx;
        final double cx = tester.getCenter(find.text('C')).dx;
        expect(dir == TextDirection.ltr ? a < cx : a > cx, isTrue);
      });
    }

    testWidgets(
      'action rotates by default; rotateActionOnOpen:false holds it',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(
            const DabblerNavigationBottomBar(
              safeArea: false,
              defaultMenuOpen: true,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          _actionTurns(tester),
          DabblerNavigationBottomBar.actionOpenTurns,
        );

        await tester.pumpWidget(
          _host(
            const DabblerNavigationBottomBar(
              key: ValueKey<int>(2),
              safeArea: false,
              defaultMenuOpen: true,
              rotateActionOnOpen: false,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(_actionTurns(tester), 0);
      },
    );
  });

  group('DSG-NEW-002 — ProgressBar onBrand', () {
    test('fill is onBrand, track is onBrand at 22%', () {
      final DabblerColors c = _colors();
      expect(
        DabblerProgressBar.fillFor(DabblerProgressBarTone.onBrand, c),
        c.onBrand,
      );
      expect(
        DabblerProgressBar.trackFor(DabblerProgressBarTone.onBrand, c),
        c.onBrand.withValues(alpha: 0.22),
      );
      expect(DabblerProgressBar.onBrandTrackOpacity, 0.22);
    });

    test('other tones keep the bgTertiary track', () {
      final DabblerColors c = _colors();
      for (final DabblerProgressBarTone t in DabblerProgressBarTone.values) {
        if (t == DabblerProgressBarTone.onBrand) continue;
        expect(DabblerProgressBar.trackFor(t, c), c.bgTertiary);
      }
    });

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('paints track, fill and onBrand caption in ${dir.name}', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(
            const DabblerProgressBar(
              value: 0.5,
              tone: DabblerProgressBarTone.onBrand,
              label: 'Waitlist',
              showValue: true,
            ),
            direction: dir,
            width: 300,
          ),
        );
        await tester.pumpAndSettle();
        final DabblerColors c = _colors();
        final List<ColoredBox> boxes = tester
            .widgetList<ColoredBox>(find.byType(ColoredBox))
            .toList();
        expect(
          boxes.map((ColoredBox b) => b.color),
          containsAll(<Color>[c.onBrand.withValues(alpha: 0.22), c.onBrand]),
        );
        expect(
          tester.widget<Text>(find.text('Waitlist')).style!.color,
          c.onBrand,
        );
        // Fill grows from the inline start.
        final Rect track = tester.getRect(find.byWidget(boxes.first));
        final Rect fill = tester.getRect(find.byWidget(boxes.last));
        if (dir == TextDirection.ltr) {
          expect(fill.left, track.left);
        } else {
          expect(fill.right, track.right);
        }
      });
    }
  });

  group('DSG-NEW-009 — DabblerBadge.dot', () {
    testWidgets('7px brand circle by default, no text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const Center(child: DabblerBadge.dot())));
      final Finder dot = find.byType(DabblerBadge);
      expect(tester.getSize(dot), const Size(7, 7));
      expect(DabblerBadge.dotDiameter, 7);
      expect(find.byType(Text), findsNothing);
      final BoxDecoration d =
          tester
                  .widget<DecoratedBox>(find.byType(DecoratedBox).first)
                  .decoration
              as BoxDecoration;
      expect(d.color, _colors().brandPrimary);
      expect(d.shape, BoxShape.circle);
    });

    test('status wins and paints its base role', () {
      final DabblerColors c = _colors();
      expect(
        DabblerBadge.dotColorOf(DabblerBadgeTone.pill, c.error, c),
        c.error.base,
      );
      expect(DabblerBadge.dotColorOf(DabblerBadgeTone.pill, null, c), c.accent);
    });

    testWidgets('silent without a label, named with one', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(_host(const Center(child: DabblerBadge.dot())));
      expect(find.bySemanticsLabel('Unread'), findsNothing);
      await tester.pumpWidget(
        _host(const Center(child: DabblerBadge.dot(semanticLabel: 'Unread'))),
      );
      expect(find.bySemanticsLabel('Unread'), findsOneWidget);
      h.dispose();
    });

    testWidgets('RTL: same size, positioned only by its host', (
      WidgetTester tester,
    ) async {
      Widget row(TextDirection d) => _host(
        const Row(
          children: <Widget>[
            DabblerBadge.dot(),
            Expanded(child: SizedBox(height: 7)),
          ],
        ),
        direction: d,
        width: 200,
      );
      await tester.pumpWidget(row(TextDirection.ltr));
      final Rect ltr = tester.getRect(find.byType(DabblerBadge));
      await tester.pumpWidget(row(TextDirection.rtl));
      final Rect rtl = tester.getRect(find.byType(DabblerBadge));
      expect(rtl.size, ltr.size);
      // The host's Row puts it at the inline start, mirrored; the dot itself
      // does nothing direction-dependent.
      expect(ltr.left, lessThan(rtl.left));
    });

    test('pill constructor is unchanged', () {
      const DabblerBadge b = DabblerBadge(label: 'x');
      expect(b.isDot, isFalse);
      expect(b.semanticLabel, isNull);
    });
  });
}
