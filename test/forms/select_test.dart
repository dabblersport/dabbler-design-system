import 'dart:io';

import 'package:dabbler_design_system/src/forms/field_shell.dart';
import 'package:dabbler_design_system/src/forms/picker_field.dart';
import 'package:dabbler_design_system/src/forms/select.dart';
import 'package:dabbler_design_system/src/forms/text_field.dart';
import 'package:dabbler_design_system/src/overlays/menu.dart';
import 'package:dabbler_design_system/src/overlays/sheet.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Above [DabblerMenu.sheetBreakpoint], so the option list is a popover.
const Size _wide = Size(800, 600);

/// Below it, so DS-700's own responsive rule turns the list into a sheet.
const Size _phone = Size(390, 780);

/// The width the field is laid out in, so `fullWidth` has something to match.
const double _fieldWidth = 320;

const List<DabblerSelectOption<String>> _sports = <DabblerSelectOption<String>>[
  DabblerSelectOption<String>(value: 'football', label: 'football'),
  DabblerSelectOption<String>(value: 'padel', label: 'padel'),
  DabblerSelectOption<String>(value: 'tennis', label: 'tennis', disabled: true),
];

DabblerColors _colours() =>
    DabblerColors.resolve(theme: DabblerTheme.main, brightness: Brightness.light);

Widget _host(
  Widget child, {
  Size size = _wide,
  TextDirection textDirection = TextDirection.ltr,
}) {
  // A MaterialApp, as in `test/forms/text_field_test.dart`: DS-600's field and
  // this one both embed Material's own TextField for its editing behaviour,
  // which needs MaterialLocalizations, and its Navigator supplies the Overlay
  // that DS-700's OverlayPortal needs.
  return MaterialApp(
    theme: ThemeData(
      extensions: <ThemeExtension<dynamic>>[_colours()],
    ),
    home: MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: textDirection,
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: _fieldWidth, child: child),
        ),
      ),
    ),
  );
}

/// A single-value select driven by its own state, as a call site would.
class _SelectHarness extends StatefulWidget {
  const _SelectHarness({
    this.initial,
    this.searchable = false,
    this.enabled = true,
    this.onChanged,
  });

  final String? initial;
  final bool searchable;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  State<_SelectHarness> createState() => _SelectHarnessState();
}

class _SelectHarnessState extends State<_SelectHarness> {
  late String? _value = widget.initial;

  @override
  Widget build(BuildContext context) => DabblerSelect<String>(
    label: 'sport',
    value: _value,
    enabled: widget.enabled,
    searchable: widget.searchable,
    options: _sports,
    onChanged: (String v) {
      setState(() => _value = v);
      widget.onChanged?.call(v);
    },
  );
}

/// The multi-value form, likewise self-driven.
class _MultiHarness extends StatefulWidget {
  const _MultiHarness();

  @override
  State<_MultiHarness> createState() => _MultiHarnessState();
}

class _MultiHarnessState extends State<_MultiHarness> {
  List<String> _values = <String>[];

  @override
  Widget build(BuildContext context) => DabblerSelect<String>.multiple(
    label: 'sport',
    values: _values,
    options: _sports,
    onChangedAll: (List<String> v) => setState(() => _values = v),
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byType(DabblerTextField).first);
  await tester.pumpAndSettle();
}

