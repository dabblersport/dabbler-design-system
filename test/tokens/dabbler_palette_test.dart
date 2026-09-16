import 'dart:io';

import 'package:dabbler_design_system/src/tokens/dabbler_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The design source the palette is transcribed from. It lives outside this
/// package, so it is located by walking up from the package root rather than
/// by a fixed relative path (the package is checked out both directly and as a
/// git worktree at varying depths).
const String colorsCssSuffix =
    'dabbler-design-system-design/project/tokens/colors.css';

File? _findColorsCss() {
  Directory dir = Directory.current;
  for (int i = 0; i < 8; i++) {
    final File candidate = File('${dir.path}/$colorsCssSuffix');
    if (candidate.existsSync()) return candidate;
    final File nested = File('${dir.path}/Dabbler/$colorsCssSuffix');
    if (nested.existsSync()) return nested;
    if (dir.parent.path == dir.path) break;
    dir = dir.parent;
  }
  return null;
}

/// Files under `lib/src/` permitted to declare a raw `Color(0x...)` literal.
const Set<String> literalAllowlist = <String>{
  'lib/src/tokens/dabbler_palette.dart',
  'lib/src/tokens/dabbler_dark_provisional.dart',
};

final RegExp _hexLiteral = RegExp(r'Color\(0x[0-9A-Fa-f]{6,8}\)');

/// Every `--name:#RRGGBB` declared in the `:root` block of `colors.css`.
Map<String, String> _rootHexTokens(String css) {
  final int start = css.indexOf(':root {');
  final int end = css.indexOf('\n}', start);
  final String root = css.substring(start, end);
  return <String, String>{
    for (final RegExpMatch m
        in RegExp(r'--([a-z0-9-]+):#([0-9A-Fa-f]{6})').allMatches(root))
      m.group(1)!: m.group(2)!.toUpperCase(),
  };
}

List<File> _dartFilesUnder(String dir) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((File f) => f.path.endsWith('.dart'))
    .toList();

void main() {
  group('DabblerPalette transcribes colors.css', () {
    late Map<String, String> tokens;

    setUpAll(() {
      final File? css = _findColorsCss();
      expect(
        css,
        isNotNull,
        reason: 'design source not found: */$colorsCssSuffix',
      );
      tokens = _rootHexTokens(css!.readAsStringSync());
    });

    test('declares one const Color per :root hex token', () {
      final String source =
          File('lib/src/tokens/dabbler_palette.dart').readAsStringSync();

      // Each token's doc comment records its CSS name; the constant below it
      // must carry that token's exact hex.
      for (final MapEntry<String, String> entry in tokens.entries) {
        final RegExp decl = RegExp(
          '/// `--${RegExp.escape(entry.key)}` — `#${entry.value}`\\.\\n'
          r'  static const Color \w+ = '
          'Color\\(0xFF${entry.value}\\);',
        );
        expect(
          decl.hasMatch(source),
          isTrue,
          reason: 'no constant for --${entry.key} (#${entry.value})',
        );
      }

      expect(_hexLiteral.allMatches(source).length, tokens.length);
    });

    test('covers all seven theme palettes and their p/s ramps', () {
      const List<String> brandRamps = <String>[
        'main',
        'social',
        'sport',
        'active',
        'bright',
      ];
      for (final String theme in brandRamps) {
        for (final String ramp in <String>['p', 's']) {
          final Iterable<String> shades =
              tokens.keys.where((String k) => k.startsWith('$theme-$ramp-'));
          expect(shades, isNotEmpty, reason: '$theme-$ramp ramp missing');
        }
      }
      // `simple` and `shade` carry no brand ramp — they resolve through ink.
      expect(DabblerPalette.ink900, const Color(0xFF1B1B1B));
      expect(DabblerPalette.ink300, const Color(0xFFC2BFCB));
    });

    test('spot-checks primitives against the source hexes', () {
      expect(DabblerPalette.mainP600, const Color(0xFF7328CE));
      expect(DabblerPalette.socialP600, const Color(0xFF3473D7));
      expect(DabblerPalette.sportP600, const Color(0xFF348638));
      expect(DabblerPalette.activeP600, const Color(0xFFCF3989));
      expect(DabblerPalette.brightP600, const Color(0xFFF6AA4F));
      expect(DabblerPalette.surfacePage, const Color(0xFFF5F0E6));
      expect(DabblerPalette.spotlight500, const Color(0xFFFF5A1F));
    });
  });

  test('no Color(0x...) literal outside the palette files', () {
    final List<String> offenders = <String>[];
    for (final File file in _dartFilesUnder('lib/src')) {
      final String path = file.path.replaceAll(r'\', '/');
      if (literalAllowlist.contains(path)) continue;
      if (_hexLiteral.hasMatch(file.readAsStringSync())) offenders.add(path);
    }
    expect(offenders, isEmpty);
  });

  test('no palette symbol names a "profile" theme', () {
    final String source =
        File('lib/src/tokens/dabbler_palette.dart').readAsStringSync();
    expect(
      RegExp('profile', caseSensitive: false).hasMatch(source),
      isFalse,
      reason: 'colors.css declares no profile theme',
    );
  });

  test('no glass-named symbol exists in the package API', () {
    final List<String> offenders = <String>[];
    final RegExp glassSymbol = RegExp(
      r'^\s*(?:static\s+)?(?:const|final|var|class|abstract|enum|[A-Za-z_<>, ?]+)'
      r'[^\n=(;]*\bglass\w*\b',
      caseSensitive: false,
      multiLine: true,
    );
    for (final File file in <File>[
      ...(_dartFilesUnder('lib/src')),
      ...(_dartFilesUnder('lib').where((File f) => !f.path.contains('/src/'))),
    ]) {
      final String body = file
          .readAsLinesSync()
          .where((String l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      if (glassSymbol.hasMatch(body)) offenders.add(file.path);
    }
    expect(
      offenders,
      isEmpty,
      reason: 'tokens/glass.css is deliberately not ported',
    );
  });
}
