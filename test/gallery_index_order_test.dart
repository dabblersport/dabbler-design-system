/// KAN-328 AC3 — the index's band order comes from `_order.md`.
///
/// `GalleryIndex._bands()` used to sequence its nine bands by
/// `GalleryPurpose.values`, a hand-authored enum. That is the "second,
/// divergent copy" AC3 exists to prevent: the enum and the authored file agree
/// today and nothing kept them agreeing tomorrow.
///
/// `cxo` ruled `D-049` — option (a), **order only**: the index takes its group
/// sequence from `_order.md` by an independent, narrower read, which is not a
/// call into the navigation's own derivation and so does not reopen the
/// `D-047`(e) merge that was withdrawn.
///
/// Because the enum order and the file order match in the real corpus, only a
/// **disagreeing** file can tell the two mechanisms apart — which is what the
/// stub bundle here is for.
library;

import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _MapBundle extends CachingAssetBundle {
  _MapBundle(this.files);

  final Map<String, String> files;

  @override
  Future<ByteData> load(String key) async => throw FlutterError('no $key');

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final String? body = files[key];
    if (body == null) throw FlutterError('Unable to load asset: $key');
    return body;
  }
}

GalleryEntry _entry(GalleryPurpose group, String id) => GalleryEntry(
      id: id,
      title: id,
      page: 'components/$id.md',
      group: group,
      builder: (BuildContext context) => const SizedBox.shrink(),
    );

/// One entry in each of the nine groups, registered in an order that matches
/// neither the enum nor the file — so a pass cannot come from registration.
final List<GalleryEntry> _nine = <GalleryEntry>[
  _entry(GalleryPurpose.structure, 'divider'),
  _entry(GalleryPurpose.navigation, 'top-bar'),
  _entry(GalleryPurpose.actions, 'button'),
  _entry(GalleryPurpose.contentContainers, 'card'),
  _entry(GalleryPurpose.statusAndFeedback, 'toast'),
  _entry(GalleryPurpose.identityAndStatus, 'avatar'),
  _entry(GalleryPurpose.presentation, 'sheet'),
  _entry(GalleryPurpose.dateAndTime, 'calendar'),
  _entry(GalleryPurpose.selectionAndInput, 'text-field'),
];

/// An `_order.md` whose nine groups run in REVERSE of the enum's order.
String _reversedOrderMd() {
  final List<GalleryPurpose> reversed =
      GalleryPurpose.values.reversed.toList();
  final StringBuffer b = StringBuffer('# Reading order\n\nLead.\n\n## Components\n\n');
  for (int i = 0; i < reversed.length; i++) {
    b.writeln('### ${i + 1} · ${reversed[i].label} — a tagline\n');
    b.writeln('- [A page](components/a.md) — one line.\n');
  }
  return b.toString();
}

const String _orderPath = 'assets/documentation/_order.md';

