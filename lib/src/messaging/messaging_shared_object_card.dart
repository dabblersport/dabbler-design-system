/// [DabblerSharedObjectCard] — a game, venue or player shared in a thread.
///
/// Split out of `messaging_parts.dart` (which re-exports it) to keep both
/// files under the 500-line ceiling.
library;

import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../controls/chip.dart';
import '../foundations/icon.dart';
import '../foundations/sport_icon.dart';
import '../foundations/sports.dart';
import '../surfaces/avatar.dart';
import '../surfaces/badge.dart';
import '../surfaces/icon_tile.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'messaging_foundations.dart';

TextStyle _t(BuildContext c, DabblerTypeStyle s) =>
    s.resolveForDirection(Directionality.of(c));

/// A line of meta (glyph + text) on a [DabblerSharedObjectCard].
@immutable
class DabblerSharedMeta {
  /// A meta line.
  const DabblerSharedMeta({required this.icon, required this.text});

  /// The Iconsax glyph (drawn bold, 14px, brand).
  final String icon;

  /// The text.
  final String text;
}

/// What a [DabblerSharedObjectCard] shares.
enum DabblerSharedKind {
  /// A game, with a sport tile, title and status badge.
  game,

  /// A venue, with a photo slot on top.
  venue,

  /// A player, with an avatar.
  player,
}

/// SharedObjectCard — a game, venue or player shared inside a conversation.
///
/// Source: `components/messaging/SharedObjectCard.jsx`. The prompt file says
/// `--surface-card`; the JSX paints a decorative pastel per kind (`PASTEL`)
/// and the JSX is followed.
///
/// | Source | Dart |
/// |---|---|
/// | `PASTEL.game` surface `--tile-info-surface`, chip `--tile-accent-surface` | [surfaceFor] / [chipFor] |
/// | `PASTEL.player` surface `--tile-accent-surface`, chip `--tile-info-surface` | same |
/// | `PASTEL.venue` surface `--tile-info-surface`, chip `--surface-card` | same |
/// | frame `1px --outline-card`, `--radius-lg`, padding `--space-4`, gap `--space-3` | `borderDefault`, lg radius, 12, 9 |
/// | venue: padding 0, `overflow: hidden`, 120px `image-slot`, body padding 12 gap 9 | [photoHeight], [photoPlaceholder] |
/// | game: `IconTile size=36`, `SportIcon` bold 20, gap `--space-3`; title nowrap ellipsis | 36 tile, 20 glyph, 9 |
/// | player: `Avatar size="md"`, gap `--space-4` | `DabblerAvatarSize.md`, 12 |
/// | title `.t-subheadline` 700 `--ink`; subtitle `.t-caption-1` `--muted` | subheadline w700 `textPrimary`; caption1 `textSecondary` |
/// | meta: gap `--space-2`, `Icon` bold 14 brand, `.t-footnote` `--ink-soft` | 6, 14, `textSecondary` (light `#404040`) |
/// | footnote `.t-caption-1` `--muted` | caption1 `textSecondary` |
/// | `Chip style={{background: pastel.chip, color: --ink}}` | a pastel pill on the `Chip` metrics |
/// | `Button tone="primary" size="small" fullWidth` | [DabblerButton] small, full width |
///
/// The `--tile-*-surface` tokens have no dark value in `tokens/colors.css`, so
/// the ground stays pastel in dark mode, as in the source.
class DabblerSharedObjectCard extends StatelessWidget {
  /// A shared object.
  const DabblerSharedObjectCard({
    super.key,
    this.kind = DabblerSharedKind.game,
    required this.title,
    this.subtitle,
    this.sport,
    this.seed,
    this.meta = const <DabblerSharedMeta>[],
    this.status,
    this.statusLabel,
    this.chips = const <String>[],
    this.photo,
    this.photoPlaceholder = 'Venue photo',
    this.cta,
    this.onPress,
    this.footnote,
  });

  /// Game, venue or player.
  final DabblerSharedKind kind;

  /// The name.
  final String title;

  /// The line under the name.
  final String? subtitle;

  /// The sport of a game (football when null, as the source).
  final DabblerSport? sport;

  /// The avatar seed of a player; defaults to [title].
  final String? seed;

  /// Meta lines.
  final List<DabblerSharedMeta> meta;

  /// The game's activity status.
  final DabblerActivityStatus? status;

  /// Overrides the status label.
  final String? statusLabel;

  /// Chips under a player or venue.
  final List<String> chips;

  /// The venue photo, supplied by the caller (120px tall).
  final Widget? photo;

  /// Shown in the empty photo slot — the source's `slotPlaceholder`.
  final String photoPlaceholder;

  /// The call-to-action label.
  final String? cta;

  /// Called by the call to action.
  final VoidCallback? onPress;

  /// A footnote under a game's meta.
  final String? footnote;

  /// The photo height — `height: 120`.
  static const double photoHeight = 120;

  /// The sport tile — `IconTile size={36}`.
  static const double tileSize = 36;

  /// The sport glyph — `size={20}`.
  static const double sportGlyph = 20;

  /// The meta glyph — `size={14}`.
  static const double metaGlyph = 14;

  /// The ground of [kind] — `PASTEL[kind].surface`.
  static Color surfaceFor(DabblerColors colors, DabblerSharedKind kind) =>
      switch (kind) {
        DabblerSharedKind.player => DabblerColors.tileAccent.surface,
        _ => DabblerColors.tileInfo.surface,
      };

