import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dabbler_design_system/docs/docs_app.dart';
import 'package:dabbler_design_system/docs/doc_registry.dart';

void main() {
  testWidgets('docs app boots to the landing page and the sidebar navigates',
      (tester) async {
    // Wide window so the persistent sidebar (not the Drawer) is shown.
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const DocsApp());
    await tester.pumpAndSettle();

    // Landing page (first registered) renders its title.
    expect(find.text('Introduction'), findsWidgets);

    // Navigate via the sidebar to a foundation page (Color has no perpetual
    // animation, so the frame settles).
    await tester.tap(find.text('Color').first);
    await tester.pumpAndSettle();

    // The Color page's definition proves routing + page rendering worked.
    expect(
      find.textContaining('Seven themes over one token structure'),
      findsOneWidget,
    );
  });

  test('registry has no duplicate routes and a valid default', () {
    final routes = docPages.map((p) => p.route).toList();
    expect(routes.toSet().length, routes.length, reason: 'duplicate routes');
    expect(routes, contains(defaultRoute));
    // Every page normalizes to itself.
    for (final p in docPages) {
      expect(normalizeRoute(p.route), p.route);
    }
    // Unknown paths fall back to the default.
    expect(normalizeRoute('/nope/nope'), defaultRoute);
  });
}
