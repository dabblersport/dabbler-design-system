import 'package:flutter/widgets.dart';

import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';

/// The five shells the design source draws its nine content-specific cards on.
///
/// Transcribed from the `VARIANTS` table at the head of
/// `components/cards/Card.jsx`, whose own comment states why there are exactly
/// five: *"The Figma kit draws its 9 content-specific cards (Event, Room,
/// Active-Room, House, Poll, Pricing) on five distinct shells; those five are
/// the variants here."*
enum DabblerCardVariant {
  /// `background: var(--surface-sunken)`, no border — the kit's neutral-200
  /// shell and the default. `CardHouse`, `CardEventLarge/Medium/Small`,
  /// `CardRoom`, `CardActiveRoom` and `CardPoll` are all drawn on this one.
  standard,

  /// `var(--surface-sunken)` with a 1px `--outline-card` hairline.
  outlined,

  /// `var(--surface-card)` with a 1px `--outline-card` hairline — the white
  /// shell `EmptyState` (`size: 'inline'`) and the panel cards use.
  white,

  /// **The chosen plan.** `var(--surface-card)` with a **2px**
  /// `--color-brand-primary` border — drawn by the kit's `CardPricingDefault`,
  /// whose Figma dump writes the same border out as four
  /// `2px solid var(--purple-600)` edges, and which paints the filled brand
  /// disc with a tick.
  ///
  /// Named by what it draws, not by the kit's symbol name, per `cxo` ruling
  /// **D-019**: the kit's two pricing symbols are inverted, `Default` painting
  /// the selected state and `Selected` the unselected one. This value was
  /// called `pricing` until D-019. Do not "fix" it back.
  pricingSelected,

  /// **Every other plan.** `var(--surface-sunken)` with a 2px `--outline-card`
  /// border — drawn by the kit's `CardPricingSelected`, which paints an empty
  /// grey ring.
  ///
  /// Named by what it draws, per **D-019**. This value was called
  /// `pricingSelected` until D-019, which is the inverted reading.
  pricingUnselected,
}

