/// ThreadSkeleton — the placeholder a message thread shows while its first page
/// loads: received and sent message rows made of [DabblerSkeleton] blocks.
library;

import 'package:flutter/widgets.dart';

import '../feedback/skeleton.dart';
import 'messaging_foundations.dart';

/// One placeholder row: who sent it and how much of the line its bubble takes.
typedef _Row = ({bool sent, double fraction});

/// A fixed, alternating rhythm so the placeholder reads as a conversation. The
/// fractions are proportions of the line, not lengths.
const List<_Row> _rhythm = <_Row>[
  (sent: false, fraction: 0.62),
  (sent: false, fraction: 0.4),
  (sent: true, fraction: 0.5),
  (sent: false, fraction: 0.74),
  (sent: true, fraction: 0.34),
  (sent: true, fraction: 0.58),
];

/// The loading state of a message thread.
///
/// Reuses [DabblerSkeleton] (circle for the avatar well, rect for the bubble).
/// Rows alternate received (avatar start, bubble after it) and sent (bubble at
/// the end edge) with logical alignment, so the sheet mirrors in RTL. It paints
/// no copy; [semanticLabel] is the caller's own loading announcement.
class DabblerThreadSkeleton extends StatelessWidget {
  /// A skeleton of [rows] message rows.
  const DabblerThreadSkeleton({
    super.key,
    this.rows = 6,
    this.animate = true,
    this.semanticLabel,
  }) : assert(rows >= 1, 'a thread skeleton needs at least one row');

  /// How many placeholder rows to draw. The rhythm repeats past its length.
  final int rows;

  /// Whether the blocks shimmer. See [DabblerSkeleton.animate].
  final bool animate;

  /// Announced to assistive technology, when set.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < rows; i++) {
      if (i > 0) {
        children.add(const SizedBox(height: DabblerMessagingSpacing.groupGap));
      }
      final _Row row = _rhythm[i % _rhythm.length];
      final Widget bubble = FractionallySizedBox(
        widthFactor: row.fraction,
        child: DabblerSkeleton.rect(animate: animate),
      );
      children.add(
        row.sent
            ? Align(alignment: AlignmentDirectional.centerEnd, child: bubble)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  DabblerSkeleton.circle(
                    width: DabblerMessagingSpacing.avatarGutter,
                    animate: animate,
                  ),
                  const SizedBox(width: DabblerMessagingSpacing.avatarGap),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: bubble,
                    ),
                  ),
                ],
              ),
      );
    }
    final Widget body = ClipRect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: DabblerMessagingSpacing.timelineInline,
          vertical: DabblerMessagingSpacing.timelineBlock,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
    return Semantics(
      container: true,
      label: semanticLabel,
      child: ExcludeSemantics(child: body),
    );
  }
}
