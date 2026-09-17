/// The gallery's appearance state — which of the seven [DabblerTheme]s, which
/// brightness and which reading direction the whole app renders under.
///
/// ## Why this is a scope above the app, not a widget inside it
///
/// `DabblerColors` reaches every component as a [ThemeExtension] installed on
/// the [MaterialApp]'s `theme`/`darkTheme`. A control that changed the theme
/// from *inside* a screen could only re-wrap that screen's own subtree, which
/// would leave the app bar, the overlays (menus, sheets, dialogs, toasts) and
/// every pushed route painting the old palette — the overlay entries in
/// particular build against the [Navigator]'s context, not the caller's.
///
/// So the state lives above [MaterialApp]: this widget rebuilds the app with a
/// new `theme`, and every route, overlay and component below it re-resolves.
/// Being above the [Navigator] is also what makes the choice survive a push
/// and a pop for free — nothing in a route holds it, so nothing resets it
/// (KAN-259 wiring; brief AC3).
///
/// The scope exposes itself downwards through a plain [InheritedWidget] so the
/// switcher can sit in any app bar, on the index and on every entry screen,
/// without the screens threading callbacks.
library;

// `material.dart` for [ThemeMode] and nothing else: it is the mechanism
// MaterialApp takes its light/dark preference as, and D-017 permits the
// import for a mechanism. No Material appearance is read here — every
// colour below comes from DabblerColors through the components.
import 'package:flutter/material.dart';

import '../tokens/dabbler_colors.dart';

/// The gallery's current appearance: one theme, one brightness preference, one
/// reading direction.
@immutable
class GalleryAppearance {
  /// Creates an appearance.
  const GalleryAppearance({
    this.theme = DabblerTheme.main,
    this.mode = ThemeMode.light,
    this.direction = TextDirection.ltr,
  });

  /// Which of the seven section themes the gallery resolves colours under.
  final DabblerTheme theme;

  /// Light, dark, or whatever the platform asks for.
  ///
  /// [ThemeMode] rather than a bare [Brightness] because "follow the OS" is a
  /// third state the reviewer needs: it is the one a screenshot taken on a
  /// device will show.
  ///
  /// **The default is [ThemeMode.light], not [ThemeMode.system].** The design
  /// source settles this: `tokens/colors.css:6` states *"Default = MAIN
  /// light"*, and the surface foundation it then declares is warm cream paper
  /// -- `--surface-page:#F5F0E6`, `--surface-card:#FFFFFF` -- inherited
  /// verbatim from the Figma file and shared by all seven themes. Dabbler is a
  /// light-first product that HAS a dark mode, not a mode-agnostic one.
  ///
  /// Following the OS made the gallery paint its provisional dark ramp on a
  /// reviewer's dark-mode machine, so the first thing anyone saw was the
  /// appearance the design does not lead with. Dark stays one tap away in
  /// [GalleryThemeSwitcher]; it is just no longer what a cold open shows.
  final ThemeMode mode;

  /// The reading direction the whole app — including overlays — renders under.
  ///
  /// RTL behaviour is specified across this package in dartdoc and asserted in
  /// widget tests, and until this axis existed none of it had ever been looked
  /// at: the calendar's Saturday-first week, the code input's deliberately
  /// unmirrored digit boxes, the slider's inverted pointer and the date
  /// field's LTR-pinned editable were all claims nobody could see. This is the
  /// control that renders them.
  ///
  /// [TextDirection] rather than a locale: the gallery flips *direction*, not
  /// language. A specimen whose text stays English under
  /// [TextDirection.rtl] is behaving correctly — mirrored layout is this
  /// axis's subject, and localized content is a separate question owned
  /// elsewhere.
  ///
  /// The default is [TextDirection.ltr], for the same reason [mode] defaults
  /// to light: a cold open shows what the design leads with.
  final TextDirection direction;

  /// This appearance with [theme] replaced.
  GalleryAppearance withTheme(DabblerTheme theme) =>
      GalleryAppearance(theme: theme, mode: mode, direction: direction);

  /// This appearance with [mode] replaced.
  GalleryAppearance withMode(ThemeMode mode) =>
      GalleryAppearance(theme: theme, mode: mode, direction: direction);

  /// This appearance with [direction] replaced.
  GalleryAppearance withDirection(TextDirection direction) =>
      GalleryAppearance(theme: theme, mode: mode, direction: direction);

