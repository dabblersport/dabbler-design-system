import 'package:flutter/material.dart';

import '../controls/button.dart';
import '../feedback/spinner.dart';
import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';

part 'top_bar_title.dart';
part 'top_bar_unread_dot.dart';

/// One trailing action in a [DabblerNavigationTopBar].
///
/// The source's export carries these as free-form `text1` / `text2` node slots
/// (`components/navigation/NavigationTopBar.d.ts:6-9`, unverified: file not mirrored), whose documented
/// defaults are an Iconsax `sms` and `notification-bing`. A bare slot cannot
/// meet this ticket's ≥44×44 target or carry an accessible name, so the slot is
/// modelled instead: a glyph, a name and a callback.
@immutable
class DabblerNavigationAction {
  /// Creates a trailing action.
  const DabblerNavigationAction({
    required this.icon,
    required this.label,
    this.onPressed,
    this.weight = DabblerIconWeight.linear,
    this.unread = false,
    this.unreadLabel,
    this.loading = false,
  }) : text = false,
       semanticLabel = null;

  /// A labelled text action — e.g. `Save` — drawn as a text-tone button in
  /// the bar instead of a glyph.
  ///
  /// [label] is the visible text and, unless [semanticLabel] is given, the
  /// accessible name too. The button's hit box keeps the 45 touch-target
  /// height; its width is the label's. Lays out with the bar, so under RTL it
  /// sits at the inline end like the icon actions. Additive: the icon-only
  /// [DabblerNavigationAction.new] is unchanged.
  const DabblerNavigationAction.text({
    required this.label,
    this.onPressed,
    this.semanticLabel,
    this.loading = false,
  }) : text = true,
       icon = '',
       weight = DabblerIconWeight.linear,
       unread = false,
       unreadLabel = null;

  /// Whether this is the [DabblerNavigationAction.text] variant.
  final bool text;

  /// Whether the action is busy — e.g. a `Save` while the save is in flight.
  ///
  /// A [DabblerSpinner] at [DabblerSpinnerSize.md] replaces the glyph (icon
  /// variant) or the label (text variant) **inside the same hit box**, so the
  /// bar does not reflow: the text variant keeps its label's width by laying
  /// the label out invisibly underneath. The action is inert while loading —
  /// taps are ignored and it leaves the focus order, like
  /// [DabblerButton.loading] (`const inert = disabled || loading`,
  /// `Button.jsx:63`) — but it is **not** dimmed.
  ///
  /// Semantics keep the action's name ([label] / [semanticLabel]), report it
  /// disabled, and carry [DabblerSpinner.defaultLabel] as the value.
  /// **Deviation:** Flutter's semantics have no `aria-busy`; the disabled flag
  /// plus a `Loading` value is the nearest equivalent. The spinner is
  /// direction-neutral, so RTL changes only where the action sits (the bar's
  /// inline end). Defaults to false — existing actions are unchanged.
  final bool loading;

  /// The text variant's accessible name when it must differ from the visible
  /// [label] (e.g. `'Save profile'` for a `Save` button). Ignored by the icon
  /// variant, whose [label] is already its only name.
  final String? semanticLabel;

  /// Draws the 9px unread dot on the glyph's top-end corner — see
  /// [DabblerNavigationUnreadDot]. The design shows no count, so none exists.
  final bool unread;

  /// Appended to [label] in the accessible name while [unread], e.g.
  /// `'new notifications'`. Without it the dot is announced by nothing.
  final String? unreadLabel;

  /// Kebab-case Iconsax name, e.g. `sms`.
  final String icon;

  /// The accessible name. The action is icon-only, so this is its only name.
  final String label;

  /// Tapped. A null callback leaves the action inert but visually unchanged,
  /// matching the export's non-interactive nodes.
  final VoidCallback? onPressed;

