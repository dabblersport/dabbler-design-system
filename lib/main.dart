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
  ...onColorIconButtonGalleryEntries,
  ...calendarGalleryEntries,
  ...calendarYearGalleryEntries,
  ...calendarStatusGalleryEntries,
  ...cardsGalleryEntries,
  ...listingCardsGalleryEntries,
  ...cardGameGalleryEntries,
  ...cardUpcomingGalleryEntries,
  ...chatComposerGalleryEntries,
  ...conversationRowGalleryEntries,
  ...messagingAtomsGalleryEntries,
  ...messagingThreadGalleryEntries,
  ...chipGalleryEntries,
  ...filterRailGalleryEntries,
  ...filterRailGalleryEntries,
  ...colorsGalleryEntries,
  ...conversationContextGalleryEntries,
  ...conversationHeaderGalleryEntries,
  ...dialogGalleryEntries,
  ...directionGalleryEntries,
  ...dividerGalleryEntries,
  ...fabGalleryEntries,
  ...fadeGalleryEntries,
  ...feedGalleryEntries,
  ...threadGalleryEntries,
  ...formsGalleryEntries,
  ...foundationsGalleryEntries,
  ...geometryGalleryEntries,
  ...iconTileGalleryEntries,
  ...imageGalleryEntries,
  ...providerMarkGalleryEntries,
  ...interactionGalleryEntries,
  ...menuGalleryEntries,
  ...messagingPartsGalleryEntries,
  ...motionGalleryEntries,
  ...appRolesGalleryEntries,
  ...navigationGalleryEntries,
  ...pageHeaderGalleryEntries,
  ...navigationTabBarGalleryEntries,
  ...panelCardsGalleryEntries,
  ...roomCardsGalleryEntries,
  ...roomsGalleryEntries,
  ...progressBarGalleryEntries,
  ...ringGalleryEntries,
  ...searchGalleryEntries,
  ...formExtrasGalleryEntries,
  ...textLinkGalleryEntries,
  ...textGalleryEntries,
  ...selectableCardGalleryEntries,
  ...dateColumnsGalleryEntries,
  ...flowGalleryEntries,
  ...iconListGalleryEntries,
  ...progressStagesGalleryEntries,
  ...stepProgressGalleryEntries,
  ...heroIconGalleryEntries,
  ...sortControlGalleryEntries,
  ...sectionGalleryEntries,
  ...sheetGalleryEntries,
  ...skeletonGalleryEntries,
  ...spinnerGalleryEntries,
  ...statTileGalleryEntries,
  ...detailGalleryEntries,
  ...profileRowGalleryEntries,
  ...surfaceGalleryEntries,
  ...swipeActionGalleryEntries,
  ...tabsGalleryEntries,
  ...refreshGalleryEntries,
  ...shellGalleryEntries,
  ...avatarImageGalleryEntries,
  ...topBarUnreadGalleryEntries,
  ...themesGalleryEntries,
  ...toastGalleryEntries,
  ...tooltipGalleryEntries,
  ...typeGalleryEntries,
  ...vibesGalleryEntries,
];
