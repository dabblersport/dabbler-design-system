/// ThreadSkeleton — the placeholder a message thread shows while its first page
/// loads: received and sent message rows made of [DabblerSkeleton] blocks.
library;

import 'package:flutter/widgets.dart';

import '../feedback/skeleton.dart';
import '../tokens/dabbler_geometry.dart';
import 'messaging_foundations.dart';

/// Bubble widths, as sums of spacing tokens: no literal length lives here.
const double _short = DabblerSpacing.space11 + DabblerSpacing.space11;
const double _medium = _short + DabblerSpacing.space11;
const double _long = _medium + _medium;

/// One placeholder row: who sent it and how wide its bubble is at most.
typedef _Row = ({bool sent, double width});

/// A fixed, alternating rhythm so the placeholder reads as a conversation.
/// A bubble never grows past the line, so a narrow screen shrinks it.
const List<_Row> _rhythm = <_Row>[
  (sent: false, width: _long),
  (sent: false, width: _short),
  (sent: true, width: _medium),
  (sent: false, width: _long + _short),
  (sent: true, width: _short),
  (sent: true, width: _long),
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
      final Widget bubble = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: row.width),
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
