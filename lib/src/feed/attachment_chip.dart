import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'feed_atoms.dart';

/// AttachmentChip — one removable attachment waiting in a composer: a photo
/// or GIF thumbnail, or an icon and a label (a place, a file), with a remove
/// button over it (KAN-412 gaps 5 item 9).
///
/// Transcribed from `Post.dc.html` (alpha-plan design set), the "composing
/// reply" frame: the media thumbnail at lines 541-546 and the place pill at
/// line 547.
///
/// | Design (`Post.dc.html`) | Dart |
/// | --- | --- |
/// | `:541` thumb `96x96; radius --radius-lg; overflow hidden; 1px --outline-card` | [thumbnail] in a [thumbnailSize] square, [DabblerRadius.lgAll], `borderDefault` hairline |
/// | `:543` remove `top:5 right:5; 22x22 circle; rgba(0,0,0,0.55); #fff` | [removeSize] circle at the top-end corner, inset `space2`; `scrim` fill, `onBrand` glyph |
/// | `:544` `close-circle` 14 bold | the same glyph, 14 |
/// | `:547` place pill `gap:6px; padding:5px 8px 5px 9px; radius pill; 12/16 600` | icon + [label] pill, `space2` gap, `space1` / `space3` padding, `caption1` semibold |
/// | `:550` trailing `close-circle` 14, `opacity:0.7` | the remove target at the pill's end, `textSecondary` |
///
/// ## Deviations (recorded, not silent)
///
/// * **Remove fill.** The literal `rgba(0,0,0,0.55)` has no token; the
///   [DabblerColors.scrim] role is the nearest (as on [DabblerImage]). The
///   white glyph is `onBrand`.
/// * **Pill fill.** The design's `--color-brand-surface` (a 10% brand tint)
///   has no token; the pill is `surfaceCard` with the `borderDefault` hairline
///   and a `brandPrimary` icon, matching the place pill at `:219`.
/// * **45px targets.** The painted remove circle keeps the design's 22px; its
///   hit box is the 45px touch minimum anchored at the same corner.
/// * **Spacing steps.** 5px insets take `space2` (6); 8 / 9 paddings take
///   `space3` (9); 5px block padding takes `space1` (3) so the pill stays
///   45 tall with its target.
///
/// RTL: the remove button sits at the inline-end corner (top-right in LTR,
/// top-left in RTL) and the pill's icon leads.
///
/// Accessibility: the chip is announced by [label] (or [semanticLabel] for
/// a thumbnail); the remove button is its own button named [removeLabel].
class DabblerAttachmentChip extends StatelessWidget {
  /// An attachment chip.
  const DabblerAttachmentChip({
    super.key,
    this.thumbnail,
    this.icon,
    this.label,
    this.semanticLabel,
    this.onRemove,
    this.onTap,
    this.removeLabel = 'Remove attachment',
    this.thumbnailSize = defaultThumbnailSize,
  }) : assert(
         thumbnail != null || label != null,
         'give a thumbnail or a label',
       );

  /// The photo or GIF preview (a [DabblerImage], say). With it the chip is a
  /// square tile; without it, a pill of [icon] and [label].
  final Widget? thumbnail;

  /// An Iconsax glyph name leading the pill (`location`, `document`).
  final String? icon;

  /// The pill's text, or the thumbnail's accessible name when
  /// [semanticLabel] is null.
  final String? label;

  /// The thumbnail's accessible name; falls back to [label].
  final String? semanticLabel;

  /// Removes the attachment. Null hides the remove button.
  final VoidCallback? onRemove;

  /// Opens the attachment (a preview, say). Null leaves it inert.
  final VoidCallback? onTap;

  /// The remove button's accessible name, localised.
  final String removeLabel;

  /// The thumbnail's side.
  final double thumbnailSize;

  /// Thumbnail side — `96x96` (`:541`).
  static const double defaultThumbnailSize = 96;

  /// Painted remove circle — `22x22` (`:543`).
  static const double removeSize = 22;

  /// Remove glyph — `size="14"` (`:544`).
  static const double removeGlyphSize = 14;

  Widget _removeTarget(Widget painted, AlignmentGeometry align) {
    return Semantics(
      button: true,
      label: removeLabel,
      onTap: onRemove,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onRemove,
        child: SizedBox(
          width: DabblerSizing.touchTargetMin,
          height: DabblerSizing.touchTargetMin,
          child: Align(alignment: align, child: painted),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);

    if (thumbnail != null) {
      final Widget tile = DabblerFeedTappable(
        onTap: onTap,
        semanticLabel: semanticLabel ?? label,
        excludeChildSemantics: true,
        borderRadius: DabblerRadius.lgAll,
        child: Semantics(
          label: onTap == null ? (semanticLabel ?? label) : null,
          image: true,
          child: Container(
            width: thumbnailSize,
            height: thumbnailSize,
            clipBehavior: Clip.antiAlias,
            foregroundDecoration: BoxDecoration(
              borderRadius: DabblerRadius.lgAll,
              border: Border.all(
                color: colors.borderDefault,
                width: DabblerSizing.borderDefault,
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: DabblerRadius.lgAll,
              color: colors.surfaceSunken,
            ),
            child: ExcludeSemantics(child: thumbnail),
          ),
        ),
      );
      return SizedBox(
        width: thumbnailSize,
        height: thumbnailSize,
        child: Stack(
          children: <Widget>[
            tile,
            if (onRemove != null)
              PositionedDirectional(
                top: 0,
                end: 0,
                child: _removeTarget(
                  Padding(
                    padding: const EdgeInsets.all(DabblerSpacing.space2),
                    child: Container(
                      width: removeSize,
                      height: removeSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.scrim,
                      ),
                      child: Center(
                        child: DabblerIcon(
                          'close-circle',
                          size: removeGlyphSize,
                          weight: DabblerIconWeight.bold,
                          color: colors.onBrand,
                        ),
                      ),
                    ),
                  ),
                  AlignmentDirectional.topEnd,
                ),
              ),
          ],
        ),
      );
    }

    final Widget pill = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: DabblerRadius.pillAll,
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: DabblerSpacing.space3,
          end: onRemove == null ? DabblerSpacing.space3 : 0,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: DabblerSizing.touchTargetMin,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                ExcludeSemantics(
                  child: DabblerIcon(
                    icon!,
                    size: removeGlyphSize,
                    weight: DabblerIconWeight.bold,
                    color: colors.brandPrimary,
                  ),
                ),
                const SizedBox(width: DabblerSpacing.space2),
              ],
              Flexible(
                child: DabblerFeedTappable(
                  onTap: onTap,
                  semanticLabel: label,
                  excludeChildSemantics: true,
                  child: Text(
                    label!,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: DabblerType.caption1
                        .resolveForDirection(dir)
                        .copyWith(
                          color: colors.textPrimary,
                          fontWeight: DabblerType.semibold,
                        ),
                  ),
                ),
              ),
              if (onRemove != null)
                _removeTarget(
                  DabblerIcon(
                    'close-circle',
                    size: removeGlyphSize,
                    color: colors.textSecondary,
                  ),
                  AlignmentDirectional.center,
                ),
            ],
          ),
        ),
      ),
    );
    return pill;
  }
}
