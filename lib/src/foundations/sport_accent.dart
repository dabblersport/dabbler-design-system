import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_palette.dart';
import 'sports.dart';

/// SportAccent — the colour a sport is drawn in where a screen colours by
/// sport: the Profiles sport picker's selected chip and primary-sport dot, the
/// hero stat tile behind a chosen sport.
///
/// Drawn from the `ACCENT` table of `Profiles.dc.html:474-480`, which the
/// frame itself captions *"One section palette per sport, straight from the
/// design system's seven themes"*. Every colour is an existing palette token;
/// no hex is added.
///
/// | key | [base] | [tint] | [deep] | source |
/// |---|---|---|---|---|
/// | (all / unknown) | `sport-p-600` | `sport-p-300` | `sport-p-700` | `:476` |
/// | `padel` | `main-p-600` | `main-p-300` | `main-p-700` | `:477` |
/// | `football` | `sport-p-600` | `sport-p-300` | `sport-p-700` | `:478` |
/// | `basketball` | `active-p-600` | `active-p-300` | `--tile-accent-ink` | `:479` |
/// | `tennis` | `social-p-600` | `social-p-300` | `--tile-info-ink` | `:480` |
///
/// ```dart
/// final DabblerSportAccent accent = DabblerSportAccent.of('padel');
/// DabblerChip(label: 'Padel', selected: on, accent: accent, onTap: pick)
/// ```
///
/// ## Only the sports the frames colour
///
/// The design colours four sports and gives every other one — and the "All
/// sports" chip's tile — the `All` entry (`ACCENT[sel] ?? ACCENT.All`,
/// `:575, :607`). [of] does the same: an unknown or unlisted key is
/// [all]. **The table may grow only from design frames**; it is not guessed
/// from the sport registry for the other fourteen sports.
///
/// ## The ink on a base fill
///
/// The design's `on` is `--color-on-brand`, which follows the theme and
/// brightness, so it is not stored here: [onColorOf] reads it from the
/// ambient [DabblerColors]. [base] is a palette ramp step and does not change
/// in dark mode, exactly as the source's `var(--sport-p-600)` does not.
@immutable
class DabblerSportAccent {
  /// An accent from three palette steps.
  const DabblerSportAccent({
    required this.base,
    required this.tint,
    required this.deep,
  });

  /// The 600 step — the selected fill and border, the idle primary-sport dot.
  final Color base;

  /// The 300 step — the pale companion tone.
  final Color tint;

  /// The 700 step (or the tile ink) — the deepest tone, for ink on a pale
  /// ground.
  final Color deep;

  /// The `All` entry, and what any unlisted sport takes (`Profiles.dc.html:476`).
  static const DabblerSportAccent all = DabblerSportAccent(
    base: DabblerPalette.sportP600,
    tint: DabblerPalette.sportP300,
    deep: DabblerPalette.sportP700,
  );

  /// `Padel` — the `main` ramp (`:477`).
  static const DabblerSportAccent padel = DabblerSportAccent(
    base: DabblerPalette.mainP600,
    tint: DabblerPalette.mainP300,
    deep: DabblerPalette.mainP700,
  );

  /// `Football` — the `sport` ramp (`:478`).
  static const DabblerSportAccent football = all;

  /// `Basketball` — the `active` ramp, deepest tone `--tile-accent-ink`
  /// (`:479`), which is `active-p-700` (`DabblerColors.tileAccent.ink`).
  static const DabblerSportAccent basketball = DabblerSportAccent(
    base: DabblerPalette.activeP600,
    tint: DabblerPalette.activeP300,
    deep: DabblerPalette.activeP700,
  );

  /// `Tennis` — the `social` ramp, deepest tone `--tile-info-ink` (`:480`),
  /// which is `social-p-700` (`DabblerColors.tileInfo.ink`).
  static const DabblerSportAccent tennis = DabblerSportAccent(
    base: DabblerPalette.socialP600,
    tint: DabblerPalette.socialP300,
    deep: DabblerPalette.socialP700,
  );

  /// The accent for a kebab-case sport [key] (`padel`, `table-tennis`), or
  /// [all] for null, an unknown key, or a sport the frames do not colour.
  static DabblerSportAccent of(String? key) => switch (key) {
    'padel' => padel,
    'football' => football,
    'basketball' => basketball,
    'tennis' => tennis,
    _ => all,
  };

  /// The accent for a registry [sport], or [all] for null.
  static DabblerSportAccent forSport(DabblerSport? sport) => of(sport?.key);

  /// The ink that sits on [base]: `--color-on-brand` (`:370`), which follows
  /// the theme and brightness.
  static Color onColorOf(DabblerColors colors) => colors.onBrand;

  /// [base] at [DabblerSportAccent.surfaceAlpha] over [card] — the pale
  /// tinted fill the persona and sport cards use
  /// (`Auth and Onboarding.dc.html:1999-2016`, [DabblerHueTone.ramp]'s recipe).
  Color surfaceOver(Color card) =>
      Color.alphaBlend(base.withValues(alpha: surfaceAlpha), card);

  /// The blend strength of [surfaceOver] — `0.12`.
  static const double surfaceAlpha = 0.12;

  @override
  bool operator ==(Object other) =>
      other is DabblerSportAccent &&
      other.base == base &&
      other.tint == tint &&
      other.deep == deep;

  @override
  int get hashCode => Object.hash(base, tint, deep);
}
