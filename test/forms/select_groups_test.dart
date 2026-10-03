import 'package:dabbler_design_system/src/forms/select.dart';
import 'package:dabbler_design_system/src/forms/text_field.dart';
import 'package:dabbler_design_system/src/overlays/menu.dart';
import 'package:dabbler_design_system/src/overlays/sheet.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// DS gaps 6 item 9 — option groups and the options-sheet title.
const Size _wide = Size(800, 600);
const Size _phone = Size(390, 780);

const List<DabblerSelectGroup<String>> _groups = <DabblerSelectGroup<String>>[
  DabblerSelectGroup<String>(
    label: 'Racket',
    options: <DabblerSelectOption<String>>[
      DabblerSelectOption<String>(value: 'padel', label: 'padel'),
      DabblerSelectOption<String>(value: 'tennis', label: 'tennis'),
    ],
  ),
  DabblerSelectGroup<String>(
    label: 'Team',
    options: <DabblerSelectOption<String>>[
      DabblerSelectOption<String>(value: 'football', label: 'football'),
    ],
  ),
];

Widget _host(
  Widget child, {
  Size size = _wide,
  TextDirection direction = TextDirection.ltr,
}) => MaterialApp(
  theme: ThemeData(
    extensions: <ThemeExtension<dynamic>>[
      DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      ),
    ],
  ),
  home: MediaQuery(
    data: MediaQueryData(size: size),
    child: Directionality(
      textDirection: direction,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: 320, child: child),
      ),
    ),
  ),
);

class _Single extends StatefulWidget {
  const _Single({this.sheetTitle, this.searchable = false});
  final String? sheetTitle;
  final bool searchable;
  @override
  State<_Single> createState() => _SingleState();
}

class _SingleState extends State<_Single> {
  String? v;
  @override
  Widget build(BuildContext context) => DabblerSelect<String>(
    label: 'sport',
    sheetTitle: widget.sheetTitle,
    searchable: widget.searchable,
    groups: _groups,
    value: v,
    onChanged: (String n) => setState(() => v = n),
  );
}

class _Multi extends StatefulWidget {
  const _Multi();
  @override
  State<_Multi> createState() => _MultiState();
}

class _MultiState extends State<_Multi> {
  List<String> v = <String>[];
  @override
  Widget build(BuildContext context) => DabblerSelect<String>.multiple(
    label: 'sports',
    sheetTitle: 'Choose sports',
    groups: _groups,
    values: v,
    onChangedAll: (List<String> n) => setState(() => v = n),
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byType(DabblerTextField).first);
  await tester.pumpAndSettle();
}

void main() {
  for (final TextDirection direction in TextDirection.values) {
    group('DabblerSelect groups ($direction)', () {
      testWidgets('each group is a heading followed by its options', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_host(const _Single(), direction: direction));
        await _open(tester);
        final DabblerMenuList list = tester.widget<DabblerMenuList>(
          find.byType(DabblerMenuList),
        );
        expect(
          list.items.map((DabblerMenuEntry e) => e.toString()).toList(),
          <String>[
            'DabblerMenuEntry.heading(Racket)',
            'DabblerMenuEntry(padel)',
            'DabblerMenuEntry(tennis)',
            'DabblerMenuEntry.heading(Team)',
            'DabblerMenuEntry(football)',
          ],
        );
        expect(list.items.first.isActivatable, isFalse);
        expect(find.byType(DabblerMenuHeading), findsNWidgets(2));
      });

      testWidgets('a heading is not selectable and is announced as a header', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        await tester.pumpWidget(_host(const _Single(), direction: direction));
        await _open(tester);
        await tester.tap(find.text('Racket'));
        await tester.pumpAndSettle();
        // Still open, nothing chosen.
        expect(find.byType(DabblerMenuList), findsOneWidget);
        expect(
          tester.widget<DabblerTextField>(find.byType(DabblerTextField)).value,
          '',
        );
        expect(
          tester.getSemantics(find.byType(DabblerMenuHeading).first),
          matchesSemantics(label: 'Racket', isHeader: true),
        );
        handle.dispose();
      });

      testWidgets('arrow keys skip the headings', (WidgetTester tester) async {
        await tester.pumpWidget(_host(const _Single(), direction: direction));
        await _open(tester);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(
          tester.widget<DabblerTextField>(find.byType(DabblerTextField)).value,
          'football',
        );
      });

      testWidgets('choosing a grouped option shows its label', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_host(const _Single(), direction: direction));
        await _open(tester);
        await tester.tap(find.text('tennis'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<DabblerTextField>(find.byType(DabblerTextField)).value,
          'tennis',
        );
      });

      testWidgets('below 480px the sheet carries sheetTitle', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(
            const _Single(sheetTitle: 'Pick a sport'),
            size: _phone,
            direction: direction,
          ),
        );
        await _open(tester);
        expect(
          tester.widget<DabblerSheet>(find.byType(DabblerSheet)).title,
          'Pick a sport',
        );
        expect(find.text('Pick a sport'), findsOneWidget);
      });

      testWidgets('multiple: groups work and the sheet title is used', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(const _Multi(), size: _phone, direction: direction),
        );
        await _open(tester);
        expect(find.text('Choose sports'), findsOneWidget);
        await tester.tap(find.text('padel'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('football'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<DabblerTextField>(find.byType(DabblerTextField).first)
              .value,
          'padel, football',
        );
      });
    });
  }

  testWidgets('without sheetTitle the sheet keeps the label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const _Single(), size: _phone));
    await _open(tester);
    expect(
      tester.widget<DabblerSheet>(find.byType(DabblerSheet)).title,
      'sport',
    );
  });

  testWidgets('search drops a group whose options are all filtered out', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const _Single(searchable: true)));
    await _open(tester);
    await tester.enterText(find.byType(EditableText).last, 'foot');
    await tester.pumpAndSettle();
    final DabblerMenuList list = tester.widget<DabblerMenuList>(
      find.byType(DabblerMenuList),
    );
    expect(
      list.items.map((DabblerMenuEntry e) => e.toString()).toList(),
      <String>['DabblerMenuEntry.heading(Team)', 'DabblerMenuEntry(football)'],
    );
  });
}
