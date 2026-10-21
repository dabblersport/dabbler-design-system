// KAN-614: the Message info stat tiles read a word where it reads better than
// the count: "All" when every recipient is in the Seen / Delivered state,
// "Nobody" when the Not yet tile is empty.
import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(
  Widget child, {
  TextDirection dir = TextDirection.ltr,
  Brightness brightness = Brightness.light,
}) => MaterialApp(
  theme: ThemeData(
    brightness: brightness,
    extensions: <ThemeExtension<dynamic>>[
      DabblerColors.resolve(theme: DabblerTheme.main, brightness: brightness),
    ],
  ),
  home: Directionality(
    textDirection: dir,
    child: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 400, child: SingleChildScrollView(child: child)),
      ),
    ),
  ),
);

List<DabblerReceiptPerson> _people(int n, String prefix) =>
    <DabblerReceiptPerson>[
      for (int i = 0; i < n; i++) DabblerReceiptPerson(name: '$prefix$i'),
    ];

DabblerReceiptsSheet _sheet(
  int seen,
  int delivered,
  int notYet, {
  String lang = 'en',
  String? allLabel,
  String? nobodyLabel,
}) => DabblerReceiptsSheet(
  lang: lang,
  allLabel: allLabel,
  nobodyLabel: nobodyLabel,
  groups: <DabblerReceiptGroup>[
    DabblerReceiptGroup(
      state: DabblerDeliveryState.seen,
      people: _people(seen, 's'),
    ),
    DabblerReceiptGroup(
      state: DabblerDeliveryState.delivered,
      people: _people(delivered, 'd'),
    ),
    DabblerReceiptGroup(
      state: DabblerDeliveryState.sent,
      people: _people(notYet, 'n'),
    ),
  ],
);

String _tileText(WidgetTester tester, int i) {
  final Finder tile = find.byKey(DabblerReceiptsSheet.tileKeyAt(i));
  final Iterable<Text> texts = tester.widgetList<Text>(
    find.descendant(of: tile, matching: find.byType(Text)),
  );
  return texts.first.data!;
}

void _expectTiles(
  WidgetTester tester,
  List<String> values,
  List<String> labels,
) {
  for (int i = 0; i < 3; i++) {
    expect(_tileText(tester, i), values[i], reason: 'tile $i value');
    expect(find.bySemanticsLabel(labels[i]), findsOneWidget, reason: 'tile $i');
  }
}

void main() {
  group('DabblerReceiptsSheet stat tiles (KAN-614)', () {
    testWidgets('3 recipients, none read: 0 / 0 / 3', (tester) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(_host(_sheet(0, 0, 3)));
      _expectTiles(
        tester,
        <String>['0', '0', '3'],
        <String>['Seen: 0', 'Delivered: 0', 'Not yet: 3'],
      );
      h.dispose();
    });

    testWidgets('all seen: All / 0 / Nobody', (tester) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(_host(_sheet(3, 0, 0)));
      _expectTiles(
        tester,
        <String>['All', '0', 'Nobody'],
        <String>['Seen: All', 'Delivered: 0', 'Not yet: Nobody'],
      );
      h.dispose();
    });

    testWidgets('all delivered, none seen: 0 / All / Nobody', (tester) async {
      await tester.pumpWidget(_host(_sheet(0, 3, 0)));
      expect(_tileText(tester, 0), '0');
      expect(_tileText(tester, 1), 'All');
      expect(_tileText(tester, 2), 'Nobody');
    });

    testWidgets('mixed, 2 seen and 1 not yet: 2 / 0 / 1', (tester) async {
      await tester.pumpWidget(_host(_sheet(2, 0, 1)));
      expect(_tileText(tester, 0), '2');
      expect(_tileText(tester, 1), '0');
      expect(_tileText(tester, 2), '1');
    });

    testWidgets('single recipient seen: All / 0 / Nobody', (tester) async {
      await tester.pumpWidget(_host(_sheet(1, 0, 0)));
      expect(_tileText(tester, 0), 'All');
      expect(_tileText(tester, 1), '0');
      expect(_tileText(tester, 2), 'Nobody');
    });

    testWidgets('single recipient delivered only: 0 / All / Nobody', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_sheet(0, 1, 0)));
      expect(_tileText(tester, 0), '0');
      expect(_tileText(tester, 1), 'All');
      expect(_tileText(tester, 2), 'Nobody');
    });

    testWidgets('single recipient not yet: 0 / 0 / 1, never All', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_sheet(0, 0, 1)));
      expect(_tileText(tester, 0), '0');
      expect(_tileText(tester, 1), '0');
      expect(_tileText(tester, 2), '1');
    });

    testWidgets('no recipients: no All anywhere, Nobody on Not yet', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_sheet(0, 0, 0)));
      expect(_tileText(tester, 0), '0');
      expect(_tileText(tester, 1), '0');
      expect(_tileText(tester, 2), 'Nobody');
    });

    testWidgets('Arabic in RTL and dark: الجميع / لا أحد, no overflow', (
      tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          _sheet(3, 0, 0, lang: 'ar'),
          dir: TextDirection.rtl,
          brightness: Brightness.dark,
        ),
      );
      _expectTiles(
        tester,
        <String>['الجميع', '0', 'لا أحد'],
        <String>['شوهدت: الجميع', 'وصلت: 0', 'لم تصل: لا أحد'],
      );
      // Seen is the first tile, so it sits at the right in RTL.
      expect(
        tester.getCenter(find.byKey(DabblerReceiptsSheet.tileKeyAt(0))).dx,
        greaterThan(
          tester.getCenter(find.byKey(DabblerReceiptsSheet.tileKeyAt(2))).dx,
        ),
      );
      expect(tester.takeException(), isNull);
      h.dispose();
    });

    testWidgets('caller labels override the defaults', (tester) async {
      await tester.pumpWidget(
        _host(_sheet(3, 0, 0, allLabel: 'Everyone', nobodyLabel: 'No one')),
      );
      expect(_tileText(tester, 0), 'Everyone');
      expect(_tileText(tester, 2), 'No one');
    });
  });
}
