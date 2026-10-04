import 'package:flutter/widgets.dart';

import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../surfaces/badge.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// The status tint of a [DabblerProfileRow] — the pastel the Profiles design
/// takes from `--color-status-<tone>-surface`.
enum DabblerProfileRowTone {
  /// `--surface-card`, no tint.
  neutral,

  /// The success status surface.
  success,

  /// The warning status surface.
  warning,

  /// The info status surface.
  info,

  /// The error status surface.
  error,
}

/// ProfileRow — the profile screens' list row: an optional lead block (a
/// figure over a caption, or a date's weekday over its day), a title, a
/// sub-line and an optional tag pill, on a card or a status-tinted surface.
///
/// Transcribed from `Profiles.dc.html:208-222` (rows) and `:254-264` (games):
/// radius-lg, 12 padding, 12 gap, one hairline border; the lead block is a
/// `--surface-card` radius-md tile at least 54 wide with a display-face figure
/// and a 11/14 semibold caption; the tag is a card-coloured hairline pill.
///
/// With [onTap] the row is a button with the shared focus ring and press scale
/// and is at least [DabblerSizing.touchTargetMin] tall. The row mirrors in RTL
/// (everything is in flow).
class DabblerProfileRow extends StatefulWidget {
  /// A profile row.
  const DabblerProfileRow({
    super.key,
    required this.title,
    this.subtitle,
    this.lead,
    this.leadCaption,
    this.captionFirst = false,
    this.tag,
    this.tone = DabblerProfileRowTone.neutral,
    this.onTap,
    this.semanticLabel,
  });

  /// The semibold title.
  final String title;

  /// The secondary line under the title.
  final String? subtitle;

  /// The lead block's figure (`3/4`, `19`). Null draws no lead block.
  final String? lead;

  /// The lead block's caption (`filled`, `Tue`).
  final String? leadCaption;

  /// Draws [leadCaption] above [lead] (the games rows' weekday over day).
  final bool captionFirst;

  /// The trailing tag pill's label.
  final String? tag;

  /// The row's tint.
  final DabblerProfileRowTone tone;

  /// Makes the row a button.
  final VoidCallback? onTap;

  /// The accessible name; defaults to title, sub-line and tag.
  final String? semanticLabel;

  /// The lead block's minimum width — `min-width: 54`.
  static const double leadMinWidth = 54;

  @override
  State<DabblerProfileRow> createState() => _DabblerProfileRowState();
}

class _DabblerProfileRowState extends State<DabblerProfileRow> {
  bool _pressed = false;
  bool _focused = false;

  Color _fill(DabblerColors c) => switch (widget.tone) {
    DabblerProfileRowTone.neutral => c.surfaceCard,
    DabblerProfileRowTone.success => c.success.surface,
    DabblerProfileRowTone.warning => c.warning.surface,
    DabblerProfileRowTone.info => c.info.surface,
    DabblerProfileRowTone.error => c.error.surface,
  };

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final TextStyle figure = DabblerType.title3
        .resolveForDirection(dir)
        .copyWith(color: colors.textPrimary);
    final TextStyle caption = DabblerType.caption2
        .resolveForDirection(dir)
        .copyWith(color: colors.textSecondary, fontWeight: DabblerType.semibold);

    Widget? leadBlock;
    final String? lead = widget.lead;
    if (lead != null) {
      final Widget fig = Text(lead, maxLines: 1, style: figure);
      final Widget? cap = widget.leadCaption == null
          ? null
          : Text(widget.leadCaption!, maxLines: 1, style: caption);
      leadBlock = ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: DabblerProfileRow.leadMinWidth,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(DabblerRadius.md),
            border: Border.all(
              color: colors.borderDefault,
              width: DabblerSizing.borderDefault,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: DabblerSpacing.space2,
              horizontal: DabblerSpacing.space3,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (widget.captionFirst && cap != null) cap,
                fig,
                if (!widget.captionFirst && cap != null) cap,
              ],
            ),
          ),
        ),
      );
    }

    final Widget body = Row(
      children: <Widget>[
        if (leadBlock != null) ...<Widget>[
          leadBlock,
          const SizedBox(width: DabblerSpacing.space4),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DabblerType.subheadline
                    .resolveForDirection(dir)
                    .copyWith(
                      color: colors.textPrimary,
                      fontWeight: DabblerType.semibold,
                    ),
              ),
              if (widget.subtitle != null)
                Text(
                  widget.subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DabblerType.footnote
                      .resolveForDirection(dir)
                      .copyWith(color: colors.textSecondary),
                ),
            ],
          ),
        ),
        if (widget.tag != null) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space4),
          DabblerBadge(
            label: widget.tag!,
            tone: DabblerBadgeTone.success,
            fill: colors.surfaceCard,
          ),
        ],
      ],
    );

    final Widget row = DecoratedBox(
      decoration: BoxDecoration(
        color: _fill(colors),
        borderRadius: BorderRadius.circular(DabblerRadius.lg),
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DabblerSpacing.space4),
        child: body,
      ),
    );

    final String name =
        widget.semanticLabel ??
        <String>[
          widget.title,
          if (widget.subtitle != null) widget.subtitle!,
          if (widget.tag != null) widget.tag!,
        ].join(', ');

    if (widget.onTap == null) {
      return Semantics(
        container: true,
        label: name,
        child: ExcludeSemantics(child: row),
      );
    }

    return Semantics(
      button: true,
      label: name,
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: DabblerSizing.touchTargetMin,
          ),
          child: FocusableActionDetector(
            mouseCursor: SystemMouseCursors.click,
            onShowFocusHighlight: (bool v) => setState(() => _focused = v),
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (ActivateIntent intent) {
                  widget.onTap?.call();
                  return null;
                },
              ),
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              onTapDown: (TapDownDetails _) => setState(() => _pressed = true),
              onTapUp: (TapUpDetails _) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              child: DabblerFocusRing.visible(
                visible: _focused,
                enabled: true,
                borderRadius: BorderRadius.circular(DabblerRadius.lg),
                child: DabblerPressScale(
                  pressed: _pressed,
                  enabled: true,
                  child: row,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
