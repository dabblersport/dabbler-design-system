// KAN-592: the place the post is ABOUT is a pill beside the sport pill, in the
// same style; the header `place` (where the author posted from) is separate.
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

DabblerPostRow _row({
  String? sport,
  String? placeTag,
  String place = 'Dubai',
}) => DabblerPostRow(
  name: 'Suraj Mehta',
  time: '2h',
  place: place,
  segments: const <DabblerPostSegment>[DabblerPostSegment('Anyone playing?')],
  sportLabel: sport,
  placeTagLabel: placeTag,
  likes: 0,
  replies: 0,
);

void main() {
  group('PostRow place tag pill (KAN-592)', () {
    testWidgets('tagged venue sits beside the sport pill; header stays the '
        'posting city', (tester) async {
      await tester.pumpWidget(
        _host(_row(sport: 'Cricket', placeTag: 'Al Wasl')),
      );
      expect(find.text('Al Wasl'), findsOneWidget);
      expect(find.text('Cricket'), findsOneWidget);
      expect(find.text('Dubai'), findsOneWidget);
      final sport = tester.getRect(find.text('Cricket'));
      final tag = tester.getRect(find.text('Al Wasl'));
      expect((sport.center.dy - tag.center.dy).abs(), lessThan(2));
      expect(tag.left, greaterThan(sport.right));
    });

    testWidgets('the pill alone, without a sport', (tester) async {
      await tester.pumpWidget(_host(_row(placeTag: 'Al Wasl Road')));
      expect(find.text('Al Wasl Road'), findsOneWidget);
    });

    testWidgets('blank draws no pill', (tester) async {
      await tester.pumpWidget(_host(_row(sport: 'Cricket', placeTag: '   ')));
      expect(find.text('Cricket'), findsOneWidget);
      expect(find.text('   '), findsNothing);
    });

    testWidgets('RTL puts the tag after the sport pill, on its left', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          _row(sport: 'كريكيت', placeTag: 'ملعب زايد'),
          direction: TextDirection.rtl,
        ),
      );
      final sport = tester.getRect(find.text('كريكيت'));
      final tag = tester.getRect(find.text('ملعب زايد'));
      expect(tag.right, lessThan(sport.left));
    });

    testWidgets('a long address ellipsizes instead of overflowing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          _row(
            sport: 'Cricket',
            placeTag: 'A very long street and building address ' * 4,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
