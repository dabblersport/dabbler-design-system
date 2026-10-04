import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/text.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'card.dart';
import 'card_event_listing.dart';

/// CardGame — a game in a listing: title with a verified mark and a tag row
/// on the start side, the day and time on the end side, a place line, the
/// player progress beside the price, and the join action.
///
/// Drawn from the Listings screen's game card, `Listings.dc.html:207-262`
/// (Alpha fidelity rebuild, KAN-426). Unlike the event cards it carries no
/// cover: a game is a time, a skill and slots.
///
/// ```dart
/// DabblerCardGame(
///   title: 'Tuesday 5-a-side',
///   verified: true,
///   tags: <Widget>[DabblerChip(label: 'Football'), DabblerChip(label: 'Futsal 5s')],
///   dayLabel: 'Today',
///   timeLabel: '7:30 PM',
///   meta: <String>['Dubai Sports City', '2.1 km', '90 min'],
///   progress: DabblerCardEventPlayers(label: '9 of 10 players in', joined: 9, capacity: 10),
///   price: DabblerCardEventPrice(price: 'AED 40', note: 'per player'),
///   action: DabblerCardEventListing.joinButton(label: 'Join game', onPressed: join),
///   onTap: open,
/// )
/// ```
///
/// ## Anatomy
///
/// | Part | Source | Here |
/// |---|---|---|
/// | title 17/22 600, verified tick 16 in success | `:212-218` | `.t-headline`, `tick-circle` bold in `success` |
/// | tag row, gap 6, wraps | `:220-224` | the [tags] slot, a [Wrap] |
/// | day (12, brand) over time (20 bold), at the end | `:227-230` | [dayLabel] and [timeLabel]; the time takes `.t-headline` at bold — the nearest sans step, as the price block does |
/// | place line: pin, venue, dot-separated distance and duration | `:234-243` | [meta], entries joined by dots |
/// | progress, price, join | `:245-262` | [DabblerCardEventListing.compose] |
/// | social counts at the end of the action row | `:263-275` | the [trailing] slot |
///
/// The shell — surface, border, radius, padding, press, focus — is
/// [DabblerCard]'s.
///
/// ## RTL
///
/// Everything is directional: the day and time move to the inline end's
/// mirror (the left under Arabic), the title and tags start at the right.
///
/// ## Accessibility
///
/// With [onTap] the whole card is one button named [semanticLabel] or the
/// title and time joined. [action] and [trailing] keep their own semantics.
class DabblerCardGame extends StatelessWidget {
  /// A game card for [title].
  const DabblerCardGame({
    super.key,
    required this.title,
    this.verified = false,
    this.verifiedLabel,
    this.tags = const <Widget>[],
    this.dayLabel,
    this.timeLabel,
    this.meta = const <String>[],
    this.progress,
    this.price,
    this.action,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.semanticLabel,
  });

  /// The game's title. Two lines, then an ellipsis.
  final String title;

  /// Draws the verified-host tick after the title.
  final bool verified;

  /// The tick's accessible name — `Verified host`.
  final String? verifiedLabel;

  /// Tag chips under the title — sport, format, skill. Wraps.
  final List<Widget> tags;

  /// The day — `Today`, at the end, in the brand ink.
  final String? dayLabel;

  /// The start time — `7:30 PM`, large and bold, under [dayLabel].
  final String? timeLabel;

  /// The place line's entries — venue, distance, duration — joined by dots.
  final List<String> meta;

  /// The player-progress block ([DabblerCardEventPlayers]).
  final Widget? progress;

  /// The price block ([DabblerCardEventPrice]).
  final Widget? price;

  /// The join action ([DabblerCardEventListing.joinButton]).
  final Widget? action;

  /// What sits beside [action] at the end — social counts. Null leaves the
  /// action full width.
  final Widget? trailing;

  /// Makes the whole card tappable.
  final VoidCallback? onTap;

  /// Whether a tappable card currently accepts input.
  final bool enabled;

  /// The accessible label of a tappable card.
  final String? semanticLabel;

  /// The place line's pin size — `size="14"` (`Listings.dc.html:234`).
  static const double pinSize = 14;

  /// The title's line cap.
  static const int titleMaxLines = 2;

  Widget _titleRow(BuildContext context, DabblerColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: DabblerSpacing.space2,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: DabblerSpacing.space2,
          children: <Widget>[
            Flexible(
              child: DabblerText(
                title,
                style: DabblerType.headline,
                weight: DabblerTextWeight.semibold,
                maxLines: titleMaxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (verified)
              Semantics(
                label: verifiedLabel,
                child: DabblerIcon(
                  'tick-circle',
                  weight: DabblerIconWeight.bold,
                  size: DabblerSizing.iconInline,
                  color: colors.success.base,
                ),
              ),
          ],
        ),
        if (tags.isNotEmpty)
          Wrap(
            spacing: DabblerSpacing.space2,
            runSpacing: DabblerSpacing.space2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: tags,
          ),
      ],
    );
  }

  Widget? _when() {
    if (dayLabel == null && timeLabel == null) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (dayLabel != null)
          DabblerText(
            dayLabel!,
            style: DabblerType.caption1,
            weight: DabblerTextWeight.semibold,
            tone: DabblerTextTone.brand,
            maxLines: 1,
          ),
        if (timeLabel != null)
          DabblerText(
            timeLabel!,
            style: DabblerType.headline,
            weight: DabblerTextWeight.bold,
            maxLines: 1,
          ),
      ],
    );
  }

  Widget? _place(DabblerColors colors) {
    if (meta.isEmpty) return null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: DabblerSpacing.space1,
      children: <Widget>[
        DabblerIcon('location', size: pinSize, color: colors.textTertiary),
        Flexible(
          child: Wrap(
            spacing: DabblerSpacing.space1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              for (int i = 0; i < meta.length; i++) ...<Widget>[
                if (i > 0)
                  DabblerText(
                    '·',
                    style: DabblerType.footnote,
                    tone: DabblerTextTone.tertiary,
                  ),
                DabblerText(
                  meta[i],
                  style: DabblerType.footnote,
                  weight: i == 0
                      ? DabblerTextWeight.medium
                      : DabblerTextWeight.regular,
                  tone: i == 0
                      ? DabblerTextTone.primary
                      : DabblerTextTone.secondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Widget? when = _when();
    final Widget? place = _place(colors);
    final Widget? actionRow = action == null
        ? null
        : trailing == null
        ? action
        : Row(
            spacing: DabblerSpacing.space3,
            children: <Widget>[
              Expanded(child: action!),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: trailing,
                ),
              ),
            ],
          );
    final Widget? lower = DabblerCardEventListing.compose(
      progress: progress,
      price: price,
      action: actionRow,
    );
    return DabblerCard(
      onTap: onTap,
      enabled: enabled,
      semanticLabel: semanticLabel ?? <String>[title, ?timeLabel].join(', '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: DabblerCardEventListing.sectionGap,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: DabblerSpacing.space4,
            children: <Widget>[
              Expanded(child: _titleRow(context, colors)),
              ?when,
            ],
          ),
          ?place,
          ?lower,
        ],
      ),
    );
  }
}
