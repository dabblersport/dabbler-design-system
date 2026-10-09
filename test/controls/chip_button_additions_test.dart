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

  // KAN-457: the Create Post composer's selection tags share one geometry.
  for (final TextDirection dir in _dirs) {
    for (final Brightness b in Brightness.values) {
      testWidgets(
        'composerTag: vibe, sport, location, game are one height and centre '
        'line, wrap on a phone, and keep their colours '
        '(${dir.name}, ${b.name})',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(320, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          const String long =
              'Al Quoz Industrial Area 3, Sheikh Zayed Road, Dubai';
          await tester.pumpWidget(
            host(
              const Align(
                alignment: AlignmentDirectional.topStart,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    DabblerChip.composerTag(
                      label: 'Disappointed',
                      vibe: DabblerVibe.disappointed,
                    ),
                    DabblerChip.composerTag(label: 'GYM'),
                    DabblerChip.composerTag(label: 'Al Quoz'),
                    DabblerChip.composerTag(label: 'Saturday 5-a-side'),
                    DabblerChip.composerTag(label: long),
                  ],
                ),
              ),
              direction: dir,
              brightness: b,
            ),
          );
          expect(tester.takeException(), isNull);
          final List<DabblerChip> chips = tester
              .widgetList<DabblerChip>(find.byType(DabblerChip))
              .toList();
          final List<Rect> rects = <Rect>[
            for (int i = 0; i < chips.length; i++)
              tester.getRect(find.byType(DabblerChip).at(i)),
          ];
          final double h = rects.first.height;
          for (final Rect r in rects) {
            expect(r.height, h, reason: 'one shared height');
            expect(r.right <= 320 + 0.01 && r.left >= -0.01, isTrue);
          }
          // Rows are whole multiples of height + gap: tags on one line share
          // its top and centre, and the long row wrapped to a later line.
          for (final Rect r in rects) {
            expect(((r.top - rects.first.top) % (h + 8)).abs() < 0.01, isTrue);
          }
          expect(rects.last.top > rects.first.top, isTrue, reason: 'wrapped');
          // Same height as the plain static regular chip.
          expect(h, closeTo(DabblerChip.visualHeight, 3.01));
          // The long label is bounded by the row, not overflowing it.
          expect(rects[4].width <= 320, isTrue);
          // Colours: the vibe keeps its vibe surface, the rest the card.
          final DabblerColors c = DabblerColors.of(
            tester.element(find.byType(DabblerChip).first),
          );
          final DabblerVibeColors v = DabblerVibe.disappointed.resolve(c);
          final List<DabblerSurface> s = tester
              .widgetList<DabblerSurface>(find.byType(DabblerSurface))
              .toList();
          expect(s[0].fill, v.selectedSurface);
          expect(s[1].fill, isNull);
          expect(s[2].fill, isNull);
          // Static: no 45 box in the layout.
          expect(
            find.byType(ConstrainedBox).evaluate().where((e) {
              final ConstrainedBox cb = e.widget as ConstrainedBox;
              return cb.constraints.minHeight == 45;
            }),
            isEmpty,
          );
        },
      );
    }
  }

  testWidgets('ellipsize is off by default, so existing chips never shrink', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _h(const DabblerChip(label: 'x'), TextDirection.ltr),
    );
    expect(
      tester.widget<DabblerChip>(find.byType(DabblerChip)).ellipsize,
      isFalse,
    );
    expect(find.byType(Flexible), findsNothing);
  });
}
