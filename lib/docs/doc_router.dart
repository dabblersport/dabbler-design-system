// =============================================================================
// Dabbler Docs — hash router
// -----------------------------------------------------------------------------
// Flutter web defaults to hash URLs, so routes look like
// `…/dabbler-design-system/#/components/buttons` — shareable and served
// correctly by GitHub Pages with no server config. The delegate holds the
// current path; the shell renders the matching page. Browser back/forward and
// deep links flow through the RouteInformationParser.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'doc_registry.dart';

/// Parses/serialises the current URL into a route path string.
class DocRouteParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) {
    final path = routeInformation.uri.path;
    return SynchronousFuture(normalizeRoute(path));
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) =>
      RouteInformation(uri: Uri.parse(configuration));
}

/// Holds the current route and rebuilds the app when it changes.
class DocRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  DocRouterDelegate(this.shellBuilder);

  /// Builds the persistent shell for a given route (sidebar + content).
  final Widget Function(String path) shellBuilder;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String _path = defaultRoute;
  String get path => _path;

  /// Navigate to [route]; the browser URL updates via [currentConfiguration].
  void go(String route) {
    final next = normalizeRoute(route);
    if (_path != next) {
      _path = next;
      notifyListeners();
    }
  }

  @override
  String get currentConfiguration => _path;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage<void>(
          key: ValueKey(_path),
          child: shellBuilder(_path),
        ),
      ],
      onDidRemovePage: (_) {},
    );
  }

  @override
  Future<void> setNewRoutePath(String configuration) {
    _path = normalizeRoute(configuration);
    return SynchronousFuture(null);
  }
}

/// Lets any descendant navigate: `DocRouterScope.of(context).go(page.route)`.
class DocRouterScope extends InheritedWidget {
  const DocRouterScope({
    super.key,
    required this.delegate,
    required super.child,
  });

  final DocRouterDelegate delegate;

  void go(String route) => delegate.go(route);

  static DocRouterDelegate of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<DocRouterScope>();
    assert(scope != null, 'DocRouterScope not found in context');
    return scope!.delegate;
  }

  @override
  bool updateShouldNotify(DocRouterScope oldWidget) =>
      delegate != oldWidget.delegate;
}
