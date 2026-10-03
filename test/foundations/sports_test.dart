import 'package:dabbler_design_system/src/foundations/sports.dart';
import 'package:flutter_test/flutter_test.dart';

/// Asserts the sport vocabulary against the design source
/// `components/foundations/SportIcon.jsx` -> `export const SPORTS`, which
/// `icons-system.card.html:155` (unverified: file not mirrored) calls "the current, complete SPORTS list".
void main() {
  /// Transcribed literally from the source array, in its order.
  const List<String> sourceSports = <String>[
    'football',
    'padel',
    'tennis',
    'basketball',
    'volleyball',
    'cricket',
    'running',
    'swimming',
    'cycling',
    'badminton',
    'golf',
    'table-tennis',
    'gym',
  ];

  /// KAN-411 item 7 — appended after the source's thirteen; not in the source.
  const List<String> addedSports = <String>[
    'handball',
    'squash',
    'baseball',
    'rugby',
    'hockey',
  ];

  group('DabblerSport', () {
    test('carries the thirteen sports of the source, in source order', () {
      expect(
        kDabblerSports.map((DabblerSport s) => s.key).take(13).toList(),
        sourceSports,
      );
    });

    test('KAN-411: five added sports follow the source thirteen', () {
      expect(
        kDabblerSports.map((DabblerSport s) => s.key).skip(13).toList(),
        addedSports,
      );
      expect(kDabblerSports, hasLength(18));
      for (final String key in addedSports) {
        expect(DabblerSport.fromKey(key), isNotNull, reason: key);
        expect(DabblerSport.fromKey(key)!.key, key);
      }
    });

    test('gym is present — the code wins over the "twelve" prose', () {
      // SportIcon.d.ts's union and parts of SportIcon.prompt.md say twelve and
      // omit gym; SPORTS, FALLBACKS, icons-system.card.html:152 (unverified: file not mirrored) and the
      // shipped gym artwork all say thirteen.
      expect(kDabblerSports, contains(DabblerSport.gym));
      expect(kDabblerSports.indexOf(DabblerSport.gym), 12);
    });

    test('fromKey round-trips every sport', () {
      for (final DabblerSport sport in kDabblerSports) {
        expect(DabblerSport.fromKey(sport.key), sport);
      }
    });

    test('fromKey returns null for an unknown key and never throws', () {
      expect(DabblerSport.fromKey('quidditch'), isNull);
      expect(DabblerSport.fromKey(''), isNull);
      expect(DabblerSport.fromKey('Football'), isNull);
    });

    test('table-tennis keeps the kebab-case key the source spells', () {
      expect(DabblerSport.tableTennis.key, 'table-tennis');
    });
  });
}
