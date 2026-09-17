import 'package:dabbler_design_system/src/forms/date_field.dart';
import 'package:dabbler_design_system/src/forms/picker_field.dart';
import 'package:dabbler_design_system/src/forms/field_shell.dart';
import 'package:dabbler_design_system/src/surfaces/surface.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/cupertino.dart' show CupertinoLocalizations, DefaultCupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors `test/forms/text_field_test.dart`'s host width so edge assertions
/// have a fixed frame.
const double hostWidth = 320;

DabblerColors _colors({Brightness brightness = Brightness.light}) =>
    DabblerColors.resolve(theme: DabblerTheme.main, brightness: brightness);

/// The host.
///
/// [locale] is the point of AC2's test: an explicit `ar` locale with
/// [TextDirection.rtl] is the configuration under which a locale-aware
/// formatter would produce `٠٥/٠٩/٢٠٢٦`.
Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const <Locale>[Locale('en'), Locale('ar')],
    localizationsDelegates: const <LocalizationsDelegate<Object>>[
      _AnyLocaleMaterialLocalizations(),
      _AnyLocaleCupertinoLocalizations(),
      DefaultWidgetsLocalizations.delegate,
    ],
    theme: ThemeData(
      extensions: <ThemeExtension<dynamic>>[_colors()],
    ),
    home: Directionality(
      textDirection: direction,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: hostWidth, child: child),
      ),
    ),
  );
}

DabblerSurface _box(WidgetTester tester) => tester.widget<DabblerSurface>(
      find
          .descendant(
            of: find.byType(DabblerFieldShell),
            matching: find.byType(DabblerSurface),
          )
          .first,
    );

/// Every Arabic-Indic and extended Arabic-Indic digit, for the containment
/// assertions AC2 turns on.
const String easternDigits = '٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹';

/// Supplies [DefaultMaterialLocalizations] for **any** locale.
///
/// `flutter_localizations` is not a dependency of this package and adding one
/// is a `cto` hand-off, so Material's own English delegate — which
/// [TextField] requires an ancestor for — is declared as supporting `ar` too.
/// That is sound for this test and is in fact the sharper harness: it means
/// the ambient locale really is `ar` while nothing in the tree carries an
/// Arabic number formatter, so a `0`-`9` result is the field's own doing.
class _AnyLocaleMaterialLocalizations
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _AnyLocaleMaterialLocalizations();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      DefaultMaterialLocalizations.load(locale);

  @override
  bool shouldReload(_AnyLocaleMaterialLocalizations old) => false;
}

/// The same, for [CupertinoLocalizations] — [MaterialApp] declares one and
/// warns loudly when the ambient locale is outside it.
class _AnyLocaleCupertinoLocalizations
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _AnyLocaleCupertinoLocalizations();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(_AnyLocaleCupertinoLocalizations old) => false;
}

