// =============================================================================
// Dabbler Docs — page registry (single source of truth)
// -----------------------------------------------------------------------------
// The ONE list the sidebar, search, and router all read. To add a page: create
// its file exposing a `DocPage`, then add it here. Nav order = list order,
// grouped by DocPage.group.
// =============================================================================

import 'doc_model.dart';
import 'pages/components_buttons.dart';
import 'pages/components_cards.dart';
import 'pages/components_inputs.dart';
import 'pages/foundations_color.dart';
import 'pages/foundations_elevation.dart';
import 'pages/foundations_iconography.dart';
import 'pages/foundations_motion.dart';
import 'pages/foundations_radius.dart';
import 'pages/foundations_spacing.dart';
import 'pages/foundations_typography.dart';
import 'pages/getting_started.dart';
import 'pages/patterns_stubs.dart';

/// Every documentation page, in sidebar order.
final List<DocPage> docPages = <DocPage>[
  gettingStartedPage,
  // Foundations
  colorPage,
  typographyPage,
  spacingPage,
  radiusPage,
  elevationPage,
  iconographyPage,
  motionPage,
  // Components
  buttonsPage,
  inputsPage,
  cardsPage,
  // Patterns
  gameCardPage,
  organiserCardPage,
  venueCardPage,
];

/// Pages grouped by [DocGroup], preserving list order — drives the sidebar.
Map<DocGroup, List<DocPage>> get docPagesByGroup {
  final map = <DocGroup, List<DocPage>>{};
  for (final page in docPages) {
    (map[page.group] ??= <DocPage>[]).add(page);
  }
  return map;
}

final Map<String, DocPage> _byRoute = {
  for (final p in docPages) p.route: p,
};

/// The landing page (first registered).
final String defaultRoute = docPages.first.route;

/// Map any incoming path to a known route (unknown / root → [defaultRoute]).
String normalizeRoute(String path) {
  final cleaned = path.isEmpty ? '/' : path;
  if (_byRoute.containsKey(cleaned)) return cleaned;
  return defaultRoute;
}

/// The page for a (normalized) route.
DocPage pageForRoute(String path) => _byRoute[normalizeRoute(path)]!;
