/// `@figure` gate — `T-086`, the mechanism `D-043`(e) assigned.
///
/// Run it:
///
/// ```
/// dart run tool/check_doc_figures.dart
/// ```
///
/// Exits non-zero on findings, zero on a clean corpus.
///
/// ## What this proves, and what it does NOT
///
/// **It proves CO-LOCATION: the literal lives inside the named member.** It
/// does **not** prove EVALUATION: that the member actually returns that value
/// at runtime. Nobody reading this should assume the stronger coverage.
///
/// That limit is a consequence, not an oversight. Evaluating the symbol needs
/// `dart:ui`, which needs `flutter test`, which is test code and barred by the
/// standing constraint. Resolving it statically needs `package:analyzer`,
/// which is not a dependency of this package and which — pinned against an
/// unpinned Flutter `stable` channel — recreates the exact breakage
/// `CLAUDE.md` records for `deploy-web.yml` and `ci.yml`. So the gate catches
/// a figure whose literal is not where the page says it is, and cannot catch a
/// member that computes something else from it.
///
/// ## Why it is a script and not a test
///
/// `T-086`(c): a plain `dart run` script, not a file under `test/`, and it
/// does not run inside `flutter test`. This is how the CEO's standing
/// no-new-tests constraint is **met by design** rather than worked around.
///
/// That forces the import list, and the import list is an acceptance criterion
/// in its own right: `doc_page.dart` only, markdown read with `dart:io`, never
/// `rootBundle`. `doc_loader.dart` and `doc_specimen_resolver.dart` both pull
/// in Flutter transitively, so importing either would make this a
/// `flutter test` target again.
///
/// ## One parse, shared with KAN-324
///
/// The `@figure` block is parsed by [DabblerDocSplitter], the same parse the
/// renderer and `KAN-324`'s gate read. There is no second parser here — this
/// file walks blocks, it does not re-tokenise markdown.
library;

import 'dart:io';

import 'package:dabbler_design_system/src/gallery/docs/doc_page.dart';

/// Where the corpus lives, relative to the package root.
const String corpusRoot = 'assets/documentation';

/// `DECISIONS.md`, for a ruling claim. Outside this repository by design —
/// governance is its own repo — so its absence is reported, never assumed.
const String decisionsPath = '../dabbler-docs/DECISIONS.md';

/// One problem, named precisely enough to fix without re-running anything.
class Finding {
  Finding(this.page, this.section, this.line, this.message);

  final String page;
  final String section;
  final int line;
  final String message;

  @override
  String toString() => '$page  [## $section]  line $line\n    $message';
}

/// A numeric token — `T-086`(d), transcribed rather than paraphrased.
///
/// Digits, optionally a decimal part, optionally one of the listed units. The
/// trailing guard is what keeps `80ms` out: a unit this list does not name is
/// not a figure, and `80` glued to letters is not a bare numeric token.
final RegExp numericToken = RegExp(
  r'(?<![\w.])(\d+(?:\.\d+)?)(px|pt|%|dp|:1)?(?![\w.%])',
);

/// A markdown link target — excluded.
final RegExp linkTarget = RegExp(r'\]\([^)]*\)');

/// A governance or ticket reference — excluded.
final RegExp reference = RegExp(r'\b(?:[DTPG]-\d+|KAN-\d+)\b');

/// Counts, not figures — `D-043` via `KAN-335`.
///
/// A figure is a claim about rendered geometry, resolvable to a declaring
/// line. A *cardinality* — how many boxes a `CodeInput` shows — is a prop
/// value the caller chooses; `4` is an example the design source happens to
/// draw and has no declaring site at all. Pinned by page and numeral rather
/// than guessed at by grammar, because "is this number a count" is a reading
/// of the sentence and not a property of the token.
const Map<String, Set<String>> cardinalityExemptions = <String, Set<String>>{
  'components/code-input.md': <String>{'4', '6'},
};

/// A backticked span — excluded where its number is a symbol, not a value.
final RegExp codeSpan = RegExp(r'`[^`]*`');

/// An `N:N` ratio — `16:9`. Excluded: a ratio is a shape, not a figure, and
/// neither half resolves to a declaring site of its own (KAN-335/D-043).
final RegExp ratio = RegExp(r'\d+\s*:\s*\d+');

/// An ordinal range — `titles 1–3`. Those digits name `title1`..`title3`;
/// they are not measurements and can never carry an `@figure`.
final RegExp ordinalRange = RegExp(r'\d+\s*[–—-]\s*\d+');

/// Digits inside a name — `ink-950`, `space-11`. The number is part of an
/// identifier, not a value the prose is claiming.
///
/// Three letters minimum, deliberately: `16/14/12-at-600` would otherwise
/// lose its `600` to the two-letter `at-`, and that 600 is a real weight
/// figure with a declaring site.
final RegExp digitsInName = RegExp(r'[A-Za-z]{3,}-\d+');

