// Pins DateSeparator.jsx (live project 4286affa-..., mirror 2026-10-02):
// paddingBlock var(--space-2)=6; pill paddingInline --space-3=9,
// paddingBlock --space-1=3; --radius-pill; .t-caption-1 600 in --muted;
// background --surface-sunken.
import 'package:dabbler_design_system/src/messaging/messaging_atoms.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';
import 'atoms_host.dart';

void main() {
  Text label(WidgetTester t) => t.widget<Text>(find.text('Today'));

  testWidgets('label is caption-1 at weight 600 in secondary ink', (t) async {
    await t.pumpWidget(atomHost(const DabblerDateSeparator(label: 'Today')));
    final TextStyle s = label(t).style!;
    expect(s.fontWeight, FontWeight.w600);
    expect(s.fontSize, 12);
    expect(s.color, atomColors().textSecondary);
  });

  testWidgets('pill is sunken, pill-radius, 9 inline / 3 block', (t) async {
    await t.pumpWidget(atomHost(const DabblerDateSeparator(label: 'Today')));
    final DecoratedBox box = t.widget<DecoratedBox>(
      find
          .ancestor(of: find.text('Today'), matching: find.byType(DecoratedBox))
          .first,
    );
    final BoxDecoration d = box.decoration as BoxDecoration;
    expect(d.color, atomColors().surfaceSunken);
    expect(d.borderRadius, DabblerRadius.pillAll);
    final Rect pill = t.getRect(find.byWidget(box));
    final Rect text = t.getRect(find.text('Today'));
    expect(text.left - pill.left, 9);
    expect(pill.right - text.right, 9);
    expect(text.top - pill.top, 3);
    expect(pill.bottom - text.bottom, 3);
  });

  testWidgets('6px block band and horizontally centred', (t) async {
    await t.pumpWidget(atomHost(const DabblerDateSeparator(label: 'Today')));
    final Rect whole = t.getRect(find.byType(DabblerDateSeparator));
    final Rect pill = t.getRect(
      find
          .ancestor(of: find.text('Today'), matching: find.byType(DecoratedBox))
          .first,
    );
    expect(pill.top - whole.top, 6);
    expect(whole.bottom - pill.bottom, 6);
    expect(pill.center.dx, closeTo(whole.center.dx, 0.01));
  });

  testWidgets('RTL Arabic uses Arabic caption-1 (11.1) and stays centred', (
    t,
  ) async {
    await t.pumpWidget(
      atomHost(
        const DabblerDateSeparator(label: 'اليوم'),
        direction: TextDirection.rtl,
      ),
    );
    expect(
      t.widget<Text>(find.text('اليوم')).style!.fontSize,
      closeTo(11.1, 0.001),
    );
    final Rect whole = t.getRect(find.byType(DabblerDateSeparator));
    expect(
      t.getRect(find.text('اليوم')).center.dx,
      closeTo(whole.center.dx, 0.01),
    );
  });

  testWidgets('label is exposed to semantics as given', (t) async {
    final SemanticsHandle h = t.ensureSemantics();
    await t.pumpWidget(atomHost(const DabblerDateSeparator(label: 'Today')));
    expect(find.bySemanticsLabel('Today'), findsOneWidget);
    h.dispose();
  });

  testWidgets('renders LTR and RTL PNGs', (t) async {
    for (final TextDirection d in TextDirection.values) {
      final f = await renderPng(
        t,
        SizedBox(
          width: 360,
          child: DabblerDateSeparator(
            label: d == TextDirection.rtl
                ? 'السبت، 14 سبتمبر'
                : 'Saturday, 14 September',
          ),
        ),
        name: 'date_separator_${d.name}',
        size: const Size(360, 60),
        direction: d,
      );
      expect(f.lengthSync(), greaterThan(0));
    }
  });
}
