import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';

/// The numbers behind [DabblerFade].
abstract final class DabblerFadeTokens {
  const DabblerFadeTokens._();

  /// Where the fade stops being opaque, measured from the bottom edge — the
  /// design's `var(--surface-page) 62%`.
  static const double opaqueStop = 0.62;

  /// The inset below the child — the design's 24px bottom padding,
  /// `--space-8`.
  static const double bottomInset = DabblerSpacing.space8;
}

/// Fade — the wash that lets a list run out beneath a bottom bar.
///
/// The design draws one, and only one, gradient: on the wrapper behind the
/// bottom navigation bar in `Home Feed.dc.html` and `Listings.dc.html`,
/// `linear-gradient(to top, var(--surface-page) 62%, rgba(245,240,230,0))`.
/// It is opaque page colour at the bottom edge, fully transparent at the top,
/// and exists only so scrolling content does not collide with the bar.
///
/// **This is the one documented exception to the system's flatness rule**, and
/// it is not a surface: it carries no content of its own, only paints the page
/// colour out to nothing. Both stops are [DabblerColors.bgPrimary] — opaque,
/// then the same colour at zero alpha — so no colour is introduced and dark
/// follows the page. The gradient runs bottom to top and has no horizontal
/// component, so it does not mirror.
///
/// The widget paints over whatever is behind it and, like the design's div,
/// takes hits across its whole box.
class DabblerFade extends StatelessWidget {
  /// Wraps [child] in the fade.
  const DabblerFade({
    super.key,
    required this.child,
    this.padding = const EdgeInsetsDirectional.only(
      bottom: DabblerFadeTokens.bottomInset,
    ),
  });

  /// The bar or control that sits on the fade.
  final Widget child;

  /// Space around [child]. The default is the design's 24px under it.
  final EdgeInsetsGeometry padding;

  /// The gradient for [colors]: opaque page colour at the bottom edge, up to
  /// [DabblerFadeTokens.opaqueStop], then transparent at the top.
  static LinearGradient gradientFor(DabblerColors colors) => LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: <Color>[
      colors.bgPrimary,
      colors.bgPrimary,
      colors.bgPrimary.withValues(alpha: 0),
    ],
    stops: const <double>[0, DabblerFadeTokens.opaqueStop, 1],
  );

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradientFor(colors)),
      child: Padding(padding: padding, child: child),
    );
  }
}
