/// KAN-328 AC3 / D-047(d) — the index never degrades on a bad `_order.md`.
///
/// **KAN-342 disposed of the rest of this file under `T-087`.** What remains is
/// the three degradation cases `T-087`(h) named as the open edge — invisible in
/// normal operation, visible only if you corrupt the file by hand, and
/// explicitly **not** covered by the gate that replaced the fourth:
///
/// - *"a file that disagrees with the enum wins"* became
///   `tool/check_order_bands.dart`, `T-087`(h)'s own recommendation: the
///   invariant underneath it — `_order.md`'s group sequence and
///   `GalleryPurpose`'s labels must not diverge — is population drift and is
///   gate-shaped, and the gate makes the stub-bundle test redundant.
/// - *"the real corpus file orders the bands"*, *"Foundations stays first"* and
///   *"GalleryPurpose keeps its ruled membership"* were the forbidden shape by
///   `T-087`(e)'s own naming — visible on one screen, or restating an enum —
///   and are deleted.
///
/// `D-047(d)` ruled the index IS the below-1000 navigation and nothing replaces
/// it: the nav may show "unavailable" on a bad file, the index may not. Each
/// case below pins one way the file can be bad and asserts all nine bands are
/// still there.
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
          '### 1 \u00b7 Structure — a tagline\n\n- [A](components/a.md) — x.\n\n'
          '### 2 \u00b7 Actions — a tagline\n\n- [B](components/b.md) — y.\n';
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
}
