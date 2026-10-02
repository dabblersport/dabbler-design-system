/// Part of the `message.dart` library — the bubble's inner column (reply, attachment, text).
///
/// **Why `part`, not a separate library.** The file stood over the
/// project's 500-line house rule (`013`). These declarations were moved
/// verbatim; `part`/`part of` keeps one logical library, so private names
/// stay private and no public API changes. No exemption was recorded.
///
/// The imports are the library's — a part file declares none of its own.
part of 'message.dart';

/// The bubble body, moved out of [DabblerMessage.build] verbatim as a
/// library-private extension so `message.dart` stays under the rule.
extension _MessageBubbleBody on DabblerMessage {
  Widget _bubbleBody(TextDirection dir, Color ink, bool out) {
    // The source bubble is a flex column with the default `align-items:
    // stretch`, so the reply reference spans the bubble's full width.
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (reply != null)
            Padding(
              padding: EdgeInsets.only(
                bottom: (attachment != null || (content?.isNotEmpty ?? false))
                    ? DabblerMessagingSpacing.replyGap
                    : 0,
              ),
              child: DabblerMessageReplyReference(
                sender: reply!.sender,
                content: reply!.content,
                attachmentLabel: reply!.attachmentLabel,
                variant: out
                    ? DabblerReplyVariant.onBrand
                    : DabblerReplyVariant.message,
              ),
            ),
          if (attachment != null)
            Padding(
              padding: EdgeInsets.only(
                bottom: (content?.isNotEmpty ?? false)
                    ? DabblerMessagingSpacing.replyGap
                    : 0,
              ),
              child: attachment!.isImage
                  ? ClipRRect(
                      borderRadius: DabblerRadius.lgAll,
                      child: SizedBox(
                        width: DabblerMessage.imageSize.width,
                        height: DabblerMessage.imageSize.height,
                        child: attachment!.child,
                      ),
                    )
                  : SizedBox(
                      width: DabblerMessage.objectWidth,
                      child: attachment!.child,
                    ),
            ),
          if (content != null && content!.isNotEmpty)
            DabblerAutoDirectionText(
              content!,
              style: DabblerType.subheadline
                  .resolveForDirection(dir)
                  .copyWith(color: ink),
            ),
        ],
      ),
    );
  }
}
