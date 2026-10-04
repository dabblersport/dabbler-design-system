import 'package:dabbler_design_system/src/controls/button.dart';
import 'package:dabbler_design_system/src/forms/text_field.dart';
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, TextDirection dir) => Directionality(
  textDirection: dir,
  child: Theme(
    data: ThemeData(
      extensions: <ThemeExtension<dynamic>>[
        DabblerColors.resolve(
          theme: DabblerTheme.main,
          brightness: Brightness.light,
        ),
      ],
    ),
    child: Center(child: child),
  ),
);

IconData _g(String name) => DabblerIconRegistry.resolve(name).glyph!;

void main() {
  test('defaults are off (additive)', () {
    expect(const DabblerButton(label: 'Next').mirrorIconInRtl, isFalse);
    expect(
      const DabblerButton.icon(
        icon: 'arrow-left',
        semanticLabel: 'Back',
      ).mirrorIconInRtl,
      isFalse,
    );
  });

  final Map<String, Widget Function(bool)> cases =
      <String, Widget Function(bool)>{
        'labelled': (bool m) => DabblerButton(
          label: 'Next',
          icon: 'arrow-right-1',
          onPressed: () {},
          mirrorIconInRtl: m,
        ),
        'icon-only': (bool m) => DabblerButton.icon(
          icon: 'arrow-right-1',
          semanticLabel: 'Next',
          onPressed: () {},
          mirrorInRtl: m,
        ),
      };

  for (final MapEntry<String, Widget Function(bool)> c in cases.entries) {
    testWidgets('${c.key}: LTR draws the passed glyph', (t) async {
      await t.pumpWidget(_host(c.value(true), TextDirection.ltr));
      expect(t.widget<Icon>(find.byType(Icon)).icon, _g('arrow-right-1'));
      expect(
        t.widget<DabblerIcon>(find.byType(DabblerIcon)).mirrorInRtl,
        isTrue,
      );
    });
    testWidgets('${c.key}: RTL draws the measured mirror, not a flip', (
      t,
    ) async {
      await t.pumpWidget(_host(c.value(true), TextDirection.rtl));
      // `arrow-left` is the pixel mirror of `arrow-right-1` (icon_mirror_test).
      expect(t.widget<Icon>(find.byType(Icon)).icon, _g('arrow-left'));
      expect(
        find.descendant(
          of: find.byType(DabblerIcon),
          matching: find.byType(Transform),
        ),
        findsNothing,
      );
    });
    testWidgets('${c.key}: RTL without the flag is unchanged', (t) async {
      await t.pumpWidget(_host(c.value(false), TextDirection.rtl));
      expect(t.widget<Icon>(find.byType(Icon)).icon, _g('arrow-right-1'));
    });
  }

  test('audit: select caret is the down chevron', () {
    expect(DabblerTextField.selectArrowName, 'arrow-down-1');
  });
}
