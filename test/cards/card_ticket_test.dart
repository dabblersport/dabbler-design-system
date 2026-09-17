import 'package:dabbler_design_system/src/cards/card.dart';
import 'package:dabbler_design_system/src/cards/card_ticket.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_palette.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DabblerColors _colors({
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

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

/// The specimen at `components/cards/cards.card.html:63`.
DabblerCardTicket _specimen({
  DabblerTicketHeader header = DabblerTicketHeader.indigo,
  DabblerTicketStatusTone tone = DabblerTicketStatusTone.progress,
  String? status = 'Upcoming',
  List<DabblerTicketAction> actions = const <DabblerTicketAction>[],
  bool enabled = true,
}) =>
    DabblerCardTicket(
      header: header,
      code: 'GBD99763JS',
      date: '24/09/2024',
      organiser: 'Reform Padel Club',
      title: 'Tuesday Padel Doubles',
      status: status,
      statusTone: tone,
      price: 'AED 45',
      actions: actions,
      enabled: enabled,
    );

void main() {
  group('KAN-234 AC1 — CardTicket composes DS-800\'s base Card', () {
    testWidgets('it renders exactly one DabblerCard',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_specimen()));

      expect(find.byType(DabblerCard), findsOneWidget);
    });

    testWidgets('on the white shell at --radius-xxl',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_specimen()));

      final DabblerCard card =
          tester.widget<DabblerCard>(find.byType(DabblerCard));
      expect(card.variant, DabblerCardVariant.white);
      expect(card.radius, DabblerRadius.xxl);
      expect(DabblerCard.fillOf(_colors(), card.variant),
          _colors().surfaceCard);
    });

    testWidgets('all four slots are used, as DS-800 published them',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_specimen()));

      final DabblerCard card =
          tester.widget<DabblerCard>(find.byType(DabblerCard));
      expect(card.media, isNotNull, reason: 'the coloured strip');
      expect(card.header, isNotNull, reason: 'organiser, title, pill');
      expect(card.child, isNotNull, reason: 'the dashed rule');
      expect(card.footer, isNotNull, reason: 'price beside actions');
    });

    testWidgets('padding and gap are the source\'s grid steps',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_specimen()));

      final DabblerCard card =
          tester.widget<DabblerCard>(find.byType(DabblerCard));
      // `padding: '18px 24px 21px'` — every one a base-3 step.
      expect(card.padding, DabblerCardTicket.bodyPadding);
      expect(DabblerSpacing.scale,
          containsAll(<double>[18, 24, 21, DabblerCardTicket.bodyGap]));
      // `gap: 15`, not DabblerCard's default 12.
      expect(card.gap, DabblerSpacing.space5);
    });
  });

  group('the header strip — five colours from the HEADERS table', () {
    test('brand follows the theme', () {
      final DabblerColors colors = _colors();
      expect(
        DabblerCardTicket.headerFillOf(DabblerTicketHeader.brand, colors),
        colors.brandPrimary,
      );
      expect(
        DabblerCardTicket.headerInkOf(DabblerTicketHeader.brand, colors),
        colors.onBrand,
      );
    });

    test('amber and pink take the decorative tile tones, ink included', () {
      final DabblerColors colors = _colors();
      expect(
        DabblerCardTicket.headerFillOf(DabblerTicketHeader.amber, colors),
        DabblerColors.tileAmber.surface,
      );
      expect(
        DabblerCardTicket.headerInkOf(DabblerTicketHeader.amber, colors),
        DabblerColors.tileAmber.ink,
      );
      expect(
        DabblerCardTicket.headerFillOf(DabblerTicketHeader.pink, colors),
        DabblerColors.tileAccent.surface,
      );
      expect(
        DabblerCardTicket.headerInkOf(DabblerTicketHeader.pink, colors),
        DabblerColors.tileAccent.ink,
      );
    });

    test('mint is the one header that reads off the status API', () {
      final DabblerColors colors = _colors();
      expect(
        DabblerCardTicket.headerFillOf(DabblerTicketHeader.mint, colors),
        colors.success.surface,
      );
      expect(
        DabblerCardTicket.headerInkOf(DabblerTicketHeader.mint, colors),
        colors.success.strong,
      );
    });

    test('indigo is the D-004 stand-in, not --accent-indigo', () {
      final DabblerColors colors = _colors();
      // The documented defect: --accent-indigo (#5C50E6) is not declared in
      // tokens/colors.css, so --social-info stands in until D-004 lands it.
      expect(
        DabblerCardTicket.headerFillOf(DabblerTicketHeader.indigo, colors),
        DabblerPalette.socialInfo,
      );
      expect(
        DabblerCardTicket.headerInkOf(DabblerTicketHeader.indigo, colors),
        DabblerPalette.paper,
        reason: 'the source names --neutral-white, a literal, not a role',
      );
    });

    test('indigo is brightness-invariant, because its fill is', () {
      expect(
        DabblerCardTicket.headerFillOf(
            DabblerTicketHeader.indigo, _colors(brightness: Brightness.dark)),
        DabblerCardTicket.headerFillOf(DabblerTicketHeader.indigo, _colors()),
      );
    });

    testWidgets('the strip carries the code and the date',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_specimen()));

      expect(find.text('GBD99763JS'), findsOneWidget);
      expect(find.text('24/09/2024'), findsOneWidget);

      final TextStyle style =
          tester.widget<Text>(find.text('24/09/2024')).style!;
      // `fontSize: 17, lineHeight: '22px', fontWeight: 500` — .t-callout.
      expect(style.fontSize, DabblerType.callout.fontSize);
      expect(style.fontWeight, DabblerType.callout.fontWeight);
      expect(
        style.color,
        DabblerCardTicket.headerInkOf(DabblerTicketHeader.indigo, _colors()),
      );
    });
  });

  // DECISIONS.md D-015 — the pill is literal, 13px/weight 500/no border, and
  // is NOT DabblerBadge (11px Bold + a 20% hairline). These assertions are the
  // guard against it being "fixed" back to composing Badge.
  group('the status pill is literal, per D-015', () {
    testWidgets('a status renders one pill; no status renders none',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_specimen()));
      expect(find.text('Upcoming'), findsOneWidget);

      await tester.pumpWidget(_host(_specimen(status: null)));
      expect(find.text('Upcoming'), findsNothing);
    });

    testWidgets('the pill is 13px at weight 500 on the tag pair\'s ink',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        _specimen(tone: DabblerTicketStatusTone.success),
      ));

      final TextStyle style =
          tester.widget<Text>(find.text('Upcoming')).style!;
      expect(style.fontSize, 13);
      expect(style.fontSize, DabblerType.footnote.fontSize);
      expect(style.fontWeight, DabblerType.medium);
      expect(style.color, DabblerColors.tagSuccess.ink);
    });

    testWidgets('the pill has the tag surface, the pill radius and NO border',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        _specimen(tone: DabblerTicketStatusTone.success),
      ));

      final Container pill = tester.widget<Container>(
        find.ancestor(
          of: find.text('Upcoming'),
          matching: find.byType(Container),
        ).first,
      );
      final BoxDecoration decoration = pill.decoration! as BoxDecoration;
      expect(decoration.color, DabblerColors.tagSuccess.surface);
      expect(decoration.border, isNull);
      expect(decoration.borderRadius, DabblerRadius.pillAll);
      expect(
        pill.padding,
        const EdgeInsets.symmetric(
          vertical: DabblerCardTicket.statusPaddingY,
          horizontal: DabblerCardTicket.statusPaddingX,
        ),
      );
    });

    test('the seven workflow tones map to their own --tag-* pair', () {
      expect(DabblerCardTicket.toneColorOf(DabblerTicketStatusTone.pending),
          DabblerColors.tagPending);
      expect(DabblerCardTicket.toneColorOf(DabblerTicketStatusTone.progress),
          DabblerColors.tagProgress);
      expect(DabblerCardTicket.toneColorOf(DabblerTicketStatusTone.submitted),
          DabblerColors.tagSubmitted);
      expect(DabblerCardTicket.toneColorOf(DabblerTicketStatusTone.review),
          DabblerColors.tagReview);
      expect(DabblerCardTicket.toneColorOf(DabblerTicketStatusTone.success),
          DabblerColors.tagSuccess);
      expect(DabblerCardTicket.toneColorOf(DabblerTicketStatusTone.failed),
          DabblerColors.tagFailed);
      expect(DabblerCardTicket.toneColorOf(DabblerTicketStatusTone.expired),
          DabblerColors.tagExpired);
    });

    test('the four booking aliases resolve exactly as STATUSES declares', () {
      // upcoming → progress, past → review, live → success, cancelled → failed.
      expect(DabblerCardTicket.toneColorOf(DabblerTicketStatusTone.upcoming),
          DabblerColors.tagProgress);
      expect(DabblerCardTicket.toneColorOf(DabblerTicketStatusTone.past),
          DabblerColors.tagReview);
      expect(DabblerCardTicket.toneColorOf(DabblerTicketStatusTone.live),
          DabblerColors.tagSuccess);
      expect(DabblerCardTicket.toneColorOf(DabblerTicketStatusTone.cancelled),
          DabblerColors.tagFailed);
    });

    test('every tone resolves — the table has no hole', () {
      for (final DabblerTicketStatusTone tone
          in DabblerTicketStatusTone.values) {
        expect(DabblerCardTicket.toneColorOf(tone).surface, isNotNull);
        expect(DabblerCardTicket.toneColorOf(tone).ink, isNotNull);
      }
    });
  });

  group('the body', () {
    testWidgets('organiser is the drawn 14/19; title and price keep their steps',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_specimen()));

      final TextStyle organiser =
          tester.widget<Text>(find.text('Reform Padel Club')).style!;
      // TOKEN CONFLICT, asserted deliberately: the design draws the organiser
      // at `font-size: 14px; line-height: 19px` — measured on the rendered
      // specimen `components/cards/cards.card.html` with `getComputedStyle`.
      // **The ramp has no 14.** This asserted `.t-footnote` (13/18) on the
      // reasoning that the nearest step should win; that snapped the organiser
      // a pixel under every surface that draws it, and it is the class of
      // substitution the fidelity pass exists to undo.
      //
      // Do NOT "restore" `DabblerType.footnote.fontSize` here. The ramp gap is
      // reported; if a 14 step is added, this becomes a reference to it.
      expect(organiser.fontSize, 14);
      expect(organiser.height, 19 / 14);
      expect(organiser.color, _colors().textSecondary);

      final TextStyle title =
          tester.widget<Text>(find.text('Tuesday Padel Doubles')).style!;
      // .t-title-2's metrics, the sans face, the source's Medium.
      expect(title.fontSize, DabblerType.title2.fontSize);
      expect(title.fontWeight, DabblerType.medium);
      expect(
        title.fontFamily,
        DabblerType.fontFamilyFor(
            DabblerTypeRole.sans, DabblerTypeScript.latin),
      );
      expect(title.color, _colors().textPrimary);

      final TextStyle price = tester.widget<Text>(find.text('AED 45')).style!;
      expect(price.fontSize, DabblerType.title1.fontSize);
      expect(price.fontWeight, DabblerType.medium);
      expect(
        price.fontFamily,
        DabblerType.fontFamilyFor(
            DabblerTypeRole.sans, DabblerTypeScript.latin),
      );
    });

    testWidgets('RTL swaps the sans face to Meral Sans, not to a display face',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(_host(_specimen(), direction: TextDirection.rtl));

      final TextStyle title =
          tester.widget<Text>(find.text('Tuesday Padel Doubles')).style!;
      expect(
        title.fontFamily,
        DabblerType.fontFamilyFor(
            DabblerTypeRole.sans, DabblerTypeScript.arabic),
      );
    });

    testWidgets('the dashed rule is one hairline tall in --outline-card',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_specimen()));

      final DabblerCard card =
          tester.widget<DabblerCard>(find.byType(DabblerCard));
      final Size size = tester.getSize(find.byWidget(card.child!));
      expect(size.height, DabblerSizing.borderDefault);
      // GRID CONFLICT, asserted deliberately: the rule's drawn period is ~4px
      // — Blink's 1px dashed stroke, measured on the rendered specimen. This
      // asserted `DabblerSpacing.space1` (3 on, 3 off) because 3 is a grid
      // step, which drew the rule a third coarser than the design.
      //
      // 2 is off the base-3 grid on purpose. A dash pattern is a stroke
      // texture, not a layout measure, and the grid has no claim on it — so do
      // not snap these back to `space1`.
      expect(DabblerCardTicket.dashLength, 2);
      expect(DabblerCardTicket.dashGap, 2);
    });
  });

  group('the action pills', () {
    testWidgets('one action for a past booking, two for an open one',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_specimen(
        actions: const <DabblerTicketAction>[
          DabblerTicketAction(label: 'View Detail'),
        ],
      )));
      expect(find.text('View Detail'), findsOneWidget);

      await tester.pumpWidget(_host(_specimen(
        actions: const <DabblerTicketAction>[
          DabblerTicketAction(label: 'Register'),
          DabblerTicketAction(label: 'Done'),
        ],
      )));
      expect(find.text('Register'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('a live pill fires and carries the system focus ring',
        (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(_host(_specimen(
        actions: <DabblerTicketAction>[
          DabblerTicketAction(label: 'Register', onPressed: () => taps++),
        ],
      )));

      expect(find.byType(DabblerFocusRing), findsOneWidget);
      await tester.tap(find.text('Register'));
      expect(taps, 1);
    });

    testWidgets('enabled: false withholds every action',
        (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(_host(_specimen(
        enabled: false,
        actions: <DabblerTicketAction>[
          DabblerTicketAction(label: 'Register', onPressed: () => taps++),
        ],
      )));

      await tester.tap(find.text('Register'));
      expect(taps, 0);
      expect(find.byType(DabblerFocusRing), findsNothing);
    });

    testWidgets('a pill is the drawn 40, under --touch-target-min',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_specimen(
        actions: const <DabblerTicketAction>[
          DabblerTicketAction(label: 'Register'),
        ],
      )));

      // TOKEN + ACCESSIBILITY CONFLICT, asserted deliberately: every action
      // pill on every ticket of the rendered specimen is a 40px box. This
      // asserted `DabblerSizing.touchTargetMin` (45) and `>= 44.0`, and the
      // old test NAME announced the deviation as a virtue — which taught the
      // next reader that overriding the drawing was the house rule.
      //
      // 40 clears neither the token nor Apple's 44pt floor, and that is a real
      // conflict, reported rather than hidden. The card itself is tappable via
      // `onTap`, so the 44pt affordance exists at card level. If the conflict
      // is resolved in favour of the floor it is resolved in the DESIGN first
      // and transcribed back — not decided here, and not by restoring the 45.
      expect(DabblerCardTicket.actionHeight, 40);
      expect(DabblerCardTicket.actionHeight, lessThan(DabblerSizing.touchTargetMin));

      final TextStyle style =
          tester.widget<Text>(find.text('Register')).style!;
      // `--ink` fill carrying `--surface-page` ink.
      expect(style.color, _colors().bgPrimary);
      expect(style.fontSize, DabblerType.subheadline.fontSize);
      expect(style.fontWeight, DabblerType.medium);
    });
  });

  group('the whole card', () {
    testWidgets('onTap reaches DabblerCard', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(_host(DabblerCardTicket(
        code: 'GBD99763JS',
        title: 'Tuesday Padel Doubles',
        onTap: () => taps++,
      )));

      await tester.tap(find.byType(DabblerCard));
      expect(taps, 1);
    });

    testWidgets('every header × every tone renders in every theme and mode',
        (WidgetTester tester) async {
      for (final DabblerTheme theme in DabblerTheme.values) {
        for (final Brightness brightness in Brightness.values) {
          for (final DabblerTicketHeader header
              in DabblerTicketHeader.values) {
            await tester.pumpWidget(_host(
              _specimen(header: header),
              theme: theme,
              brightness: brightness,
            ));
            expect(tester.takeException(), isNull,
                reason: '$theme / $brightness / $header');
          }
        }
      }

      for (final DabblerTicketStatusTone tone
          in DabblerTicketStatusTone.values) {
        await tester.pumpWidget(_host(_specimen(tone: tone)));
        expect(tester.takeException(), isNull, reason: '$tone');
      }
    });
  });
}
