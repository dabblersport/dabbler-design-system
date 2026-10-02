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
  // Fallback: the package-pinned fixture, a transcription of the live Claude
  // Design project 4286affa-bf50-4ff6-9576-917f76a93ca1 file `tokens/colors.css`
  // (read via DesignSync get_file on 2026-10-02, transcribed to a local mirror
  // by the coordinator). See `test/fixtures/live/README.md`.
  final File pinned = File('test/fixtures/live/tokens/colors.css');
  if (pinned.existsSync()) return pinned;
  return null;
}

/// Files under `lib/src/` permitted to declare a raw `Color(0x...)` literal.
const Set<String> literalAllowlist = <String>{
  'lib/src/tokens/dabbler_palette.dart',
  'lib/src/tokens/dabbler_dark_provisional.dart',
};

/// Live tokens the package deliberately does NOT mirror. Each entry is a
/// named, documented exception so this live-parity test cannot silently
/// "fix" the override back to the live value.
///
/// `tag-pending-ink`: live `#B4530E` measures 4.40:1 on `--tag-pending-surface`
/// `#FDEDE3` (fails AA 4.5:1, "a real defect"); the package ships `#A34A08`
/// at 5.20:1. Authority: `Dabbler/dabbler-docs/DECISIONS.md:11914-11919`,
/// ruling cdispatch-d92eff45 (reaffirmed cdispatch-5e71152a). See
/// `test/tokens/tag_pending_ink_override_test.dart`.
const Map<String, ({String live, String package})> liveParityExceptions =
    <String, ({String live, String package})>{
  'tag-pending-ink': (live: 'B4530E', package: 'A34A08'),
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
  final File? source = _findColorsCss();

  group('DabblerPalette transcribes colors.css', () {
    late Map<String, String> tokens;

    setUpAll(() {
      // The source is a sibling checkout; when it is absent the source-backed
      // assertions cannot run, and the group is skipped rather than passing
      // vacuously.
      if (source != null) tokens = _rootHexTokens(source.readAsStringSync());
    });

    test('declares one const Color per :root hex token', () {
      final String source =
          File('lib/src/tokens/dabbler_palette.dart').readAsStringSync();

      // Each token's doc comment records its CSS name; the constant below it
      // must carry that token's exact hex.
      for (final MapEntry<String, String> entry in tokens.entries) {
        final ({String live, String package})? exception =
            liveParityExceptions[entry.key];
        if (exception != null) {
          // The live value is still the one the exception was granted
          // against; if live changes, the exception must be re-judged.
          expect(entry.value, exception.live,
              reason: 'live --${entry.key} changed; re-judge the override');
          expect(
            RegExp('/// `--${RegExp.escape(entry.key)}` — `#${exception.package}`'
                    r'\.[^\n]*\n(?:  ///[^\n]*\n)*'
                    r'  static const Color \w+ = '
                    'Color\\(0xFF${exception.package}\\);')
                .hasMatch(source),
            isTrue,
            reason: 'override for --${entry.key} must be #${exception.package}',
          );
          continue;
        }
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

      // One literal is NOT in `tokens/colors.css`: `--accent-indigo` (#5C50E6),
      // which the live project declares only under `tokens/figma/fig-tokens.css`
      // and which `Avatar.jsx` / `Badge.jsx` / `Button.jsx` consume. Named here
      // so the count stays an exact statement rather than a tolerance.
      expect(tokens.containsKey('accent-indigo'), isFalse);
      expect(DabblerPalette.accentIndigo, const Color(0xFF5C50E6));
      expect(_hexLiteral.allMatches(source).length, tokens.length + 1);
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
  }, skip: source == null
      ? 'tokens/colors.css not found beside the package'
      : false);

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
