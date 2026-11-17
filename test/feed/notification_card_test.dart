// KAN-988: DabblerNotificationCard, the Notification Center row of
// NotificationRow.dc.html, with every part: leading avatar / pair / icon /
// sport, actor and verb, time, unread dot, menu, urgent, sub, excerpt,
// change, meta, people, actions, pending, result and menu. LTR and RTL.
import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

TextStyle _text(WidgetTester tester, String s) =>
    tester.widget<Text>(find.text(s)).style!;

BoxDecoration _deco(WidgetTester tester, Finder f) =>
    tester.widget<DecoratedBox>(f).decoration as BoxDecoration;

void main() {
  test('tones: the design TN table', () {
    final DabblerColors c = testColors();
    expect(DabblerNotificationTone.brand.of(c).surface, c.surfaceSunken);
    expect(DabblerNotificationTone.brand.of(c).ink, c.brandPrimary);
    expect(DabblerNotificationTone.ok.of(c).surface, c.success.surface);
    expect(DabblerNotificationTone.err.of(c).ink, c.error.strong);
    expect(DabblerNotificationTone.neutral.of(c).ink, c.textSecondary);
    expect(DabblerType.captionNotif.fontSize, 12);
    expect(DabblerType.captionNotif.latinLeading, 17);
  });

  for (final TextDirection dir in TextDirection.values) {
    final bool rtl = dir == TextDirection.rtl;
    final String d = rtl ? 'rtl' : 'ltr';
    double start(Rect outer, Rect inner) =>
        rtl ? outer.right - inner.right : inner.left - outer.left;

    testWidgets('shell: 12 padding, 40 leading, 12 gap; unread vs read — $d', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: <Widget>[
              DabblerNotificationCard(
                key: ValueKey<String>('u'),
                leading: DabblerNotificationIconTile(icon: 'game'),
                actor: 'Ahmed',
                verb: 'joined',
                time: '2m',
                unread: true,
              ),
              DabblerNotificationCard(
                key: ValueKey<String>('r'),
                leading: DabblerAvatar(
                  seed: 'Ahmed',
                  size: DabblerAvatarSize.sm,
                ),
                actor: 'Read',
              ),
            ],
          ),
          direction: dir,
        ),
      );
      final DabblerColors c = testColors();
      final Finder u = find.byKey(const ValueKey<String>('u'));
      final BoxDecoration ud = _deco(
        tester,
        find.descendant(of: u, matching: find.byType(DecoratedBox)).first,
      );
      expect(ud.color, c.surfaceCard);
      expect((ud.border! as Border).top.color, c.borderDefault);
      expect(ud.borderRadius, DabblerRadius.lgAll);
      final Finder r = find.byKey(const ValueKey<String>('r'));
      final BoxDecoration rd = _deco(
        tester,
        find.descendant(of: r, matching: find.byType(DecoratedBox)).first,
      );
      expect(rd.color, isNull);
      expect((rd.border! as Border).top.color, c.bgTertiary);
      final Rect card = tester.getRect(u);
      final Rect tile = tester.getRect(
        find.descendant(
          of: u,
          matching: find.byType(DabblerNotificationIconTile),
        ),
      );
      expect(tile.size, const Size(38, 38));
      // 1 border + 12 padding, then the 40 column centres the 38.
      expect(start(card, tile), 1 + 12 + 1);
      expect(tile.top - card.top, 1 + 12);
      final Rect actor = tester.getRect(
        find.textContaining('joined', findRichText: true).first,
      );
      expect(start(card, actor), 1 + 12 + 40 + 12);
      expect(_text(tester, '2m').fontSize, rtl ? 10.1 : 11);
      final Rect dot = tester.getRect(
        find.byKey(const ValueKey<String>('notif-card-unread')),
      );
      expect(dot.size, const Size(8, 8));
      expect(dot.top - card.top, 1 + 12 + 6);
      expect(
        find.byKey(const ValueKey<String>('notif-card-unread')),
        findsOneWidget,
      );
    });

    testWidgets('pair and sport leading — $d', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: <Widget>[
              DabblerNotificationAvatarPair(seed: 'A', seed2: 'B'),
              DabblerNotificationSportTile(sportKey: 'football'),
            ],
          ),
          direction: dir,
        ),
      );
      final Rect pair = tester.getRect(
        find.byType(DabblerNotificationAvatarPair),
      );
      expect(pair.size, const Size(40, 40));
      final List<Rect> avatars = tester
          .widgetList<DabblerAvatar>(find.byType(DabblerAvatar))
          .map((DabblerAvatar a) => tester.getRect(find.byWidget(a)))
          .toList();
      expect(avatars, hasLength(2));
      expect(avatars.first.width, closeTo(36 * 0.78, 0.01));
      expect(avatars.first.top, pair.top);
      expect(avatars.last.bottom, closeTo(pair.bottom, 0.01));
      if (rtl) {
        expect(avatars.first.right, closeTo(pair.right, 0.01));
        expect(avatars.last.left, closeTo(pair.left, 0.01));
      } else {
        expect(avatars.first.left, closeTo(pair.left, 0.01));
        expect(avatars.last.right, closeTo(pair.right, 0.01));
      }
      expect(
        tester.getSize(find.byType(DabblerNotificationSportTile)),
        const Size(38, 38),
      );
    });

    testWidgets('every part draws with the design metrics — $d', (
      WidgetTester tester,
    ) async {
      final List<String> taps = <String>[];
      await tester.pumpWidget(
        host(
          SingleChildScrollView(
            child: DabblerNotificationCard(
              leading: const DabblerNotificationIconTile(icon: 'game'),
              actor: 'Ahmed',
              verb: 'liked your post',
              time: '2m',
              unread: true,
              onMenu: () => taps.add('menu'),
              urgent: 'Action needed',
              sub: 'Sub line',
              excerpt: const DabblerNotificationExcerpt(
                label: 'Your post',
                text: 'Great run',
              ),
              change: const DabblerNotificationChange(
                label: 'Start',
                from: '8:00 PM',
                to: '9:00 PM',
              ),
              meta: const <DabblerNotificationMeta>[
                DabblerNotificationMeta('calendar', 'Thu'),
              ],
              people: DabblerNotificationPeople(
                toggleLabel: 'Hide people',
                open: true,
                onToggle: () => taps.add('people'),
                people: const <DabblerNotificationPerson>[
                  DabblerNotificationPerson(name: 'Hana', time: '9m'),
                ],
              ),
              actions: <DabblerNotificationCardAction>[
                DabblerNotificationCardAction(
                  'Approve',
                  primary: true,
                  onPressed: () => taps.add('approve'),
                ),
                const DabblerNotificationCardAction('Decline'),
              ],
              pending: 'Sending…',
              result: DabblerNotificationResult(
                icon: 'danger',
                text: 'Couldn’t approve.',
                tone: DabblerNotificationTone.err,
                linkLabel: 'Retry',
                onLink: () => taps.add('retry'),
              ),
              menu: <DabblerNotificationMenuItem>[
                DabblerNotificationMenuItem(
                  icon: 'tick-circle',
                  label: 'Mark as read',
                  onPressed: () => taps.add('read'),
                ),
              ],
            ),
          ),
          direction: dir,
        ),
      );
      final DabblerColors c = testColors();
      final double ar = rtl ? 0.9 : 0;
      // Urgent: warning surface and strong ink, 11/15 600.
      final Rect urgent = tester.getRect(
        find.byKey(const ValueKey<String>('notif-card-urgent')),
      );
      expect(urgent.height, 2 + 15 + 2);
      expect(_text(tester, 'Action needed').color, c.warning.strong);
      // Sub: 14 500 ink.
      expect(_text(tester, 'Sub line').fontSize, 14 - ar);
      expect(_text(tester, 'Sub line').fontWeight, FontWeight.w500);
      // Excerpt: label 11/15 600 muted, text 13 ink-soft.
      expect(_text(tester, 'Your post').color, c.textTertiary);
      expect(_text(tester, 'Great run').color, c.textSecondary);
      // Change: struck old value, 600 new value.
      expect(_text(tester, '8:00 PM').decoration, TextDecoration.lineThrough);
      expect(_text(tester, '9:00 PM').fontWeight, FontWeight.w600);
      // Meta: 12/17 muted.
      expect(_text(tester, 'Thu').fontSize, 12 - ar);
      expect(_text(tester, 'Thu').height! * (12 - ar), closeTo(17, 0.01));
      // People: brand toggle, open list.
      expect(_text(tester, 'Hide people').color, c.brandPrimary);
      expect(find.text('Hana'), findsOneWidget);
      await tester.tap(find.text('Hide people'));
      // Actions: 34 tall pills; primary brand.
      final Rect approve = tester.getRect(
        find
            .ancestor(
              of: find.text('Approve'),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(approve.height, 34);
      expect(_text(tester, 'Approve').color, c.onBrand);
      await tester.tap(find.text('Approve'));
      // Pending: 14 spinner.
      expect(
        tester.getSize(
          find.descendant(
            of: find.byKey(const ValueKey<String>('notif-card-pending')),
            matching: find.byType(FittedBox),
          ),
        ),
        const Size(14, 14),
      );
      // Result: the err tone, the Retry link.
      expect(
        _deco(
          tester,
          find.byKey(const ValueKey<String>('notif-card-result')),
        ).color,
        c.error.surface,
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('notif-card-result-link')),
      );
      // Menu: the ⋯ button 24x20; the open item 40 tall.
      expect(
        tester.getSize(find.byKey(const ValueKey<String>('notif-card-menu'))),
        const Size(24, 20),
      );
      await tester.tap(find.byKey(const ValueKey<String>('notif-card-menu')));
      await tester.tap(find.text('Mark as read'));
      expect(taps, <String>['people', 'approve', 'retry', 'menu', 'read']);
      expect(tester.takeException(), isNull);
    });
  }
}
