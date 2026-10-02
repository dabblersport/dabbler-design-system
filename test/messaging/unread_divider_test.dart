// Pins UnreadDivider.jsx (live project 4286affa-..., mirror 2026-10-02):
// paddingBlock/paddingInline var(--space-2)=6; Divider label with --faint
// overridden to --color-brand-primary; label .t-caption-2 700 brand.
// The 12px label gap comes from DabblerDivider's port of Divider.jsx
// (Divider.jsx itself is not in the mirror).
import 'package:dabbler_design_system/src/messaging/messaging_atoms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';
import 'atoms_host.dart';

void main() {
  Iterable<ColoredBox> rules(WidgetTester t) => t.widgetList<ColoredBox>(
    find.descendant(
      of: find.byType(DabblerUnreadDivider),
      matching: find.byType(ColoredBox),
    ),
  );

  testWidgets('label is caption-2 700 in brand, single line', (t) async {
    await t.pumpWidget(
      atomHost(const DabblerUnreadDivider(label: 'New messages')),
    );
    final Text text = t.widget<Text>(find.text('New messages'));
    expect(text.style!.fontWeight, FontWeight.w700);
    expect(text.style!.fontSize, 11);
    expect(text.style!.color, atomColors().brandPrimary);
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('two 1px rules in brand colour, 12 from the label', (t) async {
    await t.pumpWidget(
      atomHost(const DabblerUnreadDivider(label: 'New messages')),
    );
    final List<ColoredBox> r = rules(t).toList();
    expect(r, hasLength(2));
    for (final ColoredBox b in r) {
      expect(b.color, atomColors().brandPrimary);
      expect(t.getSize(find.byWidget(b)).height, 1);
    }
    final Rect label = t.getRect(find.text('New messages'));
    expect(label.left - t.getRect(find.byWidget(r[0])).right, 12);
    expect(t.getRect(find.byWidget(r[1])).left - label.right, 12);
  });

  testWidgets('6px padding on every side', (t) async {
    await t.pumpWidget(atomHost(const DabblerUnreadDivider(label: 'New')));
    final Rect whole = t.getRect(find.byType(DabblerUnreadDivider));
    final Rect first = t.getRect(find.byWidget(rules(t).first));
    final Rect last = t.getRect(find.byWidget(rules(t).last));
    expect(first.left - whole.left, 6);
    expect(whole.right - last.right, 6);
    final Rect label = t.getRect(find.text('New'));
    expect(label.top - whole.top, 6);
    expect(whole.bottom - label.bottom, 6);
  });

  testWidgets('RTL Arabic: Arabic caption-2 (10.1), label centred', (t) async {
    await t.pumpWidget(
      atomHost(
        const DabblerUnreadDivider(label: 'رسائل جديدة'),
        direction: TextDirection.rtl,
      ),
    );
    expect(
      t.widget<Text>(find.text('رسائل جديدة')).style!.fontSize,
      closeTo(10.1, 0.001),
    );
    final Rect whole = t.getRect(find.byType(DabblerUnreadDivider));
    expect(
      t.getRect(find.text('رسائل جديدة')).center.dx,
      closeTo(whole.center.dx, 0.01),
    );
  });

  testWidgets('one semantics node with the label, not a live region', (
    t,
  ) async {
    final SemanticsHandle h = t.ensureSemantics();
    await t.pumpWidget(
      atomHost(const DabblerUnreadDivider(label: 'New messages')),
    );
    expect(find.bySemanticsLabel('New messages'), findsOneWidget);
    expect(
      t.getSemantics(find.bySemanticsLabel('New messages')),
      isNot(matchesSemantics(label: 'New messages', isLiveRegion: true)),
    );
    h.dispose();
  });

  testWidgets('renders LTR and RTL PNGs', (t) async {
    for (final TextDirection d in TextDirection.values) {
      final f = await renderPng(
        t,
        SizedBox(
          width: 360,
          child: DabblerUnreadDivider(
            label: d == TextDirection.rtl ? 'رسائل جديدة' : 'New messages',
          ),
        ),
        name: 'unread_divider_${d.name}',
        size: const Size(360, 60),
        direction: d,
      );
      expect(f.lengthSync(), greaterThan(0));
    }
  });
}