void main(List<String> args) {
  final List<Finding> findings = <Finding>[];
  final Directory root = Directory(corpusRoot);
  if (!root.existsSync()) {
    stderr.writeln('no $corpusRoot — run from the package root');
    exit(2);
  }

  final String decisions = File(decisionsPath).existsSync()
      ? File(decisionsPath).readAsStringSync()
      : '';

  final List<File> pages = root
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.md') && !f.path.endsWith('_order.md'))
      .toList()
    ..sort((File a, File b) => a.path.compareTo(b.path));

  int figures = 0;
  for (final File file in pages) {
    final String raw = file.readAsStringSync();
    final DabblerDocPage page = DabblerDocSplitter.split(file.path, raw);
    final List<String> lines = raw.split('\n');

    // The page's own `## Source` section, for the declared-figure check.
    final Set<String> sourcePaths = <String>{};
    for (final DabblerDocSection s in page.sections) {
      if (s.heading != 'Source') continue;
      for (final DabblerDocBlock b in s.blocks) {
        if (b is DabblerDocProse) {
          for (final RegExpMatch m
              in RegExp(r'`([^`]+\.dart)`').allMatches(b.markup)) {
            sourcePaths.add(m.group(1)!);
          }
        }
      }
    }

    for (final DabblerDocSection section in page.sections) {
      final List<DabblerDocFigure> declared =
          section.blocks.whereType<DabblerDocFigure>().toList();
      figures += declared.length;

      // --- Resolution, for every @figure anywhere on the page.
      for (final DabblerDocFigure f in declared) {
        final int at = _lineOf(lines, '@figure ${f.value} ${f.claim}');
        if (f.numeral.isEmpty) {
          findings.add(Finding(file.path, section.heading, at,
              '@figure value "${f.value}" carries no digits'));
          continue;
        }
        if (f.isRuling) {
          if (decisions.isEmpty) {
            findings.add(Finding(file.path, section.heading, at,
                'ruling claim ${f.claim} cannot be checked: no $decisionsPath'));
          } else if (!RegExp('^### ${RegExp.escape(f.claim)}\\b', multiLine: true)
              .hasMatch(decisions)) {
            findings.add(Finding(file.path, section.heading, at,
                'ruling ${f.claim} has no `### ${f.claim}` heading in DECISIONS.md'));
          }
          continue;
        }
        final String? path = f.claimPath;
        final String? member = f.claimMember;
        if (path == null || member == null) {
          findings.add(Finding(file.path, section.heading, at,
              'claim "${f.claim}" is neither <path>#<member> nor a ruling id'));
          continue;
        }
        final File source = File(path);
        if (!source.existsSync()) {
          findings.add(Finding(file.path, section.heading, at,
              'claim names $path, which does not exist'));
          continue;
        }
        final String? body = _memberBody(source.readAsStringSync(), member);
        if (body == null) {
          findings.add(Finding(file.path, section.heading, at,
              'no declaration of `$member` found in $path'));
          continue;
        }
        if (!_occursIn(body, f)) {
          findings.add(Finding(file.path, section.heading, at,
              'the literal ${f.numeral} does not occur inside `$member` in '
              '$path — co-location not proved'));
        }
        // A DECLARED figure's file must be one the page's own `## Source`
        // cites; that is D-043's definition of declared, enforced not
        // trusted. A token file is exempt — those legitimately sit outside.
        final bool isToken = path.contains('/tokens/');
        if (!isToken &&
            !sourcePaths.any((String cited) => path.endsWith(cited) || cited.endsWith(path))) {
          findings.add(Finding(file.path, section.heading, at,
              '$path is not cited in this page\'s `## Source` — a declared '
              'figure must name a file the page already sources'));
        }
      }

      // --- Completeness: `## Axes` only (D-043(b)'s finding is the warrant).
      if (section.heading != 'Axes') continue;
      final Set<String> covered =
          declared.map((DabblerDocFigure f) => f.numeral).toSet();
      for (final DabblerDocBlock b in section.blocks) {
        final String text = switch (b) {
          DabblerDocProse(:final String markup) => markup,
          DabblerDocSubheading(:final String text) => text,
          _ => '',
        };
        if (text.isEmpty) continue;
        for (final String rawLine in text.split('\n')) {
          // Order matters: names and ranges are stripped before the token
          // scan, or their digits survive as phantom figures.
          final String scrubbed = rawLine
              .replaceAll(linkTarget, '')
              .replaceAll(reference, '')
              .replaceAll(codeSpan, '')
              .replaceAll(digitsInName, '')
              .replaceAll(ratio, '')
              .replaceAll(ordinalRange, '');
          for (final RegExpMatch m in numericToken.allMatches(scrubbed)) {
            final String numeral = m.group(1)!;
            if (covered.contains(numeral)) continue;
            final String relative = file.path.startsWith('$corpusRoot/')
                ? file.path.substring(corpusRoot.length + 1)
                : file.path;
            if (cardinalityExemptions[relative]?.contains(numeral) ?? false) {
              continue;
            }
            findings.add(Finding(
              file.path,
              section.heading,
              _lineOf(lines, rawLine),
              'undeclared figure "${m.group(0)}" — no @figure in this section '
              'claims it',
            ));
          }
        }
      }
    }
  }

  stdout.writeln('@figure gate — ${pages.length} pages, $figures directives');
  if (findings.isEmpty) {
    stdout.writeln('clean');
    exit(0);
  }
  stdout.writeln('${findings.length} finding(s):');
  for (final Finding f in findings) {
    stdout.writeln(f);
  }
  exit(1);
}

