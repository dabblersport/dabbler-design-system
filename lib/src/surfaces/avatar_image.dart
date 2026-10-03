part of 'avatar.dart';

/// The image-URL form of [DabblerAvatar] (KAN-409 item 1).
///
/// A photo replaces the generated portrait inside the same circle — the
/// [DabblerAvatarSize] diameter, the clip, the `bgTertiary` ground, the ring
/// and the badge are all unchanged, so a photo avatar and a seed avatar are
/// interchangeable in any layout.
///
/// The seed portrait is never absent: it is what draws while the photo is
/// loading, when [url] is null or empty, and when the request fails. A broken
/// URL therefore degrades to the same face the person would have had without
/// one — never to an error glyph, a blank disc, or initials.
///
/// Uses [Image.network], so the package takes no new dependency; caching is
/// Flutter's own [ImageCache].
Widget _avatarFace(
  BuildContext context,
  Widget seedPortrait,
  String? url,
  double diameter,
) {
  final String? trimmed = url?.trim();
  if (trimmed == null || trimmed.isEmpty) return seedPortrait;
  return Image.network(
    trimmed,
    width: diameter,
    height: diameter,
    fit: BoxFit.cover,
    // Decorative: [DabblerAvatar] excludes the whole circle from semantics.
    excludeFromSemantics: true,
    gaplessPlayback: true,
    frameBuilder:
        (BuildContext context, Widget child, int? frame, bool synchronous) =>
            synchronous || frame != null ? child : seedPortrait,
    errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
        seedPortrait,
  );
}
