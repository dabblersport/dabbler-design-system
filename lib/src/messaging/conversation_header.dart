import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/sports.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'messaging_atoms.dart';
import 'messaging_foundations.dart';

/// The colour of a [DabblerConversationHeader] subtitle.
enum DabblerConversationSubtitleTone {
  /// `--muted` — the default (the source's absent `subtitleTone`).
  muted,

  /// `--color-status-success-strong`.
  success,

  /// `--color-status-error-strong`.
  error,
}

/// ConversationHeader — the top bar of a conversation: back, a tappable
/// identity, and overflow.
///
/// Ported from the live Claude Design project
/// 4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System), files
/// `components/messaging/ConversationHeader.jsx` and
/// `ConversationHeader.prompt.md`, read via DesignSync get_file on 2026-10-02
/// and transcribed to a local mirror by the coordinator.
///
/// An injected view-model: every value and callback is a constructor
/// parameter; the header holds no conversation, presence or typing state.
///
/// | Source | Dart |
/// |---|---|
/// | row `height: 52`, `box-sizing: border-box` | [height] 52 including the hairline |
/// | `paddingInline: var(--space-2)`, `gap: var(--space-1)` | inline 6, gap 3 |
/// | `borderBlockEnd: 1px solid var(--faint)`, `background: var(--surface-page)` | 1px [DabblerColors.bgTertiary], [DabblerColors.bgPrimary] |
/// | back / overflow: `--touch-target-min` square, `--radius-pill`, `--ink`, `Icon size 24` | [target] 45, pill focus ring, [DabblerColors.textPrimary], 24 |
/// | back icon `arrow-circle-left`, overflow icon `more` | same names, never mirrored (see Direction) |
/// | `aria-label={backLabel}` / `{overflowLabel}`, defaults `Back` / `More` | [backLabel] / [overflowLabel] |
/// | identity `button`: `flex: 1`, `gap --space-3`, `paddingInline --space-1`, `height --touch-target-min`, `textAlign: start` | [Expanded], gap 9, inline 3, height 45, start-aligned |
/// | `ConversationAvatar size={36}`, `seed={seed \|\| title}` | [DabblerConversationAvatar] size 36, seed falls back to [title] |
/// | title `t-subheadline`, `fontWeight 600`, `--ink`, nowrap ellipsis | [DabblerType.subheadline] w600, [DabblerColors.textPrimary], one line, ellipsis |
/// | subtitle `t-caption-2`, tone success / error / `--muted`, nowrap ellipsis | [DabblerType.caption2], `success.strong` / `error.strong` / [DabblerColors.textSecondary] (D-003(a)) |
/// | `typing ? <TypingIndicator names={typing}/> : subtitle` | [typing] non-null replaces the subtitle with [DabblerTypingIndicator] |
///
/// ## Direction
///
/// The row is built from logical insets, so it mirrors under RTL: back sits at
/// the inline start (right in RTL) and overflow at the inline end. **The back
/// glyph is not mirrored.** The live JSX passes `arrow-circle-left` in both
/// directions, and [DabblerIcon] never mirrors itself (the Icon card selects a
/// mirrored glyph *name* instead, and this source does not). So under RTL the
/// back arrow at the right edge still points left; this matches live and is
/// recorded as an open question rather than silently corrected.
///
/// ## Accessibility
///
/// Three buttons: back ([backLabel]), identity (named by [title] then the
/// subtitle or typing sentence), and overflow ([overflowLabel]). A null
/// handler leaves the target visible but inert, as [DabblerMessagingTap] does.
class DabblerConversationHeader extends StatelessWidget {
  /// A conversation header.
  const DabblerConversationHeader({
    super.key,
    required this.title,
    this.onBack,
    this.onTitlePress,
    this.onOverflow,
    this.backLabel = 'Back',
    this.overflowLabel = 'More',
    this.kind = DabblerConversationKind.player,
    this.sport,
    this.seed,
    this.subtitle,
    this.subtitleTone = DabblerConversationSubtitleTone.muted,
    this.typing,
    this.online = false,
  });

  /// The bar height including the hairline — `height: 52`.
  static const double height = 52;

  /// The back / overflow target side — `--touch-target-min`.
  static const double target = DabblerSizing.touchTargetMin;

