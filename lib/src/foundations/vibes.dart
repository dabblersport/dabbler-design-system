/// The vibe token set — the mood a person attaches to a post (KAN-411).
///
/// Transcribed from the `VIBES` array in the design file `Post.dc.html`
/// (119 entries, complete). `Home Feed.dc.html` carries the same array but the
/// DesignSync read is truncated at 256 KiB after its 68th entry; those 68 are
/// byte-identical to the first 68 here, and everything after them in that file
/// (the remaining entries, its `VIBE_CTX`, `vibesFor`, `renderVals`) is
/// **unread**.
///
/// ## No emoji, no per-vibe glyph
///
/// The design draws an emoji beside every vibe. This system ships none: a vibe
/// is a label and a tone. The design carries no per-vibe icon name either (its
/// only glyph is the shared `add-square` trigger), so nothing here exposes an
/// Iconsax name per vibe. The emoji is recorded in the docs page, not in code.
///
/// ## Tones come from the palette, never from the design hex
///
/// Each design hex is mapped to the perceptually nearest step of
/// [DabblerPalette] (CIEDE2000). The mapping table lives in
/// `assets/documentation/foundations/vibes.md`. No colour literal is declared
/// here.
///
/// ## Dark
///
/// The design defines the accent once, for both modes. The tinted surface and
/// the border are blends over [DabblerColors.surfaceCard] and the ink is
/// [DabblerColors.textPrimary], so dark follows the package's provisional dark
/// ramp with nothing invented here.
library;

import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_palette.dart';

/// The design's `theme` field: positive, negative or neutral.
enum DabblerVibeMood {
  /// `theme: 'positive'`.
  positive,

  /// `theme: 'negative'`.
  negative,

  /// `theme: 'neutral'`.
  neutral,
}

/// The design's `type` field: whether a vibe is something done or felt.
enum DabblerVibeType {
  /// `type: 'action'`.
  action,

  /// `type: 'feeling'`.
  feeling,
}

/// The design's `contexts` field: where a vibe is offered.
enum DabblerVibeContext {
  /// `"kickin"`.
  kickin,

  /// `"dab"` — the Post screen's `VIBE_CTX`.
  dab,

  /// `"moment"`.
  moment,
}

/// The four blend strengths the design's `color-mix(in srgb, hex N%, card)`
/// uses for a vibe pill.
abstract final class DabblerVibeTint {
  const DabblerVibeTint._();

  /// Unselected fill — 16%.
  static const double surface = 0.16;

  /// Selected fill — 34%.
  static const double selectedSurface = 0.34;

  /// Unselected border — 32%.
  static const double border = 0.32;

  /// Selected border — 75%.
  static const double selectedBorder = 0.75;
}

/// One vibe resolved for a theme and brightness.
@immutable
class DabblerVibeColors {
  /// Creates a resolved vibe.
  const DabblerVibeColors({
    required this.accent,
    required this.ink,
    required this.surface,
    required this.selectedSurface,
    required this.border,
    required this.selectedBorder,
  });

  /// The palette step the vibe's design hex maps to.
  final Color accent;

  /// The label colour — `--ink`, [DabblerColors.textPrimary].
  final Color ink;

  /// The unselected pill fill.
  final Color surface;

  /// The selected pill fill.
  final Color selectedSurface;

  /// The unselected pill border.
  final Color border;

  /// The selected pill border.
  final Color selectedBorder;

  @override
  bool operator ==(Object other) =>
      other is DabblerVibeColors &&
      other.accent == accent &&
      other.ink == ink &&
      other.surface == surface &&
      other.selectedSurface == selectedSurface &&
      other.border == border &&
      other.selectedBorder == selectedBorder;

  @override
  int get hashCode => Object.hash(
    accent,
    ink,
    surface,
    selectedSurface,
    border,
    selectedBorder,
  );
}

