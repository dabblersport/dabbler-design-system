/// The canonical sport identity shared by `SportIcon` and `SportBackground`.
///
/// Transcribed from the design source `components/foundations/SportIcon.jsx` →
/// `export const SPORTS`, and cross-checked against
/// `components/foundations/icons-system.card.html:155`, which calls that array
/// *"the current, complete `SPORTS` list"*.
///
/// ## Thirteen, not twelve
///
/// The source disagrees with itself about the count, and this file follows the
/// **code**, not the prose. `SportIcon.jsx`'s `SPORTS` array and its
/// `FALLBACKS` table both carry **thirteen** entries — `gym` is the
/// thirteenth. `SportIcon.d.ts`'s `Sport` union and several sentences in
/// `SportIcon.prompt.md` say "twelve" and omit `gym`, while the same prompt
/// file's blocker section asks for *"12 glyphs"* and the card asks for
/// *"13 sports × linear/bold"*.
///
/// `gym` wins on three independent counts: it is in the executable `SPORTS`
/// array, it has a `FALLBACKS` entry (`activity`), and the card's own fallback
/// table (`icons-system.card.html:152`) lists it by name. Dropping it would
/// also break `SportBackground`, whose bundle ships `gym` artwork. The
/// "twelve" wording is treated as stale prose.
library;

/// One sport in the product's vocabulary.
///
/// The order of the values is the source's array order, which is the order the
/// specimen card renders and therefore the order a filter row should use.
///
/// The enum — rather than a bare `String` — is the one deliberate shape change
/// from the JavaScript source. The web component takes any string and warns at
/// runtime on an unknown one; Dart can make that a compile-time error instead.
/// The string door is not closed: [DabblerSport.fromKey] still accepts the
/// kebab-case key a Supabase row or a deep link carries, and returns `null`
/// rather than throwing on a value the system does not know.
enum DabblerSport {
  /// `football`.
  football('football'),

  /// `padel`.
  padel('padel'),

  /// `tennis`.
  tennis('tennis'),

  /// `basketball`.
  basketball('basketball'),

  /// `volleyball`.
  volleyball('volleyball'),

  /// `cricket`.
  cricket('cricket'),

  /// `running`.
  running('running'),

  /// `swimming`.
  swimming('swimming'),

  /// `cycling`.
  cycling('cycling'),

  /// `badminton`.
  badminton('badminton'),

  /// `golf`.
  golf('golf'),

  /// `table-tennis` — the one two-word key, kebab-cased in the source.
  tableTennis('table-tennis'),

  /// `gym`.
  gym('gym');

  const DabblerSport(this.key);

  /// The kebab-case identity string, exactly as the design source spells it.
  ///
  /// This is the value that crosses a boundary — a database column, a route
  /// parameter, an analytics event — and the key both registries are keyed by.
  final String key;

  /// The sport for a kebab-case [key], or `null` if the system has no such
  /// sport.
  ///
  /// Total and never throws: an unknown sport is a normal condition at a data
  /// boundary, and the caller decides what to show. `SportIcon`'s own
  /// unknown-sport path is documented on `DabblerSportIcon`.
  static DabblerSport? fromKey(String key) {
    for (final DabblerSport sport in values) {
      if (sport.key == key) return sport;
    }
    return null;
  }
}

/// The thirteen sports, in the design source's own order.
///
/// A named alias for [DabblerSport.values]. It exists because the source
/// exports `SPORTS` as the thing screens iterate, and a reader arriving from
/// `SportIcon.jsx` should find the same name here.
const List<DabblerSport> kDabblerSports = DabblerSport.values;
