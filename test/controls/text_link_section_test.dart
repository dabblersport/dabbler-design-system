import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

Widget _manage({VoidCallback? onPressed, String? icon = 'arrow-right-3'}) =>
    Builder(
      builder: (BuildContext context) => Center(
        child: DabblerTextLink(
          label: 'Manage',
          underline: false,
          trailingIcon: icon,
          style: DabblerType.footnote
              .resolveForDirection(Directionality.of(context))
              .copyWith(fontWeight: DabblerType.semibold),
          onPressed: onPressed,
        ),
      ),
    );

void main() {
  group('DabblerTextLink — lone section link', () {
    testWidgets('no underline, brand, footnote semibold, 45px target', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(_manage(onPressed: () {})));
      final TextStyle s = tester.widget<Text>(find.text('Manage')).style!;
      expect(s.decoration, TextDecoration.none);
      expect(s.color, testColors().brandPrimary);
      expect(s.fontWeight, DabblerType.semibold);
      final Size size = tester.getSize(find.byType(DabblerTextLink));
      expect(size.height, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
    });

    testWidgets('underline stays on by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          Center(
            child: DabblerTextLink(label: 'Log in', onPressed: () {}),
          ),
        ),
      );
      expect(
        tester.widget<Text>(find.text('Log in')).style!.decoration,
        TextDecoration.underline,
      );
      expect(find.byType(DabblerIcon), findsNothing);
    });

    testWidgets('trailing glyph: iconSm, link colour, mirrored, tertiary off', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(_manage(onPressed: () {})));
      DabblerIcon icon = tester.widget<DabblerIcon>(find.byType(DabblerIcon));
      expect(icon.size, DabblerSizing.iconSm);
      expect(icon.color, testColors().brandPrimary);
      expect(icon.mirrorInRtl, isTrue);

      await tester.pumpWidget(host(_manage()));
      icon = tester.widget<DabblerIcon>(find.byType(DabblerIcon));
      expect(icon.color, testColors().textTertiary);
    });

    for (final TextDirection d in TextDirection.values) {
      testWidgets('glyph follows the label (${d.name})', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(_manage(onPressed: () {}), direction: d));
        final Rect t = tester.getRect(find.text('Manage'));
        final Rect g = tester.getRect(find.byType(DabblerIcon));
        if (d == TextDirection.ltr) {
          expect(g.left, greaterThanOrEqualTo(t.right));
        } else {
          expect(g.right, lessThanOrEqualTo(t.left));
        }
      });
    }

    testWidgets('tap fires; the glyph adds nothing to the name', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      int taps = 0;
      await tester.pumpWidget(host(_manage(onPressed: () => taps++)));
      await tester.tap(find.byType(DabblerTextLink));
      expect(taps, 1);
      expect(
        tester.getSemantics(find.byType(DabblerTextLink)),
        matchesSemantics(
          label: 'Manage',
          isLink: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      h.dispose();
    });
  });

  group('DabblerSurface.brandTintBleed', () {
    for (final Brightness b in Brightness.values) {
      testWidgets('brand tint, square, no hairline (${b.name})', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const DabblerSurface.brandTintBleed(height: 80), brightness: b),
        );
        final BoxDecoration d =
            tester
                    .widget<DecoratedBox>(
                      find.descendant(
                        of: find.byType(DabblerSurface),
                        matching: find.byType(DecoratedBox),
                      ),
                    )
                    .decoration
                as BoxDecoration;
        expect(
          d.color,
          DabblerSurface.brandTintBleedFill(testColors(brightness: b)),
        );
        final DabblerColors c = testColors(brightness: b);
        expect(
          d.color,
          Color.lerp(c.surfaceCard, c.brandPrimary, 0.14),
        );
        expect(d.border, isNull);
        expect(d.borderRadius, BorderRadius.zero);
        expect(tester.getSize(find.byType(DabblerSurface)).width, hostWidth);
      });
    }

    testWidgets('is full width in RTL too, padding is directional', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerSurface.brandTintBleed(
            padding: EdgeInsetsDirectional.only(start: DabblerSpacing.space6),
            child: Text('hero'),
          ),
          direction: TextDirection.rtl,
        ),
      );
      final Rect s = tester.getRect(find.byType(DabblerSurface));
      final Rect t = tester.getRect(find.text('hero'));
      expect(s.width, hostWidth);
      expect(s.right - t.right, DabblerSpacing.space6);
    });
  });
}
