/// Part of the `message.dart` library — the message enums and the [DabblerReplySpec] / [DabblerMessageAttachment] view-models.
///
/// **Why `part`, not a separate library.** The file stood over the
/// project's 500-line house rule (`013`). These declarations were moved
/// verbatim; `part`/`part of` keeps one logical library, so private names
/// stay private and no public API changes. No exemption was recorded.
///
/// The imports are the library's — a part file declares none of its own.
part of 'message.dart';

/// Ownership of a [DabblerMessage]. Outgoing fills with brand and aligns to the
/// inline end.
enum DabblerMessageDirection {
  /// From someone else.
  incoming,

  /// From the viewer.
  outgoing,
}

/// The conversation context. `group` adds the avatar gutter and sender name.
enum DabblerMessageContext {
  /// One other person.
  direct,

  /// Several people.
  group,
}

/// Position within a same-sender run. Set by `DabblerMessageThread`.
enum DabblerGroupPosition {
  /// Alone.
  single,

  /// The run's first.
  first,

  /// Inside a run.
  middle,

  /// The run's last.
  last,
}

/// A message's interaction state.
enum DabblerMessageState {
  /// Normal.
  normal,

  /// Draws the brand outline.
  selected,

  /// Disables interaction.
  readOnly,
}

/// The quoted message of a reply.
@immutable
class DabblerReplySpec {
  /// A reply spec.
  const DabblerReplySpec({
    this.sender = '',
    this.content,
    this.attachmentLabel,
  });

  /// Who wrote the quoted message.
  final String sender;

  /// The quoted text.
  final String? content;

  /// Set instead of [content] when the quoted message was an attachment.
  final String? attachmentLabel;
}

/// What a message carries besides text.
@immutable
class DabblerMessageAttachment {
  /// An image, supplied by the caller and drawn 232x156 with a 12px corner.
  const DabblerMessageAttachment.image({required this.child}) : isImage = true;

  /// A shared game, venue or player.
  const DabblerMessageAttachment.object(DabblerSharedObjectCard card)
    : child = card,
      isImage = false;

  /// The attachment's widget.
  final Widget child;

  /// Whether this is an image.
  final bool isImage;
}