/// Every vibe the design offers, in the design's array order.
///
/// [fromKey] accepts the kebab-case [key] a database row carries and returns
/// `null` for an unknown one.
enum DabblerVibe {
  /// `Supportive` — positive action; accent `DabblerPalette.sportS600`.
  supportive(
    'supportive',
    'Supportive',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.moment},
    DabblerPalette.sportS600,
  ),

  /// `Caring` — positive feeling; accent `DabblerPalette.activeP300`.
  caring(
    'caring',
    'Caring',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.activeP300,
  ),

  /// `Loving` — positive feeling; accent `DabblerPalette.activeError`.
  loving(
    'loving',
    'Loving',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.activeError,
  ),

  /// `Inspired` — positive action; accent `DabblerPalette.tileAmberSurface`.
  inspired(
    'inspired',
    'Inspired',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.tileAmberSurface,
  ),

  /// `Proud` — positive feeling; accent `DabblerPalette.brightP600`.
  proud(
    'proud',
    'Proud',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.brightP600,
  ),

  /// `Hopeful` — positive feeling; accent `DabblerPalette.warning500`.
  hopeful(
    'hopeful',
    'Hopeful',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.moment},
    DabblerPalette.warning500,
  ),

  /// `Nostalgic` — positive feeling; accent `DabblerPalette.socialP300`.
  nostalgic(
    'nostalgic',
    'Nostalgic',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.socialP300,
  ),

  /// `Positive` — positive feeling; accent `DabblerPalette.sportS400`.
  positive(
    'positive',
    'Positive',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{
      DabblerVibeContext.kickin,
      DabblerVibeContext.dab,
      DabblerVibeContext.moment,
    },
    DabblerPalette.sportS400,
  ),

  /// `Loved` — positive feeling; accent `DabblerPalette.activeError`.
  loved(
    'loved',
    'Loved',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.activeError,
  ),

  /// `Supported` — positive feeling; accent `DabblerPalette.sportS400`.
  supported(
    'supported',
    'Supported',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.moment},
    DabblerPalette.sportS400,
  ),

  /// `Amazed` — positive feeling; accent `DabblerPalette.tileAmberSurface`.
  amazed(
    'amazed',
    'Amazed',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.tileAmberSurface,
  ),

  /// `Happy` — positive feeling; accent `DabblerPalette.tileAmberSurface`.
  happy(
    'happy',
    'Happy',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.tileAmberSurface,
  ),

  /// `Calm` — positive feeling; accent `DabblerPalette.socialS600`.
  calm(
    'calm',
    'Calm',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.socialS600,
  ),

  /// `Relaxed` — positive feeling; accent `DabblerPalette.socialS400`.
  relaxed(
    'relaxed',
    'Relaxed',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.socialS400,
  ),

  /// `Thankful` — positive feeling; accent `DabblerPalette.tileAmberSurface`.
  thankful(
    'thankful',
    'Thankful',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.tileAmberSurface,
  ),

  /// `Surprised` — positive feeling; accent `DabblerPalette.spotlight500`.
  surprised(
    'surprised',
    'Surprised',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.spotlight500,
  ),

  /// `Energetic` — positive action; accent `DabblerPalette.error500`.
  energetic(
    'energetic',
    'Energetic',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.error500,
  ),

  /// `Determined` — positive action; accent `DabblerPalette.spotlight500`.
  determined(
    'determined',
    'Determined',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.spotlight500,
  ),

  /// `Motivated` — positive action; accent `DabblerPalette.spotlight500`.
  motivated(
    'motivated',
    'Motivated',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.spotlight500,
  ),

  /// `Focused` — positive action; accent `DabblerPalette.socialS700`.
  focused(
    'focused',
    'Focused',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.socialS700,
  ),

  /// `Excited` — positive action; accent `DabblerPalette.warning500`.
  excited(
    'excited',
    'Excited',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.warning500,
  ),

  /// `Empowered` — positive action; accent `DabblerPalette.spotlight500`.
  empowered(
    'empowered',
    'Empowered',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.spotlight500,
  ),

  /// `Heroic` — positive action; accent `DabblerPalette.activeError`.
  heroic(
    'heroic',
    'Heroic',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.activeError,
  ),

  /// `Brave` — positive action; accent `DabblerPalette.warning500`.
  brave(
    'brave',
    'Brave',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.moment},
    DabblerPalette.warning500,
  ),

  /// `Recognized` — positive feeling; accent `DabblerPalette.tileAmberSurface`.
  recognized(
    'recognized',
    'Recognized',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.tileAmberSurface,
  ),

  /// `Kind` — positive action; accent `DabblerPalette.error100`.
  kind(
    'kind',
    'Kind',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.moment},
    DabblerPalette.error100,
  ),

  /// `Sympathetic` — positive feeling; accent `DabblerPalette.socialS400`.
  sympathetic(
    'sympathetic',
    'Sympathetic',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.socialS400,
  ),

  /// `Together` — positive action; accent `DabblerPalette.success500`.
  together(
    'together',
    'Together',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.moment},
    DabblerPalette.success500,
  ),

  /// `Free` — positive feeling; accent `DabblerPalette.tagProgressSurface`.
  free(
    'free',
    'Free',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.moment},
    DabblerPalette.tagProgressSurface,
  ),

  /// `Reflective` — positive feeling; accent `DabblerPalette.mainP400`.
  reflective(
    'reflective',
    'Reflective',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.mainP400,
  ),

  /// `Grateful` — positive feeling; accent `DabblerPalette.tileAmberSurface`.
  grateful(
    'grateful',
    'Grateful',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.tileAmberSurface,
  ),

  /// `Longing` — positive feeling; accent `DabblerPalette.ink300`.
  longing(
    'longing',
    'Longing',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.ink300,
  ),

  /// `Broken` — positive feeling; accent `DabblerPalette.ink400`.
  broken(
    'broken',
    'Broken',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.ink400,
  ),

  /// `Unique` — positive feeling; accent `DabblerPalette.activeP300`.
  unique(
    'unique',
    'Unique',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.activeP300,
  ),

  /// `Heard` — positive feeling; accent `DabblerPalette.sportP300`.
  heard(
    'heard',
    'Heard',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.sportP300,
  ),

  /// `Grounded` — positive action; accent `DabblerPalette.sportS700`.
  grounded(
    'grounded',
    'Grounded',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.sportS700,
  ),

  /// `Awake` — positive action; accent `DabblerPalette.tileAmberSurface`.
  awake(
    'awake',
    'Awake',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.dab},
    DabblerPalette.tileAmberSurface,
  ),

  /// `Jittery` — positive feeling; accent `DabblerPalette.warning500`.
  jittery(
    'jittery',
    'Jittery',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab},
    DabblerPalette.warning500,
  ),

  /// `Exploring` — positive action; accent `DabblerPalette.success500`.
  exploring(
    'exploring',
    'Exploring',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.dab},
    DabblerPalette.success500,
  ),

  /// `Orbiting` — positive action; accent `DabblerPalette.socialP600`.
  orbiting(
    'orbiting',
    'Orbiting',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.dab},
    DabblerPalette.socialP600,
  ),

  /// `Aligned` — positive feeling; accent `DabblerPalette.sportS600`.
  aligned(
    'aligned',
    'Aligned',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.sportS600,
  ),

  /// `Stellar` — positive feeling; accent `DabblerPalette.tileAmberSurface`.
  stellar(
    'stellar',
    'Stellar',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab},
    DabblerPalette.tileAmberSurface,
  ),

  /// `Celestial` — positive feeling; accent `DabblerPalette.ink600`.
  celestial(
    'celestial',
    'Celestial',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab},
    DabblerPalette.ink600,
  ),

  /// `Solar` — positive feeling; accent `DabblerPalette.warning500`.
  solar(
    'solar',
    'Solar',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.warning500,
  ),

  /// `Lunar` — positive feeling; accent `DabblerPalette.ink300`.
  lunar(
    'lunar',
    'Lunar',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.ink300,
  ),

  /// `Unearthly` — positive feeling; accent `DabblerPalette.tagSubmittedInk`.
  unearthly(
    'unearthly',
    'Unearthly',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab},
    DabblerPalette.tagSubmittedInk,
  ),

  /// `Blessed` — positive feeling; accent `DabblerPalette.tileAmberSurface`.
  blessed(
    'blessed',
    'Blessed',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.moment},
    DabblerPalette.tileAmberSurface,
  ),

  /// `Fortunate` — positive feeling; accent `DabblerPalette.sportS400`.
  fortunate(
    'fortunate',
    'Fortunate',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.sportS400,
  ),

  /// `Wishing` — positive feeling; accent `DabblerPalette.mainP300`.
  wishing(
    'wishing',
    'Wishing',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.moment},
    DabblerPalette.mainP300,
  ),

  /// `Manifesting` — positive action; accent `DabblerPalette.warning500`.
  manifesting(
    'manifesting',
    'Manifesting',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.warning500,
  ),

  /// `Resplendent` — positive feeling; accent `DabblerPalette.mainP700`.
  resplendent(
    'resplendent',
    'Resplendent',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.mainP700,
  ),

  /// `Misty-eyed` — positive feeling; accent `DabblerPalette.ink300`.
  mistyEyed(
    'misty-eyed',
    'Misty-eyed',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.ink300,
  ),

  /// `Still` — positive feeling; accent `DabblerPalette.info100`.
  still(
    'still',
    'Still',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.info100,
  ),

  /// `Muted` — positive feeling; accent `DabblerPalette.tagExpiredSurface`.
  muted(
    'muted',
    'Muted',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.tagExpiredSurface,
  ),

  /// `Wilting` — positive feeling; accent `DabblerPalette.ink400`.
  wilting(
    'wilting',
    'Wilting',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.ink400,
  ),

  /// `Fading` — positive feeling; accent `DabblerPalette.sportP300`.
  fading(
    'fading',
    'Fading',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.sportP300,
  ),

  /// `Restless` — positive feeling; accent `DabblerPalette.brightP600`.
  restless(
    'restless',
    'Restless',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.brightP600,
  ),

  /// `Regretful` — positive feeling; accent `DabblerPalette.ink400`.
  regretful(
    'regretful',
    'Regretful',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.ink400,
  ),

  /// `Rusty` — positive feeling; accent `DabblerPalette.brightP700`.
  rusty(
    'rusty',
    'Rusty',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.brightP700,
  ),

  /// `Layered` — positive feeling; accent `DabblerPalette.ink300`.
  layered(
    'layered',
    'Layered',
    DabblerVibeMood.positive,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.ink300,
  ),

  /// `Creative` — positive action; accent `DabblerPalette.activeP400`.
  creative(
    'creative',
    'Creative',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.activeP400,
  ),

  /// `Innovative` — positive action; accent `DabblerPalette.socialS700`.
  innovative(
    'innovative',
    'Innovative',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.socialS700,
  ),

  /// `Game On` — positive action; accent `DabblerPalette.error500`.
  gameOn(
    'game-on',
    'Game On',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.error500,
  ),

  /// `Last Call` — positive action; accent `DabblerPalette.spotlight500`.
  lastCall(
    'last-call',
    'Last Call',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.spotlight500,
  ),

  /// `Kickoff Ready` — positive action; accent `DabblerPalette.sportP400`.
  kickoffReady(
    'kickoff-ready',
    'Kickoff Ready',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.sportP400,
  ),

  /// `Almost Full` — positive action; accent `DabblerPalette.tileAmberSurface`.
  almostFull(
    'almost-full',
    'Almost Full',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.tileAmberSurface,
  ),

  /// `Join Fast` — positive action; accent `DabblerPalette.spotlight500`.
  joinFast(
    'join-fast',
    'Join Fast',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.spotlight500,
  ),

  /// `Final Whistle` — positive action; accent `DabblerPalette.warning500`.
  finalWhistle(
    'final-whistle',
    'Final Whistle',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.warning500,
  ),

  /// `Warming Up` — positive action; accent `DabblerPalette.spotlight500`.
  warmingUp(
    'warming-up',
    'Warming Up',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.spotlight500,
  ),

  /// `Get Moving` — positive action; accent `DabblerPalette.socialS400`.
  getMoving(
    'get-moving',
    'Get Moving',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.socialS400,
  ),

  /// `Let's Rally` — positive action; accent `DabblerPalette.sportS600`.
  letsRally(
    'lets-rally',
    'Let\'s Rally',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.sportS600,
  ),

  /// `Squad Assemble` — positive action; accent `DabblerPalette.mainP700`.
  squadAssemble(
    'squad-assemble',
    'Squad Assemble',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.mainP700,
  ),

  /// `Game Time` — positive action; accent `DabblerPalette.tileAmberSurface`.
  gameTime(
    'game-time',
    'Game Time',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.tileAmberSurface,
  ),

  /// `Open Slot` — positive action; accent `DabblerPalette.socialS400`.
  openSlot(
    'open-slot',
    'Open Slot',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.socialS400,
  ),

  /// `Late Entry` — positive action; accent `DabblerPalette.warning500`.
  lateEntry(
    'late-entry',
    'Late Entry',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.warning500,
  ),

  /// `Countdown` — positive action; accent `DabblerPalette.spotlight500`.
  countdown(
    'countdown',
    'Countdown',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.spotlight500,
  ),

  /// `Hustle Up` — positive action; accent `DabblerPalette.activeError`.
  hustleUp(
    'hustle-up',
    'Hustle Up',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.activeError,
  ),

  /// `Let's Go` — positive action; accent `DabblerPalette.activeS600`.
  letsGo(
    'lets-go',
    'Let\'s Go',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.activeS600,
  ),

  /// `All In` — positive action; accent `DabblerPalette.info500`.
  allIn(
    'all-in',
    'All In',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.info500,
  ),

  /// `Bring It On` — positive action; accent `DabblerPalette.activeS400`.
  bringItOn(
    'bring-it-on',
    'Bring It On',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.activeS400,
  ),

  /// `Underway` — positive action; accent `DabblerPalette.warning500`.
  underway(
    'underway',
    'Underway',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.warning500,
  ),

  /// `Locking In` — positive action; accent `DabblerPalette.socialP600`.
  lockingIn(
    'locking-in',
    'Locking In',
    DabblerVibeMood.positive,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin},
    DabblerPalette.socialP600,
  ),

  /// `Drained` — negative feeling; accent `DabblerPalette.ink400`.
  drained(
    'drained',
    'Drained',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.ink400,
  ),

  /// `Heavy` — negative feeling; accent `DabblerPalette.tagExpiredInk`.
  heavy(
    'heavy',
    'Heavy',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.tagExpiredInk,
  ),

  /// `Off Day` — negative feeling; accent `DabblerPalette.ink400`.
  offDay(
    'off-day',
    'Off Day',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.ink400,
  ),

  /// `Under Pressure` — negative feeling; accent `DabblerPalette.warning500`.
  underPressure(
    'under-pressure',
    'Under Pressure',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.warning500,
  ),

  /// `Tense` — negative feeling; accent `DabblerPalette.activeError`.
  tense(
    'tense',
    'Tense',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.activeError,
  ),

  /// `Shaky` — negative feeling; accent `DabblerPalette.info100`.
  shaky(
    'shaky',
    'Shaky',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab},
    DabblerPalette.info100,
  ),

  /// `Disconnected` — negative feeling; accent `DabblerPalette.ink500`.
  disconnected(
    'disconnected',
    'Disconnected',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.ink500,
  ),

  /// `Left Out` — negative feeling; accent `DabblerPalette.activeP400`.
  leftOut(
    'left-out',
    'Left Out',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.activeP400,
  ),

  /// `Lonely` — negative feeling; accent `DabblerPalette.tagExpiredInk`.
  lonely(
    'lonely',
    'Lonely',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.tagExpiredInk,
  ),

  /// `Disappointed` — negative feeling; accent `DabblerPalette.activeP400`.
  disappointed(
    'disappointed',
    'Disappointed',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.activeP400,
  ),

  /// `Uncertain` — negative feeling; accent `DabblerPalette.ink300`.
  uncertain(
    'uncertain',
    'Uncertain',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.moment},
    DabblerPalette.ink300,
  ),

  /// `Sluggish` — negative feeling; accent `DabblerPalette.ink300`.
  sluggish(
    'sluggish',
    'Sluggish',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab},
    DabblerPalette.ink300,
  ),

  /// `Flat` — negative feeling; accent `DabblerPalette.ink300`.
  flat(
    'flat',
    'Flat',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.ink300,
  ),

  /// `Numb` — negative feeling; accent `DabblerPalette.ink400`.
  numb(
    'numb',
    'Numb',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.ink400,
  ),

  /// `Overthinking` — negative feeling; accent `DabblerPalette.mainP300`.
  overthinking(
    'overthinking',
    'Overthinking',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.mainP300,
  ),

  /// `Benched` — negative action; accent `DabblerPalette.ink400`.
  benched(
    'benched',
    'Benched',
    DabblerVibeMood.negative,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.ink400,
  ),

  /// `Slipping` — negative action; accent `DabblerPalette.activeError`.
  slipping(
    'slipping',
    'Slipping',
    DabblerVibeMood.negative,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.activeError,
  ),

  /// `Burned Out` — negative feeling; accent `DabblerPalette.activeError`.
  burnedOut(
    'burned-out',
    'Burned Out',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.activeError,
  ),

  /// `Frustrated` — negative feeling; accent `DabblerPalette.error500`.
  frustrated(
    'frustrated',
    'Frustrated',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.error500,
  ),

  /// `Annoyed` — negative feeling; accent `DabblerPalette.spotlight500`.
  annoyed(
    'annoyed',
    'Annoyed',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.spotlight500,
  ),

  /// `Angry` — negative feeling; accent `DabblerPalette.tagFailedInk`.
  angry(
    'angry',
    'Angry',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.tagFailedInk,
  ),

  /// `Irritated` — negative feeling; accent `DabblerPalette.brightP600`.
  irritated(
    'irritated',
    'Irritated',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.brightP600,
  ),

  /// `Salty` — negative feeling; accent `DabblerPalette.spotlight500`.
  salty(
    'salty',
    'Salty',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.spotlight500,
  ),

  /// `Rattled` — negative feeling; accent `DabblerPalette.spotlight500`.
  rattled(
    'rattled',
    'Rattled',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.spotlight500,
  ),

  /// `On Edge` — negative feeling; accent `DabblerPalette.warning500`.
  onEdge(
    'on-edge',
    'On Edge',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.warning500,
  ),

  /// `Heated` — negative feeling; accent `DabblerPalette.activeError`.
  heated(
    'heated',
    'Heated',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.dab},
    DabblerPalette.activeError,
  ),

  /// `Clashing` — negative action; accent `DabblerPalette.mainP400`.
  clashing(
    'clashing',
    'Clashing',
    DabblerVibeMood.negative,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.moment},
    DabblerPalette.mainP400,
  ),

  /// `Snappy` — negative action; accent `DabblerPalette.spotlight500`.
  snappy(
    'snappy',
    'Snappy',
    DabblerVibeMood.negative,
    DabblerVibeType.action,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.spotlight500,
  ),

  /// `Boiling Over` — negative feeling; accent `DabblerPalette.tagFailedInk`.
  boilingOver(
    'boiling-over',
    'Boiling Over',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.tagFailedInk,
  ),

  /// `Resentful` — negative feeling; accent `DabblerPalette.ink500`.
  resentful(
    'resentful',
    'Resentful',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.ink500,
  ),

  /// `Tilted` — negative feeling; accent `DabblerPalette.tagFailedInk`.
  tilted(
    'tilted',
    'Tilted',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab},
    DabblerPalette.tagFailedInk,
  ),

  /// `Short-Fused` — negative feeling; accent `DabblerPalette.activeError`.
  shortFused(
    'short-fused',
    'Short-Fused',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.activeError,
  ),

  /// `Fed Up` — negative feeling; accent `DabblerPalette.ink400`.
  fedUp(
    'fed-up',
    'Fed Up',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.ink400,
  ),

  /// `Overloaded` — negative feeling; accent `DabblerPalette.tagPendingInk`.
  overloaded(
    'overloaded',
    'Overloaded',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.dab, DabblerVibeContext.moment},
    DabblerPalette.tagPendingInk,
  ),

  /// `Stressed` — negative feeling; accent `DabblerPalette.activeP300`.
  stressed(
    'stressed',
    'Stressed',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.kickin, DabblerVibeContext.moment},
    DabblerPalette.activeP300,
  ),

  /// `Boomerang Thoughts` — negative feeling; accent `DabblerPalette.ink400`.
  boomerangThoughts(
    'boomerang-thoughts',
    'Boomerang Thoughts',
    DabblerVibeMood.negative,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{DabblerVibeContext.moment},
    DabblerPalette.ink400,
  ),

  /// `Neutral` — neutral feeling; accent `DabblerPalette.ink`.
  neutral(
    'neutral',
    'Neutral',
    DabblerVibeMood.neutral,
    DabblerVibeType.feeling,
    <DabblerVibeContext>{
      DabblerVibeContext.kickin,
      DabblerVibeContext.dab,
      DabblerVibeContext.moment,
    },
    DabblerPalette.ink,
  );

  const DabblerVibe(
    this.key,
    this.label,
    this.mood,
    this.type,
    this.contexts,
    this.accent,
  );

  /// The kebab-case identity string.
  final String key;

  /// The design's English name. Source text, not a localised string — a screen
  /// localises by [key].
  final String label;

  /// Positive, negative or neutral.
  final DabblerVibeMood mood;

  /// Action or feeling.
  final DabblerVibeType type;

  /// Where the design offers this vibe.
  final Set<DabblerVibeContext> contexts;

  /// The [DabblerPalette] step this vibe's design hex maps to.
  final Color accent;

  /// The vibe for [key], or `null` if the system has no such vibe.
  static DabblerVibe? fromKey(String key) {
    for (final DabblerVibe vibe in values) {
      if (vibe.key == key) return vibe;
    }
    return null;
  }

  /// The vibes offered in [context], in design order.
  static List<DabblerVibe> forContext(DabblerVibeContext context) =>
      <DabblerVibe>[
        for (final DabblerVibe vibe in values)
          if (vibe.contexts.contains(context)) vibe,
      ];

  /// This vibe's colours for [colors] (a theme and brightness).
  DabblerVibeColors resolve(DabblerColors colors) {
    Color tint(double alpha) =>
        Color.alphaBlend(accent.withValues(alpha: alpha), colors.surfaceCard);
    return DabblerVibeColors(
      accent: accent,
      ink: colors.textPrimary,
      surface: tint(DabblerVibeTint.surface),
      selectedSurface: tint(DabblerVibeTint.selectedSurface),
      border: tint(DabblerVibeTint.border),
      selectedBorder: tint(DabblerVibeTint.selectedBorder),
    );
  }
}

/// All vibes, in design order.
const List<DabblerVibe> kDabblerVibes = DabblerVibe.values;
