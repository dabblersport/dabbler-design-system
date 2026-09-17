import 'package:flutter/material.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_palette.dart';

/// The four paints a [DabblerFab] can take, transcribed from the `TONES` map of
/// the design source `components/controls/FAB.jsx`.
///
/// The enum collapses the Figma kit's **four separate FAB symbols** into one
/// component — `FAB.d.ts` says so explicitly ("merged from the Figma kit's four
/// FAB symbols"), and `controls.card.html:36` names them in this order:
/// *default indigo · primary purple · accent pink · dark neutral*.
enum DabblerFabTone {
  /// `default` — indigo fill, card ink.
  ///
  /// Named [indigo] rather than `default` because `default` is a reserved word
  /// in Dart. The source's name for this tone is `default`; [source] carries it
  /// verbatim so a caller mapping from design-side props has the original.
  indigo('default'),

  /// `primary` — the theme's brand purple, card ink. The source's default tone.
  primary('primary'),

  /// `accent` — the theme's accent pink, card ink.
  accent('accent'),

  /// `dark` — the sunken neutral surface, primary text ink.
  dark('dark');

  const DabblerFabTone(this.source);

  /// The tone's name in the design source (`FAB.d.ts`), which differs from the
  /// Dart identifier only for [indigo].
  final String source;
}

/// FAB — the floating action button.
///
/// Transcribed from `components/controls/FAB.jsx`, `FAB.d.ts`,
/// `FAB.prompt.md` and the specimen `components/controls/controls.card.html`.
/// One 56×56 control carrying a single glyph or icon, in one of the four
/// [DabblerFabTone] paints.
///
/// ## THE ONE COMPONENT THAT KEEPS A SHADOW
///
/// Dabbler surfaces are flat — no shadow, no gradient, no blur. The FAB is the
/// stated exception, and the source says why in its own words: *"This is the
/// ONE component that keeps a drop shadow: the Figma file draws it with
/// `0 10px 15px -3px rgba(0,0,0,.1), 0 4px 6px -4px rgba(0,0,0,.1)`, and Figma
/// wins over the otherwise-flat surface rule."* (`FAB.jsx:11-14`). `FAB.d.ts`
/// and `FAB.prompt.md` both repeat it: *"the one component that keeps a drop
/// shadow because the Figma file draws one"*.
///
/// The reason it is an exception at all is functional, not decorative: a FAB
/// floats **over** arbitrary scrolling content, so it has no owning surface to
/// sit flush against. Without a shadow it reads as part of whatever happens to
/// be beneath it. Every other component in the system sits *on* a card or a
/// page, where flatness costs nothing.
///
/// **This shadow is [shadow], not [DabblerElevation.dialogFor].** They are
/// different values from different places and neither may borrow the other:
///
/// * [DabblerElevation.dialogFor] is `--elevation-2` from `tokens/spacing.css`,
///   which that file calls *"the ONE legal shadow and only for Material
///   dialogs"*. It is mode-aware, tinted with [DabblerPalette.ink950], and
///   reserved for Dialog (DS-702).
/// * [shadow] is the Figma FAB's own two-layer `box-shadow`, pure black at 10%,
///   identical in both modes because the source declares it once.
///
/// ## Corner: 21, not a circle
///
/// `FAB.d.ts` describes the FAB as "fully round". `FAB.jsx:8-10` overrides that
/// in the source itself: *"the Figma file draws the FAB fully round (9999). The
/// 21px corner is a deliberate override from the team, matching the full-width
/// Button's corner."* The implementation is the later statement and the one
/// that reconciles the two, so this widget draws the 21px squircle
/// ([DabblerSpacing.space7]) and not [DabblerRadius.pill]. Flagged on KAN-222
/// as a source contradiction: if the team wants the circle back, this is the
/// single line to change.
///
/// ## Press and focus
///
/// Press is the source's `transform: scale(0.96)` over `80ms ease`, and a
/// disabled FAB does not react at all — `FAB.jsx` withholds every handler when
/// `disabled`. Focus draws a [DabblerColors.focusRing] outline outside the
/// button, which the web source gets from the UA and Flutter does not.
///
/// Both behaviours live in the private `_FabInteraction` helper below. DS-200
/// is introducing shared press/focus primitives; when it lands, that helper
/// should be deleted and this widget folded onto it. It is deliberately one
/// small class so that fold is a deletion rather than a rewrite.
class DabblerFab extends StatelessWidget {
  /// Creates a FAB carrying [child].
  ///
  /// A null [onPressed] renders the disabled state: the source's `opacity: 0.45`
  /// with every interaction handler withheld.
  const DabblerFab({
    super.key,
    required this.child,
    this.onPressed,
    this.tone = DabblerFabTone.primary,
    this.semanticLabel,
  });

