// Pins live `components/messaging/MessageThread.jsx` + `.prompt.md` (live
// Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1, read via
// DesignSync get_file on 2026-10-02, local mirror): grouping derivation
// (same direction AND sender of adjacent message rows), 12 between groups,
// 3 within, 12 gutters, anchor bottom / unread offsetTop - 72, hidden scroll,
// typing row inset 28 + 6, selectedId.
import 'dart:io';

import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';

final DabblerColors _colors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(
  Widget child, {
  TextDirection dir = TextDirection.ltr,
  double height = 600,
}) => MaterialApp(
  theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors]),
  home: Directionality(
    textDirection: dir,
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 400, height: height, child: child),
    ),
  ),
);

const DabblerThreadMessage _a1 = DabblerThreadMessage(
  sender: 'A',
  content: 'a1',
);
const DabblerThreadMessage _a2 = DabblerThreadMessage(
  sender: 'A',
  content: 'a2',
);
const DabblerThreadMessage _a3 = DabblerThreadMessage(
  sender: 'A',
  content: 'a3',
);
const DabblerThreadMessage _b = DabblerThreadMessage(sender: 'B', content: 'b');
const DabblerThreadMessage _me = DabblerThreadMessage(
  direction: DabblerMessageDirection.outgoing,
  sender: 'A',
  content: 'me',
);

