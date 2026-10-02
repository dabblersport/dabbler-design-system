import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/sports.dart';
import '../interaction/focus_ring.dart';
import '../surfaces/badge.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';
import 'messaging_atoms.dart';
import 'messaging_foundations.dart';

/// The contextual status badge on a [DabblerConversationRow]'s third line —
/// the live `state: { status, label, icon }` object.
@immutable
class DabblerConversationState {
  /// A status badge reading [label].
  const DabblerConversationState({required this.label, this.status, this.icon});

  /// The badge text.
  final String label;

  /// The semantic tone; null is the source's `status || 'neutral'`.
  final DabblerStatusTone? status;

  /// An optional kebab-case Iconsax name, drawn bold at 12px.
  final String? icon;
}

/// ConversationRow — one conversation in the inbox: identity, latest
/// activity, timestamp and unread/status, as one navigational row.
///
/// Transcribed from the live Claude Design project
/// 4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System), files
/// `components/messaging/ConversationRow.jsx` and `ConversationRow.prompt.md`,
/// read via DesignSync get_file on 2026-10-02 and transcribed to a local mirror
/// by the coordinator. Player, squad, huddle and game conversations are the
/// same component; [kind] changes only the avatar's kind tile.
///
/// | Source (`ConversationRow.jsx`) | Dart |
/// | --- | --- |
/// | `kind`, `sport`, `seed \|\| title` | [kind], [sport], [seed] (falls back to [title]) |
/// | `title`, `preview`, `sender`, `timestamp` | [title], [preview], [sender], [timestamp] |
/// | `unread`, `unreadMax` (`N+` above it) | [unread], [unreadMax] |
/// | `muted` (volume-slash 14, warning badge) | [muted] |
/// | `online`, `typing`, `typingLabel` | [online], [typing], [typingLabel] |
/// | `state {status,label,icon}`, `kindLabel` | [state], [kindLabel] |
/// | `divider` (1px `--faint` block-end) | [divider], `bgTertiary` |
/// | `onClick` → `role=button`, `tabIndex 0` | [onTap] → button semantics + focus |
/// | `paddingInline/Block space-6/space-4` | 18 / 12, directional |
/// | `minHeight --touch-target-min` | 45 |
/// | pressed `--surface-sunken`, `--motion-fast` | `surfaceSunken`, 80ms ease-out |
/// | title `t-subheadline` 700 unread / 600 | [DabblerType.subheadline] |
/// | timestamp `t-caption-1` 600 brand / 400 `--muted` | caption1, `brandPrimary` / `textSecondary` |
/// | preview `t-footnote`, `dbl-clamp-1` | footnote, one line, ellipsis |
/// | `--muted` and `--ink-soft` preview ink | both `textSecondary` (D-003(a)) |
///
/// Deviations: the preview is a [String] (the source takes a ReactNode); the
/// unread badge keeps [DabblerBadge]'s own 10px inline padding because the
/// Badge port exposes no padding override (the source sets `space-2`, 6px,
/// and `minWidth: 24`; the 24 floor is honoured). Under D-003(a) the read
/// (`--muted`) and unread (`--ink-soft`) preview inks resolve to the same
/// `textSecondary` role.
///
/// RTL: every inset is directional, so the avatar leads and the timestamp
/// trails on either side, and type resolves to the Arabic metrics.
///
/// Accessibility: with [onTap] the row is one button whose label is composed
/// from title, preview (or the typing sentence), timestamp, unread count,
/// state and kind label ([semanticLabel] overrides it). The mute glyph is
/// decoration (`aria-hidden`), so mute must also be carried by copy or the
/// badge tone.
class DabblerConversationRow extends StatefulWidget {
  /// A conversation row.
  const DabblerConversationRow({
    super.key,
    this.kind = DabblerConversationKind.player,
    this.sport,
    this.seed,
    required this.title,
    this.preview,
    this.sender,
    required this.timestamp,
    this.unread = 0,
    this.unreadMax = 99,
    this.muted = false,
    this.online = false,
    this.typing = false,
    this.typingLabel,
    this.state,
    this.kindLabel,
    this.divider = true,
    this.onTap,
    this.semanticLabel,
    this.unreadLabel = 'unread',
  });

