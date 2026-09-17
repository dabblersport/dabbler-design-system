import 'package:dabbler_design_system/src/forms/picker_field.dart';
import 'package:dabbler_design_system/src/forms/field_shell.dart';
import 'package:dabbler_design_system/src/forms/time_field.dart';
import 'package:dabbler_design_system/src/surfaces/surface.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/cupertino.dart' show CupertinoLocalizations, DefaultCupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const double hostWidth = 320;

DabblerColors _colors() =>
    DabblerColors.resolve(theme: DabblerTheme.main, brightness: Brightness.light);

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
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors()]),
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
  group('DabblerTimeFormat.format — H:MM AM (AC1)', () {
    test('the hour is not padded and the minute always is', () {
      expect(
        DabblerTimeFormat.format(const TimeOfDay(hour: 18, minute: 0)),
        '6:00 PM',
      );
      expect(
        DabblerTimeFormat.format(const TimeOfDay(hour: 9, minute: 5)),
        '9:05 AM',
      );
      expect(
        DabblerTimeFormat.format(const TimeOfDay(hour: 11, minute: 59)),
        '11:59 AM',
      );
    });

    test('midnight and noon are both 12, with the right meridiem', () {
      expect(
        DabblerTimeFormat.format(const TimeOfDay(hour: 0, minute: 30)),
        '12:30 AM',
      );
      expect(
        DabblerTimeFormat.format(const TimeOfDay(hour: 12, minute: 30)),
        '12:30 PM',
      );
    });

    test('null is the empty string', () {
      expect(DabblerTimeFormat.format(null), '');
    });
  });

  group('DabblerTimeFormat.parse — the source regexp (AC1)', () {
    test('accepts every form the specimen lists', () {
      expect(DabblerTimeFormat.parse('6pm'), const TimeOfDay(hour: 18, minute: 0));
      expect(
        DabblerTimeFormat.parse('6:00 PM'),
        const TimeOfDay(hour: 18, minute: 0),
      );
      expect(
        DabblerTimeFormat.parse('18:30'),
        const TimeOfDay(hour: 18, minute: 30),
      );
      expect(
        DabblerTimeFormat.parse('6.30 pm'),
        const TimeOfDay(hour: 18, minute: 30),
      );
      expect(
        DabblerTimeFormat.parse('09:15'),
        const TimeOfDay(hour: 9, minute: 15),
      );
    });

    test('a round trip through format is stable', () {
      for (final String raw in <String>['6pm', '6:00 PM', '18:30', '9:05 AM']) {
        final TimeOfDay? t = DabblerTimeFormat.parse(raw);
        expect(t, isNotNull, reason: raw);
        expect(DabblerTimeFormat.parse(DabblerTimeFormat.format(t)), t);
      }
    });

    test('unparseable input is null', () {
      for (final String raw in <String>[
        '',
        'noon',
        '25:00',
        '6:75 PM',
        '00:30',
      ]) {
        expect(DabblerTimeFormat.parse(raw), isNull, reason: raw);
      }
    });

    test('bounds are inclusive minutes-of-day', () {
      const TimeOfDay min = TimeOfDay(hour: 9, minute: 0);
      const TimeOfDay max = TimeOfDay(hour: 17, minute: 30);
      expect(DabblerTimeFormat.inBounds(min, min: min, max: max), isTrue);
      expect(DabblerTimeFormat.inBounds(max, min: min, max: max), isTrue);
      expect(
        DabblerTimeFormat.inBounds(
          const TimeOfDay(hour: 8, minute: 59),
          min: min,
          max: max,
        ),
        isFalse,
      );
      expect(
        DabblerTimeFormat.inBounds(
          const TimeOfDay(hour: 17, minute: 31),
          min: min,
          max: max,
        ),
        isFalse,
      );
    });
  });

  group('AC2 — Western Arabic numerals regardless of locale', () {
    test('format emits ASCII 0-9 and the literal AM/PM', () {
      final String out =
          DabblerTimeFormat.format(const TimeOfDay(hour: 18, minute: 0));
      expect(out, '6:00 PM');
      for (final int rune in easternDigits.runes) {
        expect(out.contains(String.fromCharCode(rune)), isFalse);
      }
      expect(RegExp(r'^[0-9]{1,2}:[0-9]{2} (AM|PM)$').hasMatch(out), isTrue);
    });

    test('parse folds Arabic-Indic and extended Arabic-Indic input', () {
      expect(
        DabblerTimeFormat.parse('٦:٣٠ PM'),
        const TimeOfDay(hour: 18, minute: 30),
      );
      expect(
        DabblerTimeFormat.parse('۱۸:۳۰'),
        const TimeOfDay(hour: 18, minute: 30),
      );
    });

    testWidgets('renders 0-9 under an explicit ar locale in RTL', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerTimeField(
            label: 'البداية',
            value: TimeOfDay(hour: 18, minute: 0),
          ),
          direction: TextDirection.rtl,
          locale: const Locale('ar'),
        ),
      );

      final EditableText editable =
          tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.controller.text, '6:00 PM');
      for (final int rune in easternDigits.runes) {
        expect(
          editable.controller.text.contains(String.fromCharCode(rune)),
          isFalse,
        );
      }
    });

    testWidgets('a typed Arabic-Indic time commits and re-renders as 0-9', (
      WidgetTester tester,
    ) async {
      TimeOfDay? committed;
      await tester.pumpWidget(
        _host(
          DabblerTimeField(onChanged: (TimeOfDay? v) => committed = v),
          direction: TextDirection.rtl,
          locale: const Locale('ar'),
        ),
      );
      await tester.enterText(find.byType(EditableText), '٦:٣٠ PM');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(committed, const TimeOfDay(hour: 18, minute: 30));
      expect(DabblerTimeFormat.format(committed), '6:30 PM');
    });
  });

  group('AC1 — the one FieldShell', () {
    testWidgets('one shell, --radius-xxl, >= 45 tall', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerTimeField(label: 'kick-off')));
      expect(find.byType(DabblerFieldShell), findsOneWidget);
      expect(_box(tester).radius, DabblerRadius.xxl);
      expect(
        tester.getSize(find.byType(DabblerSurface).first).height,
        greaterThanOrEqualTo(DabblerSizing.touchTargetMin),
      );
    });

    testWidgets('the clock button is a 45x45 target', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerTimeField()));
      final Finder button = find.bySemanticsLabel(
        DabblerPickerFieldShell.defaultOpenSemanticsLabel,
      );
      expect(
        tester.getSize(button),
        const Size(DabblerSizing.touchTargetMin, DabblerSizing.touchTargetMin),
      );
    });

    testWidgets('the default placeholder is H:MM AM', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerTimeField()));
      expect(find.text(DabblerTimeFormat.placeholder), findsOneWidget);
    });

    testWidgets('errorText drives the error border and replaces the helper', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerTimeField(
            helperText: 'same day',
            errorText: 'pick a time',
          ),
        ),
      );
      expect(
        _box(tester).borderColor,
        _colors().status(DabblerStatusTone.error).base,
      );
      expect(find.text('same day'), findsNothing);
    });

    testWidgets('open holds the focus border', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerTimeField(open: true)));
      expect(_box(tester).borderColor, _colors().focusRing);
    });
  });

  group('the DS-806 seam', () {
    testWidgets('tapping the clock fires onOpenPicker', (
      WidgetTester tester,
    ) async {
      int opens = 0;
      await tester.pumpWidget(
        _host(DabblerTimeField(onOpenPicker: () => opens++)),
      );
      await tester.tap(
        find.bySemanticsLabel(
          DabblerPickerFieldShell.defaultOpenSemanticsLabel,
        ),
      );
      expect(opens, 1);
    });

    testWidgets('the button reports aria-expanded while open', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerTimeField(open: true)));
      expect(
        tester
            .getSemantics(
              find.bySemanticsLabel(
                DabblerPickerFieldShell.defaultCloseSemanticsLabel,
              ),
            )
            .flagsCollection.isExpanded.toBoolOrNull(),
        isTrue,
      );
    });

    testWidgets('a picked time pushed in from outside re-renders', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerTimeField()));
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '',
      );
      await tester.pumpWidget(
        _host(const DabblerTimeField(value: TimeOfDay(hour: 18, minute: 0))),
      );
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '6:00 PM',
      );
    });
  });

  group('typed commit and revert', () {
    testWidgets('Enter normalises a loose form to H:MM AM', (
      WidgetTester tester,
    ) async {
      TimeOfDay? committed;
      await tester.pumpWidget(
        _host(DabblerTimeField(onChanged: (TimeOfDay? v) => committed = v)),
      );
      await tester.enterText(find.byType(EditableText), '6pm');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(committed, const TimeOfDay(hour: 18, minute: 0));
      expect(DabblerTimeFormat.format(committed), '6:00 PM');
    });

    testWidgets('unparseable text reverts', (WidgetTester tester) async {
      bool called = false;
      await tester.pumpWidget(
        _host(
          DabblerTimeField(
            value: const TimeOfDay(hour: 18, minute: 0),
            onChanged: (TimeOfDay? v) => called = true,
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText), 'half six');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(called, isFalse);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '6:00 PM',
      );
    });

    testWidgets('an out-of-bounds time reverts on the typed path too', (
      WidgetTester tester,
    ) async {
      TimeOfDay? committed;
      await tester.pumpWidget(
        _host(
          DabblerTimeField(
            value: const TimeOfDay(hour: 10, minute: 0),
            minimum: const TimeOfDay(hour: 9, minute: 0),
            maximum: const TimeOfDay(hour: 17, minute: 30),
            onChanged: (TimeOfDay? v) => committed = v,
          ),
        ),
      );
      for (final String raw in <String>['8:59 AM', '5:31 PM']) {
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
          DabblerTimeField(
            value: const TimeOfDay(hour: 18, minute: 0),
            onChanged: (TimeOfDay? v) => cleared = v == null,
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(cleared, isTrue);
    });

    testWidgets('losing focus commits', (WidgetTester tester) async {
      TimeOfDay? committed;
      await tester.pumpWidget(
        _host(DabblerTimeField(onChanged: (TimeOfDay? v) => committed = v)),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '18:30');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(committed, const TimeOfDay(hour: 18, minute: 30));
    });
  });

  group('RTL', () {
    testWidgets('the time keeps H:MM AM order under Directionality.rtl', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerTimeField(
            label: 'البداية',
            value: TimeOfDay(hour: 18, minute: 0),
          ),
          direction: TextDirection.rtl,
          locale: const Locale('ar'),
        ),
      );
      final EditableText editable =
          tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.textDirection, TextDirection.ltr);
      expect(editable.controller.text, '6:00 PM');
    });

    testWidgets('the clock button mirrors to the inline end', (
      WidgetTester tester,
    ) async {
      final Finder button = find.bySemanticsLabel(
        DabblerPickerFieldShell.defaultOpenSemanticsLabel,
      );
      await tester.pumpWidget(_host(const DabblerTimeField()));
      expect(
        tester.getCenter(button).dx,
        greaterThan(tester.getCenter(find.byType(DabblerSurface).first).dx),
      );

      await tester.pumpWidget(
        _host(const DabblerTimeField(), direction: TextDirection.rtl),
      );
      expect(
        tester.getCenter(button).dx,
        lessThan(tester.getCenter(find.byType(DabblerSurface).first).dx),
      );
    });
  });
}
