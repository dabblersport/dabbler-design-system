import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/text.dart';
import '../surfaces/badge.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_layout.dart';
import '../tokens/dabbler_type.dart';
import 'progress_bar.dart';

/// ProgressCard — one stage of a multi-stage goal: a badge naming the stage,
/// a tick when it is done, a count at the inline end, and a progress bar.
///
/// Built for the check-in challenge ("Week 1 — 3/7 days") and any goal that
/// is a short run of equal stages.
///
/// ```dart
/// DabblerProgressCard(
///   label: 'Week 1',
///   caption: '3/7 days',
///   value: 3 / 7,
///   active: true,
/// )
/// ```
///
/// ## Active and settled
///
/// [active] sets the card on the brand tint and the count in the brand ink;
/// otherwise the card is the grey surface and the count is secondary. A
/// [completed] stage adds the bold brand tick after the badge.
///
/// ## RTL
///
/// The badge and tick are at the inline start, the count at the inline end;
/// the bar fills from the inline start.
class DabblerProgressCard extends StatelessWidget {
  /// A progress card.
  const DabblerProgressCard({
    super.key,
    required this.label,
    required this.caption,
    required this.value,
    this.active = false,
    this.completed = false,
  });

  /// The stage's name, in a badge.
  final String label;

  /// The count at the inline end ("3/7 days").
  final String caption;

  /// The bar's fill, 0 to 1.
  final double value;

  /// Whether this is the stage in progress.
  final bool active;

  /// Whether the stage is done.
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return DabblerSurface(
      variant: active
          ? DabblerSurfaceVariant.brandTint
          : DabblerSurfaceVariant.grey,
      padding: DabblerInsets.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              DabblerBadge(label: label),
              if (completed) ...<Widget>[
                const SizedBox(width: DabblerSpacing.space2),
                DabblerIcon(
                  'tick-circle',
                  size: DabblerSizing.iconInline,
                  weight: DabblerIconWeight.bold,
                  color: colors.brandPrimary,
                ),
              ],
              const Spacer(),
              DabblerText(
                caption,
                style: DabblerType.caption1,
                tone: active
                    ? DabblerTextTone.brand
                    : DabblerTextTone.secondary,
              ),
            ],
          ),
          const SizedBox(height: DabblerSpacing.space2),
          DabblerProgressBar(value: value, size: DabblerProgressBarSize.sm),
        ],
      ),
    );
  }
}
