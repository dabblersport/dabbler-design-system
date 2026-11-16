import 'dart:ui' show Brightness, Color;

import 'dabbler_colors.dart';
import 'dabbler_dark_provisional.dart';
import 'dabbler_palette.dart';

/// The Home Feed's activity-card tones (KAN-965): the pastel ground and the
/// ink of each activity type, transcribed from `Home Feed.dc.html`
/// `ACT_TONE` / `actTone()`.
///
/// The design names them `--tile-<n>-surface` / `--tile-<n>-ink` and paints
/// the fallback hex after each name, because its `tokens/colors.css` does not
/// declare `--tile-main`, `--tile-sport`, `--tile-social`, `--tile-active` or
/// `--tile-bright`. The fallbacks are therefore the values the design draws,
/// and they are the values here. The inks are the palette's 700 steps (bright
/// takes `--bright-s-600`), exactly the design's ink fallbacks.
///
/// | tone | surface | ink | design use |
/// |---|---|---|---|
/// | [main] | `#EADDF8` | `--main-p-700` `#5A1FA1` | `game_created` |
/// | [sport] | `#DDEEDE` | `--sport-p-700` `#29692C` | `game_started`, `meetup_started` |
/// | [social] | `#DCE7F9` | `--social-p-700` `#295AA8` | `player_joined` |
/// | [active] | `#F9DDEB` | `--active-p-700` `#A12C6B` | `meetup_created` |
/// | [bright] | `#FDEBD6` | `--bright-s-600` `#703900` | `venue_added` |
/// | [accent] | `--tile-accent-surface` `#FBE0EC` | `--tile-accent-ink` `#A12C6B` | `meetup_completed` |
/// | [ended] | `--surface-sunken` `#F0EBE0` | `--ink-soft` `#404040` | `game_ended` |
///
/// **Brightness.** These constants are the light pairs. The dark pairs
/// (`dark*`, KAN-972) come from the package's dark palette; cards resolve a
/// [DabblerActivityTone] against the theme and follow it.
///
/// Decorative: none of these carries state meaning by colour alone; the
/// card's kicker text says the state.
abstract final class DabblerActivityTones {
  /// `--tile-main-*`: an upcoming game.
  static const DabblerToneColor main = DabblerToneColor(
    surface: DabblerPalette.tileMainSurface,
    ink: DabblerPalette.mainP700,
  );

  /// `--tile-sport-*`: a game or meetup happening now.
  static const DabblerToneColor sport = DabblerToneColor(
    surface: DabblerPalette.tileSportSurface,
    ink: DabblerPalette.sportP700,
  );

  /// `--tile-social-*`: a new player.
  static const DabblerToneColor social = DabblerToneColor(
    surface: DabblerPalette.tileSocialSurface,
    ink: DabblerPalette.socialP700,
  );

  /// `--tile-active-*`: an upcoming meetup.
  static const DabblerToneColor active = DabblerToneColor(
    surface: DabblerPalette.tileActiveSurface,
    ink: DabblerPalette.activeP700,
  );

  /// `--tile-bright-*`: a new venue.
  static const DabblerToneColor bright = DabblerToneColor(
    surface: DabblerPalette.tileBrightSurface,
    ink: DabblerPalette.brightS600,
  );

  /// `--tile-accent-*`: a finished meetup. The same pair as
  /// [DabblerColors.tileAccent], held at its light value in dark too.
  static const DabblerToneColor accent = DabblerColors.tileAccent;

  /// `--surface-sunken` / `--ink-soft`: a finished game.
  static const DabblerToneColor ended = DabblerToneColor(
    surface: DabblerPalette.surfaceSunken,
    ink: DabblerPalette.inkSoft,
  );

  /// `--tile-info-*` (`#DCEAFB` / `--social-p-700`): a trending sport
  /// (KAN-967). The same pair as [DabblerColors.tileInfo], held light.
  static const DabblerToneColor info = DabblerColors.tileInfo;

  /// The monthly honour's soft gold (KAN-967, `player_month`, `venue_month`):
  /// `color-mix(in srgb, var(--tile-amber-surface) 30%, #FFFFFF)` with
  /// `--bright-s-600`. sRGB mixing is [Color.lerp] from white.
  static final DabblerToneColor gold = DabblerToneColor(
    surface: Color.lerp(
      DabblerPalette.paper,
      DabblerPalette.tileAmberSurface,
      goldAmberShare,
    )!,
    ink: DabblerPalette.brightS600,
  );

  /// The amber share of [gold]: `30%`.
  static const double goldAmberShare = 0.3;

