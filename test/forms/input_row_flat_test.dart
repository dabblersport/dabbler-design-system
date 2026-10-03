import 'package:dabbler_design_system/src/forms/input_row.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/surfaces/surface.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DabblerColors _colors() => DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(Widget child, {TextDirection dir = TextDirection.ltr}) =>
    MaterialApp(
      theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors()]),
      home: Directionality(
        textDirection: dir,
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 400, child: child),
        ),
      ),
    );

BoxDecoration? _flatDecoration(WidgetTester t) {
  final Iterable<DecoratedBox> boxes = t.widgetList<DecoratedBox>(
    find.descendant(
      of: find.byType(DabblerInputRow),
      matching: find.byType(DecoratedBox),
    ),
  );
  return boxes.first.decoration as BoxDecoration;
}

void main() {
  for (final TextDirection dir in TextDirection.values) {
    group('flat (${dir.name})', () {
      testWidgets('has no card surface and runs to the gutter', (t) async {
        await t.pumpWidget(
          _host(
            const DabblerInputRow(
              flat: true,
              leading: SizedBox(
                key: ValueKey<String>('lead'),
                width: 20,
                height: 20,
              ),
              title: 'Downtown Dubai',
              subtitle: 'Recent',
            ),
            dir: dir,
          ),
        );
        expect(find.byType(DabblerSurface), findsNothing);
        final Rect row = t.getRect(find.byType(DabblerInputRow));
        final Rect lead = t.getRect(find.byKey(const ValueKey<String>('lead')));
        if (dir == TextDirection.ltr) {
          expect(lead.left, row.left);
        } else {
          expect(lead.right, row.right);
        }
        // 12 block padding (Listings.dc.html:330).
        expect(
          DabblerInputRow.flatPadding,
          const EdgeInsetsDirectional.symmetric(
            vertical: DabblerSpacing.space4,
          ),
        );
        expect(row.height, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
      });

      testWidgets('draws the --faint hairline by default', (t) async {
        await t.pumpWidget(
          _host(const DabblerInputRow(flat: true, title: 'a'), dir: dir),
        );
        final BoxDecoration d = _flatDecoration(t)!;
        expect(d.color, isNull);
        expect(d.borderRadius, isNull);
        final Border b = d.border! as Border;
        expect(b.bottom.color, _colors().bgTertiary);
        expect(b.bottom.width, DabblerSizing.borderDefault);
        expect(b.top, BorderSide.none);
      });

      testWidgets('showDivider: false drops it', (t) async {
        await t.pumpWidget(
          _host(
            const DabblerInputRow(flat: true, showDivider: false, title: 'a'),
            dir: dir,
          ),
        );
        expect(_flatDecoration(t)!.border, isNull);
      });

      testWidgets('tappable flat row is one selected button, square ring', (
        t,
      ) async {
        final SemanticsHandle h = t.ensureSemantics();
        int taps = 0;
        await t.pumpWidget(
          _host(
            DabblerInputRow(
              flat: true,
              title: 'Marina',
              selected: true,
              onTap: () => taps++,
            ),
            dir: dir,
          ),
        );
        await t.tap(find.byType(DabblerInputRow));
        expect(taps, 1);
        expect(
          t.getSemantics(find.byType(DabblerInputRow)),
          matchesSemantics(
            label: 'Marina',
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            hasSelectedState: true,
            isSelected: true,
            hasTapAction: true,
            isFocusable: true,
            hasFocusAction: true,
          ),
        );
        expect(
          t
              .widget<DabblerFocusRing>(find.byType(DabblerFocusRing))
              .borderRadius,
          BorderRadius.zero,
        );
        h.dispose();
      });
    });
  }

  testWidgets('default stays boxed', (t) async {
    await t.pumpWidget(_host(const DabblerInputRow(title: 'a')));
    expect(find.byType(DabblerSurface), findsOneWidget);
  });
}
