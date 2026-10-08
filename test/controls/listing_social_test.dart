import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

Widget _wrap(
  Widget child, {
  TextDirection d = TextDirection.ltr,
  Brightness b = Brightness.light,
}) => host(
  Shortcuts(
    shortcuts: WidgetsApp.defaultShortcuts,
    child: Align(alignment: AlignmentDirectional.centerStart, child: child),
  ),
  direction: d,
  brightness: b,
);

DabblerListingSocial _social({
  bool on = false,
  String? fav = '9',
  String? share = '4',
  VoidCallback? onFav,
  VoidCallback? onShare,
}) => DabblerListingSocial(
  favourited: on,
  onFavourite: onFav ?? () {},
  favouriteLabel: on ? 'Remove from favourites' : 'Add to favourites',
  favouriteCount: fav,
  onShare: onShare ?? () {},
  shareLabel: 'Share',
  shareCount: share,
);

List<DabblerIcon> _icons(WidgetTester t) =>
    t.widgetList<DabblerIcon>(find.byType(DabblerIcon)).toList();

void main() {
  for (final Brightness b in Brightness.values) {
    for (final TextDirection d in TextDirection.values) {
      group('DabblerListingSocial $b $d', () {
        testWidgets('off: linear secondary heart, share in the same ink', (
          tester,
        ) async {
          await tester.pumpWidget(_wrap(_social(), d: d, b: b));
          final DabblerColors c = testColors(brightness: b);
          final icons = _icons(tester);
          expect(icons.length, 2);
          expect(icons[0].weight, DabblerIconWeight.linear);
          expect(icons[0].size, 20);
          expect(icons[0].color, c.textSecondary);
          expect(icons[1].color, c.textSecondary);
          expect(find.text('9'), findsOneWidget);
          expect(find.text('4'), findsOneWidget);
        });

        testWidgets('on: a bold error heart and count in the same colour', (
          tester,
        ) async {
          await tester.pumpWidget(_wrap(_social(on: true), d: d, b: b));
          final DabblerColors c = testColors(brightness: b);
          final icons = _icons(tester);
          expect(icons[0].weight, DabblerIconWeight.bold);
          expect(icons[0].color, c.error.base);
          expect(
            tester.widget<Text>(find.text('9')).style!.color,
            c.error.base,
          );
          // Share does not take the heart's state.
          expect(icons[1].color, c.textSecondary);
        });

        testWidgets('the heart comes first in reading order', (tester) async {
          await tester.pumpWidget(_wrap(_social(), d: d, b: b));
          final heart = tester.getCenter(find.text('9'));
          final share = tester.getCenter(find.text('4'));
          expect(
            d == TextDirection.ltr ? heart.dx < share.dx : heart.dx > share.dx,
            isTrue,
          );
        });

        testWidgets('a null count hides the number, not the glyph', (
          tester,
        ) async {
          await tester.pumpWidget(
            _wrap(_social(fav: null, share: null), d: d, b: b),
          );
          expect(_icons(tester).length, 2);
          expect(find.byType(Text), findsNothing);
        });
      });
    }
  }

  testWidgets('the metrics are the design\'s', (tester) async {
    expect(DabblerListingSocial.glyphSize, 20);
    expect(DabblerListingSocial.itemGap, 6);
    expect(DabblerListingSocial.groupGap, 15);
    await tester.pumpWidget(_wrap(_social()));
    final heart = tester.getTopLeft(find.byType(DabblerIcon).first);
    final countText = tester.getTopLeft(find.text('9'));
    expect(countText.dx - heart.dx, 20 + 6);
  });

  testWidgets('taps reach the right callback', (tester) async {
    int fav = 0;
    int share = 0;
    await tester.pumpWidget(
      _wrap(_social(onFav: () => fav++, onShare: () => share++)),
    );
    await tester.tap(find.byType(DabblerIcon).first);
    expect(fav, 1);
    expect(share, 0);
    await tester.tap(find.byType(DabblerIcon).last);
    expect(share, 1);
  });

  testWidgets('each item has a 45 hit area around a smaller glyph', (
    tester,
  ) async {
    int fav = 0;
    await tester.pumpWidget(
      _wrap(
        // Room around the group, so the margin is inside the host.
        Padding(
          padding: const EdgeInsets.all(DabblerSpacing.space8),
          child: _social(fav: null, share: null, onFav: () => fav++),
        ),
      ),
    );
    final Rect glyph = tester.getRect(find.byType(DabblerIcon).first);
    final double margin =
        (DabblerSizing.touchTargetMin - DabblerListingSocial.glyphSize) / 2;
    // Just inside the 45 square above and below the 20 glyph.
    await tester.tapAt(
      glyph.center - Offset(0, glyph.height / 2 + margin - 0.5),
    );
    await tester.tapAt(
      glyph.center + Offset(0, glyph.height / 2 + margin - 0.5),
    );
    expect(fav, 2);
    // Outside the 45 square nothing fires.
    await tester.tapAt(glyph.center - Offset(0, glyph.height / 2 + margin + 2));
    expect(fav, 2);
    expect(
      tester.getSize(find.byType(DabblerListingSocial)).height,
      DabblerSizing.touchTargetMin,
    );
  });

  testWidgets('semantics: toggle state and labels', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(_social(on: true)));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Remove from favourites')),
      isSemantics(
        label: 'Remove from favourites',
        isButton: true,
        isEnabled: true,
        hasEnabledState: true,
        hasToggledState: true,
        isToggled: true,
        hasTapAction: true,
      ),
    );
    expect(find.bySemanticsLabel('Share'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('null callbacks disable the items', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(
        const DabblerListingSocial(
          favourited: false,
          onFavourite: null,
          favouriteLabel: 'Add to favourites',
          onShare: null,
          shareLabel: 'Share',
        ),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Share')),
      isSemantics(
        label: 'Share',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
      ),
    );
    handle.dispose();
  });

  testWidgets('fits the trailing slot of the game card, LTR and RTL', (
    tester,
  ) async {
    for (final d in TextDirection.values) {
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 393 - 36,
            child: DabblerCardGame(
              title: 'Tuesday 5-a-side',
              action: DabblerButton(label: 'Join game', onPressed: () {}),
              trailing: _social(),
            ),
          ),
          direction: d,
        ),
      );
      expect(tester.takeException(), isNull);
      final card = tester.getRect(find.byType(DabblerCardGame));
      final social = tester.getRect(find.byType(DabblerListingSocial));
      expect(card.contains(social.center), isTrue);
      // At the inline end of the card.
      expect(
        d == TextDirection.ltr
            ? social.center.dx > card.center.dx
            : social.center.dx < card.center.dx,
        isTrue,
      );
    }
  });
}
