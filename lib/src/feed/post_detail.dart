import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// The post-detail extras a [DabblerPostRow] draws when it is the open post
/// rather than a feed row: the full timestamp, an "Edited" marker and the
/// visibility line (KAN-412 gaps 5 item 9).
///
/// Opt-in through `DabblerPostRow.detail`; a row without it is unchanged.
/// Every string is already formatted and localised by the caller.
@immutable
class DabblerPostDetail {
  /// Detail extras.
  const DabblerPostDetail({
    required this.timestamp,
    this.editedLabel,
    this.visibilityLabel,
    this.visibilityIcon = 'global',
    this.visibilitySemanticLabel,
  });

  /// The full timestamp (`8:00 PM · Aug 16, 2026`), already formatted.
  final String timestamp;

  /// The edited marker (`Edited`); null when the post was not edited.
  final String? editedLabel;

  /// Who can see the post (`Public`, `Friends`); null hides it.
  final String? visibilityLabel;

  /// The Iconsax glyph leading [visibilityLabel] — `global` as in the design
  /// (`Post.dc.html:250`); `people` or `lock` for narrower audiences.
  final String visibilityIcon;

  /// The visibility's accessible name (`Visible to everyone`); falls back to
  /// [visibilityLabel].
  final String? visibilitySemanticLabel;
}

/// The detail line of an open post — timestamp, edited marker and
/// visibility — drawn by [DabblerPostRow] when given a [DabblerPostDetail].
///
/// Transcribed from `Post.dc.html` (alpha-plan design set) lines 241-252.
///
/// | Design (`Post.dc.html`) | Dart |
/// | --- | --- |
/// | `:241` row `gap:5px; --muted; justify-content:space-between` | `space2`; `textSecondary`; visibility pushed to the end |
/// | `:242` time, 3px dot `--subtle`, date, 13/18 | [DabblerPostDetail.timestamp], `footnote` |
/// | `:250` `global` 14 + `EN` 13/18 | [DabblerPostDetail.visibilityIcon] 14 `textTertiary` + label |
/// | `:254` actions `padding-top:12px; border-top 1px --faint` | the line closes with a `bgTertiary` hairline, `space4` either side of the text |
///
/// ## Deviations (recorded, not silent)
///
/// * **Edited marker.** The design has none; it is a dot and a `footnote`
///   word after the timestamp, in the line's own ink.
/// * **Views.** The design's `1,204 views` is the row's existing `views`
///   figure; it is not repeated here.
/// * **5px gaps** take `space2` (6).
///
/// RTL: the visibility trails at the inline end; digits are Western.
class DabblerPostDetailLine extends StatelessWidget {
  /// A detail line.
  const DabblerPostDetailLine({super.key, required this.detail});

  /// What to draw.
  final DabblerPostDetail detail;

  /// Glyph side — `size="14"` (`:247`, `:250`).
  static const double glyphSize = 14;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextStyle style = DabblerType.footnote
        .resolveForDirection(Directionality.of(context))
        .copyWith(color: colors.textSecondary);
    final Widget dot = ExcludeSemantics(
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.textTertiary,
        ),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.bgTertiary,
            width: DabblerSizing.borderDefault,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: DabblerSpacing.space4,
          bottom: DabblerSpacing.space4,
        ),
        child: Row(
          children: <Widget>[
            Flexible(
              child: Text(
                DabblerType.toWesternDigits(detail.timestamp),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
            if (detail.editedLabel != null) ...<Widget>[
              const SizedBox(width: DabblerSpacing.space2),
              dot,
              const SizedBox(width: DabblerSpacing.space2),
              Text(detail.editedLabel!, maxLines: 1, style: style),
            ],
            if (detail.visibilityLabel != null) ...<Widget>[
              const Spacer(),
              const SizedBox(width: DabblerSpacing.space2),
              Semantics(
                label: detail.visibilitySemanticLabel ?? detail.visibilityLabel,
                excludeSemantics: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DabblerIcon(
                      detail.visibilityIcon,
                      size: glyphSize,
                      color: colors.textTertiary,
                    ),
                    const SizedBox(width: DabblerSpacing.space2),
                    Text(detail.visibilityLabel!, maxLines: 1, style: style),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
