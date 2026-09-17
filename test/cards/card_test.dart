import 'package:dabbler_design_system/src/cards/card.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/interaction/press_scale.dart';
import 'package:dabbler_design_system/src/surfaces/surface.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(
  Widget child, {
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
}) {
  final DabblerColors colors =
      DabblerColors.resolve(theme: theme, brightness: brightness);
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
    home: Directionality(
      textDirection: textDirection,
      child: Align(alignment: Alignment.topLeft, child: child),
    ),
  );
}

/// The one decoration the card's surface paints.
BoxDecoration _decoration(WidgetTester tester) {
  final Iterable<DecoratedBox> boxes =
      tester.widgetList<DecoratedBox>(find.descendant(
    of: find.byType(DabblerCard),
    matching: find.byType(DecoratedBox),
  ));
  expect(boxes, hasLength(1), reason: 'a card paints one decoration');
  return boxes.single.decoration as BoxDecoration;
}

DabblerColors _colors([Brightness brightness = Brightness.light]) =>
    DabblerColors.resolve(theme: DabblerTheme.main, brightness: brightness);

void main() {
  group('AC1 — the flat surface of DS-500 with the card padding of DS-104', () {
    testWidgets('the chrome is a DabblerSurface, not a hand-painted box',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(_host(const DabblerCard(child: Text('body'))));

      expect(find.descendant(
        of: find.byType(DabblerCard),
        matching: find.byType(DabblerSurface),
      ), findsOneWidget);
    });

    testWidgets('the surface is flat: no shadow, no gradient',
        (WidgetTester tester) async {
      for (final DabblerCardVariant variant in DabblerCardVariant.values) {
        await tester.pumpWidget(_host(
          DabblerCard(variant: variant, child: const Text('body')),
        ));
        final BoxDecoration decoration = _decoration(tester);
        expect(decoration.boxShadow, isNull, reason: '$variant');
        expect(decoration.gradient, isNull, reason: '$variant');
        expect(decoration.backgroundBlendMode, isNull, reason: '$variant');
      }
    });

    testWidgets('padded slots sit inside --card-padding (18)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerCard(child: Text('body')),
      ));

      final Padding padding = tester.widget<Padding>(find.descendant(
        of: find.byType(DabblerCard),
        matching: find.byType(Padding),
      ));
      expect(
        padding.padding,
        const EdgeInsets.all(DabblerSpacing.cardPadding),
      );
      expect(DabblerSpacing.cardPadding, 18);
    });

    testWidgets('the default radius is the 16 card corner — D-018',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(_host(const DabblerCard(child: Text('body'))));

      // cxo ruling D-018: all nine card shells in the source draw 16 and none
      // draws 12, so 16 is a real step and the card takes it. `--radius-lg`
      // (12) is the corner of a tile *inside* a card, not of a card.
      expect(
        _decoration(tester).borderRadius,
        const BorderRadius.all(Radius.circular(DabblerRadius.card)),
      );
      expect(DabblerCard.defaultRadius, DabblerRadius.card);
      expect(DabblerRadius.card, 16);
      expect(DabblerCard.defaultRadius, isNot(DabblerRadius.lg));
    });

    testWidgets('radius is overridable for the variants that need another step',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerCard(radius: DabblerRadius.xxl, child: Text('body')),
      ));

      expect(
        _decoration(tester).borderRadius,
        const BorderRadius.all(Radius.circular(DabblerRadius.xxl)),
      );
    });
  });

  group('the five shells of Card.jsx', () {
    testWidgets('standard is --surface-sunken with no border',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerCard(child: Text('b'))));

      final BoxDecoration decoration = _decoration(tester);
      expect(decoration.color, _colors().surfaceSunken);
      expect(decoration.border, isNull);
    });

    testWidgets('standard is NOT the page background', (WidgetTester t) async {
      // --surface-sunken and --surface-flat-sunken (--color-bg-primary) are
      // different colours; the card asks for the former.
      await t.pumpWidget(_host(const DabblerCard(child: Text('b'))));

      expect(_decoration(t).color, isNot(_colors().bgPrimary));
    });

    testWidgets('outlined is --surface-sunken with a 1px --outline-card',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerCard(
        variant: DabblerCardVariant.outlined,
        child: Text('b'),
      )));

      final BoxDecoration decoration = _decoration(tester);
      expect(decoration.color, _colors().surfaceSunken);
      expect(decoration.border, isA<Border>());
      expect((decoration.border! as Border).top.color,
          _colors().borderDefault);
      expect((decoration.border! as Border).top.width,
          DabblerSizing.borderDefault);
    });

    testWidgets('white is --surface-card with a 1px --outline-card',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerCard(
        variant: DabblerCardVariant.white,
        child: Text('b'),
      )));

      final BoxDecoration decoration = _decoration(tester);
      expect(decoration.color, _colors().surfaceCard);
      expect((decoration.border! as Border).top.color,
          _colors().borderDefault);
      expect((decoration.border! as Border).top.width, 1);
    });

    // D-019: named by what they draw. `pricingSelected` was `pricing`, and
    // `pricingUnselected` was `pricingSelected`, until that ruling.
    testWidgets('pricingSelected is --surface-card with a 2px brand border',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerCard(
        variant: DabblerCardVariant.pricingSelected,
        child: Text('b'),
      )));

      final BoxDecoration decoration = _decoration(tester);
      expect(decoration.color, _colors().surfaceCard);
      expect((decoration.border! as Border).top.color,
          _colors().brandPrimary);
      expect((decoration.border! as Border).top.width, 2);
    });

    testWidgets('pricingUnselected is --surface-sunken with a 2px outline',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerCard(
        variant: DabblerCardVariant.pricingUnselected,
        child: Text('b'),
      )));

      final BoxDecoration decoration = _decoration(tester);
      expect(decoration.color, _colors().surfaceSunken);
      expect((decoration.border! as Border).top.color,
          _colors().borderDefault);
      expect((decoration.border! as Border).top.width, 2);
    });

    test('every shell resolves in every theme and both brightnesses', () {
      for (final DabblerTheme theme in DabblerTheme.values) {
        for (final Brightness brightness in Brightness.values) {
          final DabblerColors colors =
              DabblerColors.resolve(theme: theme, brightness: brightness);
          for (final DabblerCardVariant variant
              in DabblerCardVariant.values) {
            expect(DabblerCard.fillOf(colors, variant), isA<Color>());
            expect(DabblerCard.borderWidthOf(variant),
                greaterThanOrEqualTo(0));
          }
        }
      }
    });
  });

  group('slots', () {
    testWidgets('header, body and footer stack in source order',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const SizedBox(
        width: 300,
        child: DabblerCard(
          header: Text('header'),
          footer: Text('footer'),
          child: Text('body'),
        ),
      )));

      final double header = tester.getTopLeft(find.text('header')).dy;
      final double body = tester.getTopLeft(find.text('body')).dy;
      final double footer = tester.getTopLeft(find.text('footer')).dy;
      expect(header, lessThan(body));
      expect(body, lessThan(footer));
    });

    testWidgets('the gap between padded slots is --stack-default (12)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const SizedBox(
        width: 300,
        child: DabblerCard(
          header: SizedBox(height: 20),
          child: SizedBox(height: 20),
        ),
      )));

      final Iterable<SizedBox> spacers = tester
          .widgetList<SizedBox>(find.descendant(
            of: find.byType(DabblerCard),
            matching: find.byType(SizedBox),
          ))
          .where((SizedBox b) => b.height == DabblerSpacing.stackDefault);
      expect(spacers, hasLength(1));
      expect(DabblerSpacing.stackDefault, 12);
    });

    testWidgets('media is full-bleed — outside the padding, above the body',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const SizedBox(
        width: 300,
        child: DabblerCard(
          media: SizedBox(height: 40, child: Text('media')),
          child: Text('body'),
        ),
      )));

      final Rect card = tester.getRect(find.byType(DabblerCard));
      final Rect media = tester.getRect(find.byType(SizedBox).last);
      expect(media.top, card.top,
          reason: 'media touches the top edge, not the padding box');
      expect(tester.getTopLeft(find.text('media')).dy,
          lessThan(tester.getTopLeft(find.text('body')).dy));
    });

    testWidgets('an empty card paints its chrome and nothing else',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerCard(
        width: 100,
        height: 60,
      )));

      expect(find.byType(DabblerCard), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DabblerCard),
          matching: find.byType(Padding),
        ),
        findsNothing,
      );
    });

    testWidgets('padding accepts a directional value for RTL',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const SizedBox(
          width: 300,
          child: DabblerCard(
            padding: EdgeInsetsDirectional.only(start: 30),
            child: Text('body'),
          ),
        ),
        textDirection: TextDirection.rtl,
      ));

      final Rect card = tester.getRect(find.byType(DabblerCard));
      final Rect body = tester.getRect(find.text('body'));
      expect(card.right - body.right, closeTo(30, 0.01),
          reason: 'start is the right edge under RTL');
    });
  });

  group('tappable', () {
    testWidgets('an inert card has no press scale and no focus ring',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerCard(child: Text('b'))));

      expect(find.byType(DabblerPressScale), findsNothing);
      expect(find.byType(DabblerFocusRing), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('onTap adds the system press scale and focus ring',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(DabblerCard(
        onTap: () {},
        child: const Text('b'),
      )));

      expect(find.byType(DabblerPressScale), findsOneWidget);
      expect(find.byType(DabblerFocusRing), findsOneWidget);
    });

    testWidgets('the focus ring follows the card radius',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(DabblerCard(
        radius: DabblerRadius.xxl,
        onTap: () {},
        child: const Text('b'),
      )));

      final DabblerFocusRing ring =
          tester.widget<DabblerFocusRing>(find.byType(DabblerFocusRing));
      expect(ring.borderRadius,
          const BorderRadius.all(Radius.circular(DabblerRadius.xxl)));
    });

    testWidgets('tapping fires onTap', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(_host(DabblerCard(
        onTap: () => taps++,
        child: const Text('b'),
      )));

      await tester.tap(find.byType(DabblerCard));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('enabled:false withholds the handlers and the affordances',
        (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(_host(DabblerCard(
        onTap: () => taps++,
        enabled: false,
        child: const Text('b'),
      )));

      expect(find.byType(DabblerPressScale), findsNothing);
      expect(find.byType(DabblerFocusRing), findsNothing);
      await tester.tap(find.byType(DabblerCard), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(taps, 0);
    });

    testWidgets('a tappable card is a button to the semantics tree',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(DabblerCard(
        onTap: () {},
        semanticLabel: 'Sunday five-a-side',
        child: const Text('b'),
      )));

      expect(
        find.bySemanticsLabel('Sunday five-a-side'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('the press tint of Card.jsx is not ported — the fill is stable',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(DabblerCard(
        onTap: () {},
        child: const Text('b'),
      )));

      final Color before = _decoration(tester).color!;
      final TestGesture gesture =
          await tester.startGesture(tester.getCenter(find.text('b')));
      await tester.pump(const Duration(milliseconds: 200));
      expect(_decoration(tester).color, before);
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });
}
