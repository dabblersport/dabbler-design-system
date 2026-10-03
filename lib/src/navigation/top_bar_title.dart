/// Part of the `top_bar.dart` library — the titled variant's fading title.
///
/// **Why `part`.** `top_bar.dart` was already over the 500-line house rule
/// (941 lines) before Alpha DS gaps 6 item 11; the scroll-fade lives here so
/// that file does not grow by the feature's weight.
part of 'top_bar.dart';

/// The titled bar's title text, faded by [DabblerNavigationTopBar.titleOpacity]
/// or revealed by [DabblerNavigationTopBar.scrollController].
///
/// `Profiles.dc.html:57` sets `opacity: {{ f.navTitleOpacity }}; transition:
/// opacity 160ms ease`, and `:815-822` / `:932` flip it from 0 to 1 once the
/// page has scrolled past `max(headerHeight - 52, 18)`. That is a reveal at a
/// threshold, not a scrub, so the controller path is binary and animated;
/// the [DabblerNavigationTopBar.titleOpacity] path is for a caller who wants
/// to scrub it continuously.
///
/// **Deviation (duration).** 160ms has no motion token; it sits midway between
/// [DabblerMotion.base] (120) and [DabblerMotion.slow] (200), and `base` is
/// taken. Under reduced motion the change is immediate.
///
/// The title stays in the semantics tree at every opacity — the screen is
/// still called that, whether or not it is painted yet.
class _TopBarTitle extends StatelessWidget {
  const _TopBarTitle({
    required this.text,
    required this.style,
    required this.opacity,
    required this.controller,
    required this.revealOffset,
  });

  final String text;
  final TextStyle style;
  final double opacity;
  final ScrollController? controller;
  final double revealOffset;

  @override
  Widget build(BuildContext context) {
    final Widget label = Text(
      text,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    final Duration duration = DabblerMotion.reduceMotion(context)
        ? Duration.zero
        : DabblerMotion.base;
    final ScrollController? c = controller;
    if (c == null) {
      if (opacity >= 1) {
        return label;
      }
      return Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        alwaysIncludeSemantics: true,
        child: label,
      );
    }
    return ListenableBuilder(
      listenable: c,
      builder: (BuildContext context, Widget? child) {
        final bool shown =
            c.hasClients && c.positions.first.pixels > revealOffset;
        return AnimatedOpacity(
          opacity: shown ? opacity.clamp(0.0, 1.0) : 0,
          duration: duration,
          curve: DabblerMotion.easeOut,
          alwaysIncludeSemantics: true,
          child: child,
        );
      },
      child: label,
    );
  }
}