void main() {
  group('groupPositionFor', () {
    List<DabblerGroupPosition> pos(List<DabblerThreadItem> items) =>
        <DabblerGroupPosition>[
          for (int i = 0; i < items.length; i++)
            DabblerMessageThread.groupPositionFor(items, i),
        ];
    test('runs of the same sender: first, middle, last', () {
      expect(
        pos(const <DabblerThreadItem>[_a1, _a2, _a3, _b]),
        <DabblerGroupPosition>[
          DabblerGroupPosition.first,
          DabblerGroupPosition.middle,
          DabblerGroupPosition.last,
          DabblerGroupPosition.single,
        ],
      );
    });
    test('a direction change breaks the run even with the same sender', () {
      expect(pos(const <DabblerThreadItem>[_a1, _me]), <DabblerGroupPosition>[
        DabblerGroupPosition.single,
        DabblerGroupPosition.single,
      ]);
    });
    test('date, unread, system, notice and typing rows break a run', () {
      for (final DabblerThreadItem breaker in const <DabblerThreadItem>[
        DabblerThreadDate('d'),
        DabblerThreadUnread('u'),
        DabblerThreadSystem(text: 's'),
        DabblerThreadNotice(title: 'n'),
        DabblerThreadTyping(),
      ]) {
        final List<DabblerGroupPosition> p = pos(<DabblerThreadItem>[
          _a1,
          breaker,
          _a2,
        ]);
        expect(p.first, DabblerGroupPosition.single);
        expect(p.last, DabblerGroupPosition.single);
      }
    });
  });

  testWidgets('rhythm: 12 gutters, 3 within a group, 12 between groups', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DabblerMessageThread(
          anchor: DabblerThreadAnchor.unread,
          items: <DabblerThreadItem>[_a1, _a2, _b],
        ),
      ),
    );
    await tester.pumpAndSettle();
    Rect bubble(String t) => tester.getRect(
      find
          .ancestor(of: find.text(t), matching: find.byType(DecoratedBox))
          .first,
    );
    expect(bubble('a1').top, 12);
    expect(bubble('a1').left, 12);
    expect(bubble('a2').top - bubble('a1').bottom, 3);
    expect(bubble('b').top - bubble('a2').bottom, 12);
  });

  testWidgets('derived corners: first/last own-side corners tighten', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(const DabblerMessageThread(items: <DabblerThreadItem>[_a1, _a2])),
    );
    final List<DabblerMessage> m = tester
        .widgetList<DabblerMessage>(find.byType(DabblerMessage))
        .toList();
    expect(m[0].groupPosition, DabblerGroupPosition.first);
    expect(m[1].groupPosition, DabblerGroupPosition.last);
  });

  testWidgets('anchor bottom rests on the newest row', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        DabblerMessageThread(
          items: <DabblerThreadItem>[
            for (int i = 0; i < 40; i++)
              DabblerThreadMessage(sender: '$i', content: 'm$i'),
          ],
        ),
        height: 300,
      ),
    );
    await tester.pumpAndSettle();
    final ScrollPosition p = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;
    expect(p.pixels, p.maxScrollExtent);
    expect(p.maxScrollExtent, greaterThan(0));
  });

  testWidgets('anchor unread rests 72px above the divider', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        DabblerMessageThread(
          anchor: DabblerThreadAnchor.unread,
          items: <DabblerThreadItem>[
            for (int i = 0; i < 20; i++)
              DabblerThreadMessage(sender: '$i', content: 'm$i'),
            const DabblerThreadUnread('New'),
            for (int i = 20; i < 40; i++)
              DabblerThreadMessage(sender: '$i', content: 'm$i'),
          ],
        ),
        height: 300,
      ),
    );
    await tester.pumpAndSettle();
    expect(DabblerMessageThread.unreadAnchorInset, 72);
    final Rect divider = tester.getRect(find.byType(DabblerUnreadDivider));
    expect(divider.top, closeTo(72, 0.01));
  });

  testWidgets('scrollbar hidden', (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(const DabblerMessageThread(items: <DabblerThreadItem>[_a1])),
    );
    final BuildContext ctx = tester.element(find.text('a1'));
    expect(
      ScrollConfiguration.of(ctx).buildScrollbar(
        ctx,
        const SizedBox(),
        ScrollableDetails.vertical(controller: ScrollController()),
      ),
      isA<SizedBox>(),
    );
  });

  testWidgets('typing row inset 34 logical start, both directions', (
    WidgetTester tester,
  ) async {
    for (final TextDirection dir in TextDirection.values) {
      await tester.pumpWidget(
        _host(
          const DabblerMessageThread(
            items: <DabblerThreadItem>[
              DabblerThreadTyping(names: <String>['L'], label: 'L is typing'),
            ],
          ),
          dir: dir,
        ),
      );
      final Rect r = tester.getRect(
        find
            .ancestor(
              of: find.byType(DabblerTypingIndicator),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      if (dir == TextDirection.ltr) {
        expect(r.left, 12 + 28 + 6);
      } else {
        expect(r.right, 400 - 12 - 28 - 6);
      }
      expect(find.text('L is typing'), findsOneWidget);
    }
  });

  testWidgets('selectedId, onMessagePress, onReact, forwarded retry', (
    WidgetTester tester,
  ) async {
    DabblerThreadMessage? pressed;
    String? reacted;
    int retries = 0;
    await tester.pumpWidget(
      _host(
        DabblerMessageThread(
          selectedId: '2',
          onMessagePress: (DabblerThreadMessage m) => pressed = m,
          onReact: (DabblerThreadMessage m, String k) => reacted = '${m.id}:$k',
          items: <DabblerThreadItem>[
            const DabblerThreadMessage(id: '1', sender: 'A', content: 'one'),
            const DabblerThreadMessage(
              id: '2',
              sender: 'B',
              content: 'two',
              reactions: <DabblerMessageReaction>[
                DabblerMessageReaction(key: 'in', count: 1),
              ],
            ),
            DabblerThreadMessage(
              id: '3',
              direction: DabblerMessageDirection.outgoing,
              content: 'three',
              timestamp: '1',
              deliveryState: DabblerDeliveryState.failed,
              onRetry: () => retries++,
              retryLabel: 'Again',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final List<DabblerMessage> m = tester
        .widgetList<DabblerMessage>(find.byType(DabblerMessage))
        .toList();
    expect(m[1].state, DabblerMessageState.selected);
    expect(m[0].state, DabblerMessageState.normal);
    await tester.tap(find.text('one'));
    expect(pressed?.id, '1');
    await tester.tap(find.byType(DabblerReactionGroup));
    expect(reacted, '2:in');
    await tester.tap(find.text('Again'));
    expect(retries, 1);
  });

  testWidgets('PNG: group thread LTR and RTL', (WidgetTester tester) async {
    for (final TextDirection dir in TextDirection.values) {
      final File f = await renderPng(
        tester,
        const SizedBox(
          width: 390,
          height: 1000,
          child: DabblerMessageThread(
            context: DabblerMessageContext.group,
            items: messagingSampleGroupThread,
            selectedId: '4',
          ),
        ),
        name: 'message_thread_${dir.name}',
        size: const Size(390, 1000),
        direction: dir,
      );
      expect(f.lengthSync(), greaterThan(0));
    }
  });
}