  /// Every tone, for galleries and tests.
  static const List<DabblerToneColor> all = <DabblerToneColor>[
    main,
    sport,
    social,
    active,
    bright,
    accent,
    ended,
  ];

  // --- Dark (KAN-972, CEO 2026-11-16): the design file has no dark rule, so
  // the dark pairs come from this package's dark palette, in each light
  // pair's hue family. Grounds are the provisional dark tile and status
  // surfaces; inks are the hue's 300 step (light on dark). Measured WCAG
  // contrast (test/feed/activity_card_dark_test.dart): body text on every
  // ground at least 11:1, the ink on the dark card surface at least 6.2:1,
  // the ink on its own ground at least 5.3:1.

  /// Dark [main]: the brand-tint rule ([DabblerSurface.bleedTintMix], 14% of
  /// the dark brand `--main-p-400` over the dark card), ink `--main-p-300`.
  /// The dark palette has no purple tile, so the ground is derived, not
  /// invented.
  static final DabblerToneColor darkMain = DabblerToneColor(
    surface: Color.lerp(
      DabblerProvisionalDark.surfaceCard,
      DabblerPalette.mainP400,
      darkMainMix,
    )!,
    ink: DabblerPalette.mainP300,
  );

  /// The dark brand share of [darkMain]: `14%`, the package's brand tint.
  static const double darkMainMix = 0.14;

  /// Dark [sport]: the sport theme's dark success surface, `--sport-p-300`.
  static const DabblerToneColor darkSport = DabblerToneColor(
    surface: DabblerProvisionalDark.sportSuccessSurface,
    ink: DabblerPalette.sportP300,
  );

  /// Dark [social] and [info]: the dark info tile, `--social-p-300`.
  static const DabblerToneColor darkSocial = DabblerToneColor(
    surface: DabblerProvisionalDark.tileInfoSurface,
    ink: DabblerPalette.socialP300,
  );

  /// Dark [active]: the dark accent tile, `--active-p-300`.
  static const DabblerToneColor darkActive = DabblerToneColor(
    surface: DabblerProvisionalDark.tileAccentSurface,
    ink: DabblerPalette.activeP300,
  );

  /// Dark [accent]: the Details design's dark accent tile, `--active-p-300`.
  static const DabblerToneColor darkAccent = DabblerToneColor(
    surface: DabblerProvisionalDark.detailTileAccentSurface,
    ink: DabblerPalette.activeP300,
  );

  /// Dark [bright]: the bright theme's dark warning surface, `--bright-p-300`.
  static const DabblerToneColor darkBright = DabblerToneColor(
    surface: DabblerProvisionalDark.brightWarningSurface,
    ink: DabblerPalette.brightP300,
  );

  /// Dark [ended]: the dark sunken surface and the dark secondary text.
  static const DabblerToneColor darkEnded = DabblerToneColor(
    surface: DabblerProvisionalDark.surfaceSunken,
    ink: DabblerProvisionalDark.textSecondary,
  );

  /// Dark [gold]: the dark amber tile, `--bright-p-300`.
  static const DabblerToneColor darkGold = DabblerToneColor(
    surface: DabblerProvisionalDark.tileAmberSurface,
    ink: DabblerPalette.brightP300,
  );
}

/// KAN-972: an activity tone by name, resolved for a brightness. Cards take
/// this and resolve it against the ambient [DabblerColors], so they follow
/// the theme.
enum DabblerActivityTone {
  main,
  sport,
  social,
  active,
  bright,
  accent,
  ended,
  info,
  gold;

  /// The light pair (the design's values).
  DabblerToneColor get light => switch (this) {
    main => DabblerActivityTones.main,
    sport => DabblerActivityTones.sport,
    social => DabblerActivityTones.social,
    active => DabblerActivityTones.active,
    bright => DabblerActivityTones.bright,
    accent => DabblerActivityTones.accent,
    ended => DabblerActivityTones.ended,
    info => DabblerActivityTones.info,
    gold => DabblerActivityTones.gold,
  };

  /// The dark pair (this package's dark palette).
  DabblerToneColor get dark => switch (this) {
    main => DabblerActivityTones.darkMain,
    sport => DabblerActivityTones.darkSport,
    social || info => DabblerActivityTones.darkSocial,
    active => DabblerActivityTones.darkActive,
    bright => DabblerActivityTones.darkBright,
    accent => DabblerActivityTones.darkAccent,
    ended => DabblerActivityTones.darkEnded,
    gold => DabblerActivityTones.darkGold,
  };

  /// The pair for [brightness].
  DabblerToneColor resolve(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// The pair for the ambient theme.
  DabblerToneColor of(DabblerColors colors) => resolve(colors.brightness);
}
