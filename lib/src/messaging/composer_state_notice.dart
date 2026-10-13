/// ComposerStateNotice — the strip that stands in for the composer when the
/// conversation is read-only (closed) or the person cannot send.
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// Why the composer is not offered.
enum DabblerComposerNoticeKind {
  /// The conversation is closed: read-only, nobody can post.
  closed,

  /// This person cannot send, though others may.
  cannotSend,
}

/// An icon and the caller's text, in the composer's footprint.
///
/// [DabblerComposerNoticeKind.closed] is a neutral sunken strip with a lock;
/// [DabblerComposerNoticeKind.cannotSend] is a warning strip. It matches the
/// notice [DabblerChatComposer] already draws for its own `notice`, as a
/// standalone widget for screens that do not mount the composer at all. The
/// text wraps, so it survives a 200 percent text scale.
class DabblerComposerStateNotice extends StatelessWidget {
  /// A notice of [kind] saying [text].
  const DabblerComposerStateNotice({
    super.key,
    required this.kind,
    required this.text,
    this.icon,
  });

  /// Which state this is.
  final DabblerComposerNoticeKind kind;

  /// What to say. The design system supplies no copy.
  final String text;

  /// Overrides the glyph (`lock` for closed, `slash` for cannot-send).
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final bool closed = kind == DabblerComposerNoticeKind.closed;
    final DabblerStatusColor warn = colors.status(DabblerStatusTone.warning);
    final Color fill = closed ? colors.surfaceSunken : warn.surface;
    final Color edge = closed ? colors.bgTertiary : warn.base;
    final Color ink = closed ? colors.textSecondary : colors.textPrimary;
    return Semantics(
      container: true,
      label: text,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: DabblerRadius.mdAll,
            border: Border.all(color: edge, width: DabblerSizing.borderDefault),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: DabblerSpacing.space3,
              horizontal: DabblerSpacing.space4,
            ),
            child: Row(
              children: <Widget>[
                DabblerIcon(
                  icon ?? (closed ? 'lock' : 'slash'),
                  size: DabblerSizing.iconSm,
                  color: closed ? colors.textSecondary : warn.strong,
                ),
                const SizedBox(width: DabblerSpacing.space3),
                Expanded(
                  child: Text(
                    text,
                    style: DabblerType.caption1
                        .resolveForDirection(dir)
                        .copyWith(color: ink),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
