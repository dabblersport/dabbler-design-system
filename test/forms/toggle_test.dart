import 'package:dabbler_design_system/src/forms/toggle.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

/// The painted track — the [AnimatedContainer] the switch decorates.
AnimatedContainer _track(WidgetTester tester) =>
    tester.widget<AnimatedContainer>(
      find
          .descendant(
            of: find.byType(DabblerToggle),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );

Color _trackColor(WidgetTester tester) =>
    (_track(tester).decoration! as BoxDecoration).color!;

void main() {
  group('Toggle geometry is the design source', () {
    testWidgets('the track is 48×28 and the knob 24, at a 2px inset', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerToggle(checked: false)),
      );

      final Size track = tester.getSize(
        find
            .descendant(
              of: find.byType(DabblerToggle),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      expect(track, const Size(48, 28), reason: 'Toggle.jsx:17');
      expect(DabblerToggle.trackWidth, DabblerSpacing.space11);
      expect(DabblerToggle.knobSize, DabblerSizing.iconMd);

      final Size knob = tester.getSize(
        find.descendant(
          of: find.byType(AnimatedAlign),
          matching: find.byType(Container),
        ),
      );
      expect(knob, const Size(24, 24));
      // 28 − 24 = 2 above and below: the source's `padding: 2`.
      expect(
        (track.height - knob.height) / 2,
        DabblerToggle.knobInset,
      );
    });

    testWidgets('the hit area clears the 45px floor without moving the track', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerToggle(checked: false)));

      final Size hit = tester.getSize(find.byType(DabblerToggle));
      expect(hit.height, greaterThanOrEqualTo(44));
      expect(hit.height, DabblerSizing.touchTargetMin);
      // The painted track is still 28 — the floor is laid out around it.
      expect(tester.getSize(find.byType(AnimatedContainer).first).height, 28);
    });
  });

  group('Toggle colour comes from the tokens', () {
    testWidgets('on is brandPrimary, off is borderDefault, knob is surfaceCard',
        (WidgetTester tester) async {
      final DabblerColors colors = testColors();

      await tester.pumpWidget(host(const DabblerToggle(checked: true)));
      expect(_trackColor(tester), colors.brandPrimary);

      await tester.pumpWidget(host(const DabblerToggle(checked: false)));
      await tester.pumpAndSettle();
      expect(_trackColor(tester), colors.borderDefault);

      final Container knob = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedAlign),
          matching: find.byType(Container),
        ),
      );
      expect((knob.decoration! as BoxDecoration).color, colors.surfaceCard);
    });
  });

  group('Toggle behaviour', () {
    testWidgets('a tap reports the opposite value and never mutates its own', (
      WidgetTester tester,
    ) async {
      final List<bool> reported = <bool>[];
      await tester.pumpWidget(
        host(DabblerToggle(checked: false, onChanged: reported.add)),
      );

      await tester.tap(find.byType(DabblerToggle));
      await tester.pump();

      expect(reported, <bool>[true]);
      // Controlled: the widget still shows `false` because the caller has not
      // changed it.
      expect(_trackColor(tester), testColors().borderDefault);
    });

    testWidgets('Space and Enter flip it, and the ring shows on key focus', (
      WidgetTester tester,
    ) async {
      final List<bool> reported = <bool>[];
      await tester.pumpWidget(
        host(DabblerToggle(checked: false, onChanged: reported.add)),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        tester.widget<DabblerFocusRing>(find.byType(DabblerFocusRing)).visible,
        isTrue,
        reason: 'a visible focus indicator — cpo §5.2 Principle 3',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(reported, <bool>[true, true]);
    });

    testWidgets('disabled is 45% opaque, takes no tap and no focus', (
      WidgetTester tester,
    ) async {
      final List<bool> reported = <bool>[];
      await tester.pumpWidget(
        host(
          DabblerToggle(
            checked: false,
            disabled: true,
            onChanged: reported.add,
          ),
        ),
      );

      expect(
        tester
            .widget<Opacity>(
              find
                  .descendant(
                    of: find.byType(DabblerToggle),
                    matching: find.byType(Opacity),
                  )
                  .first,
            )
            .opacity,
        DabblerToggle.disabledOpacity,
      );
      expect(DabblerToggle.disabledOpacity, 0.45);

      await tester.tap(find.byType(DabblerToggle));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(reported, isEmpty);
    });
  });

  group('Toggle semantics', () {
    testWidgets('it is announced as a switch, not a tick box', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          DabblerToggle(
            checked: true,
            semanticLabel: 'push notifications',
            onChanged: (_) {},
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(DabblerToggle)),
        matchesSemantics(
          label: 'push notifications',
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });
}