  /// What the conversation is.
  final DabblerConversationKind kind;

  /// The sport, for a `game`.
  final DabblerSport? sport;

  /// The avatar seed; falls back to [title].
  final String? seed;

  /// The conversation's name.
  final String title;

  /// The latest message.
  final String? preview;

  /// The prefix for group previews (`Omar: …`).
  final String? sender;

  /// The latest activity's time, already formatted.
  final String timestamp;

  /// Unread messages; a badge shows above zero.
  final int unread;

  /// The count above which the badge reads `N+`.
  final int unreadMax;

  /// Whether notifications are muted.
  final bool muted;

  /// Whether the player is online (player kind only).
  final bool online;

  /// Whether someone is typing; replaces the preview.
  final bool typing;

  /// Overrides the typing sentence.
  final String? typingLabel;

  /// The third-line status badge.
  final DabblerConversationState? state;

  /// The third-line kind label.
  final String? kindLabel;

  /// Whether the hairline divider is drawn.
  final bool divider;

  /// Opens the conversation. Null leaves the row inert, with no button role.
  final VoidCallback? onTap;

  /// Overrides the composed accessible name.
  final String? semanticLabel;

  /// The word after the unread count in the accessible name.
  final String unreadLabel;

  /// Avatar size — `size={48}`.
  static const double avatarSize = 48;

  /// Mute glyph size — `size={14}`.
  static const double muteGlyphSize = 14;

  /// State badge glyph size — `size={12}`.
  static const double stateGlyphSize = 12;

  /// The unread badge's minimum width — `minWidth: 24`.
  static const double unreadMinWidth = 24;

  /// Inline padding — `--space-6`.
  static const double paddingInline = DabblerSpacing.space6;

  /// Block padding — `--space-4`.
  static const double paddingBlock = DabblerSpacing.space4;

  /// Whether the row reads as unread.
  bool get isUnread => unread > 0;

  /// The unread badge text: `unreadMax+` above [unreadMax].
  String get countLabel => unread > unreadMax ? '$unreadMax+' : '$unread';

  /// The accessible name composed from the row's content.
  String composedLabel() {
    final List<String> parts = <String>[title];
    if (typing) {
      parts.add(
        DabblerTypingIndicator.textFor(
          sender == null ? const <String>[] : <String>[sender!],
          label: typingLabel,
        ),
      );
    } else if (preview != null) {
      parts.add(sender == null ? preview! : '$sender: $preview');
    }
    parts.add(timestamp);
    if (isUnread) parts.add('$countLabel $unreadLabel');
    if (state != null) parts.add(state!.label);
    if (kindLabel != null) parts.add(kindLabel!);
    return parts.join(', ');
  }

  @override
  State<DabblerConversationRow> createState() => _DabblerConversationRowState();
}

class _DabblerConversationRowState extends State<DabblerConversationRow> {
  bool _pressed = false;
  bool _focused = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final DabblerConversationRow w = widget;
    final bool unread = w.isUnread;
    TextStyle t(DabblerTypeStyle s) => s.resolveForDirection(dir);

