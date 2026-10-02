// Pinned values cite the live Claude Design project
// 4286affa-bf50-4ff6-9576-917f76a93ca1, components/messaging/
// ConversationContext.jsx and messaging.jsx (GAME_STATUS), read via DesignSync
// get_file on 2026-10-02 and transcribed to a local mirror by the coordinator.
import 'dart:ui' show Tristate;

import 'package:dabbler_design_system/src/controls/button.dart';
import 'package:dabbler_design_system/src/foundations/sports.dart';
import 'package:dabbler_design_system/src/layout/divider.dart';
import 'package:dabbler_design_system/src/messaging/conversation_context.dart';
import 'package:dabbler_design_system/src/messaging/messaging_foundations.dart';
import 'package:dabbler_design_system/src/surfaces/avatar.dart';
import 'package:dabbler_design_system/src/surfaces/badge.dart';
import 'package:dabbler_design_system/src/surfaces/icon_tile.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';

DabblerColors _colors() => DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  bool reduceMotion = false,
}) => MaterialApp(
  theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors()]),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 360, child: child),
        ),
      ),
    ),
  ),
);

DabblerConversationContext _full({
  bool collapsed = false,
  VoidCallback? onToggle,
  DabblerActivityStatus status = DabblerActivityStatus.confirmed,
  String title = 'Friday 5-a-side',
  List<DabblerConversationContextAction>? actions,
}) => DabblerConversationContext(
  title: title,
  when: 'Fri 8:00 PM',
  venue: 'Al Wasl',
  status: status,
  collapsed: collapsed,
  onToggle: onToggle ?? () {},
  mapLabel: '2.4 km away',
  mapActionLabel: 'Directions',
  participants: '8 of 10 going',
  spots: '2 spots left',
  people: const <String>['a', 'b', 'c'],
  overflow: 5,
  organizerLabel: 'Organised by',
  organizer: 'Omar',
  actions:
      actions ??
      const <DabblerConversationContextAction>[
        DabblerConversationContextAction(label: 'View', icon: 'game'),
        DabblerConversationContextAction(label: 'Invite'),
      ],
);

final Finder _header = find.byKey(
  const ValueKey<String>('conversation-context-header'),
);

