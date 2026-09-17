/// Export completeness for `lib/dabbler_design_system.dart` (KAN-256 AC3).
///
/// This is a golden-style scanner, not a hand-maintained list. It reads every
/// library under `lib/src/`, collects the public top-level declarations, and
/// asserts each one is reachable through the barrel — or named in
/// [deliberatelyInternal] with a written reason.
///
/// The point is the failure mode: a component lands in `lib/src/`, nobody
/// remembers the barrel, and this test goes red on the next run instead of the
/// package silently shipping a class no consumer can import. ~30 more tickets
/// are still landing in this package; a hand-written list would have drifted
/// inside a week.
///
/// **If this test flags something that should stay internal, add an exemption
/// here with the reason. Never widen the barrel to satisfy the scanner.**
library;

import 'dart:io';

// The AC2 check is this import and nothing else: everything the barrel
// promises has to be reachable from here with no second import. If a type
// below stops resolving, the barrel regressed.
import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Public top-level names that are deliberately absent from the barrel, each
/// with the reason it stays internal. Mirrored by the "what is deliberately
/// NOT exported" section of `lib/dabbler_design_system.dart`.
const Map<String, String> deliberatelyInternal = <String, String>{
  'DabblerFieldShell':
      'DS-600 AC1 — the paint layer the form fields compose internally. No '
      'public component API mentions it, so no consumer needs it.',
  'DabblerFieldAlign':
      'DS-600 AC1 — DabblerFieldShell\'s own cross-axis enum, passed only by '
      'the fields that compose the shell. Internal for the same reason.',
  'DabblerPickerFieldShell':
      'DS-600 AC1 — the same ruling for the typed-or-picked fields. '
      'picker_field.dart is exported with this one name hidden.',
  'progressSweepOffsetAt':
      'A test seam, documented as such at its declaration: it samples the '
      'indeterminate keyframe without pumping frames. Not a component API.',
};

/// A public top-level declaration found by the scanner.
class _Declaration {
  const _Declaration(this.name, this.library, this.file, this.line);

  /// The declared name.
  final String name;

  /// The library that owns it — the enclosing library for a `part`.
  final String library;

  /// The file it was written in, for the failure message.
  final String file;

  /// Its line number, for the failure message.
  final int line;

  @override
  String toString() => '$name ($file:$line)';
}