  /// `linear` by default — `bold` is reserved for active tabs and primary
  /// actions (`components/foundations/icons-system.card.html` — *Weights*).
  final DabblerIconWeight weight;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DabblerNavigationAction &&
          other.icon == icon &&
          other.label == label &&
          other.onPressed == onPressed &&
          other.weight == weight &&
          other.unread == unread &&
          other.unreadLabel == unreadLabel &&
          other.text == text &&
          other.semanticLabel == semanticLabel &&
          other.loading == loading;

  @override
  int get hashCode => Object.hash(
    icon,
    label,
    onPressed,
    weight,
    unread,
    unreadLabel,
    text,
    semanticLabel,
    loading,
  );

  @override
  String toString() => text
      ? 'DabblerNavigationAction.text($label)'
      : 'DabblerNavigationAction($icon)';
}

/// The app's identity row at the top of a screen: the Dabbler wordmark at the
/// inline **start**, and the trailing actions plus the account avatar at the
/// inline **end**.
///
/// Transcribed from `components/navigation/NavigationTopBar.jsx` (Figma node
/// 8:46) and the *NavigationTopBar* section of
/// `components/navigation/navigation-system.card.html`.
///
/// ## What this component deliberately is not
///
/// The card is emphatic: *"There are no title, back, action, alignment or
/// surface variants: it cannot carry a title, a live subtitle, a back action or
/// a typing state, and widening its API would mean rewriting a symbol-faithful
/// export."* A screen needing a back action or a tappable identity uses
/// `ConversationHeader`; a screen needing a plain title row composes one from
/// `Section` and `Button`. **No [title] or [onBack] is offered here on
/// purpose** — adding one would contradict the design source, not extend it.
///
/// ## Deviations from the verbatim export, and why
///
/// | source | here | why |
/// |---|---|---|
/// | fixed `width: 384` | fills its parent | a Flutter bar spans the screen; the export's 384 is the Figma frame, and the card calls it *"fixed export geometry"*, not a product width |
/// | bare 22px glyph nodes | [DabblerNavigationAction] in a 45×45 hit box | AC1 — targets ≥44×44 |
/// | no focus or press | [DabblerFocusRing] + [DabblerPressScale] | AC1 — DS-200 |
/// | outer 1px border on all four sides + radius 16 | none | that is the specimen card's own frame around a 384px export, not chrome the bar wears on a screen. Set [border] to restore it |
///
/// ## RTL
///
/// *"the export's row is plain flow, so the logo and avatar swap sides under
/// `dir="rtl"`"*. That is exactly what a [Row] under [Directionality] does; no
/// value here names `left` or `right`, and the wordmark is **never** mirrored —
/// a wordmark is text, and text is not a mirrored glyph.
///
/// ## Safe area
///
/// The card records that the export *"defines no safe-area inset of its own —
/// the screen around it owns top-inset padding"*. [safeArea] (default `true`)
/// nonetheless pads the block start by [MediaQueryData.padding]`.top`, because
/// on a device the status bar is real. It **cannot** double-apply: an ancestor
/// [SafeArea] consumes that padding for its subtree, so the value read here is
/// already `0`. Pass `false` to restore the source's literal behaviour.
class DabblerNavigationTopBar extends StatelessWidget {
  /// Creates a top bar.
  const DabblerNavigationTopBar({
    super.key,
    this.actions = const <DabblerNavigationAction>[],
    this.avatarSeed = defaultAvatarSeed,
    this.avatarBadge,
    this.onAvatarPressed,
    this.avatarLabel = 'Account',
    this.leading,
    this.border = false,
    this.safeArea = true,
    this.avatarImageUrl,
  }) : title = null,
       onBack = null,
       backLabel = defaultBackLabel,
       _titled = false,
       titleOpacity = 1,
       scrollController = null,
       titleRevealOffset = defaultTitleRevealOffset;

