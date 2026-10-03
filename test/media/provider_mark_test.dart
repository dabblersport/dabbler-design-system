import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

AssetImage _asset(WidgetTester tester) {
  final Image img = tester.widget<Image>(find.byType(Image));
  return img.image as AssetImage;
}

/// The host tightens width to 320; Align loosens it so the mark's own size shows.
Widget _loose(Widget c) =>
    Align(alignment: AlignmentDirectional.topStart, child: c);

void main() {
  for (final TextDirection dir in TextDirection.values) {
    group('direction ${dir.name}', () {
      testWidgets('Google picks the tile by brightness', (tester) async {
        await tester.pumpWidget(
          host(const DabblerProviderMark.google(), direction: dir),
        );
        expect(
          _asset(tester).assetName,
          'assets/provider_marks/google-light.png',
        );
        expect(_asset(tester).package, 'dabbler_design_system');
        await tester.pumpWidget(
          host(
            const DabblerProviderMark.google(),
            direction: dir,
            brightness: Brightness.dark,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          _asset(tester).assetName,
          'assets/provider_marks/google-dark.png',
        );
      });

      testWidgets('Apple is black on light, white on dark', (tester) async {
        await tester.pumpWidget(
          host(const DabblerProviderMark.apple(), direction: dir),
        );
        expect(
          _asset(tester).assetName,
          'assets/provider_marks/apple-black.png',
        );
        await tester.pumpWidget(
          host(
            const DabblerProviderMark.apple(),
            direction: dir,
            brightness: Brightness.dark,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          _asset(tester).assetName,
          'assets/provider_marks/apple-white.png',
        );
      });

      testWidgets('native sizes and the size override', (tester) async {
        await tester.pumpWidget(
          host(_loose(const DabblerProviderMark.google()), direction: dir),
        );
        expect(tester.getSize(find.byType(Image)), const Size(40, 40));
        await tester.pumpWidget(
          host(_loose(const DabblerProviderMark.apple()), direction: dir),
        );
        expect(tester.getSize(find.byType(Image)), const Size(44, 44));
        await tester.pumpWidget(
          host(
            _loose(const DabblerProviderMark.apple(size: 24)),
            direction: dir,
          ),
        );
        expect(tester.getSize(find.byType(Image)), const Size(24, 24));
      });

      testWidgets('is announced by vendor, label overridable', (tester) async {
        final SemanticsHandle h = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const DabblerProviderMark.google(), direction: dir),
        );
        expect(find.bySemanticsLabel('Google'), findsOneWidget);
        await tester.pumpWidget(
          host(const DabblerProviderMark.apple(), direction: dir),
        );
        expect(find.bySemanticsLabel('Apple'), findsOneWidget);
        await tester.pumpWidget(
          host(
            const DabblerProviderMark.apple(semanticLabel: 'Apple ID'),
            direction: dir,
          ),
        );
        expect(find.bySemanticsLabel('Apple ID'), findsOneWidget);
        h.dispose();
      });

      testWidgets('excludeFromSemantics removes the label', (tester) async {
        final SemanticsHandle h = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            const DabblerProviderMark.google(excludeFromSemantics: true),
            direction: dir,
          ),
        );
        expect(find.bySemanticsLabel('Google'), findsNothing);
        h.dispose();
      });

      testWidgets('is never mirrored', (tester) async {
        await tester.pumpWidget(
          host(const DabblerProviderMark.google(), direction: dir),
        );
        final Image img = tester.widget<Image>(find.byType(Image));
        expect(img.matchTextDirection, isFalse);
      });
    });
  }

  testWidgets('bundled tiles load at every declared density', (tester) async {
    for (final Brightness b in Brightness.values) {
      for (final DabblerProviderMarkVendor v
          in DabblerProviderMarkVendor.values) {
        final String path = DabblerProviderMark.assetFor(v, b);
        final String name = path.split('/').last;
        for (final String prefix in <String>['', '2.0x/', '3.0x/']) {
          await rootBundleHas('assets/provider_marks/$prefix$name');
        }
      }
    }
  });
}

Future<void> rootBundleHas(String key) async {
  final data = await DefaultAssetBundle.of(
    // ignore: invalid_use_of_visible_for_testing_member
    WidgetsBinding.instance.rootElement ?? (throw StateError('no root')),
  ).load('packages/dabbler_design_system/$key');
  expect(data.lengthInBytes, greaterThan(0), reason: key);
}
