import 'package:dabbler_design_system/src/cards/card.dart';
import 'package:dabbler_design_system/src/cards/card_pricing_default.dart';
import 'package:dabbler_design_system/src/cards/card_pricing_selected.dart'
    as selected_path;
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/interaction/press_scale.dart';
import 'package:dabbler_design_system/src/surfaces/badge.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// The resolved tokens the tile is checked against.
DabblerColors _colors({
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

/// The minimum a tile needs: a [ThemeData] carrying [DabblerColors], and a
/// direction. 186 is the source's own frame width, so the tile is measured at
/// the width Figma drew it at.
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
        child: Padding(
          // Headroom for the pill that is specified to overhang the top edge.
          padding: const EdgeInsets.only(top: 24),
          child: SizedBox(width: 186, child: child),
        ),
      ),
    ),
  );
}

/// The `Default` dump's content, verbatim from `CardPricingDefault.d.ts`.
const DabblerCardPricing _yearly = DabblerCardPricing(
  plan: 'yearly',
  price: r'$59.99/yr',
  priceNote: r'($5.00/mo)',
  billingNote: 'billed annually',
  trialLabel: '7d free trial',
  selected: true,
);

/// The `Selected` dump's content, verbatim from `CardPricingSelected.d.ts`.
const DabblerCardPricing _monthly = DabblerCardPricing(
  plan: 'monthly',
  price: r'$5.99/mo',
  billingNote: 'billed monthly',
  trialLabel: '7d free trial',
);

