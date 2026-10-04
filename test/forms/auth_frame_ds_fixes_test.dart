import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:dabbler_design_system/src/forms/field_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

final Finder _row = find.byWidgetPredicate((Widget w) => w is DabblerInputRow);

/// KAN-426 final DS pass: the frame differences only the DS can fix — the
/// border outside the box, laid-out hit areas, the landing wordmark, the sheet
/// option row, the circled select glyph and the body bottom padding.
void main() {
  for (final TextDirection dir in TextDirection.values) {
    final bool rtl = dir == TextDirection.rtl;
    // Strings that already exist in this package's own tests.
    final String nativeName = rtl ? 'العب' : 'Play';

    group('border outside the box, $dir', () {
      testWidgets('DabblerSurface: default inside, borderOutside grows by 2', (
        WidgetTester tester,
      ) async {
        Future<Size> size({required bool outside, double? height}) async {
          await tester.pumpWidget(
            host(
              Align(
                alignment: AlignmentDirectional.topStart,
                child: DabblerSurface(
                  borderOutside: outside,
                  height: height,
                  child: const SizedBox(width: 10, height: 10),
                ),
              ),
              direction: dir,
            ),
          );
          return tester.getSize(find.byType(DabblerSurface));
        }

        expect((await size(outside: false)).height, 10);
        expect((await size(outside: true)).height, 12);
        // `border-box` with an explicit height: the outer size is the height.
        expect((await size(outside: true, height: 50)).height, 50);
      });

      testWidgets('DabblerSurface.card forwards borderOutside', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const DabblerSurface.card(
              borderOutside: true,
              child: SizedBox(height: 10),
            ),
            direction: dir,
          ),
        );
        expect(tester.getSize(find.byType(DabblerSurface)).height, 12);
      });

      Future<double> boxHeight(WidgetTester tester, Widget field) async {
        await tester.pumpWidget(host(field, direction: dir));
        return tester
            .getSize(
              find
                  .descendant(
                    of: find.byType(DabblerFieldShell),
                    matching: find.byType(DabblerSurface),
                  )
                  .first,
            )
            .height;
      }

      testWidgets('text field is 45 by default and 47 with borderOutside', (
        WidgetTester tester,
      ) async {
        expect(await boxHeight(tester, const DabblerTextField()), 45);
        expect(
          await boxHeight(tester, const DabblerTextField(borderOutside: true)),
          47,
        );
      });

      testWidgets('select 45 and 47; picker, date and time fields 63 and 65', (
        WidgetTester tester,
      ) async {
        expect(
          await boxHeight(
            tester,
            const DabblerTextField(variant: DabblerTextFieldVariant.select),
          ),
          45,
        );
        expect(
          await boxHeight(
            tester,
            const DabblerTextField(
              variant: DabblerTextFieldVariant.select,
              borderOutside: true,
            ),
          ),
          47,
        );
        // The picker shell is its 45px button plus 9px block padding: 63.
        expect(await boxHeight(tester, const DabblerPickerField()), 63);
        expect(
          await boxHeight(
            tester,
            const DabblerPickerField(borderOutside: true),
          ),
          65,
        );
        expect(await boxHeight(tester, const DabblerDateField()), 63);
        expect(
          await boxHeight(tester, const DabblerDateField(borderOutside: true)),
          65,
        );
        expect(await boxHeight(tester, const DabblerTimeField()), 63);
        expect(
          await boxHeight(tester, const DabblerTimeField(borderOutside: true)),
          65,
        );
        expect(
          await boxHeight(
            tester,
            DabblerSelect<int>(
              options: const <DabblerSelectOption<int>>[],
              borderOutside: true,
            ),
          ),
          47,
        );
      });

      testWidgets('a focused field is 49 outside (2px border)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const DabblerTextField(borderOutside: true), direction: dir),
        );
        await tester.tap(find.byType(EditableText));
        await tester.pump();
        expect(tester.getSize(find.byType(DabblerSurface).first).height, 49);
      });

      testWidgets('selectable card: tile and row grow, min-height layouts keep '
          'their outer 64 and 96', (WidgetTester tester) async {
        Future<double> h(
          DabblerSelectableCardLayout layout,
          bool outside, {
          bool selected = false,
        }) async {
          await tester.pumpWidget(
            host(
              SingleChildScrollView(
                child: DabblerSelectableCard(
                  layout: layout,
                  title: nativeName,
                  borderOutside: outside,
                  selected: selected,
                  onChanged: (_) {},
                ),
              ),
              direction: dir,
            ),
          );
          return tester.getSize(find.byType(DabblerSurface)).height;
        }

        final double tile = await h(DabblerSelectableCardLayout.tile, false);
        expect(await h(DabblerSelectableCardLayout.tile, true), tile + 2);
        expect(
          await h(DabblerSelectableCardLayout.tile, true, selected: true),
          tile + 4,
        );
        final double row = await h(DabblerSelectableCardLayout.row, false);
        expect(await h(DabblerSelectableCardLayout.row, true), row + 2);
        const double lr = DabblerSelectableCard.listRowMinHeight;
        const double st = DabblerSelectableCard.stackedMinHeight;
        expect(await h(DabblerSelectableCardLayout.listRow, false), lr);
        expect(await h(DabblerSelectableCardLayout.listRow, true), lr);
        expect(
          await h(DabblerSelectableCardLayout.listRow, true, selected: true),
          lr,
        );
        expect(await h(DabblerSelectableCardLayout.stacked, false), st);
        expect(await h(DabblerSelectableCardLayout.stacked, true), st);
      });
    });

    group('compact hit areas, $dir', () {
      testWidgets('toggle: 28 tall compact, 45 by default', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            Align(
              alignment: AlignmentDirectional.topStart,
              child: DabblerToggle(
                checked: false,
                onChanged: (_) {},
                compactHitArea: true,
              ),
            ),
            direction: dir,
          ),
        );
        expect(tester.getSize(find.byType(DabblerToggle)).height, 28);

        await tester.pumpWidget(
          host(
            Align(
              alignment: AlignmentDirectional.topStart,
              child: DabblerToggle(checked: false, onChanged: (_) {}),
            ),
            direction: dir,
          ),
        );
        expect(
          tester.getSize(find.byType(DabblerToggle)).height,
          DabblerSizing.touchTargetMin,
        );
      });

      testWidgets('compact toggle is still hit from the 45px margin', (
        WidgetTester tester,
      ) async {
        bool value = false;
        await tester.pumpWidget(
          host(
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: DabblerToggle(
                  checked: value,
                  onChanged: (bool v) => value = v,
                  compactHitArea: true,
                ),
              ),
            ),
            direction: dir,
          ),
        );
        final Rect track = tester.getRect(find.byType(DabblerToggle));
        // 8px above the 28px track: inside 45, outside the layout.
        await tester.tapAt(track.topCenter - const Offset(0, 8));
        expect(value, isTrue);
        value = false;
        await tester.tapAt(track.bottomCenter + const Offset(0, 8));
        expect(value, isTrue);
        value = false;
        // 12px away is outside the 45px target.
        await tester.tapAt(track.topCenter - const Offset(0, 12));
        expect(value, isFalse);
      });

      testWidgets('chip: 40 tall compact, 45 by default', (
        WidgetTester tester,
      ) async {
        Future<Size> size({required bool compact}) async {
          await tester.pumpWidget(
            host(
              Align(
                alignment: AlignmentDirectional.topStart,
                child: DabblerChip(
                  label: nativeName,
                  onTap: () {},
                  compactHitArea: compact,
                ),
              ),
              direction: dir,
            ),
          );
          return tester.getSize(find.byType(DabblerChip));
        }

        expect((await size(compact: true)).height, rtl ? 43 : 40);
        expect(
          (await size(compact: false)).height,
          DabblerSizing.touchTargetMin,
        );
      });

      testWidgets('compact chip is still tapped from the 45px margin', (
        WidgetTester tester,
      ) async {
        int taps = 0;
        await tester.pumpWidget(
          host(
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: DabblerChip(
                  label: 'Marcus',
                  onTap: () => taps++,
                  compactHitArea: true,
                ),
              ),
            ),
            direction: dir,
          ),
        );
        final Rect pill = tester.getRect(find.byType(DabblerChip));
        // 45 minus the pill, split top and bottom.
        final double margin = (DabblerSizing.touchTargetMin - pill.height) / 2;
        await tester.tapAt(pill.topCenter - Offset(0, margin - 0.5));
        await tester.tapAt(pill.bottomCenter + Offset(0, margin - 0.5));
        expect(taps, 2);
        await tester.tapAt(pill.topCenter - Offset(0, margin + 3));
        expect(taps, 2);
      });
    });

    testWidgets('wordmark landing size is 104x20; the default stays 100x19', (
      WidgetTester tester,
    ) async {
      expect(DabblerWordmark.landingSize, const Size(104, 20));
      await tester.pumpWidget(
        host(
          Align(
            alignment: AlignmentDirectional.topStart,
            child: DabblerWordmark(size: DabblerWordmark.landingSize),
          ),
          direction: dir,
        ),
      );
      expect(
        tester.getSize(find.byType(DabblerWordmark)),
        DabblerWordmark.landingSize,
      );
      await tester.pumpWidget(
        host(
          const Align(
            alignment: AlignmentDirectional.topStart,
            child: DabblerWordmark(),
          ),
          direction: dir,
        ),
      );
      expect(
        tester.getSize(find.byType(DabblerWordmark)),
        DabblerNavigationTopBar.wordmarkSize,
      );
    });

    group('sheet option row, $dir', () {
      testWidgets('is 71 tall: 52 content, 9x3 padding, 1px hairline', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            DabblerInputRow.option(
              title: nativeName,
              selected: false,
              onTap: () {},
            ),
            direction: dir,
          ),
        );
        expect(tester.getSize(_row).height, 71);
        final TextStyle s = tester.widget<Text>(find.text(nativeName)).style!;
        expect(s.fontWeight, DabblerType.regular);
        expect(
          s.fontSize,
          DabblerType.bodyRelaxed.resolveForDirection(dir).fontSize,
        );
        expect(find.byType(DabblerIcon), findsNothing);
      });

      testWidgets('selected is semibold with the 22px bold tick', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            DabblerInputRow.option(
              title: nativeName,
              selected: true,
              onTap: () {},
            ),
            direction: dir,
          ),
        );
        expect(
          tester.widget<Text>(find.text(nativeName)).style!.fontWeight,
          DabblerType.semibold,
        );
        final DabblerIcon tick = tester.widget<DabblerIcon>(
          find.byType(DabblerIcon),
        );
        expect(tick.name, DabblerInputRow.selectedIconName);
        expect(tick.size, 22);
        expect(tick.weight, DabblerIconWeight.bold);
        // The tick sits at the inline end.
        final Rect row = tester.getRect(_row);
        final Rect icon = tester.getRect(find.byType(DabblerIcon));
        if (rtl) {
          expect(icon.left - row.left, closeTo(3, 0.5));
        } else {
          expect(row.right - icon.right, closeTo(3, 0.5));
        }
      });

      testWidgets('a tap reaches onTap; null onTap is inert', (
        WidgetTester tester,
      ) async {
        int taps = 0;
        await tester.pumpWidget(
          host(
            DabblerInputRow.option(
              title: nativeName,
              selected: false,
              onTap: () => taps++,
            ),
            direction: dir,
          ),
        );
        await tester.tap(_row);
        expect(taps, 1);
      });

      testWidgets('textDirection puts the title flush to its own script end', (
        WidgetTester tester,
      ) async {
        // The painted glyph run's right edge, relative to the row's.
        Future<double> gapToRight(TextDirection? td) async {
          await tester.pumpWidget(
            host(
              DabblerInputRow.option(
                title: nativeName,
                selected: false,
                textDirection: td,
              ),
              direction: TextDirection.ltr,
            ),
          );
          final RenderParagraph paragraph = tester
              .renderObject<RenderParagraph>(find.text(nativeName));
          final List<TextBox> boxes = paragraph.getBoxesForSelection(
            TextSelection(baseOffset: 0, extentOffset: nativeName.length),
          );
          final double runRight =
              tester.getTopLeft(find.text(nativeName)).dx +
              boxes
                  .map((TextBox b) => b.right)
                  .reduce((double a, double b) => a > b ? a : b);
          return tester.getRect(_row).right - runRight;
        }

        expect(await gapToRight(null), greaterThan(100));
        expect(await gapToRight(TextDirection.rtl), closeTo(3, 0.5));
      });

      testWidgets('showDivider false drops the hairline', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            DabblerInputRow.option(
              title: nativeName,
              selected: false,
              showDivider: false,
            ),
            direction: dir,
          ),
        );
        expect(tester.getSize(_row).height, 70);
      });
    });

    group('select glyph, $dir', () {
      Finder glyph(String name) => find.byWidgetPredicate(
        (Widget w) => w is DabblerIcon && w.name == name,
      );

      testWidgets('plain chevron by default, circled on request', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const DabblerTextField(variant: DabblerTextFieldVariant.select),
            direction: dir,
          ),
        );
        expect(glyph(DabblerTextField.selectArrowName), findsOneWidget);

        await tester.pumpWidget(
          host(
            const DabblerTextField(
              variant: DabblerTextFieldVariant.select,
              circledSelectArrow: true,
            ),
            direction: dir,
          ),
        );
        expect(glyph(DabblerTextField.selectArrowCircledName), findsOneWidget);
        expect(glyph(DabblerTextField.selectArrowName), findsNothing);

        await tester.pumpWidget(
          host(
            const DabblerTextField(
              variant: DabblerTextFieldVariant.select,
              circledSelectArrow: true,
              open: true,
            ),
            direction: dir,
          ),
        );
        expect(
          glyph(DabblerTextField.selectArrowOpenCircledName),
          findsOneWidget,
        );
        expect(glyph(DabblerTextField.selectArrowCircledName), findsNothing);
      });

      testWidgets('DabblerSelect.circledArrow reaches the field', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            DabblerSelect<int>(
              options: const <DabblerSelectOption<int>>[],
              circledArrow: true,
            ),
            direction: dir,
          ),
        );
        expect(glyph(DabblerTextField.selectArrowCircledName), findsOneWidget);
      });
    });

    testWidgets('flow page bodyBottomPadding pads the scrolling body, $dir', (
      WidgetTester tester,
    ) async {
      Future<double> bottom(double? padding) async {
        await tester.pumpWidget(
          host(
            SizedBox(
              height: 600,
              child: DabblerFlowPage(
                title: 'Title',
                content: const <Widget>[SizedBox(height: 40, key: Key('c'))],
                bodyBottomPadding: padding ?? 0,
              ),
            ),
            direction: dir,
          ),
        );
        final SingleChildScrollView scroll = tester
            .widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
        return scroll.padding!.resolve(dir).bottom;
      }

      expect(await bottom(null), 0);
      expect(await bottom(DabblerSpacing.space8), 24);
    });
  }
}
