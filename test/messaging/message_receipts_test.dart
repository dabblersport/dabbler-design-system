// Pins messaging §11 (KAN-580): delivery states, the group receipt count, the
// Message info drawer, and the motion rules around them. Source: the live
// design project's `ds-components/messaging/messaging.jsx` (`DELIVERY`,
// `receiptText`, `Message`, `ReceiptsSheet`) and MESSAGING_DS_ADDITIONS.md
// §10-§15.
import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final DabblerColors _colors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(
  Widget child, {
  TextDirection dir = TextDirection.ltr,
  bool reduceMotion = false,
  double width = 400,
}) => MaterialApp(
  theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors]),
  home: Builder(
    builder: (BuildContext context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
      child: Directionality(
        textDirection: dir,
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    ),
  ),
);

Finder _keyed(String prefix) => find.byWidgetPredicate(
  (Widget w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith(prefix),
);

DabblerMessage _out({
  DabblerDeliveryState? state,
  DabblerReceipt? receipt,
  VoidCallback? onReceipts,
  DabblerMessageContext context = DabblerMessageContext.group,
  bool showLabel = false,
  String lang = 'en',
  VoidCallback? onRetry,
  bool fresh = false,
}) => DabblerMessage(
  direction: DabblerMessageDirection.outgoing,
  context: context,
  content: 'Pitch 3 tonight',
  timestamp: '17:10',
  deliveryState: state,
  receipt: receipt,
  onReceipts: onReceipts,
  showDeliveryLabel: showLabel,
  lang: lang,
  onRetry: onRetry,
  fresh: fresh,
);

void main() {
  group('DabblerReceipt', () {
    test('text follows the four tiers (en)', () {
      expect(
        const DabblerReceipt(seen: 9, delivered: 9, total: 9).text(),
        'Seen by everyone',
      );
      expect(
        const DabblerReceipt(seen: 4, delivered: 7, total: 9).text(),
        'Seen by 4 of 9',
      );
      expect(
        const DabblerReceipt(delivered: 7, total: 9).text(),
        'Delivered to 7 of 9',
      );
      expect(const DabblerReceipt(total: 9).text(), 'Sent');
    });

    test('text follows the four tiers (ar)', () {
      expect(
        const DabblerReceipt(seen: 9, delivered: 9, total: 9).text('ar'),
        'شاهدها الجميع',
      );
      expect(
        const DabblerReceipt(seen: 4, delivered: 7, total: 9).text('ar'),
        'شاهدها 4 من 9',
      );
      expect(
        const DabblerReceipt(delivered: 7, total: 9).text('ar'),
        'وصلت إلى 7 من 9',
      );
      expect(const DabblerReceipt(total: 9).text('ar'), 'أُرسلت');
    });

    test('state is seen, delivered or sent', () {
      expect(
        const DabblerReceipt(seen: 1, delivered: 3, total: 4).state,
        DabblerDeliveryState.seen,
      );
      expect(
        const DabblerReceipt(delivered: 1, total: 4).state,
        DabblerDeliveryState.delivered,
      );
      expect(const DabblerReceipt(total: 4).state, DabblerDeliveryState.sent);
    });
  });

  group('delivery copy', () {
    test('every state has a word in both languages', () {
      for (final DabblerDeliveryState s in DabblerDeliveryState.values) {
        expect(DabblerDeliveryCopy.label(s), isNotEmpty);
        expect(DabblerDeliveryCopy.label(s, 'ar'), isNotEmpty);
        expect(
          DabblerDeliveryCopy.label(s, 'ar'),
          isNot(DabblerDeliveryCopy.label(s)),
        );
      }
      expect(DabblerDeliveryCopy.label(DabblerDeliveryState.seen), 'Seen');
      expect(
        DabblerDeliveryCopy.label(DabblerDeliveryState.failed),
        'Not sent',
      );
    });
  });

  group('Message delivery', () {
    testWidgets('direct: the glyph alone, the word only when asked', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          _out(
            state: DabblerDeliveryState.delivered,
            context: DabblerMessageContext.direct,
          ),
        ),
      );
      expect(find.text('Delivered'), findsNothing);
      await tester.pumpWidget(
        _host(
          _out(
            state: DabblerDeliveryState.delivered,
            context: DabblerMessageContext.direct,
            showLabel: true,
          ),
        ),
      );
      expect(find.text('Delivered'), findsOneWidget);
    });

    testWidgets('seen is the eye in brand colour; delivered the linear tick', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          _out(
            state: DabblerDeliveryState.seen,
            context: DabblerMessageContext.direct,
          ),
        ),
      );
      DabblerIcon icon = tester.widget<DabblerIcon>(find.byType(DabblerIcon));
      expect(icon.name, 'eye');
      expect(icon.weight, DabblerIconWeight.linear);
      expect(icon.color, _colors.brandPrimary);
      await tester.pumpWidget(
        _host(
          _out(
            state: DabblerDeliveryState.delivered,
            context: DabblerMessageContext.direct,
          ),
        ),
      );
      icon = tester.widget<DabblerIcon>(find.byType(DabblerIcon));
      expect(icon.name, 'tick-circle');
      expect(icon.weight, DabblerIconWeight.linear);
      expect(icon.color, _colors.textSecondary);
    });

    testWidgets('failed spells Not sent and Retry fires', (
      WidgetTester tester,
    ) async {
      int retries = 0;
      await tester.pumpWidget(
        _host(
          _out(state: DabblerDeliveryState.failed, onRetry: () => retries++),
        ),
      );
      expect(find.text('Not sent'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.byKey(DabblerMessage.retryKey));
      expect(retries, 1);
    });

    testWidgets('failed and Retry speak Arabic', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          _out(state: DabblerDeliveryState.failed, lang: 'ar', onRetry: () {}),
          dir: TextDirection.rtl,
        ),
      );
      expect(find.text('لم تُرسل'), findsOneWidget);
      expect(find.text('أعد المحاولة'), findsOneWidget);
    });

    testWidgets('retrying dims like sending and shows the clock', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(_out(state: DabblerDeliveryState.retrying)),
      );
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        DabblerMessage.sendingOpacity,
      );
      expect(
        tester.widget<DabblerIcon>(find.byType(DabblerIcon)).name,
        'clock',
      );
      expect(find.text('Retrying'), findsOneWidget);
    });
  });

  group('Message group receipt', () {
    const DabblerReceipt tally = DabblerReceipt(
      seen: 4,
      delivered: 7,
      total: 9,
    );

    testWidgets('replaces the glyph with one count and opens the drawer', (
      WidgetTester tester,
    ) async {
      int opened = 0;
      await tester.pumpWidget(
        _host(
          _out(
            state: DabblerDeliveryState.sent,
            receipt: tally,
            onReceipts: () => opened++,
          ),
        ),
      );
      expect(find.text('Seen by 4 of 9'), findsOneWidget);
      // One glyph only: the count's own eye, no per-message tick beside it.
      expect(tester.widgetList(find.byType(DabblerIcon)).length, 1);
      expect(tester.widget<DabblerIcon>(find.byType(DabblerIcon)).name, 'eye');
      await tester.tap(find.byKey(DabblerMessage.receiptsKey));
      expect(opened, 1);
    });

    testWidgets('the count is a 45px target', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          _out(
            state: DabblerDeliveryState.sent,
            receipt: tally,
            onReceipts: () {},
          ),
        ),
      );
      expect(
        tester.getSize(find.byKey(DabblerMessage.receiptsKey)).height,
        greaterThanOrEqualTo(DabblerSizing.touchTargetMin),
      );
    });

    testWidgets('tiers: delivered tick, plain sent', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          _out(
            state: DabblerDeliveryState.sent,
            receipt: const DabblerReceipt(delivered: 7, total: 9),
            onReceipts: () {},
          ),
        ),
      );
      expect(find.text('Delivered to 7 of 9'), findsOneWidget);
      expect(
        tester.widget<DabblerIcon>(find.byType(DabblerIcon)).color,
        _colors.textSecondary,
      );
      await tester.pumpWidget(
        _host(
          _out(
            state: DabblerDeliveryState.sent,
            receipt: const DabblerReceipt(total: 9),
            onReceipts: () {},
          ),
        ),
      );
      expect(find.text('Sent'), findsOneWidget);
      expect(
        tester.widget<DabblerIcon>(find.byType(DabblerIcon)).color,
        _colors.textTertiary,
      );
    });

    testWidgets('in flight and failed stay glyphs; the count waits', (
      WidgetTester tester,
    ) async {
      for (final DabblerDeliveryState s in <DabblerDeliveryState>[
        DabblerDeliveryState.sending,
        DabblerDeliveryState.retrying,
        DabblerDeliveryState.failed,
      ]) {
        await tester.pumpWidget(
          _host(_out(state: s, receipt: tally, onReceipts: () {})),
        );
        expect(
          find.byKey(DabblerMessage.receiptsKey),
          findsNothing,
          reason: s.name,
        );
        expect(
          find.text(DabblerDeliveryCopy.label(s)),
          findsOneWidget,
          reason: s.name,
        );
      }
    });

    testWidgets('direct and incoming never show a count', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          _out(
            state: DabblerDeliveryState.sent,
            receipt: tally,
            context: DabblerMessageContext.direct,
          ),
        ),
      );
      expect(find.byKey(DabblerMessage.receiptsKey), findsNothing);
      await tester.pumpWidget(
        _host(
          const DabblerMessage(
            context: DabblerMessageContext.group,
            sender: 'Sara',
            content: 'x',
            timestamp: '1',
            receipt: tally,
          ),
        ),
      );
      expect(find.byKey(DabblerMessage.receiptsKey), findsNothing);
    });

    testWidgets('without onReceipts the count is text, not a button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(_out(state: DabblerDeliveryState.sent, receipt: tally)),
      );
      expect(find.text('Seen by 4 of 9'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(DabblerMessage.receiptsKey)).height,
        lessThan(DabblerSizing.touchTargetMin),
      );
    });

    testWidgets('speaks Arabic and mirrors in RTL', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          _out(
            state: DabblerDeliveryState.sent,
            receipt: tally,
            onReceipts: () {},
            lang: 'ar',
          ),
          dir: TextDirection.rtl,
        ),
      );
      expect(find.text('شاهدها 4 من 9'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('motion', () {
    testWidgets('fresh fades in over --motion-slow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(_out(fresh: true)));
      Opacity o = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(DabblerMessage),
          matching: find.byType(Opacity),
        ),
      );
      expect(o.opacity, lessThan(1));
      await tester.pump(DabblerMotion.slow);
      await tester.pump();
      o = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(DabblerMessage),
          matching: find.byType(Opacity),
        ),
      );
      expect(o.opacity, 1);
    });

    testWidgets('reduced motion: no fade, no dimming transition', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          _out(fresh: true, state: DabblerDeliveryState.sending),
          reduceMotion: true,
        ),
      );
      expect(
        find.descendant(
          of: find.byType(DabblerMessage),
          matching: find.byType(TweenAnimationBuilder<double>),
        ),
        findsNothing,
      );
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).duration,
        Duration.zero,
      );
    });
  });

  group('MessageThread', () {
    testWidgets('forwards receipt, language and callbacks per message', (
      WidgetTester tester,
    ) async {
      DabblerThreadMessage? opened;
      DabblerThreadMessage? retried;
      await tester.pumpWidget(
        _host(
          SizedBox(
            height: 500,
            child: DabblerMessageThread(
              context: DabblerMessageContext.group,
              lang: 'ar',
              onReceipts: (DabblerThreadMessage m) => opened = m,
              onRetry: (DabblerThreadMessage m) => retried = m,
              items: const <DabblerThreadItem>[
                DabblerThreadMessage(
                  id: 'a',
                  direction: DabblerMessageDirection.outgoing,
                  content: 'one',
                  timestamp: '1',
                  deliveryState: DabblerDeliveryState.sent,
                  receipt: DabblerReceipt(seen: 2, delivered: 3, total: 4),
                ),
                DabblerThreadMessage(
                  id: 'b',
                  sender: 'me',
                  direction: DabblerMessageDirection.outgoing,
                  content: 'two',
                  timestamp: '2',
                  deliveryState: DabblerDeliveryState.failed,
                ),
              ],
            ),
          ),
          dir: TextDirection.rtl,
        ),
      );
      expect(find.text('شاهدها 2 من 4'), findsOneWidget);
      await tester.tap(find.byKey(DabblerMessage.receiptsKey));
      expect(opened?.id, 'a');
      await tester.tap(find.byKey(DabblerMessage.retryKey));
      expect(retried?.id, 'b');
    });
  });

  group('ReceiptsSheet', () {
    const List<DabblerReceiptGroup> groups = <DabblerReceiptGroup>[
      DabblerReceiptGroup(
        state: DabblerDeliveryState.seen,
        people: <DabblerReceiptPerson>[
          DabblerReceiptPerson(name: 'Ahmed', time: '8:43 PM'),
          DabblerReceiptPerson(name: 'Sara', time: '8:43 PM'),
        ],
      ),
      DabblerReceiptGroup(
        state: DabblerDeliveryState.delivered,
        people: <DabblerReceiptPerson>[
          DabblerReceiptPerson(name: 'Yousef', time: '8:41 PM'),
        ],
      ),
      DabblerReceiptGroup(
        state: DabblerDeliveryState.sent,
        people: <DabblerReceiptPerson>[
          DabblerReceiptPerson(name: 'Priya'),
          DabblerReceiptPerson(name: 'Fahad'),
        ],
      ),
    ];

    testWidgets('three tiles with counts, three lists with people and times', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SingleChildScrollView(
            child: DabblerReceiptsSheet(
              preview: 'Pitch 3 tonight',
              groups: groups,
            ),
          ),
        ),
      );
      expect(find.text('Pitch 3 tonight'), findsOneWidget);
      expect(_keyed('receipts-tile'), findsNWidgets(3));
      for (final String t in <String>['Seen', 'Delivered', 'Not yet']) {
        expect(find.text(t), findsOneWidget);
      }
      expect(find.text('Seen by · 2'), findsOneWidget);
      expect(find.text('Delivered to · 1'), findsOneWidget);
      expect(find.text('Not delivered yet · 2'), findsOneWidget);
      expect(_keyed('receipts-person'), findsNWidgets(5));
      expect(find.text('Ahmed'), findsOneWidget);
      expect(find.text('8:41 PM'), findsOneWidget);
    });

    testWidgets('Arabic headings in RTL without overflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SingleChildScrollView(
            child: DabblerReceiptsSheet(
              preview: 'صورة',
              groups: groups,
              lang: 'ar',
            ),
          ),
          dir: TextDirection.rtl,
          width: 360,
        ),
      );
      expect(find.text('شاهدها · 2'), findsOneWidget);
      expect(find.text('لم تصل بعد · 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty group keeps its tile but has no list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SingleChildScrollView(
            child: DabblerReceiptsSheet(
              groups: <DabblerReceiptGroup>[
                DabblerReceiptGroup(
                  state: DabblerDeliveryState.seen,
                  people: <DabblerReceiptPerson>[],
                ),
              ],
            ),
          ),
        ),
      );
      expect(_keyed('receipts-tile'), findsOneWidget);
      expect(find.text('Seen by · 0'), findsNothing);
    });

    testWidgets(
      'show() opens a titled drawer and the close control dismisses',
      (WidgetTester tester) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          _host(
            Builder(
              builder: (BuildContext c) {
                ctx = c;
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        showSheet(ctx);
        await tester.pumpAndSettle();
        expect(find.text('Message info'), findsOneWidget);
        expect(find.text('Ahmed'), findsOneWidget);
      },
    );
  });
}

void showSheet(BuildContext ctx) {
  DabblerReceiptsSheet.show(
    ctx,
    preview: 'Pitch 3 tonight',
    groups: const <DabblerReceiptGroup>[
      DabblerReceiptGroup(
        state: DabblerDeliveryState.seen,
        people: <DabblerReceiptPerson>[DabblerReceiptPerson(name: 'Ahmed')],
      ),
    ],
  );
}
