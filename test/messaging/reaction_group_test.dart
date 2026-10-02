// Pins values from the live Claude Design project
// 4286affa-bf50-4ff6-9576-917f76a93ca1, files
// components/messaging/ReactionGroup.jsx and ReactionGroup.prompt.md
// (mirror of 2026-10-02).
import 'dart:ui' show Tristate;

import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/messaging/messaging_parts.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';
import 'messaging_parts_host.dart';

const List<DabblerMessageReaction> _rx = <DabblerMessageReaction>[
  DabblerMessageReaction(key: 'in', count: 3, mine: true),
  DabblerMessageReaction(key: 'late', count: 12),
];

BoxDecoration _pill(WidgetTester t, String count) =>
    t
            .widget<DecoratedBox>(
              find
                  .ancestor(
                    of: find.text(count),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

void main() {
  testWidgets('renders nothing with no tallies and no add', (tester) async {
    await tester.pumpWidget(partsHost(const DabblerReactionGroup()));
    expect(find.byType(Wrap), findsNothing);
  });

  testWidgets('labels read "I\'m in · 3", pressed state is exposed, '
      'tap returns the key', (tester) async {
    final h = tester.ensureSemantics();
    final List<String> got = <String>[];
    await tester.pumpWidget(
      partsHost(DabblerReactionGroup(reactions: _rx, onToggle: got.add)),
    );
    final Finder mine = find.bySemanticsLabel("I'm in · 3");
    final Finder other = find.bySemanticsLabel('Running late · 12');
    expect(tester.getSemantics(mine).flagsCollection.isButton, isTrue);
    expect(
      tester.getSemantics(mine).flagsCollection.isToggled,
      Tristate.isTrue,
    );
    expect(
      tester.getSemantics(other).flagsCollection.isToggled,
      Tristate.isFalse,
    );
    await tester.tap(other);
    expect(got, <String>['late']);
    h.dispose();
  });

  testWidgets('45px targets around 24px pills', (tester) async {
    await tester.pumpWidget(
      partsHost(
        DabblerReactionGroup(reactions: _rx, onToggle: (_) {}, onAdd: () {}),
      ),
    );
    final Finder target = find.bySemanticsLabel("I'm in · 3");
    expect(tester.getSize(target).height, 45);
    expect(tester.getSize(target).width, greaterThanOrEqualTo(45));
    final Finder pill = find
        .ancestor(of: find.text('3'), matching: find.byType(DecoratedBox))
        .first;
    expect(tester.getSize(pill).height, 24);
    expect(
      tester.getSize(find.bySemanticsLabel('Add reaction')),
      const Size(45, 45),
    );
  });

  testWidgets('mine: 12% brand over the card, brand outline, bold brand glyph; '
      'not mine: card, outline, secondary ink', (tester) async {
    await tester.pumpWidget(
      partsHost(DabblerReactionGroup(reactions: _rx, onToggle: (_) {})),
    );
    final c = partsColors();
    final BoxDecoration m = _pill(tester, '3');
    expect(
      m.color,
      Color.alphaBlend(c.brandPrimary.withValues(alpha: 0.12), c.surfaceCard),
    );
    expect((m.border! as Border).top.color, c.brandPrimary);
    final BoxDecoration o = _pill(tester, '12');
    expect(o.color, c.surfaceCard);
    expect((o.border! as Border).top.color, c.borderDefault);
    expect(tester.widget<Text>(find.text('12')).style!.color, c.textSecondary);
    final DabblerIcon g = tester.widget(
      find.byWidgetPredicate(
        (w) => w is DabblerIcon && w.name == 'tick-circle',
      ),
    );
    expect(g.weight, DabblerIconWeight.bold);
    expect(g.size, 13);
    expect(g.color, c.brandPrimary);
  });

  testWidgets('idle ink follows dark mode (no light-only literal)', (
    tester,
  ) async {
    await tester.pumpWidget(
      partsHost(
        DabblerReactionGroup(reactions: _rx, onToggle: (_) {}),
        brightness: Brightness.dark,
      ),
    );
    expect(
      tester.widget<Text>(find.text('12')).style!.color,
      partsColors(Brightness.dark).textSecondary,
    );
  });

  for (final TextDirection dir in TextDirection.values) {
    testWidgets('target hugs its pill (45 wide, not the Wrap width) and sits '
        'at the inline start — ${dir.name}', (tester) async {
      await tester.pumpWidget(
        partsHost(
          DabblerReactionGroup(
            reactions: const <DabblerMessageReaction>[
              DabblerMessageReaction(key: 'in', count: 3),
            ],
            onToggle: (_) {},
          ),
          direction: dir,
        ),
      );
      final Rect target = tester.getRect(find.bySemanticsLabel("I'm in · 3"));
      final Rect row = tester.getRect(find.byType(Wrap));
      expect(target.height, 45);
      expect(target.width, lessThan(row.width));
      final Rect pill = tester.getRect(
        find
            .ancestor(of: find.text('3'), matching: find.byType(DecoratedBox))
            .first,
      );
      expect(target.width, pill.width < 45 ? 45 : pill.width);
      if (dir == TextDirection.ltr) {
        expect(target.left, row.left);
      } else {
        expect(target.right, row.right);
      }
    });
  }

  testWidgets('wraps with a 3px gap on both axes', (tester) async {
    await tester.pumpWidget(
      partsHost(DabblerReactionGroup(reactions: _rx, onToggle: (_) {})),
    );
    final Wrap w = tester.widget(find.byType(Wrap));
    expect(w.spacing, 3);
    expect(w.runSpacing, 3);
  });

  testWidgets('RTL: the first tally sits at the right; Arabic count metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      partsHost(
        DabblerReactionGroup(reactions: _rx, onToggle: (_) {}),
        direction: TextDirection.rtl,
      ),
    );
    expect(
      tester.getCenter(find.text('3')).dx,
      greaterThan(tester.getCenter(find.text('12')).dx),
    );
    final double latin = DabblerType.caption2
        .resolveForDirection(TextDirection.ltr)
        .fontSize!;
    expect(
      tester.widget<Text>(find.text('3')).style!.fontSize,
      closeTo(latin - 0.9, 0.001),
    );
  });

  testWidgets('renders a PNG in both directions', (tester) async {
    for (final TextDirection d in TextDirection.values) {
      final f = await renderPng(
        tester,
        DabblerReactionGroup(reactions: _rx, onToggle: (_) {}, onAdd: () {}),
        name: 'reaction_group_${d.name}',
        size: const Size(240, 60),
        direction: d,
        alignment: Alignment.center,
      );
      expect(f.lengthSync(), greaterThan(0));
    }
  });
}
