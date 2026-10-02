import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../controls/chip.dart';
import '../feedback/banner.dart';
import '../foundations/icon.dart';
import '../foundations/sport_icon.dart';
import '../foundations/sports.dart';
import '../surfaces/avatar.dart';
import '../surfaces/badge.dart';
import '../surfaces/icon_tile.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_palette.dart';
import '../tokens/dabbler_type.dart';
import 'messaging_foundations.dart';

TextStyle _t(BuildContext c, DabblerTypeStyle s) =>
    s.resolveForDirection(Directionality.of(c));

/// The variants of a [DabblerMessageReplyReference].
enum DabblerReplyVariant {
  /// Inside an incoming bubble — a brand rule, muted body.
  message,

  /// Inside an outgoing bubble — an on-brand rule and body.
  onBrand,

  /// Above the composer — on a sunken fill with a cancel button.
  composer,
}

/// MessageReplyReference — the quoted message.
///
/// `MessageReplyReference.jsx`: a 2px inline-start rule (brand, or on-brand in
/// an outgoing bubble), the sender in `caption-2` at weight 700 in the rule
/// colour, and the quoted text (or an attachment label with a gallery glyph) in
/// `caption-1`, clamped to two lines. The `composer` variant sits on the sunken
/// fill with a 45px cancel button.
class DabblerMessageReplyReference extends StatelessWidget {
  /// A reply reference.
  const DabblerMessageReplyReference({
    super.key,
    required this.sender,
    this.content,
    this.attachmentLabel,
    this.variant = DabblerReplyVariant.message,
    this.onCancel,
    this.cancelLabel = 'Cancel reply',
  });

  /// Who wrote the quoted message.
  final String sender;

  /// The quoted text.
  final String? content;

  /// Set instead of [content] when the quoted message was an attachment.
  final String? attachmentLabel;

  /// Where it is drawn.
  final DabblerReplyVariant variant;

  /// Shows the cancel button when set (composer).
  final VoidCallback? onCancel;

  /// The cancel button's accessible name.
  final String cancelLabel;

