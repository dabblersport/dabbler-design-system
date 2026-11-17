/// NotificationCard — the Notification Center row of the KAN-988 card
/// library, transcribed from `project/NotificationRow.dc.html`: one row that
/// draws every card family (avatar, avatar pair, icon tile or sport tile;
/// actor and verb, time, unread dot and the ⋯ button; urgent pill, sub,
/// excerpt with thumbnail, old → new change, meta, "See all N people" with
/// its list, action pills, the pending line, the result strip with its link,
/// and the inline menu).
///
/// The row draws state; it holds none. The caller decides which parts show
/// (an action that is running shows [DabblerNotificationCard.pending] instead
/// of its pills, a finished one its result) and owns the menu and people
/// toggles.
library;

import 'package:flutter/material.dart';

import '../feedback/spinner.dart';
import '../foundations/icon.dart';
import '../foundations/sport_icon.dart';
import '../foundations/sports.dart';
import '../media/image.dart';
import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'feed_atoms.dart';
import 'notification_row.dart' show DabblerNotificationMeta;

/// The row's tones (`TN` in `Notifications & Live Activities.dc.html`):
/// the icon tile's and the result strip's ground and ink.
enum DabblerNotificationTone {
  /// `--surface-sunken` / `--color-brand-primary`.
  brand,

  /// The success surface / strong ink.
  ok,

  /// The warning surface / strong ink.
  warn,

  /// The error surface / strong ink.
  err,

  /// The info surface / strong ink.
  info,

  /// `--tile-amber-surface` / `--tile-amber-ink`.
  amber,

  /// `--surface-sunken` / `--ink-soft`.
  neutral;

  /// The ground and ink in [colors].
  DabblerToneColor of(DabblerColors colors) => switch (this) {
    brand => DabblerToneColor(
      surface: colors.surfaceSunken,
      ink: colors.brandPrimary,
    ),
    ok => DabblerToneColor(
      surface: colors.success.surface,
      ink: colors.success.strong,
    ),
    warn => DabblerToneColor(
      surface: colors.warning.surface,
      ink: colors.warning.strong,
    ),
    err => DabblerToneColor(
      surface: colors.error.surface,
      ink: colors.error.strong,
    ),
    info => DabblerToneColor(
      surface: colors.info.surface,
      ink: colors.info.strong,
    ),
    amber => colors.tileAmberTone,
    neutral => DabblerToneColor(
      surface: colors.surfaceSunken,
      ink: colors.textSecondary,
    ),
  };
}

TextStyle _s(BuildContext context, DabblerTypeStyle s, Color c) =>
    s.resolveForDirection(Directionality.of(context)).copyWith(color: c);

/// The 40 leading column's 38 icon tile: `--radius-lg`, the tone's ground,
/// a 20 bold glyph in its ink.
class DabblerNotificationIconTile extends StatelessWidget {
  /// A tile.
  const DabblerNotificationIconTile({
    super.key,
    required this.icon,
    this.tone = DabblerNotificationTone.brand,
  });

  final String icon;
  final DabblerNotificationTone tone;

  /// `38px`.
  static const double size = 38;

  /// The glyph: `size="20"`.
  static const double glyph = 20;

  @override
  Widget build(BuildContext context) {
    final DabblerToneColor t = tone.of(DabblerColors.of(context));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: DabblerRadius.lgAll,
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: DabblerIcon(
            icon,
            size: glyph,
            weight: DabblerIconWeight.bold,
            color: t.ink,
          ),
        ),
      ),
    );
  }
}

/// The 38 sport tile: `--radius-lg`, `--surface-sunken` with the card
/// hairline, the sport's 24 glyph.
class DabblerNotificationSportTile extends StatelessWidget {
  /// A tile for [sportKey] (kebab-case; an unknown sport draws the generic
  /// glyph).
  const DabblerNotificationSportTile({super.key, required this.sportKey});

  final String sportKey;

  /// `38px`.
  static const double size = 38;

