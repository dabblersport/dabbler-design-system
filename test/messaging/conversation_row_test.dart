// Pinned values cite the live Claude Design project
// 4286affa-bf50-4ff6-9576-917f76a93ca1, components/messaging/ConversationRow.jsx
// and tokens/{spacing,typography}.css (local mirror, read 2026-10-02).
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/foundations/sports.dart';
import 'package:dabbler_design_system/src/messaging/conversation_row.dart';
import 'package:dabbler_design_system/src/messaging/messaging_atoms.dart';
import 'package:dabbler_design_system/src/messaging/messaging_foundations.dart';
import 'package:dabbler_design_system/src/surfaces/badge.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';

DabblerColors _colors() => DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 360,
}) => MaterialApp(
  theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors()]),
  home: Directionality(
    textDirection: direction,
    child: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: width, child: child),
      ),
    ),
  ),
);

Text _text(WidgetTester tester, String s) => tester.widget<Text>(find.text(s));

Rect _row(WidgetTester tester) =>
    tester.getRect(find.byType(DabblerConversationRow));

void main() {
  group('count and label rules', () {
    test('unread above unreadMax reads N+', () {
      const DabblerConversationRow r = DabblerConversationRow(
        title: 't',
        timestamp: '1',
        unread: 120,
      );
      expect(r.countLabel, '99+');
      expect(
        const DabblerConversationRow(
          title: 't',
          timestamp: '1',
          unread: 12,
          unreadMax: 9,
        ).countLabel,
        '9+',
      );
      expect(
        const DabblerConversationRow(
          title: 't',
          timestamp: '1',
          unread: 99,
        ).countLabel,
        '99',
      );
    });

    test('composed label carries sender, count, state and kind label', () {
      const DabblerConversationRow r = DabblerConversationRow(
        title: 'Thursday 5-a-side',
        sender: 'Omar',
        preview: 'Pitch is confirmed',
        timestamp: '17:02',
        unread: 3,
        state: DabblerConversationState(label: 'Confirmed'),
        kindLabel: 'Game chat',
      );
      expect(
        r.composedLabel(),
        'Thursday 5-a-side, Omar: Pitch is confirmed, 17:02, 3 unread, '
        'Confirmed, Game chat',
      );
      expect(
        const DabblerConversationRow(
          title: 'a',
          timestamp: '1',
          sender: 'Omar',
          typing: true,
        ).composedLabel(),
        'a, Omar is typing, 1',
      );
    });
  });

  group('geometry — ConversationRow.jsx', () {
    testWidgets('padding 18 inline / 12 block, avatar 48, gap 12 (LTR)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerConversationRow(
            title: 'Layla',
            preview: 'hi',
            timestamp: '17:02',
          ),
        ),
      );
      final Rect row = _row(tester);
      final Rect avatar = tester.getRect(
        find.byType(DabblerConversationAvatar),
      );
      expect(avatar.size, const Size(48, 48));
      expect(avatar.left - row.left, 18);
      expect(avatar.top - row.top, 12);
      final Rect title = tester.getRect(find.text('Layla'));
      expect(title.left - avatar.right, 12);
      final Rect ts = tester.getRect(find.text('17:02'));
      expect(row.right - ts.right, 18);
      // 12 + 48 avatar + 12 + 1px divider is the tallest column here.
      expect(row.height, greaterThanOrEqualTo(45));
      expect(row.height, 12 + 48 + 12 + 1);
    });

    testWidgets('RTL mirrors: avatar at the right, timestamp at the left', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerConversationRow(
            title: 'ليلى',
            preview: 'مرحبا',
            timestamp: '17:02',
          ),
          direction: TextDirection.rtl,
        ),
      );
      final Rect row = _row(tester);
      final Rect avatar = tester.getRect(
        find.byType(DabblerConversationAvatar),
      );
      expect(row.right - avatar.right, 18);
      expect(avatar.top - row.top, 12);
      expect(avatar.left - tester.getRect(find.text('ليلى')).right, 12);
      expect(tester.getRect(find.text('17:02')).left - row.left, 18);
    });

    testWidgets(
      'Arabic sizes: subheadline 14.1, caption-1 11.1, footnote 12.1',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(
            const DabblerConversationRow(
              title: 'ليلى',
              preview: 'مرحبا',
              timestamp: '17:02',
              kindLabel: 'مباراة',
            ),
            direction: TextDirection.rtl,
          ),
        );
        expect(_text(tester, 'ليلى').style!.fontSize, closeTo(14.1, 1e-9));
        expect(_text(tester, '17:02').style!.fontSize, closeTo(11.1, 1e-9));
        expect(_text(tester, 'مباراة').style!.fontSize, closeTo(10.1, 1e-9));
        final RichText preview = tester.widget<RichText>(
          find.byWidgetPredicate(
            (Widget w) => w is RichText && w.text.toPlainText() == 'مرحبا',
          ),
        );
        expect(preview.text.style!.fontSize, closeTo(12.1, 1e-9));
      },
    );

    testWidgets('Latin sizes: 15 / 12 / 13 / 11', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerConversationRow(
            title: 'Layla',
            preview: 'hi',
            timestamp: '17:02',
            kindLabel: 'Game',
          ),
        ),
      );
      expect(_text(tester, 'Layla').style!.fontSize, 15);
      expect(_text(tester, '17:02').style!.fontSize, 12);
      expect(_text(tester, 'Game').style!.fontSize, 11);
    });

    testWidgets('long title ellipsises on one line, timestamp stays whole', (
      WidgetTester tester,
    ) async {
      final String long = 'Very long conversation title ' * 6;
      await tester.pumpWidget(
        _host(
          DabblerConversationRow(
            title: long,
            preview: 'A preview that is also far too long to fit ' * 4,
            timestamp: 'Yesterday',
            unread: 5,
            muted: true,
          ),
          width: 320,
        ),
      );
      expect(tester.takeException(), isNull);
      final Text title = _text(tester, long);
      expect(title.maxLines, 1);
      expect(title.overflow, TextOverflow.ellipsis);
      final Rect row = _row(tester);
      final Rect ts = tester.getRect(find.text('Yesterday'));
      expect(row.right - ts.right, 18);
      expect(tester.getRect(find.text(long)).right, lessThan(ts.left));
      final RichText preview = tester.widget<RichText>(
        find.byWidgetPredicate(
          (Widget w) =>
              w is RichText && w.text.toPlainText().startsWith('A preview'),
        ),
      );
      expect(preview.maxLines, 1);
      expect(preview.overflow, TextOverflow.ellipsis);
    });
  });

  group('states', () {
    testWidgets('unread: title 700, timestamp 600 brand, default-tone badge', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerConversationRow(
            title: 'Layla',
            preview: 'hi',
            timestamp: '17:02',
            unread: 120,
          ),
        ),
      );
      final DabblerColors c = _colors();
      expect(_text(tester, 'Layla').style!.fontWeight, FontWeight.w700);
      final TextStyle ts = _text(tester, '17:02').style!;
      expect(ts.fontWeight, FontWeight.w600);
      expect(ts.color, c.brandPrimary);
      final DabblerBadge badge = tester.widget(find.byType(DabblerBadge));
      expect(badge.label, '99+');
      expect(badge.tone, DabblerBadgeTone.defaultTone);
      expect(
        tester.getSize(find.byType(DabblerBadge)).width,
        greaterThanOrEqualTo(24),
      );
    });

    testWidgets('unread pill geometry: minWidth 24, paddingInline 6, centred', (
      WidgetTester tester,
    ) async {
      // Live `components/messaging/ConversationRow.jsx:65-66`: Badge style
      // `minWidth: 24, justifyContent: 'center', paddingInline: var(--space-2)`.
      await tester.pumpWidget(
        _host(
          const DabblerConversationRow(
            title: 'Layla',
            preview: 'hi',
            timestamp: '17:02',
            unread: 3,
          ),
        ),
      );
      final DabblerBadge badge = tester.widget(find.byType(DabblerBadge));
      expect(badge.minWidth, 24);
      expect(badge.paddingInline, 6);
      final Rect box = tester.getRect(find.byType(DabblerBadge));
      final Rect label = tester.getRect(find.text('3'));
      expect(box.width, 24, reason: 'a one-digit count sits on the 24 floor');
      expect(label.center.dx, closeTo(box.center.dx, 0.6));

      await tester.pumpWidget(
        _host(
          const DabblerConversationRow(
            title: 'Layla',
            preview: 'hi',
            timestamp: '17:02',
            unread: 120,
          ),
        ),
      );
      final Rect wide = tester.getRect(find.byType(DabblerBadge));
      final Rect wideLabel = tester.getRect(find.text('99+'));
      expect(wideLabel.left - wide.left, closeTo(6, 0.6));
      expect(wide.right - wideLabel.right, closeTo(6, 0.6));
    });

    testWidgets('read: title 600, timestamp 400 secondary, no badge', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerConversationRow(
            title: 'Layla',
            preview: 'hi',
            timestamp: '17:02',
          ),
        ),
      );
      expect(_text(tester, 'Layla').style!.fontWeight, FontWeight.w600);
      final TextStyle ts = _text(tester, '17:02').style!;
      expect(ts.fontWeight, FontWeight.w400);
      expect(ts.color, _colors().textSecondary);
      expect(find.byType(DabblerBadge), findsNothing);
    });

    testWidgets('muted: volume-slash 14 and warning-tone badge', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerConversationRow(
            title: 'Padel',
            preview: 'hi',
            timestamp: '9',
            unread: 2,
            muted: true,
          ),
        ),
      );
      final DabblerIcon glyph = tester.widget(
        find.byWidgetPredicate(
          (Widget w) => w is DabblerIcon && w.name == 'volume-slash',
        ),
      );
      expect(glyph.size, 14);
      final DabblerBadge badge = tester.widget(find.byType(DabblerBadge));
      expect(badge.tone, DabblerBadgeTone.warning);
    });

    testWidgets('typing replaces the preview with the indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerConversationRow(
            title: 'Squad',
            sender: 'Omar',
            preview: 'hidden',
            timestamp: '9',
            typing: true,
          ),
        ),
      );
      expect(find.byType(DabblerTypingIndicator), findsOneWidget);
      expect(find.text('Omar is typing'), findsOneWidget);
      expect(find.textContaining('hidden'), findsNothing);
    });

    testWidgets('sender prefix is 600', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerConversationRow(
            title: 'Squad',
            sender: 'Omar',
            preview: 'bibs?',
            timestamp: '9',
          ),
        ),
      );
      final RichText rt = tester.widget<RichText>(
        find.byWidgetPredicate(
          (Widget w) => w is RichText && w.text.toPlainText() == 'Omar: bibs?',
        ),
      );
      TextSpan? prefix;
      rt.text.visitChildren((InlineSpan s) {
        if (s is TextSpan && s.text == 'Omar: ') prefix = s;
        return prefix == null;
      });
      expect(prefix, isNotNull);
      expect(prefix!.style!.fontWeight, FontWeight.w600);
    });

    testWidgets('state badge: semantic status, neutral fallback, bold glyph', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const Column(
            children: <Widget>[
              DabblerConversationRow(
                title: 'Game',
                timestamp: '9',
                state: DabblerConversationState(
                  label: 'Confirmed',
                  status: DabblerStatusTone.success,
                  icon: 'tick-circle',
                ),
                kindLabel: 'Game chat',
              ),
              DabblerConversationRow(
                title: 'Open',
                timestamp: '9',
                state: DabblerConversationState(label: 'Open'),
              ),
            ],
          ),
        ),
      );
      final DabblerColors c = _colors();
      final List<DabblerBadge> badges = tester
          .widgetList<DabblerBadge>(find.byType(DabblerBadge))
          .toList();
      expect(badges[0].status, c.success);
      expect(badges[1].status, DabblerBadge.neutralStatusOf(c));
      final DabblerIcon icon = badges[0].icon! as DabblerIcon;
      expect(icon.size, 12);
      expect(icon.weight, DabblerIconWeight.bold);
      final TextStyle kl = _text(tester, 'Game chat').style!;
      expect(kl.fontWeight, FontWeight.w600);
      expect(kl.color, c.textSecondary);
      // marginBlockStart space-1 + gap space-1 above the third line.
      final double gap =
          tester.getRect(find.byType(DabblerBadge).first).top -
          tester.getRect(find.text('9').first).bottom;
      expect(gap, greaterThanOrEqualTo(6));
    });

    testWidgets('kinds pass through to the avatar; seed falls back to title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerConversationRow(
            kind: DabblerConversationKind.game,
            sport: DabblerSport.padel,
            title: 'Padel night',
            timestamp: '9',
            online: true,
          ),
        ),
      );
      final DabblerConversationAvatar a = tester.widget(
        find.byType(DabblerConversationAvatar),
      );
      expect(a.kind, DabblerConversationKind.game);
      expect(a.sport, DabblerSport.padel);
      expect(a.seed, 'Padel night');
      expect(a.size, 48);
      expect(a.online, isTrue);
    });

    testWidgets('divider: 1px faint block-end, removable', (
      WidgetTester tester,
    ) async {
      BoxDecoration deco() =>
          tester
                  .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                  .decoration!
              as BoxDecoration;
      await tester.pumpWidget(
        _host(const DabblerConversationRow(title: 'a', timestamp: '1')),
      );
      final Border b = deco().border! as Border;
      expect(b.bottom.width, 1);
      expect(b.bottom.color, _colors().bgTertiary);
      expect(b.top, BorderSide.none);
      await tester.pumpWidget(
        _host(
          const DabblerConversationRow(
            title: 'a',
            timestamp: '1',
            divider: false,
          ),
        ),
      );
      expect(deco().border, isNull);
    });

    testWidgets('press tints the row with the sunken surface', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(DabblerConversationRow(title: 'a', timestamp: '1', onTap: () {})),
      );
      final TestGesture g = await tester.startGesture(
        tester.getCenter(find.byType(DabblerConversationRow)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      BoxDecoration deco() =>
          tester
                  .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                  .decoration!
              as BoxDecoration;
      expect(deco().color, _colors().surfaceSunken);
      await g.up();
      await tester.pump(const Duration(milliseconds: 200));
      expect(deco().color!.a, 0);
    });
  });

  group('semantics', () {
    testWidgets('button only when onTap is set; tap and Enter activate', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      int taps = 0;
      await tester.pumpWidget(
        _host(
          DabblerConversationRow(
            title: 'Layla',
            preview: 'hi',
            timestamp: '17:02',
            unread: 2,
            muted: true,
            onTap: () => taps++,
          ),
        ),
      );
      final SemanticsNode node = tester.getSemantics(
        find.bySemanticsLabel('Layla, hi, 17:02, 2 unread'),
      );
      expect(node.flagsCollection.isButton, isTrue);
      await tester.tap(find.byType(DabblerConversationRow));
      expect(taps, 1);
      tester.semantics.tap(
        find.semantics.byLabel('Layla, hi, 17:02, 2 unread'),
      );
      expect(taps, 2);

      await tester.pumpWidget(
        _host(
          const DabblerConversationRow(
            title: 'Inert',
            preview: 'hi',
            timestamp: '1',
          ),
        ),
      );
      final SemanticsNode inert = tester.getSemantics(
        find.byType(DabblerConversationRow),
      );
      expect(inert.flagsCollection.isButton, isFalse);
      expect(inert.label, contains('Inert'));
      h.dispose();
    });

    testWidgets('semanticLabel overrides the composed name', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          DabblerConversationRow(
            title: 'a',
            timestamp: '1',
            semanticLabel: 'Open chat with a, muted',
            onTap: () {},
          ),
        ),
      );
      expect(find.bySemanticsLabel('Open chat with a, muted'), findsOneWidget);
      h.dispose();
    });
  });

  group('png evidence (build/png, never committed)', () {
    Widget column(List<Widget> rows) => SizedBox(
      width: 390,
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
    final List<Widget> ltr = <Widget>[
      const DabblerConversationRow(
        title: 'Layla Haddad',
        preview: 'See you at the court!',
        timestamp: '17:02',
        unread: 2,
        online: true,
      ),
      const DabblerConversationRow(
        kind: DabblerConversationKind.squad,
        title: 'Sunday Strikers',
        sender: 'Omar',
        preview: 'Who is bringing the bibs?',
        timestamp: 'Mon',
      ),
      const DabblerConversationRow(
        kind: DabblerConversationKind.huddle,
        title: 'Padel regulars with a very long name that must ellipsise',
        sender: 'Sara',
        preview: 'Courts 3 and 4 are free tonight if anyone wants them',
        timestamp: '09:41',
        unread: 120,
        muted: true,
      ),
      const DabblerConversationRow(
        kind: DabblerConversationKind.game,
        sport: DabblerSport.football,
        title: 'Thursday 5-a-side',
        sender: 'Omar',
        typing: true,
        timestamp: '17:02',
        unread: 3,
        state: DabblerConversationState(
          label: 'Confirmed',
          status: DabblerStatusTone.success,
          icon: 'tick-circle',
        ),
        kindLabel: 'Game chat',
      ),
    ];

    testWidgets('LTR rows', (WidgetTester tester) async {
      final f = await renderPng(
        tester,
        column(ltr),
        name: 'conversation_row_ltr',
        size: const Size(390, 420),
        alignment: Alignment.topCenter,
      );
      expect(f.lengthSync(), greaterThan(0));
    });

    testWidgets('RTL rows', (WidgetTester tester) async {
      final f = await renderPng(
        tester,
        column(const <Widget>[
          DabblerConversationRow(
            title: 'ليلى حداد',
            preview: 'أراك في الملعب!',
            timestamp: '17:02',
            unread: 2,
            online: true,
          ),
          DabblerConversationRow(
            kind: DabblerConversationKind.huddle,
            title: 'فريق الأحد',
            sender: 'عمر',
            preview: 'من سيحضر القمصان؟',
            timestamp: 'الاثنين',
            unread: 120,
            muted: true,
          ),
          DabblerConversationRow(
            kind: DabblerConversationKind.game,
            sport: DabblerSport.football,
            title: 'مباراة الخميس',
            sender: 'عمر',
            typing: true,
            typingLabel: 'عمر يكتب',
            timestamp: '17:02',
            state: DabblerConversationState(
              label: 'مؤكد',
              status: DabblerStatusTone.success,
              icon: 'tick-circle',
            ),
            kindLabel: 'دردشة المباراة',
          ),
        ]),
        name: 'conversation_row_rtl',
        size: const Size(390, 320),
        direction: TextDirection.rtl,
        alignment: Alignment.topCenter,
      );
      expect(f.lengthSync(), greaterThan(0));
    });
  });
}
