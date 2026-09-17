import 'dart:io';

import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_dark_provisional.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The one file permitted to declare a dark-mode hex.
const String provisionalPath = 'lib/src/tokens/dabbler_dark_provisional.dart';

final RegExp _hexLiteral = RegExp(r'Color\(0x([0-9A-Fa-f]{6,8})\)');

List<File> _dartFilesUnder(String dir) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((File f) => f.path.endsWith('.dart'))
    .map((File f) => File(f.path.replaceAll(r'\', '/')))
    .toList();

/// Source with `//` comment lines stripped, so a hex quoted in a doc comment is
/// not mistaken for a declaration.
String _code(File f) => f
    .readAsLinesSync()
    .where((String l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  test('AC4 — the dark ramp declares itself provisional', () {
    expect(dabblerDarkRampProvisional, isTrue);
    final String source = File(provisionalPath).readAsStringSync();
    expect(
      source.contains('const bool dabblerDarkRampProvisional = true;'),
      isTrue,
    );
  });

  group('AC3 — no dark value is asserted by literal anywhere else', () {
    test('the semantic layer declares no Color(0x...) literal at all', () {
      final String source = _code(File('lib/src/tokens/dabbler_colors.dart'));
      expect(
        _hexLiteral.allMatches(source).map((RegExpMatch m) => m.group(0)),
        isEmpty,
        reason: 'dabbler_colors.dart must resolve through the token layers',
      );
    });

    test('every dark hex appears in exactly one file under lib/', () {
      final Set<String> darkHexes = _hexLiteral
          .allMatches(_code(File(provisionalPath)))
          .map((RegExpMatch m) => m.group(1)!.toUpperCase())
          .toSet();
      expect(darkHexes, isNotEmpty);

      for (final File file in _dartFilesUnder('lib/src')) {
        if (file.path.endsWith('dabbler_dark_provisional.dart')) continue;
        final Set<String> found = _hexLiteral
            .allMatches(_code(file))
            .map((RegExpMatch m) => m.group(1)!.toUpperCase())
            .toSet();
        expect(
          found.intersection(darkHexes),
          isEmpty,
          reason: '${file.path} re-declares a provisional dark value',
        );
      }
    });

    test('every colour a dark instance paints traces back to a token layer',
        () {
      // A stronger form of the same claim: walk every field of all seven dark
      // instances and require each value to be one the provisional file or the
      // primitive palette declares — nothing is synthesised in between.
      final Set<int> allowed = <int>{
        for (final File f in <File>[
          File(provisionalPath),
          File('lib/src/tokens/dabbler_palette.dart'),
        ])
          ..._hexLiteral
              .allMatches(_code(f))
              .map((RegExpMatch m) => int.parse(m.group(1)!, radix: 16)),
      };
      for (final DabblerTheme t in DabblerTheme.values) {
        final DabblerColors c =
            DabblerColors.resolve(theme: t, brightness: Brightness.dark);
        for (final (String name, Color v) in <(String, Color)>[
          ('bgPrimary', c.bgPrimary),
          ('bgSecondary', c.bgSecondary),
          ('bgTertiary', c.bgTertiary),
          ('surfaceCard', c.surfaceCard),
          ('surfaceSunken', c.surfaceSunken),
          ('surfaceGrey', c.surfaceGrey),
          ('textPrimary', c.textPrimary),
          ('textSecondary', c.textSecondary),
          ('textTertiary', c.textTertiary),
          ('borderDefault', c.borderDefault),
          ('borderStrong', c.borderStrong),
          ('brandPrimary', c.brandPrimary),
          ('accent', c.accent),
          ('focusRing', c.focusRing),
          ('success.surface', c.success.surface),
          ('warning.surface', c.warning.surface),
          ('error.surface', c.error.surface),
          ('info.surface', c.info.surface),
        ]) {
          expect(
            allowed.contains(v.toARGB32()),
            isTrue,
            reason: '${t.name} dark $name (${v.toARGB32().toRadixString(16)}) '
                'is not declared in a token file',
          );
        }
      }
    });
  });

  test('the provisional file is the only new home for literals', () {
    // Mirrors the DS-101 allowlist so a third literal site fails here too.
    const Set<String> allowlist = <String>{
      'lib/src/tokens/dabbler_palette.dart',
      provisionalPath,
    };
    final List<String> offenders = <String>[
      for (final File f in _dartFilesUnder('lib/src'))
        if (!allowlist.contains(f.path) && _hexLiteral.hasMatch(_code(f))) f.path,
    ];
    expect(offenders, isEmpty);
  });
}
