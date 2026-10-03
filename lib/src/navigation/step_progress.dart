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
/// **Deviation:** no 4px or 5px token exists. The segment height is
/// [DabblerSpacing.space1] (3) and the gap [DabblerSpacing.space2] (6), the
/// nearest steps on the 3pt grid.
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
  }) : assert(count > 0, 'a flow has at least one step'),
       assert(current >= 0 && current < count, 'current must be a step');

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
        segments.add(const SizedBox(width: DabblerSpacing.space2));
      }
      segments.add(
        Expanded(
          child: AnimatedContainer(
            key: ValueKey<int>(i),
            duration: duration,
            curve: DabblerMotion.easeOut,
            height: DabblerSpacing.space1,
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
