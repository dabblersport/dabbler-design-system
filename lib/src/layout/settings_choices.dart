/// The choice parts the Settings sub-pages are built from:
/// [DabblerPresetCard] (one of a stack of described options, the chosen one
/// filled), [DabblerOptionSegments] (a card holding a row of icon-over-label
/// options).
///
/// Source: Claude Design file `Settings.dc.html` — the preset cards at
/// `:317-345`, the segmented options at `:347-366`.
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// A described option in a stack of choices — leading glyph, a title over a
/// description, and, when [selected], a brand fill with a trailing check.
///
/// The Settings privacy presets and the Home-screen view picker draw it:
/// exactly one card of a stack is selected, and selecting another is the
/// caller's. The card holds no state; a null [onTap] disables it.
class DabblerPresetCard extends StatefulWidget {
  /// A card for [title] over [description].
  const DabblerPresetCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.selected = false,
    this.onTap,
    this.semanticLabel,
  });

  /// The leading Iconsax glyph name; bold when [selected].
  final String icon;

  /// The option's name.
  final String title;

  /// A line describing what the option does.
  final String description;

  /// Whether this is the chosen option.
  final bool selected;

  /// Called when the card is tapped. Null disables the card.
  final VoidCallback? onTap;

  /// The accessible name. Null reads [title] and [description].
  final String? semanticLabel;

  /// The trailing check's glyph while [selected].
  static const String checkIconName = 'tick-circle';

  @override
  State<DabblerPresetCard> createState() => _DabblerPresetCardState();
}

class _DabblerPresetCardState extends State<DabblerPresetCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final bool on = widget.selected;
    final Color ink = on ? colors.onBrand : colors.textPrimary;
    final Color soft = on ? colors.onBrand : colors.textSecondary;

    final Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 1),
          child: DabblerIcon(
            widget.icon,
            weight: on ? DabblerIconWeight.bold : DabblerIconWeight.linear,
            size: DabblerSizing.iconRow,
            color: on ? colors.onBrand : colors.textSecondary,
          ),
        ),
        const SizedBox(width: DabblerSpacing.space4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.title,
                style: DabblerType.subheadline
                    .resolveForDirection(dir)
                    .copyWith(color: ink, fontWeight: DabblerType.semibold),
              ),
              const SizedBox(height: DabblerSpacing.space1),
              Text(
                widget.description,
                style: DabblerType.footnote
                    .resolveForDirection(dir)
                    .copyWith(color: soft),
              ),
            ],
          ),
        ),
        if (on) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space4),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 1),
            child: DabblerIcon(
              DabblerPresetCard.checkIconName,
              weight: DabblerIconWeight.bold,
              size: DabblerSizing.iconRow,
              color: colors.onBrand,
            ),
          ),
        ],
      ],
    );

    final Widget surface = on
        ? DabblerSurface.selected(
            radius: DabblerRadius.lg,
            padding: const EdgeInsets.all(DabblerSpacing.space5),
            child: content,
          )
        : DabblerSurface.card(
            radius: DabblerRadius.lg,
            padding: const EdgeInsets.all(DabblerSpacing.space5),
            child: content,
          );

    return _Pressable(
      radius: DabblerRadius.lg,
      onTap: widget.onTap,
      focused: _focused,
      onFocusChange: (bool v) => setState(() => _focused = v),
      semanticLabel:
          widget.semanticLabel ?? '${widget.title}, ${widget.description}',
      selected: on,
      child: surface,
    );
  }
}

/// One option of a [DabblerOptionSegments].
@immutable
class DabblerOptionSegment {
  /// An option identified by [id], drawn as [icon] over [label].
  const DabblerOptionSegment({
    required this.id,
    required this.label,
    required this.icon,
  });

  /// The option's identity, passed to [DabblerOptionSegments.onChanged].
  final String id;

  /// The option's name, under the glyph.
  final String label;

  /// The Iconsax glyph name; bold while the option is chosen.
  final String icon;
}

/// A card holding a row of equal icon-over-label options, the chosen one
/// filled with the brand colour. The Settings theme picker (light, dark,
/// system) draws it.
///
/// Controlled: [value] is the chosen option's id and the caller redraws on
/// [onChanged]. A [value] matching no option highlights none — a mode that is
/// overridden elsewhere can say so.
class DabblerOptionSegments extends StatelessWidget {
  /// Segments over [items].
  const DabblerOptionSegments({
    super.key,
    required this.items,
    required this.value,
    this.onChanged,
    this.semanticLabel,
  });

  /// The options, in reading order.
  final List<DabblerOptionSegment> items;

  /// The chosen option's id, or null for none.
  final String? value;

