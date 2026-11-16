import 'dart:ui' show Color;

import 'dabbler_colors.dart';
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
/// **Brightness.** The design declares no dark value for any of these (no
/// `[data-mode="dark"]` rule touches a `--tile-*`, `--surface-sunken` or
/// `--ink-soft`), so the card paints the same pastel in dark mode. These are
/// constants for both brightnesses; [DabblerActivityCard] draws its content
/// as a light island so the ink on them is the design's too.
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
}