void main() {
  group('DabblerSelect — AC1: the closed state is DS-600, not a fork', () {
    testWidgets('renders one select-variant DabblerTextField and no second '
        'field shell', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const _SelectHarness(initial: 'padel')));

      final DabblerTextField field = tester.widget<DabblerTextField>(
        find.byType(DabblerTextField),
      );
      expect(field.variant, DabblerTextFieldVariant.select);
      expect(field.value, 'padel');
      expect(field.label, 'sport');
      // One shell in the tree: the one DS-600 draws.
      expect(find.byType(DabblerFieldShell), findsOneWidget);
    });

    testWidgets('an empty select shows the source placeholder',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const _SelectHarness()));

      expect(DabblerSelect.defaultPlaceholder, 'select');
      final DabblerTextField field = tester.widget<DabblerTextField>(
        find.byType(DabblerTextField),
      );
      expect(field.value, isEmpty);
      expect(field.placeholder, 'select');
    });

    testWidgets('open is handed to the shell, which owns the arrow and the '
        'border rule', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const _SelectHarness(initial: 'padel')));
      expect(
        tester.widget<DabblerTextField>(find.byType(DabblerTextField)).open,
        isFalse,
      );

      await _open(tester);

      expect(
        tester
            .widget<DabblerTextField>(find.byType(DabblerTextField).first)
            .open,
        isTrue,
      );
    });

    testWidgets('the source file restates no box geometry and no list '
        'keyboard', (WidgetTester tester) async {
      // The composition assertion the ticket asks for, made structurally: if
      // a future edit redraws the box or re-implements the roving focus, the
      // vocabulary of doing so appears here. Comments and dartdoc are stripped
      // first, so quoting the tokens in prose stays legal.
      final String code = File('lib/src/forms/select.dart')
          .readAsLinesSync()
          .where((String line) => !line.trimLeft().startsWith('//'))
          .join('\n');

      for (final String forbidden in <String>[
        // DS-600's geometry.
        'BoxDecoration',
        'Border.all',
        'DabblerRadius',
        'DabblerSurface',
        'touchTargetMin',
        // DS-700's keyboard and popover.
        'OverlayPortal',
        'LogicalKeyboardKey.home',
        'LogicalKeyboardKey.end',
        'LogicalKeyboardKey.escape',
        'typeAhead',
      ]) {
        expect(
          code,
          isNot(contains(forbidden)),
          reason: '$forbidden belongs to DS-600 or DS-700, not to Select',
        );
      }
    });
  });

  group('DabblerSelect — AC2: the dropdown is DS-700', () {
    testWidgets('the list is a DabblerMenuList, full-width and anchored to '
        'the field', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const _SelectHarness()));
      expect(find.byType(DabblerMenuList), findsNothing);

      await _open(tester);

      expect(find.byType(DabblerMenuList), findsOneWidget);
      final DabblerMenu menu = tester.widget<DabblerMenu>(
        find.byType(DabblerMenu),
      );
      expect(menu.fullWidth, isTrue);
      // `fullWidth` means the popover is the field's width, not the 200–320
      // popover range.
      expect(
        tester.getSize(find.byType(DabblerMenuList)).width,
        _fieldWidth,
      );
    });

    testWidgets('every option becomes a menu entry, disabled rows included',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const _SelectHarness(initial: 'padel')));
      await _open(tester);

      final DabblerMenuList list = tester.widget<DabblerMenuList>(
        find.byType(DabblerMenuList),
      );
      expect(list.items.length, _sports.length);
      expect(list.items.map((DabblerMenuEntry e) => e.label), <String>[
        'football',
        'padel',
        'tennis',
      ]);
      // `Menu.prompt.md`: a disabled row stays in the list.
      expect(list.items.last.disabled, isTrue);
      // The chosen row carries the tick.
      expect(list.items[1].selected, isTrue);
      expect(list.items[0].selected, isFalse);
    });

    testWidgets('the list is role=menu, which is what the design source says',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const _SelectHarness()));
      await _open(tester);

      // `fields.card.html:113` — *"the list is role="menu" with role="menuitem"
      // options"*. DS-700's own dartdoc suggests listbox; the source wins.
      expect(
        tester.widget<DabblerMenuList>(find.byType(DabblerMenuList)).role,
        DabblerMenuRole.menu,
      );
    });

    testWidgets('below 480px the list is a Sheet — inherited, not reimplemented',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const _SelectHarness(), size: _phone),
      );
      await _open(tester);

      expect(find.byType(DabblerSheet), findsOneWidget);
      expect(find.byType(DabblerMenuList), findsOneWidget);
    });

    testWidgets('choosing a row reports the value and closes',
        (WidgetTester tester) async {
      String? picked;
      await tester.pumpWidget(
        _host(_SelectHarness(onChanged: (String v) => picked = v)),
      );
      await _open(tester);

      await tester.tap(find.text('football'));
      await tester.pumpAndSettle();

      expect(picked, 'football');
      expect(find.byType(DabblerMenuList), findsNothing);
      expect(
        tester.widget<DabblerTextField>(find.byType(DabblerTextField)).value,
        'football',
      );
    });

    testWidgets('multiple keeps the list open and accumulates values',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const _MultiHarness()));
      await _open(tester);

      await tester.tap(find.text('football'));
      await tester.pumpAndSettle();
      // `closeOnSelect={!multiple}` — still open.
      expect(find.byType(DabblerMenuList), findsOneWidget);

      await tester.tap(find.text('padel'));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<DabblerTextField>(find.byType(DabblerTextField).first)
            .value,
        'football, padel',
      );

      // And a second tap on a chosen row removes it.
      await tester.tap(find.text('football'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DabblerTextField>(find.byType(DabblerTextField).first)
            .value,
        'padel',
      );
    });

    testWidgets('searchable adds a search field above the list and filters by '
        'label', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const _SelectHarness(searchable: true)),
      );
      await _open(tester);

      final Finder search = find.byWidgetPredicate(
        (Widget w) =>
            w is DabblerTextField &&
            w.variant == DabblerTextFieldVariant.search,
      );
      expect(search, findsOneWidget);

      await tester.enterText(search, 'ten');
      await tester.pumpAndSettle();

      final DabblerMenuList list = tester.widget<DabblerMenuList>(
        find.byType(DabblerMenuList),
      );
      expect(list.items.single.label, 'tennis');
    });

    testWidgets('a disabled select does not open', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const _SelectHarness(initial: 'padel', enabled: false)),
      );
      await _open(tester);

      expect(find.byType(DabblerMenuList), findsNothing);
    });
  });

  group('DabblerSelect — keyboard and announcement', () {
    testWidgets('Enter, Space and ArrowDown each open a focused field',
        (WidgetTester tester) async {
      for (final LogicalKeyboardKey key in <LogicalKeyboardKey>[
        LogicalKeyboardKey.enter,
        LogicalKeyboardKey.space,
        LogicalKeyboardKey.arrowDown,
      ]) {
        await tester.pumpWidget(_host(const _SelectHarness()));
        await tester.pumpAndSettle();

        final Element element = tester.element(find.byType(DabblerTextField));
        Focus.of(element).requestFocus();
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(key);
        await tester.pumpAndSettle();

        expect(
          find.byType(DabblerMenuList),
          findsOneWidget,
          reason: '$key should open the list',
        );
      }
    });

    testWidgets('Escape closes and returns focus to the field',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const _SelectHarness()));
      await _open(tester);
      expect(find.byType(DabblerMenuList), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(DabblerMenuList), findsNothing);
      final Element element = tester.element(find.byType(DabblerTextField));
      expect(Focus.of(element).hasFocus, isTrue);
      // The field is back in its focused paint state, so the next Tab
      // continues from here.
      expect(
        tester.widget<DabblerFieldShell>(find.byType(DabblerFieldShell)).focused,
        isTrue,
      );
    });

    testWidgets('the selected value is announced as the field button label',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const _SelectHarness(initial: 'padel')));

      // The shell is a button named by its label, and the chosen value is a
      // node inside it, so a screen reader reaches both.
      final SemanticsNode node = tester.getSemantics(
        find.byType(DabblerFieldShell),
      );
      final List<String> spoken = <String>[];
      void walk(SemanticsNode n) {
        spoken.add(n.label);
        n.visitChildren((SemanticsNode child) {
          walk(child);
          return true;
        });
      }

      walk(node);
      // The shell merges its descendants into one node, so the field is
      // announced as one string carrying both the name and the value.
      final String announced = spoken.join('\n');
      expect(announced, contains('sport'));
      expect(announced, contains('padel'));
      expect(node.flagsCollection.isButton, isTrue);
      expect(find.text('padel'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('RTL: the popover still matches the field, on the field',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const _SelectHarness(initial: 'padel'),
          textDirection: TextDirection.rtl,
        ),
      );
      await _open(tester);

      final Rect field = tester.getRect(find.byType(DabblerFieldShell).first);
      final Rect list = tester.getRect(find.byType(DabblerMenuList));
      expect(list.width, field.width);
      // Inline alignment in RTL is the end edge; DS-700 resolves it, and the
      // point here is that Select contributes no side of its own.
      expect(list.right, moreOrLessEquals(field.right, epsilon: 0.5));
    });

    testWidgets('multi-value display joins with ", ", which reads in both '
        'directions', (WidgetTester tester) async {
      expect(
        DabblerSelect.displayOf<String>(_sports, <String>['padel', 'tennis']),
        'padel, tennis',
      );
      // `hit ? hit.label : v` — an unknown value falls back to itself.
      expect(DabblerSelect.labelOf<String>(_sports, 'squash'), 'squash');
    });
  });

  group('DabblerPickerField', () {
    testWidgets('is a FieldShell with a typed input and one trailing button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerPickerField(label: 'Date', text: '12/03/2026')),
      );

      expect(find.byType(DabblerFieldShell), findsOneWidget);
      expect(find.byType(EditableText), findsOneWidget);
      expect(find.text('12/03/2026'), findsOneWidget);
      expect(find.byKey(DabblerPickerField.trailingButtonKey), findsOneWidget);
      expect(DabblerPickerFieldShell.defaultOpenSemanticsLabel, 'Open picker');
    });

    testWidgets('typing does not open the picker; the button does',
        (WidgetTester tester) async {
      final List<bool> opens = <bool>[];
      await tester.pumpWidget(
        _host(
          DabblerPickerField(
            label: 'Date',
            onOpenChanged: opens.add,
            child: const SizedBox(height: 40),
          ),
        ),
      );

      await tester.enterText(find.byType(EditableText), '12/03');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(EditableText));
      await tester.pumpAndSettle();
      // `PickerField.prompt.md`: no second way to open it.
      expect(opens, isEmpty);

      await tester.tap(find.byKey(DabblerPickerField.trailingButtonKey));
      await tester.pumpAndSettle();
      expect(opens, <bool>[true]);
    });

    testWidgets('committing fires on submit with the typed text',
        (WidgetTester tester) async {
      final List<String> committed = <String>[];
      await tester.pumpWidget(
        _host(DabblerPickerField(label: 'Time', onTextCommitted: committed.add)),
      );

      await tester.enterText(find.byType(EditableText), '6pm');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(committed, <String>['6pm']);
    });

    testWidgets('above the breakpoint the picker is DS-700\'s popover',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerPickerField(
            label: 'Date',
            open: true,
            child: Text('picker'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DabblerMenu), findsOneWidget);
      expect(find.text('picker'), findsOneWidget);
      expect(find.byType(DabblerSheet), findsNothing);
    });

    testWidgets('below it the picker is a Sheet at the source\'s own detent',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerPickerField(
            label: 'Date',
            open: true,
            child: Text('picker'),
          ),
          size: _phone,
        ),
      );
      await tester.pumpAndSettle();

      final DabblerSheet sheet = tester.widget<DabblerSheet>(
        find.byType(DabblerSheet),
      );
      expect(sheet.detents, DabblerPickerField.defaultDetents);
      expect(DabblerPickerField.defaultDetents, <double>[0.62]);
      expect(sheet.title, 'Date');
      expect(find.text('picker'), findsOneWidget);
    });

    testWidgets('a disabled field neither types nor opens',
        (WidgetTester tester) async {
      final List<bool> opens = <bool>[];
      await tester.pumpWidget(
        _host(
          DabblerPickerField(
            label: 'Date',
            enabled: false,
            onOpenChanged: opens.add,
          ),
        ),
      );

      await tester.tap(find.byKey(DabblerPickerField.trailingButtonKey));
      await tester.pumpAndSettle();

      expect(opens, isEmpty);
    });
  });
}
