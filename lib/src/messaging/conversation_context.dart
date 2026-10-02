/// ConversationContext — the compact, state-aware activity header pinned above
/// a game conversation.
library;

import 'package:flutter/material.dart';

import '../controls/button.dart';
import '../foundations/icon.dart';
import '../foundations/sport_icon.dart';
import '../foundations/sports.dart';
import '../interaction/focus_ring.dart';
import '../layout/divider.dart';
import '../surfaces/avatar.dart';
import '../surfaces/badge.dart';
import '../surfaces/icon_tile.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';
import 'messaging_foundations.dart';

TextStyle _t(BuildContext c, DabblerTypeStyle s) =>
    s.resolveForDirection(Directionality.of(c));

/// One action button in an expanded [DabblerConversationContext] — an entry
/// of the source's `actions` array (`{label, onPress, tone?, icon?}`).
@immutable
class DabblerConversationContextAction {
  /// Creates an action.
  const DabblerConversationContextAction({
    required this.label,
    this.onPress,
    this.tone,
    this.icon,
  });

  /// The button label.
  final String label;

  /// Called on press.
  final VoidCallback? onPress;

  /// Overrides the default tone (first primary, the rest outlined).
  final DabblerButtonTone? tone;

  /// Optional Iconsax glyph name, drawn bold at 16px in the source.
  final String? icon;
}

/// ConversationContext — the activity header pinned above a game conversation.
///
/// Transcribed from the live Claude Design project
/// 4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System), files
/// `components/messaging/ConversationContext.jsx` and
/// `ConversationContext.prompt.md` (status map `GAME_STATUS` in
/// `components/messaging/messaging.jsx`), read via DesignSync get_file on
/// 2026-10-02 and transcribed to a local mirror by the coordinator.
///
/// | Source | Dart |
/// |---|---|
/// | shell `--surface-card`, 1px `--outline-card`, `--radius-lg`, width 100% | `colors.surfaceCard`, `colors.borderDefault`, [DabblerRadius.lgAll], fills its width |
/// | header `<button aria-expanded>`, padding `--space-4`, gap `--space-3`, min-height `--touch-target-min` | [Semantics] `button` + `expanded`, 12 padding, 9 gap, 45 min height |
/// | `IconTile size=36`, `SportIcon bold 20` | [DabblerIconTile] 36, [DabblerSportIcon] bold 20 |
/// | tile `color`: cancelled `--color-status-error`, completed `--muted` | `colors.status(error).base`, `colors.textSecondary` (D-003(a)) |
/// | title `t-footnote` 700 `--ink`, ellipsis, line-through when cancelled | [DabblerType.footnote] w700 `textPrimary`, one line |
/// | `{when} · {venue}` `t-caption-1` `--muted` | [DabblerType.caption1] `textSecondary` |
/// | `Badge status={GAME_STATUS[status].status}` | [DabblerBadge] with [DabblerActivityStatus.tone] or the neutral status |
/// | chevron `arrow-circle-down` 18 `--muted`, rotate 180deg, `--motion-base --ease-out` | [DabblerIcon] 18, [AnimatedRotation] 0.5 turns, [DabblerMotion.base]/[DabblerMotion.easeOut]; zero duration under [DabblerMotion.reduceMotion] |
/// | body gap `--space-4`, `paddingInline`/`paddingBlockEnd` `--space-4` | 12 gaps, `EdgeInsetsDirectional.fromSTEB(12, 0, 12, 12)` |
/// | map row: sunken, 1px `--faint`, `--radius-md`, padding 12/9, location bold 24 brand | `surfaceSunken`, `bgTertiary`, [DabblerRadius.mdAll] |
/// | `Button tone=outlined size=small` map action | [DabblerButton] outlined small; `onMapAction` added (the source wires no handler) |
/// | participants: `AvatarGroup`, footnote 600 + caption-1 spots | [DabblerAvatarGroup] |
/// | organizer: crown bold 14 brand, gap `--space-2`, label `--muted` + name 600 `--ink-soft` | gap 6; name in `textSecondary` w600 (light `textSecondary` is `--ink-soft`) |
/// | actions: wrap, gap `--space-2`, small, first primary else outlined, icon bold 16 | [Wrap] spacing 6 |
///
/// Every inset is directional, so the layout mirrors under RTL; Arabic type
/// resolves through [DabblerTypeStyle.resolveForDirection] (Latin − 0.9px).
class DabblerConversationContext extends StatelessWidget {
  /// Creates the header.
  const DabblerConversationContext({
    super.key,
    this.sport = DabblerSport.football,
    required this.title,
    required this.when,
    required this.venue,
    this.status = DabblerActivityStatus.open,
    this.statusLabel,
    this.participants,
    this.spots,
    this.organizer,
    this.organizerLabel,
    this.people = const <String>[],
    this.overflow = 0,
    this.collapsed = true,
    this.onToggle,
    this.actions = const <DabblerConversationContextAction>[],
    this.mapLabel,
    this.mapActionLabel,
    this.onMapAction,
  });

