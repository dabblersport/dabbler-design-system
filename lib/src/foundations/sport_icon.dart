import 'package:flutter/material.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'icon.dart';
import 'sports.dart';

/// How [DabblerSportIconRegistry.resolve] arrived at what it returned.
///
/// The observable half of AC1: a test can ask which path a sport took without
/// reading pixels, exactly as [DabblerIconOutcome] does for `DabblerIcon`.
enum DabblerSportIconOutcome {
  /// A commissioned glyph was registered for this sport and drawn.
  registered,

  /// No glyph is registered, so the sport's documented Iconsax fallback
  /// (`game` / `activity` / `ticket-2`) is drawn. Warned once per sport.
  ///
  /// This is the state of **every** sport today — see
  /// [DabblerSportIconRegistry] → *Open blocker*.
  fallback,

  /// The `sport` string is not one of the thirteen. Warned once, and the
  /// generic `game` glyph is drawn.
  ///
  /// Only reachable through [DabblerSportIconRegistry.resolveKey]; the
  /// enum-typed [DabblerSportIconRegistry.resolve] cannot produce it.
  unknownSport,
}

/// A commissioned sport glyph at both weights.
///
/// The Flutter analogue of the source's registry value
/// `{ linear: url|node, bold: url|node }`. The web takes a URL *or* a React
/// node; the Dart equivalent of "either" is a builder, because an SVG asset,
/// an `Image.asset`, an [IconData] from a custom font and a hand-built
/// [CustomPaint] all collapse to the same thing once they are a function of
/// size and colour. That also keeps this package free of an SVG dependency,
/// which it is not allowed to add.
///
/// [bold] may be omitted. The source's `entry[type] || entry.linear` means a
/// registered sport with no bold weight falls back to its own linear glyph —
/// the same bold-to-linear rule [DabblerIconRegistry] applies to Iconsax, and
/// the reason that fallback is not recorded as a separate outcome here: the
/// sport is still [DabblerSportIconOutcome.registered], and it is
/// [DabblerSportGlyph.builderFor] that reports the substitution.
@immutable
class DabblerSportGlyph {
  /// Creates a glyph entry. [linear] is required; [bold] is optional and falls
  /// back to [linear] when absent.
  const DabblerSportGlyph({required this.linear, this.bold});

  /// Draws the linear weight at the given side and tint.
  final Widget Function(BuildContext context, double size, Color color) linear;

  /// Draws the bold weight, or null if the set does not yet include one.
  final Widget Function(BuildContext context, double size, Color color)? bold;

  /// The builder for [weight], falling back to [linear] when [bold] is absent.
  Widget Function(BuildContext context, double size, Color color) builderFor(
    DabblerIconWeight weight,
  ) =>
      weight == DabblerIconWeight.bold ? (bold ?? linear) : linear;

  /// Whether this entry actually carries the requested weight.
  bool hasWeight(DabblerIconWeight weight) =>
      weight == DabblerIconWeight.linear || bold != null;
}

/// The result of resolving one sport at one weight.
///
/// Pure data, so the whole AC1 contract is assertable without building a
/// widget.
@immutable
class DabblerSportIconResolution {
  /// Creates a resolution result. Produced by
  /// [DabblerSportIconRegistry.resolve]; exposed as a constructor so a test
  /// can state an expected value literally.
  const DabblerSportIconResolution({
    required this.requestedKey,
    required this.sport,
    required this.weight,
    required this.glyph,
    required this.iconsaxName,
    required this.outcome,
  });

  /// The kebab-case sport string the caller asked for.
  final String requestedKey;

  /// The recognised sport, or null when [outcome] is
  /// [DabblerSportIconOutcome.unknownSport].
  final DabblerSport? sport;

  /// The weight the caller asked for.
  final DabblerIconWeight weight;

  /// The registered glyph, or null when there is none and an Iconsax fallback
  /// is being used.
  final DabblerSportGlyph? glyph;

  /// The kebab-case Iconsax name to draw when [glyph] is null.
  ///
  /// Never null: the fallback path is total, which is what *"nothing ever
  /// renders blank"* means here.
  final String iconsaxName;

  /// Which path the lookup took.
  final DabblerSportIconOutcome outcome;

  /// Whether a commissioned glyph will be drawn rather than a fallback.
  bool get hasGlyph => glyph != null;

  @override
  String toString() => 'DabblerSportIconResolution($requestedKey -> '
      '${hasGlyph ? 'registered glyph' : 'Iconsax "$iconsaxName"'}, '
      '${weight.name}, ${outcome.name})';
}

