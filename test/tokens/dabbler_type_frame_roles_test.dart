import 'package:dabbler_design_system/src/foundations/text.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

/// `(latin size, latin leading, arabic leading, weight, role)` per frame role,
/// pinned from the design frames named in each role's dartdoc (KAN-426).
final Map<String, (double, double, double, FontWeight, DabblerTypeRole)>
_pinned = <String, (double, double, double, FontWeight, DabblerTypeRole)>{
  'displayHero': (40, 46, 46, FontWeight.w400, DabblerTypeRole.display),
  'displayWelcome': (36, 42, 42, FontWeight.w400, DabblerTypeRole.display),
  'displayScreen': (34, 40, 40, FontWeight.w400, DabblerTypeRole.display),
  'displayStep': (30, 36, 40, FontWeight.w400, DabblerTypeRole.display),
  'displaySection': (26, 32, 32, FontWeight.w400, DabblerTypeRole.display),
  'displayStat': (42, 46, 46, FontWeight.w400, DabblerTypeRole.display),
  'displayStatHero': (56, 56, 56, FontWeight.w400, DabblerTypeRole.display),
  'displayStatMid': (34, 36, 36, FontWeight.w400, DabblerTypeRole.display),
  'displayStatSmall': (30, 32, 32, FontWeight.w400, DabblerTypeRole.display),
  'displayLabel': (18, 23, 23, FontWeight.w400, DabblerTypeRole.display),
  'leadLarge': (19, 27, 27, FontWeight.w400, DabblerTypeRole.sans),
  'lead': (17, 24, 25, FontWeight.w400, DabblerTypeRole.sans),
  'rowTitle': (17, 23, 25, FontWeight.w500, DabblerTypeRole.sans),
  'copy': (15, 21, 24, FontWeight.w400, DabblerTypeRole.sans),
  'small': (14, 20, 22, FontWeight.w400, DabblerTypeRole.sans),
  'smallTight': (14, 19, 22, FontWeight.w400, DabblerTypeRole.sans),
  'smallRelaxed': (14, 21, 22, FontWeight.w400, DabblerTypeRole.sans),
  'footnoteTight': (13, 17, 17, FontWeight.w600, DabblerTypeRole.sans),
  'footnoteRelaxed': (13, 20, 20, FontWeight.w400, DabblerTypeRole.sans),
  'tag': (11, 15, 15, FontWeight.w600, DabblerTypeRole.sans),
  'tagTight': (11, 14, 14, FontWeight.w600, DabblerTypeRole.sans),
  'figure': (18, 22, 22, FontWeight.w700, DabblerTypeRole.sans),
  'figureLarge': (20, 26, 26, FontWeight.w700, DabblerTypeRole.sans),
  'figureXl': (22, 27, 27, FontWeight.w700, DabblerTypeRole.sans),
  'displayNameMid': (19, 25, 25, FontWeight.w400, DabblerTypeRole.display),
  'displayNameSmall': (17, 22, 22, FontWeight.w400, DabblerTypeRole.display),
};

void main() {
  group('DabblerType.frameRoles (KAN-426, D-024 amended)', () {
    test('every pinned role is declared, and no other', () {
      expect(
        DabblerType.frameRoles.map((DabblerTypeStyle s) => s.name).toList(),
        _pinned.keys.toList(),
      );
    });

    test('the twelve .t-* steps are unchanged and stay separate', () {
      expect(DabblerType.styles.length, 12);
      final Set<String> ramp = DabblerType.styles
          .map((DabblerTypeStyle s) => s.name)
          .toSet();
      for (final DabblerTypeStyle r in DabblerType.frameRoles) {
        expect(ramp.contains(r.name), isFalse, reason: r.name);
      }
    });

    for (final MapEntry<
          String,
          (double, double, double, FontWeight, DabblerTypeRole)
        >
        e
        in _pinned.entries) {
      final DabblerTypeStyle role = DabblerType.frameRoles.firstWhere(
        (DabblerTypeStyle s) => s.name == e.key,
      );
      final (
        double size,
        double lead,
        double arLead,
        FontWeight w,
        DabblerTypeRole kind,
      ) = e.value;

      test('${e.key}: tokens', () {
        expect(role.fontSize, size);
        expect(role.arabicFontSize, closeTo(size - 0.9, 1e-9));
        expect(role.latinLeading, lead);
        expect(role.arabicLeading, arLead);
        expect(role.fontWeight, w);
        expect(role.role, kind);
        expect(
          DabblerType.frameRolesArabicExtraLeading.contains(e.key),
          role.takesArabicExtraLeading,
        );
      });

      for (final TextDirection dir in TextDirection.values) {
        testWidgets('${e.key}: DabblerText resolves it ($dir)', (
          WidgetTester tester,
        ) async {
          final bool rtl = dir == TextDirection.rtl;
          await tester.pumpWidget(
            host(
              DabblerText(rtl ? 'مرحبا 24' : 'Hello 24', style: role),
              direction: dir,
            ),
          );
          final Text text = tester.widget<Text>(find.byType(Text).first);
          final TextStyle s = text.style!;
          final TextDirection d = rtl ? TextDirection.rtl : TextDirection.ltr;
          final TextStyle expected = role.resolveForDirection(d);
          expect(s.fontSize, rtl ? size - 0.9 : size);
          expect(s.fontSize, expected.fontSize);
          expect(s.height! * s.fontSize!, closeTo(rtl ? arLead : lead, 1e-6));
          expect(s.fontWeight, w);
          expect(s.fontFamily, expected.fontFamily);
          expect(s.decoration, TextDecoration.none);
          expect(s.fontFeatures, DabblerType.numeralFeatures);
          // Arabic selects the Arabic face of the same role.
          expect(
            s.fontFamily,
            DabblerType.fontFamilyFor(
              kind,
              rtl ? DabblerTypeScript.arabic : DabblerTypeScript.latin,
            ),
          );
        });
      }
    }
  });
}