/// Whether [figure]'s value occurs as a literal inside [body].
///
/// **Percentage / fraction equivalence — KAN-335.** Prose writes `45%` where
/// Dart writes `0.45`, and a plain digit match cannot bridge that: `45` sits
/// inside `0.45` but is preceded by a dot, which the word-boundary guard
/// rejects — correctly, or `0.456` would satisfy a claim of `45`. So a
/// percentage claim is also tried as its fraction, exactly.
///
/// Only a `%` value earns the second form. A bare `45` still means 45 and is
/// never satisfied by `0.45`, because a figure that does not say percent is
/// not claiming one.
bool _occursIn(String body, DabblerDocFigure figure) {
  bool literal(String n) =>
      RegExp(r'(?<![\w.])' + RegExp.escape(n) + r'(?![\w.])').hasMatch(body);

  if (literal(figure.numeral)) return true;

  // A font weight. Prose writes `600`; Dart writes `FontWeight.w600`, where
  // the digits sit inside an identifier and the word-boundary guard rightly
  // refuses them. Same representation problem as the percentage below, and
  // narrow on purpose: three digits, `w`-prefixed, nothing else. The guard
  // allows a preceding dot, because the form is always `FontWeight.w600`.
  if (RegExp(r'^\d{3}$').hasMatch(figure.numeral) &&
      RegExp('(?<![\\w])w${figure.numeral}(?![\\w])').hasMatch(body)) {
    return true;
  }

  if (!figure.value.contains('%')) return false;

  final num? asPercent = num.tryParse(figure.numeral);
  if (asPercent == null) return false;
  // `45%` -> `0.45`, `60%` -> `0.6`, `7.5%` -> `0.075`. Trailing zeros are
  // dropped so 0.60 and 0.6 both match what Dart would actually be written as.
  final String fraction = (asPercent / 100)
      .toStringAsFixed(6)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
  return literal(fraction);
}

/// The 1-based line [needle] sits on, or 0 when it cannot be located.
int _lineOf(List<String> lines, String needle) {
  final String want = needle.trim();
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].trim() == want) return i + 1;
  }
  return 0;
}

/// The source text of [member]'s declaration, located STRUCTURALLY.
///
/// Never a whole-file grep — `T-086`(4) is explicit. The declaring line is
/// found, then the body is taken to the matching close brace, or to the `;`
/// when the declaration carries no brace (a `static const`, an enum
/// constructor arg).
String? _memberBody(String source, String member) {
  final RegExp declaration = RegExp(
    r'^[ \t]*(?:[\w<>,\?\[\] ]+[ \t]+)?' + RegExp.escape(member) + r'\b',
    multiLine: true,
  );
  final RegExpMatch? m = declaration.firstMatch(source);
  if (m == null) return null;
  final int start = m.start;
  // Parens and braces are counted SEPARATELY. Counting them together ended a
  // method at the close of its parameter list, before its body had been
  // read — which reported a literal as absent when it was three lines below.
  int paren = 0;
  int brace = 0;
  bool sawBrace = false;
  for (int i = start; i < source.length; i++) {
    switch (source[i]) {
      case '(':
        paren++;
      case ')':
        paren--;
      case '{':
        // A `{` while a paren is open is a NAMED PARAMETER list, not the
        // body: `resolve({required ...})` would otherwise "close" at the end
        // of its own parameters and hide everything the member actually does.
        if (paren == 0) {
          brace++;
          sawBrace = true;
        }
      case '}':
        if (paren == 0) {
          brace--;
          if (sawBrace && brace <= 0) return source.substring(start, i + 1);
        }
      case ';':
        // A declaration with no body at all — a `static const`, a field.
        if (paren <= 0 && brace <= 0) return source.substring(start, i + 1);
    }
  }
  return source.substring(start);
}
