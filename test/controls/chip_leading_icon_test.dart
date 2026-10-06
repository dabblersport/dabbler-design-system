import 'package:dabbler_design_system/src/controls/chip.dart';
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, TextDirection d, {double scale = 1}) {
  final DabblerColors colors = DabblerColors.resolve(
    theme: DabblerTheme.main,
    brightness: Brightness.light,
  );
  return MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
    child: Directionality(
      textDirection: d,
      child: Theme(
        data: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  );
}

void main() {
  for (final bool compact in <bool>[true, false]) {
    for (final TextDirection d in TextDirection.values) {
      testWidgets('leading icon sits before the label, centred (compact: '
          '$compact, ${d.name})', (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(
            DabblerChip(
              label: 'Parking',
              compact: compact,
              leadingIcon: const DabblerIcon('car'),
            ),
            d,
          ),
        );
        final Rect icon = tester.getRect(find.byType(DabblerIcon));
        final Rect label = tester.getRect(find.text('Parking'));
        final Rect pill = tester.getRect(find.byType(DabblerChip));
        if (d == TextDirection.ltr) {
          expect(icon.right, lessThanOrEqualTo(label.left));
        } else {
          expect(icon.left, greaterThanOrEqualTo(label.right));
        }
        // The icon is the slot size, not the 24 default painted over it.
        final double slot = compact
            ? DabblerSizing.iconXs
            : DabblerSizing.iconSm;
        expect(icon.width, slot);
        expect(icon.height, slot);
        expect(icon.center.dy, closeTo(pill.center.dy, 0.5));
        expect(label.center.dy, closeTo(pill.center.dy, 1.0));
        final double gap = d == TextDirection.ltr
            ? label.left - icon.right
            : icon.left - label.right;
        expect(gap, greaterThanOrEqualTo(DabblerChip.iconGap));
      });
    }
  }

  testWidgets('a compact chip is 8 + 18 line + 8 tall at scale 1', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DabblerChip(
          label: 'Parking',
          compact: true,
          leadingIcon: DabblerIcon('car'),
        ),
        TextDirection.ltr,
      ),
    );
    final Size s = tester.getSize(find.byType(DabblerChip));
    expect(s.height, DabblerChip.compactVerticalPadding * 2 + 18);
  });

  testWidgets('a bare DabblerIcon follows the ambient IconTheme size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const IconTheme(
          data: IconThemeData(size: 16),
          child: DabblerIcon('car'),
        ),
        TextDirection.ltr,
      ),
    );
    expect(tester.getSize(find.byType(DabblerIcon)), const Size(16, 16));
    expect(tester.widget<Icon>(find.byType(Icon)).size, 16);
  });
}
