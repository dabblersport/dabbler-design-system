// Pins SystemMessage.jsx (live project 4286affa-..., mirror 2026-10-02):
// role="status"; gap --space-2=6; paddingBlock SPACING.systemBlock=3;
// paddingInline --space-6=18; icon size 14 aria-hidden, --subtle / success
// strong; text .t-caption-1 --muted / success strong; timestamp span --muted.
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/messaging/messaging_atoms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';
import 'atoms_host.dart';

void main() {
  Finder line() =>
      find.byWidgetPredicate((w) => w is Text && w.textSpan != null);
  ({InlineSpan text}) rich(WidgetTester t) =>
      (text: t.widget<Text>(line()).textSpan!);

  test('tone and positive shorthand both select the success tone', () {
    expect(const DabblerSystemMessage(text: 'x').isPositive, isFalse);
    expect(
      const DabblerSystemMessage(text: 'x', positive: true).isPositive,
      isTrue,
    );
    expect(
      const DabblerSystemMessage(
        text: 'x',
        tone: DabblerSystemMessageTone.positive,
      ).isPositive,
      isTrue,
    );
  });

  testWidgets('neutral: caption-1 secondary text, tertiary glyph', (t) async {
    await t.pumpWidget(
      atomHost(const DabblerSystemMessage(text: 'Mina left', icon: 'people')),
    );
    final TextSpan root = rich(t).text as TextSpan;
    expect(root.style!.fontSize, 12);
    expect(root.style!.color, atomColors().textSecondary);
    final DabblerIcon icon = t.widget<DabblerIcon>(find.byType(DabblerIcon));
    expect(icon.size, 14);
    expect(icon.color, atomColors().textTertiary);
  });

  testWidgets('positive tints text and glyph; timestamp stays muted', (
    t,
  ) async {
    await t.pumpWidget(
      atomHost(
        const DabblerSystemMessage(
          text: 'Booking confirmed',
          icon: 'tick-circle',
          timestamp: '18:45',
          tone: DabblerSystemMessageTone.positive,
        ),
      ),
    );
    final TextSpan root = rich(t).text as TextSpan;
    expect(root.style!.color, atomColors().success.strong);
    final TextSpan ts = root.children!.single as TextSpan;
    expect(ts.text, ' · 18:45');
    expect(ts.style!.color, atomColors().textSecondary);
    expect(
      t.widget<DabblerIcon>(find.byType(DabblerIcon)).color,
      atomColors().success.strong,
    );
  });

  testWidgets('geometry: 3 block, 6 gap, centred, 18 inline floor', (t) async {
    await t.pumpWidget(
      atomHost(const DabblerSystemMessage(text: 'Mina joined', icon: 'people')),
    );
    final Rect whole = t.getRect(find.byType(DabblerSystemMessage));
    final Rect icon = t.getRect(find.byType(DabblerIcon));
    final Rect text = t.getRect(line());
    expect(text.left - icon.right, 6);
    expect(text.top - whole.top, 3);
    expect(whole.bottom - text.bottom, 3);
    expect(
      ((icon.left - whole.left) - (whole.right - text.right)).abs(),
      lessThan(0.5),
    );
    // A long line wraps inside the 18px inline padding.
    await t.pumpWidget(
      atomHost(DabblerSystemMessage(text: 'word ' * 40), width: 200),
    );
    final Rect w2 = t.getRect(find.byType(DabblerSystemMessage));
    final Rect t2 = t.getRect(line());
    expect(t2.left - w2.left, greaterThanOrEqualTo(18));
    expect(w2.right - t2.right, greaterThanOrEqualTo(18));
  });

  testWidgets('RTL: glyph at the inline start (right), Arabic caption-1', (
    t,
  ) async {
    await t.pumpWidget(
      atomHost(
        const DabblerSystemMessage(text: 'انضمت مينا', icon: 'people'),
        direction: TextDirection.rtl,
      ),
    );
    final Rect icon = t.getRect(find.byType(DabblerIcon));
    final Rect text = t.getRect(line());
    expect(icon.left - text.right, 6);
    expect((rich(t).text as TextSpan).style!.fontSize, closeTo(11.1, 0.001));
  });

  testWidgets('status live region; glyph hidden from semantics', (t) async {
    final SemanticsHandle h = t.ensureSemantics();
    await t.pumpWidget(
      atomHost(
        const DabblerSystemMessage(
          text: 'Mina joined',
          icon: 'people',
          timestamp: '18:42',
        ),
      ),
    );
    expect(find.bySemanticsLabel('Mina joined · 18:42'), findsOneWidget);
    expect(
      t.getSemantics(find.byType(DabblerSystemMessage)),
      matchesSemantics(isLiveRegion: true, label: 'Mina joined · 18:42'),
    );
    h.dispose();
  });

  testWidgets('renders LTR and RTL PNGs', (t) async {
    for (final TextDirection d in TextDirection.values) {
      final bool rtl = d == TextDirection.rtl;
      final f = await renderPng(
        t,
        SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DabblerSystemMessage(
                text: rtl ? 'غادرت مينا المباراة' : 'Mina left the game',
              ),
              DabblerSystemMessage(
                icon: 'people',
                text: rtl ? 'دعا عمر سارة' : 'Omar invited Sara',
                timestamp: '18:42',
              ),
              DabblerSystemMessage(
                icon: 'tick-circle',
                text: rtl ? 'تم تأكيد الحجز' : 'Booking confirmed',
                timestamp: '18:45',
                tone: DabblerSystemMessageTone.positive,
              ),
            ],
          ),
        ),
        name: 'system_message_${d.name}',
        size: const Size(360, 90),
        direction: d,
      );
      expect(f.lengthSync(), greaterThan(0));
    }
  });
}