Future<List<String>> _renderedBands(
  WidgetTester tester, {
  required Map<String, String> files,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: galleryTheme(DabblerTheme.main, Brightness.light),
    home: Scaffold(
      body: GalleryIndex(
        entries: _nine,
        onOpen: (GalleryEntry _) {},
        loader: DabblerDocLoader(bundle: _MapBundle(files)),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  // Band names render through GalleryGroup -> GallerySectionLabel, uppercase,
  // suffixed with a count. Existing chrome, read as found.
  return tester
      .widgetList<GallerySectionLabel>(find.byType(GallerySectionLabel))
      .map((GallerySectionLabel l) => l.text.split(' (').first)
      .toList();
}

void main() {
  group('AC3 — the order is sourced from _order.md', () {
    testWidgets('a file that disagrees with the enum wins', (
      WidgetTester tester,
    ) async {
      final List<String> bands = await _renderedBands(
        tester,
        files: <String, String>{_orderPath: _reversedOrderMd()},
      );
      expect(
        bands,
        GalleryPurpose.values.reversed
            .map((GalleryPurpose p) => p.label)
            .toList(),
        reason: 'the authored file is the spine; the enum order is not',
      );
      expect(bands, isNot(GalleryPurpose.values.map((GalleryPurpose p) => p.label).toList()),
          reason: 'if this matched, the enum would still be deciding');
    });

    testWidgets('the real corpus file orders the bands', (
      WidgetTester tester,
    ) async {
      final String real = await rootBundle.loadString(_orderPath);
      final List<String> bands = await _renderedBands(
        tester,
        files: <String, String>{_orderPath: real},
      );
      // The real file and the enum agree, which is the point: this pins that
      // they still do, and the test above proves which one is load-bearing.
      expect(
        bands,
        GalleryPurpose.values.map((GalleryPurpose p) => p.label).toList(),
      );
    });
  });

  group('D-047(d) — the index never degrades', () {
    testWidgets('an unreadable _order.md falls back to the enum, all nine '
        'bands present', (WidgetTester tester) async {
      final List<String> bands =
          await _renderedBands(tester, files: const <String, String>{});
      expect(
        bands,
        GalleryPurpose.values.map((GalleryPurpose p) => p.label).toList(),
        reason: 'the nav may show "unavailable"; the index may not — it is '
            'the below-1000 navigation and nothing replaces it',
      );
    });

    testWidgets('an unparseable _order.md falls back the same way', (
      WidgetTester tester,
    ) async {
      final List<String> bands = await _renderedBands(
        tester,
        files: const <String, String>{_orderPath: 'not a reading order at all'},
      );
      expect(bands.length, GalleryPurpose.values.length);
    });

    testWidgets('a group the file never names is still rendered', (
      WidgetTester tester,
    ) async {
      // A file naming only two groups must not drop the other seven.
      const String partial = '# Reading order\n\nLead.\n\n## Components\n\n'
          '### 1 · Structure — a tagline\n\n- [A](components/a.md) — x.\n\n'
          '### 2 · Actions — a tagline\n\n- [B](components/b.md) — y.\n';
      final List<String> bands = await _renderedBands(
        tester,
        files: const <String, String>{_orderPath: partial},
      );
      expect(bands.first, 'Structure');
      expect(bands[1], 'Actions');
      expect(bands.length, GalleryPurpose.values.length,
          reason: 'unnamed groups are appended, never dropped');
    });
  });

  group('non-changes D-049 names explicitly', () {
    test('GalleryPurpose keeps its ruled membership', () {
      expect(GalleryPurpose.values.length, 9);
      expect(
        GalleryPurpose.values.map((GalleryPurpose p) => p.label).toList(),
        <String>[
          'Navigation',
          'Content containers',
          'Identity and status',
          'Selection and input',
          'Date and time',
          'Actions',
          'Presentation',
          'Status and feedback',
          'Structure',
        ],
      );
    });

    testWidgets('Foundations stays first, and stays hardcoded (D-033(a))', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(
        theme: galleryTheme(DabblerTheme.main, Brightness.light),
        home: Scaffold(
          body: GalleryIndex(
            entries: <GalleryEntry>[
              ..._nine,
              GalleryEntry(
                id: 'colour',
                title: 'Colour',
                page: 'foundations/colour.md',
                group: null,
                builder: (BuildContext context) => const SizedBox.shrink(),
              ),
            ],
            onOpen: (GalleryEntry _) {},
            loader: DabblerDocLoader(
              bundle: _MapBundle(<String, String>{
                _orderPath: _reversedOrderMd(),
              }),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final List<String> bands = tester
          .widgetList<GallerySectionLabel>(find.byType(GallerySectionLabel))
          .map((GallerySectionLabel l) => l.text.split(' (').first)
          .toList();
      expect(bands.first, 'Foundations',
          reason: 'section order is D-033(a), transcribed per D-043, and is '
              'not what moved to the file');
    });
  });
}
