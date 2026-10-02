/// Part of the `messaging_parts.dart` library — [DabblerNoticeTone] and [DabblerConversationNotice].
///
/// **Why `part`, not a separate library.** The file stood over the
/// project's 500-line house rule (`013`). These declarations were moved
/// verbatim; `part`/`part of` keeps one logical library, so private names
/// stay private and no public API changes. No exemption was recorded.
///
/// The imports are the library's — a part file declares none of its own.
part of 'messaging_parts.dart';

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
/// Source: `components/messaging/ConversationNotice.jsx`.
///
/// | Source | Dart |
/// |---|---|
/// | `paddingInline: --space-2` | 6 each side |
/// | column `gap: SPACING.metaGap` | [DabblerMessagingSpacing.metaGap] 3 |
/// | `Banner tone={critical ? 'error' : tone}` | [bannerToneFor] |
/// | `action={{label, onPress}}` only when `actionLabel` | [DabblerBannerAction] |
/// | timestamp `.t-caption-1`, `--muted`, `alignSelf: center` | caption1, `textSecondary` (D-003(a)), centred |
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
        DabblerNoticeTone.critical => DabblerBannerTone.error,
      };

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: DabblerSpacing.space2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            Center(
              child: Text(
                timestamp!,
                style: _t(
                  context,
                  DabblerType.caption1,
                ).copyWith(color: colors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
