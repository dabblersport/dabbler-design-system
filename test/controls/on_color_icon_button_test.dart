import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

Widget _row(List<Widget> children, {TextDirection d = TextDirection.ltr}) =>
    host(Row(children: <Widget>[...children, const Spacer()]), direction: d);

BoxDecoration _fill(WidgetTester t) =>
    t
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byType(DabblerOnColorIconButton),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

void main() {
  group('DabblerOnColorIconButton', () {
    testWidgets('onBrand at 18% fill, onBrand glyph, 45px pill', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _row(<Widget>[
          DabblerOnColorIconButton(
            icon: 'share',
            semanticLabel: 'Share',
            onPressed: () {},
          ),
        ]),
      );
      final DabblerColors c = testColors();
      final BoxDecoration d = _fill(tester);
      expect(d.color, c.onBrand.withValues(alpha: 0.18));
      expect(d.borderRadius, DabblerRadius.pillAll);
      final Size size = tester.getSize(find.byType(DabblerOnColorIconButton));
      expect(size.width, DabblerSizing.touchTargetMin);
      expect(size.height, DabblerSizing.touchTargetMin);
      final DabblerIcon icon = tester.widget<DabblerIcon>(
        find.byType(DabblerIcon),
      );
      expect(icon.color, c.onBrand);
      expect(icon.size, DabblerSizing.iconSm);
    });

    testWidgets('a caller colour overrides the glyph only', (
      WidgetTester tester,
    ) async {
      final DabblerColors c = testColors();
      await tester.pumpWidget(
        _row(<Widget>[
          DabblerOnColorIconButton(
            icon: 'heart',
            semanticLabel: 'Favourite',
            color: c.accent,
            onPressed: () {},
          ),
        ]),
      );
      expect(
        tester.widget<DabblerIcon>(find.byType(DabblerIcon)).color,
        c.accent,
      );
      expect(_fill(tester).color, c.onBrand.withValues(alpha: 0.18));
    });

    testWidgets('tap, Enter and Space all activate it', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _row(<Widget>[
          DabblerOnColorIconButton(
            icon: 'share',
            semanticLabel: 'Share',
            autofocus: true,
            onPressed: () => taps++,
          ),
        ]),
      );
      await tester.pump();
      await tester.tap(find.byType(DabblerOnColorIconButton));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(taps, 3);
    });

    testWidgets('semantics: button, label, toggled, enabled', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(
        _row(<Widget>[
          DabblerOnColorIconButton(
            icon: 'heart',
            semanticLabel: 'Favourite',
            selected: true,
            onPressed: () {},
          ),
          const DabblerOnColorIconButton(icon: 'share', semanticLabel: 'Share'),
        ]),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Favourite')),
        matchesSemantics(
          label: 'Favourite',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasToggledState: true,
          isToggled: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Share')),
        matchesSemantics(label: 'Share', isButton: true, hasEnabledState: true),
      );
      h.dispose();
    });

    testWidgets('disabled dims and ignores taps', (WidgetTester tester) async {
      await tester.pumpWidget(
        _row(<Widget>[
          const DabblerOnColorIconButton(icon: 'share', semanticLabel: 'Share'),
        ]),
      );
      final Opacity o = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(DabblerOnColorIconButton),
          matching: find.byType(Opacity),
        ),
      );
      expect(o.opacity, DabblerOnColorIconButton.disabledOpacity);
    });

    for (final TextDirection d in TextDirection.values) {
      testWidgets('follows the row and mirrors a back glyph (${d.name})', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _row(<Widget>[
            DabblerOnColorIconButton(
              icon: 'arrow-circle-left',
              semanticLabel: 'Back',
              mirrorInRtl: true,
              onPressed: () {},
            ),
          ], d: d),
        );
        final Rect r = tester.getRect(find.byType(DabblerOnColorIconButton));
        final Rect row = tester.getRect(find.byType(Row));
        if (d == TextDirection.ltr) {
          expect(r.left, row.left);
        } else {
          expect(r.right, row.right);
        }
        expect(
          tester.widget<DabblerIcon>(find.byType(DabblerIcon)).mirrorInRtl,
          isTrue,
        );
      });
    }
  });
}
