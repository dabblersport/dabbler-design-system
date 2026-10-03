import 'package:dabbler_design_system/src/surfaces/avatar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// KAN-409 item 1 — DabblerAvatar's image-URL form.
///
/// No real network: the flutter_test binding installs an HttpOverrides whose
/// every request answers HTTP 400, which is exactly the failing-image path.

const Key _seedKey = ValueKey<String>('seed-portrait');

class _StubPortrait extends DabblerAvatarPortraitBuilder {
  const _StubPortrait();

  @override
  Widget build(
    BuildContext context, {
    required String seed,
    required double diameter,
  }) => SizedBox.square(key: _seedKey, dimension: diameter);
}

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    MaterialApp(
      theme: ThemeData(
        extensions: <ThemeExtension<dynamic>>[
          DabblerColors.resolve(
            theme: DabblerTheme.main,
            brightness: Brightness.light,
          ),
        ],
      ),
      home: Directionality(
        textDirection: direction,
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    );

void main() {
  setUp(() => DabblerAvatar.portrait = const _StubPortrait());
  tearDown(() => DabblerAvatar.portrait = const DabblerRandomAvatarPortrait());

  testWidgets('null URL draws the seed portrait and no Image', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const DabblerAvatar(seed: 'a')));
    expect(find.byKey(_seedKey), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('empty / blank URL draws the seed portrait and no Image', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(const DabblerAvatar(seed: 'a', imageUrl: '  ')),
    );
    expect(find.byKey(_seedKey), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('while loading, the seed portrait stands in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DabblerAvatar(
          seed: 'a',
          imageUrl: 'https://example.invalid/a.png',
        ),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.byKey(_seedKey), findsOneWidget);
  });

  testWidgets(
    'a failing image falls back to the seed portrait (errorBuilder)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerAvatar(
            seed: 'a',
            size: DabblerAvatarSize.lg,
            imageUrl: 'https://example.invalid/broken.png',
          ),
        ),
      );
      // Let the mocked HTTP 400 resolve outside the fake-async zone.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byKey(_seedKey), findsOneWidget);
      // Geometry identical to the seed form.
      expect(tester.getSize(find.byType(DabblerAvatar)), const Size.square(64));
    },
  );

  testWidgets('RTL: the image form keeps the seed geometry and badge corner', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DabblerAvatar(
          seed: 'a',
          imageUrl: 'https://example.invalid/a.png',
          badge: Text('1'),
        ),
        direction: TextDirection.rtl,
      ),
    );
    final Rect avatar = tester.getRect(find.byType(DabblerAvatar));
    expect(avatar.size, const Size.square(48));
    final Rect badge = tester.getRect(find.text('1'));
    // Badge sits on the bottom-START (left) corner under RTL.
    expect(badge.center.dx, lessThan(avatar.center.dx));
  });
}
