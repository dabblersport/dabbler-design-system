import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/expanded_hit_area.dart';
import '../interaction/focus_ring.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// ListingSocial — the engagement group at the end of a listing card's action
/// row: a heart (favourite) with its count, and a share glyph with its count.
///
/// Drawn from the Listings game card (`Listings.dc.html:273-279`) and the
/// meetup card (`:644-655`): a row of two items, `gap: 15px`, each a 20px
/// glyph, `gap: 6px`, and a 12/16 600 count. It fits the `trailing` slot of
/// `DabblerCardGame` (and so the meetup listing card, which is that card).
///
/// ```dart
/// DabblerListingSocial(
///   favourited: saved,
///   onFavourite: toggleFavourite,
///   favouriteLabel: saved ? 'Remove from favourites' : 'Add to favourites',
///   favouriteCount: 14,
///   onShare: share,
///   shareLabel: 'Share',
///   shareCount: 6,
/// )
/// ```
///
/// ## States
///
/// Heart: off is the linear glyph in the secondary ink (`--ink-soft`); on is
/// the bold glyph in the error status base (`--color-status-error`,
/// `Listings.dc.html:2065-2066`). The count takes the heart's colour. The
/// share glyph and its count are `--share-ink`, which is the secondary text
/// colour in both modes (`:24`, `:28`). A count of null hides the number, not
/// the glyph.
///
/// ## Placement
///
/// * `DabblerCardGame.trailing` — the design's own slot; the action row seats
///   it at the inline end, vertically centred.
/// * The meetup listing card is a `DabblerCardGame`, so the same slot.
/// * `DabblerCardVenue` keeps its bordered heart well
///   (`DabblerFavouriteButton`, `:791-793`): the venue card draws a well at
///   the name row, with no share and no count, so this group is not used there.
///
/// ## RTL and accessibility
///
/// The row follows the reading direction (heart first at the inline start of
/// the group); nothing inside mirrors. Each item is its own button with a
/// 45 hit area ([DabblerSizing.touchTargetMin]) and a caller-supplied label;
/// the heart is announced as a toggle so state is not carried by colour alone.
/// The target is 45 tall; horizontally it grows into the gap between the two
/// items, so the group's outer edges stay the design's.
class DabblerListingSocial extends StatelessWidget {
  /// A heart + share group.
  const DabblerListingSocial({
    super.key,
    required this.favourited,
    required this.onFavourite,
    required this.favouriteLabel,
    required this.onShare,
    required this.shareLabel,
    this.favouriteCount,
    this.shareCount,
  });

  /// Whether the viewer favourited the item.
  final bool favourited;

  /// Toggles the favourite. Null disables the heart.
  final VoidCallback? onFavourite;

  /// The heart's accessible name, for the current state.
  final String favouriteLabel;

  /// The favourite count; null hides the number.
  final String? favouriteCount;

  /// Opens the share sheet. Null disables the share item.
  final VoidCallback? onShare;

  /// The share item's accessible name.
  final String shareLabel;

  /// The share count; null hides the number.
  final String? shareCount;

  /// The glyph size — `size="20"` (`Listings.dc.html:274`).
  static const double glyphSize = 20;

  /// Glyph to count — `gap: 6px`.
  static const double itemGap = DabblerSpacing.space2;

  /// Between the two items — `gap: 15px` (`:273`).
  static const double groupGap = DabblerSpacing.space5;

  /// The disabled opacity, as the favourite button's.
  static const double disabledOpacity = 0.45;

  /// The heart's colour: error base when on, secondary ink when off.
  static Color heartColorFor(
    DabblerColors colors, {
    required bool favourited,
  }) => favourited ? colors.error.base : colors.textSecondary;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: groupGap,
      children: <Widget>[
        _Item(
          icon: 'heart',
          weight: favourited
              ? DabblerIconWeight.bold
              : DabblerIconWeight.linear,
          color: heartColorFor(colors, favourited: favourited),
          count: favouriteCount,
          label: favouriteLabel,
          toggled: favourited,
          onPressed: onFavourite,
        ),
        _Item(
          icon: 'share',
          weight: DabblerIconWeight.linear,
          color: colors.textSecondary,
          count: shareCount,
          label: shareLabel,
          onPressed: onShare,
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.weight,
    required this.color,
    required this.label,
    required this.onPressed,
    this.count,
    this.toggled,
  });

  final String icon;
  final DabblerIconWeight weight;
  final Color color;
  final String label;
  final String? count;
  final bool? toggled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final TextDirection dir = Directionality.of(context);
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: DabblerListingSocial.itemGap,
      children: <Widget>[
        DabblerIcon(
          icon,
          weight: weight,
          size: DabblerListingSocial.glyphSize,
          color: color,
        ),
        if (count != null)
          Text(
            count!,
            maxLines: 1,
            style: DabblerType.caption1
                .resolveForDirection(dir)
                .copyWith(fontWeight: DabblerType.semibold, color: color),
          ),
      ],
    );
    if (!enabled) {
      content = Opacity(
        opacity: DabblerListingSocial.disabledOpacity,
        child: content,
      );
    }
    // 45 tall (the action row's height) so the group's own bounds contain the
    // whole vertical target; horizontally the target grows into the gap
    // between the two items, and the group's outer edges stay the design's.
    return DabblerExpandedHitArea(
      minimum: const Size.square(DabblerSizing.touchTargetMin),
      child: Semantics(
        button: true,
        enabled: enabled,
        toggled: toggled,
        label: label,
        excludeSemantics: true,
        onTap: onPressed,
        child: Actions(
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent _) {
                onPressed?.call();
                return null;
              },
            ),
          },
          child: MouseRegion(
            cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onPressed,
              child: SizedBox(
                height: DabblerSizing.touchTargetMin,
                child: Center(
                  widthFactor: 1,
                  child: DabblerFocusRing(
                    borderRadius: DabblerRadius.smAll,
                    enabled: enabled,
                    canRequestFocus: enabled,
                    child: content,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
