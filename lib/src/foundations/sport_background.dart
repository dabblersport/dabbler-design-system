import 'package:flutter/material.dart';

import 'sports.dart';

/// The two background families a sport can have.
///
/// Transcribed from `components/foundations/SportBackground.jsx` →
/// `export const BACKGROUND_VARIANTS` and `SportBackground.d.ts` →
/// `SportBackgroundVariant`.
enum DabblerSportBackgroundVariant {
  /// `main` — general sport identity. Populated for the eleven sports whose
  /// artwork the bundle ships.
  main,

  /// `matchDay` — match/game-day context. **Structurally anticipated and
  /// entirely unpopulated.**
  ///
  /// `sport-backgrounds.card.html:76` is explicit: *"Do not treat `main` as an
  /// interim Match Day background — requesting `matchDay` today returns
  /// `null`."* Batch 2 registers the real assets through
  /// [DabblerSportBackgroundRegistry.registerSportBackgrounds] without
  /// restructuring anything here.
  matchDay;

  /// The identity string the design source uses as the registry key.
  String get key => this == matchDay ? 'matchDay' : 'main';
}

/// A reference to one piece of sport artwork.
///
/// ## Why a reference and not a bundled image
///
/// The artwork is eleven PNG files in the design bundle
/// (`project/uploads/*.png`), **outside this package**. They are not copied
/// in, and `pubspec.yaml` is not touched: it is shared with every other agent
/// working in this package right now, and adding an `assets:` section to it is
/// a collision, not a change. Nor would it be the right call unilaterally —
/// ~941×1672 editorial illustrations for thirteen sports across two variants
/// is a payload decision (bundle vs. remote vs. CDN) that belongs to `cto` and
/// `cxo`, not to a component ticket.
///
/// So the registry stores a **typed reference the consumer resolves**, which
/// is exactly what the source does: its own registry is *"empty by default —
/// the consuming app registers real deployment paths with
/// `registerSportBackgrounds()`"*, and the specimen card registers paths
/// relative to itself for preview only.
///
/// The one addition here is [defaultMainArtwork]: the eleven canonical
/// *paths* are pre-registered, because AC2 requires `main` to be populated for
/// those eleven. A path is not a binary — nothing is bundled, and an app that
/// ships the files at those paths gets the artwork with no registration call,
/// while an app that ships them elsewhere calls
/// [DabblerSportBackgroundRegistry.registerSportBackgrounds] and overrides
/// them.
@immutable
class DabblerSportArtwork {
  /// References an image asset at [assetPath], optionally owned by [package].
  const DabblerSportArtwork.asset(this.assetPath, {this.package});

  /// The asset key, as it would appear in a `pubspec.yaml` `assets:` list.
  final String assetPath;

  /// The package that owns the asset, or null when the consuming app does.
  ///
  /// Null for every entry in [DabblerSportBackgroundRegistry.defaultMainArtwork]:
  /// this package ships no artwork, so the app owns it.
  final String? package;

  /// The image provider for this reference.
  ImageProvider<Object> get image =>
      AssetImage(assetPath, package: package);

  @override
  bool operator ==(Object other) =>
      other is DabblerSportArtwork &&
      other.assetPath == assetPath &&
      other.package == package;

  @override
  int get hashCode => Object.hash(assetPath, package);

  @override
  String toString() => 'DabblerSportArtwork.asset($assetPath'
      '${package == null ? '' : ', package: $package'})';
}

