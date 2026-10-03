import 'dabbler_colors.dart';

/// Named on-colour pairs for the four status tones — **no new colours**.
///
/// [DabblerStatusColor] already declares, per tone, a tint fill
/// ([DabblerStatusColor.surface], `--color-status-<tone>-surface`) and the
/// status ink that is specified to sit on it ([DabblerStatusColor.strong],
/// `--color-status-<tone>-strong`, `tokens/colors.css:123-131`: *"legible both
/// on surface and on a neutral card"*). Callers kept re-assembling that pair
/// by hand — a status pill, a "Confirmed" chip on a game card, a warning
/// strip. This names it once, as the same [DabblerToneColor] shape the tags
/// and tiles use, so a caller cannot pair a tone's surface with another
/// tone's ink.
///
/// ## Measured contrast
///
/// `test/tokens/dabbler_status_pairs_test.dart` measures `strong` on
/// `surface` for every tone in all 14 resolutions (7 themes × light/dark) and
/// requires **WCAG AA, 4.5:1**, for body text; the test prints the lowest
/// measured ratio per tone so the figure is recorded rather than asserted
/// from memory.
///
/// There is deliberately no `solid` pair: the white that sits on
/// [DabblerStatusColor.solid] is not a member of the status tone, and adding
/// it here would invent a role the source does not declare.
extension DabblerStatusPairs on DabblerStatusColor {
  /// The tint pair: [surface] as the fill, [strong] as the ink on it.
  DabblerToneColor get tint => DabblerToneColor(surface: surface, ink: strong);
}

/// [DabblerStatusPairs] reached from the colour API by tone.
extension DabblerColorsStatusPairs on DabblerColors {
  /// The tint pair of [tone] — `status(tone).tint`.
  DabblerToneColor statusTint(DabblerStatusTone tone) => status(tone).tint;
}
