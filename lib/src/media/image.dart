import 'package:flutter/widgets.dart';

import '../feed/feed_atoms.dart';
import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';

/// Image — a network photo in a token-radius frame, for article covers,
/// activity thumbnails and post media (KAN-410 item b).
///
/// Built on [Image.network], so the package takes no new dependency; caching is
/// Flutter's own [ImageCache].
///
/// ## What the design shows
///
/// `Home Feed.dc.html` (DesignSync, truncated at 256 KiB — the markup is
/// complete) has **no pager carousel**. Its only multi-image surface is the
/// composer's horizontal media *rail* (`:519-524`), which is an editing strip
/// of add / remove thumbnails, not a viewing carousel; no post row, article or
/// news card pages through several images. So this is a single-image
/// component and no carousel is built. Single images in the design:
///
/// | Design | Dart |
/// | --- | --- |
/// | `:409` news cover `height:210px; radius --radius-xl; bg --surface-sunken` | [height] 210, [DabblerRadius.xlAll] (the default), `surfaceSunken` |
/// | Article hero (`NOTES-inline-read.md:10`) `230px radius-xl` | [height] 230, the default radius |
/// | Article / favourites 64px thumb (`NOTES-inline-read.md:10,15`) | [height] 64 + [width] 64, [DabblerRadius.lgAll] |
/// | `:520-524` composer thumb `104x128; radius --radius-lg; overflow hidden` | [width] 104, [height] 128, [DabblerRadius.lgAll] |
/// | `:410` `<image-slot>` hint text | not reproduced — [errorLabel] is a caller string |
/// | `:411` sport pill `top:12 left:12` over the cover | [overlay] — a start-anchored slot, inset `space4` |
/// | `:524` remove chip `rgba(20,20,20,0.55)` | no token carries that value; the [scrim] role is the nearest (see below) |
///
/// ## Deviations (recorded, not silent)
///
/// * **Scrim.** The design uses a literal `rgba(20,20,20,0.55)` on its remove
///   chip and no wash over covers. [scrim] draws the existing
///   [DabblerColors.scrim] role (ink at 45% light, 65% dark) as a flat wash
///   over the whole image, so a badge placed in [overlay] stays legible. No
///   gradient and no new token.
/// * **Placeholder.** The design's slot shows `surface-sunken` with a text
///   hint; this draws `surfaceSunken` only.
/// * **Error glyph.** The design has no error state. The glyph is the
///   Iconsax `gallery` name (the one the design uses for media), tinted
///   `textTertiary`; the optional [errorLabel] is `caption1` `textSecondary`.
///
/// ## Sizing
///
/// Give a [height] or an [aspectRatio]; with neither, the frame takes the
/// incoming constraints (which must then be bounded in height). The width
/// fills the parent unless [width] is set. The image is always
/// [BoxFit.cover] by default; pass [fit] `BoxFit.contain` for a full-screen
/// viewer, where the whole photo must show (KAN-412 gaps 5 item 8).
///
/// ## Request headers
///
/// [headers] are passed to the network request as is (a CDN that wants a
/// `User-Agent` or an `Accept`, say). They change nothing about loading,
/// error or semantics. Flutter web ignores request headers on image loads.
///
/// ## States
///
/// The sunken fill shows while loading and when [url] is null or blank. When
/// the request fails the same fill shows with the glyph and [errorLabel]. A
/// loaded image fades in over [DabblerMotion.base] with [DabblerMotion.easeOut];
/// under reduced motion it appears at once.
///
/// ## Accessibility
///
/// Without a [semanticLabel] the image is decorative and excluded from
/// semantics. With one it is announced as an image; with [onTap] as a button
/// named by it. [overlay] keeps its own semantics unless the image is
/// decorative.
///
/// RTL: [overlay] sits at the inline-start corner and mirrors.
class DabblerImage extends StatelessWidget {
  /// Creates an image frame.
  const DabblerImage({
    super.key,
    this.url,
    this.width,
    this.height,
    this.aspectRatio,
    this.radius = DabblerRadius.xlAll,
    this.scrim = false,
    this.overlay,
    this.semanticLabel,
    this.errorLabel,
    this.onTap,
    this.fit = BoxFit.cover,
    this.headers,
    this.placeholderGlyph = false,
  }) : assert(
         aspectRatio == null || aspectRatio > 0,
         'aspectRatio must be positive',
       );