  /// The rule width — `2px`.
  static const double ruleWidth = 2;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool onBrand = variant == DabblerReplyVariant.onBrand;
    final bool composer = variant == DabblerReplyVariant.composer;
    final Color rule = onBrand ? colors.onBrand : colors.brandPrimary;
    final Color body = onBrand ? colors.onBrand : colors.textSecondary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: composer ? colors.surfaceSunken : null,
        borderRadius: composer ? DabblerRadius.mdAll : null,
        border: BorderDirectional(
          start: BorderSide(color: rule, width: ruleWidth),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: DabblerSpacing.space3,
          end: composer ? DabblerSpacing.space3 : 0,
          top: DabblerSpacing.space1,
          bottom: DabblerSpacing.space1,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    sender,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(context, DabblerType.caption2)
                        .copyWith(fontWeight: FontWeight.w700, color: rule),
                  ),
                  if (attachmentLabel != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        DabblerIcon('gallery', size: 13, color: body),
                        const SizedBox(width: DabblerSpacing.space1),
                        Flexible(
                          child: Text(
                            attachmentLabel!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _t(context, DabblerType.caption1)
                                .copyWith(color: body),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      content ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(context, DabblerType.caption1)
                          .copyWith(color: body),
                    ),
                ],
              ),
            ),
            if (onCancel != null)
              DabblerMessagingTap(
                onTap: onCancel,
                label: cancelLabel,
                ringRadius: DabblerRadius.pillAll,
                child: SizedBox(
                  width: DabblerSizing.touchTargetMin,
                  height: DabblerSizing.touchTargetMin,
                  child: Center(
                    child: DabblerIcon(
                      'close-circle',
                      size: DabblerSizing.iconSm,
                      color: colors.textSecondary,
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

/// One reaction tally on a message.
@immutable
class DabblerMessageReaction {
  /// A tally.
  const DabblerMessageReaction({
    required this.key,
    required this.count,
    this.mine = false,
  });

  /// A [DabblerReactions] key.
  final String key;

  /// How many people reacted.
  final int count;

  /// Whether the viewer reacted.
  final bool mine;
}

/// ReactionGroup — the reaction tallies under a message.
///
/// `ReactionGroup.jsx`: 24px pills (13px glyph + `caption-2` count at weight
/// 700) inside 45px buttons so the touch target clears the floor without the
/// pill growing; `mine` pills are brand-tinted with a brand outline and a bold
/// glyph; an optional add button.
class DabblerReactionGroup extends StatelessWidget {
  /// A reaction row.
  const DabblerReactionGroup({
    super.key,
    this.reactions = const <DabblerMessageReaction>[],
    this.onToggle,
    this.onAdd,
    this.addLabel = 'Add reaction',
  });

  /// The tallies.
  final List<DabblerMessageReaction> reactions;

  /// Called with the reaction key when a pill is pressed.
  final ValueChanged<String>? onToggle;

  /// Shows the add button when set.
  final VoidCallback? onAdd;

  /// The add button's accessible name.
  final String addLabel;

  /// The pill height — `var(--icon-md)`.
  static const double pillHeight = DabblerSizing.iconMd;

  /// The glyph size — `size={13}`.
  static const double glyphSize = 13;

  /// The `mine` fill — brand at 12% over the card.
  static const double mineAlpha = 0.12;

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty && onAdd == null) return const SizedBox.shrink();
    final DabblerColors colors = DabblerColors.of(context);
    Widget target(Widget pill, {required VoidCallback? tap, String? label, bool? pressed}) =>
        DabblerMessagingTap(
          onTap: tap,
          label: label,
          selected: pressed,
          ringRadius: DabblerRadius.pillAll,
          scale: false,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: DabblerSizing.touchTargetMin,
              minHeight: DabblerSizing.touchTargetMin,
            ),
            child: Center(child: pill),
          ),
        );

    return Wrap(
      spacing: DabblerSpacing.space1,
      children: <Widget>[
        for (final DabblerMessageReaction r in reactions)
          target(
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: DabblerRadius.pillAll,
                color: r.mine
                    ? Color.alphaBlend(
                        colors.brandPrimary.withValues(alpha: mineAlpha),
                        colors.surfaceCard,
                      )
                    : colors.surfaceCard,
                border: Border.all(
                  color: r.mine ? colors.brandPrimary : colors.borderDefault,
                  width: DabblerSizing.borderDefault,
                ),
              ),
              child: SizedBox(
                height: pillHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DabblerSpacing.space2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DabblerIcon(
                        DabblerReactions.byKey(r.key).icon,
                        weight: r.mine
                            ? DabblerIconWeight.bold
                            : DabblerIconWeight.linear,
                        size: glyphSize,
                        color: r.mine ? colors.brandPrimary : DabblerPalette.inkSoft,
                      ),
                      const SizedBox(width: DabblerSpacing.space1),
                      Text(
                        '${r.count}',
                        style: _t(context, DabblerType.caption2).copyWith(
                          fontWeight: FontWeight.w700,
                          color:
                              r.mine ? colors.brandPrimary : DabblerPalette.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            tap: onToggle == null ? null : () => onToggle!(r.key),
            label: '${DabblerReactions.byKey(r.key).label} · ${r.count}',
            pressed: r.mine,
          ),
        if (onAdd != null)
          target(
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceCard,
                border: Border.all(
                  color: colors.borderDefault,
                  width: DabblerSizing.borderDefault,
                ),
              ),
              child: SizedBox(
                width: pillHeight,
                height: pillHeight,
                child: Center(
                  child: DabblerIcon(
                    'emoji-happy',
                    size: glyphSize,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ),
            tap: onAdd,
            label: addLabel,
          ),
      ],
    );
  }
}

/// ReactionPicker — the six reactions in one pill, to choose from.
///
/// `ReactionPicker.jsx`: a card pill with a hairline, 6px padding, six 45px
/// round buttons with a 19px glyph; an active reaction fills with the brand
/// colour and a bold on-brand glyph.
class DabblerReactionPicker extends StatelessWidget {
  /// A picker.
  const DabblerReactionPicker({
    super.key,
    this.onPick,
    this.active = const <String>[],
    this.groupLabel = 'React',
  });

  /// Called with the chosen reaction key.
  final ValueChanged<String>? onPick;

  /// The keys already chosen.
  final List<String> active;

  /// The group's accessible name.
  final String groupLabel;

  /// The glyph size — `size={19}`.
  static const double glyphSize = 19;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Semantics(
      container: true,
      label: groupLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: DabblerRadius.pillAll,
          border: Border.all(
            color: colors.borderDefault,
            width: DabblerSizing.borderDefault,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DabblerSpacing.space2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final DabblerReactionDef r in DabblerReactions.all) ...<Widget>[
                if (r != DabblerReactions.all.first)
                  const SizedBox(width: DabblerSpacing.space1),
                Builder(
                  builder: (BuildContext context) {
                    final bool on = active.contains(r.key);
                    return DabblerMessagingTap(
                      onTap: onPick == null ? null : () => onPick!(r.key),
                      label: r.label,
                      selected: on,
                      ringRadius: DabblerRadius.pillAll,
                      child: Container(
                        width: DabblerSizing.touchTargetMin,
                        height: DabblerSizing.touchTargetMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: on ? colors.brandPrimary : const Color.fromARGB(0, 0, 0, 0),
                        ),
                        child: DabblerIcon(
                          r.icon,
                          weight: on
                              ? DabblerIconWeight.bold
                              : DabblerIconWeight.linear,
                          size: glyphSize,
                          color: on ? colors.onBrand : DabblerPalette.inkSoft,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

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
/// `SharedObjectCard.jsx` (design system 1.2.0): a pastel ground per kind from
/// the decorative tile tokens (game and venue `info`, player `accent`), a
/// hairline, the large radius and 12 padding. A game shows a 36px sport tile,
/// the title, a status badge, meta lines and an optional primary call to
/// action; a player an avatar, name and subtitle with chips; a venue a 120px
/// photo slot above its text. The photo is an injected widget.
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

  /// The sport of a game.
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

  /// The call-to-action label.
  final String? cta;

  /// Called by the call to action.
  final VoidCallback? onPress;

  /// A footnote under a game's meta.
  final String? footnote;

  /// The photo height — `height: 120`.
  static const double photoHeight = 120;

  /// The surface of [kind] — `PASTEL`.
  static Color surfaceFor(DabblerColors colors, DabblerSharedKind kind) =>
      switch (kind) {
        DabblerSharedKind.player => DabblerColors.tileAccent.surface,
        _ => DabblerColors.tileInfo.surface,
      };

  /// The chip fill of [kind] — `PASTEL`.
  static Color chipFor(DabblerColors colors, DabblerSharedKind kind) =>
      switch (kind) {
        DabblerSharedKind.game => DabblerColors.tileAccent.surface,
        DabblerSharedKind.player => DabblerColors.tileInfo.surface,
        DabblerSharedKind.venue => colors.surfaceCard,
      };

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Widget metaLines = meta.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < meta.length; i++)
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : DabblerSpacing.space2),
                  child: Row(
                    children: <Widget>[
                      DabblerIcon(
                        meta[i].icon,
                        weight: DabblerIconWeight.bold,
                        size: 14,
                        color: colors.brandPrimary,
                      ),
                      const SizedBox(width: DabblerSpacing.space2),
                      Expanded(
                        child: Text(
                          meta[i].text,
                          style: _t(context, DabblerType.footnote)
                              .copyWith(color: DabblerPalette.inkSoft),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
    final Widget action = cta == null
        ? const SizedBox.shrink()
        : DabblerButton(
            label: cta!,
            size: DabblerButtonSize.small,
            fullWidth: true,
            onPressed: onPress,
          );
    final Widget chipRow = chips.isEmpty
        ? const SizedBox.shrink()
        : Wrap(
            spacing: DabblerSpacing.space2,
            runSpacing: DabblerSpacing.space2,
            children: <Widget>[
              for (final String c in chips)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: chipFor(colors, kind),
                    borderRadius: DabblerRadius.pillAll,
                  ),
                  child: DabblerChip(label: c),
                ),
            ],
          );
    Widget gap(Widget w, bool show) => show
        ? Padding(
            padding: const EdgeInsets.only(top: DabblerSpacing.space3),
            child: w,
          )
        : const SizedBox.shrink();

    final Widget titles = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _t(context, DabblerType.subheadline)
              .copyWith(fontWeight: FontWeight.w700, color: colors.textPrimary),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: _t(context, DabblerType.caption1)
                .copyWith(color: colors.textSecondary),
          ),
      ],
    );

    final Widget inner = switch (kind) {
      DabblerSharedKind.player => Padding(
          padding: const EdgeInsets.all(DabblerSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  DabblerAvatar(seed: seed ?? title, size: DabblerAvatarSize.md),
                  const SizedBox(width: DabblerSpacing.space4),
                  Expanded(child: titles),
                ],
              ),
              gap(chipRow, chips.isNotEmpty),
              gap(metaLines, meta.isNotEmpty),
              gap(action, cta != null),
            ],
          ),
        ),
      DabblerSharedKind.venue => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: photoHeight, child: photo ?? const SizedBox.shrink()),
            Padding(
              padding: const EdgeInsets.all(DabblerSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  titles,
                  gap(chipRow, chips.isNotEmpty),
                  gap(metaLines, meta.isNotEmpty),
                  gap(action, cta != null),
                ],
              ),
            ),
          ],
        ),
      DabblerSharedKind.game => Padding(
          padding: const EdgeInsets.all(DabblerSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  DabblerIconTile(
                    DabblerSportIcon(
                      sport ?? DabblerSport.football,
                      weight: DabblerIconWeight.bold,
                      size: 20,
                      color: colors.brandPrimary,
                    ),
                    size: 36,
                  ),
                  const SizedBox(width: DabblerSpacing.space3),
                  Expanded(child: titles),
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
              gap(metaLines, meta.isNotEmpty),
              gap(
                Text(
                  footnote ?? '',
                  style: _t(context, DabblerType.caption1)
                      .copyWith(color: colors.textSecondary),
                ),
                footnote != null,
              ),
              gap(action, cta != null),
            ],
          ),
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceFor(colors, kind),
        borderRadius: DabblerRadius.lgAll,
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: ClipRRect(borderRadius: DabblerRadius.lgAll, child: inner),
    );
  }
}

