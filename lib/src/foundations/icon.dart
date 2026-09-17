import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';

/// The two icon weights the product uses, transcribed from the design source
/// `components/foundations/Icon.d.ts` and the *Weights* table in
/// `components/foundations/icons-system.card.html`.
///
/// Iconsax also ships `outline`, `broken`, `bulk` and `twotone`. The card is
/// explicit that **the app uses only linear and bold**, and that this system
/// deliberately does not expose the other four, *"because nothing in the
/// product consumes them"* — so this enum has two values and not six.
enum DabblerIconWeight {
  /// `linear` — the default weight. `Iconsax.<name>`.
  linear,

  /// `bold` — the filled variant, `Iconsax.<name>_copy`.
  ///
  /// The card reserves it for **active tabs and primary actions**; everything
  /// else is [linear].
  bold,
}

/// How [DabblerIconRegistry.resolve] arrived at what it returned.
///
/// The observable half of the AC2 contract: a caller — or a test — can ask
/// which of the three paths a name took without reading pixels.
enum DabblerIconOutcome {
  /// The name resolved at the weight that was asked for.
  resolved,

  /// The name exists, but not in the requested weight, so the other weight was
  /// drawn. Only ever bold → linear; see [DabblerIconRegistry].
  ///
  /// Of the 1,988 keys `iconsax_flutter` declares, **16 named glyphs have a
  /// linear weight and no `_copy` bold** (plus 24 unnamed `uniXXXX` codepoint
  /// leftovers) — `refresh-2`, the one T-083 names, plus
  /// `arrow-right-4`, `arrow-square-right`, `bootsrap`, `bootstrap`,
  /// `celsius-cel`, `document-copy1`, `drop`, `google-1`, `google-drive`,
  /// `google-paly`, `google-play`, `import-3`, `notification-circle`,
  /// `shield` and `shield-security`. Measured from `Iconsax.items`, and the
  /// test re-derives the count rather than restating it.
  ///
  /// The right glyph in the wrong weight is closer to the design than a
  /// placeholder, so this is preferred over [missing].
  weightFallback,

  /// The name is not in Iconsax under either weight — a typo, or a glyph the
  /// set does not draw. [DabblerIcon] renders the visible placeholder and
  /// raises a debug-only report.
  missing,
}

/// The result of resolving one icon name at one weight.
///
/// [DabblerIconRegistry.resolve] is a pure function, so the whole fallback
/// contract is testable without building a widget.
@immutable
class DabblerIconResolution {
  /// Creates a resolution result. Produced by [DabblerIconRegistry.resolve];
  /// exposed as a constructor so a test can state an expected value literally.
  const DabblerIconResolution({
    required this.requestedName,
    required this.resolvedKey,
    required this.requestedWeight,
    required this.resolvedWeight,
    required this.glyph,
    required this.outcome,
  });

  /// The kebab-case name the caller asked for, e.g. `search-normal`.
  final String requestedName;

  /// The `Iconsax.items` key that was actually drawn, e.g. `search_normal` or
  /// `search_normal_copy`. Null when [outcome] is [DabblerIconOutcome.missing].
  final String? resolvedKey;

  /// The weight the caller asked for.
  final DabblerIconWeight requestedWeight;

  /// The weight actually drawn. Differs from [requestedWeight] exactly when
  /// [outcome] is [DabblerIconOutcome.weightFallback].
  final DabblerIconWeight resolvedWeight;

  /// The glyph to draw, or null when [outcome] is [DabblerIconOutcome.missing].
  final IconData? glyph;

  /// Which path the lookup took.
  final DabblerIconOutcome outcome;

  /// Whether a glyph is available to draw.
  bool get hasGlyph => glyph != null;

  @override
  String toString() => 'DabblerIconResolution($requestedName -> $resolvedKey, '
      '${resolvedWeight.name}, ${outcome.name})';
}

