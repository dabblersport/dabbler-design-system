import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'fade.dart';

part 'page_overlay.dart';

/// Page — the screen scaffold: the page background, the safe area, an optional
/// top bar, the body, and an optional bottom bar.
///
/// It replaces Material's `Scaffold` for screens built from this system and
/// draws nothing of Material's: the only paint is the page background,
/// `bgPrimary` (`--surface-page`, the design files' screen ground — e.g.
/// `Home Feed.dc.html`, `Article.dc.html`, `Settings.dc.html`, each frame's
/// `background:var(--surface-page)`).
///
/// ## Safe area
///
/// `DabblerNavigationTopBar` and `DabblerNavigationBottomBar` already pad
/// themselves by the status-bar and home-indicator insets. The page therefore
/// applies the safe area only on an edge that has **no** bar: the top inset
/// when [topBar] is null, the bottom inset when [bottomBar] is null. The two can
/// never double-apply.
///
/// ## Keyboard
///
/// With [resizeForKeyboard] (the default), the page lifts its content above the
/// on-screen keyboard by the view insets — the body shrinks and the bottom bar
/// rides on the keyboard — the same contract `Scaffold.resizeToAvoidBottomInset`
/// gives. Set it to `false` for a page that manages the keyboard itself.
///
/// ## Floating overlay
///
/// [bottomOverlay] is a bar that floats **over** the body rather than under
/// it — the Home Feed and Listings frames' bottom navigation, drawn on a
/// wrapper with `linear-gradient(to top, surface-page 62%, transparent)`.
/// The body is not shrunk: it keeps scrolling beneath the overlay, and the
/// page raises the bottom padding (and view padding) of the body's
/// `MediaQuery` by the overlay's measured height, so a scrolling body that
/// honours it (`ListView` and `CustomScrollView` do by default) can still
/// scroll its last item clear of the bar. A non-scrolling body is covered by
/// the overlay — size it yourself or read the padding.
///
/// RTL: nothing here is directional; the slots mirror on their own.
class DabblerPage extends StatelessWidget {
  /// A page.
  const DabblerPage({
    super.key,
    required this.body,
    this.topBar,
    this.bottomBar,
    this.resizeForKeyboard = true,
    this.bottomOverlay,
    this.overlayFade = true,
    this.overlayPadding,
    this.maxContentWidth,
  });

  /// The side and bottom padding the design wraps the Home Feed bar in:
  /// `0 18px 24px` — `--space-6` at the sides, `--space-8` below.
  static const EdgeInsetsGeometry overlayPaddingDefault =
      EdgeInsetsDirectional.fromSTEB(
        DabblerSpacing.space6,
        0,
        DabblerSpacing.space6,
        DabblerFadeTokens.bottomInset,
      );

  /// The Listings frame's `0 12px 24px` — `--space-4` at the sides.
  static const EdgeInsetsGeometry overlayPaddingCompact =
      EdgeInsetsDirectional.fromSTEB(
        DabblerSpacing.space4,
        0,
        DabblerSpacing.space4,
        DabblerFadeTokens.bottomInset,
      );

  /// The page content, filling the space between the bars.
  final Widget body;

  /// The top bar — usually a `DabblerNavigationTopBar` (plain or `.titled`).
  final Widget? topBar;

  /// The bottom bar — usually a `DabblerNavigationBottomBar`.
  final Widget? bottomBar;

  /// Whether the page lifts its content above the on-screen keyboard.
  final bool resizeForKeyboard;

  /// A bar that floats over the bottom of [body] — usually a
  /// `DabblerNavigationBottomBar`. Null (the default) draws nothing extra and
  /// leaves the page exactly as it was. The overlay is full width and pads its
  /// own home-indicator inset, as the bars do.
  final Widget? bottomOverlay;

  /// Whether a [DabblerFade] sits behind [bottomOverlay], washing the body out
  /// to the page colour beneath it. Default true; ignored without an overlay.
  final bool overlayFade;

  /// Space around [bottomOverlay] inside the fade (or alone when
  /// [overlayFade] is false). Null is [overlayPaddingDefault] with the fade
  /// and none without it.
  final EdgeInsetsGeometry? overlayPadding;

  /// The widest the top bar, body and bottom bar grow, centred in the page.
  ///
  /// Null (the default) lets them fill the page, exactly as before. A phone
  /// frame never reaches the limit; a wide window shows the phone layout
  /// rather than stretching it. [DabblerPage.readableWidth] is the width the
  /// Auth and Onboarding frames are drawn at.
  final double? maxContentWidth;

  /// `480` — the widest a phone-shaped screen is drawn on a wide window.
  static const double readableWidth = 480;

  Widget _bounded(Widget child, {required bool fillHeight}) {
    final double? max = maxContentWidth;
    if (max == null) return child;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Center(
        child: SizedBox(
          width: constraints.maxWidth < max ? constraints.maxWidth : max,
          height: fillHeight ? constraints.maxHeight : null,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final double keyboard = resizeForKeyboard
        ? MediaQuery.viewInsetsOf(context).bottom
        : 0;

    final Widget content = bottomOverlay == null
        ? SafeArea(
            top: topBar == null,
            bottom: bottomBar == null && keyboard == 0,
            child: body,
          )
        : _DabblerPageOverlayStack(
            safeTop: topBar == null,
            overlay: _wrapOverlay(),
            body: body,
          );

    final Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (topBar != null) _bounded(topBar!, fillHeight: false),
        Expanded(child: _bounded(content, fillHeight: true)),
        if (bottomBar != null) _bounded(bottomBar!, fillHeight: false),
      ],
    );

    return ColoredBox(
      color: colors.bgPrimary,
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: MediaQuery.removeViewInsets(
          context: context,
          removeBottom: resizeForKeyboard,
          child: column,
        ),
      ),
    );
  }
}