/// Sport glyph resolution, the documented fallback table, and the registration
/// hook for the commissioned set.
///
/// ## The one documented exception, and what it is not
///
/// `icons-system.card.html` rule 1 is *"Iconsax only, always through
/// `<Icon>`"*. `SportIcon` is one of the two documented exceptions to it —
/// and, as the card says at line 253, *"the only sanctioned custom-icon
/// mechanism in the whole system"*. It is **not** a licence to hand-draw an
/// SVG in a component: this class is the registry that receives a design
/// deliverable, and until that deliverable exists every sport draws an Iconsax
/// glyph through [DabblerIcon] like everything else.
///
/// ## Open blocker — the glyph set does not exist
///
/// `SportIcon.prompt.md` → *BLOCKER* and `icons-system.card.html:157` both
/// record it: the set needs 13 sports × linear/bold = **26 glyphs**, drawn on
/// the Iconsax 24px grid at 1.5px stroke, matching Iconsax's optical weight,
/// under a licence permitting redistribution in the app and this kit. Neither
/// route (commission to spec, or buy and redraw) has been chosen. Owner:
/// design, plus whoever signs the licence.
///
/// Until then [registry] is empty and every sport takes the fallback path,
/// which warns once so the gap stays visible rather than becoming invisible
/// house style.
///
/// ### The standing constraint every screen-builder must obey — D-009
///
/// `DECISIONS.md` **D-009** attaches a rule to this gap, and it binds screens,
/// not this class:
///
/// > **No screen may carry "which sport" in the icon alone.** Sport is also
/// > carried by a label or by the sport background artwork wherever it is the
/// > primary information. A screen that breaks this is an experience defect,
/// > not a missing-asset inconvenience.
///
/// The reason is arithmetic, not taste: four sports collapse onto `game` and
/// five onto `activity`, so the fallback glyph destroys the one thing a sport
/// icon exists to do — distinguish sports. If you are building a screen where
/// sport is the primary information, put a **text label** on it. See also
/// `DabblerSportBackgroundRegistry` (`sport_background.dart`), which carries
/// the same constraint from the artwork side (D-010).
///
/// ### This does NOT end when the licensed set ships — D-022
///
/// The obvious wrong inference is *"we'll turn the sport overlay back on when
/// the icons land"*. **D-022 rules that out in advance**, and it is a
/// durability point, not an interim one. The measured ratios for the sport
/// overlay on `CardEvent`'s covers:
///
/// | Size | Thumb | Well 32 as % width | As % **area** |
/// |---|---|---|---|
/// | Medium | 64 | 50% | 25% |
/// | Small | 48 | 67% | **44%** |
///
/// **A real, licensed glyph at 32-on-48 is still 44% of the cover's area** —
/// *"a replacement of it, not a mark on it"*. The geometry does not improve
/// because the drawing does. So `DabblerCardEventMedium` and
/// `DabblerCardEventSmall` carry no sport overlay **at all**, independent of
/// glyph-set status; the sport overlay belongs to Large's full-bleed 16:9
/// cover only, where 32pt genuinely is a mark in a corner. It reopens only if
/// a **smaller mark** is drawn in the design source — and that is a new node
/// with its own geometry, never an inference from this one.
///
/// ## The premise was verified, not assumed
///
/// The ticket's premise is that *"no sport-specific Iconsax glyph exists"*.
/// That was checked against `iconsax_flutter` 1.0.1 itself rather than taken
/// from the source's prose: of the 2,012 `IconData` constants the package
/// declares, **none** matches any of `football`, `soccer`, `padel`, `tennis`,
/// `basketball`, `volleyball`, `cricket`, `running`, `swimming`, `cycling`,
/// `bicycle`, `badminton`, `golf`, `table-tennis`, `gym`, `dumbbell`, `ball`
/// or `sport` in either weight. The only near hit is `weight` / `weight-1`,
/// which is Iconsax's kitchen-and-parcel scale, not a gym glyph, and
/// substituting it would ship a wrong picture. The premise holds, and the test
/// re-derives this from `Iconsax.items` rather than restating it.
///
/// All three fallback names resolve in **both** weights (`game`, `game_copy`,
/// `activity`, `activity_copy`, `ticket_2`, `ticket_2_copy`), so the fallback
/// path never lands on `DabblerIcon`'s missing-glyph placeholder.
///
/// ## How this composes with DS-300 rather than replacing it
///
/// The two contracts are stacked, not alternatives:
///
/// 1. **This registry** decides *which name* a sport draws — a registered
///    glyph, or the documented Iconsax fallback for that sport.
/// 2. **[DabblerIconRegistry]** then decides *how that name resolves* —
///    requested weight, then bold→linear, then the visible placeholder. That
///    step is untouched here.
///
/// Neither step throws and neither returns an empty [SizedBox].
abstract final class DabblerSportIconRegistry {
  const DabblerSportIconRegistry._();

