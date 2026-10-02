/// Part of the `chat_composer.dart` library — the notice that replaces the input row.
///
/// **Why `part`, not a separate library.** The file stood over the
/// project's 500-line house rule (`013`). These declarations were moved
/// verbatim; `part`/`part of` keeps one logical library, so private names
/// stay private and no public API changes. No exemption was recorded.
///
/// The imports are the library's — a part file declares none of its own.
part of 'chat_composer.dart';

/// The notice builder, moved off [_DabblerChatComposerState] verbatim as a
/// library-private extension so the state class stays under the rule.
extension _ComposerNotice on _DabblerChatComposerState {
  Widget _buildNotice(
    BuildContext context,
    DabblerColors colors,
    DabblerComposerNotice notice,
  ) {
    final TextDirection dir = Directionality.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: DabblerRadius.mdAll,
        border: Border.all(
          color: colors.bgTertiary,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: Padding(
        // 9 vertical / 12 horizontal, inside the 1px border.
        padding: const EdgeInsets.symmetric(
          vertical: DabblerSpacing.space3,
          horizontal: DabblerSpacing.space4,
        ),
        child: Row(
          children: <Widget>[
            DabblerIcon(
              notice.icon,
              size: DabblerSizing.iconSm,
              color: colors.textSecondary,
            ),
            const SizedBox(width: DabblerSpacing.space3),
            Expanded(
              child: Text(
                notice.text,
                style: DabblerType.caption1
                    .resolveForDirection(dir)
                    .copyWith(color: colors.textSecondary),
              ),
            ),
            if (notice.actionLabel != null) ...<Widget>[
              const SizedBox(width: DabblerSpacing.space3),
              DabblerButton(
                label: notice.actionLabel!,
                tone: DabblerButtonTone.outlined,
                size: DabblerButtonSize.small,
                onPressed: notice.onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
