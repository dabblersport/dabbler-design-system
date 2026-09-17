/// The enforced half of `DECISIONS.md` D-003(a) (KAN-260).
///
/// `--subtle` (`#B8B0A0`, 2.15:1 on a card) and `--muted` (`#8C8C8C`, 3.36:1)
/// are surface-ramp neutrals inherited verbatim from "Dabbler Design UI.fig".
/// They are **not defects** and nothing here changes their hex. What this file
/// enforces is the mapping laid over them:
///
/// * `--subtle` is not a text role at all. It fails even AA-large, so it
///   cannot paint body text, tertiary text, or a placeholder — a placeholder
///   is text under WCAG 1.4.3.
/// * `--muted` is large-text-only (≥24px, or ≥18.66px bold), icons,
///   non-informational rules, and the disabled state of a control.
/// * Secondary body text is [DabblerPalette.inkSoft].
///
/// Three gates, deliberately overlapping, because each one alone has a hole:
/// the static scan catches a component reaching past the semantic layer to the
/// raw token, and the resolved-value gates catch the semantic layer itself
/// being re-pointed at a surface neutral — which is exactly the state this
/// ticket found the package in, and which no amount of file scanning would
/// have seen.
///
/// **The dark ramp is out of scope by ruling, not by oversight.**
/// `DabblerProvisionalDark.textSecondary` *is* [DabblerPalette.subtle], and on
/// `#141414` it measures above 4.5:1. D-003 reopens only the light/paper
/// ramp's role mapping; the dark ramp's structure is D-003(c), a separate
/// ticket that is not actionable until `colors.css` is re-exported. That
/// exemption is asserted below rather than assumed, so the day the dark ramp
/// moves, this file notices.
library;

import 'dart:io';

import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_dark_provisional.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


/// Files under `lib/src/` permitted to name [DabblerPalette.subtle] or
/// [DabblerPalette.muted] at all. Everything else must reach them through
/// [DabblerColors], which is where the role mapping lives and is therefore the
/// only place the mapping can be audited.
const Set<String> tokenLayerAllowlist = <String>{
  'lib/src/tokens/dabbler_palette.dart',
  'lib/src/tokens/dabbler_colors.dart',
  'lib/src/tokens/dabbler_dark_provisional.dart',
};

/// Parameters and constructors that paint text. A `--subtle`/`--muted`
/// reference on the same logical expression as one of these is a text colour,
/// whatever the surrounding widget is called.
final RegExp _textPaintingContext = RegExp(
  r'\b('
  r'TextStyle|DefaultTextStyle|'
  r'[a-zA-Z]*[tT]extStyle|' // textStyle, hintStyle is caught below
  r'hintStyle|labelStyle|helperStyle|errorStyle|prefixStyle|suffixStyle|'
  r'counterStyle|floatingLabelStyle|titleTextStyle|contentTextStyle|'
  r'toolbarTextStyle|'
  r'style|foreground|textColor|'
  r'Text'
  r')\b',
);

final RegExp _bannedToken = RegExp(r'DabblerPalette\.(subtle|muted)\b');

List<File> _dartFilesUnder(String dir) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((File f) => f.path.endsWith('.dart'))
    .toList();

String _relative(File f) {
  final String path = f.path.replaceAll(r'\', '/');
  final int i = path.indexOf('/lib/src/');
  return i == -1 ? path : path.substring(i + 1);
}

/// Strips `//` line comments and `///` dartdoc so that *documenting* the rule
/// is not itself a violation of it. Without this the gate would fire on every
/// file that explains why it does not use the token — including this one's
/// counterparts — and a gate that punishes documentation gets deleted.
String _stripComments(String source) => source
    .split('\n')
    .map((String line) {
      final int i = line.indexOf('//');
      return i == -1 ? line : line.substring(0, i);
    })
    .join('\n');

/// Every `(file, lineNumber, line)` under `lib/src/` where a banned token is
/// named in a text-painting context.
List<(String, int, String)> scanForTokenAsText(List<File> files) {
  final List<(String, int, String)> hits = <(String, int, String)>[];
  for (final File file in files) {
    final String relative = _relative(file);
    if (tokenLayerAllowlist.contains(relative)) continue;
    final List<String> lines = _stripComments(file.readAsStringSync()).split(
      '\n',
    );
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      if (!_bannedToken.hasMatch(line)) continue;
      // A banned token anywhere outside the token layer is already a finding;
      // a banned token in a text-painting context is the specific one D-003(a)
      // names. Both are reported, so the check cannot pass vacuously just
      // because the offending call was spread over two lines.
      final String window = <String>[
        if (i > 0) lines[i - 1],
        line,
        if (i + 1 < lines.length) lines[i + 1],
      ].join(' ');
      hits.add((
        relative,
        i + 1,
        _textPaintingContext.hasMatch(window)
            ? 'text-painting context: ${line.trim()}'
            : 'raw token outside the token layer: ${line.trim()}',
      ));
    }
  }
  return hits;
}