  /// The glyph or icon painted in the centre. The source types it as
  /// `React.ReactNode` and the specimen passes a 24px [Icon].
  final Widget child;

  /// Called on tap. Null disables the button.
  final VoidCallback? onPressed;

  /// The paint. Defaults to [DabblerFabTone.primary], as the source does.
  final DabblerFabTone tone;

  /// The action this FAB performs, announced by assistive technology.
  ///
  /// A FAB carries an icon and no text, so without this it is announced as an
  /// unlabelled button.
  final String? semanticLabel;

  /// `--fab-size` — 56×56, from `FAB.jsx` (`width: 56, height: 56`).
  ///
  /// Off the base-3 grid, and deliberately so: 56 is the Material FAB diameter
  /// the Figma kit was drawn on, not a step of [DabblerSpacing]. It clears
  /// [DabblerSizing.touchTargetMin] (45) with room to spare.
  static const double size = 56;

  /// The corner radius — [DabblerSpacing.space7] (21), per `FAB.jsx:8-10`.
  static const double cornerRadius = DabblerSpacing.space7;

  /// The disabled opacity, from `FAB.jsx` (`opacity: disabled ? 0.45 : 1`).
  static const double disabledOpacity = 0.45;

  /// The pressed scale, from `FAB.jsx` (`transform: scale(0.96)`).
  static const double pressedScale = 0.96;

  /// The press transition, from `FAB.jsx` (`transition: transform 80ms ease`).
  static const Duration pressDuration = Duration(milliseconds: 80);

