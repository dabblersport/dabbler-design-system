// Pins values from the live Claude Design project
// 4286affa-bf50-4ff6-9576-917f76a93ca1, files
// components/messaging/ReactionPicker.jsx and ReactionPicker.prompt.md
// (mirror of 2026-10-02).
import 'dart:ui' show Tristate;

import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/messaging/messaging_foundations.dart';
import 'package:dabbler_design_system/src/messaging/messaging_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';
import 'messaging_parts_host.dart';

DabblerIcon _glyph(WidgetTester t, String name) =>
    t.widget(find.byWidgetPredicate((w) => w is DabblerIcon && w.name == name));

void main() {
  testWidgets('six named 45px buttons inside a named group; active pressed', (
    tester,
  ) async {
    final h = tester.ensureSemantics();
    final List<String> got = <String>[];
    await tester.pumpWidget(
      partsHost(
        DabblerReactionPicker(onPick: got.add, active: const <String>['heart']),
      ),
    );
    expect(find.bySemanticsLabel('React'), findsOneWidget);
    for (final DabblerReactionDef r in DabblerReactions.all) {
      final Finder f = find.bySemanticsLabel(r.label);
      expect(tester.getSize(f), const Size(45, 45));
      expect(
        tester.getSemantics(f).flagsCollection.isToggled,
        r.key == 'heart' ? Tristate.isTrue : Tristate.isFalse,
      );
    }
    await tester.tap(find.bySemanticsLabel('Running late'));
    expect(got, <String>['late']);
    h.dispose();
  });

  testWidgets(
    'geometry: 6px padding, 3px gaps, 1px hairline → 6×45+5×3+2×6+2',
    (tester) async {
      await tester.pumpWidget(
        partsHost(
          const Align(
            alignment: AlignmentDirectional.topStart,
            child: DabblerReactionPicker(),
          ),
        ),
      );
      final Size s = tester.getSize(find.byType(DabblerReactionPicker));
      expect(s.width, 6 * 45 + 5 * 3 + 2 * 6 + 2);
      expect(s.height, 45 + 2 * 6 + 2);
      final BoxDecoration d =
          tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.byType(DabblerReactionPicker),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;
      final c = partsColors();
      expect(d.color, c.surfaceCard);
      expect((d.border! as Border).top.color, c.borderDefault);
      expect((d.border! as Border).top.width, 1);
    },
  );

  testWidgets('active fills brand with a bold on-brand 19px glyph; idle is '
      'unfilled with the secondary ink', (tester) async {
    await tester.pumpWidget(
      partsHost(const DabblerReactionPicker(active: <String>['heart'])),
    );
    final c = partsColors();
    final DabblerIcon on = _glyph(tester, 'heart');
    expect(on.weight, DabblerIconWeight.bold);
    expect(on.color, c.onBrand);
    expect(on.size, 19);
    final DabblerIcon idle = _glyph(tester, 'star');
    expect(idle.weight, DabblerIconWeight.linear);
    expect(idle.color, c.textSecondary);
    final Container idleBox = tester.widget(
      find
          .ancestor(of: find.byWidget(idle), matching: find.byType(Container))
          .first,
    );
    expect(idleBox.decoration, isNull);
    final Container onBox = tester.widget(
      find
          .ancestor(of: find.byWidget(on), matching: find.byType(Container))
          .first,
    );
    expect((onBox.decoration! as BoxDecoration).color, c.brandPrimary);
  });

  testWidgets('RTL: the first reaction sits at the right', (tester) async {
    await tester.pumpWidget(
      partsHost(const DabblerReactionPicker(), direction: TextDirection.rtl),
    );
    expect(
      tester.getCenter(find.byWidget(_glyph(tester, 'tick-circle'))).dx,
      greaterThan(tester.getCenter(find.byWidget(_glyph(tester, 'star'))).dx),
    );
  });

  testWidgets('renders a PNG in both directions', (tester) async {
    for (final TextDirection d in TextDirection.values) {
      final f = await renderPng(
        tester,
        const DabblerReactionPicker(active: <String>['in', 'heart']),
        name: 'reaction_picker_${d.name}',
        size: const Size(320, 70),
        direction: d,
        alignment: Alignment.center,
      );
      expect(f.lengthSync(), greaterThan(0));
    }
  });
}