void main() {
  group('D-003(a) — `--subtle` is not a text role, `--muted` is large-text '
      'only', () {
    late List<File> libFiles;

    setUpAll(() {
      final Directory lib = Directory('lib/src');
      expect(
        lib.existsSync(),
        isTrue,
        reason: 'run this from the package root; lib/src must exist',
      );
      libFiles = _dartFilesUnder('lib/src');
      expect(libFiles.length, greaterThan(20),
          reason: 'the scan found almost nothing — it is not looking at the '
              'package, and would pass vacuously');
    });

    test('no component names --subtle or --muted directly', () {
      final List<(String, int, String)> hits = scanForTokenAsText(libFiles);
      expect(
        hits,
        isEmpty,
        reason: 'D-003(a): components reach these tokens through '
            'DabblerColors, never by name. Found:\n'
            '${hits.map(((String, int, String) h) => '  ${h.$1}:${h.$2} — '
                '${h.$3}').join('\n')}',
      );
    });

    // The scanner's own guard. If the regex ever stops matching what it is
    // meant to police — the failure mode DS-504 hit, where a pattern passed
    // vacuously on exactly the files it existed for — this fails instead of
    // the suite going quietly green.
    test('the scanner detects a violation when one is present', () {
      final Directory tmp = Directory.systemTemp.createTempSync('d003_gate');
      addTearDown(() => tmp.deleteSync(recursive: true));
      final File planted = File('${tmp.path}/lib/src/planted_violation.dart')
        ..createSync(recursive: true)
        ..writeAsStringSync('''
import 'package:flutter/material.dart';
import 'tokens/dabbler_palette.dart';

Widget build(BuildContext context) => Text(
      'hello',
      style: TextStyle(color: DabblerPalette.subtle),
    );
''');
      final List<(String, int, String)> hits = scanForTokenAsText(<File>[
        planted,
      ]);
      expect(hits, hasLength(1));
      expect(hits.single.$3, contains('text-painting context'));

      // And the comment-stripper does not create a hole: the same token named
      // only in a dartdoc line is NOT a violation.
      final File documented = File('${tmp.path}/lib/src/documented.dart')
        ..createSync(recursive: true)
        ..writeAsStringSync('''
/// Never [DabblerPalette.subtle] — see D-003(a).
// DabblerPalette.muted is not used here either.
const int x = 0;
''');
      expect(scanForTokenAsText(<File>[documented]), isEmpty);
    });

    test('no LIGHT text role resolves to --subtle, in any of the 7 themes', () {
      for (final DabblerTheme theme in DabblerTheme.values) {
        final DabblerColors c = DabblerColors.resolve(
          theme: theme,
          brightness: Brightness.light,
        );
        for (final (String name, Color value) in <(String, Color)>[
          ('textPrimary', c.textPrimary),
          ('textSecondary', c.textSecondary),
          ('textTertiary', c.textTertiary),
        ]) {
          expect(
            value,
            isNot(DabblerPalette.subtle),
            reason: '$theme.$name resolves to --subtle (2.15:1), which '
                'D-003(a) forbids as a text colour outright',
          );
        }
      }
    });

    test('secondary body text is --ink-soft, not --muted, in all 7 themes', () {
      for (final DabblerTheme theme in DabblerTheme.values) {
        final DabblerColors c = DabblerColors.resolve(
          theme: theme,
          brightness: Brightness.light,
        );
        expect(c.textSecondary, DabblerPalette.inkSoft, reason: '$theme');
        expect(c.textSecondary, isNot(DabblerPalette.muted), reason: '$theme');
      }
    });

    test('--muted survives only as the tertiary de-emphasis role', () {
      final DabblerColors c = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      expect(c.textTertiary, DabblerPalette.muted);
      // The role it is allowed to serve: AA-large (3:1), and not AA body.
      expect(c.textTertiary, isNot(c.textSecondary));
    });

    test('the dark ramp is the one recorded exemption, and it is deliberate',
        () {
      // D-003(c), not this ticket. Asserted so that a change to the dark ramp
      // has to come back through here rather than slipping past a gate that
      // only ever looked at light.
      expect(DabblerProvisionalDark.textSecondary, DabblerPalette.subtle);
      expect(DabblerProvisionalDark.textTertiary, DabblerPalette.muted);
      final DabblerColors dark = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.dark,
      );
      expect(dark.textSecondary, DabblerProvisionalDark.textSecondary);
      expect(dark.textTertiary, DabblerProvisionalDark.textTertiary);
    });
  });
}