  /// The glyph: `24px`.
  static const double glyph = DabblerSizing.iconMd;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final DabblerSport? sport = DabblerSport.fromKey(sportKey);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: DabblerRadius.lgAll,
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: sport != null
              ? DabblerSportIcon(sport, size: glyph)
              : DabblerSportIcon.fromKey(sportKey, size: glyph),
        ),
      ),
    );
  }
}

/// Two avatars in the 40 square (`leadPair`): the first at the top start,
/// the second at the bottom end ringed 2 in the card surface, each the 36
/// avatar at 78% (28).
class DabblerNotificationAvatarPair extends StatelessWidget {
  /// A pair.
  const DabblerNotificationAvatarPair({
    super.key,
    required this.seed,
    required this.seed2,
    this.imageUrl,
    this.imageUrl2,
  });

  final String seed;
  final String seed2;
  final String? imageUrl;
  final String? imageUrl2;

  /// The square: `40px`.
  static const double box = 40;

  /// `transform:scale(0.78)` of the 36 avatar.
  static const double scale = 0.78;

  /// The second avatar's ring: `outline:2px`.
  static const double ring = 2;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final double d = DabblerAvatarSize.sm.diameter * scale;
    Widget avatar(String seed, String? url, {bool ringed = false}) =>
        SizedBox.square(
          dimension: d,
          child: FittedBox(
            child: DabblerAvatar(
              seed: seed,
              imageUrl: url,
              size: DabblerAvatarSize.sm,
              ringColor: ringed ? colors.surfaceCard : null,
              ringWidth: ring / scale,
            ),
          ),
        );
    return SizedBox.square(
      dimension: box,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          PositionedDirectional(
            start: 0,
            top: 0,
            child: avatar(seed, imageUrl),
          ),
          PositionedDirectional(
            end: 0,
            bottom: 0,
            child: avatar(seed2, imageUrl2, ringed: true),
          ),
        ],
      ),
    );
  }
}

/// The excerpt box (`hasEx`): `padding:8px 9px`, `gap:9px`, `--radius-md`,
/// `--surface-sunken`; the label (11/15 600 `--muted`) over the text (13/18
/// `--ink-soft`, two lines), and the 42 thumbnail (`--radius-sm`, hairline).
@immutable
class DabblerNotificationExcerpt {
  /// An excerpt.
  const DabblerNotificationExcerpt({
    required this.label,
    required this.text,
    this.thumbnailUrl,
  });

  /// "Your post", "Your comment".
  final String label;
  final String text;
  final String? thumbnailUrl;
}

/// The old → new change (`hasChg`): the label and the old value (`--muted`,
/// struck through), `arrow-right` 13, the new value (`--ink`, 600); 13/18,
/// wrapping with `gap:4px 8px`.
@immutable
class DabblerNotificationChange {
  /// A change.
  const DabblerNotificationChange({
    required this.label,
    required this.from,
    required this.to,
  });

  final String label;
  final String from;
  final String to;
}

/// One person of the aggregation list.
@immutable
class DabblerNotificationPerson {
  /// A person.
  const DabblerNotificationPerson({
    required this.name,
    this.time,
    this.imageUrl,
  });

  /// The name as entered (never translated).
  final String name;
  final String? time;
  final String? imageUrl;
}

/// The aggregation (`hasAgg`): the toggle ("See all N people" / "Hide
/// people", 12/17 600 brand) and, when [open], the list under a `--faint`
/// rule: a 26 avatar (the 36 at 72%), the name (13/18 `--ink`) and the time
/// (11/15 `--muted`), `gap:6px`.
@immutable
class DabblerNotificationPeople {
  /// An aggregation.
  const DabblerNotificationPeople({
    required this.toggleLabel,
    required this.people,
    required this.open,
    this.onToggle,
  });

  final String toggleLabel;
  final List<DabblerNotificationPerson> people;
  final bool open;
  final VoidCallback? onToggle;
}

