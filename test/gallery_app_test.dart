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
///
/// Updated by KAN-354: a tile no longer pushes `GalleryEntryScreen`; it opens
/// the entry's canonical documentation page ([DabblerDocPageView]) in place,
/// identically above and below the 1000px rail breakpoint, and the reader can
/// get back to the catalogue from there.
library;

import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:dabbler_design_system/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
    // KAN-295 replaced the single COMPONENTS band with one band per purpose
    // group, plus a Foundations band, so the count is now per band. The sum
    // of the band counts is still every registered entry, which is what this
    // was checking.
    final int foundations = galleryEntries
        .where((GalleryEntry e) => e.page.startsWith('foundations/'))
        .length;
    expect(find.text('FOUNDATIONS ($foundations)'), findsOneWidget);
    int banded = foundations;
    for (final GalleryPurpose purpose in GalleryPurpose.values) {
      final int n = galleryEntries
          .where((GalleryEntry e) => e.group == purpose)
          .length;
      if (n == 0) continue;
      banded += n;
      expect(find.text('${purpose.label.toUpperCase()} ($n)'), findsOneWidget);
    }
    expect(banded, galleryEntries.length);
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

  // 800 is the default test surface; 1400 puts the rail beside the pane.
  for (final double width in <double>[800, 1400]) {
    testWidgets('a tile opens its documentation page at ${width}px', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      // rootBundle caches each asset's load future, and one created in an
      // earlier test's fake-async zone never completes in this one.
      addTearDown(rootBundle.clear);

      await tester.pumpWidget(const GalleryApp(entries: galleryEntries));
      await tester.pumpAndSettle();

      final GalleryEntry entry = tester
          .widget<GalleryIndexTile>(find.byType(GalleryIndexTile).first)
          .entry;
      await tester.tap(find.byType(GalleryIndexTile).first);
      // The page loads from the bundle a frame after the tap.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(GalleryEntryScreen), findsNothing);
      expect(find.byType(DabblerDocPageView), findsOneWidget);
      expect(
        find.byKey(ValueKey<String>('${entry.page}.md')),
        findsWidgets,
        reason: 'the tile must open the page its entry names',
      );
      expect(find.byType(GalleryIndexTile), findsNothing);

      // The way back: the rail's catalogue row above the breakpoint, the
      // page's own Back control below it.
      if (width < 1000) {
        await tester.tap(find.widgetWithText(DabblerButton, 'Back'));
      } else {
        await tester.tap(find.text('All specimens').first);
      }
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(DabblerDocPageView), findsNothing);
      expect(find.byType(GalleryIndexTile), findsWidgets);
    });
  }
}