  @override
  bool operator ==(Object other) =>
      other is GalleryAppearance &&
      other.theme == theme &&
      other.mode == mode &&
      other.direction == direction;

  @override
  int get hashCode => Object.hash(theme, mode, direction);
}

/// Holds the gallery's [GalleryAppearance] and rebuilds [builder] with it.
///
/// Wrap the [MaterialApp] — not a screen:
///
/// ```dart
/// GalleryThemeScope(
///   builder: (BuildContext context, GalleryAppearance appearance) =>
///       MaterialApp(
///         theme: galleryTheme(appearance.theme, Brightness.light),
///         darkTheme: galleryTheme(appearance.theme, Brightness.dark),
///         themeMode: appearance.mode,
///         builder: (BuildContext context, Widget? child) => Directionality(
///           textDirection: appearance.direction,
///           child: child ?? const SizedBox.shrink(),
///         ),
///         home: const GalleryHomeScreen(),
///       ),
/// )
/// ```
class GalleryThemeScope extends StatefulWidget {
  /// Creates the scope, starting at [initial].
  const GalleryThemeScope({
    super.key,
    required this.builder,
    this.initial = const GalleryAppearance(),
  });

  /// Builds the app under the current appearance.
  final Widget Function(BuildContext context, GalleryAppearance appearance)
      builder;

  /// The appearance the gallery opens on.
  final GalleryAppearance initial;

  /// The nearest scope's controls, or null when there is none.
  ///
  /// Returns a [GalleryThemeController] rather than the state object so the
  /// only thing reachable from a widget is "read the appearance, set the
  /// appearance".
  static GalleryThemeController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_GalleryAppearanceScope>()
      ?.controller;

  /// The nearest scope's controls.
  ///
  /// Asserts when there is none: a switcher with nothing to switch is a wiring
  /// bug, exactly as [DabblerColors.of] treats a missing extension.
  static GalleryThemeController of(BuildContext context) {
    final GalleryThemeController? controller = maybeOf(context);
    assert(
      controller != null,
      'No GalleryThemeScope above this widget. The gallery installs one above '
      'its MaterialApp; a switcher can only be used below that.',
    );
    return controller!;
  }

  @override
  State<GalleryThemeScope> createState() => _GalleryThemeScopeState();
}

/// Read-and-set access to the gallery's appearance, handed out by
/// [GalleryThemeScope.of].
abstract class GalleryThemeController {
  /// The appearance the gallery is rendering under right now.
  GalleryAppearance get appearance;

  /// Renders everything under [theme] from the next frame.
  void setTheme(DabblerTheme theme);

  /// Switches to [mode] from the next frame.
  void setMode(ThemeMode mode);

  /// Renders everything — pages and overlays alike — under [direction] from
  /// the next frame.
  void setDirection(TextDirection direction);
}

class _GalleryThemeScopeState extends State<GalleryThemeScope>
    implements GalleryThemeController {
  late GalleryAppearance _appearance = widget.initial;

  @override
  GalleryAppearance get appearance => _appearance;

  @override
  void setTheme(DabblerTheme theme) {
    if (theme != _appearance.theme) {
      setState(() => _appearance = _appearance.withTheme(theme));
    }
  }

  @override
  void setMode(ThemeMode mode) {
    if (mode != _appearance.mode) {
      setState(() => _appearance = _appearance.withMode(mode));
    }
  }

  @override
  void setDirection(TextDirection direction) {
    if (direction != _appearance.direction) {
      setState(() => _appearance = _appearance.withDirection(direction));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _GalleryAppearanceScope(
      appearance: _appearance,
      controller: this,
      child: Builder(
        builder: (BuildContext context) => widget.builder(context, _appearance),
      ),
    );
  }
}

/// Publishes the appearance downwards. Rebuilds dependents when it changes;
/// the controller identity is the [State] and never does.
class _GalleryAppearanceScope extends InheritedWidget {
  const _GalleryAppearanceScope({
    required this.appearance,
    required this.controller,
    required super.child,
  });

  final GalleryAppearance appearance;
  final GalleryThemeController controller;

  @override
  bool updateShouldNotify(_GalleryAppearanceScope oldWidget) =>
      oldWidget.appearance != appearance;
}
