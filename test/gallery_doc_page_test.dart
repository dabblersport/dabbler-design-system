/// KAN-327 — the documentation screen.
///
/// `KAN-323` delivered [DabblerDocPageView], which renders an already-parsed
/// page, and `test/` already pins that rendering. This ticket is the screen
/// around it: a path in, the loader run, the `#` title in the header, and a
/// route so a reader can arrive. These tests cover what that adds.
library;

import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A bundle serving pages from a map, so a test states its own corpus instead
/// of depending on what the real one happens to contain today.
class _MapBundle extends CachingAssetBundle {
  _MapBundle(this.pages);

  final Map<String, String> pages;

  @override
  Future<ByteData> load(String key) async => throw FlutterError('no $key');

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final String? body = pages[key];
    if (body == null) throw FlutterError('Unable to load asset: $key');
    return body;
  }
}

/// A specimen whose text carries the live brand colour, so a frozen figure and
/// a re-rendered one are distinguishable.
GalleryEntry _liveEntry() => GalleryEntry(
      id: 'live-swatch',
      title: 'Live swatch',
      page: 'Tokens',
      group: GalleryPurpose.navigation,
      builder: (BuildContext context) => Text(
        'brand:${DabblerColors.of(context).brandPrimary}',
        key: const Key('liveSwatch'),
      ),
    );

Widget _app({
  required String page,
  required Map<String, String> pages,
  List<GalleryEntry> entries = const <GalleryEntry>[],
}) {
  return GalleryThemeScope(
    builder: (BuildContext context, GalleryAppearance appearance) =>
        MaterialApp(
      theme: galleryTheme(appearance.theme, Brightness.light),
      darkTheme: galleryTheme(appearance.theme, Brightness.dark),
      themeMode: appearance.mode,
      builder: (BuildContext context, Widget? child) => Directionality(
        textDirection: appearance.direction,
        child: child ?? const SizedBox.shrink(),
      ),
      home: GalleryDocPage(
        page: page,
        resolver: DabblerDocSpecimenResolver(entries),
        loader: DabblerDocLoader(bundle: _MapBundle(pages)),
      ),
    ),
  );
}

const String _colourPath = 'assets/documentation/foundations/colour.md';
const String _good = '# Colour\n\n'
    'Colour is the one axis every component resolves through the theme.\n\n'
    'Intro paragraph.\n\n'
    '## Specimen\n\n@specimen live-swatch\n\n'
    '## Using it\n\nBody.\n\n'
    '## Source\n\n`lib/src/tokens/dabbler_colors.dart`\n';

