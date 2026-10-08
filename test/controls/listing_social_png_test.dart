import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';

/// Evidence renders of [DabblerListingSocial] (written to build/png, never
/// committed): the action row of a game card with the group in its trailing
/// slot, and the four states on the card surface, light and dark, LTR and RTL.
Widget _states(DabblerColors c) {
  Widget row(Widget w) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: DabblerSpacing.space5),
    child: Align(alignment: AlignmentDirectional.centerEnd, child: w),
  );
  return DecoratedBox(
    decoration: BoxDecoration(color: c.surfaceCard),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: DabblerSpacing.space3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          row(
            DabblerListingSocial(
              favourited: false,
              onFavourite: () {},
              favouriteLabel: 'Add to favourites',
              favouriteCount: '14',
              onShare: () {},
              shareLabel: 'Share',
              shareCount: '6',
            ),
          ),
          row(
            DabblerListingSocial(
              favourited: true,
              onFavourite: () {},
              favouriteLabel: 'Remove from favourites',
              favouriteCount: '15',
              onShare: () {},
              shareLabel: 'Share',
              shareCount: '6',
            ),
          ),
          row(
            DabblerListingSocial(
              favourited: true,
              onFavourite: () {},
              favouriteLabel: 'Remove from favourites',
              onShare: () {},
              shareLabel: 'Share',
            ),
          ),
          row(
            DabblerListingSocial(
              favourited: false,
              onFavourite: () {},
              favouriteLabel: 'Add to favourites',
              onShare: () {},
              shareLabel: 'Share',
            ),
          ),
        ],
      ),
    ),
  );
}

void main() {
  for (final Brightness b in Brightness.values) {
    for (final TextDirection d in TextDirection.values) {
      final String name =
          '${b == Brightness.dark ? 'dark' : 'light'}_${d == TextDirection.rtl ? 'rtl' : 'ltr'}';
      testWidgets('render $name', (WidgetTester tester) async {
        final DabblerColors c = DabblerColors.resolve(
          theme: DabblerTheme.main,
          brightness: b,
        );
        await renderPng(
          tester,
          SizedBox(
            width: 357,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: DabblerSpacing.space5,
              children: <Widget>[
                DabblerCardGame(
                  title: 'Tuesday 5-a-side',
                  action: DabblerButton(label: 'Join game', onPressed: () {}),
                  trailing: DabblerListingSocial(
                    favourited: true,
                    onFavourite: () {},
                    favouriteLabel: 'Remove from favourites',
                    favouriteCount: '15',
                    onShare: () {},
                    shareLabel: 'Share',
                    shareCount: '6',
                  ),
                ),
                _states(c),
              ],
            ),
          ),
          name: 'listing_social_$name',
          size: const Size(393, 520),
          direction: d,
          brightness: b,
          alignment: Alignment.center,
        );
      });
    }
  }
}