/// Name resolution and the missing-glyph contract — **designed once, here, for
/// every component**.
///
/// ## What this is, and what it deliberately is not
///
/// The design source's `components/foundations/Icon.jsx` carries a
/// `PRO_FALLBACKS` table that substitutes a free glyph for the plain `arrow-*`
/// family, `more-2`, `refresh`, `logout` and `login`, because those render as
/// an empty box on the free Iconsax **web CDN** tier.
///
/// **That table is not ported, and must not be.** `cto` verified the Flutter
/// package rather than the source's prompt file (`DECISIONS.md` T-083):
/// `iconsax_flutter` declares 1,988 glyphs, and every name the web source
/// calls Pro-gated is present in **both** weights — `arrow-right`,
/// `arrow-left`, `arrow-up`, `arrow-down`, the `-1`/`-2`/`-3` variants,
/// `more-2`, `refresh`, `logout` and `login`. The blank box is an artefact of
/// the CDN's licensing tier and **cannot occur here**. Substituting
/// `arrow-circle-right` where the design asked for `arrow-right` would ship a
/// wrong glyph to fix a condition that does not exist; T-083 names that a
/// defect. There is therefore no substitution table, no licence key and no
/// `registerPro` hook in this package.
///
/// ## What the fallback contract does cover
///
/// The contract survives with its cause restated. It exists for an unknown
/// name, a typo, and a real gap in the glyph set.
///
/// ## Resolution order
///
/// For a kebab-case `name` at a `weight`, first hit wins:
///
/// 1. **The requested weight.** `linear` looks up `<snake_name>`; `bold` looks
///    up `<snake_name>_copy`. A hit is [DabblerIconOutcome.resolved].
/// 2. **The other weight — bold falls back to linear before it falls back to
///    the placeholder.** A `bold` request whose `_copy` is absent draws the
///    linear glyph: [DabblerIconOutcome.weightFallback], warned once. There
///    are 16 such named glyphs, listed on
///    [DabblerIconOutcome.weightFallback].
///
///    A `linear` request never falls back to bold — linear is the app's
///    default weight, and a filled glyph standing in for an outline one is a
///    visible style error, whereas the reverse is a near-miss. Seven keys are
///    bold-only (`video-slash`, `hex-hex`, `icon-another`, `mini-music-sqaure`,
///    `triangle-3rd`, `triangle-another`, `celsius-cel-`); asked for at
///    `linear` they go to the placeholder, deliberately.
/// 3. **Missing.** The name is not in Iconsax under either weight:
///    [DabblerIconOutcome.missing], warned once, reported in debug, and
///    [DabblerIcon] draws a visible neutral placeholder at the requested size
///    and colour.
///
/// Step 3 is total. **No path throws, and no path returns an empty
/// [SizedBox]** — a zero-size blank collapses the surrounding layout and is
/// precisely the failure mode that survives a review unnoticed.
///
/// ## Why a debug report and not an `assert`
///
/// T-083 asks for a debug assertion on a missing glyph *and* for the frame to
/// render anyway. Those two cannot both be served by `assert`: an `assert`
/// reached from [State.build] throws, the subtree fails to build, and what the
/// developer gets is the collapsed layout the same ruling forbids. So the
/// debug signal is [FlutterError.reportError] raised by [DabblerIcon], which is
/// just as loud in debug — red ink in the console, a red error box in the
/// inspector — costs nothing in release, and leaves the placeholder on screen.
/// [resolve] itself stays pure and total, so it is safe to call from a build
/// method, a test, or a gallery.
abstract final class DabblerIconRegistry {
  const DabblerIconRegistry._();

  /// The app's core icon vocabulary, transcribed from `Icon.prompt.md` →
  /// *"The app's vocabulary"*, in source order.
  ///
  /// Documentation and a test fixture, not a gate: [resolve] never consults it,
  /// and a name outside this list resolves like any other.
  static const List<String> vocabulary = <String>[
    'home-2', 'search-normal', 'add', 'add-circle', 'user', 'profile-circle',
    'people', 'notification', 'notification-bing', 'setting-2', 'calendar',
    'location', 'game', 'ticket-2', 'cup', 'activity', 'clock', 'star',
    'heart', 'sms', 'call', 'filter', 'tick-circle', 'danger', 'warning-2',
    'info-circle', 'eye', 'eye-slash', 'lock', 'edit', 'trash', 'gallery',
    'camera', 'video', 'play', 'share', 'microphone-2', 'more', 'menu',
    'close-circle',
  ];

