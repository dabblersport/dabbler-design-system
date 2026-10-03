import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/foundations/sport_background.dart';
import 'package:dabbler_design_system/src/foundations/sport_icon.dart';
import 'package:dabbler_design_system/src/foundations/sports.dart';
import 'package:flutter_test/flutter_test.dart';

/// Values pinned against a hand-transcribed mirror of the live Claude Design project
/// 4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System), files
/// `components/foundations/Icon.jsx`, `SportIcon.jsx` and `SportBackground.jsx`,
/// read via DesignSync get_file on 2026-10-02 and hand-transcribed (no byte check) to a local mirror
/// by the coordinator.
void main() {
  setUp(() {
    DabblerIconRegistry.reset();
    DabblerSportIconRegistry.reset();
    DabblerSportBackgroundRegistry.reset();
  });

  test('Icon.jsx PRO_FALLBACKS keys are the web-gated names', () {
    // Live `PRO_FALLBACKS` keys, in order (Icon.jsx:30-42).
    expect(DabblerIconRegistry.webProGatedNames, <String>[
      'arrow-right',
      'arrow-right-1',
      'arrow-right-2',
      'arrow-right-3',
      'arrow-left',
      'arrow-left-1',
      'arrow-left-2',
      'arrow-left-3',
      'arrow-down',
      'arrow-down-1',
      'arrow-down-2',
      'arrow-up',
      'arrow-up-1',
      'arrow-up-2',
      'more-2',
      'refresh',
      'refresh-2',
      'logout',
      'login',
    ]);
  });

  test('every gated name still draws a real glyph, never a blank', () {
    // The live web tier substitutes `arrow-circle-*` for these; Flutter's
    // iconsax_flutter carries them, so each must resolve to a glyph.
    for (final String name in DabblerIconRegistry.webProGatedNames) {
      final DabblerIconResolution r = DabblerIconRegistry.resolve(name);
      expect(r.hasGlyph, isTrue, reason: name);
    }
  });

  test('Icon default weight is linear', () {
    // Icon.jsx — `type = 'linear'`.
    final DabblerIcon icon = const DabblerIcon('home-2');
    expect(icon.weight, DabblerIconWeight.linear);
    expect(icon.size, isNull, reason: 'null falls back to 24 (size = 24)');
  });

  test('SportIcon.jsx SPORTS list and FALLBACKS map', () {
    // The first thirteen are the design source's; KAN-411 appends five.
    expect(
      kDabblerSports.map((DabblerSport s) => s.key).take(13).toList(),
      <String>[
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
      ],
    );
    const Map<String, String> live = <String, String>{
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
    for (final DabblerSport s in DabblerSport.values.take(13)) {
      expect(DabblerSportIconRegistry.fallbacks[s], live[s.key], reason: s.key);
    }
    // KAN-411 additions are not in the source's FALLBACKS; they follow its
    // grouping (team/ball games -> game, racket sports -> ticket-2).
    const Map<String, String> added = <String, String>{
      'handball': 'game',
      'baseball': 'game',
      'rugby': 'game',
      'hockey': 'game',
      'squash': 'ticket-2',
    };
    for (final MapEntry<String, String> e in added.entries) {
      expect(
        DabblerSportIconRegistry.fallbacks[DabblerSport.fromKey(e.key)!],
        e.value,
        reason: e.key,
      );
    }
    expect(DabblerSportIconRegistry.fallbacks, hasLength(18));
  });

  test('SportIcon never resolves blank: every sport and an unknown key', () {
    for (final DabblerSport s in DabblerSport.values) {
      final DabblerSportIconResolution r = DabblerSportIconRegistry.resolve(s);
      expect(
        DabblerIconRegistry.resolve(r.iconsaxName).hasGlyph,
        isTrue,
        reason: s.key,
      );
    }
    final DabblerSportIconResolution u = DabblerSportIconRegistry.resolveKey(
      'quidditch',
    );
    expect(u.iconsaxName, 'game', reason: 'SportIcon.jsx: unknown -> game');
    expect(DabblerIconRegistry.resolve(u.iconsaxName).hasGlyph, isTrue);
  });

  test('SportBackground.jsx: variants main/matchDay, no fallback to main', () {
    expect(
      DabblerSportBackgroundVariant.values
          .map((DabblerSportBackgroundVariant v) => v.key)
          .toList(),
      <String>['main', 'matchDay'],
    );
    for (final DabblerSport s in DabblerSport.values) {
      expect(
        DabblerSportBackgroundRegistry.resolve(
          s,
          variant: DabblerSportBackgroundVariant.matchDay,
        ),
        isNull,
        reason: s.key,
      );
    }
  });
}