  /// The titled variant: a back button, a title and trailing actions — the
  /// inner-screen header of the design files `Settings.dc.html` (`isInner`
  /// header) and `Article.dc.html` (top bar). There is no wordmark and no
  /// avatar.
  ///
  /// The back glyph is `arrow-circle-left` in LTR and `arrow-circle-right` in
  /// RTL, so it always points toward the reading start. [title] may be null
  /// (the Article header shows its title only once the page has scrolled).
  ///
  /// This constructor **always** draws the titled variant — a null or empty
  /// [title] with no [onBack] is still a titled bar with an empty title slot,
  /// never the wordmark.
  ///
  /// **Scroll-fade.** [titleOpacity] fades the title directly (a caller
  /// scrubbing it from its own scroll position). [scrollController] instead
  /// reveals it — opacity 0 until the controller's offset passes
  /// [titleRevealOffset], then [titleOpacity] — animated over
  /// [DabblerMotion.base], immediate under reduced motion
  /// (`Profiles.dc.html:57, 815-822, 932`).
  const DabblerNavigationTopBar.titled({
    super.key,
    this.title,
    this.onBack,
    this.backLabel = defaultBackLabel,
    this.actions = const <DabblerNavigationAction>[],
    this.border = false,
    this.safeArea = true,
    this.titleOpacity = 1,
    this.scrollController,
    this.titleRevealOffset = defaultTitleRevealOffset,
  }) : _titled = true,
       avatarSeed = defaultAvatarSeed,
       avatarBadge = null,
       onAvatarPressed = null,
       avatarLabel = 'Account',
       leading = null,
       avatarImageUrl = null;

  /// The back button's default accessible name.
  static const String defaultBackLabel = 'Back';

  /// The back glyph's LTR name. Drawn with [DabblerIcon.mirrorInRtl], so RTL
  /// shows `arrow-circle-right` — pointing at the inline start, where the
  /// button sits and where "back" leads.
  static const String backIcon = 'arrow-circle-left';

  /// The titled variant's title; null draws an empty title slot.
  final String? title;

  /// The titled variant's back action. Null hides the back button.
  final VoidCallback? onBack;

  /// The back button's accessible name.
  final String backLabel;

  /// The account avatar's photo. Drawn by [DabblerAvatar] in the same circle;
  /// the [avatarSeed] portrait stands in while it loads, when it is empty and
  /// when it fails.
  final String? avatarImageUrl;

  /// Whether this bar is the titled (back + title) variant — true for every
  /// bar built by [DabblerNavigationTopBar.titled], whatever its [title].
  bool get isTitled => _titled;

  final bool _titled;

  /// The title's opacity, 0–1. Default 1 (always shown). Titled variant only.
  final double titleOpacity;

  /// When given, the title is hidden until this controller has scrolled past
  /// [titleRevealOffset], then fades in. Titled variant only.
  final ScrollController? scrollController;

  /// The scroll offset past which [scrollController] reveals the title.
  final double titleRevealOffset;

  /// [titleRevealOffset]'s default — the `18` floor of
  /// `Math.max(el.offsetHeight - 52, 18)` (`Profiles.dc.html:818`),
  /// [DabblerSpacing.space6].
  static const double defaultTitleRevealOffset = DabblerSpacing.space6;

  /// Diameter of the titled variant's back button — `40x40` in
  /// `Settings.dc.html` and `Article.dc.html`, inside a 45px hit box.
  static const double backButtonSide = 40;

  /// The back glyph's size — `size="20"` in both files.
  static const double backGlyphSize = 20;

  /// The export's Multiavatar seed — `text3`'s documented default
  /// (`navigation-system.card.html` — *Anatomy*).
  static const String defaultAvatarSeed = 'Alen Rahman';

  /// `height: 62` (`NavigationTopBar.jsx:10`), applied as a **fixed height**.
  ///
  /// The export draws 62 with a 1px border top and bottom (`:15`, `:17`), so
  /// the interior is **60**. A 45-tall [actionTarget] centred in 60 leaves
  /// 7.5 above and below, and the 22px glyph keeps its 28px line box. Nothing
  /// is clipped and not one painted pixel moves, so the bar takes the drawn
  /// height exactly — `D-039`. (This port draws no border unless [border] is
  /// set, so by default the interior is the full 62 and the clearance is 8.5.
  /// Either way the 45 box fits with room to spare.)
  ///
  /// **A hit box is bounded by the pitch between peer targets, never by the
  /// padding around the drawn mark.** [barPadding]'s 12 is space the target
  /// may claim, not a wall it must stay inside; the only real bounds are
  /// another target's claim and the edge of what the component owns. That is
  /// the rule `D-032` exists to state, and it is why the interior is the
  /// number that matters here rather than padding-plus-content.
  static const double barHeight = 62;

