/// The design system gallery app (KAN-259).
///
/// The package root is itself the runnable app — there is no `example/`
/// directory.
///
/// ## How a component gets into the gallery
///
/// **One added line here, and one file of its own.** A component declares its
/// entries in a colocated `*_gallery.dart` sibling and exports them through
/// the public barrel; this file spreads them. Nothing in this file builds
/// demo widgets, and adding a component never edits another component's
/// gallery file — which is the point: wave 2 ran six component tickets in
/// parallel against a single shared list in this file, and the next wave would
/// have collided on it (KAN-259 AC2/AC3).
///
/// ## It consumes the public barrel
///
/// This app imports `package:dabbler_design_system/dabbler_design_system.dart`
/// and nothing under `lib/src/`, so the gallery doubles as a standing check
/// that the barrel actually exposes what a consumer needs (KAN-256).
library;

import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const GalleryApp());
}

/// The gallery index.
///
/// Each line is one component's own entries. Add a component by exporting its
/// `*_gallery.dart` from the barrel and adding its spread here, alphabetically.
const List<GalleryEntry> galleryEntries = <GalleryEntry>[
  ...avatarGalleryEntries,
  ...badgeGalleryEntries,
  ...bannerGalleryEntries,
  ...buttonGalleryEntries,
  ...calendarGalleryEntries,
  ...cardsGalleryEntries,
  ...chipGalleryEntries,
  ...dialogGalleryEntries,
  ...dividerGalleryEntries,
  ...fabGalleryEntries,
  ...formsGalleryEntries,
  ...foundationsGalleryEntries,
  ...iconTileGalleryEntries,
  ...interactionGalleryEntries,
  ...menuGalleryEntries,
  ...navigationGalleryEntries,
  ...progressBarGalleryEntries,
  ...sectionGalleryEntries,
  ...sheetGalleryEntries,
  ...skeletonGalleryEntries,
  ...spinnerGalleryEntries,
  ...surfaceGalleryEntries,
  ...tabsGalleryEntries,
  ...toastGalleryEntries,
];

/// Entry point of the design system gallery.
class GalleryApp extends StatelessWidget {
  /// Creates the app.
  const GalleryApp({super.key, this.theme = DabblerTheme.main});

  /// Which of the five category palettes the gallery renders under.
  final DabblerTheme theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dabbler Design System',
      debugShowCheckedModeBanner: false,
      theme: galleryTheme(theme, Brightness.light),
      darkTheme: galleryTheme(theme, Brightness.dark),
      // Toasts are an overlay: DabblerToasts needs a provider above the
      // navigator, so it is installed once here rather than per entry.
      builder: (BuildContext context, Widget? child) =>
          DabblerToastProvider(child: child ?? const SizedBox.shrink()),
      home: const GalleryHomeScreen(),
    );
  }
}

/// A [ThemeData] carrying the [DabblerColors] extension every component reads.
///
/// Without the extension `DabblerColors.of` asserts — it treats a missing one
/// as a wiring bug, not a runtime condition — so the gallery installs it
/// rather than relying on a fallback.
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

/// The index screen: every registered entry, one row each.
class GalleryHomeScreen extends StatelessWidget {
  /// Creates the index.
  const GalleryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dabbler Design System (${galleryEntries.length})'),
      ),
      body: galleryEntries.isEmpty
          // Kept, but no longer the common case (AC5): it now describes a
          // real regression — every component's entries failing to register.
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(DabblerSpacing.space8),
                child: Text(
                  'No components registered.\nEvery component contributes its '
                  'own entries; an empty index means none of them reached '
                  'galleryEntries.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              itemCount: galleryEntries.length,
              itemBuilder: (BuildContext context, int index) {
                final GalleryEntry entry = galleryEntries[index];
                return ListTile(
                  title: Text(entry.title),
                  subtitle: entry.description == null
                      ? null
                      : Text(entry.description!),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          GalleryEntryScreen(entry: entry),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// One entry's own screen: the scaffold, the padding and the scroll view, so
/// a component's gallery file builds the specimen and nothing else.
class GalleryEntryScreen extends StatelessWidget {
  /// Creates the screen for [entry].
  const GalleryEntryScreen({super.key, required this.entry});

  /// The entry being shown.
  final GalleryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(entry.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DabblerSpacing.space8),
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: Builder(builder: entry.builder),
          ),
        ),
      ),
    );
  }
}
