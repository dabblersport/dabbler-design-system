/// The gallery's app shell and its two screens.
///
/// These used to live in `lib/main.dart`, which made the app entry point the
/// place the gallery's appearance was defined as well as the place every
/// component registered itself. They moved here so `main.dart` is what it
/// claims to be: the registration list and `runApp`, and no widget code.
///
/// ## The chrome is the design's, not Material's
///
/// Nothing on either screen is a `Scaffold`, an `AppBar`, a `ListTile`, a
/// `Card` or a `Divider`. The page is [GalleryPaper], the title row is
/// [GalleryPageHeader], the catalogue is [GalleryIndex] and a specimen sits in
/// a [GalleryGroup] — every one of them a rebuild of how the design's own
/// `*.card.html` specimen pages are composed. See `gallery_page.dart` for the
/// line-by-line mapping back to the design source.
///
/// [MaterialApp] itself stays, and so does the route: they are mechanisms
/// (directionality, media query, the [Navigator], text editing, overlays) that
/// Flutter offers nowhere else, which is exactly what D-017 permits the import
/// for. What does not survive is Material's paint — the [ThemeData] built here
/// carries the [DabblerColors] extension and is otherwise never read.
library;

// `material.dart` for MaterialApp, ThemeData, ThemeMode and the Navigator —
// mechanisms only. No Material appearance is read anywhere below; every colour
// comes from DabblerColors. D-017.
import 'package:flutter/material.dart';

import '../controls/button.dart';
import '../feedback/toast.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'gallery_entry.dart';
import 'gallery_index.dart';
import 'gallery_page.dart';
import 'gallery_theme_scope.dart';
import 'gallery_theme_switcher.dart';

/// Entry point of the design system gallery.
class GalleryApp extends StatelessWidget {
  /// Creates the app over [entries].
  ///
  /// The list is passed in rather than read from `main.dart`: this file sits
  /// under `lib/src/` and a component's registration list lives above it, so
  /// the dependency only points one way.
  const GalleryApp({super.key, required this.entries});

  /// Every registered entry.
  final List<GalleryEntry> entries;

  @override
  Widget build(BuildContext context) {
    // Above the MaterialApp on purpose: the switcher has to repaint every
    // pushed route and every overlay, not just one screen — and being above
    // the Navigator is what makes the choice survive a push and a pop. See
    // GalleryThemeScope.
    return GalleryThemeScope(
      builder: (BuildContext context, GalleryAppearance appearance) =>
          MaterialApp(
        title: 'Dabbler Design System',
        debugShowCheckedModeBanner: false,
        theme: galleryTheme(appearance.theme, Brightness.light),
        darkTheme: galleryTheme(appearance.theme, Brightness.dark),
        themeMode: appearance.mode,
        // Toasts are an overlay: DabblerToasts needs a provider above the
        // navigator, so it is installed once here rather than per entry.
        //
        // The DefaultTextStyle is installed at the same height, and for the
        // reason `galleryTextStyle` documents: without one, Flutter's
        // fallback underlines every label in yellow. GalleryPaper installs it
        // for the screens, but menus, sheets, dialogs and toasts build from
        // the Navigator's context — above any page — so they need it here.
        // The Directionality sits here for the same reason, and it is the
        // whole point of the axis: a menu, a sheet, a dialog or a toast builds
        // from the Navigator's context, so a Directionality installed on a
        // screen would mirror the page and leave every overlay unmirrored —
        // which would look like proof while proving nothing. Installed above
        // the Navigator, it overrides the one WidgetsApp derives from the
        // locale, and every route and overlay resolves under it.
        builder: (BuildContext context, Widget? child) => Directionality(
          textDirection: appearance.direction,
          child: DefaultTextStyle(
            style: galleryTextStyle(context),
            child:
                DabblerToastProvider(child: child ?? const SizedBox.shrink()),
          ),
        ),
        home: GalleryHomeScreen(entries: entries),
      ),
    );
  }
}

/// A [ThemeData] carrying the [DabblerColors] extension every component reads.
///
/// Without the extension `DabblerColors.of` asserts — it treats a missing one
/// as a wiring bug, not a runtime condition — so the gallery installs it
/// rather than relying on a fallback. Nothing else on this [ThemeData] is ever
/// read for paint; `scaffoldBackgroundColor` is set only so that the platform
/// clears to paper rather than white during a route transition.
ThemeData galleryTheme(DabblerTheme theme, Brightness brightness) {
  final DabblerColors colors = DabblerColors.resolve(
    theme: theme,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: colors.bgPrimary,
    extensions: <ThemeExtension<dynamic>>[colors],
  );
}

/// The catalogue screen.
class GalleryHomeScreen extends StatelessWidget {
  /// Creates the catalogue.
  const GalleryHomeScreen({super.key, required this.entries});

  /// Every registered entry.
  final List<GalleryEntry> entries;

  @override
  Widget build(BuildContext context) {
    return GalleryPaper(
      header: const GalleryPageHeader(
        title: 'Dabbler Design System',
        subtitle: 'Every component, under all fourteen palettes.',
        trailing: GalleryThemeSwitcher(),
      ),
      child: GalleryIndex(
        entries: entries,
        onOpen: (GalleryEntry entry) => Navigator.of(context).push(
          galleryEntryRoute(entry),
        ),
      ),
    );
  }
}

/// The route an entry opens in.
///
/// A [PageRouteBuilder] with a plain fade rather than [MaterialPageRoute]:
/// routing is the mechanism the gallery wants, but `MaterialPageRoute` also
/// brings `ThemeData.pageTransitionsTheme`, which is a Material appearance
/// reaching a pixel.
Route<void> galleryEntryRoute(GalleryEntry entry) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 160),
    reverseTransitionDuration: const Duration(milliseconds: 120),
    pageBuilder: (BuildContext context, Animation<double> a,
            Animation<double> b) =>
        GalleryEntryScreen(entry: entry),
    transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondary, Widget child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// One entry's own page, composed the way the design composes a `.card.html`:
/// the page's name and subtitle over a hairline, then the specimen under its
/// band label with air around it.
class GalleryEntryScreen extends StatelessWidget {
  /// Creates the screen for [entry].
  const GalleryEntryScreen({super.key, required this.entry});

  /// The entry being shown.
  final GalleryEntry entry;

  @override
  Widget build(BuildContext context) {
    const String separator = ' — ';
    final int at = entry.title.indexOf(separator);
    final String component = at < 0 ? entry.title : entry.title.substring(0, at);
    final String band = at < 0
        ? 'Specimen'
        : entry.title.substring(at + separator.length);

    return GalleryPaper(
      header: GalleryPageHeader(
        title: component,
        subtitle: entry.description,
        // Present only when there is something to pop — the entry screen is
        // also pumped directly by `test/gallery_test.dart`, with no route
        // below it.
        leading: Navigator.of(context).canPop()
            ? DabblerButton(
                label: 'Back',
                tone: DabblerButtonTone.outlined,
                size: DabblerButtonSize.small,
                semanticLabel: 'Back to the catalogue',
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        trailing: const GalleryThemeSwitcher(),
      ),
      child: GalleryGroup(
        name: band,
        wrap: false,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: DabblerSpacing.space2),
            child: Builder(builder: entry.builder),
          ),
        ],
      ),
    );
  }
}