  /// The image address. Null or blank draws the placeholder.
  final String? url;

  /// A fixed width; null fills the parent.
  final double? width;

  /// A fixed height; takes precedence over [aspectRatio].
  final double? height;

  /// Width / height, used when [height] is null.
  final double? aspectRatio;

  /// The corner, one of the [DabblerRadius] `*All` values (`lgAll` for a
  /// tile, `xlAll` for a cover).
  final BorderRadius radius;

  /// Whether [DabblerColors.scrim] washes over the image.
  final bool scrim;

  /// Content over the image (a sport badge, say), at the inline-start top
  /// corner, above the [scrim].
  final Widget? overlay;

  /// The accessible name. Null marks the image decorative.
  final String? semanticLabel;

  /// Text under the glyph in the error state; this package ships no strings,
  /// so the caller localises it. Null shows the glyph alone.
  final String? errorLabel;

  /// Opens the image. Null leaves it inert.
  final VoidCallback? onTap;

  /// How the photo fills the frame. Default [BoxFit.cover]; use
  /// [BoxFit.contain] for a full-screen viewer (the sunken fill shows in the
  /// letterbox).
  final BoxFit fit;

  /// HTTP headers sent with the image request. Null sends none.
  final Map<String, String>? headers;

  /// Whether a null or blank [url] draws the `gallery` glyph over the sunken
  /// fill (the error state's glyph) instead of the bare fill — for a slot that
  /// must read as "a photo goes here", such as a venue cover with no photo yet.
  /// Default false: the bare fill, as before.
  final bool placeholderGlyph;

  /// Error glyph side — [DabblerSizing.iconLg].
  static const double errorGlyphSize = DabblerSizing.iconLg;

  /// Overlay inset — `top:12 left:12` (`Home Feed.dc.html:411`), `space4`.
  static const double overlayInset = DabblerSpacing.space4;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final String? trimmed = url?.trim();
    final bool hasUrl = trimmed != null && trimmed.isNotEmpty;
    final bool reduceMotion = DabblerMotion.reduceMotion(context);

    final Widget fill = ColoredBox(color: colors.surfaceSunken);

    Widget error(BuildContext context) {
      final TextDirection dir = Directionality.of(context);
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          fill,
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DabblerIcon(
                  'gallery',
                  size: errorGlyphSize,
                  color: colors.textTertiary,
                ),
                if (errorLabel != null) ...<Widget>[
                  const SizedBox(height: DabblerSpacing.space2),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DabblerSpacing.space2,
                    ),
                    child: Text(
                      errorLabel!,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: DabblerType.caption1
                          .resolveForDirection(dir)
                          .copyWith(color: colors.textSecondary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    final Widget frame = Stack(
      fit: StackFit.expand,
      children: <Widget>[
        fill,
        if (!hasUrl && placeholderGlyph) error(context),
        if (hasUrl)
          Image.network(
            trimmed,
            fit: fit,
            headers: headers,
            excludeFromSemantics: true,
            gaplessPlayback: true,
            frameBuilder:
                (BuildContext c, Widget child, int? frame, bool sync) {
                  if (sync || reduceMotion) {
                    return frame == null ? const SizedBox.shrink() : child;
                  }
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: DabblerMotion.base,
                    curve: DabblerMotion.easeOut,
                    child: child,
                  );
                },
            errorBuilder: (BuildContext c, Object e, StackTrace? s) => error(c),
          ),
        if (scrim) ColoredBox(color: colors.scrim),
        if (overlay != null)
          PositionedDirectional(
            top: overlayInset,
            start: overlayInset,
            child: overlay!,
          ),
      ],
    );

    Widget body = ClipRRect(borderRadius: radius, child: frame);
    if (height != null) {
      body = SizedBox(width: width, height: height, child: body);
    } else if (aspectRatio != null) {
      body = AspectRatio(aspectRatio: aspectRatio!, child: body);
      if (width != null) body = SizedBox(width: width, child: body);
    } else if (width != null) {
      body = SizedBox(width: width, child: body);
    }

    if (onTap != null) {
      return DabblerFeedTappable(
        onTap: onTap,
        semanticLabel: semanticLabel,
        borderRadius: radius,
        child: body,
      );
    }
    if (semanticLabel == null) return ExcludeSemantics(child: body);
    return Semantics(label: semanticLabel, image: true, child: body);
  }
}