void main() {
  group('AC1 — a path in, an assembled page out', () {
    testWidgets('loads by path and titles the header with the # heading',
        (WidgetTester tester) async {
      await tester.pumpWidget(_app(
        page: 'foundations/colour.md',
        pages: const <String, String>{_colourPath: _good},
        entries: <GalleryEntry>[_liveEntry()],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Colour'), findsOneWidget,
          reason: 'the `#` heading is the page title');
      expect(find.byType(GalleryPaper), findsOneWidget);
      expect(find.byType(DabblerDocPageView), findsOneWidget);
      expect(find.byType(GallerySectionLabel), findsWidgets);
    });

    testWidgets('a corpus-relative path and a full asset path both work',
        (WidgetTester tester) async {
      for (final String spelling in <String>[
        'foundations/colour.md',
        _colourPath,
      ]) {
        await tester.pumpWidget(_app(
          page: spelling,
          pages: const <String, String>{_colourPath: _good},
        ));
        await tester.pumpAndSettle();
        expect(find.text('Colour'), findsOneWidget, reason: spelling);
      }
    });

    testWidgets('`## Source` is a file-path line, never a link',
        (WidgetTester tester) async {
      await tester.pumpWidget(_app(
        page: 'foundations/colour.md',
        pages: const <String, String>{_colourPath: _good},
      ));
      await tester.pumpAndSettle();
      // GallerySectionLabel renders uppercase — existing chrome, used as
      // found rather than restyled (D-041(c)4).
      expect(find.text('SOURCE'), findsOneWidget);
      expect(find.text('lib/src/tokens/dabbler_colors.dart'), findsOneWidget,
          reason: 'D-033(e)10 — a code chip carrying the path, not a link to '
              'anything executable');
    });
  });

  group('AC3 — @specimen renders live, in a labelled group', () {
    testWidgets('the resolved entry builds, under its own title',
        (WidgetTester tester) async {
      await tester.pumpWidget(_app(
        page: 'foundations/colour.md',
        pages: const <String, String>{_colourPath: _good},
        entries: <GalleryEntry>[_liveEntry()],
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('liveSwatch')), findsOneWidget);
      // GalleryGroup labels through GallerySectionLabel, so uppercase.
      expect(find.text('LIVE SWATCH'), findsOneWidget,
          reason: 'the group is labelled with the resolved entry title');
    });
  });

  group('AC5 — a bad page is visible, never a throw', () {
    testWidgets('navigating to a missing path renders the failure in place',
        (WidgetTester tester) async {
      final DabblerDocLoader loader =
          DabblerDocLoader(bundle: _MapBundle(const <String, String>{}));
      await tester.pumpWidget(MaterialApp(
        theme: galleryTheme(DabblerTheme.main, Brightness.light),
        home: Builder(
          builder: (BuildContext context) => DabblerButton(
            label: 'Open',
            onPressed: () => Navigator.of(context).push(
              GalleryDocPage.route(
                page: 'components/does-not-exist.md',
                resolver: DabblerDocSpecimenResolver(const <GalleryEntry>[]),
                loader: loader,
              ),
            ),
          ),
        ),
      ));
      // Actually navigated to, per AC5 — not pumped in place.
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(GalleryDocPage), findsOneWidget);
      expect(find.text('Page not available'), findsOneWidget);
    });
  });

  group('AC6 — no figure is frozen across an appearance change', () {
    testWidgets('a specimen recomputes when the theme changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(_app(
        page: 'foundations/colour.md',
        pages: const <String, String>{_colourPath: _good},
        entries: <GalleryEntry>[_liveEntry()],
      ));
      await tester.pumpAndSettle();
      final String before =
          tester.widget<Text>(find.byKey(const Key('liveSwatch'))).data!;

      // Through the real scope, the way the header switcher drives it — not
      // by rebuilding the widget with different arguments.
      GalleryThemeScope.of(tester.element(find.byType(GalleryDocPage)))
          .setTheme(DabblerTheme.sport);
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(find.byKey(const Key('liveSwatch'))).data!,
        isNot(before),
        reason: 'D-037(c): the figure recomputes; it is not cached across a '
            'theme change',
      );
    });

    testWidgets('and survives a direction change', (WidgetTester tester) async {
      await tester.pumpWidget(_app(
        page: 'foundations/colour.md',
        pages: const <String, String>{_colourPath: _good},
        entries: <GalleryEntry>[_liveEntry()],
      ));
      await tester.pumpAndSettle();

      GalleryThemeScope.of(tester.element(find.byType(GalleryDocPage)))
          .setDirection(TextDirection.rtl);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        Directionality.of(tester.element(find.byKey(const Key('liveSwatch')))),
        TextDirection.rtl,
      );
    });
  });

  group('AC4 — D-040(a) is stated on the rendered Start here page', () {
    testWidgets('the chrome-is-not-API rule reaches the screen', (
      WidgetTester tester,
    ) async {
      // Authored content, verified RENDERED. If start-here.md ever loses the
      // line this fails here, and the fix is content-manager's — not a
      // sentence this widget injects.
      const String startHere = 'assets/documentation/start-here.md';
      final String raw =
          await rootBundle.loadString(startHere);
      expect(raw, contains('gallery chrome'),
          reason: 'start-here.md must carry D-040(a) in its own prose');

      await tester.pumpWidget(_app(
        page: 'start-here.md',
        pages: <String, String>{startHere: raw},
      ));
      await tester.pumpAndSettle();

      final Iterable<String> onScreen = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data ?? t.textSpan?.toPlainText() ?? '');
      expect(
        onScreen.any((String s) =>
            s.contains('gallery chrome') &&
            s.contains('not a component to import')),
        isTrue,
        reason: 'D-040(a) must be legible on the rendered Start here page, '
            'not only in the markdown',
      );
    });
  });
}
