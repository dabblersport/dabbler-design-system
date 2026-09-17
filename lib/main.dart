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
/// widgets of any kind — not demo widgets and, since the chrome rebuild, not
/// the app shell either, which now lives in `lib/src/gallery/gallery_app.dart`.
/// Adding a component never edits another component's gallery file, which is
/// the point: wave 2 ran six component tickets in parallel against a single
/// shared list in this file, and the next wave would have collided on it
/// (KAN-259 AC2/AC3).
///
/// ## It consumes the public barrel
///
/// This app imports `package:dabbler_design_system/dabbler_design_system.dart`
/// and nothing under `lib/src/`, so the gallery doubles as a standing check
/// that the barrel actually exposes what a consumer needs (KAN-256).
library;

import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const GalleryApp(entries: galleryEntries));
}

/// The gallery index.
///
/// Each line is one component's own entries. Add a component by exporting its
/// `*_gallery.dart` from the barrel and adding its spread here, alphabetically.
const List<GalleryEntry> galleryEntries = <GalleryEntry>[
  ...accordionGalleryEntries,
  ...avatarGalleryEntries,
  ...badgeGalleryEntries,
  ...ratingGalleryEntries,
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
  ...tooltipGalleryEntries,
];
