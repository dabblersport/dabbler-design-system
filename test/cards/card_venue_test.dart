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

void main() {
  test('default semantic label joins name, place and price', () {
    const DabblerCardVenue v = DabblerCardVenue(
      name: 'Elite Arena',
      area: 'DSO',
      distance: '4 km',
      price: 'AED 120 / hour',
      priceCaption: 'Starting from',
    );
    expect(
      v.defaultSemanticLabel,
      'Elite Arena, DSO, 4 km, Starting from AED 120 / hour',
    );
    expect(DabblerCardVenue.coverHeight, 170);
    expect(DabblerCardVenue.nameMaxLines, 2);
  });

  for (final TextDirection dir in TextDirection.values) {
    testWidgets('full card, taps and favourite (${dir.name})', (
      WidgetTester t,
    ) async {
      final SemanticsHandle h = t.ensureSemantics();
      int taps = 0;
      int favs = 0;
      await t.pumpWidget(
        _host(
          DabblerCardVenue(
            name: 'Elite Football Arena',
            cover: const SizedBox(key: Key('cover')),
            area: 'Dubai Silicon Oasis',
            distance: '4 km',
            tags: <Widget>[
              DabblerCardVenue.rating(rating: '4.8', reviews: '(126)'),
            ],
            favourite: DabblerButton.icon(
              key: const Key('fav'),
              icon: 'heart',
              semanticLabel: 'Save venue',
              onPressed: () => favs++,
            ),
            price: 'AED 120 / hour',
            priceCaption: 'Starting from',
            onTap: () => taps++,
          ),
          direction: dir,
        ),
      );
      expect(t.takeException(), isNull);
      expect(
        t.getSize(find.byKey(const Key('cover'))).height,
        DabblerCardVenue.coverHeight,
      );
      expect(find.text('Dubai Silicon Oasis · 4 km'), findsOneWidget);
      expect(find.bySemanticsLabel('4.8 (126)'), findsOneWidget);

      await t.tap(find.byKey(const Key('fav')));
      expect(favs, 1);
      expect(taps, 0);
      await t.tap(find.text('AED 120 / hour'));
      expect(taps, 1);

      // Favourite sits at the inline end of the name.
      final Rect name = t.getRect(find.text('Elite Football Arena'));
      final Rect fav = t.getRect(find.byKey(const Key('fav')));
      if (dir == TextDirection.ltr) {
        expect(fav.left, greaterThanOrEqualTo(name.right));
      } else {
        expect(fav.right, lessThanOrEqualTo(name.left));
      }
      h.dispose();
    });
  }

  testWidgets('no cover, no price: minimal card renders', (
    WidgetTester t,
  ) async {
    await t.pumpWidget(_host(const DabblerCardVenue(name: 'Lane Eight')));
    expect(t.takeException(), isNull);
    expect(find.text('Lane Eight'), findsOneWidget);
    final DabblerCard card = t.widget(find.byType(DabblerCard));
    expect(card.media, isNull);
  });

  for (final TextDirection dir in <TextDirection>[
    TextDirection.ltr,
    TextDirection.rtl,
  ]) {
    testWidgets('sports and facilities rows render ($dir)', (
      WidgetTester t,
    ) async {
      await t.pumpWidget(
        _host(
          DabblerCardVenue(
            name: dir == TextDirection.rtl ? 'ملاعب النخيل' : 'Elite',
            sports: const <Widget>[DabblerChip(label: 'Padel')],
            facilities: <Widget>[
              DabblerCardVenue.facility(icon: 'car', label: 'Parking'),
              DabblerCardVenue.facility(icon: 'cup', label: 'Cafe'),
            ],
          ),
          direction: dir,
        ),
      );
      expect(t.takeException(), isNull);
      expect(find.text('Padel'), findsOneWidget);
      expect(find.text('Parking'), findsOneWidget);
      final double a = t.getCenter(find.text('Parking')).dx;
      final double b = t.getCenter(find.text('Cafe')).dx;
      expect(dir == TextDirection.ltr ? a < b : a > b, isTrue);
    });
  }

  for (final TextDirection dir in TextDirection.values) {
    testWidgets('actionFirst puts the button before the price (${dir.name})', (
      WidgetTester t,
    ) async {
      Widget card({required bool first}) => _host(
        DabblerCardVenue(
          name: 'Lane Eight',
          price: 'AED 120 / hour',
          priceCaption: 'Starting from',
          trailing: const SizedBox(key: Key('action'), width: 90, height: 40),
          actionFirst: first,
        ),
        direction: dir,
      );
      for (final bool first in <bool>[false, true]) {
        await t.pumpWidget(card(first: first));
        final double action = t.getCenter(find.byKey(const Key('action'))).dx;
        final double price = t.getCenter(find.text('AED 120 / hour')).dx;
        // Inline start is left in LTR and right in RTL.
        final bool actionAtStart = dir == TextDirection.ltr
            ? action < price
            : action > price;
        expect(actionAtStart, first);
      }
    });
  }
}