  /// The sport glyph in the tile.
  final DabblerSport sport;

  /// The activity title.
  final String title;

  /// When it happens (caption, before the dot).
  final String when;

  /// Where it happens (caption, after the dot; also the map row title).
  final String venue;

  /// Activity status — badge tone, tile colour, title strike.
  final DabblerActivityStatus status;

  /// Overrides the status badge label.
  final String? statusLabel;

  /// Participants line; null hides the participants row.
  final String? participants;

  /// Spots caption under [participants].
  final String? spots;

  /// Organizer name; null hides the organizer row.
  final String? organizer;

  /// Text before [organizer] (e.g. "Organised by").
  final String? organizerLabel;

  /// Avatar seeds for the participants row.
  final List<String> people;

  /// `+N` chip count.
  final int overflow;

  /// Whether only the header shows. Controlled.
  final bool collapsed;

  /// Called when the header is activated.
  final VoidCallback? onToggle;

  /// Expanded action buttons.
  final List<DabblerConversationContextAction> actions;

  /// Map row caption; null hides the map row.
  final String? mapLabel;

  /// Map row button label; null hides the button.
  final String? mapActionLabel;

  /// Map row button handler (not in the source).
  final VoidCallback? onMapAction;

  /// The badge label actually shown.
  String get resolvedStatusLabel => statusLabel ?? status.label;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
        borderRadius: DabblerRadius.lgAll,
      ),
      // `box-sizing: border-box`: content sits inside the 1px border.
      child: Padding(
        padding: const EdgeInsets.all(DabblerSizing.borderDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Header(owner: this),
            if (!collapsed) _body(context, colors),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, DabblerColors colors) {
    const SizedBox gap = SizedBox(height: DabblerSpacing.space4);
    final List<Widget> rows = <Widget>[const DabblerDivider()];
    void add(Widget w) => rows
      ..add(gap)
      ..add(w);

    if (mapLabel != null) {
      add(
        Container(
          key: const ValueKey<String>('conversation-context-map'),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: DabblerSpacing.space4,
            vertical: DabblerSpacing.space3,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceSunken,
            border: Border.all(
              color: colors.bgTertiary,
              width: DabblerSizing.borderDefault,
            ),
            borderRadius: DabblerRadius.mdAll,
          ),
          child: Row(
            children: <Widget>[
              DabblerIcon(
                'location',
                weight: DabblerIconWeight.bold,
                size: DabblerSizing.iconMd,
                color: colors.brandPrimary,
              ),
              const SizedBox(width: DabblerSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      venue,
                      style: _t(context, DabblerType.footnote).copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      mapLabel!,
                      style: _t(
                        context,
                        DabblerType.caption1,
                      ).copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (mapActionLabel != null) ...<Widget>[
                const SizedBox(width: DabblerSpacing.space3),
                DabblerButton(
                  label: mapActionLabel,
                  tone: DabblerButtonTone.outlined,
                  size: DabblerButtonSize.small,
                  onPressed: onMapAction,
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (participants != null) {
      add(
        Row(
          key: const ValueKey<String>('conversation-context-participants'),
          children: <Widget>[
            DabblerAvatarGroup(people: people, overflow: overflow),
            const SizedBox(width: DabblerSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    participants!,
                    style: _t(context, DabblerType.footnote).copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (spots != null)
                    Text(
                      spots!,
                      style: _t(
                        context,
                        DabblerType.caption1,
                      ).copyWith(color: colors.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (organizer != null) {
      final TextStyle cap = _t(
        context,
        DabblerType.caption1,
      ).copyWith(color: colors.textSecondary);
      add(
        Row(
          key: const ValueKey<String>('conversation-context-organizer'),
          children: <Widget>[
            DabblerIcon(
              'crown',
              weight: DabblerIconWeight.bold,
              size: 14,
              color: colors.brandPrimary,
            ),
            const SizedBox(width: DabblerSpacing.space2),
            Flexible(
              child: Text.rich(
                TextSpan(
                  style: cap,
                  children: <InlineSpan>[
                    if (organizerLabel != null)
                      TextSpan(text: '$organizerLabel '),
                    TextSpan(
                      text: organizer,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (actions.isNotEmpty) {
      add(
        Wrap(
          key: const ValueKey<String>('conversation-context-actions'),
          spacing: DabblerSpacing.space2,
          runSpacing: DabblerSpacing.space2,
          children: <Widget>[
            for (int i = 0; i < actions.length; i++)
              // IntrinsicWidth: DabblerButton's centred surface otherwise
              // fills a Wrap's loose width (the source sizes to content).
              IntrinsicWidth(
                child: DabblerButton(
                  label: actions[i].label,
                  tone:
                      actions[i].tone ??
                      (i == 0
                          ? DabblerButtonTone.primary
                          : DabblerButtonTone.outlined),
                  size: DabblerButtonSize.small,
                  icon: actions[i].icon,
                  onPressed: actions[i].onPress,
                ),
              ),
          ],
        ),
      );
    }

    return Padding(
      key: const ValueKey<String>('conversation-context-body'),
      padding: const EdgeInsetsDirectional.fromSTEB(
        DabblerSpacing.space4,
        0,
        DabblerSpacing.space4,
        DabblerSpacing.space4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: rows,
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({required this.owner});

  final DabblerConversationContext owner;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final DabblerConversationContext o = widget.owner;
    final DabblerColors colors = DabblerColors.of(context);
    final bool cancelled = o.status == DabblerActivityStatus.cancelled;
    final bool done = o.status == DabblerActivityStatus.completed;
    final Color? tint = cancelled
        ? colors.status(DabblerStatusTone.error).base
        : done
        ? colors.textSecondary
        : null;
    final Widget glyph = DabblerSportIcon(
      o.sport,
      weight: DabblerIconWeight.bold,
      size: 20,
      color: tint ?? colors.brandPrimary,
    );
    final Widget tile = tint == null
        ? DabblerIconTile(glyph, size: 36)
        : DabblerIconTile.tinted(glyph, color: tint, size: 36);
    final bool reduce = DabblerMotion.reduceMotion(context);

    final Widget row = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: DabblerSizing.touchTargetMin,
      ),
      child: Padding(
        padding: const EdgeInsets.all(DabblerSpacing.space4),
        child: Row(
          children: <Widget>[
            KeyedSubtree(
              key: const ValueKey<String>('conversation-context-tile'),
              child: tile,
            ),
            const SizedBox(width: DabblerSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    o.title,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: _t(context, DabblerType.footnote).copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      decorationColor: colors.textPrimary,
                      decoration: cancelled
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  Text(
                    '${o.when} · ${o.venue}',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: _t(
                      context,
                      DabblerType.caption1,
                    ).copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DabblerSpacing.space3),
            DabblerBadge(
              label: o.resolvedStatusLabel,
              status: o.status.tone == null
                  ? DabblerBadge.neutralStatusOf(colors)
                  : colors.status(o.status.tone!),
            ),
            const SizedBox(width: DabblerSpacing.space3),
            AnimatedRotation(
              key: const ValueKey<String>('conversation-context-chevron'),
              turns: o.collapsed ? 0 : 0.5,
              duration: reduce ? Duration.zero : DabblerMotion.base,
              curve: DabblerMotion.easeOut,
              child: DabblerIcon(
                'arrow-circle-down',
                size: DabblerSizing.iconSm,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      expanded: !o.collapsed,
      label: '${o.title}, ${o.when} · ${o.venue}, ${o.resolvedStatusLabel}',
      onTap: o.onToggle,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          enabled: o.onToggle != null,
          mouseCursor: o.onToggle != null
              ? SystemMouseCursors.click
              : MouseCursor.defer,
          onShowFocusHighlight: (bool v) => setState(() => _focused = v),
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent _) {
                o.onToggle?.call();
                return null;
              },
            ),
          },
          child: GestureDetector(
            key: const ValueKey<String>('conversation-context-header'),
            behavior: HitTestBehavior.opaque,
            onTap: o.onToggle,
            child: DabblerFocusRing.visible(
              visible: _focused,
              borderRadius: DabblerRadius.lgAll,
              child: row,
            ),
          ),
        ),
      ),
    );
  }
}