/// The indicator's decoration — the tile draws exactly one [Container].
BoxDecoration _indicatorDecoration(WidgetTester tester) {
  final Container container = tester.widget<Container>(
    find.descendant(
      of: find.byType(DabblerCardPricing),
      matching: find.byType(Container),
    ),
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  group('KAN-249 AC1 — one widget, two states', () {
    test('the selected state is not a second type', () {
      // The point of AC1: `selected` is a field on one class, and the file
      // named for the second Figma symbol introduces no new type.
      expect(_yearly, isA<DabblerCardPricing>());
      expect(_monthly, isA<DabblerCardPricing>());
      expect(_yearly.selected, isTrue);
      expect(_monthly.selected, isFalse);
    });

    test('card_pricing_selected.dart re-exports the one widget', () {
      // Importing either Surfaces path yields the same type.
      expect(
        selected_path.DabblerCardPricing,
        same(DabblerCardPricing),
      );
    });

    test('the whole chrome difference is one expression', () {
      // `Default` (the tick) is the SELECTED tile; `Selected` (the empty ring)
      // is the unselected one — the kit's symbol names are inverted. Per D-019
      // the enum is named by what it draws, so this mapping is the obvious one
      // and stays that way.
      expect(
        DabblerCardPricing.variantOf(selected: true),
        DabblerCardVariant.pricingSelected,
      );
      expect(
        DabblerCardPricing.variantOf(selected: false),
        DabblerCardVariant.pricingUnselected,
      );
    });

    testWidgets('both states draw the same tree, differing only in chrome',
        (WidgetTester tester) async {
      for (final bool selected in <bool>[false, true]) {
        await tester.pumpWidget(
          _host(
            DabblerCardPricing(
              plan: 'yearly',
              price: r'$59.99/yr',
              priceNote: r'($5.00/mo)',
              billingNote: 'billed annually',
              trialLabel: '7d free trial',
              selected: selected,
            ),
          ),
        );

        // Same slots, same texts, same pill, in both states.
        expect(find.text('yearly'), findsOneWidget);
        expect(find.text(r'$59.99/yr'), findsOneWidget);
        expect(find.text(r'($5.00/mo)'), findsOneWidget);
        expect(find.text('billed annually'), findsOneWidget);
        expect(find.byType(DabblerBadge), findsOneWidget);
        // Exactly one indicator, in both states.
        expect(
          find.descendant(
            of: find.byType(DabblerCardPricing),
            matching: find.byType(Container),
          ),
          findsOneWidget,
        );
      }
    });
  });

  group('the shell comes from DabblerCard, not from this file', () {
    testWidgets('selected is the white shell with a 2px brand border',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_yearly));
      final DabblerColors colors = _colors();

      final DabblerCard card = tester.widget<DabblerCard>(
        find.byType(DabblerCard),
      );
      expect(card.variant, DabblerCardVariant.pricingSelected);
      // `backgroundColor: var(--neutral-white)`, `2px solid var(--purple-600)`
      // — CardPricingDefault.jsx.
      expect(
        DabblerCard.fillOf(colors, card.variant),
        colors.surfaceCard,
      );
      expect(
        DabblerCard.borderOf(colors, card.variant),
        colors.brandPrimary,
      );
      expect(
        DabblerCard.borderWidthOf(card.variant),
        DabblerSizing.borderDefault * 2,
      );
    });

    testWidgets('unselected is the sunken shell with a 2px outline border',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_monthly));
      final DabblerColors colors = _colors();

      final DabblerCard card = tester.widget<DabblerCard>(
        find.byType(DabblerCard),
      );
      expect(card.variant, DabblerCardVariant.pricingUnselected);
      // `backgroundColor: var(--neutral-200)`, `2px solid var(--neutral-400)`
      // — CardPricingSelected.jsx.
      expect(
        DabblerCard.fillOf(colors, card.variant),
        colors.surfaceSunken,
      );
      expect(
        DabblerCard.borderOf(colors, card.variant),
        colors.borderDefault,
      );
      expect(
        DabblerCard.borderWidthOf(card.variant),
        DabblerSizing.borderDefault * 2,
      );
    });

    testWidgets('the tile adds no chrome of its own',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_yearly));
      // The only decorated box this file draws is the indicator. Everything
      // else — fill, border, radius — belongs to DabblerCard.
      expect(
        find.descendant(
          of: find.byType(DabblerCardPricing),
          matching: find.byType(Container),
        ),
        findsOneWidget,
      );
      final BoxDecoration decoration = _indicatorDecoration(tester);
      expect(decoration.shape, BoxShape.circle);
      // Flat: no shadow, no gradient, anywhere in the tile.
      expect(decoration.boxShadow, isNull);
      expect(decoration.gradient, isNull);
    });
  });

  group('the indicator', () {
    testWidgets('selected — a brand-filled disc carrying a tick',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_yearly));
      final DabblerColors colors = _colors();
      final BoxDecoration decoration = _indicatorDecoration(tester);

      // `backgroundColor: var(--purple-600)`, `2px solid var(--purple-600)`.
      expect(decoration.color, colors.brandPrimary);
      expect((decoration.border! as Border).top.color, colors.brandPrimary);
      expect(
        (decoration.border! as Border).top.width,
        DabblerCardPricing.indicatorBorderWidth,
      );

      // THIS ASSERTED A DEFECT: the tick was `DabblerIcon('check')`, and
      // `check` is not a name this package can resolve — `iconsax_flutter`
      // declares `tick_circle` and `tick_square` and no bare tick, so it fell
      // through `DabblerIconRegistry.resolve` to the placeholder and the
      // selected tile rendered a garbled mark. Confirmed on the built gallery.
      //
      // The design does not draw an icon here at all. It draws a three-point
      // polyline, `M 0 2.5 L 2.8 5.5 L 8 0`, in an `8 x 5.5` box with a round
      // cap and join — read off the specimen's flattened `<path>`. So there is
      // no icon to assert, and reinstating one would reinstate the placeholder.
      expect(find.byType(DabblerIcon), findsNothing);

      final Size tick = tester.getSize(
        find.descendant(
          of: find.byType(DabblerCardPricing),
          matching: find.byType(CustomPaint),
        ).first,
      );
      expect(
        tick,
        const Size(DabblerCardPricing.tickWidth,
            DabblerCardPricing.tickHeight),
      );
    });

    testWidgets('unselected — an empty --outline-strong ring',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_monthly));
      final DabblerColors colors = _colors();
      final BoxDecoration decoration = _indicatorDecoration(tester);

      // No fill; `2px solid var(--neutral-500)`, which is --outline-strong.
      expect(decoration.color, isNull);
      expect((decoration.border! as Border).top.color, colors.borderStrong);
      expect(
        (decoration.border! as Border).top.width,
        DabblerCardPricing.indicatorBorderWidth,
      );
      // No tick — the ring is empty.
      expect(find.byType(DabblerIcon), findsNothing);
    });

    testWidgets('is the drawn 28x28 in both states, off the icon grid',
        (WidgetTester tester) async {
      for (final bool selected in <bool>[true, false]) {
        await tester.pumpWidget(
          _host(
            DabblerCardPricing(
              plan: 'yearly',
              price: r'$59.99/yr',
              selected: selected,
              key: ValueKey<bool>(selected),
            ),
          ),
        );
        final Size size = tester.getSize(
          find.descendant(
            of: find.byType(DabblerCardPricing),
            matching: find.byType(Container),
          ),
        );
        // TOKEN CONFLICT, asserted deliberately: the rendered specimen draws
        // both the selected tick disc and the unselected ring as 28x28 boxes.
        // This asserted 24 / `DabblerSizing.iconMd`, which drew the control
        // 4px short in each axis on a 186x123 tile.
        //
        // 28 is off the icon grid (18 / 24 / 32) and that gap is reported. The
        // indicator is a CONTROL, not an icon, so the icon grid was never the
        // right constraint — do not snap this back to `iconMd`.
        expect(size, const Size(28, 28));
        expect(DabblerCardPricing.indicatorSide, 28);
      }
    });
  });

  group('content and type', () {
    testWidgets('the four text slots carry the source\'s values',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_monthly));
      // CardPricingSelected.d.ts's four defaults, minus the priceNote it does
      // not have.
      expect(find.text('monthly'), findsOneWidget);
      expect(find.text(r'$5.99/mo'), findsOneWidget);
      expect(find.text('billed monthly'), findsOneWidget);
      expect(find.text('7d free trial'), findsOneWidget);
    });

    testWidgets('the optional lines drop out cleanly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerCardPricing(plan: 'free', price: r'$0')),
      );
      expect(find.text('free'), findsOneWidget);
      expect(find.text(r'$0'), findsOneWidget);
      expect(find.byType(DabblerBadge), findsNothing);
      // Two texts only: no note, no billing line, no pill.
      expect(
        find.descendant(
          of: find.byType(DabblerCardPricing),
          matching: find.byType(Text),
        ),
        findsNWidgets(2),
      );
    });

    test('the styles are ramp steps, not invented sizes', () {
      // --font-size-body-lg 15 @700 → .t-subheadline at bold.
      final TextStyle plan =
          DabblerCardPricing.planStyleFor(TextDirection.ltr);
      expect(plan.fontSize, DabblerType.subheadline.fontSize);
      expect(plan.fontWeight, DabblerType.bold);

      // --font-size-body-sm 13 @400 → .t-footnote, unmodified.
      final TextStyle price =
          DabblerCardPricing.priceStyleFor(TextDirection.ltr);
      expect(price.fontSize, DabblerType.footnote.fontSize);
      expect(price.fontWeight, DabblerType.regular);

      // --font-size-overline 11 @400 → .t-caption-2, unmodified.
      final TextStyle note =
          DabblerCardPricing.noteStyleFor(TextDirection.ltr);
      expect(note.fontSize, DabblerType.caption2.fontSize);
      expect(note.fontWeight, DabblerType.regular);
    });

    testWidgets('text takes its colour from the tokens',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_yearly));
      final DabblerColors colors = _colors();

      // --neutral-900 is --ink is textPrimary.
      expect(
        tester.widget<Text>(find.text('yearly')).style!.color,
        colors.textPrimary,
      );
      expect(
        tester.widget<Text>(find.text(r'$59.99/yr')).style!.color,
        colors.textPrimary,
      );
      // --neutral-700 is --muted is textSecondary.
      expect(
        tester.widget<Text>(find.text(r'($5.00/mo)')).style!.color,
        colors.textSecondary,
      );
      expect(
        tester.widget<Text>(find.text('billed annually')).style!.color,
        colors.textSecondary,
      );
    });

    test('the slot gap is a base-3 step', () {
      expect(DabblerCardPricing.slotGap, DabblerSpacing.stackTight);
      expect(DabblerSpacing.scale, contains(DabblerCardPricing.slotGap));
    });

    test('the trial pill inset is a base-3 step', () {
      expect(DabblerCardPricing.trialInset, DabblerSpacing.space5);
      expect(DabblerSpacing.scale, contains(DabblerCardPricing.trialInset));
    });
  });

  group('the trial pill', () {
    testWidgets('straddles the card\'s top edge', (WidgetTester tester) async {
      await tester.pumpWidget(_host(_yearly));

      final Rect card = tester.getRect(find.byType(DabblerCard));
      final Rect pill = tester.getRect(find.byType(DabblerBadge));

      // Centred on the edge: half above, half below. `top: -10` in the Figma
      // dump, expressed without depending on the badge's measured height.
      expect(pill.top, lessThan(card.top));
      expect(pill.bottom, greaterThan(card.top));
      expect(pill.center.dy, closeTo(card.top, 0.5));
    });

    testWidgets('is inset from the LEADING edge under RTL',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_yearly, direction: TextDirection.rtl));

      final Rect card = tester.getRect(find.byType(DabblerCard));
      final Rect pill = tester.getRect(find.byType(DabblerBadge));

      // In RTL the leading edge is the right one.
      expect(
        card.right - pill.right,
        closeTo(DabblerCardPricing.trialInset, 0.5),
      );
    });

    testWidgets('is inset from the left under LTR',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_yearly));

      final Rect card = tester.getRect(find.byType(DabblerCard));
      final Rect pill = tester.getRect(find.byType(DabblerBadge));

      expect(
        pill.left - card.left,
        closeTo(DabblerCardPricing.trialInset, 0.5),
      );
    });
  });

  group('interaction', () {
    testWidgets('a tappable tile fires, and composes the system primitives',
        (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(
          DabblerCardPricing(
            plan: 'yearly',
            price: r'$59.99/yr',
            selected: true,
            onTap: () => taps++,
          ),
        ),
      );

      // The press and focus affordances are DabblerCard's, i.e. the system's —
      // not a bare GestureDetector of this file's own.
      expect(find.byType(DabblerFocusRing), findsOneWidget);
      expect(find.byType(DabblerPressScale), findsOneWidget);

      await tester.tap(find.byType(DabblerCardPricing));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('an inert tile has no focus ring and no press scale',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_yearly));
      expect(find.byType(DabblerFocusRing), findsNothing);
      expect(find.byType(DabblerPressScale), findsNothing);
    });

    testWidgets('enabled: false withholds the handler and the affordances',
        (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(
          DabblerCardPricing(
            plan: 'yearly',
            price: r'$59.99/yr',
            enabled: false,
            onTap: () => taps++,
          ),
        ),
      );
      expect(find.byType(DabblerFocusRing), findsNothing);
      expect(find.byType(DabblerPressScale), findsNothing);

      await tester.tap(find.byType(DabblerCardPricing));
      await tester.pump();
      expect(taps, 0);
    });
  });

  group('accessibility', () {
    testWidgets('the tile reports its selected state', (WidgetTester tester) async {
      for (final bool selected in <bool>[true, false]) {
        await tester.pumpWidget(
          _host(
            DabblerCardPricing(
              plan: 'yearly',
              price: r'$59.99/yr',
              selected: selected,
              onTap: () {},
            ),
          ),
        );

        final SemanticsNode node = tester.getSemantics(
          find.byType(DabblerCardPricing),
        );
        // `isSelected` is a Tristate: unset is neither true nor false.
        expect(
          node.flagsCollection.isSelected,
          selected ? Tristate.isTrue : Tristate.isFalse,
        );
        expect(node.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
        // Merged with DabblerCard's button node, not a second node beside it.
        expect(node.flagsCollection.isButton, isTrue);
      }
    });

    testWidgets('an unlabelled tile still reads its own content',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_yearly));
      final SemanticsNode node = tester.getSemantics(
        find.byType(DabblerCardPricing),
      );
      expect(
        node.label,
        contains('yearly'),
      );
      expect(node.label, contains(r'$59.99/yr'));
      expect(node.label, contains('billed annually'));
      expect(node.label, contains('7d free trial'));
    });

    testWidgets('an explicit label wins', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerCardPricing(
            plan: 'yearly',
            price: r'$59.99/yr',
            semanticLabel: 'Yearly plan, best value',
          ),
        ),
      );
      final SemanticsNode node = tester.getSemantics(
        find.byType(DabblerCardPricing),
      );
      expect(node.label, 'Yearly plan, best value');
    });

    testWidgets('the whole tile is the target, and it clears 44×44',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          DabblerCardPricing(
            plan: 'yearly',
            price: r'$59.99/yr',
            priceNote: r'($5.00/mo)',
            billingNote: 'billed annually',
            selected: true,
            onTap: () {},
          ),
        ),
      );

      final Size size = tester.getSize(find.byType(DabblerCard));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
      // And comfortably clears the token floor too.
      expect(size.height, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
    });

    testWidgets('meets the framework\'s own tap-target guideline',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          DabblerCardPricing(
            plan: 'yearly',
            price: r'$59.99/yr',
            billingNote: 'billed annually',
            onTap: () {},
          ),
        ),
      );
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });
  });

  group('themes', () {
    testWidgets('the indicator follows the active theme\'s brand',
        (WidgetTester tester) async {
      for (final DabblerTheme theme in <DabblerTheme>[
        DabblerTheme.main,
        DabblerTheme.sport,
        DabblerTheme.social,
      ]) {
        // A fresh instance per iteration: an identical `const` widget makes
        // `Element.updateChild` skip the subtree entirely, and the indicator
        // would keep the previous theme's brand.
        await tester.pumpWidget(
          _host(
            DabblerCardPricing(
              plan: 'yearly',
              price: r'$59.99/yr',
              selected: true,
              key: ValueKey<DabblerTheme>(theme),
            ),
            theme: theme,
          ),
        );
        // MaterialApp animates a ThemeData change, so the extension is only at
        // the new theme's values once that animation has run out.
        await tester.pumpAndSettle();
        expect(
          _indicatorDecoration(tester).color,
          _colors(theme: theme).brandPrimary,
        );
      }
    });

    testWidgets('it builds in dark without a hardcoded colour',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_yearly, brightness: Brightness.dark));
      expect(tester.takeException(), isNull);
      expect(
        _indicatorDecoration(tester).color,
        _colors(brightness: Brightness.dark).brandPrimary,
      );
    });
  });
}
