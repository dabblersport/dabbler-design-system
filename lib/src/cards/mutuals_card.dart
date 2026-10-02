import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_palette.dart';
import '../tokens/dabbler_type.dart';

/// MutualsCard — an avatar stack beside a line of context, such as who you both
/// follow.
///
/// Ported from the live design project's `components/cards/MutualsCard.jsx`
/// (design system 1.2.0): the same shell as the other profile cards — card
/// fill, 1px card outline, [DabblerRadius.lg] — 12 padding, a 12 gap, and the
/// text in `footnote` (13/18) at `--ink-soft`.
///
/// The avatars are injected ([avatars], usually a `DabblerAvatarGroup`) and the
/// text is a plain string; the widget owns no data.
class DabblerMutualsCard extends StatelessWidget {
  /// A mutuals card.
  const DabblerMutualsCard({super.key, required this.text, this.avatars});

  /// The avatar stack, leading. Null leaves only the text.
  final Widget? avatars;

  /// The line of context.
  final String text;

  /// Padding on every edge — `padding: 12`.
  static const double padding = DabblerSpacing.space4;

  /// Gap between the avatars and the text — `gap: 12`.
  static const double gap = DabblerSpacing.space4;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: DabblerRadius.lgAll,
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(padding),
        child: Row(
          children: <Widget>[
            if (avatars != null) ...<Widget>[
              avatars!,
              const SizedBox(width: gap),
            ],
            Expanded(
              child: Text(
                text,
                style: DabblerType.footnote
                    .resolveForDirection(direction)
                    .copyWith(color: DabblerPalette.inkSoft),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