/// Card — the shared card chrome every `CardXxx` in the system composes.
///
/// Transcribed from `components/cards/Card.jsx`, its `Card.d.ts` and
/// `Card.prompt.md`: *"the merged card shell — five variants, one per distinct
/// shell the kit draws its nine content cards on."*
///
/// ```dart
/// DabblerCard(
///   onTap: () {},
///   header: const Text('Sunday five-a-side'),
///   child: const Text('Al Barsha · 18:00'),
/// )
/// ```
///
/// ## What this component owns, and what the variants own
///
/// A `CardXxx` ticket should supply **content**, never chrome. Everything in
/// the list below is settled here once, so that seven later tickets cannot
/// each re-derive it and drift:
///
/// * the fill, the border colour and the border **width** of all five shells
///   ([fillOf], [borderOf], [borderWidthOf]);
/// * the corner radius ([defaultRadius]);
/// * the inner padding ([defaultPadding]) and the fact that [media] sits
///   *outside* it;
/// * the press and focus affordances of a tappable card;
/// * the vertical rhythm between the slots ([gap]).
///
/// The four slots, top to bottom:
///
/// | Slot | Padded | What the variants put in it |
/// |---|---|---|
/// | [media] | **no** — full-bleed to the radius | `CardTicket`'s coloured header strip; an event cover image |
/// | [header] | yes | a title row, a leading icon well beside a title |
/// | [child] | yes | the body — the card's substance |
/// | [footer] | yes | a price beside its actions, a status row |
///
/// Every slot is optional. A card with only a [child] is a padded surface and
/// nothing more, which is what most of the kit's cards actually are. Slots are
/// stretched to the card's width, so a variant that wants a row simply puts a
/// [Row] in a slot; this component never imposes a flex direction on content.
///
/// ## Flat, with the live press tint
///
/// The chrome is a [DabblerSurface], so the whole flat ruling — opaque fill,
/// 1px hairline, no shadow, no gradient, no blur — is inherited rather than
/// restated, and there is no API here through which any of them could return.
///
/// A tappable card darkens its fill while pressed, as live `Card.jsx:37,43`
/// does: `background: pressed ? color-mix(in srgb, <bg> 94%, black) : <bg>`,
/// `transition: background 80ms ease`. [pressedFillOf] derives that from the
/// card's resolved fill (each sRGB channel × 0.94 — exactly a 94% mix with
/// black; no colour literal), animated over [DabblerMotion.fast] (80ms) with
/// [DabblerMotion.easeOut], and dropped under reduced motion. The system
/// press scale ([DabblerPressScale]) still applies on top. It was dropped for
/// a while as "superseded by the press scale"; ruling cdispatch-5e71152a
/// item 3 restored it because live proves the tint exists.
///
/// ## Radius: 16 is the card corner, and it is a real step
///
/// `Card.jsx` writes `radius: 16` as a literal on all five variants. This file
/// once took [DabblerRadius.lg] (12) instead, on the grounds that 16 was not a
/// step of the base-3 ramp and `tokens/spacing.css:27` annotated `--radius-lg`
/// *"cards, icon tiles"*. **`cxo` ruling D-018 reverses that**: all nine
/// top-level card shells in the source draw 16 and not one draws 12, and
/// `CardHouse.jsx` draws 16 for its shell (`:9`) and 12 for the icon tile
/// inside it (`:36`) in the same file — so the annotation was conflating two
/// different corners, not naming one. 12 is the corner of a tile *inside* a
/// card; 16 is the card. [defaultRadius] is therefore [DabblerRadius.card], a
/// real step added for exactly this job, so the package's ban on raw geometry
/// values still holds. A variant that genuinely needs another step passes
/// [radius] — `CardTicket` draws at `24` ([DabblerRadius.xxl]) and is expected
/// to.
///
/// ## Padding: 16 (live `Card.jsx`)
///
/// `Card.jsx` declares `padding = 16` and says *"Figma wins on every value"*;
/// every Figma export it merges writes `padding: "16px"`. [defaultPadding] is
/// therefore 16, as in the live project 4286affa-bf50-4ff6-9576-917f76a93ca1.
/// (It was `--card-padding` — 18 — until this was compared against the live
/// source; that alias still exists for surfaces that name it.)
///
/// **The two values differ on purpose.** `--card-padding` ([DabblerSpacing.cardPadding],
/// 18, `tokens/spacing.css`) is the semantic alias on the base-3 grid for
/// surfaces specified through tokens (panels, sheets, `DabblerSurface` users).
/// Live `Card.jsx` hard-codes `padding = 16`, the value of every Figma card
/// export it merges, and says "Figma wins on every value"; the card shell takes
/// that value. A card that wants the token passes `padding:` explicitly.
class DabblerCard extends StatelessWidget {
  /// A card on the [variant] shell.
  const DabblerCard({
    super.key,
    this.child,
    this.variant = DabblerCardVariant.standard,
    this.media,
    this.header,
    this.footer,
    this.padding,
    this.gap,
    this.radius,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.semanticLabel,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  });

  /// The body slot — the card's substance. Padded.
  final Widget? child;

  /// Which of the five shells to draw.
  final DabblerCardVariant variant;

  /// The full-bleed slot above [header]: a cover image, or the coloured header
  /// strip `CardTicket` draws. **Not** padded, and clipped to the radius.
  final Widget? media;

  /// The padded slot above [child] — a title row, a leading icon beside a
  /// title.
  final Widget? header;

  /// The padded slot below [child] — a price beside its actions, a status row.
  final Widget? footer;

  /// Inner padding around [header], [child] and [footer]. Defaults to
  /// [defaultPadding].
  ///
  /// [EdgeInsetsGeometry], so a variant may pass [EdgeInsetsDirectional] and
  /// stay correct under RTL.
  final EdgeInsetsGeometry? padding;

