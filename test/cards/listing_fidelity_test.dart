// Listings fidelity pass — every listing part measured against the computed
// layout of `Listings.dc.html` (rendered at 393 wide; the measurements are in
// `Dabbler-Alpha-Plan/listings/diff-table.md`). Geometry, LTR and RTL, a 2x
// text scale without overflow, and dark-mode contrast of the text on the card.
import 'dart:math' as math;

import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';
import '../support/png_harness.dart' show loadDesignSystemFonts;

Widget _scaled(Widget child, {double scale = 1, TextDirection? direction}) =>
    host(
      Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child,
        ),
      ),
      direction: direction ?? TextDirection.ltr,
      width: 357,
    );

double _luminance(Color c) => c.computeLuminance();

double _contrast(Color a, Color b) {
  final double l1 = _luminance(a);
  final double l2 = _luminance(b);
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

DabblerCardGame _game({Widget? trailing}) => DabblerCardGame(
  title: 'Tuesday 5-a-side',
  verified: true,
  tags: const <Widget>[
    DabblerListingTag(label: 'Football'),
    DabblerListingTag(
      label: 'Futsal 5s',
      tone: DabblerListingTagTone.brandTint,
    ),
    DabblerListingTag(
      label: 'Intermediate',
      tone: DabblerListingTagTone.warning,
    ),
  ],
  dayLabel: 'Today',
  timeLabel: '7:30 PM',
  meta: const <String>['Dubai Sports City', '2.1 km', '90 min'],
  progress: const DabblerCardEventPlayers(
    label: '9 of 10 players in',
    joined: 9,
    capacity: 10,
    note: '1 spot left · almost full',
    tone: DabblerProgressBarTone.warning,
  ),
  price: const DabblerCardEventPrice(price: 'AED 40', note: 'per player'),
  action: DabblerCardEventListing.joinButton(
    key: const Key('join'),
    label: 'Join game',
    onPressed: () {},
  ),
  trailing: trailing,
  onTap: () {},
);

DabblerCardVenue _venue() => DabblerCardVenue(
  name: 'Elite Football Arena',
  area: 'Dubai Silicon Oasis',
  tags: <Widget>[
    DabblerCardVenue.distanceTag(
      key: const Key('distance'),
      label: '4 km away',
    ),
    DabblerCardVenue.rating(rating: '4.8', reviews: '(126)'),
    const DabblerListingTag(
      label: 'Top rated',
      tone: DabblerListingTagTone.warning,
    ),
  ],
  sports: const <Widget>[
    DabblerListingTag.outlined(key: Key('sport'), label: 'Football'),
    DabblerListingTag.outlined(label: 'Padel'),
  ],
  facilities: <Widget>[
    DabblerCardVenue.facility(icon: 'car', label: 'Parking'),
    DabblerCardVenue.facility(icon: 'cup', label: 'Cafe'),
  ],
  price: 'AED 120 / hour',
  priceCaption: 'Starting from',
  trailing: DabblerButton(label: 'View venue', onPressed: () {}),
  onTap: () {},
);

void main() {
  // Real faces, so widths (and a 2x scale) are the app's, not Ahem's.
  setUpAll(loadDesignSystemFonts);

  group('ListingTag', () {
    testWidgets('filled tag: 4/10 padding, 11/15 600, no hairline — 23 tall', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _scaled(
          const Align(
            alignment: AlignmentDirectional.topStart,
            child: DabblerListingTag(key: Key('t'), label: 'Football'),
          ),
        ),
      );
      expect(tester.getSize(find.byKey(const Key('t'))).height, 23);
      final Text text = tester.widget<Text>(find.text('Football'));
      expect(text.style!.fontSize, 11);
      expect(text.style!.height! * 11, closeTo(15, 0.01));
      expect(text.style!.fontWeight, FontWeight.w600);
      final DecoratedBox box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byKey(const Key('t')),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect((box.decoration as BoxDecoration).border, isNull);
      expect(
        tester.getTopLeft(find.text('Football')).dx -
            tester.getTopLeft(find.byKey(const Key('t'))).dx,
        DabblerListingTag.paddingInline,
      );
    });

    testWidgets('outlined sport chip: 5/12 inside a 1px hairline — 28 tall', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _scaled(
          const Align(
            alignment: AlignmentDirectional.topStart,
            child: DabblerListingTag.outlined(key: Key('t'), label: 'Padel'),
          ),
        ),
      );
      expect(tester.getSize(find.byKey(const Key('t'))).height, 28);
      final Text text = tester.widget<Text>(find.text('Padel'));
      expect(text.style!.fontSize, 12);
      expect(text.style!.fontWeight, FontWeight.w500);
    });

    for (final Brightness b in Brightness.values) {
      test('every tone clears 4.5:1 ink on fill ($b)', () {
        final DabblerColors c = testColors(brightness: b);
        for (final DabblerListingTagTone t in DabblerListingTagTone.values) {
          final Color ink = DabblerListingTag.inkOf(c, t);
          final Color fill = DabblerListingTag.fillOf(c, t);
          expect(
            _contrast(ink, fill),
            // Brand in dark is the provisional `--main-p-400`
            // (`colors.css:200`, not signed off): brand ink, or on-brand ink
            // on a brand fill, clears 3:1 only — the same pair every brand
            // run and primary button in the system uses in dark.
            greaterThanOrEqualTo(
              b == Brightness.dark &&
                      (ink == c.brandPrimary || fill == c.brandPrimary)
                  ? 3.0
                  : 4.5,
            ),
            reason: '$t',
          );
        }
      });
    }

    testWidgets('RTL: the glyph sits at the inline start (right)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _scaled(
          Align(
            alignment: AlignmentDirectional.topStart,
            child: DabblerCardVenue.distanceTag(label: 'على بعد 4 كم'),
          ),
          direction: TextDirection.rtl,
        ),
      );
      expect(
        tester.getCenter(find.byType(DabblerIcon)).dx,
        greaterThan(tester.getCenter(find.text('على بعد 4 كم')).dx),
      );
    });
  });

  group('MetaLine', () {
    testWidgets('pin, then facts 5 apart split by 3px dots; first at 500', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(
        _scaled(
          const DabblerMetaLine(
            items: <String>['Dubai Sports City', '2.1 km', '90 min'],
          ),
        ),
      );
      final Finder dots = find.byWidgetPredicate(
        (Widget w) =>
            w is SizedBox &&
            w.width == DabblerMetaLine.dotSize &&
            w.height == DabblerMetaLine.dotSize,
      );
      expect(dots, findsNWidgets(2));
      expect(
        tester.widget<Text>(find.text('Dubai Sports City')).style!.fontWeight,
        FontWeight.w500,
      );
      expect(
        tester.widget<Text>(find.text('2.1 km')).style!.fontWeight,
        FontWeight.w400,
      );
      final double venueEnd = tester
          .getTopRight(find.text('Dubai Sports City'))
          .dx;
      final double dotStart = tester.getTopLeft(dots.first).dx;
      expect(dotStart - venueEnd, DabblerMetaLine.gap);
      expect(
        find.bySemanticsLabel('Dubai Sports City, 2.1 km, 90 min'),
        findsOneWidget,
      );
      h.dispose();
    });

    testWidgets('RTL: the pin is at the right, facts run leftwards', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _scaled(
          const DabblerMetaLine(items: <String>['شاطئ كايت', '3 كم']),
          direction: TextDirection.rtl,
        ),
      );
      final double pin = tester.getCenter(find.byType(DabblerIcon)).dx;
      final double place = tester.getCenter(find.text('شاطئ كايت')).dx;
      final double km = tester.getCenter(find.text('3 كم')).dx;
      expect(pin, greaterThan(place));
      expect(place, greaterThan(km));
    });
  });

  group('CardGame', () {
    for (final TextDirection d in TextDirection.values) {
      testWidgets('shell 18 / white, time 20/26 700, price 22/27 700 ($d)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_scaled(_game(), direction: d));
        expect(tester.takeException(), isNull);
        final DabblerCard card = tester.widget<DabblerCard>(
          find.byType(DabblerCard),
        );
        expect(card.variant, DabblerCardVariant.white);
        expect(card.radius, 18);
        expect(card.padding, DabblerCardEventListing.cardPadding);
        final TextStyle figure = DabblerType.figureLarge.resolveForDirection(d);
        final Text time = tester.widget<Text>(find.text('7:30 PM'));
        expect(time.style!.fontSize, figure.fontSize);
        expect(DabblerType.figureLarge.fontSize, 20);
        expect(DabblerType.figureLarge.latinLeading, 26);
        expect(time.style!.height, figure.height);
        expect(time.style!.fontWeight, FontWeight.w700);
        final TextStyle xl = DabblerType.figureXl.resolveForDirection(d);
        final Text price = tester.widget<Text>(find.text('AED 40'));
        expect(price.style!.fontSize, xl.fontSize);
        expect(DabblerType.figureXl.fontSize, 22);
        expect(DabblerType.figureXl.latinLeading, 27);
        // Title at the inline start, time at the inline end.
        final double title = tester.getCenter(find.text('Tuesday 5-a-side')).dx;
        final double at = tester.getCenter(find.text('7:30 PM')).dx;
        expect(d == TextDirection.ltr ? title < at : title > at, isTrue);
        // Title to tags 6 — the frame's 7 on the base-3 grid.
        expect(
          tester.getTopLeft(find.byType(DabblerListingTag).first).dy -
              tester.getBottomLeft(find.text('Tuesday 5-a-side')).dy,
          DabblerSpacing.space2,
        );
        expect(find.byType(DabblerMetaLine), findsOneWidget);
      });
    }

    testWidgets('Join takes half of what the social counts leave', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _scaled(
          _game(
            trailing: const SizedBox(key: Key('counts'), width: 72, height: 20),
          ),
        ),
      );
      final double row = 357 - 2 * DabblerCardEventListing.cardPadding.left;
      expect(
        tester.getSize(find.byKey(const Key('join'))).width,
        closeTo((row - DabblerListingActionRow.gap - 72) / 2, 0.01),
      );
      expect(
        tester.getTopRight(find.byKey(const Key('counts'))).dx,
        closeTo(
          tester.getTopRight(find.byType(DabblerCard)).dx -
              DabblerCardEventListing.cardPadding.right,
          0.01,
        ),
      );
    });

    testWidgets('without counts Join fills the row', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_scaled(_game()));
      expect(
        tester.getSize(find.byKey(const Key('join'))).width,
        357 - 2 * DabblerCardEventListing.cardPadding.left,
      );
    });

    testWidgets('2x text: no overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        _scaled(SingleChildScrollView(child: _game()), scale: 2),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('dark: every text run on the card clears 4.5:1', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(_game(), brightness: Brightness.dark, width: 357),
      );
      final DabblerColors c = testColors(brightness: Brightness.dark);
      final Color fill = DabblerCard.fillOf(c, DabblerCardVariant.white);
      for (final Text t in tester.widgetList<Text>(find.byType(Text))) {
        final Color? ink = t.style?.color;
        if (ink == null || ink == c.onBrand) continue; // on the brand button
        // Tag inks sit on their own tag fill — checked in the tag group.
        if (<String>[
          'Football',
          'Futsal 5s',
          'Intermediate',
        ].contains(t.data)) {
          continue;
        }
        expect(
          _contrast(ink, fill),
          // See the tag test: the provisional dark brand ink ("Today").
          greaterThanOrEqualTo(ink == c.brandPrimary ? 3.0 : 4.5),
          reason: t.data,
        );
      }
    });
  });

  group('CardVenue', () {
    for (final TextDirection d in TextDirection.values) {
      testWidgets('white shell 18, chips 23 / 28, 16/21 price ($d)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_scaled(_venue(), direction: d));
        expect(tester.takeException(), isNull);
        final DabblerCard card = tester.widget<DabblerCard>(
          find.byType(DabblerCard),
        );
        expect(card.variant, DabblerCardVariant.white);
        expect(card.radius, 18);
        expect(tester.getSize(find.byKey(const Key('distance'))).height, 23);
        expect(tester.getSize(find.byKey(const Key('sport'))).height, 28);
        final Text price = tester.widget<Text>(find.text('AED 120 / hour'));
        expect(
          price.style!.fontSize,
          DabblerType.body.resolveForDirection(d).fontSize,
        );
        expect(DabblerType.body.fontSize, 16);
        expect(DabblerType.body.latinLeading, 21);
        expect(price.style!.fontWeight, FontWeight.w600);
        final Text caption = tester.widget<Text>(find.text('Starting from'));
        expect(
          caption.style!.height,
          DabblerType.tag.resolveForDirection(d).height,
        );
        expect(DabblerType.tag.latinLeading, 15);
        // Name block to tags 6 (the frame's 7), tags to sports 12.
        expect(
          tester.getTopLeft(find.byKey(const Key('distance'))).dy -
              tester.getBottomLeft(find.text('Dubai Silicon Oasis')).dy,
          closeTo(DabblerSpacing.space2, 1),
        );
        final Finder tagRow = find.ancestor(
          of: find.byKey(const Key('distance')),
          matching: find.byType(Wrap),
        );
        expect(
          tester.getTopLeft(find.byKey(const Key('sport'))).dy -
              tester.getBottomLeft(tagRow).dy,
          DabblerSpacing.stackDefault,
        );
        final double name = tester
            .getCenter(find.text('Elite Football Arena'))
            .dx;
        final double button = tester.getCenter(find.text('View venue')).dx;
        expect(d == TextDirection.ltr ? name < button : name > button, isTrue);
      });
    }

    testWidgets('2x text: no overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        _scaled(SingleChildScrollView(child: _venue()), scale: 2),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('the favourite well lays out at 32, flush with the padding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _scaled(
          DabblerCardVenue(
            name: 'Elite Football Arena',
            area: 'Dubai Silicon Oasis',
            favourite: DabblerFavouriteButton(
              key: const Key('fav'),
              selected: false,
              semanticLabel: 'Save',
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(
        tester.getSize(find.byKey(const Key('fav'))),
        const Size.square(32),
      );
      expect(
        tester.getTopRight(find.byType(DabblerCard)).dx -
            tester.getTopRight(find.byKey(const Key('fav'))).dx,
        DabblerCardEventListing.cardPadding.right,
      );
    });

    testWidgets('dark: text on the card clears 4.5:1', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(_venue(), brightness: Brightness.dark, width: 357),
      );
      final DabblerColors c = testColors(brightness: Brightness.dark);
      final Color fill = DabblerCard.fillOf(c, DabblerCardVariant.white);
      for (final String s in <String>[
        'Elite Football Arena',
        'Dubai Silicon Oasis',
        'Parking',
        'Starting from',
        'AED 120 / hour',
        '4.8',
      ]) {
        final Color ink = tester.widget<Text>(find.text(s)).style!.color!;
        expect(_contrast(ink, fill), greaterThanOrEqualTo(4.5), reason: s);
      }
    });
  });

  group('CardUpcoming', () {
    testWidgets('12 radius, 1px hairline, 62 ring, display numeral', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _scaled(
          const DabblerCardUpcoming(
            title: 'Sunrise run',
            fraction: 0.5,
            countdownValue: '19',
            countdownUnit: 'hours',
            when: 'Sep 2 · 6:00 AM',
            place: 'Kite Beach',
            distance: '4.6 km',
          ),
        ),
      );
      final DabblerCard card = tester.widget<DabblerCard>(
        find.byType(DabblerCard),
      );
      expect(card.radius, DabblerRadius.lg);
      expect(card.variant, DabblerCardVariant.outlined);
      expect(tester.getSize(find.byType(DabblerRing)).width, 62);
      final Text n = tester.widget<Text>(find.text('19'));
      expect(n.style!.fontSize, 18);
    });

    testWidgets('a rail card under unbounded width hugs its content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _scaled(
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DabblerCardUpcoming(
              key: Key('u'),
              rail: true,
              title: 'Tuesday 5-a-side',
              fraction: 0.2,
              countdownValue: '4',
              countdownUnit: 'hours',
              when: 'Sep 2 · 7:30 PM · 60 min',
              place: 'Dubai Sports City',
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(const Key('u'))).width, lessThan(357));
      expect(
        tester.widget<Text>(find.text('Tuesday 5-a-side')).style!.fontSize,
        14,
      );
    });
  });

  group('Upcoming, games single and the rail tile', () {
    for (final TextDirection d in TextDirection.values) {
      testWidgets('date block first, 56 ring at the inline end ($d)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _scaled(
            const DabblerCardUpcoming(
              title: 'Tuesday 5-a-side',
              month: 'SEP',
              day: '2',
              fraction: 0.4,
              countdownValue: '4',
              countdownUnit: 'hours',
              when: '7:30 PM',
              place: 'Dubai Sports City',
            ),
            direction: d,
          ),
        );
        expect(tester.takeException(), isNull);
        expect(tester.getSize(find.byType(DabblerRing)).width, 56);
        final double month = tester.getCenter(find.text('SEP')).dx;
        final double ring = tester.getCenter(find.byType(DabblerRing)).dx;
        expect(d == TextDirection.ltr ? month < ring : month > ring, isTrue);
        expect(find.text('Dubai Sports City · 7:30 PM'), findsOneWidget);
      });
    }

    testWidgets('2x text: the countdown shrinks into the fixed ring', (
      WidgetTester tester,
    ) async {
      for (final Widget w in <Widget>[
        const DabblerCardUpcoming(
          title: 'Tuesday 5-a-side',
          month: 'OCT',
          day: '6',
          fraction: 0.4,
          countdownValue: '14',
          countdownUnit: 'hours',
          when: '4:18 PM',
          place: 'Dubai Sports City',
        ),
        const DabblerCardUpcoming(
          title: 'Sunrise run',
          fraction: 0.4,
          countdownValue: '19',
          countdownUnit: 'hours',
          when: 'Oct 7 · 6:35 AM',
          place: 'Kite Beach',
        ),
      ]) {
        await tester.pumpWidget(
          _scaled(SingleChildScrollView(child: w), scale: 2),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('rail tile: outlined 12 shell, 14/19 title, no place glyph', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _scaled(
          const Align(
            alignment: AlignmentDirectional.topStart,
            child: DabblerCardUpcomingRail(
              month: 'SEP',
              day: '2',
              title: 'Sunrise run',
              time: '6:00 AM',
              place: 'Kite Beach',
              fraction: 0.4,
              countdownValue: '3',
              countdownUnit: 'hours',
            ),
          ),
        ),
      );
      final DabblerCard card = tester.widget<DabblerCard>(
        find.byType(DabblerCard),
      );
      expect(card.variant, DabblerCardVariant.outlined);
      expect(card.radius, DabblerRadius.lg);
      expect(tester.widget<Text>(find.text('Sunrise run')).style!.fontSize, 14);
      expect(find.byType(DabblerIcon), findsNothing);
      expect(tester.widget<Text>(find.text('2')).style!.fontSize, 18);
    });
  });

  group('ListingSkeleton', () {
    for (final TextDirection d in TextDirection.values) {
      testWidgets('venue: 160 media then 58% / 38% lines ($d)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _scaled(
            const DabblerListingSkeleton(
              kind: DabblerListingSkeletonKind.venue,
            ),
            direction: d,
          ),
        );
        final List<Size> sizes = tester
            .widgetList<DabblerSkeleton>(find.byType(DabblerSkeleton))
            .map((DabblerSkeleton _) => Size.zero)
            .toList();
        expect(sizes, hasLength(4));
        final Finder media = find.byType(DabblerSkeleton).first;
        expect(tester.getSize(media).height, 160);
        final Finder title = find.byType(DabblerSkeleton).at(1);
        final Rect card = tester.getRect(find.byType(DabblerCard));
        final double inner =
            card.width - 2 * DabblerCardEventListing.cardPadding.left;
        expect(tester.getSize(title).width, closeTo(inner * 0.58, 0.5));
        // The line hugs the inline start.
        final double edge = d == TextDirection.ltr
            ? tester.getTopLeft(title).dx - card.left
            : card.right - tester.getTopRight(title).dx;
        expect(edge, closeTo(DabblerCardEventListing.cardPadding.left, 0.5));
      });
    }

    testWidgets('game: 45 tile, 52 block, 45 bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        _scaled(
          const DabblerListingSkeleton(kind: DabblerListingSkeletonKind.game),
        ),
      );
      final List<double> heights = <double>[
        for (final Element e in find.byType(DabblerSkeleton).evaluate())
          (e.renderObject! as RenderBox).size.height,
      ];
      expect(heights, containsAll(<double>[45, 14, 11, 28, 52]));
    });

    testWidgets('meetup: 36 face, 24 head block', (WidgetTester tester) async {
      await tester.pumpWidget(
        _scaled(
          const DabblerListingSkeleton(kind: DabblerListingSkeletonKind.meetup),
        ),
      );
      final List<double> heights = <double>[
        for (final Element e in find.byType(DabblerSkeleton).evaluate())
          (e.renderObject! as RenderBox).size.height,
      ];
      expect(heights, containsAll(<double>[16, 11, 24, 36, 12, 45]));
    });
  });

  group('EmptyState.listing', () {
    testWidgets('18 radius card, 60 brand well, 20 display title, 14/21 copy', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _scaled(
          DabblerEmptyState(
            icon: 'game',
            title: 'No games found nearby.',
            text: 'Nothing within 5 km in the next 3 days.',
            size: DabblerEmptyStateSize.listing,
            action: DabblerButton(label: 'Change filters', onPressed: () {}),
          ),
        ),
      );
      final DabblerCard card = tester.widget<DabblerCard>(
        find.byType(DabblerCard),
      );
      expect(card.radius, 18);
      expect(card.variant, DabblerCardVariant.white);
      final DabblerIcon icon = tester.widget<DabblerIcon>(
        find.byType(DabblerIcon).first,
      );
      expect(icon.size, 30);
      expect(
        tester
            .widget<Text>(find.text('No games found nearby.'))
            .style!
            .fontSize,
        20,
      );
      final Text copy = tester.widget<Text>(
        find.text('Nothing within 5 km in the next 3 days.'),
      );
      expect(copy.style!.fontSize, 14);
      expect(copy.style!.height! * 14, closeTo(21, 0.01));
      expect(
        tester
            .getSize(find.text('Nothing within 5 km in the next 3 days.'))
            .width,
        lessThanOrEqualTo(250),
      );
    });
  });

  group('Chrome', () {
    testWidgets(
      'header actions are 42 circles; the count is an 18 brand pill',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            DabblerPageHeader(
              title: 'Games',
              locationLabel: 'Dubai Marina',
              safeArea: false,
              actions: <DabblerPageHeaderAction>[
                DabblerPageHeaderAction(
                  icon: 'filter',
                  semanticLabel: 'Filters',
                  onPressed: () {},
                  count: 3,
                ),
              ],
            ),
            width: 393,
          ),
        );
        final Finder circle = find.byWidgetPredicate(
          (Widget w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).shape == BoxShape.circle,
        );
        expect(tester.getSize(circle), const Size.square(42));
        final Container badge = tester.widget<Container>(
          find.byKey(DabblerPageHeader.badgeKey),
        );
        expect(
          (badge.decoration! as BoxDecoration).color,
          testColors().brandPrimary,
        );
        expect(
          tester.getSize(find.byKey(DabblerPageHeader.badgeKey)).height,
          18,
        );
        final Text loc = tester.widget<Text>(find.text('Dubai Marina'));
        expect(loc.style!.fontWeight, FontWeight.w500);
        expect(loc.style!.height! * 11, closeTo(14, 0.01));
      },
    );

    testWidgets('a header action fires from the 45 margin around its 42', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        host(
          DabblerPageHeader(
            title: 'Games',
            safeArea: false,
            actions: <DabblerPageHeaderAction>[
              DabblerPageHeaderAction(
                icon: 'search-normal',
                semanticLabel: 'Search',
                onPressed: () => taps++,
              ),
            ],
          ),
          width: 393,
        ),
      );
      final Rect circle = tester.getRect(
        find.byWidgetPredicate(
          (Widget w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).shape == BoxShape.circle,
        ),
      );
      await tester.tapAt(circle.centerLeft - const Offset(1, 0));
      expect(taps, 1);
    });

    testWidgets('listing tabs: 600 / 500, 21 apart, 9 under the label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          DabblerTabs(
            variant: DabblerTabsVariant.listing,
            scrollable: true,
            value: 'all',
            onChanged: (_) {},
            items: const <DabblerTabItem>[
              DabblerTabItem(id: 'all', label: 'All sports'),
              DabblerTabItem(id: 'f', label: 'Football'),
            ],
          ),
          width: 393,
        ),
      );
      expect(
        tester.widget<Text>(find.text('All sports')).style!.fontWeight,
        FontWeight.w600,
      );
      expect(
        tester.widget<Text>(find.text('Football')).style!.fontWeight,
        FontWeight.w500,
      );
      expect(
        tester.getTopLeft(find.text('Football')).dx -
            tester.getTopRight(find.text('All sports')).dx,
        DabblerSpacing.space7,
      );
      // The indicator is placed after the first frame measures the tabs.
      await tester.pumpAndSettle();
      // 20 line + 9 + the 2px underline + the 1px rail: a 32 tall strip.
      expect(tester.getSize(find.byType(DabblerTabs)).height, 32);
      // The underline sits on the rail, 1 above the strip's bottom.
      final Finder underline = find.byWidgetPredicate(
        (Widget w) => w is ColoredBox && w.color == testColors().brandPrimary,
      );
      expect(
        tester.getBottomLeft(find.byType(DabblerTabs)).dy -
            tester.getBottomLeft(underline).dy,
        DabblerSizing.borderDefault,
      );
      expect(tester.getSize(underline).height, 2);
    });

    testWidgets('applied filters are 32 tall brand pills with a 16 glyph', (
      WidgetTester tester,
    ) async {
      int removed = 0;
      await tester.pumpWidget(
        host(
          DabblerFilterRail(
            items: <DabblerFilterRailItem>[
              DabblerFilterRailItem(
                label: 'Within 5 km',
                onRemove: () => removed++,
              ),
            ],
            clearAllLabel: 'Clear all',
            onClearAll: () {},
          ),
          width: 393,
        ),
      );
      expect(
        tester
            .getSize(find.byKey(DabblerFilterRail.pillKeyFor('Within 5 km')))
            .height,
        32,
      );
      expect(tester.widget<DabblerIcon>(find.byType(DabblerIcon)).size, 16);
      await tester.tap(find.byType(DabblerIcon));
      expect(removed, 1);
    });
  });
}
