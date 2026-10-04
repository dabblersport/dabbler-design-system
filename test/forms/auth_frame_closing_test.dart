import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

TextStyle _styleOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!;

void main() {
  for (final TextDirection dir in TextDirection.values) {
    final bool rtl = dir == TextDirection.rtl;
    final String hook = rtl ? 'العب' : 'Play';
    final String sub = rtl ? 'انضم' : 'Join';

    group('closing pass, $dir', () {
      testWidgets('persona card: hook 16/23, subtitle small 14/20, 3px gaps', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            DabblerSelectableCard(
              icon: 'game',
              caption: 'Player',
              title: hook,
              subtitle: sub,
              onChanged: (_) {},
            ),
            direction: dir,
          ),
        );
        final TextStyle h = _styleOf(tester, hook);
        final TextStyle s = _styleOf(tester, sub);
        expect(h.fontSize, rtl ? 15.1 : 16);
        expect(h.height! * h.fontSize!, closeTo(rtl ? 24 : 23, 1e-6));
        expect(s.fontSize, DabblerType.small.resolveForDirection(dir).fontSize);
        expect(s.height! * s.fontSize!, closeTo(rtl ? 22 : 20, 1e-6));
        if (!rtl) {
          // 21 + 3 + 23 + 3 + 20 = 70, the frame's text column (`:381-384`).
          expect(
            tester.getRect(find.text(sub)).bottom -
                tester.getRect(find.text('PLAYER')).top,
            closeTo(70, 0.5),
          );
        }
      });

      testWidgets('list row title is rowTitle, stacked label is copy medium', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const DabblerSelectableCard(
              layout: DabblerSelectableCardLayout.listRow,
              title: 'Padel',
            ),
            direction: dir,
          ),
        );
        TextStyle s = _styleOf(tester, 'Padel');
        final TextStyle row = DabblerType.rowTitle.resolveForDirection(dir);
        expect(s.fontSize, row.fontSize);
        expect(s.height, row.height);
        expect(s.fontWeight, DabblerType.medium);

        await tester.pumpWidget(
          host(
            const DabblerSelectableCard(
              layout: DabblerSelectableCardLayout.stacked,
              title: 'Male',
            ),
            direction: dir,
          ),
        );
        s = _styleOf(tester, 'Male');
        final TextStyle copy = DabblerType.copy.resolveForDirection(dir);
        expect(s.fontSize, copy.fontSize);
        expect(s.height, copy.height);
        expect(s.fontWeight, DabblerType.medium);
      });

      testWidgets('tile label is tagTight at medium', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const DabblerSelectableCard(
              layout: DabblerSelectableCardLayout.tile,
              title: 'Padel',
            ),
            direction: dir,
          ),
        );
        final TextStyle s = _styleOf(tester, 'Padel');
        final TextStyle tag = DabblerType.tagTight.resolveForDirection(dir);
        expect(s.fontSize, tag.fontSize);
        expect(s.height, tag.height);
        expect(s.fontWeight, DabblerType.medium);
      });

      testWidgets('flow page titleGap defaults to 6 and takes 9', (
        WidgetTester tester,
      ) async {
        Future<double> gap(double? titleGap) async {
          await tester.pumpWidget(
            host(
              SizedBox(
                height: 600,
                child: titleGap == null
                    ? const DabblerFlowPage(title: 'Title', subtitle: 'Sub')
                    : DabblerFlowPage(
                        title: 'Title',
                        subtitle: 'Sub',
                        titleGap: titleGap,
                      ),
              ),
              direction: dir,
            ),
          );
          return tester.getRect(find.text('Sub')).top -
              tester.getRect(find.text('Title')).bottom;
        }

        final double base = await gap(null);
        final double wide = await gap(DabblerSpacing.space3);
        expect(wide - base, DabblerSpacing.space3 - DabblerSpacing.space2);
      });

      testWidgets('chip rail gap overrides the 6 default', (
        WidgetTester tester,
      ) async {
        Future<double> between(double? gap) async {
          await tester.pumpWidget(
            host(
              DabblerChipRail(
                gap: gap,
                items: <DabblerChipRailItem>[
                  DabblerChipRailItem(label: 'A', onTap: () {}),
                  DabblerChipRailItem(label: 'B', onTap: () {}),
                ],
              ),
              direction: dir,
            ),
          );
          final Rect a = tester.getRect(find.byType(DabblerSurface).first);
          final Rect b = tester.getRect(find.byType(DabblerSurface).last);
          return rtl ? a.left - b.right : b.left - a.right;
        }

        expect(await between(null), DabblerChipRail.gap);
        expect(await between(DabblerSpacing.space3), 9);
      });

      testWidgets('compact page dots are exactly 6 tall; default is 45', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            DabblerPageDots(
              count: 3,
              index: 0,
              onSelected: (_) {},
              compactHitArea: true,
            ),
            direction: dir,
          ),
        );
        expect(tester.getSize(find.byType(DabblerPageDots)).height, 6);
        await tester.tap(find.byKey(const ValueKey<int>(2)));

        await tester.pumpWidget(
          host(
            DabblerPageDots(count: 3, index: 0, onSelected: (_) {}),
            direction: dir,
          ),
        );
        expect(
          tester.getSize(find.byType(DabblerPageDots)).height,
          DabblerSizing.touchTargetMin,
        );
      });

      testWidgets('field label and placeholder are muted (tertiary)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const DabblerTextField(label: 'Email', placeholder: 'you@x.com'),
            direction: dir,
          ),
        );
        final DabblerColors colors = testColors();
        expect(_styleOf(tester, 'Email').color, colors.textTertiary);
        final TextField field = tester.widget<TextField>(
          find.byType(TextField),
        );
        expect(field.decoration!.hintStyle!.color, colors.textTertiary);
      });

      testWidgets('regular chip is 40 tall, selected or not', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const DabblerChip(label: 'Marcus'), direction: dir),
        );
        final double h = tester.getSize(find.byType(DabblerSurface)).height;
        expect(h, rtl ? 43 : 40);
        await tester.pumpWidget(
          host(
            const DabblerChip(label: 'Marcus', selected: true),
            direction: dir,
          ),
        );
        expect(tester.getSize(find.byType(DabblerSurface)).height, h);
      });
    });
  }
}