  /// The names the web design source treats as Pro-gated, kept **only** so a
  /// test can prove T-083's finding: every one of them is present in this
  /// package in both weights, which is why no substitution table exists.
  ///
  /// Nothing in [resolve] reads this list.
  static const List<String> webProGatedNames = <String>[
    'arrow-right', 'arrow-right-1', 'arrow-right-2', 'arrow-right-3',
    'arrow-left', 'arrow-left-1', 'arrow-left-2', 'arrow-left-3',
    'arrow-down', 'arrow-down-1', 'arrow-down-2',
    'arrow-up', 'arrow-up-1', 'arrow-up-2',
    'more-2', 'refresh', 'refresh-2', 'logout', 'login',
  ];

  /// The suffix `iconsax_flutter` gives the bold variant of every glyph.
  static const String boldSuffix = '_copy';

  static final Set<String> _warned = <String>{};

  /// Where a one-time warning goes. Defaults to [debugPrint]; a host may point
  /// it at its own logger, and a test replaces it to capture warnings.
  static void Function(String message) warn = debugPrint;

  /// The names that have already warned, so the "warn once" half of the
  /// contract is assertable. Unmodifiable.
  static Set<String> get warnedNames => Set<String>.unmodifiable(_warned);

  /// Clears the recorded warnings. The set is process-global, so tests reset
  /// it between cases.
  @visibleForTesting
  static void reset() {
    _warned.clear();
    warn = debugPrint;
  }

  /// The `Iconsax.items` key for a kebab-case [name] at [weight].
  ///
  /// The mapping the design source itself states: `linear` → `Iconsax.<name>`,
  /// `bold` → `Iconsax.<name>_copy`, with `-` becoming `_`.
  static String keyFor(String name, DabblerIconWeight weight) {
    final String snake = name.replaceAll('-', '_');
    return weight == DabblerIconWeight.bold ? '$snake$boldSuffix' : snake;
  }

  static void _warnOnce(String key, String message) {
    if (!_warned.add(key)) return;
    warn(message);
  }

  /// Resolves [name] at [weight] through the three steps in the class doc.
  ///
  /// Pure, total, and never throws.
  static DabblerIconResolution resolve(
    String name, {
    DabblerIconWeight weight = DabblerIconWeight.linear,
  }) {
    // 1 — the weight that was asked for.
    final IconData? exact = Iconsax.items[keyFor(name, weight)];
    if (exact != null) {
      return DabblerIconResolution(
        requestedName: name,
        resolvedKey: keyFor(name, weight),
        requestedWeight: weight,
        resolvedWeight: weight,
        glyph: exact,
        outcome: DabblerIconOutcome.resolved,
      );
    }

    // 2 — bold falls back to linear before it falls back to the placeholder.
    if (weight == DabblerIconWeight.bold) {
      final String linearKey = keyFor(name, DabblerIconWeight.linear);
      final IconData? linear = Iconsax.items[linearKey];
      if (linear != null) {
        _warnOnce(
          'weight:$name',
          '[Dabbler DS] Icon "$name" has no bold weight in iconsax_flutter '
          '("$linearKey$boldSuffix" is not declared) — drawing the linear '
          'glyph instead. The right glyph in the wrong weight is closer to the '
          'design than a placeholder.',
        );
        return DabblerIconResolution(
          requestedName: name,
          resolvedKey: linearKey,
          requestedWeight: weight,
          resolvedWeight: DabblerIconWeight.linear,
          glyph: linear,
          outcome: DabblerIconOutcome.weightFallback,
        );
      }
    }

    // 3 — not in Iconsax under either weight. Visible placeholder, never blank,
    // never a throw.
    _warnOnce(
      'missing:$name',
      '[Dabbler DS] Icon "$name" is not an Iconsax glyph — no '
      '"${keyFor(name, DabblerIconWeight.linear)}" in iconsax_flutter. '
      'Rendering the missing-glyph placeholder. Check the kebab-case name '
      'against app.iconsax.io.',
    );
    return DabblerIconResolution(
      requestedName: name,
      resolvedKey: null,
      requestedWeight: weight,
      resolvedWeight: weight,
      glyph: null,
      outcome: DabblerIconOutcome.missing,
    );
  }
}

