import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

/// KAN-426 second DS round: flow back box, step bar tokens, persona caption
/// leading, password toggle ink and the chip rail edge.
void main() {
  for (final TextDirection dir in TextDirection.values) {
    final bool rtl = dir == TextDirection.rtl;
    // Strings that already exist in this package's own tests.
    final String hook = rtl ? 'العب' : 'Play';

    group('round 2, $dir', () {
      testWidgets('flow back is a 45x45 square, glyph centred 34.5 in', (
        WidgetTester tester,
      ) async {
        int backs = 0;
        await tester.pumpWidget(
          host(
            SizedBox(
              height: 600,
              child: DabblerFlowPage(
                onBack: () => backs++,
                backLabel: 'Back',
                title: 'Title',
              ),
            ),
            direction: dir,
          ),
        );
        final Finder icon = find.byWidgetPredicate(
          (Widget w) => w is DabblerIcon && w.name.startsWith('arrow-'),
        );
        final Rect glyph = tester.getRect(icon);
        final Rect box = tester.getRect(
          find.ancestor(of: icon, matching: find.byType(SizedBox)).first,
        );
        expect(box.size, const Size(45, 45));
        expect(glyph.size, const Size(24, 24));
        final Rect screen = tester.getRect(find.byType(DabblerFlowPage));
        final double fromEdge = rtl
            ? screen.right - glyph.center.dx
            : glyph.center.dx - screen.left;
        // The host centres a 320 column; the page gutter inside it is 12
        // for the box, so the glyph centre is 12 + 22.5 from the edge.
        expect(fromEdge, closeTo(34.5, 0.5));
        await tester.tap(icon);
        expect(backs, 1);
      });

      testWidgets('step progress is 4 high with a 5 gap; both overridable', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(DabblerStepProgress(count: 3, current: 1), direction: dir),
        );
        final Rect a = tester.getRect(find.byKey(const ValueKey<int>(0)));
        final Rect b = tester.getRect(find.byKey(const ValueKey<int>(1)));
        expect(a.height, 4);
        expect(rtl ? a.left - b.right : b.left - a.right, 5);

        await tester.pumpWidget(
          host(
            DabblerStepProgress(
              count: 3,
              current: 1,
              segmentHeight: DabblerSpacing.space1,
              segmentGap: DabblerSpacing.space2,
            ),
            direction: dir,
          ),
        );
        await tester.pumpAndSettle();
        final Rect c = tester.getRect(find.byKey(const ValueKey<int>(0)));
        final Rect d = tester.getRect(find.byKey(const ValueKey<int>(1)));
        expect(c.height, 3);
        expect(rtl ? c.left - d.right : d.left - c.right, 6);
      });

      testWidgets('persona caption keeps its natural leading, not 21', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            DabblerSelectableCard(
              icon: 'game',
              caption: 'Player',
              title: hook,
              onChanged: (_) {},
            ),
            direction: dir,
          ),
        );
        final TextStyle s = tester.widget<Text>(find.text('PLAYER')).style!;
        if (rtl) {
          expect(s.height, isNotNull);
        } else {
          expect(s.height, isNull);
          expect(s.fontWeight, DabblerType.semibold);
        }
      });

      testWidgets('password toggle: secondary 24 by default, muted 20 on ask', (
        WidgetTester tester,
      ) async {
        DabblerIcon eye() => tester.widget<DabblerIcon>(
          find.byWidgetPredicate(
            (Widget w) => w is DabblerIcon && w.name == 'eye',
          ),
        );
        await tester.pumpWidget(
          host(
            const DabblerTextField(variant: DabblerTextFieldVariant.password),
            direction: dir,
          ),
        );
        expect(eye().size, 24);
        expect(eye().color, testColors().textSecondary);

        await tester.pumpWidget(
          host(
            const DabblerTextField(
              variant: DabblerTextFieldVariant.password,
              mutedPasswordToggle: true,
            ),
            direction: dir,
          ),
        );
        expect(eye().size, 20);
        expect(eye().color, testColors().textTertiary);
        // The target is still 45x45.
        expect(
          tester.getSize(
            find
                .ancestor(
                  of: find.byWidgetPredicate(
                    (Widget w) => w is DabblerIcon && w.name == 'eye',
                  ),
                  matching: find.byType(SizedBox),
                )
                .first,
          ),
          const Size(45, 45),
        );
      });

      testWidgets('chip rail never paints a chip border on its clip edge', (
        WidgetTester tester,
      ) async {
        final GlobalKey key = GlobalKey();
        await tester.pumpWidget(
          host(
            RepaintBoundary(
              key: key,
              child: ColoredBox(
                color: const Color(0xFFFFFFFF),
                child: DabblerChipRail(
                  gap: DabblerSpacing.space3,
                  items: <DabblerChipRailItem>[
                    for (int i = 0; i < 8; i++)
                      DabblerChipRailItem(label: '$hook $i', onTap: () {}),
                  ],
                ),
              ),
            ),
            direction: dir,
          ),
        );
        final Rect view = tester.getRect(find.byKey(DabblerChipRail.scrollKey));
        final Rect first = tester.getRect(find.byType(DabblerSurface).first);
        final double inset = rtl
            ? view.right - first.right
            : first.left - view.left;
        expect(inset, greaterThanOrEqualTo(DabblerChipRail.edgeInset));

        await tester.runAsync(() async {
          final RenderRepaintBoundary boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final ui.Image img = await boundary.toImage();
          final ByteData data = (await img.toByteData())!;
          final int y = img.height ~/ 2;
          int rgb(int x) {
            final int o = (y * img.width + x) * 4;
            return (data.getUint8(o) << 16) |
                (data.getUint8(o + 1) << 8) |
                data.getUint8(o + 2);
          }

          // The hairline column is the first non-white pixel from the
          // chip's side: it exists, and is at least 1px inside the edge.
          final int step = rtl ? -1 : 1;
          int x = rtl ? img.width - 1 : 0;
          int guard = 0;
          while (rgb(x) == 0xFFFFFF && guard++ < 6) {
            x += step;
          }
          final int distance = rtl ? img.width - 1 - x : x;
          expect(distance, greaterThanOrEqualTo(1));
          expect(rgb(x), isNot(0xFFFFFF));
        });
      });
    });
  }
}
