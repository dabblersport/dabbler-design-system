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

/// A backticked span — excluded where its number is a symbol, not a value.
final RegExp codeSpan = RegExp(r'`[^`]*`');

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
        if (!RegExp(r'(?<![\w.])' + RegExp.escape(f.numeral) + r'(?![\w.])')
            .hasMatch(body)) {
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
          final String scrubbed = rawLine
              .replaceAll(linkTarget, '')
              .replaceAll(reference, '')
              .replaceAll(codeSpan, '');
          for (final RegExpMatch m in numericToken.allMatches(scrubbed)) {
            final String numeral = m.group(1)!;
            if (covered.contains(numeral)) continue;
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
        brace++;
        sawBrace = true;
      case '}':
        brace--;
        if (sawBrace && brace <= 0) return source.substring(start, i + 1);
      case ';':
        // A declaration with no body at all — a `static const`, a field.
        if (paren <= 0 && brace <= 0) return source.substring(start, i + 1);
    }
  }
  return source.substring(start);
}