  /// Vertical space between the padded slots. Defaults to
  /// [DabblerSpacing.stackDefault] (12), the source's own inter-slot gap on
  /// `CardHouse` and `CardEventLarge`.
  final double? gap;

  /// Corner radius. Defaults to [defaultRadius].
  final double? radius;

  /// Makes the card tappable. Null leaves it inert — no press scale, no focus
  /// ring, no pointer cursor, no button semantics.
  final VoidCallback? onTap;

  /// An optional long-press action. Does not on its own make the card tappable
  /// or focusable; [onTap] is what does that.
  final VoidCallback? onLongPress;

  /// Whether a tappable card currently accepts input. `false` withholds the
  /// handlers, the press scale and the focus ring together, so a disabled card
  /// has no pressed state that could stick.
  final bool enabled;

  /// The accessible label of a tappable card. Ignored on an inert card, whose
  /// content already reads as content.
  final String? semanticLabel;

  /// Fixed width. Null sizes the card to its constraints and its slots.
  final double? width;

  /// Fixed height. Null sizes the card to its slots.
  final double? height;

  /// How content is clipped to the rounded corners. [Clip.antiAlias] matches
  /// the kit's `overflow: hidden`, and is what keeps [media] inside the radius.
  final Clip clipBehavior;

  /// **16** — [DabblerRadius.card], the card corner ruled by `cxo` **D-018**.
  ///
  /// Was [DabblerRadius.lg] (12). See the class doc's *Radius* section for why
  /// that reading of `tokens/spacing.css:27` was wrong.
  static const double defaultRadius = DabblerRadius.card;

  /// `padding = 16` — the live `Card.jsx` default (*"Radius 16, padding 16,
  /// flat. Figma wins on every value."*). Not the `--card-padding` alias (18):
  /// the live shell names 16 as its own value, and the Figma exports it merges
  /// all write `padding: 16`.
  static const double livePadding = 16;

  /// [livePadding] on every side — see there.
  static const EdgeInsets defaultPadding = EdgeInsets.all(livePadding);

  /// The [DabblerSurface] fill step each shell is built on.
  ///
  /// Both steps need a fill override at the call site and the reason is worth
  /// recording: `DabblerSurfaceVariant.sunken` is `--surface-flat-sunken`,
  /// which resolves to `--color-bg-primary` — the **page** background — while
  /// the cards ask for `--surface-sunken`, the tonal card fill. They are
  /// different colours. [fillOf] is the authority; this getter only picks the
  /// chassis.
  static DabblerSurfaceVariant surfaceVariantOf(DabblerCardVariant variant) {
    return switch (variant) {
      DabblerCardVariant.white ||
      DabblerCardVariant.pricingSelected => DabblerSurfaceVariant.card,
      DabblerCardVariant.standard ||
      DabblerCardVariant.outlined ||
      DabblerCardVariant.pricingUnselected => DabblerSurfaceVariant.sunken,
    };
  }

  /// The share of the fill kept while pressed — live `Card.jsx`
  /// `color-mix(in srgb, <bg> 94%, black)`.
  static const double pressedMix = 0.94;

  /// [fill] mixed [pressedMix] with black, as live `Card.jsx` paints a
  /// pressed tappable card. Alpha is kept.
  static Color pressedFillOf(Color fill) => fill.withValues(
    red: fill.r * pressedMix,
    green: fill.g * pressedMix,
    blue: fill.b * pressedMix,
  );

  /// The fill of [variant], resolved against [colors].
  static Color fillOf(DabblerColors colors, DabblerCardVariant variant) {
    return switch (variant) {
      // `var(--surface-sunken)` — the tonal card fill, neutral-200 in light.
      DabblerCardVariant.standard ||
      DabblerCardVariant.outlined ||
      DabblerCardVariant.pricingUnselected => colors.surfaceSunken,
      // `var(--surface-card)`.
      DabblerCardVariant.white ||
      DabblerCardVariant.pricingSelected => colors.surfaceCard,
    };
  }

