import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';

/// StepProgress — the segmented bar at the top of a multi-step flow.
///
/// Transcribed from the onboarding step header,
/// `Auth and Onboarding.dc.html:333-339`: a row of [count] equal segments,
/// `height: 4px`, `gap: 5px`, `--radius-pill`, each painted
/// `i <= active ? --color-brand-primary : --faint` (`segs()`, `:1386-1388`),
/// and under it an optional uppercase step label (`12/16`, weight 600,
/// `--muted`, `:337`) such as *"Step 3 of 5"*.
///
/// ```dart
/// DabblerStepProgress(count: 5, current: 2, label: 'Step 3 of 5')
/// ```
///
/// [current] is the zero-based index of the step on screen. Segments before
/// it are **completed**, the segment at it is **current**, the rest are
/// upcoming. Completed and current share the brand fill, as the design draws
/// them; [isCompleted] / [isCurrent] expose the distinction for callers and
/// tests, and the semantics value reads "step N of M".
///
/// **Missing tokens, named not resolved:** no 4px or 5px token exists on the
/// 3pt grid. The frame's `height: 4px` and `gap: 5px` are therefore the
/// literals [defaultSegmentHeight] and [defaultSegmentGap] below, the defaults, and a caller
/// that wants the old grid-aligned 3 and 6 passes
/// [DabblerSpacing.space1] and [DabblerSpacing.space2]. Until 2026-10-04 the
/// defaults were 3 and 6.
///
/// ## Motion
///
/// A segment's fill crossfades over [DabblerMotion.base] with
/// [DabblerMotion.easeOut] (`transition: background 120ms var(--ease-out)`).
/// Under reduced motion it snaps.
///
/// ## RTL
///
/// The segments are a [Row], so step one sits at the inline start — the right
/// edge in RTL.
class DabblerStepProgress extends StatelessWidget {
  /// Creates a step progress bar.
  const DabblerStepProgress({
    super.key,
    required this.count,
    required this.current,
    this.label,
    this.semanticLabel,
    this.segmentHeight = defaultSegmentHeight,
    this.segmentGap = defaultSegmentGap,
  }) : assert(count > 0, 'a flow has at least one step'),
       assert(current >= 0 && current < count, 'current must be a step');

  /// The segments' height. Default [defaultSegmentHeight], `4`.
  final double segmentHeight;

  /// The gap between segments. Default [defaultSegmentGap], `5`.
  final double segmentGap;

  /// `height: 4px` (`Auth and Onboarding.dc.html`, the step bar). No token: see the class
  /// doc.
  static const double defaultSegmentHeight = 4;

  /// `gap: 5px` (`Auth and Onboarding.dc.html`, the step bar). No token: see the class
  /// doc.
  static const double defaultSegmentGap = 5;

  /// How many steps the flow has.
  final int count;

  /// The zero-based step on screen.
  final int current;

  /// The visible label under the bar, already localised ("Step 3 of 5").
  final String? label;

  /// Overrides what assistive technology reads. Defaults to [label], else
  /// "Step N of M".
  final String? semanticLabel;

  /// Whether segment [index] is a step already passed.
  bool isCompleted(int index) => index < current;

  /// Whether segment [index] is the step on screen.
  bool isCurrent(int index) => index == current;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final Duration duration = DabblerMotion.reduceMotion(context)
        ? Duration.zero
        : DabblerMotion.base;

    final List<Widget> segments = <Widget>[];
    for (int i = 0; i < count; i++) {
      if (i > 0) {
        segments.add(SizedBox(width: segmentGap));
      }
      segments.add(
        Expanded(
          child: AnimatedContainer(
            key: ValueKey<int>(i),
            duration: duration,
            curve: DabblerMotion.easeOut,
            height: segmentHeight,
            decoration: BoxDecoration(
              color: i <= current ? colors.brandPrimary : colors.bgTertiary,
              borderRadius: DabblerRadius.pillAll,
            ),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: semanticLabel ?? label ?? 'Step ${current + 1} of $count',
      value: '${current + 1}/$count',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(children: segments),
            if (label != null) ...<Widget>[
              const SizedBox(height: DabblerSpacing.space2),
              Text(
                label!.toUpperCase(),
                style: DabblerType.caption1
                    .resolveForDirection(direction)
                    .copyWith(
                      color: colors.textTertiary,
                      fontWeight: DabblerType.semibold,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
