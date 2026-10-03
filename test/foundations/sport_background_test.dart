import 'package:dabbler_design_system/src/foundations/sport_background.dart';
import 'package:dabbler_design_system/src/foundations/sports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// AC2 — `main` is populated for the eleven sports the bundle ships;
/// `golf`/`table-tennis` main artwork and the entire `matchDay` variant return
/// null for an unpopulated sport/variant, and never throw.
///
/// Asserted against `components/foundations/sport-backgrounds.card.html`
/// (`MAIN_SRC` at :31-41, `MAIN_MISSING` at :45) and
/// `components/foundations/SportBackground.jsx`.
void main() {
  setUp(DabblerSportBackgroundRegistry.reset);
  tearDown(DabblerSportBackgroundRegistry.reset);

  /// MAIN_SRC, transcribed from the specimen card.
  const Map<String, String> sourceMainSrc = <String, String>{
    'football': 'assets/images/sports/football-main-background.png',
    'padel': 'assets/images/sports/padel-main-background.png',
    'tennis': 'assets/images/sports/tennis-main-background.png',
    'basketball': 'assets/images/sports/basketball-main-background.png',
    'volleyball': 'assets/images/sports/volleyball-main-background.png',
    'cricket': 'assets/images/sports/cricket-main-background.png',
    'running': 'assets/images/sports/running-main-background.png',
    'swimming': 'assets/images/sports/swimming-main-background.png',
    'cycling': 'assets/images/sports/cycling-main-background.png',
    'badminton': 'assets/images/sports/badminton-main-background.png',
    'gym': 'assets/images/sports/gym-main-background.png',
  };

  /// MAIN_MISSING, transcribed from the specimen card.
  const List<String> sourceMainMissing = <String>['golf', 'table-tennis'];

  /// KAN-411 item 7 — in DabblerSport, no artwork in the design project.
  const List<String> addedSports = <String>[
    'handball',
    'squash',
    'baseball',
    'rugby',
    'hockey',
  ];

  group('AC2 — main is populated for the eleven bundled sports', () {
    test('exactly eleven sports have main artwork', () {
      expect(sourceMainSrc, hasLength(11));
      expect(DabblerSportBackgroundRegistry.mainPopulated, hasLength(11));
    });

    test('each populated sport resolves to the canonical asset path', () {
      for (final MapEntry<String, String> entry in sourceMainSrc.entries) {
        final DabblerSport sport = DabblerSport.fromKey(entry.key)!;
        final DabblerSportArtwork? artwork =
            DabblerSportBackgroundRegistry.resolve(sport);
        expect(artwork, isNotNull, reason: entry.key);
        expect(artwork!.assetPath, entry.value, reason: entry.key);
        // This package ships no artwork — the consuming app owns the assets.
        expect(artwork.package, isNull, reason: entry.key);
      }
    });

    test('populated + unpopulated together account for every sport', () {
      expect(<DabblerSport>{
        ...DabblerSportBackgroundRegistry.mainPopulated,
        ...DabblerSportBackgroundRegistry.mainUnpopulated,
      }, kDabblerSports.toSet());
    });
  });

  group('AC2 — the null paths, asserted explicitly', () {
    test('golf and table-tennis main artwork is null', () {
      for (final String key in sourceMainMissing) {
        final DabblerSport sport = DabblerSport.fromKey(key)!;
        expect(
          DabblerSportBackgroundRegistry.resolve(sport),
          isNull,
          reason: key,
        );
      }
    });

    test('matchDay is null for every sport', () {
      for (final DabblerSport sport in kDabblerSports) {
        expect(
          DabblerSportBackgroundRegistry.resolve(
            sport,
            variant: DabblerSportBackgroundVariant.matchDay,
          ),
          isNull,
          reason: sport.key,
        );
      }
    });

    test('matchDay does not fall back to main, even where main exists', () {
      expect(
        DabblerSportBackgroundRegistry.resolve(DabblerSport.football),
        isNotNull,
      );
      expect(
        DabblerSportBackgroundRegistry.resolve(
          DabblerSport.football,
          variant: DabblerSportBackgroundVariant.matchDay,
        ),
        isNull,
      );
    });

    test('a miss never substitutes another sport', () {
      final Set<String> paths = <String>{
        for (final DabblerSport sport in kDabblerSports)
          if (DabblerSportBackgroundRegistry.resolve(sport) != null)
            DabblerSportBackgroundRegistry.resolve(sport)!.assetPath,
      };
      expect(paths, hasLength(11));
    });

    test('nothing throws, for any sport at any variant', () {
      for (final DabblerSport sport in kDabblerSports) {
        for (final DabblerSportBackgroundVariant variant
            in DabblerSportBackgroundVariant.values) {
          expect(
            () =>
                DabblerSportBackgroundRegistry.resolve(sport, variant: variant),
            returnsNormally,
            reason: '${sport.key}:${variant.key}',
          );
        }
      }
    });

    test('an unknown sport key warns once and returns null, as live does', () {
      // Live `SportBackground.jsx` `warnMissing(sport, variant)` fires for an
      // unregistered sport string too, then renders null.
      final List<String> messages = <String>[];
      DabblerSportBackgroundRegistry.warn = messages.add;
      expect(DabblerSportBackgroundRegistry.resolveKey('quidditch'), isNull);
      expect(DabblerSportBackgroundRegistry.resolveKey('quidditch'), isNull);
      expect(messages, hasLength(1));
      expect(messages.single, contains('quidditch'));
    });

    test('an unknown sport key returns null rather than throwing', () {
      expect(DabblerSportBackgroundRegistry.resolveKey('quidditch'), isNull);
      expect(
        () => DabblerSportBackgroundRegistry.resolveKey(''),
        returnsNormally,
      );
    });

    test('a miss warns once per sport/variant pair', () {
      final List<String> messages = <String>[];
      DabblerSportBackgroundRegistry.warn = messages.add;
      DabblerSportBackgroundRegistry.resolve(DabblerSport.golf);
      DabblerSportBackgroundRegistry.resolve(DabblerSport.golf);
      expect(messages, hasLength(1));
      expect(messages.single, contains('golf'));
      expect(messages.single, contains('main'));
    });
  });

  group('registration merges without restructuring', () {
    const DabblerSportArtwork matchDayArt = DabblerSportArtwork.asset(
      'assets/images/sports/golf-matchday.png',
    );

    test('Batch 2 can add matchDay without disturbing main', () {
      DabblerSportBackgroundRegistry.registerSportBackgrounds(
        <DabblerSport, Map<DabblerSportBackgroundVariant, DabblerSportArtwork>>{
          DabblerSport.football:
              <DabblerSportBackgroundVariant, DabblerSportArtwork>{
                DabblerSportBackgroundVariant.matchDay: matchDayArt,
              },
        },
      );
      expect(
        DabblerSportBackgroundRegistry.resolve(
          DabblerSport.football,
        )!.assetPath,
        sourceMainSrc['football'],
      );
      expect(
        DabblerSportBackgroundRegistry.resolve(
          DabblerSport.football,
          variant: DabblerSportBackgroundVariant.matchDay,
        ),
        matchDayArt,
      );
    });

    test('an app can supply the two missing main assets', () {
      DabblerSportBackgroundRegistry.registerSportBackgrounds(
        <DabblerSport, Map<DabblerSportBackgroundVariant, DabblerSportArtwork>>{
          DabblerSport.golf:
              <DabblerSportBackgroundVariant, DabblerSportArtwork>{
                DabblerSportBackgroundVariant.main: matchDayArt,
              },
        },
      );
      expect(
        DabblerSportBackgroundRegistry.resolve(DabblerSport.golf),
        matchDayArt,
      );
    });

    test('a null set is a no-op', () {
      DabblerSportBackgroundRegistry.registerSportBackgrounds(null);
      expect(DabblerSportBackgroundRegistry.resolve(DabblerSport.golf), isNull);
      expect(
        DabblerSportBackgroundRegistry.resolve(DabblerSport.football),
        isNotNull,
      );
    });
  });

  group('KAN-411 item 7 — path for the new sports and the existing names', () {
    test('the five added sports resolve to null (no design artwork)', () {
      for (final String key in addedSports) {
        final DabblerSport sport = DabblerSport.fromKey(key)!;
        expect(
          DabblerSportBackgroundRegistry.resolve(sport),
          isNull,
          reason: key,
        );
        expect(DabblerSportBackgroundRegistry.mainUnpopulated, contains(sport));
      }
      expect(
        DabblerSportBackgroundRegistry.addedWithoutArtwork,
        addedSports.map((String k) => DabblerSport.fromKey(k)),
      );
    });

    test(
      'conventionalMainArtwork follows the convention for all 18 sports',
      () {
        for (final DabblerSport sport in kDabblerSports) {
          expect(
            DabblerSportBackgroundRegistry.conventionalMainArtwork(
              sport,
            ).assetPath,
            'assets/images/sports/${sport.key}-main-background.png',
            reason: sport.key,
          );
        }
        // …and it agrees with every pre-registered default.
        for (final MapEntry<DabblerSport, DabblerSportArtwork> e
            in DabblerSportBackgroundRegistry.defaultMainArtwork.entries) {
          expect(
            DabblerSportBackgroundRegistry.conventionalMainArtwork(e.key),
            e.value,
          );
        }
        expect(
          DabblerSportBackgroundRegistry.conventionalMainArtwork(
            DabblerSport.rugby,
            package: 'p',
          ).package,
          'p',
        );
      },
    );

    test(
      'registerConventionalMainArtwork defaults to the five added sports',
      () {
        DabblerSportBackgroundRegistry.registerConventionalMainArtwork();
        for (final String key in addedSports) {
          expect(
            DabblerSportBackgroundRegistry.resolve(
              DabblerSport.fromKey(key)!,
            )!.assetPath,
            'assets/images/sports/$key-main-background.png',
            reason: key,
          );
        }
        // Existing behaviour untouched: golf is still null, football unchanged.
        expect(
          DabblerSportBackgroundRegistry.resolve(DabblerSport.golf),
          isNull,
        );
        expect(
          DabblerSportBackgroundRegistry.resolve(
            DabblerSport.football,
          )!.assetPath,
          sourceMainSrc['football'],
        );
      },
    );

    test('registerConventionalMainArtwork accepts an explicit set', () {
      DabblerSportBackgroundRegistry.registerConventionalMainArtwork(
        <DabblerSport>[DabblerSport.golf],
      );
      expect(
        DabblerSportBackgroundRegistry.resolve(DabblerSport.golf),
        isNotNull,
      );
      expect(
        DabblerSportBackgroundRegistry.resolve(DabblerSport.rugby),
        isNull,
      );
    });

    testWidgets('a registered-but-missing asset degrades: no throw into the '
        'tree, host fallback paint still visible', (WidgetTester tester) async {
      DabblerSportBackgroundRegistry.registerConventionalMainArtwork();
      const Key paint = Key('fallback-paint');
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            width: 200,
            height: 300,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ColoredBox(key: paint, color: Color(0xFF123456)),
                DabblerSportBackground(DabblerSport.rugby),
              ],
            ),
          ),
        ),
      );
      // The asset is not bundled: the load failure is reported, not thrown
      // into the widget tree, and the fallback paint beneath stays on screen.
      expect(
        tester.takeException().toString(),
        contains('Unable to load asset'),
      );
      expect(find.byKey(paint), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('an unregistered new sport renders nothing and the fallback '
        'paint remains', (WidgetTester tester) async {
      const Key paint = Key('fallback-paint');
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: <Widget>[
              SizedBox(key: paint, width: 10, height: 10),
              DabblerSportBackground(DabblerSport.handball),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(Image), findsNothing);
      expect(find.byKey(paint), findsOneWidget);
      expect(DabblerSportBackground.maybe(DabblerSport.squash), isNull);
    });
  });

  group('DabblerSportBackground widget', () {
    Widget host(Widget child) => MaterialApp(
      home: Scaffold(body: SizedBox(width: 300, height: 500, child: child)),
    );

    testWidgets('renders nothing for an unpopulated sport, without throwing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerSportBackground(DabblerSport.golf)),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders nothing for matchDay on every sport', (
      WidgetTester tester,
    ) async {
      for (final DabblerSport sport in kDabblerSports) {
        await tester.pumpWidget(
          host(
            DabblerSportBackground(
              sport,
              variant: DabblerSportBackgroundVariant.matchDay,
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: sport.key);
        expect(find.byType(Image), findsNothing, reason: sport.key);
      }
    });

    testWidgets('builds an Image for a populated sport with cover fit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerSportBackground(DabblerSport.football)),
      );
      final Image image = tester.widget(find.byType(Image));
      // The asset itself is NOT in this package — see DabblerSportArtwork on
      // why no binaries are bundled and pubspec.yaml is not touched. The
      // resulting "unable to load asset" is therefore the expected outcome in
      // this package's own test bundle, and is consumed rather than hidden.
      // What is under test is the reference the widget builds, not the bytes.
      final Object? assetLoadFailure = tester.takeException();
      expect(assetLoadFailure.toString(), contains('Unable to load asset'));
      expect(image.fit, BoxFit.cover);
      expect(image.alignment, Alignment.center);
      expect((image.image as AssetImage).assetName, sourceMainSrc['football']);
    });

    testWidgets('maybe() returns null exactly where resolve() does', (
      WidgetTester tester,
    ) async {
      expect(DabblerSportBackground.maybe(DabblerSport.golf), isNull);
      expect(
        DabblerSportBackground.maybe(
          DabblerSport.football,
          variant: DabblerSportBackgroundVariant.matchDay,
        ),
        isNull,
      );
      expect(DabblerSportBackground.maybe(DabblerSport.football), isNotNull);
    });
  });
}
