import 'package:dabbler_design_system/src/controls/button.dart';
import 'package:dabbler_design_system/src/controls/chip.dart';
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/foundations/vibes.dart';
import 'package:dabbler_design_system/src/surfaces/surface.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

const List<TextDirection> _dirs = <TextDirection>[
  TextDirection.ltr,
  TextDirection.rtl,
];

Widget _h(Widget child, TextDirection dir) =>
    host(Center(child: child), direction: dir);

void main() {
  final DabblerColors colors = testColors();

  for (final TextDirection dir in _dirs) {
    group('DS gaps 5 Button/Chip additions (${dir.name})', () {
      testWidgets(
        'DabblerButton onLongPress fires, tap still fires onPressed',
        (WidgetTester tester) async {
          int taps = 0;
          int longs = 0;
          await tester.pumpWidget(
            _h(
              DabblerButton(
                label: 'join',
                onPressed: () => taps++,
                onLongPress: () => longs++,
              ),
              dir,
            ),
          );
          await tester.longPress(find.text('join'));
          expect(longs, 1);
          expect(taps, 0);
          await tester.tap(find.text('join'));
          expect(taps, 1);
          final SemanticsHandle h = tester.ensureSemantics();
          await tester.pump();
          expect(
            tester
                .getSemantics(find.byType(DabblerButton))
                .getSemanticsData()
                .hasAction(SemanticsAction.longPress),
            isTrue,
          );
          h.dispose();
        },
      );

      testWidgets('DabblerButton.icon onLongPress is inert while disabled', (
        WidgetTester tester,
      ) async {
        int longs = 0;
        await tester.pumpWidget(
          _h(
            DabblerButton.icon(
              icon: 'more',
              semanticLabel: 'More',
              disabled: true,
              onLongPress: () => longs++,
            ),
            dir,
          ),
        );
        await tester.longPress(find.byType(DabblerButton));
        expect(longs, 0);
      });

      testWidgets('DabblerChip onLongPress', (WidgetTester tester) async {
        int longs = 0;
        await tester.pumpWidget(
          _h(
            DabblerChip(
              label: 'Padel',
              onTap: () {},
              onLongPress: () => longs++,
            ),
            dir,
          ),
        );
        await tester.longPress(find.text('Padel'));
        expect(longs, 1);
      });

      testWidgets('onRemove: own glyph, own target, own semantics', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle h = tester.ensureSemantics();
        int taps = 0;
        int removes = 0;
        await tester.pumpWidget(
          _h(
            DabblerChip(
              label: 'Sara',
              onTap: () => taps++,
              onRemove: () => removes++,
            ),
            dir,
          ),
        );
        final Finder glyph = find.byWidgetPredicate(
          (Widget w) =>
              w is DabblerIcon && w.name == DabblerChip.removeIconName,
        );
        expect(glyph, findsOneWidget);
        // The glyph sits inline-end of the label.
        final double lx = tester.getCenter(find.text('Sara')).dx;
        final double gx = tester.getCenter(glyph).dx;
        expect(dir == TextDirection.ltr ? gx > lx : gx < lx, isTrue);

        final Finder target = find.byKey(
          const ValueKey<String>('dabbler-chip-remove'),
        );
        expect(tester.getSize(target).width, greaterThanOrEqualTo(45));
        await tester.tap(target);
        expect(removes, 1);
        expect(taps, 0);
        await tester.tap(find.text('Sara'));
        expect(taps, 1);
        expect(removes, 1);

        expect(find.bySemanticsLabel('Remove Sara'), findsOneWidget);
        expect(find.bySemanticsLabel('Sara'), findsOneWidget);
        h.dispose();
      });

      testWidgets('onRemove works on a static tag, custom label', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle h = tester.ensureSemantics();
        int removes = 0;
        await tester.pumpWidget(
          _h(
            DabblerChip(
              label: 'tag',
              onRemove: () => removes++,
              removeSemanticLabel: 'Untag',
            ),
            dir,
          ),
        );
        await tester.tap(
          find.byKey(const ValueKey<String>('dabbler-chip-remove')),
        );
        expect(removes, 1);
        expect(find.bySemanticsLabel('Untag'), findsOneWidget);
        h.dispose();
      });

      testWidgets('vibe tints surface/border, selected uses selected steps', (
        WidgetTester tester,
      ) async {
        final DabblerVibeColors v = DabblerVibe.calm.resolve(colors);
        for (final bool sel in <bool>[false, true]) {
          await tester.pumpWidget(
            _h(
              DabblerChip(
                label: 'Calm',
                selected: sel,
                vibe: DabblerVibe.calm,
                onTap: () {},
              ),
              dir,
            ),
          );
          final DabblerSurface s = tester.widget<DabblerSurface>(
            find.byType(DabblerSurface),
          );
          expect(s.fill, sel ? v.selectedSurface : v.surface);
          expect(s.borderColor, sel ? v.selectedBorder : v.border);
          expect(tester.widget<Text>(find.text('Calm')).style!.color, v.ink);
        }
      });
    });
  }

  testWidgets('without the new params the chip is unchanged', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _h(const DabblerChip(label: 'x'), TextDirection.ltr),
    );
    final DabblerSurface s = tester.widget<DabblerSurface>(
      find.byType(DabblerSurface),
    );
    expect(s.fill, isNull);
    expect(find.byType(DabblerIcon), findsNothing);
  });
}