/// Sport + variant → artwork, and the registration hook Batch 2 will use.
///
/// Transcribed from `components/foundations/SportBackground.jsx` and
/// `sport-backgrounds.card.html`.
///
/// ## The whole of AC2, in one sentence
///
/// A lookup returns the artwork if it is registered and **`null` if it is
/// not** — for `golf`, for `table-tennis`, and for every one of the thirteen
/// sports at [DabblerSportBackgroundVariant.matchDay]. It never substitutes
/// another sport's artwork, never substitutes another variant's, and **never
/// throws**.
///
/// An unpopulated sport/variant is a **normal case**, not an error. That is
/// why the miss path is a `null` return and a one-time warning rather than an
/// exception or an assert: the product is expected to run today with two
/// sports missing their `main` art and a whole variant missing entirely, and a
/// screen that asks for `matchDay` must render, without art, rather than fail.
///
/// ## What is populated, and how that was established
///
/// `main` is registered for the eleven sports the bundle ships artwork for:
/// football, padel, tennis, basketball, volleyball, cricket, running,
/// swimming, cycling, badminton, gym. That list comes from two agreeing
/// sources — the `MAIN_SRC` map in `sport-backgrounds.card.html:31-41`, and
/// the eleven PNG files actually present in `project/uploads/`
/// (`Football.png`, `Padel.png`, `Tennis.png`, `Basketball.png`,
/// `Vollyball.png` [sic], `Cricket.png`, `Running.png`, `Swimming.png`,
/// `Cycling.png`, `Badminton.png`, `Gym.png`). The card's own
/// `MAIN_MISSING = ['golf','table-tennis']` states the complement.
///
/// The asset paths follow the card's `MAIN_SRC` naming —
/// `assets/images/sports/<sport>-main-background.png` — not the bundle's
/// upload filenames, which are capitalised, inconsistent (`Vollyball.png`) and
/// an artefact of how the files were uploaded rather than a deployment
/// convention.
///
/// ## Composition — never treat this artwork
///
/// `sport-backgrounds.card.html:71`: the art is ~941×1672 (9:16) editorial
/// illustration with *"a deliberate quiet zone for overlaid content"*, and
/// *"never scrim, blur, darken or fade this artwork — text-legibility
/// treatment, if needed, belongs to the consuming screen"*. [DabblerSportBackground]
/// therefore applies no scrim, no gradient and no filter, which is also what
/// the flat-system house rule requires.
abstract final class DabblerSportBackgroundRegistry {
  const DabblerSportBackgroundRegistry._();

  /// The directory the canonical asset paths sit in, per
  /// `sport-backgrounds.card.html`'s `MAIN_SRC`.
  static const String assetDirectory = 'assets/images/sports';

  /// The eleven sports whose `main` artwork the bundle ships, in `SPORTS`
  /// order.
  ///
  /// Documentation and a test fixture. [resolve] does not consult it; it reads
  /// [defaultMainArtwork] like any other registration.
  static const List<DabblerSport> mainPopulated = <DabblerSport>[
    DabblerSport.football,
    DabblerSport.padel,
    DabblerSport.tennis,
    DabblerSport.basketball,
    DabblerSport.volleyball,
    DabblerSport.cricket,
    DabblerSport.running,
    DabblerSport.swimming,
    DabblerSport.cycling,
    DabblerSport.badminton,
    DabblerSport.gym,
  ];

  /// The two sports with no `main` artwork — the card's `MAIN_MISSING`.
  static const List<DabblerSport> mainUnpopulated = <DabblerSport>[
    DabblerSport.golf,
    DabblerSport.tableTennis,
  ];

  /// The canonical `main` asset paths, transcribed from `MAIN_SRC`
  /// (`sport-backgrounds.card.html:31-41`).
  static const Map<DabblerSport, DabblerSportArtwork> defaultMainArtwork =
      <DabblerSport, DabblerSportArtwork>{
    DabblerSport.football:
        DabblerSportArtwork.asset('$assetDirectory/football-main-background.png'),
    DabblerSport.padel:
        DabblerSportArtwork.asset('$assetDirectory/padel-main-background.png'),
    DabblerSport.tennis:
        DabblerSportArtwork.asset('$assetDirectory/tennis-main-background.png'),
    DabblerSport.basketball: DabblerSportArtwork.asset(
        '$assetDirectory/basketball-main-background.png'),
    DabblerSport.volleyball: DabblerSportArtwork.asset(
        '$assetDirectory/volleyball-main-background.png'),
    DabblerSport.cricket:
        DabblerSportArtwork.asset('$assetDirectory/cricket-main-background.png'),
    DabblerSport.running:
        DabblerSportArtwork.asset('$assetDirectory/running-main-background.png'),
    DabblerSport.swimming: DabblerSportArtwork.asset(
        '$assetDirectory/swimming-main-background.png'),
    DabblerSport.cycling:
        DabblerSportArtwork.asset('$assetDirectory/cycling-main-background.png'),
    DabblerSport.badminton: DabblerSportArtwork.asset(
        '$assetDirectory/badminton-main-background.png'),
    DabblerSport.gym:
        DabblerSportArtwork.asset('$assetDirectory/gym-main-background.png'),
  };