void main() {
  group('DabblerDateFormat.format — DD/MM/YYYY (AC1)', () {
    test('zero-pads day and month, never the year', () {
      expect(DabblerDateFormat.format(DateTime(2026, 9, 5)), '05/09/2026');
      expect(DabblerDateFormat.format(DateTime(2026, 12, 31)), '31/12/2026');
      expect(DabblerDateFormat.format(DateTime(867, 1, 2)), '02/01/867');
    });

    test('null is the empty string, not a placeholder', () {
      expect(DabblerDateFormat.format(null), '');
    });

    test('a span joins on an en dash and drops an unset end', () {
      expect(
        DabblerDateFormat.formatSpan(
          DabblerDateSpan(start: DateTime(2026, 9, 5), end: DateTime(2026, 9, 12)),
        ),
        '05/09/2026 – 12/09/2026',
      );
      expect(
        DabblerDateFormat.formatSpan(
          DabblerDateSpan(start: DateTime(2026, 9, 5)),
        ),
        '05/09/2026',
      );
      expect(DabblerDateFormat.formatSpan(DabblerDateSpan.empty), '');
    });
  });

  group('DabblerDateFormat.parse — the source regexp (AC1)', () {
    test('accepts /, . and - separators and optional spaces', () {
      for (final String raw in <String>[
        '05/09/2026',
        '5/9/2026',
        '05.09.2026',
        '05-09-2026',
        ' 5 / 9 / 2026 ',
      ]) {
        expect(DabblerDateFormat.parse(raw), DateTime(2026, 9, 5), reason: raw);
      }
    });

    test('a two-digit year is 2000-based', () {
      expect(DabblerDateFormat.parse('05/09/26'), DateTime(2026, 9, 5));
      expect(DabblerDateFormat.parse('05/09/99'), DateTime(2099, 9, 5));
    });

    test('unparseable and rolled-over input is null, not a silent date', () {
      for (final String raw in <String>[
        '',
        'tomorrow',
        '2026-09-05',
        '05/09',
        '32/01/2026',
        '05/13/2026',
      ]) {
        expect(DabblerDateFormat.parse(raw), isNull, reason: raw);
      }
    });

    test('a range splits on en dash, em dash and a SPACED hyphen only', () {
      expect(
        DabblerDateFormat.parseSpan('05/09/2026 – 12/09/2026'),
        DabblerDateSpan(start: DateTime(2026, 9, 5), end: DateTime(2026, 9, 12)),
      );
      expect(
        DabblerDateFormat.parseSpan('05/09/2026 — 12/09/2026'),
        DabblerDateSpan(start: DateTime(2026, 9, 5), end: DateTime(2026, 9, 12)),
      );
      // The unspaced hyphen is a separator inside a single date, so it must
      // not split — `05-09-2026` is one date.
      expect(
        DabblerDateFormat.parseSpan('05-09-2026'),
        DabblerDateSpan(start: DateTime(2026, 9, 5)),
      );
    });

    test('bounds are inclusive at both ends', () {
      final DateTime min = DateTime(2026, 9, 1);
      final DateTime max = DateTime(2026, 9, 30);
      expect(DabblerDateFormat.inBounds(min, min: min, max: max), isTrue);
      expect(DabblerDateFormat.inBounds(max, min: min, max: max), isTrue);
      expect(
        DabblerDateFormat.inBounds(DateTime(2026, 8, 31), min: min, max: max),
        isFalse,
      );
      expect(
        DabblerDateFormat.inBounds(DateTime(2026, 10, 1), min: min, max: max),
        isFalse,
      );
    });
  });

  group('AC2 — Western Arabic numerals regardless of locale', () {
    test('format emits ASCII 0-9 and no Arabic-Indic digit', () {
      final String out = DabblerDateFormat.format(DateTime(2026, 9, 5));
      expect(out, '05/09/2026');
      for (final int rune in easternDigits.runes) {
        expect(out.contains(String.fromCharCode(rune)), isFalse);
      }
      expect(RegExp(r'^[0-9/]+$').hasMatch(out), isTrue);
    });

    test('parse folds Arabic-Indic and extended Arabic-Indic input', () {
      expect(DabblerDateFormat.parse('٠٥/٠٩/٢٠٢٦'), DateTime(2026, 9, 5));
      expect(DabblerDateFormat.parse('۰۵/۰۹/۲۰۲۶'), DateTime(2026, 9, 5));
    });

    testWidgets('renders 0-9 under an explicit ar locale in RTL', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerDateField(label: 'تاريخ المباراة', value: DateTime(2026, 9, 5)),
          direction: TextDirection.rtl,
          locale: const Locale('ar'),
        ),
      );

      final EditableText editable = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editable.controller.text, '05/09/2026');
      for (final int rune in easternDigits.runes) {
        expect(
          editable.controller.text.contains(String.fromCharCode(rune)),
          isFalse,
        );
      }
    });

    testWidgets('a typed Arabic-Indic date commits and re-renders as 0-9', (
      WidgetTester tester,
    ) async {
      DateTime? committed;
      await tester.pumpWidget(
        _host(
          DabblerDateField(
            label: 'تاريخ',
            onChanged: (DateTime? v) => committed = v,
          ),
          direction: TextDirection.rtl,
          locale: const Locale('ar'),
        ),
      );

      await tester.enterText(find.byType(EditableText), '٠٥/٠٩/٢٠٢٦');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(committed, DateTime(2026, 9, 5));
      expect(DabblerDateFormat.format(committed), '05/09/2026');
    });
  });

  group('AC1 — composes the one FieldShell, and does not fork it', () {
    testWidgets('paints exactly one DabblerFieldShell at --radius-xxl', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerDateField(label: 'game date')));

      expect(find.byType(DabblerFieldShell), findsOneWidget);
      expect(_box(tester).radius, DabblerRadius.xxl);
    });

    testWidgets('the box is never shorter than the 45 touch minimum', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerDateField()));
      expect(
        tester.getSize(find.byType(DabblerSurface).first).height,
        greaterThanOrEqualTo(DabblerSizing.touchTargetMin),
      );
    });

    testWidgets('the trailing picker button is a 45x45 target', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerDateField()));
      final Finder button = find.bySemanticsLabel(
        DabblerPickerFieldShell.defaultOpenSemanticsLabel,
      );
      expect(button, findsOneWidget);
      expect(
        tester.getSize(button),
        const Size(DabblerSizing.touchTargetMin, DabblerSizing.touchTargetMin),
      );
    });

    testWidgets('errorText drives the error border', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerDateField(errorText: 'pick a date')),
      );
      expect(
        _box(tester).borderColor,
        _colors().status(DabblerStatusTone.error).base,
      );
      expect(find.text('pick a date'), findsOneWidget);
    });

    testWidgets('helperText is replaced by errorText, never both', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerDateField(
            helperText: 'up to 14 days',
            errorText: 'pick a date',
          ),
        ),
      );
      expect(find.text('pick a date'), findsOneWidget);
      expect(find.text('up to 14 days'), findsNothing);
    });

    testWidgets('open holds the focus border while focus is in the picker', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerDateField()));
      expect(_box(tester).borderColor, isNot(_colors().focusRing));

      await tester.pumpWidget(_host(const DabblerDateField(open: true)));
      expect(_box(tester).borderColor, _colors().focusRing);
      expect(_box(tester).borderWidth, 2);
    });
  });

  group('the DS-806 seam', () {
    testWidgets('tapping the trailing button fires onOpenPicker', (
      WidgetTester tester,
    ) async {
      int opens = 0;
      await tester.pumpWidget(
        _host(DabblerDateField(onOpenPicker: () => opens++)),
      );
      await tester.tap(
        find.bySemanticsLabel(
          DabblerPickerFieldShell.defaultOpenSemanticsLabel,
        ),
      );
      expect(opens, 1);
    });

    testWidgets('a disabled field does not fire it', (
      WidgetTester tester,
    ) async {
      int opens = 0;
      await tester.pumpWidget(
        _host(
          DabblerDateField(enabled: false, onOpenPicker: () => opens++),
        ),
      );
      await tester.tap(
        find.bySemanticsLabel(
          DabblerPickerFieldShell.defaultOpenSemanticsLabel,
        ),
        warnIfMissed: false,
      );
      expect(opens, 0);
    });

    testWidgets('the button reports aria-expanded through Semantics', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerDateField(open: true)));
      final Finder button = find.bySemanticsLabel(
        DabblerPickerFieldShell.defaultCloseSemanticsLabel,
      );
      expect(button, findsOneWidget);
      expect(
        tester.getSemantics(button).flagsCollection.isExpanded.toBoolOrNull(),
        isTrue,
      );
    });

    testWidgets('a value pushed in from outside replaces the typed text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerDateField()));
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '',
      );

      // What DS-806 does when a day is tapped in its calendar: it reports the
      // date through onChanged, the owner rebuilds with a new value, and the
      // field re-renders it in its own format.
      await tester.pumpWidget(
        _host(DabblerDateField(value: DateTime(2026, 9, 5))),
      );
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '05/09/2026',
      );
    });
  });

  group('typed commit and revert', () {
    testWidgets('Enter commits a valid date', (WidgetTester tester) async {
      DateTime? committed;
      await tester.pumpWidget(
        _host(DabblerDateField(onChanged: (DateTime? v) => committed = v)),
      );
      await tester.enterText(find.byType(EditableText), '05/09/2026');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(committed, DateTime(2026, 9, 5));
    });

    testWidgets('unparseable text reverts to the current value', (
      WidgetTester tester,
    ) async {
      bool called = false;
      await tester.pumpWidget(
        _host(
          DabblerDateField(
            value: DateTime(2026, 9, 5),
            onChanged: (DateTime? v) => called = true,
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText), 'next tuesday');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(called, isFalse);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '05/09/2026',
      );
    });

    testWidgets('an out-of-bounds date reverts on both min and max', (
      WidgetTester tester,
    ) async {
      DateTime? committed;
      await tester.pumpWidget(
        _host(
          DabblerDateField(
            value: DateTime(2026, 9, 5),
            minimum: DateTime(2026, 9, 1),
            maximum: DateTime(2026, 9, 30),
            onChanged: (DateTime? v) => committed = v,
          ),
        ),
      );
      for (final String raw in <String>['31/08/2026', '01/10/2026']) {
        await tester.enterText(find.byType(EditableText), raw);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
        expect(committed, isNull, reason: raw);
      }
    });

    testWidgets('emptying the field commits null', (WidgetTester tester) async {
      bool cleared = false;
      await tester.pumpWidget(
        _host(
          DabblerDateField(
            value: DateTime(2026, 9, 5),
            onChanged: (DateTime? v) => cleared = v == null,
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(cleared, isTrue);
    });

    testWidgets('losing focus commits, exactly as Enter does', (
      WidgetTester tester,
    ) async {
      DateTime? committed;
      await tester.pumpWidget(
        _host(DabblerDateField(onChanged: (DateTime? v) => committed = v)),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '12/09/2026');
      // Blur.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(committed, DateTime(2026, 9, 12));
    });

    testWidgets('a range typed backwards is reordered, not rejected', (
      WidgetTester tester,
    ) async {
      DabblerDateSpan? committed;
      await tester.pumpWidget(
        _host(
          DabblerDateField.range(
            onSpanChanged: (DabblerDateSpan v) => committed = v,
          ),
        ),
      );
      await tester.enterText(
        find.byType(EditableText),
        '12/09/2026 – 05/09/2026',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(
        committed,
        DabblerDateSpan(start: DateTime(2026, 9, 5), end: DateTime(2026, 9, 12)),
      );
    });

    testWidgets('the range placeholder is the doubled form', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerDateField.range()));
      expect(find.text(DabblerDateFormat.rangePlaceholder), findsOneWidget);
    });
  });

  group('RTL', () {
    testWidgets('the value keeps logical order under Directionality.rtl', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerDateField(label: 'تاريخ', value: DateTime(2026, 9, 5)),
          direction: TextDirection.rtl,
          locale: const Locale('ar'),
        ),
      );

      final EditableText editable = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      // The classic bug: `/` is bidi-neutral, so an unpinned run renders as
      // `2026/09/05`. The editable is pinned LTR so the day stays first.
      expect(editable.textDirection, TextDirection.ltr);
      expect(editable.controller.text, '05/09/2026');
      expect(editable.textAlign, TextAlign.right);
    });

    testWidgets('the trailing button sits at the inline end in both scripts', (
      WidgetTester tester,
    ) async {
      final Finder button = find.bySemanticsLabel(
        DabblerPickerFieldShell.defaultOpenSemanticsLabel,
      );

      await tester.pumpWidget(_host(const DabblerDateField()));
      expect(
        tester.getCenter(button).dx,
        greaterThan(tester.getCenter(find.byType(DabblerSurface).first).dx),
      );

      await tester.pumpWidget(
        _host(const DabblerDateField(), direction: TextDirection.rtl),
      );
      expect(
        tester.getCenter(button).dx,
        lessThan(tester.getCenter(find.byType(DabblerSurface).first).dx),
      );
    });
  });
}