  /// The FAB's own drop shadow — **the system's one non-Dialog shadow**.
  ///
  /// Transcribed layer for layer from `FAB.jsx`:
  /// `0px 10px 15px -3px rgba(0,0,0,0.1), 0px 4px 6px -4px rgba(0,0,0,0.1)`.
  ///
  /// The offsets, blurs and spreads are raw CSS pixels and are **not** on the
  /// base-3 grid, because they are not spacing: they are one Tailwind-shaped
  /// shadow that the Figma file bakes in as a single visual unit. Rounding them
  /// onto [DabblerSpacing] would change the drawing to no one's specification.
  /// The colour is plain black at 10%, again as the source declares it, and is
  /// identical in light and dark because the source declares it once — unlike
  /// `--elevation-2`, which `tokens/spacing.css` redeclares under
  /// `[data-mode="dark"]`.
  ///
  /// Never substitute [DabblerElevation.dialogFor] here, and never use this in
  /// a Dialog.
  static final List<BoxShadow> shadow = List<BoxShadow>.unmodifiable(
    <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        offset: const Offset(0, 10),
        blurRadius: 15,
        spreadRadius: -3,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        offset: const Offset(0, 4),
        blurRadius: 6,
        spreadRadius: -4,
      ),
    ],
  );

  /// The fill for [tone], resolved against the enclosing theme.
  static Color backgroundOf(DabblerFabTone tone, DabblerColors colors) =>
      switch (tone) {
        // `--accent-indigo`. See [_indigo] for why this is not an exact
        // transcription.
        DabblerFabTone.indigo => _indigo,
        DabblerFabTone.primary => colors.brandPrimary,
        DabblerFabTone.accent => colors.accent,
        DabblerFabTone.dark => colors.surfaceSunken,
      };

  /// The glyph colour for [tone], resolved against the enclosing theme.
  static Color foregroundOf(DabblerFabTone tone, DabblerColors colors) =>
      switch (tone) {
        // Three of the four tones name `--surface-card` as the foreground in
        // `FAB.jsx`; transcribed literally rather than through `--color-on-brand`
        // so the source stays readable against this file.
        DabblerFabTone.indigo ||
        DabblerFabTone.primary ||
        DabblerFabTone.accent =>
          colors.surfaceCard,
        // `--ink`, whose semantic role in the token layer is `--color-text-primary`.
        DabblerFabTone.dark => colors.textPrimary,
      };

  /// **Approximation, pending a token.** `FAB.jsx` paints the `default` tone
  /// with `--accent-indigo`, which is `rgb(92, 80, 230)` — but that token is
  /// declared only in `tokens/figma/fig-tokens.css`, **not** in
  /// `tokens/colors.css`. [DabblerPalette] is contractually a transcription of
  /// `colors.css`'s `:root` block and its test enforces that, so `#5C50E6`
  /// cannot legally be added here by this ticket.
  ///
  /// [DabblerPalette.socialInfo] (`#6366F1`) is the nearest indigo the palette
  /// actually declares and is what this tone paints today. Raised on KAN-222 as
  /// a hand-off: adopting `--accent-indigo` means widening the palette's stated
  /// source beyond `colors.css`, which is a `cto`/`cxo` call, not a developer's.
  static const Color _indigo = DabblerPalette.socialInfo;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool enabled = onPressed != null;

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: enabled,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: _FabInteraction(
          onPressed: onPressed,
          focusRing: colors.focusRing,
          child: Opacity(
            opacity: enabled ? 1 : disabledOpacity,
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: backgroundOf(tone, colors),
                borderRadius: const BorderRadius.all(
                  Radius.circular(cornerRadius),
                ),
                boxShadow: shadow,
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: foregroundOf(tone, colors),
                  size: DabblerSizing.iconMd,
                ),
                child: DefaultTextStyle.merge(
                  // `FAB.jsx`: `fontSize: 24, fontWeight: 700, lineHeight: 1`.
                  // 24 is the native icon grid, [DabblerSizing.iconMd], so a
                  // text glyph and an icon child render at the same size.
                  style: TextStyle(
                    color: foregroundOf(tone, colors),
                    fontSize: DabblerSizing.iconMd,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Press-scale and focus-ring behaviour for [DabblerFab].
///
/// **Temporary.** DS-200 is writing the shared press/focus primitives for the
/// whole system and was not available when KAN-222 was built. This helper is
/// the local stand-in: it does exactly what `FAB.jsx` does and nothing more, so
/// that folding it onto DS-200 is a deletion. Do not grow it, and do not reuse
/// it from another component — use DS-200 instead.
class _FabInteraction extends StatefulWidget {
  const _FabInteraction({
    required this.child,
    required this.onPressed,
    required this.focusRing,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final Color focusRing;

  @override
  State<_FabInteraction> createState() => _FabInteractionState();
}

class _FabInteractionState extends State<_FabInteraction> {
  bool _pressed = false;
  bool _focused = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;

    // The source withholds every handler when disabled rather than guarding
    // inside them, so a disabled FAB has no pressed state to get stuck in.
    final Widget scaled = AnimatedScale(
      scale: _pressed ? DabblerFab.pressedScale : 1,
      duration: DabblerFab.pressDuration,
      curve: Curves.ease,
      child: widget.child,
    );

    // The focus ring the browser draws for the web source and Flutter does not:
    // a hairline-pair outline one base-3 step outside the button.
    final Widget ringed = Container(
      padding: const EdgeInsets.all(DabblerSpacing.space1),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(DabblerFab.cornerRadius + DabblerSpacing.space1),
        ),
        border: Border.all(
          color: _focused && enabled ? widget.focusRing : Colors.transparent,
          width: DabblerSizing.borderDefault * 2,
        ),
      ),
      child: scaled,
    );

    if (!enabled) return ringed;

    return Focus(
      onFocusChange: (bool value) => setState(() => _focused = value),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ringed,
        ),
      ),
    );
  }
}
