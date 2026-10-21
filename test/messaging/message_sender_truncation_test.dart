// KAN-623: the DabblerMessage sender is one line that truncates (design
// section 10, "One line, truncates"), in LTR and RTL.
import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

final DabblerColors _colors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(Widget child, TextDirection dir) => MaterialApp(
  theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors]),
  home: Directionality(
    textDirection: dir,
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 400, child: child),
    ),
  ),
);

void main() {
  final String longLtr = List<String>.filled(6, 'Abdelrahman').join(' ');
  final String longRtl = List<String>.filled(
    6,
    'عبدالرحمن',
  ).join(' ');

  final List<(String, String, TextDirection)> cases =
      <(String, String, TextDirection)>[
        (longLtr, 'LTR', TextDirection.ltr),
        (longRtl, 'RTL', TextDirection.rtl),
      ];
  for (final (String name, String label, TextDirection dir) in cases) {
    testWidgets('a 54+ character sender stays on one line ($label)', (
      WidgetTester tester,
    ) async {
      expect(name.length, greaterThanOrEqualTo(54));
      await tester.pumpWidget(
        _host(
          DabblerMessage(
            context: DabblerMessageContext.group,
            sender: name,
            content: 'Hi',
          ),
          dir,
        ),
      );
      final Text text = tester.widget<Text>(find.text(name));
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
      final RenderParagraph p = tester.renderObject<RenderParagraph>(
        find.text(name),
      );
      expect(p.didExceedMaxLines, isTrue);
      expect(
        p.size.height,
        lessThanOrEqualTo(DabblerType.caption1.fontSize * 1.6),
      );
    });
  }
}