  static final Map<DabblerSport, Map<DabblerSportBackgroundVariant,
      DabblerSportArtwork>> _registry = _seed();

  static Map<DabblerSport,
      Map<DabblerSportBackgroundVariant, DabblerSportArtwork>> _seed() {
    return <DabblerSport,
        Map<DabblerSportBackgroundVariant, DabblerSportArtwork>>{
      for (final MapEntry<DabblerSport, DabblerSportArtwork> entry
          in defaultMainArtwork.entries)
        entry.key: <DabblerSportBackgroundVariant, DabblerSportArtwork>{
          DabblerSportBackgroundVariant.main: entry.value,
        },
    };
  }

  static final Set<String> _warned = <String>{};

  /// Where a one-time warning goes. Defaults to [debugPrint]; a test replaces
  /// it to capture warnings.
  static void Function(String message) warn = debugPrint;

  /// The warning keys already emitted, so "warn once" is assertable.
  static Set<String> get warnedKeys => Set<String>.unmodifiable(_warned);

  /// Merges [set] into the registry, per sport and per variant.
  ///
  /// Mirrors `registerSportBackgrounds(set)`, including its merge semantics:
  /// a sport's existing variants are kept and only the supplied ones are
  /// overwritten, so Batch 2 can register `matchDay` for every sport without
  /// disturbing `main`. A null or empty [set] is a no-op, as in the source.
  static void registerSportBackgrounds(
    Map<DabblerSport,
            Map<DabblerSportBackgroundVariant, DabblerSportArtwork>>?
        set,
  ) {
    if (set == null) return;
    set.forEach((DabblerSport sport,
        Map<DabblerSportBackgroundVariant, DabblerSportArtwork> variants) {
      (_registry[sport] ??=
              <DabblerSportBackgroundVariant, DabblerSportArtwork>{})
          .addAll(variants);
    });
  }

  /// Restores the registry to the eleven canonical `main` entries and clears
  /// the recorded warnings. Both are process-global, so tests reset them
  /// between cases.
  @visibleForTesting
  static void reset() {
    _registry
      ..clear()
      ..addAll(_seed());
    _warned.clear();
    warn = debugPrint;
  }

  /// The artwork registered for [sport] at [variant], or `null` if there is
  /// none.
  ///
  /// Total. Never throws, and never substitutes: a `matchDay` miss does not
  /// fall back to `main`, and a `golf` miss does not fall back to another
  /// sport. The first miss for a given sport/variant pair warns once.
  static DabblerSportArtwork? resolve(
    DabblerSport sport, {
    DabblerSportBackgroundVariant variant = DabblerSportBackgroundVariant.main,
  }) {
    final DabblerSportArtwork? artwork = _registry[sport]?[variant];
    if (artwork != null) return artwork;

    final String key = '${sport.key}:${variant.key}';
    if (_warned.add(key)) {
      warn(
        '[Dabbler DS] SportBackground: no "${variant.key}" artwork registered '
        'for "${sport.key}" yet. Register it with '
        'DabblerSportBackgroundRegistry.registerSportBackgrounds(). Does not '
        'fall back to another variant.',
      );
    }
    return null;
  }

  /// The artwork for a kebab-case sport [key] from outside the type system.
  ///
  /// An unrecognised key returns `null` — the same answer as a recognised
  /// sport with no artwork, because the caller's handling is identical and
  /// neither is an error.
  static DabblerSportArtwork? resolveKey(
    String key, {
    DabblerSportBackgroundVariant variant = DabblerSportBackgroundVariant.main,
  }) {
    final DabblerSport? sport = DabblerSport.fromKey(key);
    if (sport == null) return null;
    return resolve(sport, variant: variant);
  }
}

