import 'package:flutter/material.dart';

import '../foundations/icon.dart';
import '../media/image.dart';
import '../surfaces/avatar.dart';
import '../surfaces/rating.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_palette.dart';
import '../tokens/dabbler_type.dart';
import 'activity_card.dart';

/// The KAN-967 Active card types, transcribed from `ActivityCard.dc.html`:
/// the trending strip ([DabblerActivitySlim]) and its pair of boxes
/// ([DabblerActivityPair] of [DabblerActivityTrendBox]), and the parts the
/// full card composes for awards, featured venues and venue ratings
/// ([DabblerActivityBadge], [DabblerActivityAward], [DabblerActivityStats],
/// [DabblerActivityPhoto], [DabblerActivityReason], [DabblerActivityReview],
/// [DabblerActivityVenueRow]).
///
/// Every part reads [DabblerColors] at light brightness: the slim strip and
/// the pair boxes set their own light island, as [DabblerActivityCard] does,
/// and the full-card parts sit inside one.

TextStyle _style(BuildContext context, DabblerTypeStyle s, Color color) =>
    s.resolveForDirection(Directionality.of(context)).copyWith(color: color);

Widget _island(BuildContext context, Widget child) => Theme(
  data: ThemeData(
    brightness: Brightness.light,
    extensions: <DabblerColors>[
      DabblerActivityCard.islandOf(DabblerColors.of(context)),
    ],
  ),
  child: child,
);

Text _line(
  BuildContext context,
  String text,
  DabblerTypeStyle style,
  Color color, {
  bool oneLine = false,
  TextAlign? align,
}) => Text(
  DabblerType.toWesternDigits(text),
  maxLines: oneLine ? 1 : null,
  softWrap: !oneLine,
  overflow: oneLine ? TextOverflow.ellipsis : null,
  textAlign: align,
  style: _style(context, style, color),
);

/// The full-width trending strip (`a.isSlim`): `padding:12px 15px`,
/// `min-height:64px`, `gap:12px`, `--radius-xl`, the tone ground; a 40 icon
/// tile (`--radius-lg`, card, glyph 20 bold in the ink), the kicker (11/13
/// ink) over the value (20/25 display, one line), and the metric pill
/// (`padding:5px 10px`, `gap:4px`, card, `trend-up` 14, 12/16 ink).
class DabblerActivitySlim extends StatelessWidget {
  /// A strip.
  const DabblerActivitySlim({
    super.key,
    required this.tone,
    required this.icon,
    required this.kicker,
    required this.value,
    required this.metric,
  });

  final DabblerToneColor tone;

  /// `a.slimIcon`: `trend-up` (sport) or `hashtag`.
  final String icon;
  final String kicker;
  final String value;
  final String metric;

