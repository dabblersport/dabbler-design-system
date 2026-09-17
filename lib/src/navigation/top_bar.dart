import 'package:flutter/material.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';

/// One trailing action in a [DabblerNavigationTopBar].
///
/// The source's export carries these as free-form `text1` / `text2` node slots
/// (`components/navigation/NavigationTopBar.d.ts:6-9`), whose documented
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
  });

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
          other.weight == weight;

  @override
  int get hashCode => Object.hash(icon, label, onPressed, weight);

  @override
  String toString() => 'DabblerNavigationAction($icon)';
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
/// | `height: 62` | [barHeight] (62) as a **minimum** | the 45-target actions add up to 45 + 2×12 = 69 of content, so a hard 62 would clip them. See [barHeight] |
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
  });

  /// The export's Multiavatar seed — `text3`'s documented default
  /// (`navigation-system.card.html` — *Anatomy*).
  static const String defaultAvatarSeed = 'Alen Rahman';

  /// `height: 62` (`NavigationTopBar.jsx:8`), applied as a **minimum**.
  ///
  /// The export's own row is `padding: '12px 16px'` around 22px glyphs, i.e.
  /// 46 — it fits 62 only because nothing in it is a real target. Raising the
  /// glyph boxes to the 45 floor this ticket requires makes the content 69
  /// tall, so pinning 62 would clip it. A minimum keeps the export's height
  /// wherever the content still fits under it.
  static const double barHeight = 62;

  /// `padding: '12px 16px'` (`NavigationTopBar.jsx:33`). 16 is off the base-3
  /// grid; `--space-5` (15) is the step the system carries.
  static const EdgeInsetsDirectional barPadding =
      EdgeInsetsDirectional.symmetric(
    vertical: DabblerSpacing.space4,
    horizontal: DabblerSpacing.space5,
  );

  /// `gap: 12` between the trailing actions and the avatar
  /// (`NavigationTopBar.jsx:124`) — `--space-4`.
  static const double trailingGap = DabblerSpacing.space4;

  /// The wordmark's intrinsic box, `100 × 19` (`NavigationTopBar.jsx:46-50`).
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

    final Widget row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: leading ??
              DabblerWordmark(
                // `color: 'var(--purple-600)'` on the export's root, which the
                // paths inherit through `fill="currentColor"`.
                color: colors.brandPrimary,
              ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: trailingGap,
          children: <Widget>[
            for (final DabblerNavigationAction action in actions)
              _action(colors, action),
            _avatar(),
          ],
        ),
      ],
    );

    Widget bar = Container(
      constraints: const BoxConstraints(minHeight: barHeight),
      padding: barPadding,
      decoration: BoxDecoration(
        // `backgroundColor: 'var(--neutral-100)'`, which is `--surface-page`
        // (`tokens/colors.css:32`).
        color: colors.bgPrimary,
        borderRadius: border ? DabblerRadius.lgAll : null,
        border: border
            ? Border.all(
                color: colors.borderDefault,
                width: DabblerSizing.borderDefault,
              )
            : null,
      ),
      child: row,
    );

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
    final Widget body = SizedBox(
      width: DabblerSizing.touchTargetMin,
      height: DabblerSizing.touchTargetMin,
      child: Center(
        child: DabblerIcon(
          action.icon,
          weight: action.weight,
          // `size={22}` is off the 18/24/30 steps; the card's token table names
          // `--icon-md · 24px` for *"every navigation glyph"*.
          size: DabblerSizing.iconMd,
          // `color: 'var(--neutral-900)'` — `--ink`, i.e. textPrimary.
          color: colors.textPrimary,
        ),
      ),
    );

    return Semantics(
      container: true,
      button: true,
      enabled: action.onPressed != null,
      label: action.label,
      onTap: action.onPressed,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: action.onPressed,
          child: DabblerFocusRing(
            borderRadius: DabblerRadius.pillAll,
            child: DabblerPressScale.gesture(
              enabled: action.onPressed != null,
              child: body,
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
  Widget _avatar() {
    final Widget avatar = DabblerAvatar(
      seed: avatarSeed,
      size: DabblerAvatarSize.sm,
      badge: avatarBadge,
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
/// inlines (`components/navigation/NavigationTopBar.jsx:51-113`).
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
      0, 0.211,
      0, 14.904, 0, 8.12, 3.543, 4.59, 10.529, 4.59, 10.529, 0,
      14.234, 0, 14.234, 18.603, 3.684, 18.603, 3.684, 14.904, 0, 14.904,
      -1,
      3.725, 14.906, 10.529, 14.906, 10.529, 8.287, 3.725, 8.287, 3.725, 14.906,
    ],
    // a — left 16.082, top 4.801
    <double>[
      16.082, 4.801,
      0.02, 14.012, 0, 14.012, 0, 5.146, 10.509, 5.146, 10.509, 3.696,
      0, 3.696, 0, 0, 10.691, 0, 14.214, 3.529, 14.214, 14.012,
      3.704, 14.012, 3.704, 10.314, 10.509, 10.316, 10.509, 8.383,
      3.704, 8.383, 3.704, 10.314, 0.02, 10.314, 0.02, 14.012,
    ],
    // b — left 32.16, top 0.21
    <double>[
      32.16, 0.21,
      0, 18.603, 0, 0, 3.684, 0, 3.684, 4.59, 10.67, 4.59, 14.194, 8.12,
      14.194, 18.603, 3.684, 18.603, 3.684, 14.904, 10.509, 14.906,
      10.509, 8.287, 3.684, 8.287, 3.684, 14.904, 0, 14.904, 0, 18.603,
    ],
    // b — left 48.222, top 0.21 (the same glyph, moved)
    <double>[
      48.222, 0.21,
      0, 18.603, 0, 0, 3.684, 0, 3.684, 4.59, 10.67, 4.59, 14.194, 8.12,
      14.194, 18.603, 3.684, 18.603, 3.684, 14.904, 10.509, 14.906,
      10.509, 8.287, 3.684, 8.287, 3.684, 14.904, 0, 14.904, 0, 18.603,
    ],
    // l — left 64.276, top 0.186
    <double>[
      64.276, 0.186,
      0, 15.098, 0, 0, 3.725, 0, 3.725, 14.93, 6.543, 14.93,
      6.543, 18.627, 3.523, 18.627, 0, 15.098,
    ],
    // e — left 72.676, top 4.801
    <double>[
      72.676, 4.801,
      0, 10.314, 0, 0, 10.67, 0, 14.214, 3.529, 14.214, 8.866,
      3.704, 8.866, 3.704, 10.314, 0, 10.314,
      -1,
      3.704, 10.314, 14.214, 10.316, 14.214, 14.012, 3.704, 14.012, 3.704, 10.314,
      -1,
      3.704, 5.629, 10.51, 5.629, 10.51, 3.696, 3.704, 3.696, 3.704, 5.629,
    ],
    // r — left 88.745, top 4.801
    <double>[
      88.745, 4.801,
      0, 14.012, 0, 3.529, 3.523, 0, 11.255, 0, 11.255, 3.696,
      3.684, 3.696, 3.684, 14.012, 0, 14.012,
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
    final Color tint = color ??
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