void main() {
  final Directory packageRoot = _packageRoot();
  final File barrel = File(
    '${packageRoot.path}/lib/dabbler_design_system.dart',
  );

  group('lib/dabbler_design_system.dart (the public barrel)', () {
    test('exists at the package root', () {
      expect(
        barrel.existsSync(),
        isTrue,
        reason:
            'The package exists to be imported in one line. Without this file '
            'no consumer — including Dabbler/dabbler-code — can reach a '
            'single component.',
      );
    });

    test('every public top-level declaration is exported or exempted', () {
      final Map<String, _ExportClause> exports = _parseExports(barrel);
      final List<_Declaration> declarations = _scanSource(packageRoot);

      expect(
        declarations,
        isNotEmpty,
        reason: 'The scanner found nothing under lib/src/ — it is broken.',
      );

      final List<String> unexported = <String>[];
      for (final _Declaration declaration in declarations) {
        if (deliberatelyInternal.containsKey(declaration.name)) {
          continue;
        }
        final _ExportClause? clause = exports[declaration.library];
        if (clause == null) {
          unexported.add(
            '$declaration — its library ${declaration.library} is not '
            'exported by the barrel at all',
          );
        } else if (!clause.exposes(declaration.name)) {
          unexported.add(
            '$declaration — ${declaration.library} is exported, but this name '
            'is filtered out by its show/hide clause',
          );
        }
      }

      expect(
        unexported,
        isEmpty,
        reason:
            'These public declarations are unreachable through '
            'package:dabbler_design_system/dabbler_design_system.dart:\n'
            '  ${unexported.join('\n  ')}\n\n'
            'Add an export to lib/dabbler_design_system.dart. If the type is '
            'meant to stay internal, add it to deliberatelyInternal in this '
            'file WITH ITS REASON — do not widen the public API to silence '
            'the scanner.',
      );
    });

    test('every exempted name still exists, and is still unexported', () {
      final Map<String, _ExportClause> exports = _parseExports(barrel);
      final Map<String, _Declaration> byName = <String, _Declaration>{
        for (final _Declaration d in _scanSource(packageRoot)) d.name: d,
      };

      for (final MapEntry<String, String> entry
          in deliberatelyInternal.entries) {
        final _Declaration? declaration = byName[entry.key];
        expect(
          declaration,
          isNotNull,
          reason:
              '${entry.key} is exempted here but no longer exists under '
              'lib/src/. Remove the stale exemption — an exemption list that '
              'outlives its types stops describing anything.',
        );
        final _ExportClause? clause = exports[declaration!.library];
        expect(
          clause == null || !clause.exposes(entry.key),
          isTrue,
          reason:
              '${entry.key} is listed as deliberately internal but the barrel '
              'now exports it. Either the exemption is wrong or the export '
              'is; resolve it rather than leaving both claims standing.',
        );
      }
    });

    test('AC2 — every AC1 type is reachable and usable from this one import',
        () {
      // Tokens.
      expect(DabblerPalette.paper, isA<Color>());
      const DabblerTheme theme = DabblerTheme.main;
      const DabblerStatusTone tone = DabblerStatusTone.success;
      final DabblerColors colors = DabblerColors.resolve(
        theme: theme,
        brightness: Brightness.light,
      );
      expect(colors.status(tone), isA<DabblerStatusColor>());
      expect(
        const DabblerStatusColor(
          base: DabblerPalette.paper,
          surface: DabblerPalette.paper,
          strong: DabblerPalette.paper,
          solid: DabblerPalette.paper,
        ),
        isA<DabblerStatusColor>(),
      );
      expect(
        const DabblerToneColor(
          surface: DabblerPalette.paper,
          ink: DabblerPalette.paper,
        ),
        isA<DabblerToneColor>(),
      );
      expect(dabblerNeutralStatus(colors), isA<DabblerStatusColor>());

      const DabblerTypeStyle style = DabblerType.body;
      expect(style.role, isA<DabblerTypeRole>());
      expect(
        DabblerType.bareFamilyFor(style.role, DabblerTypeScript.arabic),
        isA<String>(),
      );

      expect(DabblerSpacing.space4, isA<double>());
      expect(DabblerRadius.mdAll, isA<BorderRadius>());
      expect(DabblerSizing.touchTargetMin, isA<double>());
      expect(
        DabblerElevation.dialogFor(Brightness.light),
        isA<List<BoxShadow>>(),
      );
      expect(DabblerMotion.fast, isA<Duration>());

      // Components — constructed, not merely named.
      const Widget child = SizedBox.shrink();
      expect(
        const <Widget>[
          DabblerFocusRing.visible(visible: false, child: child),
          DabblerPressScale(pressed: false, child: child),
          DabblerScrim(child: child),
          DabblerSurface(variant: DabblerSurfaceVariant.card, child: child),
          DabblerFab(tone: DabblerFabTone.primary, child: child),
          DabblerBanner(message: 'x'),
          DabblerProgressBar(value: 0.5),
          DabblerSpinner(),
          DabblerSkeleton.text(),
        ],
        hasLength(9),
      );
    });

    test('exports no file twice and no part file', () {
      final List<String> paths = _exportPaths(barrel);
      expect(
        paths.toSet().length,
        paths.length,
        reason:
            'A duplicated export is an ambiguous-export diagnostic waiting to '
            'happen.',
      );
      for (final String path in paths) {
        final File file = File('${packageRoot.path}/lib/$path');
        expect(
          file.existsSync(),
          isTrue,
          reason: 'The barrel exports $path, which does not exist.',
        );
        expect(
          _isPart(file),
          isFalse,
          reason:
              'The barrel exports $path, which is a `part of` another '
              'library. A part is not a library and cannot be exported.',
        );
      }
    });
  });
}

/// The `show`/`hide` filter on one export directive.
class _ExportClause {
  const _ExportClause({this.shown, this.hidden = const <String>{}});

  /// The `show` names, or null when the directive has no `show`.
  final Set<String>? shown;

  /// The `hide` names.
  final Set<String> hidden;

  /// Whether [name] survives this clause.
  bool exposes(String name) {
    if (hidden.contains(name)) {
      return false;
    }
    return shown == null || shown!.contains(name);
  }
}