  /// The documented Iconsax fallback for every sport, transcribed from
  /// `SportIcon.jsx` → `const FALLBACKS` and cross-checked against the
  /// fallback table in `icons-system.card.html:151-153`.
  ///
  /// The source's own rationale, kept verbatim in its three groups:
  ///
  /// * `game` — team/ball games.
  /// * `activity` — body/endurance sports.
  /// * `ticket-2` — racket sports *"that read better as a booked slot"*.
  static const Map<DabblerSport, String> fallbacks = <DabblerSport, String>{
    DabblerSport.football: 'game',
    DabblerSport.basketball: 'game',
    DabblerSport.volleyball: 'game',
    DabblerSport.cricket: 'game',
    DabblerSport.running: 'activity',
    DabblerSport.swimming: 'activity',
    DabblerSport.cycling: 'activity',
    DabblerSport.golf: 'activity',
    DabblerSport.gym: 'activity',
    DabblerSport.padel: 'ticket-2',
    DabblerSport.tennis: 'ticket-2',
    DabblerSport.badminton: 'ticket-2',
    DabblerSport.tableTennis: 'ticket-2',
  };

  /// What an unrecognised sport string draws.
  ///
  /// `SportIcon.jsx`: *"An unknown `sport` warns and renders `game`."*
  static const String unknownSportFallback = 'game';

  static final Map<DabblerSport, DabblerSportGlyph> _registry =
      <DabblerSport, DabblerSportGlyph>{};

  static final Set<String> _warned = <String>{};

  /// Where a one-time warning goes. Defaults to [debugPrint]; a host may point
  /// it at its own logger, and a test replaces it to capture warnings.
  static void Function(String message) warn = debugPrint;

  /// The currently registered glyphs. Unmodifiable — register through
  /// [registerSportIcons].
  static Map<DabblerSport, DabblerSportGlyph> get registry =>
      Map<DabblerSport, DabblerSportGlyph>.unmodifiable(_registry);

  /// The warning keys already emitted, so the "warn once" half of the contract
  /// is assertable. Unmodifiable.
  static Set<String> get warnedKeys => Set<String>.unmodifiable(_warned);

  /// Merges [set] into the registry.
  ///
  /// Mirrors `registerSportIcons(set)`. **Partial registration is fine** — the
  /// source is explicit that registration *"switches off the fallbacks and the
  /// warnings for every sport it covers"* and that unregistered sports keep
  /// falling back. Passing `null` clears the registry, which is what the
  /// source's `registry = set || null` does.
  static void registerSportIcons(Map<DabblerSport, DabblerSportGlyph>? set) {
    if (set == null) {
      _registry.clear();
      return;
    }
    _registry.addAll(set);
  }

  /// Clears the registry and the recorded warnings. Both are process-global,
  /// so tests reset them between cases.
  @visibleForTesting
  static void reset() {
    _registry.clear();
    _warned.clear();
    warn = debugPrint;
  }

  static void _warnOnce(String key, String message) {
    if (!_warned.add(key)) return;
    warn(message);
  }

  /// Resolves a [sport] at [weight].
  ///
  /// Pure apart from the one-time warning, total, and never throws.
  static DabblerSportIconResolution resolve(
    DabblerSport sport, {
    DabblerIconWeight weight = DabblerIconWeight.linear,
  }) {
    final String fallbackName = fallbacks[sport]!;
    final DabblerSportGlyph? glyph = _registry[sport];

    if (glyph != null) {
      return DabblerSportIconResolution(
        requestedKey: sport.key,
        sport: sport,
        weight: weight,
        glyph: glyph,
        iconsaxName: fallbackName,
        outcome: DabblerSportIconOutcome.registered,
      );
    }

    _warnOnce(
      'fallback:${sport.key}',
      '[Dabbler DS] SportIcon "${sport.key}" has no licensed glyph yet — '
      'falling back to Iconsax "$fallbackName". Register the commissioned set '
      'with DabblerSportIconRegistry.registerSportIcons() to resolve every '
      'sport. See SportIcon.prompt.md -> Blocker.',
    );

    return DabblerSportIconResolution(
      requestedKey: sport.key,
      sport: sport,
      weight: weight,
      glyph: null,
      iconsaxName: fallbackName,
      outcome: DabblerSportIconOutcome.fallback,
    );
  }

  /// Resolves a kebab-case sport [key] that came from outside the type system
  /// — a database row, a deep link, an API payload.
  ///
  /// An unrecognised key warns once and resolves to
  /// [unknownSportFallback], which is the source's behaviour. It does not
  /// throw: a stale sport string in production data is a data problem, and
  /// crashing a card is a worse answer than drawing a generic glyph.
  static DabblerSportIconResolution resolveKey(
    String key, {
    DabblerIconWeight weight = DabblerIconWeight.linear,
  }) {
    final DabblerSport? sport = DabblerSport.fromKey(key);
    if (sport != null) return resolve(sport, weight: weight);

    _warnOnce(
      'unknown:$key',
      '[Dabbler DS] SportIcon: unknown sport "$key". Supported: '
      '${kDabblerSports.map((DabblerSport s) => s.key).join(', ')}.',
    );

    return DabblerSportIconResolution(
      requestedKey: key,
      sport: null,
      weight: weight,
      glyph: null,
      iconsaxName: unknownSportFallback,
      outcome: DabblerSportIconOutcome.unknownSport,
    );
  }
}

