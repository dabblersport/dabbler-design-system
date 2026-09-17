import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';

/// The two frames an [DabblerAccordion] can wear — `AccordionVariant` in
/// `components/layout/Accordion.d.ts`.
enum DabblerAccordionVariant {
  /// Sits inline in a content column, items separated by `--faint` rules.
  plain,

  /// Each item wrapped in the standard card surface + hairline, with
  /// `--space-3` between them.
  card,
}

/// One collapsible section of a [DabblerAccordion].
@immutable
class DabblerAccordionItem {
  /// Creates a section.
  const DabblerAccordionItem({
    required this.id,
    required this.title,
    required this.content,
    this.icon,
  });

  /// Stable id, compared against [DabblerAccordion.value].
  final String id;

  /// The header text, in [DabblerType.headline].
  final String title;

  /// The body, revealed by [DabblerCollapse].
  final Widget content;

  /// Optional leading Iconsax glyph, drawn at 24 in
  /// [DabblerColors.brandPrimary] (`Accordion.jsx:107`).
  final String? icon;
}

/// Collapse — **the system's one expand/collapse animation**.
///
/// Transcribed from `Collapse` in `components/layout/Accordion.jsx:13-25`,
/// where the web version animates a grid row track `0fr → 1fr` over
/// `--motion-base` so *"height is never measured in JS and never hard-coded"*.
/// [Align]`.heightFactor` is the direct Flutter equivalent: it takes the
/// child's own intrinsic height and reveals a fraction of it, so content of
/// any size animates correctly with nothing measured.
///
/// Nothing in the package should hand-roll a height transition; compose this.
/// Under [DabblerMotion.reduceMotion] the child simply appears.
class DabblerCollapse extends StatelessWidget {
  /// Creates a collapsible region.
  const DabblerCollapse({
    super.key,
    required this.open,
    required this.child,
  });

  /// Whether the child is revealed.
  final bool open;

  /// The content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: DabblerMotion.reduceMotion(context)
          ? Duration.zero
          : DabblerMotion.base,
      curve: DabblerMotion.easeOut,
      alignment: Alignment.topCenter,
      child: open
          ? child
          // `<div style={{overflow:'hidden', minHeight:0}}>` collapsed to a
          // zero track. The subtree is dropped rather than hidden, which is
          // the Flutter equivalent of `aria-hidden` on the collapsed row.
          : const SizedBox(width: double.infinity, height: 0),
    );
  }
}

/// Accordion — collapsible sections for content that is secondary but not
/// hidden: FAQs, venue rules, refund terms.
///
/// Transcribed from `components/layout/Accordion.jsx`. **This component did
/// not exist in the package before this pass**: the design draws it on
/// `components/layout/structure.card.html` and the Flutter cut skipped both it
/// and [DabblerCollapse].
///
/// Single-open by default; [multiple] allows several at once. Controlled by
/// passing [value] (a single id, or a `List<String>` under [multiple]),
/// uncontrolled otherwise — the source's own pair rule.
///
/// ## Flat
///
/// Fill, hairline, [DabblerRadius.lg] under [DabblerAccordionVariant.card].
/// No shadow.
class DabblerAccordion extends StatefulWidget {
  /// Creates an accordion.
  const DabblerAccordion({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.multiple = false,
    this.variant = DabblerAccordionVariant.plain,
  });

  /// The sections, in order.
  final List<DabblerAccordionItem> items;

  /// Controlled open state: a `String` id, or a `List<String>` when
  /// [multiple]. Omit to let the widget hold it.
  final Object? value;

  /// Fired with the new open state — the same shape as [value].
  final ValueChanged<Object?>? onChanged;

  /// Whether more than one section may be open.
  final bool multiple;

  /// Which frame the items wear.
  final DabblerAccordionVariant variant;

  @override
  State<DabblerAccordion> createState() => _DabblerAccordionState();
}

class _DabblerAccordionState extends State<DabblerAccordion> {
  Object? _own;

  bool get _controlled => widget.value != null;

