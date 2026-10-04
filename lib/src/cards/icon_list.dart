import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/text.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_layout.dart';
import '../tokens/dabbler_type.dart';

/// IconList — a short list of lines, each led by the same small glyph, with
/// an optional uppercase title: the "Don't forget" panel of the persona
/// welcome, `Auth and Onboarding.dc.html:511-525`.
///
/// ```dart
/// DabblerIconList(
///   title: "Don't forget",
///   items: ['Only confirm when you know you can play.', 'Turning up builds your reputation.'],
/// )
/// ```
///
/// | part | value | source |
/// |---|---|---|
/// | title | [DabblerType.footnote] (13), weight 600, uppercase, `--muted` | `:513` |
/// | glyph | [icon] (default `tick-circle`) bold, [DabblerSizing.iconSm] (18), brand | `:516-518` |
/// | line | [DabblerType.subheadline] (15), `--ink` | `:520` |
/// | gaps | `space4` between title and rows and between rows, `space3` glyph to line | `:512`, `:515` |
///
/// The glyph sits `space1` below the line's top so it centres on the first
/// line of a wrapping item (`margin-top:2px`, `:516`).
///
/// It paints no surface: place it in a `DabblerCard` for the panel.
///
/// ## RTL
///
/// The glyph is at the inline start; lines wrap and align to the reading
/// direction.
class DabblerIconList extends StatelessWidget {
  /// Creates the list.
  const DabblerIconList({
    super.key,
    required this.items,
    this.title,
    this.icon = 'tick-circle',
  });

  /// The lines, already localised.
  final List<String> items;

  /// The uppercase title above the lines.
  final String? title;

  /// The glyph before each line.
  final String icon;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (title != null) ...<Widget>[
          DabblerText(
            title!.toUpperCase(),
            style: DabblerType.footnote,
            weight: DabblerTextWeight.semibold,
            tone: DabblerTextTone.tertiary,
          ),
          const DabblerGap.v(DabblerSpacing.space4),
        ],
        for (int i = 0; i < items.length; i++) ...<Widget>[
          if (i > 0) const DabblerGap.v(DabblerSpacing.space4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: DabblerSpacing.space1,
                ),
                child: DabblerIcon(
                  icon,
                  weight: DabblerIconWeight.bold,
                  size: DabblerSizing.iconSm,
                  color: colors.brandPrimary,
                ),
              ),
              const DabblerGap.h(DabblerSpacing.space3),
              Expanded(
                child: DabblerText(items[i], style: DabblerType.subheadline),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
