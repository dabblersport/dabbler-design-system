import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';

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
/// RTL: nothing here is directional; the slots mirror on their own.
class DabblerPage extends StatelessWidget {
  /// A page.
  const DabblerPage({
    super.key,
    required this.body,
    this.topBar,
    this.bottomBar,
    this.resizeForKeyboard = true,
  });

  /// The page content, filling the space between the bars.
  final Widget body;

  /// The top bar — usually a `DabblerNavigationTopBar` (plain or `.titled`).
  final Widget? topBar;

  /// The bottom bar — usually a `DabblerNavigationBottomBar`.
  final Widget? bottomBar;

  /// Whether the page lifts its content above the on-screen keyboard.
  final bool resizeForKeyboard;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final double keyboard = resizeForKeyboard
        ? MediaQuery.viewInsetsOf(context).bottom
        : 0;

    final Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ?topBar,
        Expanded(
          child: SafeArea(
            top: topBar == null,
            bottom: bottomBar == null && keyboard == 0,
            child: body,
          ),
        ),
        ?bottomBar,
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