/// SportIcon — the glyph for one sport.
///
/// Transcribed from `components/foundations/SportIcon.jsx`, `SportIcon.d.ts`,
/// `SportIcon.prompt.md` and the *SportIcon — the documented exception*
/// section of `icons-system.card.html`.
///
/// ## Props map one-to-one onto [DabblerIcon]
///
/// The source says the props are *"the same shape as `Icon`"*: [weight]
/// (`type` on the web) selects linear or bold, [size] defaults to
/// [DabblerSizing.iconMd] (24, the native Iconsax grid), [color] behaves like
/// `currentColor`, and [semanticLabel] (`title`) flips the icon between
/// decorative and labelled.
///
/// ## No chrome of its own
///
/// `SportIcon.prompt.md` → *Visual*: *"No chrome of its own — it is a glyph.
/// Put it in an `IconTile` when it needs a container."* This widget therefore
/// draws no background, no border and no padding beyond its own square box.
///
/// ## RTL
///
/// Sport glyphs are pictograms, *"never mirrored"* in RTL
/// (`icons-system.card.html:177,180`). This widget has no RTL-aware property
/// and never mirrors itself.
///
/// ## Composition rules, from the source
///
/// * One `SportIcon` per sport reference — never paired with an emoji or a
///   Unicode ball character, both banned system-wide.
/// * [DabblerIconWeight.bold] for the selected state of a sport filter,
///   [DabblerIconWeight.linear] otherwise — the same rule as [DabblerIcon].
/// * Never inline a sport image in a screen. A missing glyph belongs in
///   [DabblerSportIconRegistry], not in the screen.
class DabblerSportIcon extends StatelessWidget {
  /// Creates the glyph for a known [sport].
  const DabblerSportIcon(
    this.sport, {
    super.key,
    this.weight = DabblerIconWeight.linear,
    this.size,
    this.color,
    this.semanticLabel,
  }) : sportKey = null;

  /// Creates the glyph for a kebab-case sport string from outside the type
  /// system.
  ///
  /// An unrecognised key warns once and draws the generic `game` glyph rather
  /// than throwing. Prefer the default constructor wherever the sport is known
  /// at compile time.
  const DabblerSportIcon.fromKey(
    String this.sportKey, {
    super.key,
    this.weight = DabblerIconWeight.linear,
    this.size,
    this.color,
    this.semanticLabel,
  }) : sport = null;

  /// The sport to draw, when it is known at compile time.
  final DabblerSport? sport;

  /// The kebab-case sport string, when it came from data.
  final String? sportKey;

  /// `linear` (default) or `bold`. Bold marks a selected sport filter.
  final DabblerIconWeight weight;

  /// The square side in logical pixels. Defaults to [DabblerSizing.iconMd]
  /// (24) — the Iconsax grid the commissioned set will be drawn on.
  final double? size;

  /// The tint. Null inherits the enclosing [IconTheme] the way [DabblerIcon]
  /// does, which is the source's `currentColor`.
  final Color? color;

  /// The accessible label.
  ///
  /// `SportIcon.prompt.md` → *Accessibility*: decorative by default, because
  /// *"the sport name is almost always adjacent as text"*. Pass a label only
  /// when the icon is the sole label, e.g. an icon-only sport filter.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final DabblerSportIconResolution resolution = sport != null
        ? DabblerSportIconRegistry.resolve(sport!, weight: weight)
        : DabblerSportIconRegistry.resolveKey(sportKey!, weight: weight);

    // No registered glyph: hand the documented fallback name to DabblerIcon and
    // let DS-300's contract run unchanged. That is the whole of AC1.
    if (!resolution.hasGlyph) {
      return DabblerIcon(
        resolution.iconsaxName,
        weight: weight,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      );
    }

    final double side = size ?? DabblerSizing.iconMd;
    final Color tint = color ??
        IconTheme.of(context).color ??
        DabblerColors.of(context).textPrimary;

    final Widget box = SizedBox(
      width: side,
      height: side,
      child: Center(
        child: resolution.glyph!.builderFor(weight)(context, side, tint),
      ),
    );

    final String? label = semanticLabel;
    if (label == null) return ExcludeSemantics(child: box);
    return Semantics(label: label, image: true, child: box);
  }
}