  /// The avatar badge's diameter — `16x16` in the export (the plain Avatar's
  /// own badge is 24).
  static const double avatarBadgeSide = 16;

  /// `padding: '12px 16px'` (`NavigationTopBar.jsx:32`, written there as `'12px 16px 12px 16px'`). 16 is off the base-3
  /// grid and is transcribed literally: the previous cut rounded it to
  /// `--space-5` (15), which pulls the wordmark a pixel in from where the
  /// specimen draws it. Recorded as a token conflict, not resolved to the ramp.
  static const EdgeInsetsDirectional barPadding =
      EdgeInsetsDirectional.symmetric(
        vertical: DabblerSpacing.space4,
        horizontal: barPaddingInline,
      );

  /// `gap: 12` between the trailing actions and the avatar
  /// (`NavigationTopBar.jsx:115`) — `--space-4`.
  static const double trailingGap = DabblerSpacing.space4;

  /// `16` — the inline half of `padding: '12px 16px'`. Off-grid, transcribed.
  static const double barPaddingInline = 16;

  /// `size={22}` on each trailing glyph (`NavigationTopBar.jsx:139,160`). Off
  /// the 18/24/30 icon ramp and transcribed: the previous cut drew 24, which
  /// crowds the 12px gap the specimen leaves between the two glyphs and the
  /// avatar.
  static const double actionGlyphSize = 22;

  /// A trailing action's hit box: **34 × 45**, per `DECISIONS.md` D-032.
  ///
  /// The target floor never cost this bar its fidelity — assuming the box had
  /// to be *square* did. A 45×45 box carries 11.5 of inline padding each side,
  /// so the specimen's `gap: 12` on top of it spreads the cluster to 57
  /// between glyph centres against the drawn 34; butting the boxes still gave
  /// 45. A 34-wide box takes 6 each side of the 22 glyph, so 34 + 0 gap is
  /// exactly the drawn 34 pitch, and 45 tall still clears the floor on the
  /// axis the floor is measured against.
  static const Size actionTarget = Size(34, DabblerSizing.touchTargetMin);

  /// The wordmark's intrinsic box, `100 × 19` (`NavigationTopBar.jsx:42-43`).
  static const Size wordmarkSize = Size(100, 19);

  /// The trailing icon actions, in visual order. Empty by default; the
  /// export's documented pair is `sms` and `notification-bing`, which a caller
  /// supplies because only the caller owns what they do.
  final List<DabblerNavigationAction> actions;

  /// The Multiavatar seed for the trailing avatar — the export's `text3`.
  final String avatarSeed;

  /// The avatar's corner badge — the export's `text4`, an Iconsax bold `star`
  /// by default in the source. Null draws no badge.
  final Widget? avatarBadge;

  /// Tapped on the avatar. Null leaves it inert.
  final VoidCallback? onAvatarPressed;

  /// The avatar's accessible name.
  final String avatarLabel;

  /// Replaces the wordmark at the inline start. Null draws
  /// [DabblerWordmark].
  final Widget? leading;

  /// Draws the specimen's 1px [DabblerColors.borderDefault] outline and
  /// [DabblerRadius.lg] corners around the bar. Off by default — see the class
  /// doc's deviation table.
  final bool border;