  /// `padding:12px 15px`.
  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: DabblerSpacing.space5,
    vertical: DabblerSpacing.space4,
  );

  /// `min-height:64px`.
  static const double minHeight = 64;

  /// The icon tile: `40px`.
  static const double tileSize = 40;

  /// The tile glyph: `size="20"`.
  static const double iconSize = 20;

  /// The metric glyph: `trend-up`, `size="14"`, linear.
  static const double metricIconSize = 14;

  /// `padding:5px 10px`.
  static const EdgeInsets metricPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 5,
  );

  /// `gap:4px` in the metric pill.
  static const double metricGap = 4;

  /// Overflow guard, not a design value: the source's pill does not shrink
  /// (`flex-shrink:0; white-space:nowrap`) and the strip clips. Here the pill
  /// is held to half the strip's content width and ellipsizes past it, so a
  /// long figure or a large text scale cannot overflow. The design's figures
  /// fit well inside it.
  static const double metricMaxShare = 0.5;

  @override
  Widget build(BuildContext context) => _island(
    context,
    Builder(
      builder: (BuildContext context) {
        final DabblerColors colors = DabblerColors.of(context);
        return ClipRRect(
          borderRadius: DabblerRadius.xlAll,
          child: ColoredBox(
            color: tone.surface,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: minHeight),
              child: Padding(
                padding: padding,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints c) => Row(
                    children: <Widget>[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.surfaceCard,
                          borderRadius: DabblerRadius.lgAll,
                        ),
                        child: SizedBox.square(
                          dimension: tileSize,
                          child: Center(
                            child: DabblerIcon(
                              icon,
                              size: iconSize,
                              weight: DabblerIconWeight.bold,
                              color: tone.ink,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: DabblerSpacing.space4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _line(
                              context,
                              kicker,
                              DabblerType.caption2,
                              tone.ink,
                            ),
                            _line(
                              context,
                              value,
                              DabblerType.title3,
                              colors.textPrimary,
                              oneLine: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: DabblerSpacing.space4),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: c.maxWidth * metricMaxShare,
                        ),
                        child: DecoratedBox(
                          key: const ValueKey<String>('activity-slim-metric'),
                          decoration: BoxDecoration(
                            color: colors.surfaceCard,
                            borderRadius: DabblerRadius.pillAll,
                          ),
                          child: Padding(
                            padding: metricPadding,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                DabblerIcon(
                                  'trend-up',
                                  size: metricIconSize,
                                  color: tone.ink,
                                ),
                                const SizedBox(width: metricGap),
                                Flexible(
                                  child: Text(
                                    DabblerType.toWesternDigits(metric),
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: _style(
                                      context,
                                      DabblerType.caption1,
                                      tone.ink,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// One trending box of a pair (`a.isPair`, `a.left` / `a.right`):
/// `padding:15px`, `min-height:132px`, `gap:9px`, `--radius-xl`, the tone
/// ground; the glyph (78 bold, 14%, `inset-inline-end:-12px; bottom:-14px`)
/// behind the compact kicker pill, the value (22/28 display, one line) and
/// the metric pushed to the bottom (`margin-top:auto`, 12/16 ink).
class DabblerActivityTrendBox extends StatelessWidget {
  /// A box.
  const DabblerActivityTrendBox({
    super.key,
    required this.tone,
    required this.icon,
    required this.kicker,
    required this.value,
    required this.metric,
  });

  final DabblerToneColor tone;
  final String icon;
  final String kicker;
  final String value;
  final String metric;

  /// `padding:15px`.
  static const double padding = DabblerSpacing.space5;

  /// `min-height:132px`.
  static const double minHeight = 132;

  /// `gap:9px`.
  static const double gap = DabblerSpacing.space3;

  /// The glyph: `size="78"`.
  static const double markSize = 78;

  /// `inset-inline-end:-12px`.
  static const double markInsetEnd = -DabblerSpacing.space4;

  /// `bottom:-14px`.
  static const double markInsetBottom = -14;

  @override
  Widget build(BuildContext context) => _island(
    context,
    Builder(
      builder: (BuildContext context) {
        final DabblerColors colors = DabblerColors.of(context);
        return ClipRRect(
          borderRadius: DabblerRadius.xlAll,
          child: ColoredBox(
            color: tone.surface,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: minHeight),
              child: IntrinsicHeight(
                child: Stack(
                  children: <Widget>[
                    PositionedDirectional(
                      end: markInsetEnd,
                      bottom: markInsetBottom,
                      child: IgnorePointer(
                        child: ExcludeSemantics(
                          child: DabblerIcon(
                            icon,
                            key: const ValueKey<String>('activity-trend-mark'),
                            size: markSize,
                            weight: DabblerIconWeight.bold,
                            color: tone.ink.withValues(
                              alpha: DabblerActivityCard.markOpacity,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          DabblerActivityKicker(
                            label: kicker,
                            ink: tone.ink,
                            icon: icon,
                            compact: true,
                          ),
                          const SizedBox(height: gap),
                          _line(
                            context,
                            value,
                            DabblerType.title2,
                            colors.textPrimary,
                            oneLine: true,
                          ),
                          const SizedBox(height: gap),
                          const Spacer(),
                          _line(
                            context,
                            metric,
                            DabblerType.caption1,
                            tone.ink,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// Two trending boxes side by side (`pairSlims`): two equal columns
/// (`grid-template-columns:repeat(2, minmax(0, 1fr))`), `gap:9px`, both as
/// tall as the taller (a grid row stretches).
class DabblerActivityPair extends StatelessWidget {
  /// A pair.
  const DabblerActivityPair({
    super.key,
    required this.start,
    required this.end,
  });

  /// The first item (`a.left`, the inline start).
  final Widget start;

  /// The second item (`a.right`).
  final Widget end;

  /// `gap:9px`.
  static const double gap = DabblerSpacing.space3;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: start),
        const SizedBox(width: gap),
        Expanded(child: end),
      ],
    ),
  );
}

/// The period badge beside the kicker (`a.badge`, "Week 47"):
/// `padding:4px 10px`, `--radius-pill`, the tone ink filled, 11/13 card.
class DabblerActivityBadge extends StatelessWidget {
  /// A badge.
  const DabblerActivityBadge({
    super.key,
    required this.label,
    required this.ink,
  });

  final String label;
  final Color ink;

  /// `padding:4px 10px`.
  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: ink, borderRadius: DabblerRadius.pillAll),
    child: Padding(
      padding: padding,
      child: _line(
        context,
        label,
        DabblerType.caption2,
        DabblerColors.of(context).surfaceCard,
        oneLine: true,
      ),
    ),
  );
}

/// The player-of-the-week / month spotlight (`a.isAward`): centred, `gap:9px`,
/// `padding-top:3px`; the 80 avatar ringed 4 in the card surface with the
/// medal (30, the tone ink, the mark 16 bold in card, ringed 3) at
/// `inset-inline-end:-6px; bottom:-4px`; the name at 26/32 display and the
/// sub at 13/18 `--ink-soft`.
class DabblerActivityAward extends StatelessWidget {
  /// A spotlight.
  const DabblerActivityAward({
    super.key,
    required this.seed,
    required this.mark,
    required this.ink,
    required this.headline,
    required this.sub,
    this.imageUrl,
  });

  final String seed;
  final String? imageUrl;

  /// The medal glyph (`a.mark`: `medal-star`, `crown`).
  final String mark;
  final Color ink;
  final String headline;
  final String sub;

  /// `outline:4px` round the avatar.
  static const double avatarRing = 4;

  /// The medal: `30px`.
  static const double medalSize = 30;

  /// `outline:3px` round the medal.
  static const double medalRing = DabblerSpacing.space1;

  /// The medal glyph: `size="16"`.
  static const double medalIconSize = 16;

  /// `inset-inline-end:-6px`.
  static const double medalInsetEnd = -DabblerSpacing.space2;

  /// `bottom:-4px`.
  static const double medalInsetBottom = -4;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: DabblerSpacing.space1),
      child: Column(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              DabblerAvatar(
                seed: seed,
                imageUrl: imageUrl,
                size: DabblerAvatarSize.xl,
                ringColor: colors.surfaceCard,
                ringWidth: avatarRing,
              ),
              PositionedDirectional(
                end: medalInsetEnd - medalRing,
                bottom: medalInsetBottom - medalRing,
                child: DecoratedBox(
                  key: const ValueKey<String>('activity-award-medal'),
                  decoration: BoxDecoration(
                    color: colors.surfaceCard,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(medalRing),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: ink,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox.square(
                        dimension: medalSize,
                        child: Center(
                          child: DabblerIcon(
                            mark,
                            size: medalIconSize,
                            weight: DabblerIconWeight.bold,
                            color: colors.surfaceCard,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DabblerSpacing.space3),
          _line(
            context,
            headline,
            DabblerType.displaySection,
            colors.textPrimary,
            align: TextAlign.center,
          ),
          const SizedBox(height: DabblerSpacing.space3),
          _line(
            context,
            sub,
            DabblerType.footnote,
            colors.textSecondary,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// The three-figure strip (`a.hasStats`): three equal columns, `gap:6px`;
/// each `padding:9px 6px`, `--radius-lg`, card, centred, `gap:1px`, the value
/// at 20/25 display `--ink` over the label at 11/13 `--muted`.
class DabblerActivityStats extends StatelessWidget {
  /// A strip.
  const DabblerActivityStats({super.key, required this.items});

  /// `(value, label)` pairs; the strip always has [columns] columns.
  final List<(String, String)> items;

  /// `repeat(3, minmax(0, 1fr))`.
  static const int columns = 3;

  /// `gap:6px`.
  static const double gap = DabblerSpacing.space2;

  /// `padding:9px 6px`.
  static const EdgeInsets cellPadding = EdgeInsets.symmetric(
    horizontal: DabblerSpacing.space2,
    vertical: DabblerSpacing.space3,
  );

  /// `gap:1px` between value and label.
  static const double cellGap = 1;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    Widget cell((String, String) s) => DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: DabblerRadius.lgAll,
      ),
      child: Padding(
        padding: cellPadding,
        child: Column(
          children: <Widget>[
            _line(context, s.$1, DabblerType.title3, colors.textPrimary),
            const SizedBox(height: cellGap),
            _line(
              context,
              s.$2,
              DabblerType.caption2,
              colors.textTertiary,
              align: TextAlign.center,
            ),
          ],
        ),
      ),
    );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < columns; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: gap),
            Expanded(
              child: i < items.length
                  ? cell(items[i])
                  : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }
}

/// The featured venue's photo (`a.isFeature`): 150 tall, full width,
/// `--radius-lg`, on the card surface; the rating pill at
/// `bottom:9px; inset-inline-start:9px` (`padding:4px 9px`, `gap:4px`, card,
/// a 13 bold star in `--tile-amber-surface`, 12/16 `--ink`).
class DabblerActivityPhoto extends StatelessWidget {
  /// A photo.
  const DabblerActivityPhoto({super.key, this.url, required this.ratingText});

  /// The venue photo; null leaves the card-surface frame empty.
  final String? url;

  /// `a.ratingText`: "4.7 · 312 reviews"; empty hides the pill.
  final String ratingText;

  /// `height:150px`.
  static const double height = 150;

  /// `bottom:9px; inset-inline-start:9px`.
  static const double pillInset = DabblerSpacing.space3;

  /// `padding:4px 9px`.
  static const EdgeInsets pillPadding = EdgeInsets.symmetric(
    horizontal: DabblerSpacing.space3,
    vertical: 4,
  );

  /// `gap:4px`.
  static const double pillGap = 4;

  /// The star: `size="13"`.
  static const double starSize = 13;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final String? src = url;
    return ClipRRect(
      borderRadius: DabblerRadius.lgAll,
      child: ColoredBox(
        color: colors.surfaceCard,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            children: <Widget>[
              if (src != null && src.trim().isNotEmpty)
                Positioned.fill(
                  child: DabblerImage(url: src, radius: BorderRadius.zero),
                ),
              if (ratingText.isNotEmpty)
                PositionedDirectional(
                  bottom: pillInset,
                  start: pillInset,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      key: const ValueKey<String>('activity-photo-rating'),
                      decoration: BoxDecoration(
                        color: colors.surfaceCard,
                        borderRadius: DabblerRadius.pillAll,
                      ),
                      child: Padding(
                        padding: pillPadding,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const DabblerIcon(
                              'star',
                              size: starSize,
                              weight: DabblerIconWeight.bold,
                              color: DabblerPalette.tileAmberSurface,
                            ),
                            const SizedBox(width: pillGap),
                            _line(
                              context,
                              ratingText,
                              DabblerType.caption1,
                              colors.textPrimary,
                              oneLine: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A reason the venue is recommended (`a.reasons`): `padding:5px 10px 5px
/// 8px`, `gap:5px`, card, a 14 bold glyph in the tone ink, 12/16 `--ink`.
class DabblerActivityReason extends StatelessWidget {
  /// A reason.
  const DabblerActivityReason({
    super.key,
    required this.icon,
    required this.text,
    required this.ink,
  });

  final String icon;
  final String text;
  final Color ink;

  /// `padding:5px 10px 5px 8px`.
  static const EdgeInsetsDirectional padding = EdgeInsetsDirectional.fromSTEB(
    8,
    5,
    10,
    5,
  );

  /// `gap:5px`.
  static const double gap = 5;

  /// The glyph: `size="14"`.
  static const double iconSize = 14;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: DabblerRadius.pillAll,
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DabblerIcon(
              icon,
              size: iconSize,
              weight: DabblerIconWeight.bold,
              color: ink,
            ),
            const SizedBox(width: gap),
            Flexible(
              child: _line(
                context,
                text,
                DabblerType.caption1,
                colors.textPrimary,
                oneLine: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The venue rating's quote box (`a.isReview`): `padding:12px`, `gap:9px`,
/// `--radius-lg`, card; the rater row (`gap:9px`: the 36 avatar, the name at
/// 15/20 `--ink` over the line at 12/16 `--muted`, the small star rating) and
/// the quote at 18/24 display `--ink` in curly quotes.
class DabblerActivityReview extends StatelessWidget {
  /// A quote box.
  const DabblerActivityReview({
    super.key,
    required this.seed,
    required this.name,
    required this.line,
    required this.rating,
    required this.ratingLabel,
    required this.quote,
    this.imageUrl,
  });

  final String seed;
  final String name;
  final String? imageUrl;

  /// `a.actorLine`.
  final String line;
  final double rating;

  /// The rating's accessible name ("Rated 5 out of 5").
  final String ratingLabel;
  final String quote;

  /// `padding:12px`.
  static const double padding = DabblerSpacing.space4;

  /// `gap:9px`.
  static const double gap = DabblerSpacing.space3;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: DabblerRadius.lgAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                DabblerAvatar(
                  seed: seed,
                  imageUrl: imageUrl,
                  size: DabblerAvatarSize.sm,
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _line(
                        context,
                        name,
                        DabblerType.subheadline,
                        colors.textPrimary,
                        oneLine: true,
                      ),
                      if (line.isNotEmpty)
                        _line(
                          context,
                          line,
                          DabblerType.caption1,
                          colors.textTertiary,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: gap),
                DabblerRating(
                  value: rating,
                  size: DabblerRatingSize.sm,
                  label: ratingLabel,
                ),
              ],
            ),
            const SizedBox(height: gap),
            _line(
              context,
              '“$quote”',
              DabblerType.displayQuote,
              colors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

/// The rated venue under the quote: `gap:9px`; a 40 tile (`--radius-md`,
/// card, `building-4` 20 linear in the tone ink) and the name at 15/20
/// `--ink` (one line) over the detail at 12/16 `--ink-soft`.
class DabblerActivityVenueRow extends StatelessWidget {
  /// A row.
  const DabblerActivityVenueRow({
    super.key,
    required this.title,
    required this.detail,
    required this.ink,
  });

  final String title;
  final String detail;
  final Color ink;

  /// The tile: `40px`.
  static const double tileSize = 40;

  /// The glyph: `size="20"`.
  static const double iconSize = 20;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Row(
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: DabblerRadius.mdAll,
          ),
          child: SizedBox.square(
            dimension: tileSize,
            child: Center(
              child: DabblerIcon('building-4', size: iconSize, color: ink),
            ),
          ),
        ),
        const SizedBox(width: DabblerSpacing.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _line(
                context,
                title,
                DabblerType.subheadline,
                colors.textPrimary,
                oneLine: true,
              ),
              if (detail.isNotEmpty)
                _line(
                  context,
                  detail,
                  DabblerType.caption1,
                  colors.textSecondary,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