void main() {
  group('collapsed header', () {
    testWidgets('shows title, "when · venue", status label; no body', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_full(collapsed: true)));
      expect(find.text('Friday 5-a-side'), findsOneWidget);
      expect(find.text('Fri 8:00 PM · Al Wasl'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.byType(DabblerDivider), findsNothing);
      expect(find.text('8 of 10 going'), findsNothing);
    });

    testWidgets('geometry: 36 tile, 12 padding, min 45 tall', (tester) async {
      await tester.pumpWidget(_host(_full(collapsed: true)));
      final Rect tile = tester.getRect(
        find.byKey(const ValueKey<String>('conversation-context-tile')),
      );
      expect(tile.size, const Size(36, 36)); // IconTile size={36}
      final Rect card = tester.getRect(find.byType(DabblerConversationContext));
      expect(card.width, 360); // width: 100%
      expect(tile.left - card.left, 1 + 12); // 1px border + --space-4
      expect(tester.getSize(_header).height, greaterThanOrEqualTo(45));
      final Rect chev = tester.getRect(
        find.byKey(const ValueKey<String>('conversation-context-chevron')),
      );
      expect(card.right - chev.right, 1 + 12);
      expect(chev.width, 18); // Icon size={18}
    });

    testWidgets('RTL mirrors: tile at the right, chevron at the left', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(_full(collapsed: true), direction: TextDirection.rtl),
      );
      final Rect card = tester.getRect(find.byType(DabblerConversationContext));
      final Rect tile = tester.getRect(
        find.byKey(const ValueKey<String>('conversation-context-tile')),
      );
      final Rect chev = tester.getRect(
        find.byKey(const ValueKey<String>('conversation-context-chevron')),
      );
      expect(card.right - tile.right, 13);
      expect(chev.left - card.left, 13);
    });

    testWidgets('Arabic sizes: footnote 12.1, caption-1 11.1', (tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerConversationContext(
            title: 'مباراة',
            when: 'الجمعة',
            venue: 'النادي',
          ),
          direction: TextDirection.rtl,
        ),
      );
      final Text title = tester.widget(find.text('مباراة'));
      final Text cap = tester.widget(find.text('الجمعة · النادي'));
      expect(title.style!.fontSize, closeTo(12.1, 0.001));
      expect(title.style!.fontWeight, FontWeight.w700);
      expect(cap.style!.fontSize, closeTo(11.1, 0.001));
    });

    testWidgets('Latin sizes: footnote 13/700 one line ellipsis, caption 12', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_full(collapsed: true)));
      final Text title = tester.widget(find.text('Friday 5-a-side'));
      expect(title.style!.fontSize, 13);
      expect(title.maxLines, 1);
      expect(title.overflow, TextOverflow.ellipsis);
      expect(title.style!.color, _colors().textPrimary);
      final Text cap = tester.widget(find.text('Fri 8:00 PM · Al Wasl'));
      expect(cap.style!.fontSize, 12);
      expect(cap.style!.color, _colors().textSecondary);
    });
  });

  group('status', () {
    testWidgets('statusLabel overrides; GAME_STATUS tone drives the badge', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerConversationContext(
            title: 't',
            when: 'w',
            venue: 'v',
            status: DabblerActivityStatus.soon,
            statusLabel: 'Kick-off soon',
          ),
        ),
      );
      final DabblerBadge b = tester.widget(find.byType(DabblerBadge));
      expect(b.label, 'Kick-off soon');
      expect(b.status, _colors().status(DabblerStatusTone.warning));
    });

    testWidgets('open is neutral', (tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerConversationContext(title: 't', when: 'w', venue: 'v'),
        ),
      );
      final DabblerBadge b = tester.widget(find.byType(DabblerBadge));
      expect(b.label, 'Open');
      expect(b.status, DabblerBadge.neutralStatusOf(_colors()));
    });

    testWidgets('cancelled: struck title and error-tinted tile', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(_full(collapsed: true, status: DabblerActivityStatus.cancelled)),
      );
      final Text title = tester.widget(find.text('Friday 5-a-side'));
      expect(title.style!.decoration, TextDecoration.lineThrough);
      final DabblerIconTile tile = tester.widget(find.byType(DabblerIconTile));
      expect(tile.color, _colors().status(DabblerStatusTone.error).base);
    });

    testWidgets('completed: muted tile, title not struck', (tester) async {
      await tester.pumpWidget(
        _host(_full(collapsed: true, status: DabblerActivityStatus.completed)),
      );
      final Text title = tester.widget(find.text('Friday 5-a-side'));
      expect(title.style!.decoration, TextDecoration.none);
      final DabblerIconTile tile = tester.widget(find.byType(DabblerIconTile));
      expect(tile.color, _colors().textSecondary);
    });

    testWidgets('other statuses keep the default brand tile', (tester) async {
      await tester.pumpWidget(_host(_full(collapsed: true)));
      final DabblerIconTile tile = tester.widget(find.byType(DabblerIconTile));
      expect(tile.color, isNull);
    });
  });

  group('expanded body', () {
    testWidgets('divider, map, participants, organizer, actions', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_full()));
      expect(find.byType(DabblerDivider), findsOneWidget);
      expect(find.text('2.4 km away'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);
      expect(find.text('8 of 10 going'), findsOneWidget);
      expect(find.text('2 spots left'), findsOneWidget);
      final DabblerAvatarGroup g = tester.widget(
        find.byType(DabblerAvatarGroup),
      );
      expect(g.people, <String>['a', 'b', 'c']);
      expect(g.overflow, 5);
      expect(find.textContaining('Omar', findRichText: true), findsOneWidget);
      final List<DabblerButton> buttons = tester
          .widgetList<DabblerButton>(find.byType(DabblerButton))
          .toList();
      expect(buttons.map((b) => b.label), <String?>[
        'Directions',
        'View',
        'Invite',
      ]);
      expect(buttons[0].tone, DabblerButtonTone.outlined);
      expect(buttons[1].tone, DabblerButtonTone.primary);
      expect(buttons[1].icon, 'game');
      expect(buttons[2].tone, DabblerButtonTone.outlined);
      expect(buttons.every((b) => b.size == DabblerButtonSize.small), isTrue);
    });

    testWidgets('actions size to content and sit 6px apart in a row', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_full()));
      final Rect view = tester.getRect(
        find.widgetWithText(DabblerButton, 'View'),
      );
      final Rect invite = tester.getRect(
        find.widgetWithText(DabblerButton, 'Invite'),
      );
      expect(view.width, lessThan(200));
      expect(invite.top, view.top);
      expect(invite.left - view.right, 6); // gap: var(--space-2)
    });

    testWidgets('an action tone overrides the index default', (tester) async {
      await tester.pumpWidget(
        _host(
          _full(
            actions: const <DabblerConversationContextAction>[
              DabblerConversationContextAction(
                label: 'Leave',
                tone: DabblerButtonTone.neutral,
              ),
            ],
          ),
        ),
      );
      final DabblerButton b = tester.widget(
        find.widgetWithText(DabblerButton, 'Leave'),
      );
      expect(b.tone, DabblerButtonTone.neutral);
    });

    testWidgets('rows hide without content', (tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerConversationContext(
            title: 't',
            when: 'w',
            venue: 'v',
            collapsed: false,
          ),
        ),
      );
      expect(find.byType(DabblerDivider), findsOneWidget);
      for (final String k in <String>[
        'map',
        'participants',
        'organizer',
        'actions',
      ]) {
        expect(
          find.byKey(ValueKey<String>('conversation-context-$k')),
          findsNothing,
        );
      }
    });

    testWidgets('body insets 12 inline; map row 12/9 padding', (tester) async {
      await tester.pumpWidget(_host(_full()));
      final Rect card = tester.getRect(find.byType(DabblerConversationContext));
      final Rect map = tester.getRect(
        find.byKey(const ValueKey<String>('conversation-context-map')),
      );
      expect(map.left - card.left, 13);
      expect(card.right - map.right, 13);
      final Container c = tester.widget(
        find.byKey(const ValueKey<String>('conversation-context-map')),
      );
      expect(
        c.padding,
        const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 9),
      );
      final BoxDecoration d = c.decoration! as BoxDecoration;
      expect(d.color, _colors().surfaceSunken);
      expect(d.borderRadius, const BorderRadius.all(Radius.circular(9)));
    });
  });

  group('toggle, chevron, semantics', () {
    testWidgets('tap calls onToggle; chevron rotates over 120ms', (
      tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(_full(collapsed: true, onToggle: () => taps++)),
      );
      await tester.tap(_header);
      expect(taps, 1);
      AnimatedRotation rot() => tester.widget(find.byType(AnimatedRotation));
      expect(rot().turns, 0);
      expect(rot().duration, const Duration(milliseconds: 120));
      await tester.pumpWidget(_host(_full()));
      expect(rot().turns, 0.5);
    });

    testWidgets('reduced motion: zero-duration chevron', (tester) async {
      await tester.pumpWidget(
        _host(_full(collapsed: true), reduceMotion: true),
      );
      final AnimatedRotation r = tester.widget(find.byType(AnimatedRotation));
      expect(r.duration, Duration.zero);
    });

    testWidgets('header is a button reporting expanded state', (tester) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(_host(_full(collapsed: true)));
      SemanticsNode node() => tester.getSemantics(
        find.bySemanticsLabel(RegExp('^Friday 5-a-side')),
      );
      expect(node().flagsCollection.isButton, isTrue);
      expect(node().flagsCollection.isExpanded, Tristate.isFalse);
      await tester.pumpWidget(_host(_full()));
      expect(node().flagsCollection.isExpanded, Tristate.isTrue);
      h.dispose();
    });

    testWidgets('keyboard Enter toggles', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(_full(collapsed: true, onToggle: () => taps++)),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
    });
  });

  group('png evidence (build/png, not committed)', () {
    Future<void> shot(
      WidgetTester t,
      Widget w,
      String n, [
      TextDirection d = TextDirection.ltr,
    ]) async {
      final f = await renderPng(
        t,
        Padding(padding: const EdgeInsets.all(15), child: w),
        name: n,
        size: const Size(390, 420),
        direction: d,
        alignment: Alignment.topCenter,
      );
      expect(f.lengthSync(), greaterThan(0));
    }

    testWidgets(
      'collapsed',
      (t) => shot(t, _full(collapsed: true), 'conversation_context_collapsed'),
    );
    testWidgets(
      'expanded',
      (t) => shot(t, _full(), 'conversation_context_expanded'),
    );
    testWidgets(
      'cancelled',
      (t) => shot(
        t,
        _full(collapsed: true, status: DabblerActivityStatus.cancelled),
        'conversation_context_cancelled',
      ),
    );
    testWidgets(
      'completed',
      (t) => shot(
        t,
        _full(collapsed: true, status: DabblerActivityStatus.completed),
        'conversation_context_completed',
      ),
    );
    testWidgets(
      'rtl',
      (t) => shot(
        t,
        const DabblerConversationContext(
          sport: DabblerSport.padel,
          title: 'مباراة الجمعة',
          when: 'الجمعة 8:00 م',
          venue: 'نادي الوصل',
          status: DabblerActivityStatus.soon,
          statusLabel: 'تبدأ قريبًا',
          collapsed: false,
          participants: '8 من 10',
          people: <String>['a', 'b'],
          organizerLabel: 'المنظم',
          organizer: 'عمر',
          mapLabel: 'على بعد 2.4 كم',
          actions: <DabblerConversationContextAction>[
            DabblerConversationContextAction(label: 'عرض'),
          ],
        ),
        'conversation_context_rtl',
        TextDirection.rtl,
      ),
    );
  });
}