/// One action pill: `min-height:34px`, `padding:0 15px`, `--radius-pill`,
/// 13/18 600; [primary] brand-filled, else the card with the hairline.
@immutable
class DabblerNotificationCardAction {
  /// An action.
  const DabblerNotificationCardAction(
    this.label, {
    this.onPressed,
    this.primary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
}

/// The result strip (`showRes`): `padding:8px 10px`, `gap:7px`,
/// `--radius-md`, the tone's ground and ink; a 15 bold glyph, the text
/// (12/17 600) and an optional underlined link ("Undo", "Retry").
@immutable
class DabblerNotificationResult {
  /// A result.
  const DabblerNotificationResult({
    required this.icon,
    required this.text,
    this.tone = DabblerNotificationTone.neutral,
    this.linkLabel,
    this.onLink,
  });

  final String icon;
  final String text;
  final DabblerNotificationTone tone;
  final String? linkLabel;
  final VoidCallback? onLink;
}

/// One inline menu item (`menuOpen`): `min-height:40px`, `padding:0 12px`,
/// `gap:9px`, a 15 glyph, 13/18 `--ink`, a `--faint` rule under it.
@immutable
class DabblerNotificationMenuItem {
  /// An item.
  const DabblerNotificationMenuItem({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final String icon;
  final String label;
  final VoidCallback? onPressed;
}

/// The row (`NotificationRow.dc.html`): `padding:12px`, `gap:12px`,
/// `--radius-lg`; unread on `--surface-card` inside `--outline-card`, read
/// transparent inside `--faint`; the 40 leading column; the content column
/// `gap:4px`.
class DabblerNotificationCard extends StatelessWidget {
  /// A row.
  const DabblerNotificationCard({
    super.key,
    required this.leading,
    required this.actor,
    this.verb = '',
    this.time,
    this.unread = false,
    this.onOpen,
    this.onMenu,
    this.menuLabel = 'More options',
    this.urgent,
    this.sub,
    this.excerpt,
    this.change,
    this.meta = const <DabblerNotificationMeta>[],
    this.people,
    this.actions = const <DabblerNotificationCardAction>[],
    this.pending,
    this.result,
    this.menu,
    this.semanticLabel,
  });

  /// [DabblerAvatar] (sm), [DabblerNotificationAvatarPair],
  /// [DabblerNotificationIconTile] or [DabblerNotificationSportTile].
  final Widget leading;

  /// Who or what, in `--ink` (700 unread, 600 read).
  final String actor;

  /// What happened, after the actor, in `--ink-soft`.
  final String verb;
  final String? time;
  final bool unread;

  /// Opens the notification (the leading and the head text).
  final VoidCallback? onOpen;

  /// Toggles the menu (the ⋯ button); null hides the button.
  final VoidCallback? onMenu;

  /// The ⋯ button's accessible name.
  final String menuLabel;

  /// The urgent pill's text.
  final String? urgent;

  /// The 2-line sub (14/19 500 `--ink`).
  final String? sub;
  final DabblerNotificationExcerpt? excerpt;
  final DabblerNotificationChange? change;
  final List<DabblerNotificationMeta> meta;
  final DabblerNotificationPeople? people;
  final List<DabblerNotificationCardAction> actions;

  /// The pending line's text ("Sending…"); shows the spinner.
  final String? pending;
  final DabblerNotificationResult? result;

  /// The open menu's items; null when closed.
  final List<DabblerNotificationMenuItem>? menu;

  /// The row's accessible name (`aria-label`).
  final String? semanticLabel;

  /// `padding:12px`.
  static const double padding = DabblerSpacing.space4;

  /// `gap:12px`.
  static const double gap = DabblerSpacing.space4;

  /// The leading column: `width:40px`.
  static const double leadingWidth = 40;

  /// The content column's `gap:4px`.
  static const double rowGap = 4;

  /// The `margin-top:5px` above the actions, pending, result and menu.
  static const double blockTop = 5;

  /// The unread dot: `8px`, `margin-top:6px`.
  static const double dot = 8;
  static const double dotTop = 6;

  /// The ⋯ button: `24 x 20`, the glyph 16, `margin-right:-4px`.
  static const Size menuButton = Size(24, 20);
  static const double menuGlyph = 16;
  static const double menuButtonOutset = 4;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final List<Widget> blocks = <Widget>[
      _head(context, colors),
      if (urgent != null) _Urgent(urgent!),
      if (sub != null && sub!.isNotEmpty)
        Text(
          DabblerType.toWesternDigits(sub!),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _s(
            context,
            DabblerType.smallTight,
            colors.textPrimary,
          ).copyWith(fontWeight: DabblerType.medium),
        ),
      if (excerpt != null) _Excerpt(excerpt!),
      if (change != null) _Change(change!),
      if (meta.isNotEmpty) _Meta(meta),
      if (people != null) _People(people!),
      if (actions.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: blockTop),
          child: Wrap(
            spacing: DabblerSpacing.space2,
            runSpacing: DabblerSpacing.space2,
            children: <Widget>[for (final a in actions) _Pill(a)],
          ),
        ),
      if (pending != null)
        Padding(
          padding: const EdgeInsets.only(top: blockTop),
          child: _Pending(pending!),
        ),
      if (result != null)
        Padding(
          padding: const EdgeInsets.only(top: blockTop),
          child: _Result(result!),
        ),
      if (menu != null)
        Padding(
          padding: const EdgeInsets.only(top: blockTop),
          child: _Menu(menu!),
        ),
    ];
    final Widget openable = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpen,
      child: SizedBox(
        width: leadingWidth,
        child: Center(child: leading),
      ),
    );
    return Semantics(
      container: true,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: unread ? colors.surfaceCard : null,
          borderRadius: DabblerRadius.lgAll,
          border: Border.all(
            color: unread ? colors.borderDefault : colors.bgTertiary,
            width: DabblerSizing.borderDefault,
          ),
        ),
        child: Padding(
          // CSS border-box: the 1px border sits outside the 12 padding.
          padding: const EdgeInsets.all(padding + DabblerSizing.borderDefault),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              openable,
              const SizedBox(width: gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (int i = 0; i < blocks.length; i++) ...<Widget>[
                      if (i > 0) const SizedBox(height: rowGap),
                      blocks[i],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _head(BuildContext context, DabblerColors colors) {
    final TextStyle base = _s(
      context,
      DabblerType.smallTight,
      colors.textSecondary,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onOpen,
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: actor,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: unread
                          ? DabblerType.bold
                          : DabblerType.semibold,
                    ),
                  ),
                  if (verb.isNotEmpty) TextSpan(text: ' $verb'),
                ],
              ),
              style: base,
            ),
          ),
        ),
        if (time != null) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space2),
          // 11px on the 19px line: the caption's 13 line sits 3 lower.
          Padding(
            padding: const EdgeInsets.only(top: DabblerSpacing.space1),
            child: Text(
              DabblerType.toWesternDigits(time!),
              maxLines: 1,
              softWrap: false,
              style: _s(context, DabblerType.caption2, colors.textTertiary),
            ),
          ),
        ],
        if (unread) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space2),
          Padding(
            padding: const EdgeInsets.only(top: dotTop),
            child: DecoratedBox(
              key: const ValueKey<String>('notif-card-unread'),
              decoration: BoxDecoration(
                color: colors.brandPrimary,
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(dimension: dot),
            ),
          ),
        ],
        if (onMenu != null) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space2),
          Transform.translate(
            offset: Offset(
              Directionality.of(context) == TextDirection.rtl
                  ? -menuButtonOutset
                  : menuButtonOutset,
              0,
            ),
            child: DabblerFeedTappable(
              onTap: onMenu,
              semanticLabel: menuLabel,
              excludeChildSemantics: true,
              borderRadius: DabblerRadius.smAll,
              child: SizedBox(
                key: const ValueKey<String>('notif-card-menu'),
                width: menuButton.width,
                height: menuButton.height,
                child: Center(
                  child: DabblerIcon(
                    'more',
                    size: menuGlyph,
                    color: colors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// `padding:2px 8px 2px 6px`, `gap:5px`, the warning surface and strong ink,
/// 11/15 600, `warning-2` 12 bold.
class _Urgent extends StatelessWidget {
  const _Urgent(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return DecoratedBox(
      key: const ValueKey<String>('notif-card-urgent'),
      decoration: BoxDecoration(
        color: colors.warning.surface,
        borderRadius: DabblerRadius.pillAll,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(6, 2, 8, 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DabblerIcon(
              'warning-2',
              size: DabblerSpacing.space4,
              weight: DabblerIconWeight.bold,
              color: colors.warning.strong,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                style: _s(context, DabblerType.tag, colors.warning.strong),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Excerpt extends StatelessWidget {
  const _Excerpt(this.e);

  final DabblerNotificationExcerpt e;

  /// The thumbnail: `42px`.
  static const double thumb = 42;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final String? url = e.thumbnailUrl;
    return DecoratedBox(
      key: const ValueKey<String>('notif-card-excerpt'),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: DabblerRadius.mdAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DabblerSpacing.space3,
          vertical: 8,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    e.label,
                    style: _s(context, DabblerType.tag, colors.textTertiary),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    DabblerType.toWesternDigits(e.text),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _s(
                      context,
                      DabblerType.footnote,
                      colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (url != null && url.trim().isNotEmpty) ...<Widget>[
              const SizedBox(width: DabblerSpacing.space3),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: DabblerRadius.smAll,
                  border: Border.all(
                    color: colors.borderDefault,
                    width: DabblerSizing.borderDefault,
                  ),
                ),
                child: SizedBox.square(
                  key: const ValueKey<String>('notif-card-thumb'),
                  dimension: thumb,
                  child: DabblerImage(url: url, radius: DabblerRadius.smAll),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Change extends StatelessWidget {
  const _Change(this.c);

  final DabblerNotificationChange c;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextStyle muted = _s(
      context,
      DabblerType.footnote,
      colors.textTertiary,
    );
    return Wrap(
      key: const ValueKey<String>('notif-card-change'),
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(c.label, style: muted),
        Text(
          DabblerType.toWesternDigits(c.from),
          style: muted.copyWith(decoration: TextDecoration.lineThrough),
        ),
        DabblerIcon(
          'arrow-right',
          size: 13,
          color: colors.textSecondary,
          mirrorInRtl: true,
        ),
        Text(
          DabblerType.toWesternDigits(c.to),
          style: _s(
            context,
            DabblerType.footnote,
            colors.textPrimary,
          ).copyWith(fontWeight: DabblerType.semibold),
        ),
      ],
    );
  }
}

/// `gap:2px 10px`; each `gap:4px`, a 13 glyph, 12/17 `--muted`.
class _Meta extends StatelessWidget {
  const _Meta(this.items);

  final List<DabblerNotificationMeta> items;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final DabblerNotificationMeta m in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DabblerIcon(m.icon, size: 13, color: colors.textTertiary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  DabblerType.toWesternDigits(m.text),
                  style: _s(
                    context,
                    DabblerType.captionNotif,
                    colors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _People extends StatelessWidget {
  const _People(this.p);

  final DabblerNotificationPeople p;

  /// The 36 avatar at `scale(0.72)`: 26.
  static const double scale = 0.72;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final double d = DabblerAvatarSize.sm.diameter * scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: p.onToggle,
          child: Text(
            DabblerType.toWesternDigits(p.toggleLabel),
            key: const ValueKey<String>('notif-card-people-toggle'),
            style: _s(
              context,
              DabblerType.captionNotif,
              colors.brandPrimary,
            ).copyWith(fontWeight: DabblerType.semibold),
          ),
        ),
        if (p.open) ...<Widget>[
          const SizedBox(height: DabblerSpacing.space2),
          DecoratedBox(
            key: const ValueKey<String>('notif-card-people'),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colors.bgTertiary,
                  width: DabblerSizing.borderDefault,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: DabblerSpacing.space2),
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < p.people.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(height: DabblerSpacing.space2),
                    Row(
                      children: <Widget>[
                        SizedBox.square(
                          dimension: d,
                          child: FittedBox(
                            child: DabblerAvatar(
                              seed: p.people[i].name,
                              imageUrl: p.people[i].imageUrl,
                              size: DabblerAvatarSize.sm,
                            ),
                          ),
                        ),
                        const SizedBox(width: DabblerSpacing.space3),
                        Expanded(
                          child: Text(
                            p.people[i].name,
                            style: _s(
                              context,
                              DabblerType.footnote,
                              colors.textPrimary,
                            ),
                          ),
                        ),
                        if (p.people[i].time != null)
                          Text(
                            DabblerType.toWesternDigits(p.people[i].time!),
                            style: _s(
                              context,
                              DabblerType.tag,
                              colors.textTertiary,
                            ).copyWith(fontWeight: DabblerType.regular),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.a);

  final DabblerNotificationCardAction a;

  /// `min-height:34px`.
  static const double minHeight = 34;

  /// `padding:0 15px`.
  static const double paddingInline = DabblerSpacing.space5;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return DabblerFeedTappable(
      onTap: a.onPressed,
      semanticLabel: a.label,
      excludeChildSemantics: true,
      borderRadius: DabblerRadius.pillAll,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: a.primary ? colors.brandPrimary : colors.surfaceCard,
          borderRadius: DabblerRadius.pillAll,
          border: Border.all(
            color: a.primary ? colors.brandPrimary : colors.borderDefault,
            width: DabblerSizing.borderDefault,
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: minHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: paddingInline),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                a.label,
                maxLines: 1,
                style: _s(
                  context,
                  DabblerType.footnote,
                  a.primary ? colors.onBrand : colors.textPrimary,
                ).copyWith(fontWeight: DabblerType.semibold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `gap:8px`, the 14 spinner, 12/17 `--muted`.
class _Pending extends StatelessWidget {
  const _Pending(this.text);

  final String text;

  /// `size="14"`.
  static const double spinner = 14;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Row(
      key: const ValueKey<String>('notif-card-pending'),
      children: <Widget>[
        // The 14 spinner: the package's 18 ring scaled to the design's size.
        const SizedBox.square(
          dimension: spinner,
          child: FittedBox(child: DabblerSpinner(size: DabblerSpinnerSize.sm)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: _s(context, DabblerType.captionNotif, colors.textTertiary),
          ),
        ),
      ],
    );
  }
}

class _Result extends StatelessWidget {
  const _Result(this.r);

  final DabblerNotificationResult r;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final DabblerToneColor t = r.tone.of(colors);
    final TextStyle text = _s(
      context,
      DabblerType.captionNotif,
      t.ink,
    ).copyWith(fontWeight: DabblerType.semibold);
    return DecoratedBox(
      key: const ValueKey<String>('notif-card-result'),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: DabblerRadius.mdAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: <Widget>[
            DabblerIcon(
              r.icon,
              size: 15,
              weight: DabblerIconWeight.bold,
              color: t.ink,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(DabblerType.toWesternDigits(r.text), style: text),
            ),
            if (r.linkLabel != null) ...<Widget>[
              const SizedBox(width: 7),
              DabblerFeedTappable(
                onTap: r.onLink,
                semanticLabel: r.linkLabel,
                excludeChildSemantics: true,
                child: Text(
                  r.linkLabel!,
                  key: const ValueKey<String>('notif-card-result-link'),
                  style: text.copyWith(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu(this.items);

  final List<DabblerNotificationMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return ClipRRect(
      borderRadius: DabblerRadius.mdAll,
      child: DecoratedBox(
        key: const ValueKey<String>('notif-card-menu-list'),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: DabblerRadius.mdAll,
          border: Border.all(
            color: colors.borderDefault,
            width: DabblerSizing.borderDefault,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (int i = 0; i < items.length; i++)
              DabblerFeedTappable(
                onTap: items[i].onPressed,
                semanticLabel: items[i].label,
                excludeChildSemantics: true,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: i == items.length - 1
                        ? null
                        : Border(
                            bottom: BorderSide(
                              color: colors.bgTertiary,
                              width: DabblerSizing.borderDefault,
                            ),
                          ),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 40),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DabblerSpacing.space4,
                      ),
                      child: Row(
                        children: <Widget>[
                          DabblerIcon(
                            items[i].icon,
                            size: 15,
                            color: colors.textPrimary,
                          ),
                          const SizedBox(width: DabblerSpacing.space3),
                          Expanded(
                            child: Text(
                              items[i].label,
                              style: _s(
                                context,
                                DabblerType.footnote,
                                colors.textPrimary,
                              ),
                            ),
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
    );
  }
}
