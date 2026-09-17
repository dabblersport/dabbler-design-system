import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/foundations/sport_icon.dart';
import 'package:dabbler_design_system/src/foundations/sports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// AC1 — SportIcon falls back to `game`/`activity`/`ticket-2` per DS-300's
/// fallback contract when no sport-specific Iconsax glyph exists.
///
/// Asserted against the design source's own `FALLBACKS` table
/// (`components/foundations/SportIcon.jsx`) and the fallback table in
/// `components/foundations/icons-system.card.html:151-153`, not against the
/// implementation.
void main() {
  setUp(() {
    DabblerSportIconRegistry.reset();
    DabblerIconRegistry.reset();
  });

  tearDown(() {
    DabblerSportIconRegistry.reset();
    DabblerIconRegistry.reset();
  });

  /// The source's FALLBACKS map, transcribed by hand.
  const Map<String, String> sourceFallbacks = <String, String>{
    'football': 'game',
    'basketball': 'game',
    'volleyball': 'game',
    'cricket': 'game',
    'running': 'activity',
    'swimming': 'activity',
    'cycling': 'activity',
    'golf': 'activity',
    'gym': 'activity',
    'padel': 'ticket-2',
    'tennis': 'ticket-2',
    'badminton': 'ticket-2',
    'table-tennis': 'ticket-2',
  };

  group('the ticket premise, re-derived from iconsax_flutter', () {
    test('no sport-specific glyph exists in either weight', () {
      const List<String> sportish = <String>[
        'football', 'foot_ball', 'soccer', 'padel', 'tennis', 'basketball',
        'basket_ball', 'volleyball', 'volley_ball', 'cricket', 'running',
        'swimming', 'cycling', 'bicycle', 'badminton', 'golf', 'table_tennis',
        'gym', 'dumbbell', 'ball', 'sport',
      ];
      for (final String name in sportish) {
        expect(Iconsax.items[name], isNull, reason: '"$name" should not exist');
        expect(Iconsax.items['${name}_copy'], isNull,
            reason: '"${name}_copy" should not exist');
      }
    });

    test('all three documented fallbacks resolve in both weights', () {
      for (final String name in <String>{...sourceFallbacks.values}) {
        for (final DabblerIconWeight weight in DabblerIconWeight.values) {
          expect(
            DabblerIconRegistry.resolve(name, weight: weight).outcome,
            DabblerIconOutcome.resolved,
            reason: '$name at ${weight.name} must not hit the placeholder',
          );
        }
      }
    });
  });

  group('AC1 — the fallback table', () {
    test('every sport maps to the fallback the design source states', () {
      for (final DabblerSport sport in kDabblerSports) {
        expect(
          DabblerSportIconRegistry.fallbacks[sport],
          sourceFallbacks[sport.key],
          reason: sport.key,
        );
      }
    });

    test('every one of the thirteen sports has a fallback — no gaps', () {
      expect(DabblerSportIconRegistry.fallbacks.keys.toSet(),
          kDabblerSports.toSet());
    });

    test('with an empty registry every sport resolves to its fallback', () {
      for (final DabblerSport sport in kDabblerSports) {
        final DabblerSportIconResolution r =
            DabblerSportIconRegistry.resolve(sport);
        expect(r.outcome, DabblerSportIconOutcome.fallback);
        expect(r.hasGlyph, isFalse);
        expect(r.iconsaxName, sourceFallbacks[sport.key]);
      }
    });

    test('bold requests take the same fallback name', () {
      for (final DabblerSport sport in kDabblerSports) {
        expect(
          DabblerSportIconRegistry
              .resolve(sport, weight: DabblerIconWeight.bold)
              .iconsaxName,
          sourceFallbacks[sport.key],
        );
      }
    });

    test('an unknown sport string warns and resolves to game', () {
      final DabblerSportIconResolution r =
          DabblerSportIconRegistry.resolveKey('quidditch');
      expect(r.outcome, DabblerSportIconOutcome.unknownSport);
      expect(r.sport, isNull);
      expect(r.iconsaxName, 'game');
      expect(DabblerSportIconRegistry.warnedKeys, contains('unknown:quidditch'));
    });

    test('resolveKey matches resolve for every known key', () {
      for (final DabblerSport sport in kDabblerSports) {
        expect(DabblerSportIconRegistry.resolveKey(sport.key).outcome,
            DabblerSportIconOutcome.fallback);
      }
    });

    test('resolution never throws for any sport at any weight', () {
      for (final DabblerSport sport in kDabblerSports) {
        for (final DabblerIconWeight weight in DabblerIconWeight.values) {
          expect(() => DabblerSportIconRegistry.resolve(sport, weight: weight),
              returnsNormally);
        }
      }
      expect(() => DabblerSportIconRegistry.resolveKey(''), returnsNormally);
    });
  });

  group('warnings are one-time and visible', () {
    test('a sport warns once, not per call', () {
      final List<String> messages = <String>[];
      DabblerSportIconRegistry.warn = messages.add;
      DabblerSportIconRegistry.resolve(DabblerSport.padel);
      DabblerSportIconRegistry.resolve(DabblerSport.padel);
      DabblerSportIconRegistry.resolve(DabblerSport.padel);
      expect(messages, hasLength(1));
      expect(messages.single, contains('padel'));
      expect(messages.single, contains('ticket-2'));
    });
  });

  group('registration', () {
    DabblerSportGlyph markerGlyph(String tag) => DabblerSportGlyph(
          linear: (BuildContext context, double size, Color color) =>
              SizedBox(width: size, height: size, child: Text('$tag-linear')),
          bold: (BuildContext context, double size, Color color) =>
              SizedBox(width: size, height: size, child: Text('$tag-bold')),
        );

    test('a registered sport stops falling back; others keep falling back', () {
      DabblerSportIconRegistry.registerSportIcons(
        <DabblerSport, DabblerSportGlyph>{
          DabblerSport.football: markerGlyph('football'),
        },
      );
      expect(DabblerSportIconRegistry.resolve(DabblerSport.football).outcome,
          DabblerSportIconOutcome.registered);
      expect(DabblerSportIconRegistry.resolve(DabblerSport.tennis).outcome,
          DabblerSportIconOutcome.fallback);
    });

    test('a registered sport with no bold weight reuses its own linear', () {
      final DabblerSportGlyph linearOnly = DabblerSportGlyph(
        linear: (BuildContext context, double size, Color color) =>
            const SizedBox.shrink(),
      );
      DabblerSportIconRegistry.registerSportIcons(
        <DabblerSport, DabblerSportGlyph>{DabblerSport.golf: linearOnly},
      );
      expect(linearOnly.hasWeight(DabblerIconWeight.bold), isFalse);
      expect(linearOnly.builderFor(DabblerIconWeight.bold),
          same(linearOnly.linear));
    });

    test('registering null clears the registry', () {
      DabblerSportIconRegistry.registerSportIcons(
        <DabblerSport, DabblerSportGlyph>{
          DabblerSport.football: markerGlyph('football'),
        },
      );
      DabblerSportIconRegistry.registerSportIcons(null);
      expect(DabblerSportIconRegistry.registry, isEmpty);
    });
  });

  group('DabblerSportIcon widget', () {
    Widget host(Widget child) =>
        MaterialApp(home: Scaffold(body: Center(child: child)));

    testWidgets('draws the fallback through DabblerIcon, never blank',
        (WidgetTester tester) async {
      await tester.pumpWidget(host(const DabblerSportIcon(DabblerSport.padel)));
      expect(find.byType(DabblerIcon), findsOneWidget);
      final DabblerIcon icon = tester.widget(find.byType(DabblerIcon));
      expect(icon.name, 'ticket-2');
      // The fallback resolves to a real glyph, so no placeholder is painted.
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('every sport renders without throwing at both weights',
        (WidgetTester tester) async {
      for (final DabblerSport sport in kDabblerSports) {
        for (final DabblerIconWeight weight in DabblerIconWeight.values) {
          await tester
              .pumpWidget(host(DabblerSportIcon(sport, weight: weight)));
          expect(tester.takeException(), isNull, reason: sport.key);
          expect(find.byType(Icon), findsOneWidget, reason: sport.key);
        }
      }
    });

    testWidgets('an unknown key renders the game glyph, not an exception',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(host(const DabblerSportIcon.fromKey('quidditch')));
      expect(tester.takeException(), isNull);
      final DabblerIcon icon = tester.widget(find.byType(DabblerIcon));
      expect(icon.name, 'game');
    });

    testWidgets('decorative by default; labelled when semanticLabel is given',
        (WidgetTester tester) async {
      await tester.pumpWidget(host(const DabblerSportIcon(DabblerSport.tennis)));
      expect(find.byType(ExcludeSemantics), findsWidgets);

      await tester.pumpWidget(host(const DabblerSportIcon(
        DabblerSport.tennis,
        semanticLabel: 'Tennis',
      )));
      expect(find.bySemanticsLabel('Tennis'), findsOneWidget);
    });

    testWidgets('a registered glyph is drawn instead of the fallback',
        (WidgetTester tester) async {
      DabblerSportIconRegistry.registerSportIcons(
        <DabblerSport, DabblerSportGlyph>{
          DabblerSport.cricket: DabblerSportGlyph(
            linear: (BuildContext context, double size, Color color) =>
                const Text('cricket-glyph'),
          ),
        },
      );
      await tester
          .pumpWidget(host(const DabblerSportIcon(DabblerSport.cricket)));
      expect(find.text('cricket-glyph'), findsOneWidget);
      expect(find.byType(DabblerIcon), findsNothing);
    });
  });
}
