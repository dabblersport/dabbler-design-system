/// The gallery (KAN-259).
///
/// Three things are checked here, in the order the ticket asks for them:
/// every registered entry renders without throwing (AC4), the index agrees
/// with what is actually registered (AC6), and `main.dart` still only spreads
/// per-component lists rather than building demos inline (AC2/AC3).
library;

import 'dart:io';

import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:dabbler_design_system/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the gallery index', () {
    testWidgets('pumps, and lists every registered entry', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const GalleryApp());
      await tester.pumpAndSettle();

      expect(
        galleryEntries,
        isNotEmpty,
        reason:
            'An empty index is the regression the placeholder copy now '
            'describes: no component reached galleryEntries.',
      );
      // AC6 — the count the app shows is the count that is registered.
      expect(
        find.text('Dabbler Design System (${galleryEntries.length})'),
        findsOneWidget,
      );
      // Every title is unique, so the index does not silently hide an entry
      // behind another's row.
      expect(
        galleryEntries.map((GalleryEntry e) => e.title).toSet(),
        hasLength(galleryEntries.length),
      );
    });

    // AC4 — each entry's builder is pumped in the app's own theme. A
    // component whose specimen throws fails here by name.
    for (final GalleryEntry entry in galleryEntries) {
      testWidgets('renders: ${entry.title}', (WidgetTester tester) async {
        // Every error raised while this entry renders is collected rather
        // than aggregated, so each one can be judged on its own message.
        final List<FlutterErrorDetails> errors = <FlutterErrorDetails>[];
        final void Function(FlutterErrorDetails)? previous =
            FlutterError.onError;
        FlutterError.onError = errors.add;
        try {
          await tester.pumpWidget(
            MaterialApp(
              theme: galleryTheme(DabblerTheme.main, Brightness.light),
              home: DabblerToastProvider(
                child: GalleryEntryScreen(entry: entry),
              ),
            ),
          );
          // Not pumpAndSettle: several specimens are deliberately perpetual —
          // the spinner, the shimmering skeleton, the indeterminate progress
          // bar — and settling would never return. Two pumps is enough to
          // build, lay out and paint, which is what AC4 asks about.
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
        } finally {
          FlutterError.onError = previous;
        }

        // The sport artwork PNGs the registry names are not in this package
        // yet — there is no `assets/` directory and no `assets:` block in
        // pubspec.yaml, because the art is a pending hand-off. The widgets
        // build and lay out correctly; only the decode fails. That one
        // failure is tolerated by message, so every other kind of error still
        // fails the entry it came from.
        final List<String> unexpected = errors
            .map((FlutterErrorDetails d) => d.exceptionAsString())
            .where((String m) => !m.contains('Unable to load asset'))
            .toList();
        expect(
          unexpected,
          isEmpty,
          reason:
              '"${entry.title}" raised ${unexpected.length} error(s) while '
              'rendering:\n  ${unexpected.join('\n  ')}\n'
              'A gallery entry that throws is a component defect or a broken '
              "specimen; fix it in that component's own gallery file.",
        );
        expect(find.text(entry.title), findsWidgets);
      });
    }
  });

  group('the registration shape (AC2/AC3)', () {
    final File main = File('lib/main.dart');

    test('main.dart assembles the index only by spreading', () {
      final RegExp entryList = RegExp(
        r'galleryEntries = <GalleryEntry>\[(.*?)\];',
        dotAll: true,
      );
      final String body = entryList.firstMatch(main.readAsStringSync())!
          .group(1)!;

      final List<String> lines = body
          .split('\n')
          .map((String l) => l.trim())
          .where((String l) => l.isNotEmpty && !l.startsWith('//'))
          .toList();

      expect(lines, isNotEmpty);
      for (final String line in lines) {
        expect(
          RegExp(r'^\.\.\.[a-z][A-Za-z0-9]*GalleryEntries,$').hasMatch(line),
          isTrue,
          reason:
              'main.dart\'s index must be spreads of per-component lists and '
              'nothing else, so adding a component is one line here and a '
              'file of its own. Offending line: "$line".',
        );
      }
    });

    test('every spread names a colocated *_gallery.dart that exists', () {
      final Iterable<RegExpMatch> spreads = RegExp(
        r'\.\.\.([a-z][A-Za-z0-9]*)GalleryEntries,',
      ).allMatches(main.readAsStringSync());

      final Set<String> galleryFiles = Directory('lib/src')
          .listSync(recursive: true)
          .whereType<File>()
          .map((File f) => f.uri.pathSegments.last)
          .where((String name) => name.endsWith('_gallery.dart'))
          .toSet();

      expect(spreads, hasLength(greaterThan(1)));
      expect(
        galleryFiles,
        hasLength(greaterThanOrEqualTo(spreads.length)),
        reason:
            'Every spread in main.dart comes from a colocated *_gallery.dart '
            'under lib/src/. Found ${spreads.length} spreads and '
            '${galleryFiles.length} gallery files.',
      );
    });

    test('main.dart builds no component demo of its own', () {
      // Comments are prose about the design system and routinely name its
      // types; only code counts.
      final String source = main
          .readAsLinesSync()
          .where(
            (String l) =>
                !l.trimLeft().startsWith('///') && !l.trimLeft().startsWith('//'),
          )
          .join('\n');
      // The app shell is allowed to name the design system's tokens, its
      // toast provider and its theme; it is not allowed to construct a
      // component specimen, which is what AC2 moves out of this file.
      const Set<String> allowed = <String>{
        'DabblerTheme',
        'DabblerColors',
        'DabblerSpacing',
        'DabblerToastProvider',
      };
      final Set<String> constructed = RegExp(r'\b(Dabbler[A-Za-z]+)\b')
          .allMatches(source)
          .map((RegExpMatch m) => m.group(1)!)
          .where((String name) => !allowed.contains(name))
          .toSet();

      expect(
        constructed,
        isEmpty,
        reason:
            'main.dart names $constructed. Component demo code belongs in '
            'that component\'s own *_gallery.dart, not in the app shell — '
            'otherwise main.dart is a collision point again.',
      );
    });
  });
}