  /// The chip fill of [kind] — `PASTEL[kind].chip`.
  static Color chipFor(DabblerColors colors, DabblerSharedKind kind) =>
      switch (kind) {
        DabblerSharedKind.game => DabblerColors.tileAccent.surface,
        DabblerSharedKind.player => DabblerColors.tileInfo.surface,
        DabblerSharedKind.venue => colors.surfaceCard,
      };

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final List<Widget> sections = <Widget>[];
    void add(Widget w) {
      if (sections.isNotEmpty) {
        sections.add(const SizedBox(height: DabblerSpacing.space3));
      }
      sections.add(w);
    }

    Widget titles({required bool clampTitle}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          maxLines: clampTitle ? 1 : null,
          softWrap: !clampTitle,
          overflow: clampTitle ? TextOverflow.ellipsis : null,
          style: _t(
            context,
            DabblerType.subheadline,
          ).copyWith(fontWeight: FontWeight.w700, color: colors.textPrimary),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: _t(
              context,
              DabblerType.caption1,
            ).copyWith(color: colors.textSecondary),
          ),
      ],
    );

    switch (kind) {
      case DabblerSharedKind.player:
        add(
          Row(
            children: <Widget>[
              DabblerAvatar(seed: seed ?? title, size: DabblerAvatarSize.md),
              const SizedBox(width: DabblerSpacing.space4),
              Expanded(child: titles(clampTitle: false)),
            ],
          ),
        );
      case DabblerSharedKind.venue:
        add(titles(clampTitle: false));
      case DabblerSharedKind.game:
        add(
          Row(
            children: <Widget>[
              DabblerIconTile(
                DabblerSportIcon(
                  sport ?? DabblerSport.football,
                  weight: DabblerIconWeight.bold,
                  size: sportGlyph,
                  color: colors.brandPrimary,
                ),
                size: tileSize,
              ),
              const SizedBox(width: DabblerSpacing.space3),
              Expanded(child: titles(clampTitle: true)),
              if (status != null) ...<Widget>[
                const SizedBox(width: DabblerSpacing.space3),
                DabblerBadge(
                  label: statusLabel ?? status!.label,
                  status: status!.tone == null
                      ? DabblerBadge.neutralStatusOf(colors)
                      : colors.status(status!.tone!),
                ),
              ],
            ],
          ),
        );
    }
    if (kind != DabblerSharedKind.game && chips.isNotEmpty) {
      add(
        Wrap(
          spacing: DabblerSpacing.space2,
          runSpacing: DabblerSpacing.space2,
          children: <Widget>[
            for (final String c in chips)
              _PastelChip(label: c, fill: chipFor(colors, kind)),
          ],
        ),
      );
    }
    if (meta.isNotEmpty) {
      add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int i = 0; i < meta.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  top: i == 0 ? 0 : DabblerSpacing.space2,
                ),
                child: Row(
                  children: <Widget>[
                    DabblerIcon(
                      meta[i].icon,
                      weight: DabblerIconWeight.bold,
                      size: metaGlyph,
                      color: colors.brandPrimary,
                    ),
                    const SizedBox(width: DabblerSpacing.space2),
                    Flexible(
                      child: Text(
                        meta[i].text,
                        style: _t(
                          context,
                          DabblerType.footnote,
                        ).copyWith(color: colors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }
    if (kind == DabblerSharedKind.game && footnote != null) {
      add(
        Text(
          footnote!,
          style: _t(
            context,
            DabblerType.caption1,
          ).copyWith(color: colors.textSecondary),
        ),
      );
    }
    if (cta != null) {
      add(
        DabblerButton(
          label: cta!,
          size: DabblerButtonSize.small,
          fullWidth: true,
          onPressed: onPress,
        ),
      );
    }

    final Widget body = Padding(
      padding: const EdgeInsets.all(DabblerSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: sections,
      ),
    );

    final Widget inner = kind == DabblerSharedKind.venue
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: photoHeight,
                child:
                    photo ??
                    ColoredBox(
                      color: colors.surfaceSunken,
                      child: Center(
                        child: Text(
                          photoPlaceholder,
                          style: DabblerType.caption1
                              .resolveForDirection(dir)
                              .copyWith(color: colors.textSecondary),
                        ),
                      ),
                    ),
              ),
              body,
            ],
          )
        : body;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceFor(colors, kind),
        borderRadius: DabblerRadius.lgAll,
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      // The source's border sits outside its padding (and clips the venue
      // photo inside it), so content is inset by the 1px hairline too.
      child: Padding(
        padding: const EdgeInsets.all(DabblerSizing.borderDefault),
        child: ClipRRect(borderRadius: DabblerRadius.lgAll, child: inner),
      ),
    );
  }
}

/// A static `Chip` whose fill is overridden, as `style={chipStyle}` does:
/// the chip's own padding, radius, hairline and label type, with the pastel
/// fill and `--ink` label.
class _PastelChip extends StatelessWidget {
  const _PastelChip({required this.label, required this.fill});

  final String label;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(DabblerChip.radius),
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          // `Surface.jsx` draws its 1px border outside the `9px 15px` padding
          // span, so the hairline is added here (live pill: 40px tall).
          horizontal:
              DabblerChip.horizontalPadding + DabblerSizing.borderDefault,
          vertical: DabblerChip.verticalPadding + DabblerSizing.borderDefault,
        ),
        child: Text(
          label,
          maxLines: 1,
          style: DabblerChip.labelStyleFor(
            colors,
            Directionality.of(context),
            selected: false,
          ).copyWith(color: colors.textPrimary),
        ),
      ),
    );
  }
}
