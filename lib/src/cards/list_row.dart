import 'package:flutter/widgets.dart';

import '../feed/feed_atoms.dart';
import '../foundations/icon.dart';
import '../layout/divider.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_home_frame.dart';
import '../tokens/dabbler_type.dart';

/// The fill of a [DabblerListGroup] — the surfaces the Details frames set
/// their rows on.
enum DabblerListGroupTone {
  /// `--surface-sunken` — the squad list (`Details.dc.html:120`).
  sunken,

  /// `--tile-info-surface` — the host card and the contact list
  /// (`Details.dc.html:101`, `:466`).
  info,

  /// `--tile-accent-surface` — the community-host card
  /// (`Details.dc.html:270`).
  accent,

  /// `--tile-amber-surface`.
  amber,
}

/// ListRow — one row of a [DabblerListGroup]: an optional leading slot, a
/// title with an optional small overline above and subtitle below, and an
/// optional trailing slot.
///
/// Drawn from the Details frames (`Details.dc.html`): the squad row `:122-133`
/// (avatar, name, note, tag), the open-spot row `:135-146` (round icon,
/// two lines, a button), the host card `:101-114` (avatar, "Hosted by" above
/// the name, a pill) and the contact row `:466-476` (icon, label above the
/// value, a chevron).
///
/// ```dart
/// DabblerListRow(
///   leading: DabblerAvatar(seed: name, size: DabblerAvatarSize.sm),
///   title: 'Ahmed Farouk',
///   subtitle: 'Host',
///   trailing: const DabblerBadge(label: 'Host'),
///   onTap: openProfile,
/// )
/// ```
///
/// ## Slots, not data
///
/// [leading] and [trailing] are widgets so the row stays one shape for an
/// avatar, an icon tile, a badge, a button or a chevron. The row itself owns
/// the padding, the text styles and the tap.
///
/// ## Type, and where it snaps
///
/// * [title] — `subheadline` (15/20) at weight 600. The design draws 14/19;
///   the ramp has no 14, and 15 is the step the other rows in this system
///   already snap to (`DabblerMemberListPanel`).
/// * [overline] — `caption2` (11/15) in the secondary ink, above the title
///   (`Details.dc.html:107, 469`).
/// * [subtitle] — `caption1` (12/16) in the secondary ink.
///
/// ## Padding
///
/// [DabblerSpacing.space5] (15) at the sides and [DabblerSpacing.space4] (12)
/// above and below: the squad row's own values. The contact row draws 14
/// vertically; it takes the same 12 as every other row in the group so a group
/// never mixes row heights.
///
/// ## Interaction
///
/// With [onTap] the whole row is one button with the shared press and focus
/// treatment ([DabblerFeedTappable]); [trailing] keeps its own semantics when
/// it is a button of its own. [showChevron] adds the design's forward arrow
/// (`arrow-circle-right`), which mirrors in right-to-left.
///
/// ## RTL
///
/// Everything is directional: [leading] sits at the inline start, [trailing]
/// at the inline end, and the chevron mirrors.
class DabblerListRow extends StatelessWidget {
  /// A list row.
  const DabblerListRow({
    super.key,
    required this.title,
    this.overline,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    this.semanticLabel,
    this.flat = false,
    this.brand = false,
    this.metrics = DabblerFeedMetrics.touch,
  });

  /// [DabblerFeedMetrics.drawn] draws the row as the Home city sheet's area
  /// row: the title at the regular weight, 1 between title and subtitle (a
  /// row with a subtitle is 62 with its hairline). Default unchanged.
  final DabblerFeedMetrics metrics;

  /// The row's main line.
  final String title;

  /// A small line above [title].
  final String? overline;

  /// A line below [title].
  final String? subtitle;

  /// The inline-start slot — an avatar, an icon tile, a round icon.
  final Widget? leading;

  /// The inline-end slot — a badge, a button, a pill.
  final Widget? trailing;

  /// Makes the whole row a button.
  final VoidCallback? onTap;

  /// Draws the forward arrow at the inline end, after [trailing].
  final bool showChevron;

  /// The accessible name of a tappable row. Null lets the text compose it.
  final String? semanticLabel;

  /// The sheet-list form: no inline padding (the host supplies the gutter) and
  /// a 1px `--faint` hairline under the row — the Listings "Change location"
  /// rows (`Listings.dc.html:343-364`, `padding:12px 0; border-bottom:1px solid
  /// var(--faint)`). Default false keeps the grouped-panel row exactly.
  final bool flat;