  /// Called with the tapped option's id. Null disables every option.
  final ValueChanged<String>? onChanged;

  /// The accessible name of the group.
  final String? semanticLabel;

  /// The height of one option, `76px` in `Settings.dc.html:349`.
  static const double segmentHeight = 76;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel,
      child: DabblerSurface.card(
        radius: DabblerRadius.xl,
        padding: const EdgeInsets.all(DabblerSpacing.space2),
        child: Row(
          children: <Widget>[
            for (int i = 0; i < items.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: DabblerSpacing.space2),
              Expanded(
                child: _Segment(
                  item: items[i],
                  selected: items[i].id == value,
                  onTap: onChanged == null
                      ? null
                      : () => onChanged!(items[i].id),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatefulWidget {
  const _Segment({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final DabblerOptionSegment item;
  final bool selected;
  final VoidCallback? onTap;

  @override
  State<_Segment> createState() => _SegmentState();
}

class _SegmentState extends State<_Segment> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final bool on = widget.selected;
    final Color ink = on ? colors.onBrand : colors.textSecondary;

    final Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        DabblerIcon(
          widget.item.icon,
          weight: on ? DabblerIconWeight.bold : DabblerIconWeight.linear,
          size: DabblerSizing.iconRow,
          color: ink,
        ),
        const SizedBox(height: DabblerSpacing.space2),
        Text(
          widget.item.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: DabblerType.footnote
              .resolveForDirection(dir)
              .copyWith(color: ink, fontWeight: DabblerType.semibold),
        ),
      ],
    );

    final Widget body = on
        ? DabblerSurface.selected(
            radius: DabblerRadius.md,
            height: DabblerOptionSegments.segmentHeight,
            center: true,
            child: content,
          )
        : SizedBox(
            height: DabblerOptionSegments.segmentHeight,
            child: Center(child: content),
          );

    return _Pressable(
      radius: DabblerRadius.md,
      onTap: widget.onTap,
      focused: _focused,
      onFocusChange: (bool v) => setState(() => _focused = v),
      semanticLabel: widget.item.label,
      selected: on,
      child: body,
    );
  }
}

/// One choice in a sheet's list — a bordered card row holding a label and, when
/// [selected], a brand `tick-circle` at the inline end
/// (`Settings.dc.html:368-378`). The audience and language sheets draw it.
class DabblerOptionRow extends StatefulWidget {
  /// A row reading [label].
  const DabblerOptionRow({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  /// The option's name.
  final String label;

  /// Whether this is the chosen option.
  final bool selected;

  /// Called when the row is tapped. Null disables it.
  final VoidCallback? onTap;

  /// The row's minimum height, `52px` in `Settings.dc.html:370`.
  static const double minHeight = 52;

  @override
  State<DabblerOptionRow> createState() => _DabblerOptionRowState();
}

class _DabblerOptionRowState extends State<DabblerOptionRow> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    return _Pressable(
      radius: DabblerRadius.lg,
      onTap: widget.onTap,
      focused: _focused,
      onFocusChange: (bool v) => setState(() => _focused = v),
      semanticLabel: widget.label,
      selected: widget.selected,
      child: DabblerSurface.card(
        radius: DabblerRadius.lg,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: DabblerSpacing.space5,
          vertical: DabblerSpacing.space4,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: DabblerOptionRow.minHeight - 2 * DabblerSpacing.space4,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.label,
                  style: DabblerType.subheadline
                      .resolveForDirection(dir)
                      .copyWith(color: colors.textPrimary),
                ),
              ),
              if (widget.selected)
                DabblerIcon(
                  DabblerPresetCard.checkIconName,
                  weight: DabblerIconWeight.bold,
                  size: DabblerSizing.iconRow,
                  color: colors.brandPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The tap, focus ring, press scale and semantics the two choice parts share.
class _Pressable extends StatelessWidget {
  const _Pressable({
    required this.radius,
    required this.onTap,
    required this.focused,
    required this.onFocusChange,
    required this.semanticLabel,
    required this.selected,
    required this.child,
  });

  final double radius;
  final VoidCallback? onTap;
  final bool focused;
  final ValueChanged<bool> onFocusChange;
  final String semanticLabel;
  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      enabled: enabled,
      label: semanticLabel,
      onTap: onTap,
      child: ExcludeSemantics(
        child: DabblerFocusRing.visible(
          visible: focused,
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          child: FocusableActionDetector(
            enabled: enabled,
            mouseCursor: enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            onShowFocusHighlight: onFocusChange,
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  onTap?.call();
                  return null;
                },
              ),
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: DabblerPressScale.gesture(enabled: enabled, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
