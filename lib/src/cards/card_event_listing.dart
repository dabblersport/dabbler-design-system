import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../feedback/progress_bar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// The listing slots an event card can carry under its title and metadata:
/// a **player-progress** block, a **price** block and a **join action** —
/// the three rows the Listings screen draws on every game card
/// (`Listings.dc.html:242-259`).
///
/// [DabblerCardEventLarge], [DabblerCardEventMedium] and
/// [DabblerCardEventSmall] all take the same three optional slots —
/// `progress`, `price` and `action` — and lay them out through [compose], so
/// the three densities cannot drift apart. Every slot is optional and the
/// default of each is null: a card built without them renders exactly as it
/// did before (Alpha DS gaps 6, item 1, additive).
///
/// ```dart
/// DabblerCardEventLarge(
///   title: 'Sunday five-a-side',
///   sport: DabblerSport.football,
///   progress: const DabblerCardEventPlayers(
///     label: '9 of 10 players in',
///     joined: 9,
///     capacity: 10,
///     note: '1 spot left · almost full',
///     tone: DabblerProgressBarTone.warning,
///   ),
///   price: const DabblerCardEventPrice(price: 'AED 40', note: 'per player'),
///   action: DabblerCardEventListing.joinButton(
///     label: 'Join game',
///     onPressed: () {},
///     loading: joining,
///   ),
/// )
/// ```
///
/// ## Layout
///
/// `Listings.dc.html:242`: progress and price share one row,
/// `align-items: flex-end`, progress taking the remaining width and price at
/// the inline end; the action sits under them at full width
/// (`Listings.dc.html:256-259`, `full-width`, 45px). Row gap 15 is
/// [DabblerSpacing.space5]; the gap between rows is
/// [DabblerSpacing.stackDefault] (12, the card's `gap: 12`).
///
/// ## RTL
///
/// The row is a [Row] under [Directionality]: under Arabic the price moves to
/// the left and the bar fills right-to-left (the [DabblerProgressBar] fill is
/// directional). Nothing here names a physical side.
///
/// ## Accessibility
///
/// [DabblerCardEventPlayers] is one semantics node — label then note — with
/// the bar's own percentage excluded so it is not read twice.
/// [DabblerCardEventPrice] is one node, price then note. The action keeps its
/// own button semantics; a card with an [action] and an `onTap` exposes two
/// controls, which is what the design draws (`onClick="{{ stop }}"` stops the
/// join tap from opening the card).
abstract final class DabblerCardEventListing {
  /// Gap between the progress block and the price block — `gap: 15`
  /// (`Listings.dc.html:242`), [DabblerSpacing.space5].
  static const double rowGap = DabblerSpacing.space5;

  /// Gap between the listing rows and between them and the metadata —
  /// the card body's `gap: 12`, [DabblerSpacing.stackDefault].
  static const double sectionGap = DabblerSpacing.stackDefault;

  /// Lays out [progress], [price] and [action]. Null when all three are null,
  /// so a caller can skip the gap entirely.
  static Widget? compose({Widget? progress, Widget? price, Widget? action}) {
    if (progress == null && price == null && action == null) return null;
    final Widget? top = switch ((progress, price)) {
      (null, null) => null,
      (final Widget p, null) => p,
      (null, final Widget q) => Align(
        alignment: AlignmentDirectional.centerEnd,
        child: q,
      ),
      (final Widget p, final Widget q) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: rowGap,
        children: <Widget>[
          Expanded(child: p),
          q,
        ],
      ),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: sectionGap,
      children: <Widget>[?top, ?action],
    );
  }

  /// [compose] followed by a caller's own [footer] — Large's pre-existing
  /// `footer` slot keeps rendering, under the listing rows.
  static Widget? withFooter(
    Widget? footer, {
    Widget? progress,
    Widget? price,
    Widget? action,
  }) {
    final Widget? listing = compose(
      progress: progress,
      price: price,
      action: action,
    );
    if (listing == null) return footer;
    if (footer == null) return listing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: sectionGap,
      children: <Widget>[listing, footer],
    );
  }

  /// The design's Join button — a full-width medium [DabblerButton]
  /// (`Listings.dc.html:258`). [loading] shows the button's spinner and
  /// blocks taps; [disabled] (or a null [onPressed]) greys it out — for a
  /// full or past game.
  static Widget joinButton({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool loading = false,
    bool disabled = false,
    String? semanticLabel,
  }) => DabblerButton(
    key: key,
    label: label,
    onPressed: onPressed,
    loading: loading,
    disabled: disabled || onPressed == null,
    fullWidth: true,
    semanticLabel: semanticLabel,
  );
}

