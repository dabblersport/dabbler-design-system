import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../surfaces/badge.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';

/// LinkChip — the small "copy profile link" pill that sits beside a handle.
///
/// Transcribed from `Profiles.dc.html:77-82`: a pill with a 14px `link` glyph;
/// once pressed it turns to the success tint, swaps the glyph for
/// `tick-circle` and reads [copiedLabel] ("Link copied"). The widget owns no
/// clipboard and no timer: the caller passes [copied] and resets it.
///
/// It is a button with a [semanticLabel], at least
/// [DabblerSizing.touchTargetMin] tall in hit area, and it is drawn from
/// [DabblerBadge], so its geometry is the badge's.
class DabblerLinkChip extends StatelessWidget {
  /// A link chip.
  const DabblerLinkChip({
    super.key,
    required this.semanticLabel,
    required this.onTap,
    this.copied = false,
    this.copiedLabel = '',
  });

  /// The accessible name while idle (`Copy profile link`).
  final String semanticLabel;

  /// Called on tap.
  final VoidCallback? onTap;

  /// Whether the link has just been copied.
  final bool copied;

  /// The label shown while [copied].
  final String copiedLabel;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Widget badge = copied
        ? DabblerBadge(
            label: copiedLabel,
            status: colors.success,
            icon: const DabblerIcon(
              'tick-circle',
              size: DabblerSizing.iconXs,
            ),
          )
        : const DabblerBadge(
            label: '',
            tone: DabblerBadgeTone.withIcon,
            icon: DabblerIcon('link', size: DabblerSizing.iconXs),
          );
    return Semantics(
      button: true,
      label: copied ? copiedLabel : semanticLabel,
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: badge,
        ),
      ),
    );
  }
}