/// SportBackground — canonical full-bleed sport artwork.
///
/// Transcribed from `components/foundations/SportBackground.jsx`,
/// `SportBackground.d.ts` and `components/foundations/sport-backgrounds.card.html`.
///
/// ## The null contract, in a widget world
///
/// The source component *returns `null`* when nothing is registered. A Flutter
/// `build` cannot return null, so the contract is expressed twice:
///
/// * [DabblerSportBackground.maybe] returns `Widget?` — a real `null` a caller
///   can branch on. **Prefer it**, because a screen that wants a fallback
///   surface behind its content needs to know the art is absent.
/// * The widget itself renders `const SizedBox.shrink()` on a miss. This is
///   the faithful analogue of the source returning null, and it is *not* the
///   empty-`SizedBox` failure `DabblerIcon` forbids: a background has no
///   intrinsic size and is always laid out by its parent (a [Stack] fill, a
///   sized box, an aspect ratio), so an absent background collapses nothing.
///   An icon is the opposite — it *is* its own box — which is why the two
///   primitives resolve absence differently.
///
/// Neither path throws.
///
/// ## Never treat the artwork
///
/// No scrim, blur, darken or fade — the card forbids all four, and the quiet
/// zone for overlaid content is composed into the illustration itself. Text
/// legibility is the consuming screen's job.
///
/// ## Accessibility
///
/// Decorative by default, matching the source's `aria-hidden` default. Pass
/// [semanticLabel] only where the image genuinely carries meaning.
///
/// ## RTL
///
/// The artwork is an illustration, not a directional affordance, and is never
/// mirrored — the same rule `SportIcon` states for pictograms. [alignment] is
/// therefore an [Alignment] and not an [AlignmentDirectional]: mirroring the
/// crop of a photograph by locale would move the quiet zone out from under the
/// content it was drawn for.
class DabblerSportBackground extends StatelessWidget {
  /// Creates the background for [sport].
  const DabblerSportBackground(
    this.sport, {
    super.key,
    this.variant = DabblerSportBackgroundVariant.main,
    this.artwork,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
  });

  /// The sport whose artwork to draw.
  final DabblerSport sport;

  /// Which family to draw. Defaults to [DabblerSportBackgroundVariant.main];
  /// [DabblerSportBackgroundVariant.matchDay] is unpopulated and renders
  /// nothing today.
  final DabblerSportBackgroundVariant variant;

  /// An explicit artwork reference, overriding the registry for this instance.
  ///
  /// The source's `src` prop, which the specimen card uses to preview assets
  /// it has not registered globally.
  final DabblerSportArtwork? artwork;

  /// How the image fills its container. Defaults to [BoxFit.cover], the
  /// source's `object-fit: cover`.
  final BoxFit fit;

  /// The crop anchor. Defaults to [Alignment.center], the source's
  /// `object-position: center`. Deliberately not direction-aware — see the
  /// class doc.
  final Alignment alignment;

  /// The accessible label. Null means decorative, and the image is hidden from
  /// assistive technology.
  final String? semanticLabel;

  /// The widget for [sport] at [variant], or `null` when no artwork is
  /// registered.
  ///
  /// The direct analogue of the source component returning `null`, for callers
  /// that need to know rather than to render nothing.
  static Widget? maybe(
    DabblerSport sport, {
    Key? key,
    DabblerSportBackgroundVariant variant = DabblerSportBackgroundVariant.main,
    DabblerSportArtwork? artwork,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
    String? semanticLabel,
  }) {
    final DabblerSportArtwork? resolved = artwork ??
        DabblerSportBackgroundRegistry.resolve(sport, variant: variant);
    if (resolved == null) return null;
    return DabblerSportBackground(
      sport,
      key: key,
      variant: variant,
      artwork: resolved,
      fit: fit,
      alignment: alignment,
      semanticLabel: semanticLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final DabblerSportArtwork? resolved = artwork ??
        DabblerSportBackgroundRegistry.resolve(sport, variant: variant);

    // An unpopulated sport/variant is a normal case: nothing is drawn, nothing
    // is substituted, nothing throws.
    if (resolved == null) return const SizedBox.shrink();

    final Widget image = Image(
      image: resolved.image,
      fit: fit,
      alignment: alignment,
      excludeFromSemantics: true,
    );

    final String? label = semanticLabel;
    if (label == null) return ExcludeSemantics(child: image);
    return Semantics(label: label, image: true, child: image);
  }
}