/// Resolves the package root from the test's working directory, which
/// `flutter test` sets to the package root but which a differently-invoked
/// runner may not.
Directory _packageRoot() {
  Directory directory = Directory.current;
  while (!File('${directory.path}/pubspec.yaml').existsSync()) {
    final Directory parent = directory.parent;
    if (parent.path == directory.path) {
      fail('Could not find the package root from ${Directory.current.path}.');
    }
    directory = parent;
  }
  return directory;
}

final RegExp _exportDirective = RegExp(
  r"^export\s+'([^']+)'([^;]*);",
  multiLine: true,
);
final RegExp _showClause = RegExp(r'\bshow\s+([A-Za-z0-9_,\s]+)');
final RegExp _hideClause = RegExp(r'\bhide\s+([A-Za-z0-9_,\s]+)');

/// The library paths (relative to `lib/`) the barrel exports, in order.
List<String> _exportPaths(File barrel) => _exportDirective
    .allMatches(barrel.readAsStringSync())
    .map((RegExpMatch m) => m.group(1)!)
    .toList();

/// The barrel's export directives, keyed by the exported path.
Map<String, _ExportClause> _parseExports(File barrel) {
  final Map<String, _ExportClause> exports = <String, _ExportClause>{};
  for (final RegExpMatch match
      in _exportDirective.allMatches(barrel.readAsStringSync())) {
    final String combinators = match.group(2) ?? '';
    exports[match.group(1)!] = _ExportClause(
      shown: _names(_showClause.firstMatch(combinators)?.group(1)),
      hidden: _names(_hideClause.firstMatch(combinators)?.group(1)) ??
          const <String>{},
    );
  }
  return exports;
}

Set<String>? _names(String? clause) => clause
    ?.split(',')
    .map((String name) => name.trim())
    .where((String name) => name.isNotEmpty)
    .toSet();

final RegExp _partOf = RegExp(r"^part\s+of\s+'([^']+)';", multiLine: true);

bool _isPart(File file) => _partOf.hasMatch(file.readAsStringSync());

/// Public top-level `class`/`enum`/`mixin`/`extension`/`typedef` declarations
/// and public top-level functions.
///
/// Private names (`_`-prefixed) are skipped, which covers the private state
/// classes, painters and intents every component here declares. Lines inside
/// a `///` doc comment or a `//` comment are stripped first, so a type named
/// in prose is not mistaken for a declaration.
final RegExp _declaration = RegExp(
  r'^(?:abstract\s+|final\s+|sealed\s+|base\s+|interface\s+)*'
  r'(?:class|enum|mixin|extension|typedef)\s+([A-Za-z_][A-Za-z0-9_]*)',
);
final RegExp _function = RegExp(
  r'^[A-Za-z_][A-Za-z0-9_<>?,\s.]*\s+([a-z][A-Za-z0-9_]*)\s*(?:<[^>]*>)?\s*\(',
);

List<_Declaration> _scanSource(Directory packageRoot) {
  final Directory source = Directory('${packageRoot.path}/lib/src');
  final List<_Declaration> declarations = <_Declaration>[];

  for (final File file in source
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))) {
    final String contents = file.readAsStringSync();
    final String relative = file.path
        .substring('${packageRoot.path}/lib/'.length)
        .replaceAll(r'\', '/');

    // A `part` belongs to the library that declares it; that library is what
    // the barrel exports.
    final RegExpMatch? partOf = _partOf.firstMatch(contents);
    final String owner = partOf == null
        ? relative
        : _resolve(relative, partOf.group(1)!);

    final List<String> lines = contents.split('\n');
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      if (line.startsWith('///') || line.trimLeft().startsWith('//')) {
        continue;
      }
      final String? name = _declaration.firstMatch(line)?.group(1) ??
          _function.firstMatch(line)?.group(1);
      if (name == null || name.startsWith('_')) {
        continue;
      }
      declarations.add(_Declaration(name, owner, relative, i + 1));
    }
  }
  declarations.sort((_Declaration a, _Declaration b) => a.name.compareTo(b.name));
  return declarations;
}

/// Resolves a relative `part of` target against the part's own path.
String _resolve(String from, String target) {
  final List<String> segments = from.split('/')..removeLast();
  for (final String segment in target.split('/')) {
    if (segment == '..') {
      segments.removeLast();
    } else if (segment != '.') {
      segments.add(segment);
    }
  }
  return segments.join('/');
}