  /// The border colour of [variant], or null where the shell has none.
  static Color? borderOf(DabblerColors colors, DabblerCardVariant variant) {
    return switch (variant) {
      DabblerCardVariant.standard => null,
      // `1px solid var(--outline-card)` / `2px solid var(--outline-card)`.
      DabblerCardVariant.outlined ||
      DabblerCardVariant.white ||
      DabblerCardVariant.pricingUnselected => colors.borderDefault,
      // `2px solid var(--color-brand-primary)`.
      DabblerCardVariant.pricingSelected => colors.brandPrimary,
    };
  }

  /// The border width of [variant]: 0 on the borderless shell, 1 on the
  /// hairline shells, 2 on the two pricing shells.
  static double borderWidthOf(DabblerCardVariant variant) {
    return switch (variant) {
      DabblerCardVariant.standard => 0,
      DabblerCardVariant.outlined ||
      DabblerCardVariant.white => DabblerSizing.borderDefault,
      DabblerCardVariant.pricingSelected ||
      DabblerCardVariant.pricingUnselected => DabblerSizing.borderDefault * 2,
    };
  }

  /// Whether this card takes pointer and keyboard input.
  bool get _interactive => onTap != null && enabled;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final double resolvedRadius = radius ?? defaultRadius;
    final BorderRadius borderRadius = BorderRadius.all(
      Radius.circular(resolvedRadius),
    );

    final Color fill = fillOf(colors, variant);
    final Widget? content = _content();
    Widget surfaceWith(Color paint) => DabblerSurface(
      variant: surfaceVariantOf(variant),
      fill: paint,
      borderColor: borderOf(colors, variant),
      borderWidth: borderWidthOf(variant),
      radius: resolvedRadius,
      width: width,
      height: height,
      clipBehavior: clipBehavior,
      child: content,
    );

    if (!_interactive) return surfaceWith(fill);

    final Widget surface = _CardPressTint(fill: fill, builder: surfaceWith);

    return Semantics(
      label: semanticLabel,
      button: true,
      onTap: onTap,
      child: DabblerFocusRing(
        borderRadius: borderRadius,
        child: DabblerPressScale.gesture(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            onLongPress: onLongPress,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: surface,
            ),
          ),
        ),
      ),
    );
  }

  /// The slot stack. Null when no slot was filled — an empty card is a
  /// legitimate skeleton or media well, exactly as [DabblerSurface] allows.
  Widget? _content() {
    final List<Widget> padded = <Widget>[?header, ?child, ?footer];

    if (padded.isEmpty && media == null) return null;

    final double resolvedGap = gap ?? DabblerSpacing.stackDefault;

    Widget? body;
    if (padded.isNotEmpty) {
      body = Padding(
        padding: padding ?? defaultPadding,
        child: padded.length == 1
            ? padded.single
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (int i = 0; i < padded.length; i++) ...<Widget>[
                    if (i > 0) SizedBox(height: resolvedGap),
                    padded[i],
                  ],
                ],
              ),
      );
    }

    if (media == null) return body;
    if (body == null) return media;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[media!, body],
    );
  }
}

/// Tracks the pointer and paints [DabblerCard.pressedFillOf] while it is down,
/// animated over [DabblerMotion.fast] like live `transition: background 80ms`.
class _CardPressTint extends StatefulWidget {
  const _CardPressTint({required this.fill, required this.builder});

  final Color fill;
  final Widget Function(Color fill) builder;

  @override
  State<_CardPressTint> createState() => _CardPressTintState();
}

class _CardPressTintState extends State<_CardPressTint> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final Color target = _pressed
        ? DabblerCard.pressedFillOf(widget.fill)
        : widget.fill;
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: target),
        duration: DabblerMotion.reduceMotion(context)
            ? Duration.zero
            : DabblerMotion.fast,
        curve: DabblerMotion.easeOut,
        builder: (BuildContext context, Color? value, Widget? _) =>
            widget.builder(value ?? target),
      ),
    );
  }
}
