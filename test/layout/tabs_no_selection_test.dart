import 'package:dabbler_design_system/src/layout/tabs.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const List<DabblerTabItem> _items = <DabblerTabItem>[
  DabblerTabItem(id: 'a', label: 'Alpha'),
  DabblerTabItem(id: 'b', label: 'Beta'),
  DabblerTabItem(id: 'c', label: 'Gamma'),
];

Widget _host(Widget child, {TextDirection dir = TextDirection.ltr}) =>
    MaterialApp(
      theme: ThemeData(
        extensions: <ThemeExtension<dynamic>>[
          DabblerColors.resolve(
            theme: DabblerTheme.main,
            brightness: Brightness.light,
          ),
        ],
      ),
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: dir,
          child: Material(child: SizedBox(width: 390, child: child)),
        ),
      ),
    );

bool _selected(WidgetTester t, String label) =>
    t
        .getSemantics(find.bySemanticsLabel(label))
        .getSemanticsData()
        .flagsCollection
        .isSelected
        .toBoolOrNull() ??
    false;

Finder get _indicator => find.descendant(
  of: find.byType(DabblerTabs),
  matching: find.byType(AnimatedPositionedDirectional),
);

void main() {
  for (final TextDirection dir in TextDirection.values) {
    group(dir.name, () {
      testWidgets('null + allowNoSelection: no tab selected, no indicator', (
        t,
      ) async {
        final SemanticsHandle h = t.ensureSemantics();
        await t.pumpWidget(
          _host(
            const DabblerTabs(items: _items, allowNoSelection: true),
            dir: dir,
          ),
        );
        await t.pump();
        expect(_indicator, findsNothing);
        for (final DabblerTabItem i in _items) {
          expect(_selected(t, i.label), isFalse, reason: i.label);
        }
        h.dispose();
      });

      testWidgets('default: null still selects the first (unchanged)', (
        t,
      ) async {
        final SemanticsHandle h = t.ensureSemantics();
        await t.pumpWidget(_host(const DabblerTabs(items: _items), dir: dir));
        await t.pump();
        expect(_indicator, findsOneWidget);
        expect(_selected(t, 'Alpha'), isTrue);
        h.dispose();
      });

      testWidgets('a given value behaves as before, unmatched -> first', (
        t,
      ) async {
        final SemanticsHandle h = t.ensureSemantics();
        await t.pumpWidget(
          _host(
            const DabblerTabs(
              items: _items,
              value: 'b',
              allowNoSelection: true,
            ),
            dir: dir,
          ),
        );
        await t.pump();
        expect(_selected(t, 'Beta'), isTrue);
        expect(_indicator, findsOneWidget);
        await t.pumpWidget(
          _host(
            const DabblerTabs(
              items: _items,
              value: 'zzz',
              allowNoSelection: true,
            ),
            dir: dir,
          ),
        );
        await t.pump();
        expect(_selected(t, 'Alpha'), isTrue);
        h.dispose();
      });

      testWidgets('selected -> null clears the indicator', (t) async {
        await t.pumpWidget(
          _host(
            const DabblerTabs(
              items: _items,
              value: 'c',
              allowNoSelection: true,
            ),
            dir: dir,
          ),
        );
        await t.pump();
        expect(_indicator, findsOneWidget);
        await t.pumpWidget(
          _host(
            const DabblerTabs(items: _items, allowNoSelection: true),
            dir: dir,
          ),
        );
        await t.pump();
        expect(_indicator, findsNothing);
      });
    });
  }

  testWidgets('segmented with nothing selected still renders all inactive', (
    t,
  ) async {
    final SemanticsHandle h = t.ensureSemantics();
    await t.pumpWidget(
      _host(
        const DabblerTabs(
          items: _items,
          variant: DabblerTabsVariant.segmented,
          allowNoSelection: true,
        ),
      ),
    );
    await t.pump();
    for (final DabblerTabItem i in _items) {
      expect(_selected(t, i.label), isFalse);
    }
    h.dispose();
  });

  testWidgets('tap and keyboard select from nothing', (t) async {
    final List<String> got = <String>[];
    await t.pumpWidget(
      _host(
        DabblerTabs(items: _items, allowNoSelection: true, onChanged: got.add),
      ),
    );
    await t.pump();
    await t.tap(find.text('Gamma'));
    expect(got, <String>['c']);
    // First tab is the tab stop when nothing is selected.
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(got.last, 'a');
    await t.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    expect(got.last, 'c');
  });
}
