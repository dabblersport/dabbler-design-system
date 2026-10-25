// KAN-642: the post's vibe is a pill in the sport/place pill row, same style.
import 'package:dabbler_design_system/src/feed/post_row.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 360,
              child: SingleChildScrollView(child: child),
            ),
          ),
        ),
      ),
    );

DabblerPostRow _row({String? sport, String? placeTag, String? vibe}) =>
    DabblerPostRow(
      name: 'Suraj Mehta',
      time: '2h',
      place: 'Dubai',
      segments: const <DabblerPostSegment>[
        DabblerPostSegment('Anyone playing?'),
      ],
      sportLabel: sport,
      placeTagLabel: placeTag,
      vibeTagLabel: vibe,
      likes: 0,
      replies: 0,
    );

void main() {
  testWidgets(
    'the vibe pill is first in the same row, then sport, then place',
    (tester) async {
      await tester.pumpWidget(
        _host(_row(sport: 'Cricket', placeTag: 'Al Wasl', vibe: 'Chill')),
      );
      final sport = tester.getRect(find.text('Cricket'));
      final place = tester.getRect(find.text('Al Wasl'));
      final vibe = tester.getRect(find.text('Chill'));
      expect((sport.center.dy - vibe.center.dy).abs(), lessThan(2));
      expect(sport.left, greaterThan(vibe.right));
      expect(place.left, greaterThan(sport.right));
      expect(
        tester.widget<Text>(find.text('Chill')).style,
        tester.widget<Text>(find.text('Cricket')).style,
      );
    },
  );

  testWidgets('the vibe pill alone, and blank draws none', (tester) async {
    await tester.pumpWidget(_host(_row(vibe: 'Chill')));
    expect(find.text('Chill'), findsOneWidget);
    await tester.pumpWidget(_host(_row(sport: 'Cricket', vibe: '  ')));
    expect(find.text('Cricket'), findsOneWidget);
    expect(find.text('Chill'), findsNothing);
  });
}