  /// Whether to pad the block start by the device's top inset. See the class
  /// doc — this cannot double-apply under an ancestor [SafeArea].
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);

    final Widget row = isTitled
        ? _titledRow(context, colors)
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child:
                    leading ??
                    DabblerWordmark(
                      // `color: 'var(--purple-600)'` on the export's root, which the
                      // paths inherit through `fill="currentColor"`.
                      color: colors.brandPrimary,
                    ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                // `gap: 12` between **bare** 22px glyph nodes — i.e. 34 between
                // glyph centres. [actionTarget] is 34 wide, so butting the boxes
                // reproduces that pitch exactly while each box still clears the
                // touch-target floor on its constrained axis (D-032).
                spacing: 0,
                children: <Widget>[
                  for (final DabblerNavigationAction action in actions)
                    _action(colors, action),
                  _avatar(),
                ],
              ),
            ],
          );

    Widget bar = Container(
      height: barHeight,
      // Horizontal only. [barPadding]'s vertical 12 is claimable space, not a
      // wall — see [barHeight]. Applying it here would box the row into
      // 62 - 24 = 38 and crush the 45-tall [actionTarget] back to 38, which is
      // the very clipping the old minimum was invented to avoid. Nothing
      // painted moves: the tallest drawn thing is the 22px glyph in its 28px
      // line box, and the row centres it either way.
      padding: EdgeInsetsDirectional.only(
        start: barPadding.start,
        end: barPadding.end,
      ),
      decoration: BoxDecoration(
        // `backgroundColor: 'var(--neutral-100)'`, which is `--surface-page`
        // (`tokens/colors.css:32`).
        color: colors.bgPrimary,
        // Root `borderRadius: 16` (`NavigationTopBar.jsx:14`).
        borderRadius: border ? DabblerRadius.cardAll : null,
        border: border
            ? Border.all(
                color: colors.borderDefault,
                width: DabblerSizing.borderDefault,
              )
            : null,
      ),
      child: row,
    );
    if (isTitled && border) {
      // The inner header's rule is a bottom hairline (`border-bottom:1px solid
      // var(--faint)`), not the card outline the plain bar's `border` draws.
      bar = Container(
        height: barHeight,
        padding: EdgeInsetsDirectional.only(
          start: barPadding.start,
          end: barPadding.end,
        ),
        decoration: BoxDecoration(
          color: colors.bgPrimary,
          border: Border(
            bottom: BorderSide(
              color: colors.bgTertiary,
              width: DabblerSizing.borderDefault,
            ),
          ),
        ),
        child: row,
      );
    }

    if (safeArea) {
      // Zero under an ancestor SafeArea, which has already consumed it.
      bar = Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: bar,
      );
    }
    return bar;
  }

  /// One trailing action in a [DabblerSizing.touchTargetMin] square.
  ///
  /// The glyph is 22 in the export; the box around it is the target.
  Widget _action(DabblerColors colors, DabblerNavigationAction action) {
    if (action.text) {
      return _textAction(action);
    }
    final VoidCallback? onPressed = action.loading ? null : action.onPressed;
    final Widget body = SizedBox(
      width: actionTarget.width,
      height: actionTarget.height,
      child: Center(
        child: action.loading
            ? IconTheme.merge(
                data: IconThemeData(color: colors.textPrimary),
                child: const DabblerSpinner(
                  // 24 — the nearest spinner size to the 22 glyph.
                  size: DabblerSpinnerSize.md,
                  tone: DabblerSpinnerTone.inherit,
                ),
              )
            : DabblerNavigationUnreadDot.wrap(
                visible: action.unread,
                child: DabblerIcon(
                  action.icon,
                  weight: action.weight,
                  // `size={22}` — transcribed, see [actionGlyphSize].
                  size: actionGlyphSize,
                  // `color: 'var(--neutral-900)'` — `--ink`, i.e. textPrimary.
                  color: colors.textPrimary,
                ),
              ),
      ),
    );

    return Semantics(
      container: true,
      button: true,
      enabled: onPressed != null,
      label: DabblerNavigationUnreadDot.semanticLabel(action),
      value: action.loading ? DabblerSpinner.defaultLabel : null,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: DabblerFocusRing(
            borderRadius: DabblerRadius.pillAll,
            child: DabblerPressScale.gesture(
              enabled: onPressed != null,
              child: body,
            ),
          ),
        ),
      ),
    );
  }

  /// A [DabblerNavigationAction.text] action: a [DabblerButtonTone.text]
  /// button at [DabblerButtonSize.small], whose own focus ring, press scale,
  /// disabled state and RTL label resolution apply. The button carries the
  /// semantics; [DabblerNavigationAction.semanticLabel] overrides its name. A
  /// null callback draws it disabled.
  Widget _textAction(DabblerNavigationAction action) {
    final Widget labelled = DabblerButton(
      label: action.label,
      semanticLabel: action.semanticLabel,
      tone: DabblerButtonTone.text,
      size: DabblerButtonSize.small,
      // A null callback reads as disabled, matching the icon actions'
      // `enabled: onPressed != null`.
      disabled: action.onPressed == null,
      onPressed: action.onPressed,
    );
    if (!action.loading) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: DabblerSizing.touchTargetMin,
        ),
        child: Center(widthFactor: 1, child: labelled),
      );
    }
    // Loading: the label is laid out invisibly so the action keeps its width,
    // and the spinner sits centred over it. See [DabblerNavigationAction.loading].
    return Semantics(
      container: true,
      button: true,
      enabled: false,
      label: action.semanticLabel ?? action.label,
      value: DabblerSpinner.defaultLabel,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: DabblerSizing.touchTargetMin,
          ),
          child: Center(
            widthFactor: 1,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Visibility(
                  visible: false,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: DabblerButton(
                    label: action.label,
                    tone: DabblerButtonTone.text,
                    size: DabblerButtonSize.small,
                  ),
                ),
                Builder(
                  builder: (BuildContext context) => IconTheme.merge(
                    data: IconThemeData(
                      color: DabblerButton.foregroundFor(
                        DabblerColors.of(context),
                        DabblerButtonTone.text,
                      ),
                    ),
                    child: const DabblerSpinner(
                      size: DabblerSpinnerSize.md,
                      tone: DabblerSpinnerTone.inherit,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The trailing avatar — 36 in the export, which is
  /// [DabblerAvatarSize.sm]'s own diameter.
  ///
  /// 36 is under the 45 target floor, so the hit box around it is the floor
  /// while the circle still paints 36. The avatar is only a target at all when
  /// [onAvatarPressed] is given; the export's is decorative.
  Widget _titledRow(BuildContext context, DabblerColors colors) {
    final TextDirection dir = Directionality.of(context);
    final VoidCallback? back = onBack;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (back != null) ...<Widget>[
          Semantics(
            container: true,
            button: true,
            label: backLabel,
            onTap: back,
            child: ExcludeSemantics(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: back,
                child: DabblerFocusRing(
                  borderRadius: DabblerRadius.pillAll,
                  child: DabblerPressScale.gesture(
                    child: SizedBox(
                      width: DabblerSizing.touchTargetMin,
                      height: DabblerSizing.touchTargetMin,
                      child: Center(
                        child: Container(
                          width: backButtonSide,
                          height: backButtonSide,
                          decoration: BoxDecoration(
                            // `background:var(--surface-card);
                            // border:1px solid var(--outline-card)`.
                            color: colors.surfaceCard,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.borderDefault,
                              width: DabblerSizing.borderDefault,
                            ),
                          ),
                          child: Center(
                            // Measured 2026-10-03: `arrow-circle-left` and
                            // `-right` are true pixel mirrors in
                            // iconsax_flutter, so RTL draws the start-pointing
                            // glyph. See [DabblerIconMirror].
                            child: DabblerIcon(
                              backIcon,
                              mirrorInRtl: true,
                              size: backGlyphSize,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // `gap:9px` between the header's children.
          const SizedBox(width: DabblerSpacing.space3),
        ],
        Expanded(
          child: Semantics(
            header: true,
            child: _TopBarTitle(
              text: title ?? '',
              opacity: titleOpacity,
              controller: scrollController,
              revealOffset: titleRevealOffset,
              // `font-size:16px;line-height:21px;font-weight:600;color:var(--ink)`
              // — the body step at semibold (weight override only).
              style: DabblerType.body
                  .resolveForDirection(dir)
                  .copyWith(
                    color: colors.textPrimary,
                    fontWeight: DabblerType.semibold,
                  ),
            ),
          ),
        ),
        for (final DabblerNavigationAction action in actions)
          _action(colors, action),
      ],
    );
  }

  Widget _avatar() {
    final Widget avatar = DabblerAvatar(
      seed: avatarSeed,
      imageUrl: avatarImageUrl,
      size: DabblerAvatarSize.sm,
      badge: avatarBadge,
      // Badge `16x16`, `2px solid var(--neutral-100)` (`NavigationTopBar.jsx:189-196`).
      badgeSize: avatarBadgeSide,
    );

    final VoidCallback? onPressed = onAvatarPressed;
    if (onPressed == null) {
      return avatar;
    }

    return Semantics(
      container: true,
      button: true,
      label: avatarLabel,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: DabblerFocusRing(
            borderRadius: DabblerRadius.pillAll,
            child: DabblerPressScale.gesture(
              child: SizedBox(
                width: DabblerSizing.touchTargetMin,
                height: DabblerSizing.touchTargetMin,
                child: Center(child: avatar),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The Dabbler wordmark, transcribed path-for-path from the SVG the export
/// inlines (`components/navigation/NavigationTopBar.jsx:47-109`).
///
/// It is drawn rather than loaded because the design source's own note —
/// *"the real `dabbler_logo.svg` mark and wordmark, used as-is"* — means an
/// asset, and this package ships no assets and may take no new dependency
/// (a `cto` hand-off). Every coordinate below is the export's, translated by
/// that glyph's `left` / `top`; nothing is redrawn or re-spaced.
///
/// Each glyph's sub-paths are wound as the source's `fillRule="evenodd"`
/// requires, which is what hollows the counters of `d`, `b` and `e`.
class DabblerWordmark extends StatelessWidget {
  /// Draws the wordmark at [size], scaled from its intrinsic
  /// [DabblerNavigationTopBar.wordmarkSize].
  const DabblerWordmark({super.key, this.color, this.size});

  /// The fill. Null inherits from the enclosing [IconTheme], then falls back to
  /// [DabblerColors.textPrimary] — the `fill="currentColor"` behaviour of the
  /// source.
  final Color? color;

  /// The drawn box. Null uses [DabblerNavigationTopBar.wordmarkSize] (100×19).
  final Size? size;

  /// The seven glyphs of "dabbler", each as `[dx, dy, x0, y0, x1, y1, …]` with
  /// a `-1` marking the start of a new sub-path within the same glyph.
  ///
  /// Coordinates are the export's own `d` attributes verbatim; `dx` / `dy` are
  /// its absolute `left` / `top`.
  static const List<List<double>> glyphs = <List<double>>[
    // d — left 0, top 0.211
    <double>[
      0,
      0.211,
      0,
      14.904,
      0,
      8.12,
      3.543,
      4.59,
      10.529,
      4.59,
      10.529,
      0,
      14.234,
      0,
      14.234,
      18.603,
      3.684,
      18.603,
      3.684,
      14.904,
      0,
      14.904,
      -1,
      3.725,
      14.906,
      10.529,
      14.906,
      10.529,
      8.287,
      3.725,
      8.287,
      3.725,
      14.906,
    ],
    // a — left 16.082, top 4.801
    <double>[
      16.082,
      4.801,
      0.02,
      14.012,
      0,
      14.012,
      0,
      5.146,
      10.509,
      5.146,
      10.509,
      3.696,
      0,
      3.696,
      0,
      0,
      10.691,
      0,
      14.214,
      3.529,
      14.214,
      14.012,
      3.704,
      14.012,
      3.704,
      10.314,
      10.509,
      10.316,
      10.509,
      8.383,
      3.704,
      8.383,
      3.704,
      10.314,
      0.02,
      10.314,
      0.02,
      14.012,
    ],
    // b — left 32.16, top 0.21
    <double>[
      32.16,
      0.21,
      0,
      18.603,
      0,
      0,
      3.684,
      0,
      3.684,
      4.59,
      10.67,
      4.59,
      14.194,
      8.12,
      14.194,
      18.603,
      3.684,
      18.603,
      3.684,
      14.904,
      10.509,
      14.906,
      10.509,
      8.287,
      3.684,
      8.287,
      3.684,
      14.904,
      0,
      14.904,
      0,
      18.603,
    ],
    // b — left 48.222, top 0.21 (the same glyph, moved)
    <double>[
      48.222,
      0.21,
      0,
      18.603,
      0,
      0,
      3.684,
      0,
      3.684,
      4.59,
      10.67,
      4.59,
      14.194,
      8.12,
      14.194,
      18.603,
      3.684,
      18.603,
      3.684,
      14.904,
      10.509,
      14.906,
      10.509,
      8.287,
      3.684,
      8.287,
      3.684,
      14.904,
      0,
      14.904,
      0,
      18.603,
    ],
    // l — left 64.276, top 0.186
    <double>[
      64.276,
      0.186,
      0,
      15.098,
      0,
      0,
      3.725,
      0,
      3.725,
      14.93,
      6.543,
      14.93,
      6.543,
      18.627,
      3.523,
      18.627,
      0,
      15.098,
    ],
    // e — left 72.676, top 4.801
    <double>[
      72.676,
      4.801,
      0,
      10.314,
      0,
      0,
      10.67,
      0,
      14.214,
      3.529,
      14.214,
      8.866,
      3.704,
      8.866,
      3.704,
      10.314,
      0,
      10.314,
      -1,
      3.704,
      10.314,
      14.214,
      10.316,
      14.214,
      14.012,
      3.704,
      14.012,
      3.704,
      10.314,
      -1,
      3.704,
      5.629,
      10.51,
      5.629,
      10.51,
      3.696,
      3.704,
      3.696,
      3.704,
      5.629,
    ],
    // r — left 88.745, top 4.801
    <double>[
      88.745,
      4.801,
      0,
      14.012,
      0,
      3.529,
      3.523,
      0,
      11.255,
      0,
      11.255,
      3.696,
      3.684,
      3.696,
      3.684,
      14.012,
      0,
      14.012,
    ],
  ];

  /// Builds the wordmark's [Path] in its intrinsic 100×19 space.
  static Path buildPath() {
    final Path path = Path()..fillType = PathFillType.evenOdd;
    for (final List<double> glyph in glyphs) {
      final double dx = glyph[0];
      final double dy = glyph[1];
      bool startNext = true;
      for (int i = 2; i < glyph.length;) {
        if (glyph[i] == -1) {
          path.close();
          startNext = true;
          i += 1;
          continue;
        }
        final double x = dx + glyph[i];
        final double y = dy + glyph[i + 1];
        if (startNext) {
          path.moveTo(x, y);
          startNext = false;
        } else {
          path.lineTo(x, y);
        }
        i += 2;
      }
      path.close();
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final Size box = size ?? DabblerNavigationTopBar.wordmarkSize;
    final Color tint =
        color ??
        IconTheme.of(context).color ??
        DabblerColors.of(context).textPrimary;
    return ExcludeSemantics(
      child: SizedBox.fromSize(
        size: box,
        child: CustomPaint(
          painter: _WordmarkPainter(color: tint),
          size: box,
        ),
      ),
    );
  }
}

class _WordmarkPainter extends CustomPainter {
  _WordmarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Size intrinsic = DabblerNavigationTopBar.wordmarkSize;
    canvas.save();
    canvas.scale(size.width / intrinsic.width, size.height / intrinsic.height);
    canvas.drawPath(
      DabblerWordmark.buildPath(),
      Paint()
        ..color = color
        ..isAntiAlias = true
        ..style = PaintingStyle.fill,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WordmarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
