import 'package:dabbler_design_system/src/cards/card.dart';
import 'package:dabbler_design_system/src/cards/card_event_large.dart';
import 'package:dabbler_design_system/src/cards/card_event_medium.dart';
import 'package:dabbler_design_system/src/cards/card_event_small.dart';
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/foundations/sport_background.dart';
import 'package:dabbler_design_system/src/foundations/sport_icon.dart';
import 'package:dabbler_design_system/src/foundations/sports.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/interaction/press_scale.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// KAN-252 — DS-801, the CardEvent family.
///
/// The assertions are written against the ticket's acceptance criteria and
/// against the values the design bundle *does* specify, never against this
/// package's own implementation. Where the bundle specifies nothing — the
/// exported `CardEventLarge/Medium/Small` nodes are mis-labelled settings rows,
/// which `card_event_large.dart`'s class doc records in full — the test asserts
/// the derivation instead: that Medium and Small take Large's rule rather than
/// restating it, which is AC2.

/// The resolved tokens the cards are checked against.
DabblerColors _colors({
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

/// The minimum a card needs: a [ThemeData] carrying [DabblerColors], and a
/// direction.
Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 400,
}) {
  return MaterialApp(
    theme: ThemeData(
      extensions: <ThemeExtension<dynamic>>[_colors()],
    ),
    home: Directionality(
      textDirection: direction,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}

/// A title long enough that no size can fit it — used for every truncation
/// assertion, so the cap is measured rather than assumed.
const String _longTitle =
    'Sunday five-a-side at Al Barsha Pond Park with the Thursday regulars and '
    'anyone else who turns up before the floodlights go off at half past ten';

/// An Arabic title of comparable length, for the RTL half of the truncation
/// assertions.
const String _longTitleAr =
    'مباراة كرة قدم خماسية يوم الأحد في حديقة بحيرة البرشاء مع اللاعبين '
    'المعتادين وأي شخص آخر يحضر قبل انطفاء الأضواء الكاشفة في العاشرة والنصف';

/// The script a direction implies, for the leading a measured line should have.
DabblerTypeScript _scriptOf(TextDirection direction) =>
    direction == TextDirection.rtl
        ? DabblerTypeScript.arabic
        : DabblerTypeScript.latin;

/// A live [BuildContext] under the host theme, for calling the family's
/// statics directly.
///
/// The image-treatment assertions inspect the widget
/// [DabblerCardEventLarge.mediaContent] *returns* rather than pumping it.
/// Mounting real sport artwork would try to load an `AssetImage` that this
/// package deliberately does not bundle (see `DabblerSportArtwork`'s doc: the
/// registry stores typed references the consuming app resolves), and the
/// resulting asset failure would be noise, not a finding. Inspecting the
/// returned tree tests the resolution order exactly, with nothing to load.
Future<BuildContext> _context(WidgetTester tester) async {
  late BuildContext captured;
  await tester.pumpWidget(_host(Builder(builder: (BuildContext context) {
    captured = context;
    return const SizedBox.shrink();
  })));
  return captured;
}

/// The imagery layer of what [DabblerCardEventLarge.mediaContent] returned.
Widget _artworkLayer(Widget media) => (media as Stack).children.first;

/// A thumbnail of [side], found by its own box rather than by a [ClipRRect]
/// that the card's chrome also uses.
Finder _thumb(double side) => find.byWidgetPredicate(
      (Widget w) => w is SizedBox && w.width == side && w.height == side,
    );

/// The paragraph the title is painted into.
RenderParagraph _titleParagraph(WidgetTester tester, String title) =>
    tester.renderObject<RenderParagraph>(find.text(title));

void main() {
  setUp(DabblerSportBackgroundRegistry.reset);
  tearDown(DabblerSportBackgroundRegistry.reset);

  group('AC1 — Large establishes the pattern: it composes Card and adds no chrome', () {
    testWidgets('draws on the standard shell, which is what the source paints',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerCardEventLarge(title: 'Five-a-side'),
      ));

      final DabblerCard card = tester.widget<DabblerCard>(
        find.byType(DabblerCard),
      );
      // `backgroundColor: var(--neutral-200)`, no border — every exported
      // CardEvent node paints exactly this, and it is Card's `standard`.
      expect(card.variant, DabblerCardVariant.standard);
      // No chrome restated locally: radius and padding are left to Card.
      expect(card.radius, isNull);
      expect(card.padding, isNull);
    });

    testWidgets('is inert without onTap and gains the system affordances with it',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerCardEventLarge(title: 'Five-a-side'),
      ));
      expect(find.byType(DabblerFocusRing), findsNothing);
      expect(find.byType(DabblerPressScale), findsNothing);

      int taps = 0;
      await tester.pumpWidget(_host(
        DabblerCardEventLarge(title: 'Five-a-side', onTap: () => taps++),
      ));
      expect(find.byType(DabblerFocusRing), findsOneWidget);
      expect(find.byType(DabblerPressScale), findsOneWidget);

      await tester.tap(find.byType(DabblerCardEventLarge));
      expect(taps, 1);
    });
  });

  group('AC1 — image treatment', () {
    testWidgets('the cover goes in Card.media at 16:9, full-bleed',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerCardEventLarge(
          title: 'Five-a-side',
          cover: Container(key: const Key('cover')),
        ),
      ));

      final DabblerCard card =
          tester.widget<DabblerCard>(find.byType(DabblerCard));
      expect(card.media, isNotNull);

      final AspectRatio ratio = tester.widget<AspectRatio>(
        find.descendant(
          of: find.byType(DabblerCardEventLarge),
          matching: find.byType(AspectRatio),
        ),
      );
      expect(ratio.aspectRatio, DabblerCardEventLarge.coverAspectRatio);
      expect(find.byKey(const Key('cover')), findsOneWidget);
    });

    testWidgets('an explicit cover wins over the sport artwork',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerCardEventLarge(
          title: 'Five-a-side',
          sport: DabblerSport.football,
          cover: Container(key: const Key('cover')),
        ),
      ));

      expect(find.byKey(const Key('cover')), findsOneWidget);
      expect(find.byType(DabblerSportBackground), findsNothing);
    });

    testWidgets('with no cover it falls back to the sport artwork',
        (WidgetTester tester) async {
      // football is one of the eleven DS-400 pre-registers `main` artwork for.
      expect(
        DabblerSportBackgroundRegistry.resolve(DabblerSport.football),
        isNotNull,
      );

      final BuildContext context = await _context(tester);
      expect(
        _artworkLayer(DabblerCardEventLarge.mediaContent(
          context,
          sport: DabblerSport.football,
        )),
        isA<DabblerSportBackground>(),
      );
    });

    testWidgets('the resolution order is cover, then artwork, then a flat well',
        (WidgetTester tester) async {
      final BuildContext context = await _context(tester);
      final Widget cover = Container(key: const Key('cover'));

      // 1. an explicit cover wins outright.
      expect(
        _artworkLayer(DabblerCardEventLarge.mediaContent(
          context,
          cover: cover,
          sport: DabblerSport.football,
        )),
        same(cover),
      );
      // 2. the sport's artwork, where there is any.
      expect(
        _artworkLayer(DabblerCardEventLarge.mediaContent(
          context,
          sport: DabblerSport.football,
        )),
        isA<DabblerSportBackground>(),
      );
      // 3. the flat well — for an unpopulated sport, and for no sport at all.
      for (final DabblerSport? sport in <DabblerSport?>[
        DabblerSport.golf,
        null,
      ]) {
        expect(
          _artworkLayer(
              DabblerCardEventLarge.mediaContent(context, sport: sport)),
          isA<ColoredBox>().having(
              (ColoredBox b) => b.color, 'color', _colors().surfaceGrey),
        );
      }
    });

    testWidgets(
        'a sport with no registered artwork is a normal case, not an error',
        (WidgetTester tester) async {
      // DS-400 ships no `main` artwork for golf or table-tennis, by design,
      // and `resolve` returns null without throwing.
      for (final DabblerSport sport in <DabblerSport>[
        DabblerSport.golf,
        DabblerSport.tableTennis,
      ]) {
        expect(DabblerSportBackgroundRegistry.resolve(sport), isNull,
            reason: '${sport.key} is expected to be unpopulated');

        await tester.pumpWidget(_host(
          DabblerCardEventLarge(title: 'Match', sport: sport),
        ));

        expect(tester.takeException(), isNull);
        expect(find.byType(DabblerSportBackground), findsNothing);
        // The flat well is what a miss resolves to.
        expect(
          find.descendant(
            of: find.byType(DabblerCardEventLarge),
            matching: find.byWidgetPredicate((Widget w) =>
                w is ColoredBox && w.color == _colors().surfaceGrey),
          ),
          findsOneWidget,
        );
        // The overlay still draws: the mark is registered even when the
        // artwork is not.
        expect(find.byType(DabblerSportIcon), findsOneWidget);
      }
    });

    testWidgets('the whole matchDay variant being unpopulated does not throw',
        (WidgetTester tester) async {
      for (final DabblerSport sport in <DabblerSport>[
        DabblerSport.football,
        DabblerSport.golf,
      ]) {
        expect(
          DabblerSportBackgroundRegistry.resolve(
            sport,
            variant: DabblerSportBackgroundVariant.matchDay,
          ),
          isNull,
        );
      }

      await tester.pumpWidget(_host(
        const DabblerCardEventSmall(
          title: 'Match',
          sport: DabblerSport.tableTennis,
        ),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('no sport and no cover is still a card, not a hole',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerCardEventLarge(title: 'Five-a-side'),
      ));

      expect(tester.takeException(), isNull);
      expect(find.byType(DabblerSportIcon), findsNothing);
      expect(find.text('Five-a-side'), findsOneWidget);
    });
  });

  group('AC1 — the sport-icon overlay', () {
    testWidgets('D-022: Large draws it and neither row size does',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerCardEventLarge(
          title: 'Match',
          sport: DabblerSport.golf,
        ),
      ));
      expect(find.byType(DabblerSportIcon), findsOneWidget);

      // D-006 ruled one overlay geometry and did not carve out the row sizes;
      // D-022 closed that as D-006's omission and exempted BOTH of them. The
      // rule is not a size ladder — the overlay exists where the cover is
      // large enough to still read as a cover underneath it — so there is no
      // smaller well to assert, only its absence.
      for (final Widget row in <Widget>[
        const DabblerCardEventMedium(title: 'Match', sport: DabblerSport.golf),
        const DabblerCardEventSmall(title: 'Match', sport: DabblerSport.golf),
      ]) {
        await tester.pumpWidget(_host(row));
        expect(find.byType(DabblerSportIcon), findsNothing);
      }
    });

    testWidgets('it is a flat circular well on the token surface',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerCardEventLarge(
          title: 'Match',
          sport: DabblerSport.golf,
        ),
      ));

      final Container well = tester.widget<Container>(
        find.ancestor(
          of: find.byType(DabblerSportIcon),
          matching: find.byType(Container),
        ).first,
      );
      final BoxDecoration decoration = well.decoration! as BoxDecoration;

      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, _colors().surfaceCard);
      // The system is flat: no shadow, no gradient, no border.
      expect(decoration.boxShadow, isNull);
      expect(decoration.gradient, isNull);
      expect(decoration.border, isNull);

      expect(
        tester.getSize(find.byType(DabblerSportIcon).first).width,
        DabblerCardEventGeometry.overlayIconSize,
      );
      expect(
        tester.getSize(find.byWidget(well)),
        const Size(DabblerCardEventGeometry.overlayWellSide,
            DabblerCardEventGeometry.overlayWellSide),
      );
    });

    testWidgets('it follows the reading order, not a fixed edge',
        (WidgetTester tester) async {
      const Widget card = DabblerCardEventLarge(
        title: 'Match',
        sport: DabblerSport.golf,
      );

      await tester.pumpWidget(_host(card));
      final Rect ltr = tester.getRect(find.byType(DabblerSportIcon));
      final Rect ltrCard = tester.getRect(find.byType(DabblerCardEventLarge));

      await tester.pumpWidget(_host(card, direction: TextDirection.rtl));
      final Rect rtl = tester.getRect(find.byType(DabblerSportIcon));
      final Rect rtlCard = tester.getRect(find.byType(DabblerCardEventLarge));

      // Start edge in LTR is the left; in RTL it is the right.
      expect(ltr.left - ltrCard.left,
          closeTo(rtlCard.right - rtl.right, 0.01));
      expect(ltr.left, lessThan(rtl.left));
      // Bottom-anchored in both.
      expect(ltr.top, closeTo(rtl.top, 0.01));
    });
  });

  group('AC1 — title truncation', () {
    for (final TextDirection direction in TextDirection.values) {
      final String title =
          direction == TextDirection.rtl ? _longTitleAr : _longTitle;

      testWidgets('Large caps at two lines and ellipses (${direction.name})',
          (WidgetTester tester) async {
        await tester.pumpWidget(_host(
          DabblerCardEventLarge(title: title),
          direction: direction,
        ));

        final RenderParagraph paragraph = _titleParagraph(tester, title);
        expect(paragraph.maxLines, DabblerCardEventLarge.titleMaxLines);
        expect(paragraph.maxLines, 2);
        expect(paragraph.overflow, TextOverflow.ellipsis);
        // Measured, not assumed: the title genuinely overflows and genuinely
        // paints exactly two lines.
        expect(paragraph.didExceedMaxLines, isTrue);
        expect(
          paragraph.size.height,
          closeTo(2 * DabblerType.headline.leadingFor(_scriptOf(direction)), 1),
        );
        expect(paragraph.textDirection, direction);
      });

      testWidgets('Medium caps at one line and ellipses (${direction.name})',
          (WidgetTester tester) async {
        await tester.pumpWidget(_host(
          DabblerCardEventMedium(title: title),
          direction: direction,
        ));

        final RenderParagraph paragraph = _titleParagraph(tester, title);
        expect(paragraph.maxLines, DabblerCardEventMedium.titleMaxLines);
        expect(paragraph.maxLines, 1);
        expect(paragraph.overflow, TextOverflow.ellipsis);
        expect(paragraph.didExceedMaxLines, isTrue);
        expect(
          paragraph.size.height,
          closeTo(
              DabblerType.subheadline.leadingFor(_scriptOf(direction)), 1),
        );
      });

      testWidgets('Small caps at one line and ellipses (${direction.name})',
          (WidgetTester tester) async {
        await tester.pumpWidget(_host(
          DabblerCardEventSmall(title: title),
          direction: direction,
        ));

        final RenderParagraph paragraph = _titleParagraph(tester, title);
        expect(paragraph.maxLines, DabblerCardEventSmall.titleMaxLines);
        expect(paragraph.maxLines, 1);
        expect(paragraph.overflow, TextOverflow.ellipsis);
        expect(paragraph.didExceedMaxLines, isTrue);
        expect(
          paragraph.size.height,
          closeTo(
              DabblerType.subheadline.leadingFor(_scriptOf(direction)), 1),
        );
      });
    }

    testWidgets('a short title is not truncated at any size',
        (WidgetTester tester) async {
      for (final Widget card in <Widget>[
        const DabblerCardEventLarge(title: 'Padel'),
        const DabblerCardEventMedium(title: 'Padel'),
        const DabblerCardEventSmall(title: 'Padel'),
      ]) {
        await tester.pumpWidget(_host(card));
        expect(_titleParagraph(tester, 'Padel').didExceedMaxLines, isFalse);
      }
    });

    testWidgets('a long title does not overflow the card at any size',
        (WidgetTester tester) async {
      for (final Widget card in <Widget>[
        const DabblerCardEventLarge(title: _longTitle, dateTime: 'Sun · 18:00'),
        const DabblerCardEventMedium(title: _longTitle, dateTime: 'Sun · 18:00'),
        const DabblerCardEventSmall(title: _longTitle, dateTime: 'Sun · 18:00'),
      ]) {
        await tester.pumpWidget(_host(card));
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('AC1 — date/time and place (the DS-602 seam)', () {
    testWidgets('both entries draw, each with its own mark',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerCardEventLarge(
          title: 'Five-a-side',
          dateTime: 'Sun 21 Sep · 18:00',
          location: 'Al Barsha Pond Park',
        ),
      ));

      expect(find.text('Sun 21 Sep · 18:00'), findsOneWidget);
      expect(find.text('Al Barsha Pond Park'), findsOneWidget);

      final Iterable<DabblerIcon> icons =
          tester.widgetList<DabblerIcon>(find.byType(DabblerIcon));
      expect(icons.map((DabblerIcon i) => i.name), containsAll(
        <String>['calendar', 'location'],
      ));
    });

    testWidgets('either entry alone is a valid line',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerCardEventLarge(
          title: 'Five-a-side',
          dateTime: 'Sun 21 Sep · 18:00',
        ),
      ));
      expect(find.text('Sun 21 Sep · 18:00'), findsOneWidget);
      expect(
        tester
            .widgetList<DabblerIcon>(find.byType(DabblerIcon))
            .map((DabblerIcon i) => i.name),
        isNot(contains('location')),
      );
    });

    testWidgets('neither drops the line entirely', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerCardEventLarge(title: 'Five-a-side'),
      ));
      expect(find.byType(DabblerIcon), findsNothing);
    });

    test('the seam is one function wide', () {
      // The cards never format a date. metaRow is the single place all three
      // sizes render the already-formatted strings, so wiring DS-602 in
      // touches exactly this function and the three String parameters.
      expect(
        DabblerCardEventLarge.metaRow(
          TextDirection.ltr,
          _colors(),
        ),
        isNull,
        reason: 'no entries means no line, rather than empty reserved height',
      );
    });
  });

  group('AC2 — Medium and Small derive from Large', () {
    testWidgets('both compose Card on the same shell, adding no chrome',
        (WidgetTester tester) async {
      for (final Widget card in <Widget>[
        const DabblerCardEventMedium(title: 'Padel'),
        const DabblerCardEventSmall(title: 'Padel'),
      ]) {
        await tester.pumpWidget(_host(card));
        final DabblerCard shell =
            tester.widget<DabblerCard>(find.byType(DabblerCard));
        expect(shell.variant, DabblerCardVariant.standard);
        expect(shell.radius, isNull);
        expect(shell.padding, isNull);
        // The row sizes put their image in the row, not in the media slot.
        expect(shell.media, isNull);
      }
    });

    testWidgets('both take Large\'s metadata row verbatim',
        (WidgetTester tester) async {
      for (final Widget card in <Widget>[
        const DabblerCardEventMedium(
          title: 'Padel',
          dateTime: 'Sun · 18:00',
          location: 'Al Quoz',
        ),
        const DabblerCardEventSmall(
          title: 'Padel',
          dateTime: 'Sun · 18:00',
          location: 'Al Quoz',
        ),
      ]) {
        await tester.pumpWidget(_host(card));
        expect(find.text('Sun · 18:00'), findsOneWidget);
        expect(find.text('Al Quoz'), findsOneWidget);
        expect(
          tester
              .widgetList<DabblerIcon>(find.byType(DabblerIcon))
              .map((DabblerIcon i) => i.name),
          containsAll(<String>['calendar', 'location']),
        );
      }
    });

    testWidgets('both take Large\'s image resolution order',
        (WidgetTester tester) async {
      // An explicit cover wins at both row sizes...
      for (final Widget card in <Widget>[
        DabblerCardEventMedium(
          title: 'Padel',
          sport: DabblerSport.golf,
          cover: Container(key: const Key('cover')),
        ),
        DabblerCardEventSmall(
          title: 'Padel',
          sport: DabblerSport.golf,
          cover: Container(key: const Key('cover')),
        ),
      ]) {
        await tester.pumpWidget(_host(card));
        expect(find.byKey(const Key('cover')), findsOneWidget);
        expect(find.byType(DabblerSportBackground), findsNothing);
      }

      // ...and an unpopulated sport resolves to the same flat well Large uses,
      // rather than to an error or to another sport's art.
      for (final Widget card in <Widget>[
        const DabblerCardEventMedium(title: 'Padel', sport: DabblerSport.golf),
        const DabblerCardEventSmall(title: 'Padel', sport: DabblerSport.golf),
      ]) {
        await tester.pumpWidget(_host(card));
        expect(tester.takeException(), isNull);
        expect(
          find.byWidgetPredicate((Widget w) =>
              w is ColoredBox && w.color == _colors().surfaceGrey),
          findsOneWidget,
        );
      }
    });

    test('the two row sizes share one title style, and it is a ramp step', () {
      final TextStyle medium =
          DabblerCardEventLarge.compactTitleStyleFor(TextDirection.ltr);
      expect(medium.fontSize, DabblerType.subheadline.fontSize);
      expect(medium.fontWeight, DabblerType.bold);

      // Large's own title is the headline step, carrying its own weight.
      final TextStyle large =
          DabblerCardEventLarge.titleStyleFor(TextDirection.ltr);
      expect(large.fontSize, DabblerType.headline.fontSize);
      expect(large.fontWeight, DabblerType.headline.fontWeight);
    });

    test('the metadata style is the footnote step, unmodified', () {
      final TextStyle meta =
          DabblerCardEventLarge.metaStyleFor(TextDirection.ltr);
      expect(meta.fontSize, DabblerType.footnote.fontSize);
      expect(meta.fontWeight, DabblerType.footnote.fontWeight);
    });

    test('the ruled geometry is D-006, and the widgets re-export it', () {
      // The ruling itself. These literals are the one place in the family
      // where a geometry number is written down, and they are D-006's.
      expect(DabblerCardEventGeometry.coverAspectRatio, 16 / 9);
      expect(DabblerCardEventGeometry.mediumThumbSide, 64);
      expect(DabblerCardEventGeometry.mediumThumbRadius, 12);
      expect(DabblerCardEventGeometry.smallThumbSide, 48);
      expect(DabblerCardEventGeometry.overlayWellSide, 32);
      expect(DabblerCardEventGeometry.overlayIconSize, 24);
      expect(DabblerCardEventGeometry.overlayInset, 8);
      expect(DabblerCardEventGeometry.rowGap, 12);

      // 45 is gone: cxo rejected it as a hit-target floor rather than a
      // thumbnail scale, and 48 is on the 4dp grid where 45 is not.
      expect(DabblerCardEventGeometry.smallThumbSide,
          isNot(DabblerSizing.touchTargetMin));
      expect(DabblerCardEventGeometry.smallThumbSide % 4, 0);

      // Where a ruled number coincides with a system token, it is taken as
      // the token rather than re-typed.
      expect(DabblerCardEventGeometry.mediumThumbRadius, DabblerRadius.lg);
      expect(DabblerCardEventGeometry.overlayIconSize, DabblerSizing.iconMd);
      expect(DabblerCardEventGeometry.rowGap, DabblerSpacing.stackDefault);

      // The widgets re-export the block; none of them declares its own.
      expect(DabblerCardEventLarge.coverAspectRatio,
          DabblerCardEventGeometry.coverAspectRatio);
      expect(DabblerCardEventMedium.thumbSide,
          DabblerCardEventGeometry.mediumThumbSide);
      expect(DabblerCardEventMedium.thumbRadius,
          DabblerCardEventGeometry.mediumThumbRadius);
      expect(DabblerCardEventSmall.thumbSide,
          DabblerCardEventGeometry.smallThumbSide);
      expect(DabblerCardEventSmall.thumbRadius,
          DabblerCardEventGeometry.rowThumbRadius);
      // D-018 confirms 12 as the corner of a tile inside a card, which is what
      // both row thumbnails are — so the two row sizes share one ruled step.
      expect(DabblerCardEventGeometry.rowThumbRadius,
          DabblerCardEventGeometry.mediumThumbRadius);

      // The cover inherits the card's corner rather than carrying a literal.
      // D-018 resolves D-006's 16 by changing the card's corner, so this
      // constant follows it with no edit — which is the property to pin.
      expect(DabblerCardEventGeometry.coverCornerRadius,
          DabblerCard.defaultRadius);

      // The token-only values, which needed no ruling.
      expect(DabblerCardEventLarge.metaIconSize, DabblerSizing.iconSm);
      expect(DabblerCardEventLarge.metaIconGap, DabblerSpacing.iconGap);
      expect(DabblerCardEventLarge.metaEntryGap, DabblerSpacing.stackDefault);
    });

    testWidgets('the thumbnails are the sides they declare',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerCardEventMedium(title: 'Padel'),
      ));
      expect(_thumb(DabblerCardEventMedium.thumbSide), findsOneWidget);
      expect(
        tester.getSize(_thumb(DabblerCardEventMedium.thumbSide)),
        const Size(DabblerCardEventMedium.thumbSide,
            DabblerCardEventMedium.thumbSide),
      );

      await tester.pumpWidget(_host(
        const DabblerCardEventSmall(title: 'Padel'),
      ));
      expect(_thumb(DabblerCardEventSmall.thumbSide), findsOneWidget);
      expect(
        tester.getSize(_thumb(DabblerCardEventSmall.thumbSide)),
        const Size(
            DabblerCardEventSmall.thumbSide, DabblerCardEventSmall.thumbSide),
      );
    });
  });

  group('RTL', () {
    testWidgets('the row sizes mirror, so the thumbnail leads in both',
        (WidgetTester tester) async {
      const Widget card = DabblerCardEventMedium(title: 'Padel');

      await tester.pumpWidget(_host(card));
      final Rect ltrThumb = tester.getRect(_thumb(DabblerCardEventMedium.thumbSide));
      final Rect ltrTitle = tester.getRect(find.text('Padel'));
      expect(ltrThumb.left, lessThan(ltrTitle.left));

      await tester.pumpWidget(_host(card, direction: TextDirection.rtl));
      final Rect rtlThumb = tester.getRect(_thumb(DabblerCardEventMedium.thumbSide));
      final Rect rtlTitle = tester.getRect(find.text('Padel'));
      expect(rtlThumb.right, greaterThan(rtlTitle.right));
    });
  });
}