/// The tone of a [DabblerConversationNotice] — `critical` is an alias of `error`.
enum DabblerNoticeTone {
  /// Info.
  info,

  /// Success.
  success,

  /// Warning.
  warning,

  /// Error.
  error,

  /// Alias of [error].
  critical,
}

/// ConversationNotice — an important update inside a thread, a `Banner`.
///
/// `ConversationNotice.jsx`: composes the banner (`critical` maps to `error`)
/// with an optional centred caption timestamp beneath.
class DabblerConversationNotice extends StatelessWidget {
  /// A notice.
  const DabblerConversationNotice({
    super.key,
    this.tone = DabblerNoticeTone.info,
    this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.timestamp,
  });

  /// The tone.
  final DabblerNoticeTone tone;

  /// The headline.
  final String? title;

  /// The body.
  final String? description;

  /// The action button label.
  final String? actionLabel;

  /// Called by the action.
  final VoidCallback? onAction;

  /// Shows the dismiss button when set.
  final VoidCallback? onDismiss;

  /// A caption under the banner.
  final String? timestamp;

  /// The banner tone for [tone].
  static DabblerBannerTone bannerToneFor(DabblerNoticeTone tone) =>
      switch (tone) {
        DabblerNoticeTone.info => DabblerBannerTone.info,
        DabblerNoticeTone.success => DabblerBannerTone.success,
        DabblerNoticeTone.warning => DabblerBannerTone.warning,
        DabblerNoticeTone.error ||
        DabblerNoticeTone.critical =>
          DabblerBannerTone.error,
      };

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DabblerSpacing.space2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DabblerBanner(
            tone: bannerToneFor(tone),
            title: title,
            message: description,
            action: actionLabel == null
                ? null
                : DabblerBannerAction(label: actionLabel!, onPressed: onAction),
            onDismiss: onDismiss,
          ),
          if (timestamp != null) ...<Widget>[
            const SizedBox(height: DabblerMessagingSpacing.metaGap),
            Text(
              timestamp!,
              style: _t(context, DabblerType.caption1)
                  .copyWith(color: colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
