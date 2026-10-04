import 'package:flutter/widgets.dart';

import '../feed/feed_atoms.dart';
import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// StepperPill — a small bounded integer in a compact pill: minus, the value,
/// plus.
///
/// Transcribed from `Home Feed.dc.html` (alpha-plan design set) lines
/// 1038-1049, the Players row of the Create game sheet: a pill with card
/// fill and a 1px hairline, `padding:5px 10px`, `gap:8px`; `minus` 14 in the
/// muted ink, the value 13/18 with a 26px minimum width, `add` 14 in the
/// brand ink.
///
/// ## Deviations
///
/// * **Targets.** Each glyph gets a 45px box, so the pill is taller than the
///   design's 30px; its paint stays the pill.
/// * **Type.** 13/18 is `footnote`.
///
/// RTL: minus leads and plus trails, mirrored by the row.
/// Accessibility: two buttons named [decreaseLabel] and [increaseLabel].
class DabblerStepperPill extends StatelessWidget {
  /// A stepper pill.
  const DabblerStepperPill({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 99,
    this.suffix,
    this.decreaseLabel = 'Decrease',
    this.increaseLabel = 'Increase',
  });

  /// The current value.
  final int value;

  /// Called with the next, clamped value.
  final ValueChanged<int>? onChanged;

  /// The lower bound.
  final int min;

  /// The upper bound.
  final int max;

  /// A word after the value (`min`, `max`).
  final String? suffix;

  /// The minus button's name.
  final String decreaseLabel;

  /// The plus button's name.
  final String increaseLabel;

  /// Glyph side — `size="14"`.
  static const double glyphSize = 14;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final bool canDown = onChanged != null && value > min;
    final bool canUp = onChanged != null && value < max;
    Widget button(String icon, String label, Color ink, bool on, int next) =>
        DabblerFeedTappable(
          onTap: on ? () => onChanged!(next.clamp(min, max)) : null,
          semanticLabel: label,
          excludeChildSemantics: true,
          borderRadius: DabblerRadius.pillAll,
          child: SizedBox(
            width: DabblerSizing.touchTargetMin,
            height: DabblerSizing.touchTargetMin,
            child: Center(
              child: DabblerIcon(
                icon,
                size: glyphSize,
                color: on ? ink : colors.textTertiary,
              ),
            ),
          ),
        );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: DabblerRadius.pillAll,
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          button(
            'minus',
            decreaseLabel,
            colors.textSecondary,
            canDown,
            value - 1,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: DabblerSpacing.space8),
            child: Text(
              DabblerType.toWesternDigits(
                suffix == null ? '$value' : '$value $suffix',
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              style: DabblerType.footnote
                  .resolveForDirection(dir)
                  .copyWith(color: colors.textPrimary),
            ),
          ),
          button('add', increaseLabel, colors.brandPrimary, canUp, value + 1),
        ],
      ),
    );
  }
}
