import 'package:dabbler_design_system/src/foundations/sports.dart';
import 'package:flutter_test/flutter_test.dart';

/// Asserts the sport vocabulary against the design source
/// `components/foundations/SportIcon.jsx` -> `export const SPORTS`, which
/// `icons-system.card.html:155` calls "the current, complete SPORTS list".
void main() {
  /// Transcribed literally from the source array, in its order.
  const List<String> sourceSports = <String>[
    'football', 'padel', 'tennis', 'basketball', 'volleyball', 'cricket',
    'running', 'swimming', 'cycling', 'badminton', 'golf', 'table-tennis',
    'gym',
  ];

  group('DabblerSport', () {
    test('carries the thirteen sports of the source, in source order', () {
      expect(
        kDabblerSports.map((DabblerSport s) => s.key).toList(),
        sourceSports,
      );
    });

    test('gym is present — the code wins over the "twelve" prose', () {
      // SportIcon.d.ts's union and parts of SportIcon.prompt.md say twelve and
      // omit gym; SPORTS, FALLBACKS, icons-system.card.html:152 and the
      // shipped gym artwork all say thirteen.
      expect(kDabblerSports, contains(DabblerSport.gym));
      expect(kDabblerSports, hasLength(13));
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