  /// The avatar size — `size={36}`.
  static const double avatarSize = 36;

  /// The icon size — `size={24}`.
  static const double iconSize = 24;

  /// The back glyph — `arrow-circle-left`, in both directions.
  static const String backIcon = 'arrow-circle-left';

  /// The overflow glyph — `more`.
  static const String overflowIcon = 'more';

  /// The conversation name.
  final String title;

  /// Back. Null leaves the target inert.
  final VoidCallback? onBack;

  /// Opens conversation details. Null leaves the identity inert.
  final VoidCallback? onTitlePress;

  /// Opens the overflow menu. Null leaves the target inert.
  final VoidCallback? onOverflow;

  /// The back target's accessible name.
  final String backLabel;

  /// The overflow target's accessible name.
  final String overflowLabel;

  /// What the conversation is (the avatar's kind tile).
  final DabblerConversationKind kind;

  /// The sport for a `game`.
  final DabblerSport? sport;

  /// The avatar seed; falls back to [title].
  final String? seed;

  /// The line under the title (presence, member count, status).
  final String? subtitle;

  /// The subtitle's colour.
  final DabblerConversationSubtitleTone subtitleTone;

  /// Who is typing; non-null replaces the subtitle.
  final List<String>? typing;

  /// Whether the player is online (avatar presence dot).
  final bool online;

  /// The subtitle colour for [tone].
  static Color subtitleColorFor(
    DabblerColors colors,
    DabblerConversationSubtitleTone tone,
  ) => switch (tone) {
    DabblerConversationSubtitleTone.success => colors.success.strong,
    DabblerConversationSubtitleTone.error => colors.error.strong,
    DabblerConversationSubtitleTone.muted => colors.textSecondary,
  };

  /// The identity target's accessible name.
  String get identityLabel {
    final String? second = typing != null
        ? DabblerTypingIndicator.textFor(typing!)
        : subtitle;
    return (second == null || second.isEmpty) ? title : '$title, $second';
  }

  Widget _iconTarget(
    DabblerColors colors,
    String icon,
    String label,
    VoidCallback? onTap,
  ) => DabblerMessagingTap(
    label: label,
    onTap: onTap,
    ringRadius: DabblerRadius.pillAll,
    child: SizedBox(
      width: target,
      height: target,
      child: Center(
        child: DabblerIcon(icon, size: iconSize, color: colors.textPrimary),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final TextStyle titleStyle = DabblerType.subheadline
        .resolveForDirection(dir)
        .copyWith(fontWeight: DabblerType.semibold, color: colors.textPrimary);
    final TextStyle subtitleStyle = DabblerType.caption2
        .resolveForDirection(dir)
        .copyWith(color: subtitleColorFor(colors, subtitleTone));

    final Widget? second = typing != null
        // The atom's sentence sets no maxLines; the header keeps it to one
        // line (the subtitle's nowrap) through the inherited text style.
        ? DefaultTextStyle.merge(
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            child: DabblerTypingIndicator(names: typing!),
          )
        : (subtitle == null
              ? null
              : Text(
                  subtitle!,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: subtitleStyle,
                ));

    final Widget identity = DabblerMessagingTap(
      label: identityLabel,
      onTap: onTitlePress,
      scale: false,
      child: SizedBox(
        height: target,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: DabblerSpacing.space1,
          ),
          child: Row(
            children: <Widget>[
              DabblerConversationAvatar(
                kind: kind,
                sport: sport,
                seed: seed ?? title,
                size: avatarSize,
                online: online,
              ),
              const SizedBox(width: DabblerSpacing.space3),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: titleStyle,
                    ),
                    ?second,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      height: height,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: DabblerSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: colors.bgPrimary,
        border: Border(
          bottom: BorderSide(
            color: colors.bgTertiary,
            width: DabblerSizing.borderDefault,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          _iconTarget(colors, backIcon, backLabel, onBack),
          const SizedBox(width: DabblerSpacing.space1),
          Expanded(child: identity),
          const SizedBox(width: DabblerSpacing.space1),
          _iconTarget(colors, overflowIcon, overflowLabel, onOverflow),
        ],
      ),
    );
  }
}
