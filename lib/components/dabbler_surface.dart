// =============================================================================
// Dabbler — Surface layout: section grouping · list tile · chevron
// -----------------------------------------------------------------------------
// Flat, token-driven building blocks that sit on the tinted-neutral ladder.
// No shadows. RTL-safe throughout: sides use start/end (never left/right) so
// titles, trailing actions, divider insets, and chevron glyphs all mirror.
//
// NOTE: the titled grouping is `DabblerSurfaceSection`, not `DabblerSection` —
// `DabblerSection` is already the (home/sport/social/active) theme-section enum
// in dabbler_colors.dart, a foundation token we don't rename.
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/dabbler_colors.dart';
import '../theme/dabbler_spacing.dart';
import '../theme/dabbler_type.dart';

/// A titled group of content for a screen: optional title (title3) + optional
/// trailing action (e.g. a `DabblerButton.text` "See all") + optional subtitle
/// (footnote), then [children] stacked with `stackDefault` between them.
///
/// Title and action live in a [Row], so they swap sides under RTL.
class DabblerSurfaceSection extends StatelessWidget {
  const DabblerSurfaceSection({
    super.key,
    this.title,
    this.subtitle,
    this.action,
    required this.children,
  });

  final String? title;
  final String? subtitle;
  final Widget? action;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    TextStyle a(TextStyle s) => rtl ? DabblerType.arabic(s) : s;

    final hasHeader = title != null || action != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasHeader)
          Row(
            children: [
              if (title != null)
                Expanded(
                  child: Text(
                    title!,
                    style: a(DabblerType.title3).copyWith(color: d.textPrimary),
                  ),
                )
              else
                const Spacer(),
              if (action != null) action!,
            ],
          ),
        if (subtitle != null) ...[
          const SizedBox(height: DabblerSpacing.stackTight),
          Text(
            subtitle!,
            style: a(DabblerType.footnote).copyWith(color: d.textSecondary),
          ),
        ],
        if (hasHeader && children.isNotEmpty)
          const SizedBox(height: DabblerSpacing.stackDefault),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: DabblerSpacing.stackDefault), // 12
          children[i],
        ],
      ],
    );
  }
}

/// A directional chevron that mirrors its glyph under RTL (› → ‹).
class DabblerChevron extends StatelessWidget {
  const DabblerChevron({super.key});

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Icon(
      rtl ? Icons.chevron_left : Icons.chevron_right,
      size: DabblerSizing.iconMd,
      color: context.dabbler.textTertiary,
    );
  }
}

/// The workhorse row: leading · (title / subtitle) · trailing. Flat, token-
/// driven, with a tonal press. The optional divider is inset to align with the
/// title and mirrors under RTL.
class DabblerListTile extends StatefulWidget {
  const DabblerListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.selected = false,
    this.dense = false,
    this.showDivider = false,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final bool selected;
  final bool dense;
  final bool showDivider;

  /// Leading lane width — the leading slot is centred in it so the title (and
  /// therefore the divider inset) starts at a consistent offset.
  static const double _leadingLane = DabblerSpacing.space9; // 30
  static const double _gap = DabblerSpacing.space3; // 9

  bool get _tappable => enabled && onTap != null;

  @override
  State<DabblerListTile> createState() => _DabblerListTileState();
}

class _DabblerListTileState extends State<DabblerListTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    TextStyle a(TextStyle s) => rtl ? DabblerType.arabic(s) : s;

    final minHeight = widget.dense
        ? DabblerSpacing.space10 // 36
        : DabblerSizing.touchTargetMin; // 45

    final titleColor = widget.enabled ? d.textPrimary : d.textTertiary;
    final subtitleColor = widget.enabled ? d.textSecondary : d.textTertiary;

    final row = Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: DabblerSpacing.space4, // 12
        vertical: DabblerSpacing.space3, // 9
      ),
      child: Row(
        children: [
          if (widget.leading != null) ...[
            SizedBox(
              width: DabblerListTile._leadingLane,
              child: Center(child: widget.leading),
            ),
            const SizedBox(width: DabblerListTile._gap),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: a(DabblerType.body).copyWith(color: titleColor),
                ),
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    style:
                        a(DabblerType.footnote).copyWith(color: subtitleColor),
                  ),
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: DabblerListTile._gap),
            widget.trailing!,
          ],
        ],
      ),
    );

    // Background: tonal press → bgTertiary; selected → subtle brand tint.
    final Color bg;
    if (_pressed && widget._tappable) {
      bg = d.bgTertiary;
    } else if (widget.selected) {
      bg = Color.lerp(d.surfaceCard, d.brandPrimary, 0.08)!;
    } else {
      bg = Colors.transparent;
    }

    Widget tile = Material(
      color: bg,
      // ignore: avoid_redundant_argument_values  (explicit: the flat-elevation rule)
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: widget._tappable
            ? InkWell(
                onTap: widget.onTap,
                onHighlightChanged: (h) => setState(() => _pressed = h),
                child: row,
              )
            : row,
      ),
    );

    if (!widget.enabled) {
      tile = Opacity(opacity: 0.5, child: tile);
    }

    if (!widget.showDivider) return tile;

    // Divider inset to the title's start edge; start-inset mirrors under RTL.
    final inset = DabblerSpacing.space4 +
        (widget.leading != null
            ? DabblerListTile._leadingLane + DabblerListTile._gap
            : 0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        Padding(
          padding: EdgeInsetsDirectional.only(start: inset.toDouble()),
          child: Container(
            height: DabblerSizing.borderHairline, // 0.5px
            color: d.borderDefault,
          ),
        ),
      ],
    );
  }
}