/// Icon — the design system's single icon primitive.
///
/// Transcribed from `components/foundations/Icon.jsx`, `Icon.d.ts`,
/// `Icon.prompt.md` and the *Icon — the primitive* / *Sizes* / *States*
/// sections of `icons-system.card.html`.
///
/// ## Governance
///
/// The card's first rule: *"Iconsax is the only icon source. No emoji, no
/// Unicode glyphs, no hand-drawn SVG — anywhere, for any reason."* Every icon
/// in this system goes through this widget. The two documented exceptions —
/// `SportIcon` and the reaction glyph set — are separate tickets and are still
/// rendered through this primitive.
///
/// ## Names, weights, sizes
///
/// [name] is the kebab-case Iconsax name exactly as shown at app.iconsax.io
/// (`home-2`, `search-normal`, `tick-circle`); it is resolved internally to
/// `Iconsax.<name>` for [DabblerIconWeight.linear] and `Iconsax.<name>_copy`
/// for [DabblerIconWeight.bold], which is the mapping the source states.
/// Bold is for active tabs and primary actions. [size] defaults to
/// [DabblerSizing.iconMd] (24) — *"the native Iconsax grid, and `Icon`'s own
/// default"* — with [DabblerSizing.iconSm] (18) and [DabblerSizing.iconLg] (30)
/// the other two documented steps.
///
/// **Always pass the name the design asks for.** Never substitute a stand-in at
/// the call site: `Icon.prompt.md` forbids it, and there is nothing to work
/// around — see [DabblerIconRegistry] on why the web source's Pro substitution
/// table is deliberately not ported.
///
/// ## Colour behaves like `currentColor`
///
/// The source's default is `currentColor` — the icon inherits tint the way text
/// does. Flutter's equivalent is [IconTheme], so [color] falls back to
/// `IconTheme.of(context).color` and only then to [DabblerColors.textPrimary].
///
/// ## No state props, by design
///
/// The card's *States* table is explicit: `disabled`, `focused` and `pressed`
/// are **container-level** concerns — the interactive wrapper owns the focus
/// ring and the press treatment, not the glyph. This widget therefore composes
/// neither `DabblerFocusRing` nor `DabblerPressScale`; the only icon-level
/// state is active/inactive, expressed by swapping [weight] and/or [color].
///
/// ## Accessibility
///
/// The source flips on the presence of a label: with `title` the element is
/// `role="img"` with an `aria-label`; without it, `aria-hidden="true"`. That
/// maps to [Semantics] with a label versus [ExcludeSemantics], which is what
/// [semanticLabel] selects between.
///
/// ## RTL
///
/// The card is explicit that direction is handled by *"selecting the mirrored
/// glyph name (`arrow-circle-right` ↔ `-left`), not a CSS transform on the
/// SVG"*, and that no icon-specific RTL prop exists anywhere in the system.
/// This widget has none and never mirrors itself; the caller picks the name and
/// the surrounding layout does the rest with logical padding.
class DabblerIcon extends StatelessWidget {
  /// Creates an icon for the kebab-case Iconsax [name].
  ///
  /// A name Iconsax does not carry is **not** an exception: it asserts in debug
  /// and draws the visible placeholder. See [DabblerIconRegistry].
  const DabblerIcon(
    this.name, {
    super.key,
    this.weight = DabblerIconWeight.linear,
    this.size,
    this.color,
    this.semanticLabel,
  });

  /// The kebab-case Iconsax name, exactly as at app.iconsax.io.
  final String name;

  /// `linear` (default) or `bold`. Bold is for active tabs and primary actions.
  final DabblerIconWeight weight;