    final Widget line1 = Row(
      children: <Widget>[
        Expanded(
          child: Text(
            w.title,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: t(DabblerType.subheadline).copyWith(
              fontWeight: unread ? DabblerType.bold : DabblerType.semibold,
              color: colors.textPrimary,
            ),
          ),
        ),
        if (w.muted) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space2),
          ExcludeSemantics(
            child: DabblerIcon(
              'volume-slash',
              size: DabblerConversationRow.muteGlyphSize,
              color: colors.textSecondary,
            ),
          ),
        ],
        const SizedBox(width: DabblerSpacing.space2),
        Text(
          w.timestamp,
          maxLines: 1,
          style: t(DabblerType.caption1).copyWith(
            fontWeight: unread ? DabblerType.semibold : DabblerType.regular,
            color: unread ? colors.brandPrimary : colors.textSecondary,
          ),
        ),
      ],
    );

    final TextStyle footnote = t(DabblerType.footnote);
    final Widget previewBody = w.typing
        ? Align(
            alignment: AlignmentDirectional.centerStart,
            child: DabblerTypingIndicator(
              names: w.sender == null ? const <String>[] : <String>[w.sender!],
              label: w.typingLabel,
            ),
          )
        : Text.rich(
            TextSpan(
              children: <InlineSpan>[
                if (w.sender != null)
                  TextSpan(
                    text: '${w.sender}: ',
                    style: const TextStyle(fontWeight: DabblerType.semibold),
                  ),
                TextSpan(text: w.preview ?? ''),
              ],
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: footnote.copyWith(color: colors.textSecondary),
          );

    final Widget line2 = Row(
      children: <Widget>[
        Expanded(child: previewBody),
        if (unread) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space2),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: DabblerConversationRow.unreadMinWidth,
            ),
            child: DabblerBadge(
              label: w.countLabel,
              tone: w.muted
                  ? DabblerBadgeTone.warning
                  : DabblerBadgeTone.defaultTone,
            ),
          ),
        ],
      ],
    );

    final DabblerConversationState? state = w.state;
    final Widget? line3 = (state == null && w.kindLabel == null)
        ? null
        : Padding(
            padding: const EdgeInsetsDirectional.only(
              top: DabblerSpacing.space1,
            ),
            child: Row(
              children: <Widget>[
                if (state != null)
                  DabblerBadge(
                    label: state.label,
                    status: state.status == null
                        ? DabblerBadge.neutralStatusOf(colors)
                        : colors.status(state.status!),
                    icon: state.icon == null
                        ? null
                        : DabblerIcon(
                            state.icon!,
                            weight: DabblerIconWeight.bold,
                            size: DabblerConversationRow.stateGlyphSize,
                          ),
                  ),
                if (state != null && w.kindLabel != null)
                  const SizedBox(width: DabblerSpacing.space2),
                if (w.kindLabel != null)
                  Flexible(
                    child: Text(
                      w.kindLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t(DabblerType.caption2).copyWith(
                        fontWeight: DabblerType.semibold,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          );

    final Widget content = AnimatedContainer(
      duration: DabblerMotion.reduceMotion(context)
          ? Duration.zero
          : DabblerMotion.fast,
      curve: DabblerMotion.easeOut,
      constraints: const BoxConstraints(
        minHeight: DabblerSizing.touchTargetMin,
      ),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: DabblerConversationRow.paddingInline,
        vertical: DabblerConversationRow.paddingBlock,
      ),
      decoration: BoxDecoration(
        color: _pressed
            ? colors.surfaceSunken
            : colors.surfaceSunken.withValues(alpha: 0),
        border: w.divider
            ? Border(
                bottom: BorderSide(
                  color: colors.bgTertiary,
                  width: DabblerSizing.borderDefault,
                ),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DabblerConversationAvatar(
            kind: w.kind,
            sport: w.sport,
            seed: w.seed ?? w.title,
            size: DabblerConversationRow.avatarSize,
            online: w.online,
          ),
          const SizedBox(width: DabblerSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                line1,
                const SizedBox(height: DabblerSpacing.space1),
                line2,
                if (line3 != null) ...<Widget>[
                  const SizedBox(height: DabblerSpacing.space1),
                  line3,
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (w.onTap == null) {
      return MergeSemantics(child: content);
    }
    return Semantics(
      button: true,
      label: w.semanticLabel ?? w.composedLabel(),
      onTap: w.onTap,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          mouseCursor: SystemMouseCursors.click,
          onShowFocusHighlight: (bool v) => setState(() => _focused = v),
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent intent) {
                w.onTap!();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: w.onTap,
            onTapDown: (TapDownDetails _) => _setPressed(true),
            onTapUp: (TapUpDetails _) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            child: DabblerFocusRing.visible(visible: _focused, child: content),
          ),
        ),
      ),
    );
  }
}
