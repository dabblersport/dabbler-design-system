import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) {
  final DabblerColors colors = DabblerColors.resolve(
    theme: DabblerTheme.main,
    brightness: Brightness.light,
  );
  return MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 340, child: child),
          ),
        ),
      ),
    ),
  );
}

const DabblerCardEventPlayers _players = DabblerCardEventPlayers(
  label: '9 of 10 players in',
  joined: 9,
  capacity: 10,
  note: '1 spot left',
  tone: DabblerProgressBarTone.warning,
);
const DabblerCardEventPrice _price = DabblerCardEventPrice(
  price: 'AED 40',
  note: 'per player',
);

void main() {
  group('compose', () {
    test('null when every slot is null', () {
      expect(DabblerCardEventListing.compose(), isNull);
      expect(DabblerCardEventListing.withFooter(null), isNull);
    });
    test('withFooter returns the footer alone when no slot is set', () {
      const Widget f = SizedBox();
      expect(DabblerCardEventListing.withFooter(f), same(f));
    });
  });

  group('players', () {
    test('fraction is clamped and safe on zero capacity', () {
      expect(_players.fraction, closeTo(0.9, 1e-9));
      expect(
        const DabblerCardEventPlayers(
          label: 'x',
          joined: 12,
          capacity: 10,
        ).fraction,
        1,
      );
      expect(
        const DabblerCardEventPlayers(
          label: 'x',
          joined: 3,
          capacity: 0,
        ).fraction,
        0,
      );
    });

    test('note ink follows the tone', () {
      final DabblerColors c = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      expect(
        DabblerCardEventPlayers.noteColorFor(c, DabblerProgressBarTone.warning),
        c.warning.strong,
      );
      expect(
        DabblerCardEventPlayers.noteColorFor(c, DabblerProgressBarTone.brand),
        c.brandPrimary,
      );
    });

    testWidgets('one semantics node: label then note', (WidgetTester t) async {
      final SemanticsHandle h = t.ensureSemantics();
      await t.pumpWidget(_host(_players));
      expect(
        find.bySemanticsLabel('9 of 10 players in, 1 spot left'),
        findsOneWidget,
      );
      expect(find.byType(DabblerProgressBar), findsOneWidget);
      h.dispose();
    });
  });

  group('cards', () {
    for (final TextDirection dir in TextDirection.values) {
      testWidgets('large renders all three slots (${dir.name})', (
        WidgetTester t,
      ) async {
        int joins = 0;
        await t.pumpWidget(
          _host(
            DabblerCardEventLarge(
              title: 'Five-a-side',
              progress: _players,
              price: _price,
              action: DabblerCardEventListing.joinButton(
                label: 'Join game',
                onPressed: () => joins++,
              ),
            ),
            direction: dir,
          ),
        );
        expect(find.text('9 of 10 players in'), findsOneWidget);
        expect(find.text('AED 40'), findsOneWidget);
        await t.tap(find.text('Join game'));
        expect(joins, 1);
        expect(t.takeException(), isNull);

        // Price sits at the inline end of the progress row.
        final Rect bar = t.getRect(find.byType(DabblerProgressBar));
        final Rect price = t.getRect(find.text('AED 40'));
        if (dir == TextDirection.ltr) {
          expect(price.left, greaterThan(bar.right));
        } else {
          expect(price.right, lessThan(bar.left));
        }
      });
    }

    testWidgets('loading and disabled join do not fire', (
      WidgetTester t,
    ) async {
      int joins = 0;
      await t.pumpWidget(
        _host(
          Column(
            children: <Widget>[
              DabblerCardEventMedium(
                title: 'A',
                action: DabblerCardEventListing.joinButton(
                  label: 'Loading',
                  onPressed: () => joins++,
                  loading: true,
                ),
              ),
              DabblerCardEventSmall(
                title: 'B',
                action: DabblerCardEventListing.joinButton(
                  label: 'Disabled',
                  onPressed: () => joins++,
                  disabled: true,
                ),
              ),
            ],
          ),
        ),
      );
      await t.tap(find.byType(DabblerButton).first, warnIfMissed: false);
      await t.tap(find.text('Disabled'), warnIfMissed: false);
      await t.pump();
      expect(joins, 0);
    });

    testWidgets('null slots change nothing', (WidgetTester t) async {
      await t.pumpWidget(_host(const DabblerCardEventMedium(title: 'Plain')));
      expect(find.byType(DabblerProgressBar), findsNothing);
      expect(find.byType(DabblerButton), findsNothing);
      final DabblerCard card = t.widget(find.byType(DabblerCard));
      expect(card.footer, isNull);
    });

    testWidgets('large keeps its existing footer under the slots', (
      WidgetTester t,
    ) async {
      await t.pumpWidget(
        _host(
          const DabblerCardEventLarge(
            title: 'X',
            price: _price,
            footer: Text('own footer'),
          ),
        ),
      );
      expect(
        t.getRect(find.text('own footer')).top,
        greaterThan(t.getRect(find.text('AED 40')).bottom),
      );
    });
  });
}