  Object? get _current => _controlled ? widget.value : _own;

  bool _isOpen(String id) {
    final Object? current = _current;
    if (widget.multiple) {
      return current is List && current.contains(id);
    }
    return current == id;
  }

  void _toggle(String id) {
    final Object? next;
    if (widget.multiple) {
      final List<String> open = <String>[
        if (_current case final List<Object?> list) ...list.cast<String>(),
      ];
      next = _isOpen(id)
          ? (open..remove(id))
          : (open..add(id));
    } else {
      next = _isOpen(id) ? null : id;
    }
    if (!_controlled) {
      setState(() => _own = next);
    }
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final bool card = widget.variant == DabblerAccordionVariant.card;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      // `gap: variant === 'card' ? var(--space-3) : 0` (`Accordion.jsx:60`).
      spacing: card ? DabblerSpacing.space3 : 0,
      children: <Widget>[
        for (int i = 0; i < widget.items.length; i++)
          _DabblerAccordionItemView(
            item: widget.items[i],
            variant: widget.variant,
            open: _isOpen(widget.items[i].id),
            onToggle: () => _toggle(widget.items[i].id),
            // `separator: variant === 'plain' && i < items.length - 1`.
            separator: !card && i < widget.items.length - 1,
          ),
      ],
    );
  }
}

class _DabblerAccordionItemView extends StatelessWidget {
  const _DabblerAccordionItemView({
    required this.item,
    required this.variant,
    required this.open,
    required this.onToggle,
    required this.separator,
  });

  final DabblerAccordionItem item;
  final DabblerAccordionVariant variant;
  final bool open;
  final VoidCallback onToggle;
  final bool separator;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool card = variant == DabblerAccordionVariant.card;

    final Widget header = Semantics(
      container: true,
      button: true,
      expanded: open,
      label: item.title,
      onTap: onToggle,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onToggle,
          child: DabblerFocusRing(
            borderRadius: DabblerRadius.smAll,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: DabblerSizing.touchTargetMin,
              ),
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                // `gap: var(--space-3)` (`Accordion.jsx:100`).
                spacing: DabblerSpacing.space3,
                children: <Widget>[
                  if (item.icon != null)
                    DabblerIcon(
                      item.icon!,
                      size: DabblerSizing.iconMd,
                      color: colors.brandPrimary,
                    ),
                  Expanded(
                    child: Text(
                      item.title,
                      style: DabblerType.headline
                          .resolveForDirection(direction)
                          .copyWith(color: colors.textPrimary),
                    ),
                  ),
                  // `transform: rotate(180deg)` on open (`Accordion.jsx:110`).
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: DabblerMotion.reduceMotion(context)
                        ? Duration.zero
                        : DabblerMotion.base,
                    curve: DabblerMotion.easeOut,
                    child: DabblerIcon(
                      'arrow-down',
                      size: DabblerSizing.iconSm,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        header,
        DabblerCollapse(
          open: open,
          child: Padding(
            // `paddingBlockEnd: var(--space-4)` (`Accordion.jsx:116`).
            padding: const EdgeInsetsDirectional.only(
              bottom: DabblerSpacing.space4,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: item.content,
            ),
          ),
        ),
      ],
    );

    return Container(
      padding: card
          // `paddingInline: var(--space-5)` (`Accordion.jsx:93`).
          ? const EdgeInsetsDirectional.symmetric(
              horizontal: DabblerSpacing.space5,
            )
          : null,
      decoration: BoxDecoration(
        color: card ? colors.surfaceCard : null,
        borderRadius: card ? DabblerRadius.lgAll : null,
        border: card
            ? Border.all(
                color: colors.borderDefault,
                width: DabblerSizing.borderDefault,
              )
            // `borderBlockEnd: 1px solid var(--faint)` between plain items.
            : separator
                ? Border(
                    bottom: BorderSide(
                      color: colors.bgTertiary,
                      width: DabblerSizing.borderDefault,
                    ),
                  )
                : null,
      ),
      child: body,
    );
  }
}