/// The player-progress block: "9 of 10 players in", a fill bar, and an
/// optional status note (`Listings.dc.html:243-249`).
class DabblerCardEventPlayers extends StatelessWidget {
  /// A progress block for [joined] of [capacity] players.
  const DabblerCardEventPlayers({
    super.key,
    required this.label,
    required this.joined,
    required this.capacity,
    this.note,
    this.tone = DabblerProgressBarTone.brand,
  });

  /// The visible count, already formatted and localised — `9 of 10 players
  /// in`, `9/10 players`.
  final String label;

  /// Players in.
  final int joined;

  /// Players the game holds. Zero or less draws an empty bar.
  final int capacity;

  /// The status line under the bar — `1 spot left · almost full`.
  final String? note;

  /// The bar's fill tone, and the note's ink: brand ink for
  /// [DabblerProgressBarTone.brand], the status `strong` role otherwise. The
  /// note's words carry the meaning; colour only reinforces them.
  final DabblerProgressBarTone tone;

  /// The bar's fraction, clamped to 0–1.
  double get fraction =>
      capacity <= 0 ? 0 : (joined / capacity).clamp(0.0, 1.0).toDouble();

  /// The note's ink for [tone].
  static Color noteColorFor(
    DabblerColors colors,
    DabblerProgressBarTone tone,
  ) => switch (tone) {
    DabblerProgressBarTone.success => colors.success.strong,
    DabblerProgressBarTone.warning => colors.warning.strong,
    DabblerProgressBarTone.error => colors.error.strong,
    DabblerProgressBarTone.info => colors.info.strong,
    DabblerProgressBarTone.brand ||
    DabblerProgressBarTone.onBrand => colors.brandPrimary,
  };

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    return Semantics(
      container: true,
      label: <String>[label, ?note].join(', '),
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // `gap: 6` (`Listings.dc.html:243`).
          spacing: DabblerSpacing.space2,
          children: <Widget>[
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // `13/17, 600, --ink` — `.t-footnote` at semibold.
              style: DabblerType.footnote
                  .resolveForDirection(direction)
                  .copyWith(
                    color: colors.textPrimary,
                    fontWeight: DabblerType.semibold,
                  ),
            ),
            // `height: 6`, pill — the bar's `md` track.
            DabblerProgressBar(value: fraction, tone: tone),
            if (note != null)
              Text(
                note!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // `11/15, 600` — `.t-caption-2` at semibold.
                style: DabblerType.caption2
                    .resolveForDirection(direction)
                    .copyWith(
                      color: noteColorFor(colors, tone),
                      fontWeight: DabblerType.semibold,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The price block: the amount over its unit (`Listings.dc.html:250-253`).
///
/// **Deviation:** the design sets the amount at 22/27 weight 700 in the sans
/// face. The ramp's 22 step (`.t-title-2`) is the display face at 400, so the
/// amount takes `.t-headline` (17/22, sans) at [DabblerType.bold] — the
/// nearest sans step — rather than inventing a size.
class DabblerCardEventPrice extends StatelessWidget {
  /// A price block showing [price].
  const DabblerCardEventPrice({
    super.key,
    required this.price,
    this.note,
    this.free = false,
  });

  /// The amount, already formatted and localised — `AED 40`, `Free`.
  final String price;

  /// The unit — `per player`.
  final String? note;

  /// Draws the amount in the success ink, as the design does for a free game
  /// (`g.priceColor`). The word itself must still say "Free".
  final bool free;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    return Semantics(
      container: true,
      label: <String>[price, ?note].join(', '),
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              price,
              maxLines: 1,
              style: DabblerType.headline
                  .resolveForDirection(direction)
                  .copyWith(
                    color: free ? colors.success.strong : colors.textPrimary,
                    fontWeight: DabblerType.bold,
                  ),
            ),
            if (note != null)
              Text(
                note!,
                maxLines: 1,
                // `11/15, --muted`.
                style: DabblerType.caption2
                    .resolveForDirection(direction)
                    .copyWith(color: colors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}
