/// The gallery app shell.
///
/// Updated by KAN-259: this file asserted the DS-000 empty state — "No
/// components yet" and no `ListView` — which AC5 retires. That state is no
/// longer the common case and asserting it would now be asserting a
/// regression. What the shell must still do is boot, title itself, and put
/// the registered entries on screen; the entries themselves are checked in
/// `test/gallery_test.dart`.
///
/// Updated again by the chrome rebuild: the shell is no longer a `Scaffold` +
/// `AppBar` + `ListView` of `ListTile`s, so the finders that named those
/// widgets now name the design's own page furniture instead — the page title
/// lives in a [GalleryPageHeader] and the catalogue is a band of
/// [GalleryIndexTile]s. What is being asserted is unchanged: it boots, it
/// titles itself, it shows what is registered, and a tile opens its entry.
library;

import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:dabbler_design_system/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('gallery app boots and shows its title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GalleryApp(entries: galleryEntries));
    await tester.pumpAndSettle();

    expect(find.byType(GalleryHomeScreen), findsOneWidget);
    expect(
      find.widgetWithText(GalleryPageHeader, 'Dabbler Design System'),
      findsOneWidget,
    );
    // The count moved off the title and onto the catalogue band's label,
    // which the design renders uppercase.
    expect(
      find.text('COMPONENTS (${galleryEntries.length})'),
      findsOneWidget,
    );
  });

  testWidgets('the index is a list of the registered entries, not the '
      'placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(const GalleryApp(entries: galleryEntries));
    await tester.pumpAndSettle();

    expect(galleryEntries, isNotEmpty);
    expect(find.byType(GalleryIndexTile), findsWidgets);
    expect(find.textContaining('No components registered.'), findsNothing);
    // The first entry's tile is on screen; the rest are below the fold. The
    // tile splits '<Component> — <subject>' across two lines, so the
    // component half is what is findable as a single string.
    expect(
      find.text(galleryEntries.first.title.split(' — ').first),
      findsWidgets,
    );
  });

  testWidgets('tapping a tile opens that entry', (WidgetTester tester) async {
    await tester.pumpWidget(const GalleryApp(entries: galleryEntries));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(GalleryIndexTile).first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(GalleryEntryScreen), findsOneWidget);
  });
}
