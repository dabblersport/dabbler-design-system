/// The two small parts the Home Feed rows (`DabblerPostRow`,
/// `DabblerNewsCard`, `DabblerActivityRow`) share: a tappable wrapper and an
/// icon-with-count action.
///
/// Both are public because the three rows live in separate libraries; they are
/// also usable on their own wherever a feed-shaped surface needs them.
///
/// Source: Claude Design file `Home Feed.dc.html` (DesignSync, truncated at
/// 256 KiB — the markup is complete, see the row dartdocs).
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// Wraps [child] so the whole of it is one focusable, tappable region.
///
/// With [onTap] null it is inert and adds nothing: no semantics, no focus.
/// With [onTap] it is a button: `Semantics(button, label)`, the shared focus
/// ring on keyboard focus, Enter/Space activation, and a pointer cursor.
class DabblerFeedTappable extends StatefulWidget {
  /// Makes [child] tappable when [onTap] is set.
  const DabblerFeedTappable({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.borderRadius = BorderRadius.zero,
    this.excludeChildSemantics = false,
  });

  /// The tappable content.
  final Widget child;

  /// Invoked on tap or keyboard activation. Null leaves [child] inert.
  final VoidCallback? onTap;

  /// The accessible name. Null lets the descendants' text compose the name.
  final String? semanticLabel;

  /// The focus ring's corner radius.
  final BorderRadius borderRadius;

  /// Whether descendants are hidden from assistive technology, so that only
  /// [semanticLabel] is announced. Use it for a leaf action; leave it false for
  /// a row that contains its own nested actions.
  final bool excludeChildSemantics;

  @override
  State<DabblerFeedTappable> createState() => _DabblerFeedTappableState();
}

class _DabblerFeedTappableState extends State<DabblerFeedTappable> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? onTap = widget.onTap;
    if (onTap == null) return widget.child;
    final Widget body = FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (bool v) => setState(() => _focused = v),
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            onTap();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DabblerFocusRing.visible(
          visible: _focused,
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      ),
    );
    return Semantics(
      button: true,
      container: widget.excludeChildSemantics,
      label: widget.semanticLabel,
      onTap: onTap,
      child: widget.excludeChildSemantics
          ? ExcludeSemantics(child: body)
          : body,
    );
  }
}

/// One icon, optionally followed by a count — the post row's like / reply /
/// share / more actions and the news card's like / comment / view figures.
///
/// With [onTap] it is a button with a [DabblerSizing.touchTargetMin] (45)
/// minimum hit box on both axes; the painted icon and count keep the design's
/// size. Without it, it is a plain figure (the news card's view count).
///
/// The count is a number, drawn with Western digits in either direction.
class DabblerFeedAction extends StatelessWidget {
  /// An action drawing the Iconsax [icon] and an optional [count].
  const DabblerFeedAction({
    super.key,
    required this.icon,
    this.count,
    this.iconSize = 20,
    this.weight = DabblerIconWeight.linear,
    this.color,
    this.onTap,
    this.semanticLabel,
  });

  /// The kebab-case Iconsax name.
  final String icon;

  /// The figure beside the icon; null draws the icon alone.
  final int? count;

  /// The glyph's square side: 20 in the post row, 18 in the news card.
  final double iconSize;

  /// Linear, or bold for an active state (a liked heart).
  final DabblerIconWeight weight;

  /// The ink of icon and count. Null is `textSecondary`.
  final Color? color;

  /// Makes the action a button. Null leaves it a plain figure.
  final VoidCallback? onTap;

  /// The accessible name; the count is appended when there is one.
  final String? semanticLabel;

  /// Icon-to-count gap — the design's 6px (`gap:6px`), `space2`.
  static const double gap = DabblerSpacing.space2;

  /// The accessible name composed from [semanticLabel] and [count].
  String? get composedLabel => semanticLabel == null
      ? null
      : (count == null ? semanticLabel : '$semanticLabel, $count');

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final Color ink = color ?? colors.textSecondary;
    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ExcludeSemantics(
          child: DabblerIcon(icon, size: iconSize, weight: weight, color: ink),
        ),
        if (count != null) ...<Widget>[
          const SizedBox(width: gap),
          Text(
            DabblerType.toWesternDigits('$count'),
            maxLines: 1,
            style: DabblerType.caption1
                .resolveForDirection(dir)
                .copyWith(color: ink),
          ),
        ],
      ],
    );
    if (onTap == null) {
      return Semantics(
        label: composedLabel,
        container: composedLabel != null,
        excludeSemantics: composedLabel != null,
        child: content,
      );
    }
    return DabblerFeedTappable(
      onTap: onTap,
      semanticLabel: composedLabel,
      excludeChildSemantics: true,
      borderRadius: DabblerRadius.pillAll,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: DabblerSizing.touchTargetMin,
          minHeight: DabblerSizing.touchTargetMin,
        ),
        child: Center(widthFactor: 1, heightFactor: 1, child: content),
      ),
    );
  }
}
