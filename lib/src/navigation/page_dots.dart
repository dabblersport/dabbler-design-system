import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';

/// Builds the label a page dot is read as, from its zero-based [index] and
/// the [count] of pages.
typedef DabblerPageDotLabel = String Function(int index, int count);

/// PageDots — the position indicator under a carousel.
///
/// Transcribed from the welcome carousel,
/// `Auth and Onboarding.dc.html:77-81` and `:1874-1878`: a row of pills,
/// `height: 6px`, `gap: 6px`, `--radius-pill`; the active one `24px` wide in
/// `--color-brand-primary`, the rest `6px` in `--outline-strong`, the width
/// animating over `120ms var(--ease-out)`. Each dot jumps to its page on tap.
///
/// ```dart
/// DabblerPageDots(
///   count: 4,
///   index: page,
///   onSelected: (int i) => controller.animateToPage(i, ...),
/// )
/// ```
///
/// | part | token |
/// |---|---|
/// | dot height, idle width, gap | [DabblerSpacing.space2] (6) |
/// | active width | [DabblerSpacing.space8] (24) |
/// | active fill | [DabblerColors.brandPrimary] |
/// | idle fill | [DabblerColors.borderStrong] (`--outline-strong`) |
///
/// ## Tappable is optional
///
/// With [onSelected] null the row is a single read-only node ("Page 2 of 4").
/// With it, every dot is a button with a selected state and a
/// [DabblerSizing.touchTargetMin]-tall hit area, so a 6px dot is still a
/// 45px target vertically.
///
/// ## RTL
///
/// The dots are a [Row]: page one is at the inline start — the right edge in
/// RTL, matching a [PageView] that also runs right-to-left.
///
/// ## Motion
///
/// Width and colour animate over [DabblerMotion.base]; under reduced motion
/// they snap.
class DabblerPageDots extends StatelessWidget {
  /// Creates a page indicator.
  const DabblerPageDots({
    super.key,
    required this.count,
    required this.index,
    this.onSelected,
    this.semanticLabelBuilder,
    this.compactHitArea = false,
  }) : assert(count > 0, 'there is at least one page'),
       assert(index >= 0 && index < count, 'index must be a page');

  /// How many pages there are.
  final int count;

  /// The zero-based page on screen.
  final int index;

  /// Called with a dot's index when it is tapped. Null makes the row static.
  final ValueChanged<int>? onSelected;

  /// Builds each dot's label — pass a localised one. Defaults to
  /// "Page N of M".
  final DabblerPageDotLabel? semanticLabelBuilder;

  /// Whether a tappable row ([onSelected] set) drops the
  /// [DabblerSizing.touchTargetMin]-tall hit area and is exactly as tall as
  /// its 6px dots, as the frame draws them
  /// (`Auth and Onboarding.dc.html:77-81`). Default false keeps the 45px
  /// target. Use it where another control (a swipe, a Next button) already
  /// carries the action and the dots only echo it. A static row
  /// ([onSelected] null) is always compact.
  final bool compactHitArea;

  /// The width of the active dot.
  static const double activeWidth = DabblerSpacing.space8;

  /// The width and height of an idle dot.
  static const double dotSize = DabblerSpacing.space2;

  static String _defaultLabel(int index, int count) =>
      'Page ${index + 1} of $count';

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Duration duration = DabblerMotion.reduceMotion(context)
        ? Duration.zero
        : DabblerMotion.base;
    final DabblerPageDotLabel labelOf = semanticLabelBuilder ?? _defaultLabel;

    Widget dot(int i) => AnimatedContainer(
      key: ValueKey<int>(i),
      duration: duration,
      curve: DabblerMotion.easeOut,
      width: i == index ? activeWidth : dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: i == index ? colors.brandPrimary : colors.borderStrong,
        borderRadius: DabblerRadius.pillAll,
      ),
    );

    if (onSelected == null) {
      final List<Widget> children = <Widget>[];
      for (int i = 0; i < count; i++) {
        if (i > 0) {
          children.add(const SizedBox(width: DabblerSpacing.space2));
        }
        children.add(dot(i));
      }
      return Semantics(
        container: true,
        label: labelOf(index, count),
        child: ExcludeSemantics(
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        ),
      );
    }

    final List<Widget> children = <Widget>[];
    for (int i = 0; i < count; i++) {
      children.add(
        Semantics(
          button: true,
          selected: i == index,
          label: labelOf(i, count),
          onTap: () => onSelected!(i),
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected!(i),
              child: compactHitArea
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DabblerSpacing.space1,
                      ),
                      child: dot(i),
                    )
                  : SizedBox(
                      height: DabblerSizing.touchTargetMin,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DabblerSpacing.space1,
                        ),
                        child: Center(child: dot(i)),
                      ),
                    ),
            ),
          ),
        ),
      );
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
