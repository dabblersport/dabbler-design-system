import 'package:dabbler_design_system/src/cards/card.dart';
import 'package:dabbler_design_system/src/cards/card_house.dart';
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/interaction/press_scale.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The resolved tokens the card is checked against.
DabblerColors _colors({
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

/// The minimum a card needs: a [ThemeData] carrying [DabblerColors], and a
/// direction.
Widget _host(
  Widget child, {
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
  TextDirection direction = TextDirection.ltr,
}) {
  return MaterialApp(
    theme: ThemeData(
      brightness: brightness,
      extensions: <ThemeExtension<dynamic>>[
        _colors(theme: theme, brightness: brightness),
      ],
    ),
    home: Directionality(
      textDirection: direction,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: 400, child: child),
      ),
    ),
  );
}

/// The well's decoration — the first [Container] this component draws.
BoxDecoration _wellDecoration(WidgetTester tester) {
  final Container well = tester.widget<Container>(
    find.descendant(
      of: find.byType(DabblerCardHouse),
      matching: find.byType(Container),
    ).first,
  );
  return well.decoration! as BoxDecoration;
}

void main() {
  const DabblerCardHouse subject = DabblerCardHouse(
    name: 'Dabbler Design House',
    meta: '25–50 rooms / week',
    actionLabel: 'join house',
  );

  group('KAN-233 AC1 — CardHouse composes DS-800\'s base Card', () {
    testWidgets('it renders exactly one DabblerCard and no second surface',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(subject));

      expect(find.byType(DabblerCard), findsOneWidget);
    });

    testWidgets('the card takes the standard shell — the source paints '
        '--neutral-200 with no border', (WidgetTester tester) async {
      await tester.pumpWidget(_host(subject));

      final DabblerCard card = tester.widget<DabblerCard>(
        find.byType(DabblerCard),
      );
      expect(card.variant, DabblerCardVariant.standard);
      expect(DabblerCard.borderOf(_colors(), card.variant), isNull);
      expect(DabblerCard.fillOf(_colors(), card.variant),
          _colors().surfaceSunken);
    });

    testWidgets('no chrome is restated — radius and padding are left to the '
        'base card', (WidgetTester tester) async {
      await tester.pumpWidget(_host(subject));

      final DabblerCard card = tester.widget<DabblerCard>(
        find.byType(DabblerCard),
      );
      expect(card.radius, isNull, reason: 'the card owns the radius');
      expect(card.padding, isNull, reason: 'the card owns the padding');
      expect(card.gap, isNull, reason: 'the card owns the inter-slot gap');
    });

    testWidgets('the row goes in child and the join pill in footer',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(subject));

      final DabblerCard card = tester.widget<DabblerCard>(
        find.byType(DabblerCard),
      );
      expect(card.child, isA<Row>());
      expect(card.footer, isNotNull,
          reason: 'CardHouse.jsx draws a join pill below the row');
      expect(card.media, isNull);
      expect(card.header, isNull);
    });
  });

  group('the design source\'s content', () {
    testWidgets('name, meta and action label all render',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(subject));

      expect(find.text('Dabbler Design House'), findsOneWidget);
      expect(find.text('25–50 rooms / week'), findsOneWidget);
      expect(find.text('join house'), findsOneWidget);
    });

    testWidgets('a null meta drops the line, not the card',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerCardHouse(name: 'Dabbler Design House'),
      ));

      expect(find.text('Dabbler Design House'), findsOneWidget);
      expect(find.text('25–50 rooms / week'), findsNothing);
    });

    testWidgets('a null actionLabel drops the pill entirely',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerCardHouse(name: 'Dabbler Design House'),
      ));

      final DabblerCard card = tester.widget<DabblerCard>(
        find.byType(DabblerCard),
      );
      expect(card.footer, isNull);
    });
  });

  group('the icon well', () {
    testWidgets('is 64×64 at --radius-lg, filled --color-brand-primary',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(subject));

      final BoxDecoration decoration = _wellDecoration(tester);
      expect(decoration.color, _colors().brandPrimary);
      expect(
        decoration.borderRadius,
        const BorderRadius.all(Radius.circular(DabblerRadius.lg)),
      );
      // D-018: the well keeps 12 while the shell moves to 16. The two corners
      // must not collapse back onto one another — that nesting reading as a
      // single surface is the defect the ruling exists to fix.
      expect(DabblerCardHouse.wellRadius, isNot(DabblerCard.defaultRadius));

      final Size size = tester.getSize(
        find.descendant(
          of: find.byType(DabblerCardHouse),
          matching: find.byType(Container),
        ).first,
      );
      expect(size, const Size(DabblerCardHouse.wellSide,
          DabblerCardHouse.wellSide));
    });

    testWidgets('draws the vocabulary\'s house at --icon-lg in --color-on-brand',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(subject));

      final DabblerIcon icon =
          tester.widget<DabblerIcon>(find.byType(DabblerIcon));
      expect(icon.name, 'home-2');
      expect(DabblerIconRegistry.vocabulary, contains(icon.name));
      expect(icon.size, DabblerSizing.iconLg);
      expect(icon.color, _colors().onBrand);
    });

    testWidgets('a supplied icon replaces it', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerCardHouse(
        name: 'Dabbler Design House',
        icon: SizedBox.shrink(key: ValueKey<String>('custom')),
      )));

      expect(find.byKey(const ValueKey<String>('custom')), findsOneWidget);
      expect(find.byType(DabblerIcon), findsNothing);
    });
  });

  group('type comes from the ramp, with the source\'s weights', () {
    testWidgets('the name is .t-subheadline at Bold on --color-text-primary',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(subject));

      final TextStyle style =
          tester.widget<Text>(find.text('Dabbler Design House')).style!;
      expect(style.fontSize, DabblerType.subheadline.fontSize);
      expect(style.fontWeight, DabblerType.bold);
      expect(style.color, _colors().textPrimary);
    });

    testWidgets('the meta is .t-footnote, unmodified, on --muted',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(subject));

      final TextStyle style =
          tester.widget<Text>(find.text('25–50 rooms / week')).style!;
      expect(style.fontSize, DabblerType.footnote.fontSize);
      expect(style.fontWeight, DabblerType.footnote.fontWeight);
      expect(style.color, _colors().textSecondary);
    });

    testWidgets('the pill label is .t-label on --color-on-brand',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(subject));

      final TextStyle style =
          tester.widget<Text>(find.text('join house')).style!;
      expect(style.fontSize, DabblerType.label.fontSize);
      expect(style.fontWeight, DabblerType.label.fontWeight);
      expect(style.color, _colors().onBrand);
    });

    testWidgets('Arabic leading is taken on the sans steps that declare it',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(subject, direction: TextDirection.rtl));

      final TextStyle style =
          tester.widget<Text>(find.text('Dabbler Design House')).style!;
      expect(
        style.height,
        DabblerType.subheadline.arabicLeading /
            DabblerType.subheadline.fontSize,
      );
    });
  });

  group('the join pill', () {
    testWidgets('clears --touch-target-min, not the source\'s 41',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(subject));

      final Size size = tester.getSize(find.text('join house').first);
      expect(size.height, lessThanOrEqualTo(DabblerSizing.touchTargetMin));
      expect(DabblerCardHouse.actionHeight, DabblerSizing.touchTargetMin);
      expect(DabblerCardHouse.actionHeight,
          greaterThanOrEqualTo(44.0),
          reason: 'Apple\'s 44pt floor; the source\'s 41 does not clear it');
    });

    testWidgets('a live action gets the system press and focus primitives',
        (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(_host(DabblerCardHouse(
        name: 'Dabbler Design House',
        actionLabel: 'join house',
        onAction: () => taps++,
      )));

      expect(find.byType(DabblerFocusRing), findsOneWidget);
      expect(find.byType(DabblerPressScale), findsOneWidget);

      await tester.tap(find.text('join house'));
      expect(taps, 1);
    });

    testWidgets('a label with no callback is inert — no ring, no scale',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(subject));

      expect(find.byType(DabblerFocusRing), findsNothing);
      expect(find.byType(DabblerPressScale), findsNothing);
    });

    testWidgets('enabled: false withholds the action',
        (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(_host(DabblerCardHouse(
        name: 'Dabbler Design House',
        actionLabel: 'join house',
        onAction: () => taps++,
        enabled: false,
      )));

      await tester.tap(find.text('join house'));
      expect(taps, 0);
    });
  });

  group('the card itself', () {
    testWidgets('onTap reaches DabblerCard, so the press language is shared',
        (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(_host(DabblerCardHouse(
        name: 'Dabbler Design House',
        onTap: () => taps++,
        semanticLabel: 'Dabbler Design House',
      )));

      final DabblerCard card = tester.widget<DabblerCard>(
        find.byType(DabblerCard),
      );
      expect(card.onTap, isNotNull);
      expect(card.semanticLabel, 'Dabbler Design House');

      await tester.tap(find.byType(DabblerCard));
      expect(taps, 1);
    });

    testWidgets('it renders in every theme and both brightnesses',
        (WidgetTester tester) async {
      for (final DabblerTheme theme in DabblerTheme.values) {
        for (final Brightness brightness in Brightness.values) {
          await tester.pumpWidget(
            _host(subject, theme: theme, brightness: brightness),
          );
          expect(tester.takeException(), isNull,
              reason: '$theme / $brightness');
          expect(find.text('Dabbler Design House'), findsOneWidget);
        }
      }
    });
  });
}
