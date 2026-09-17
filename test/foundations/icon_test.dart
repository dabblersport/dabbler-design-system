import 'dart:io';

import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Minimum host: a [DabblerColors] in the theme and a [Directionality].
Widget _host(Widget child, {Color? ambientColor}) {
  Widget body = Align(alignment: Alignment.topLeft, child: child);
  if (ambientColor != null) {
    body = IconTheme(data: IconThemeData(color: ambientColor), child: body);
  }
  return Theme(
    data: ThemeData(
      extensions: <ThemeExtension<dynamic>>[
        DabblerColors.resolve(
          theme: DabblerTheme.main,
          brightness: Brightness.light,
        ),
      ],
    ),
    child: Directionality(textDirection: TextDirection.ltr, child: body),
  );
}

DabblerColors get _colors => DabblerColors.resolve(
      theme: DabblerTheme.main,
      brightness: Brightness.light,
    );

void main() {
  final List<String> warnings = <String>[];

  setUp(() {
    DabblerIconRegistry.reset();
    warnings.clear();
    DabblerIconRegistry.warn = warnings.add;
  });

  tearDown(DabblerIconRegistry.reset);

  group('T-083 — the web source\'s Pro substitution table is NOT ported', () {
    test('every web-Pro-gated name exists in iconsax_flutter in BOTH weights',
        () {
      // This is cto's finding, re-derived here rather than taken on trust. If
      // it ever stops holding, this test fails and the question of a fallback
      // table is reopened deliberately instead of silently.
      final List<String> missingLinear = <String>[];
      final List<String> missingBold = <String>[];
      for (final String name in DabblerIconRegistry.webProGatedNames) {
        final String snake = name.replaceAll('-', '_');
        // Corrected 2026-09-17 with the weight mapping: the base key is the
        // BOLD (solid) glyph and `_copy` is the LINEAR (outline) one.
        if (!Iconsax.items.containsKey(snake)) missingBold.add(name);
        if (!Iconsax.items.containsKey('$snake${DabblerIconRegistry.linearSuffix}')) {
          missingLinear.add(name);
        }
      }
      expect(missingBold, isEmpty);
      // refresh-2 is the one documented gap, and it is a LINEAR gap only.
      expect(missingLinear, <String>['refresh-2']);
    });

    test('a web-Pro-gated name resolves to ITSELF, never to a circled stand-in',
        () {
      for (final String name in DabblerIconRegistry.webProGatedNames) {
        // Asked for at BOLD, which is the side every one of these ships. The
        // point of the test is that the NAME is never swapped for a stand-in,
        // and refresh-2's linear gap is a separate, documented fact.
        final DabblerIconResolution r =
            DabblerIconRegistry.resolve(name, weight: DabblerIconWeight.bold);
        expect(r.outcome, DabblerIconOutcome.resolved, reason: name);
        expect(r.resolvedKey, name.replaceAll('-', '_'), reason: name);
      }
      expect(warnings, isEmpty, reason: 'nothing was substituted, so nothing warns');
    });

    test('arrow-right is arrow-right, not arrow-circle-right', () {
      final DabblerIconResolution r = DabblerIconRegistry.resolve('arrow-right');
      // Linear is the `_copy` (outline) side since the mapping correction; the
      // assertion that matters is that the NAME is not substituted.
      expect(r.glyph, Iconsax.arrow_right_copy);
      expect(r.glyph, isNot(Iconsax.arrow_circle_right));
      expect(r.glyph, isNot(Iconsax.arrow_circle_right_copy));
      expect(r.resolvedKey, 'arrow_right_copy');
    });

    test('the four names AC2 called out resolve to themselves in both weights',
        () {
      for (final String name in <String>[
        'arrow-right', 'arrow-left', 'arrow-up', 'arrow-down',
        'more-2', 'refresh', 'logout',
      ]) {
        for (final DabblerIconWeight w in DabblerIconWeight.values) {
          final DabblerIconResolution r =
              DabblerIconRegistry.resolve(name, weight: w);
          expect(r.outcome, DabblerIconOutcome.resolved, reason: '$name/${w.name}');
          expect(r.resolvedWeight, w, reason: '$name/${w.name}');
        }
      }
    });
  });

  group('Name → glyph mapping', () {
    test('kebab-case becomes snake_case; linear appends _copy', () {
      // Corrected 2026-09-17: `_copy` is the OUTLINE glyph, so it is linear
      // that takes the suffix. See DabblerIconRegistry.keyFor for the evidence.
      expect(DabblerIconRegistry.keyFor('search-normal', DabblerIconWeight.bold),
          'search_normal');
      expect(DabblerIconRegistry.keyFor('search-normal', DabblerIconWeight.linear),
          'search_normal_copy');
      expect(DabblerIconRegistry.linearSuffix, '_copy');
    });

    test('linear resolves to Iconsax.<name>_copy', () {
      final DabblerIconResolution r =
          DabblerIconRegistry.resolve('search-normal');
      expect(r.outcome, DabblerIconOutcome.resolved);
      expect(r.glyph, Iconsax.search_normal_copy);
      expect(r.resolvedWeight, DabblerIconWeight.linear);
    });

    test('bold resolves to Iconsax.<name>', () {
      final DabblerIconResolution r = DabblerIconRegistry.resolve(
        'search-normal',
        weight: DabblerIconWeight.bold,
      );
      expect(r.outcome, DabblerIconOutcome.resolved);
      expect(r.glyph, Iconsax.search_normal);
      expect(r.glyph, isNot(Iconsax.search_normal_copy));
    });

    test('every name in the app vocabulary resolves in both weights', () {
      final List<String> failures = <String>[];
      for (final String name in DabblerIconRegistry.vocabulary) {
        for (final DabblerIconWeight w in DabblerIconWeight.values) {
          final DabblerIconResolution r =
              DabblerIconRegistry.resolve(name, weight: w);
          if (r.outcome != DabblerIconOutcome.resolved) {
            failures.add('$name/${w.name} -> ${r.outcome.name}');
          }
        }
      }
      expect(failures, isEmpty);
      expect(DabblerIconRegistry.vocabulary, hasLength(40));
    });
  });

  group('AC2 — fallback: linear falls back to BOLD before the placeholder', () {
    // Direction inverted 2026-09-17 with the weight mapping: `_copy` is the
    // outline side, so it is a LINEAR request that can come up short.
    test('refresh-2 linear draws the bold glyph, not a placeholder', () {
      final DabblerIconResolution r = DabblerIconRegistry.resolve('refresh-2');
      expect(r.outcome, DabblerIconOutcome.weightFallback);
      expect(r.hasGlyph, isTrue);
      expect(r.glyph, Iconsax.refresh_2);
      expect(r.resolvedKey, 'refresh_2');
      expect(r.requestedWeight, DabblerIconWeight.linear);
      expect(r.resolvedWeight, DabblerIconWeight.bold);
      expect(warnings.single, contains('no linear weight'));
    });

    test('refresh-2 bold is an ordinary resolve, with no warning', () {
      final DabblerIconResolution r = DabblerIconRegistry.resolve(
        'refresh-2',
        weight: DabblerIconWeight.bold,
      );
      expect(r.outcome, DabblerIconOutcome.resolved);
      expect(warnings, isEmpty);
    });

    test('the linear gaps are re-derived from the package, not restated', () {
      // T-083 names refresh-2 as "the one genuine gap". Measured against
      // Iconsax.items there are 16 names with a bold weight and no _copy
      // outline — refresh-2 is simply the only one inside the web-Pro-gated
      // set. Every one of them must take the weight-fallback path, not the
      // placeholder.
      final List<String> linearGaps = <String>[
        for (final String key in Iconsax.items.keys)
          if (!key.endsWith(DabblerIconRegistry.linearSuffix) &&
              !Iconsax.items
                  .containsKey('$key${DabblerIconRegistry.linearSuffix}'))
            key,
      ];
      // 40 keys have no _copy: 16 real names plus 24 unnamed `uniXXXX`
      // codepoint leftovers the package ships. Split them, because only the
      // named ones are a design-facing gap.
      final List<String> named =
          linearGaps.where((String k) => !k.startsWith('uni')).toList()..sort();
      expect(named, hasLength(16));
      expect(named, contains('refresh_2'));
      expect(linearGaps.where((String k) => k.startsWith('uni')), hasLength(24));

      for (final String key in linearGaps) {
        final DabblerIconResolution r =
            DabblerIconRegistry.resolve(key.replaceAll('_', '-'));
        expect(r.outcome, DabblerIconOutcome.weightFallback, reason: key);
        expect(r.hasGlyph, isTrue, reason: key);
      }
    });

    test('bold never falls back to linear — an outline stand-in reads inactive',
        () {
      // Seven keys are outline-only. Asked for at bold they must reach the
      // placeholder rather than quietly drawing an outline glyph, which in an
      // active tab or a primary action reads as a DISABLED control.
      final List<String> linearOnly = <String>[
        for (final String key in Iconsax.items.keys)
          if (key.endsWith(DabblerIconRegistry.linearSuffix) &&
              !Iconsax.items.containsKey(key.substring(
                  0, key.length - DabblerIconRegistry.linearSuffix.length)))
            key,
      ];
      expect(linearOnly, hasLength(7));

      for (final String key in linearOnly) {
        final String boldName = key
            .substring(0, key.length - DabblerIconRegistry.linearSuffix.length)
            .replaceAll('_', '-');
        final DabblerIconResolution r = DabblerIconRegistry.resolve(
          boldName,
          weight: DabblerIconWeight.bold,
        );
        expect(r.outcome, DabblerIconOutcome.missing, reason: key);
        expect(r.hasGlyph, isFalse, reason: key);
      }
    });
  });

  group('AC2 — missing: visible, asserted, never thrown, never blank', () {
    test('resolve is total — an unknown name returns missing and never throws',
        () {
      late DabblerIconResolution r;
      expect(
        () => r = DabblerIconRegistry.resolve('definitely-not-an-icon'),
        returnsNormally,
        reason: 'resolve is called from build(); it must not throw there',
      );
      expect(r.outcome, DabblerIconOutcome.missing);
      expect(r.hasGlyph, isFalse);
      expect(r.resolvedKey, isNull);
      expect(warnings.single, contains('is not an Iconsax glyph'));
    });

    test('a warning is emitted once per unknown name', () {
      for (int i = 0; i < 3; i++) {
        DabblerIconRegistry.resolve('nope-one');
      }
      expect(warnings, hasLength(1));
      expect(DabblerIconRegistry.warnedNames, contains('missing:nope-one'));
    });

    test('distinct unknown names each warn once', () {
      DabblerIconRegistry.resolve('nope-a');
      DabblerIconRegistry.resolve('nope-b');
      expect(warnings, hasLength(2));
    });

    test('a weight fallback warns once however often it is asked', () {
      for (int i = 0; i < 5; i++) {
        // refresh-2's gap is on the LINEAR side since the mapping correction.
        DabblerIconRegistry.resolve('refresh-2');
      }
      expect(warnings, hasLength(1));
    });
  });

  group('AC1 — the widget: names, weights, sizes', () {
    testWidgets('renders the linear glyph at the default 24px box',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerIcon('home-2')));

      final Icon icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Iconsax.home_2_copy);
      expect(icon.size, DabblerSizing.iconMd);
      expect(DabblerSizing.iconMd, 24);
      expect(tester.getSize(find.byType(DabblerIcon)),
          const Size(DabblerSizing.iconMd, DabblerSizing.iconMd));
    });

    testWidgets('bold renders the base (solid) glyph',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerIcon('home-2', weight: DabblerIconWeight.bold),
      ));
      expect(tester.widget<Icon>(find.byType(Icon)).icon, Iconsax.home_2);
    });

    testWidgets('the three documented sizes are 18 / 24 / 30',
        (WidgetTester tester) async {
      for (final double side in <double>[
        DabblerSizing.iconSm,
        DabblerSizing.iconMd,
        DabblerSizing.iconLg,
      ]) {
        await tester.pumpWidget(_host(DabblerIcon('star', size: side)));
        expect(tester.getSize(find.byType(DabblerIcon)), Size(side, side));
        expect(tester.widget<Icon>(find.byType(Icon)).size, side);
      }
      expect(
        <double>[
          DabblerSizing.iconSm,
          DabblerSizing.iconMd,
          DabblerSizing.iconLg,
        ],
        <double>[18, 24, 30],
      );
    });

    testWidgets('colour inherits from IconTheme like currentColor',
        (WidgetTester tester) async {
      final Color ambient = _colors.brandPrimary;
      await tester.pumpWidget(
        _host(const DabblerIcon('home-2'), ambientColor: ambient),
      );
      expect(tester.widget<Icon>(find.byType(Icon)).color, ambient);
    });

    testWidgets('an explicit colour wins over the ambient IconTheme',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerIcon('home-2', color: _colors.accent),
        ambientColor: _colors.brandPrimary,
      ));
      expect(tester.widget<Icon>(find.byType(Icon)).color, _colors.accent);
    });

    testWidgets('the whole app vocabulary builds with no exception',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        Wrap(
          children: <Widget>[
            for (final String name in DabblerIconRegistry.vocabulary)
              DabblerIcon(name),
            for (final String name in DabblerIconRegistry.vocabulary)
              DabblerIcon(name, weight: DabblerIconWeight.bold),
          ],
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(warnings, isEmpty);
      expect(find.byType(Icon),
          findsNWidgets(DabblerIconRegistry.vocabulary.length * 2));
    });

    testWidgets('a linear weight gap renders the bold glyph in the same box',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerIcon('refresh-2')));
      expect(tester.takeException(), isNull);
      expect(tester.widget<Icon>(find.byType(Icon)).icon, Iconsax.refresh_2);
      expect(tester.getSize(find.byType(DabblerIcon)),
          const Size(DabblerSizing.iconMd, DabblerSizing.iconMd));
    });
  });

  group('AC2 — the placeholder occupies the box and is never blank', () {
    testWidgets('an unknown name paints a visible mark at the requested size',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerIcon('definitely-not-an-icon', size: DabblerSizing.iconLg),
      ));

      // The debug diagnostic is reported, not thrown: the test binding catches
      // it AND the subtree still built, which is the whole point of using
      // FlutterError.reportError instead of an assert inside build().
      expect(tester.takeException(), isA<FlutterError>());
      expect(find.byType(Icon), findsNothing);
      expect(find.byType(CustomPaint), findsWidgets);
      // Never an empty SizedBox: the box is the full requested icon size.
      expect(tester.getSize(find.byType(DabblerIcon)),
          const Size(DabblerSizing.iconLg, DabblerSizing.iconLg));
      expect(tester.getSize(find.byType(DabblerIcon)).isEmpty, isFalse);
    });

    test('the placeholder inset leaves a non-zero mark at the smallest size',
        () {
      final double inset = DabblerSizing.iconSm * DabblerIcon.placeholderInset;
      expect(DabblerSizing.iconSm - 2 * inset, greaterThan(0));
    });
  });

  group('Accessibility — decorative by default, named when labelled', () {
    testWidgets('no label: nothing reaches the semantics tree',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const DabblerIcon('star')));
      expect(find.byType(ExcludeSemantics), findsWidgets);
      expect(
        tester.widget<ExcludeSemantics>(find.byType(ExcludeSemantics).first)
            .excluding,
        isTrue,
      );
      expect(tester.getSemantics(find.byType(DabblerIcon)).label, isEmpty);
      handle.dispose();
    });

    testWidgets('a label makes it a named image', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const DabblerIcon('notification-bing', semanticLabel: 'Notifications'),
      ));
      expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
      handle.dispose();
    });
  });

  group('Dependency — iconsax_flutter, and nothing else', () {
    test('pubspec declares iconsax_flutter as the one runtime dependency', () {
      final List<String> lines = File('pubspec.yaml').readAsLinesSync();
      final int start = lines.indexOf('dependencies:');
      final int end = lines.indexOf('dev_dependencies:');
      expect(start, isNonNegative);
      final List<String> declared = <String>[
        for (final String line in lines.sublist(start + 1, end))
          if (line.startsWith('  ') && !line.trimLeft().startsWith('#'))
            line.trim().split(':').first,
      ];
      // Scoped to this ticket's dependency only: other tickets in this wave add
      // their own to the same file, and policing the whole list here would
      // fail on their work rather than on mine.
      expect(declared, contains('iconsax_flutter'),
          reason: 'T-083 authorises iconsax_flutter for KAN-235');
    });
  });
}