  /// The square side in logical pixels. Defaults to [DabblerSizing.iconMd] (24).
  ///
  /// The documented steps are [DabblerSizing.iconSm] (18),
  /// [DabblerSizing.iconMd] (24) and [DabblerSizing.iconLg] (30).
  final double? size;

  /// The tint. Null inherits from the enclosing [IconTheme], then falls back to
  /// [DabblerColors.textPrimary] — the `currentColor` behaviour of the source.
  final Color? color;

  /// The accessible label. Null means decorative, and the icon is hidden from
  /// assistive technology entirely.
  final String? semanticLabel;

  /// The placeholder's inset relative to the icon box, as a fraction of the
  /// side.
  ///
  /// Not a design-source value — the source has no placeholder, because on the
  /// web a missing glyph is an empty element of the right size. The inset
  /// inscribes the mark inside the icon's own square so a missing glyph
  /// occupies exactly the space the real one would.
  static const double placeholderInset = 0.125;

  /// Raises the missing-glyph diagnostic in debug only.
  ///
  /// See [DabblerIconRegistry] → *Why a debug report and not an `assert`*.
  static void _reportMissingInDebug(DabblerIconResolution resolution) {
    assert(() {
      FlutterError.reportError(FlutterErrorDetails(
        exception: FlutterError(
          'DabblerIcon: "${resolution.requestedName}" is not an Iconsax glyph.',
        ),
        library: 'dabbler design system',
        context: ErrorDescription(
          'building a DabblerIcon. Names are kebab-case exactly as at '
          'app.iconsax.io (e.g. "search-normal", "home-2"). A visible '
          'placeholder is rendered at the requested size rather than failing '
          'the frame.',
        ),
      ));
      return true;
    }());
  }

  @override
  Widget build(BuildContext context) {
    final double side = size ?? DabblerSizing.iconMd;
    final DabblerIconResolution resolution =
        DabblerIconRegistry.resolve(name, weight: weight);
    final Color tint = color ??
        IconTheme.of(context).color ??
        DabblerColors.of(context).textPrimary;

    // Both branches fill the same box: the placeholder is a drawn mark at the
    // requested size and colour, never an empty SizedBox, so a missing glyph
    // cannot collapse the layout around it.
    if (resolution.outcome == DabblerIconOutcome.missing) {
      _reportMissingInDebug(resolution);
    }

    final Widget glyph = resolution.hasGlyph
        ? Icon(resolution.glyph, size: side, color: tint)
        : _MissingGlyph(side: side, color: tint);

    final Widget box = SizedBox(
      width: side,
      height: side,
      child: Center(child: glyph),
    );

    final String? label = semanticLabel;
    if (label == null) {
      return ExcludeSemantics(child: box);
    }
    return Semantics(label: label, image: true, child: box);
  }
}

/// The visible missing-glyph mark.
///
/// The contract's *"returns a visible fallback; never throws; never an empty
/// `SizedBox`"* made literal: a hairline rounded square with one diagonal,
/// drawn in the icon's own tint at the icon's own size.
///
/// Deliberately **not** a question mark or a warning triangle — those are real
/// glyphs in the vocabulary (`info-circle`, `warning-2`) and would read as
/// content rather than as absent artwork.
class _MissingGlyph extends StatelessWidget {
  const _MissingGlyph({required this.side, required this.color});

  final double side;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double inset = side * DabblerIcon.placeholderInset;
    return SizedBox(
      width: side,
      height: side,
      child: Padding(
        padding: EdgeInsets.all(inset),
        child: CustomPaint(painter: _MissingGlyphPainter(color: color)),
      ),
    );
  }
}

/// Paints the missing-glyph mark: a rounded hairline box plus one diagonal.
class _MissingGlyphPainter extends CustomPainter {
  const _MissingGlyphPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = DabblerSizing.borderDefault
      ..color = color;
    final RRect frame = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(DabblerRadius.sm),
    );
    canvas.drawRRect(frame, stroke);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), stroke);
  }

  @override
  bool shouldRepaint(_MissingGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}
