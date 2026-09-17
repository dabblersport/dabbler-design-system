/// The gallery app shell.
///
/// Updated by KAN-259: this file asserted the DS-000 empty state — "No
/// components yet" and no `ListView` — which AC5 retires. That state is no
/// longer the common case and asserting it would now be asserting a
/// regression. What the shell must still do is boot, title itself, and put
/// the registered entries on screen; the entries themselves are checked in
/// `test/gallery_test.dart`.
library;

import 'package:dabbler_design_system/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('gallery app boots and shows its title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();

    expect(find.byType(GalleryHomeScreen), findsOneWidget);
    expect(
      find.widgetWithText(
        AppBar,
        'Dabbler Design System (${galleryEntries.length})',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the index is a list of the registered entries, not the '
      'placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();

    expect(galleryEntries, isNotEmpty);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.textContaining('No components registered.'), findsNothing);
    // The first entry's row is on screen; the rest are below the fold.
    expect(find.text(galleryEntries.first.title), findsOneWidget);
  });

  testWidgets('tapping a row opens that entry', (WidgetTester tester) async {
    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text(galleryEntries.first.title));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(GalleryEntryScreen), findsOneWidget);
  });
}
