/// ConnectionNotice — the slim strip that says the thread is offline or
/// reconnecting.
library;

import 'package:flutter/widgets.dart';

import '../feedback/spinner.dart';
import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// An offline / reconnecting notice, a one-line (wrapping) warning strip.
///
/// The text is the caller's, and so is whether it is shown: with [visible]
/// false it collapses to nothing. While [reconnecting] it shows a spinner in
/// place of the [icon]. It is a polite live region, so a change is announced.
class DabblerConnectionNotice extends StatelessWidget {
  /// A notice saying [text].
  const DabblerConnectionNotice({
    super.key,
    required this.text,
    this.visible = true,
    this.reconnecting = false,
    this.icon = 'wifi',
  });

  /// What to say. The design system supplies no copy.
  final String text;

  /// Whether the strip is shown.
  final bool visible;

  /// Shows a spinner instead of [icon].
  final bool reconnecting;

  /// The Iconsax glyph beside the text.
  final String icon;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final DabblerColors colors = DabblerColors.of(context);
    final DabblerStatusColor tone = colors.status(DabblerStatusTone.warning);
    final TextDirection dir = Directionality.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      label: text,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tone.surface,
            border: Border(
              bottom: BorderSide(
                color: tone.base,
                width: DabblerSizing.borderHairline,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: DabblerSpacing.space3,
              horizontal: DabblerSpacing.space4,
            ),
            child: Row(
              children: <Widget>[
                if (reconnecting)
                  const DabblerSpinner(size: DabblerSpinnerSize.sm)
                else
                  DabblerIcon(
                    icon,
                    size: DabblerSizing.iconSm,
                    color: tone.strong,
                  ),
                const SizedBox(width: DabblerSpacing.space3),
                Expanded(
                  child: Text(
                    text,
                    style: DabblerType.caption1
                        .resolveForDirection(dir)
                        .copyWith(color: colors.textPrimary),
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