  /// Sets [title] in the brand colour — the "Use current location" row
  /// (`Listings.dc.html:340-341`). Default false.
  final bool brand;

  /// The gap between the slots and the text — [DabblerSpacing.space4].
  static const double gap = DabblerSpacing.space4;

  /// The side padding — [DabblerSpacing.space5].
  static const double paddingInline = DabblerSpacing.space5;

  /// The vertical padding — [DabblerSpacing.space4].
  static const double paddingBlock = DabblerSpacing.space4;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);

    final Widget text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (overline != null)
          Text(
            overline!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DabblerType.caption2
                .resolveForDirection(direction)
                .copyWith(color: colors.textSecondary),
          ),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: DabblerType.subheadline
              .resolveForDirection(direction)
              .copyWith(
                color: brand ? colors.brandPrimary : colors.textPrimary,
                fontWeight: metrics == DabblerFeedMetrics.drawn
                    ? DabblerType.regular
                    : DabblerType.semibold,
              ),
        ),
        if (subtitle != null && metrics == DabblerFeedMetrics.drawn)
          const SizedBox(height: DabblerHomeFrame.listRowSubtitleGap),
        if (subtitle != null)
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DabblerType.caption1
                .resolveForDirection(direction)
                .copyWith(color: colors.textSecondary),
          ),
      ],
    );

    final Widget row = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: flat ? 0 : paddingInline,
        vertical: paddingBlock,
      ),
      child: Row(
        children: <Widget>[
          if (leading != null) ...<Widget>[
            leading!,
            const SizedBox(width: gap),
          ],
          Expanded(child: text),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: gap),
            trailing!,
          ],
          if (showChevron) ...<Widget>[
            const SizedBox(width: gap),
            ExcludeSemantics(
              child: DabblerIcon(
                'arrow-circle-right',
                mirrorInRtl: true,
                size: DabblerSizing.iconSm,
                color: colors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );

    final Widget tappable = DabblerFeedTappable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: row,
    );
    if (!flat) return tappable;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[tappable, const DabblerDivider()],
    );
  }
}

/// ListGroup — a rounded panel that stacks [DabblerListRow]s with a hairline
/// between each.
///
/// The Details frames put their rows in a `--radius-lg` block on one of the
/// pastel or sunken fills, `overflow: hidden`, with a hairline under every row
/// but the last (`Details.dc.html:120-148`, `:466-478`). This is that block;
/// [children] are usually [DabblerListRow]s but may be any widget.
///
/// ```dart
/// DabblerListGroup(
///   tone: DabblerListGroupTone.info,
///   children: <Widget>[
///     DabblerListRow(overline: 'Phone', title: '+971 4 691 0256', showChevron: true),
///     DabblerListRow(overline: 'Website', title: 'elitefootballarena.ae', showChevron: true),
///   ],
/// )
/// ```
///
/// ## Corner
///
/// [DabblerRadius.lg] (12), the design's `--radius-lg`. The group clips its
/// children to it.
///
/// ## RTL
///
/// Nothing here is directional; the rows mirror themselves.
class DabblerListGroup extends StatelessWidget {
  /// A group of rows on [tone].
  const DabblerListGroup({
    super.key,
    required this.children,
    this.tone = DabblerListGroupTone.sunken,
  });

  /// The rows, top to bottom.
  final List<Widget> children;

  /// The fill. Defaults to [DabblerListGroupTone.sunken].
  final DabblerListGroupTone tone;

  /// The group's corner — [DabblerRadius.lg].
  static const double radius = DabblerRadius.lg;

  /// The fill of [tone] in [colors].
  static Color fillOf(DabblerColors colors, DabblerListGroupTone tone) =>
      switch (tone) {
        DabblerListGroupTone.sunken => colors.surfaceSunken,
        DabblerListGroupTone.info => DabblerColors.tileInfo.surface,
        DabblerListGroupTone.accent => DabblerColors.tileAccent.surface,
        DabblerListGroupTone.amber => DabblerColors.tileAmber.surface,
      };

  @override
  Widget build(BuildContext context) {
    final Color fill = fillOf(DabblerColors.of(context), tone);
    return DabblerSurface(
      fill: fill,
      borderColor: fill,
      radius: radius,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            if (i > 0) const DabblerDivider(),
            children[i],
          ],
        ],
      ),
    );
  }
}
