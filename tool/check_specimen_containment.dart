/// Containment gate — `KAN-332`, the mechanism `D-047`(e) recommended.
///
/// Run it:
///
/// ```
/// dart run tool/check_specimen_containment.dart
/// ```
///
/// Exits non-zero on findings, zero on a clean registry.
///
/// ## What it checks
///
/// **One direction only: every [GalleryEntry.page] names a doc page that
/// exists.** `page: 'components/button'` must resolve to
/// `assets/documentation/components/button.md`.
///
/// Explicitly NOT this gate's job: the reverse direction. A documentation
/// page with no entry naming it is legitimate and documented as such on
/// `GalleryEntry.page` — "one page per entry, not one entry per page" — so
/// reporting it would be reporting the design.
///
/// ## Why it exists at all
///
/// `D-046`(d) said no gate was needed, on the premise that the nav and the
/// index share `GalleryIndex._bands()`. `D-047`(e) found that premise
/// impossible to follow — the two views cover different object sets, 45
/// specimen pages against 58 doc pages, and cannot be merged. With the
/// shared derivation withdrawn, the drift it was meant to prevent is real
/// again, and this is what catches it.
///
/// ## Why it is a script and not a test
///
/// The `T-086` pattern, satisfying the standing no-new-tests constraint the
/// same way [check_doc_figures.dart] does: a plain `dart run` script, not a
/// file under `test/`, and it does not run inside `flutter test`.
///
/// That forces the approach. The registry is `galleryEntries` in
/// `lib/main.dart`, and every list it spreads is a Flutter-importing library —
/// so this file cannot import the registry and read it. It READS THE SOURCE
/// instead, with `dart:io` and nothing else.
///
/// **What that limit means.** The parse is structural — the spread list is
/// resolved to its declaration, the declaration to its `GalleryEntry(...)`
/// literals, each literal to its own `id:` and `page:` — but it is still a
/// parse of text, not of a program. An entry whose `page` is not a plain
/// string literal cannot be checked, and is REPORTED as such rather than
/// skipped: a gate that silently passes what it could not read is worse than
/// no gate. The same is true of a spread this file cannot resolve to a
/// declaration.
library;

import 'dart:io';

/// Where the corpus lives, relative to the package root.
const String corpusRoot = 'assets/documentation';

/// The registry's own file — the single list this gate is defined against.
const String registryPath = 'lib/main.dart';

/// Where the spread lists are declared.
const String libRoot = 'lib';

/// One problem, named precisely enough to fix without re-running anything.
///
/// `KAN-332`: a finding names the entry's id and the missing page path. No
/// summary counts — a count tells you the gate is red and nothing about what
/// to do next.
class Finding {
  Finding(this.entryId, this.message);

  /// The `id:` of the offending entry, or the spread/list name where no
  /// entry could be identified.
  final String entryId;

  final String message;

  @override
  String toString() => '$entryId\n    $message';
}

/// One `GalleryEntry(...)` literal, as read off the source.
class ParsedEntry {
  ParsedEntry(this.id, this.page, this.file);

  /// The `id:` literal, or null when it is not a plain string.
  final String? id;

  /// The `page:` literal, or null when it is not a plain string.
  final String? page;

  /// The file the literal was read from, for a finding that needs it.
  final String file;
}

void main(List<String> args) {
  final List<Finding> findings = <Finding>[];

  if (!Directory(corpusRoot).existsSync() || !File(registryPath).existsSync()) {
    stderr.writeln('no $corpusRoot or $registryPath — run from the package root');
    exit(2);
  }

  final List<String> spreads = _registrySpreads(_stripComments(File(registryPath).readAsStringSync()));
  if (spreads.isEmpty) {
    stderr.writeln('no spreads found in $registryPath\'s galleryEntries — '
        'the registry moved, and this gate is checking nothing');
    exit(2);
  }

  final List<ParsedEntry> entries = <ParsedEntry>[];

  for (final String spread in spreads) {
    final _ListDeclaration? declaration = _findList(spread);
    if (declaration == null) {
      findings.add(Finding(spread,
          'spread in $registryPath resolves to no `List<GalleryEntry> $spread` '
          'declaration under $libRoot/ — unreadable, so unchecked'));
      continue;
    }
    final List<ParsedEntry> parsed = _entriesIn(declaration);
    if (parsed.isEmpty) {
      findings.add(Finding(spread,
          'no GalleryEntry literal found in ${declaration.file} — unreadable, '
          'so unchecked'));
      continue;
    }
    entries.addAll(parsed);
  }

  for (final ParsedEntry entry in entries) {
    if (entry.id == null) {
      findings.add(Finding('<unnamed entry in ${entry.file}>',
          'its `id:` is not a plain string literal — unreadable, so the entry '
          'cannot be named in a finding'));
    }
    final String name = entry.id ?? '<unnamed entry in ${entry.file}>';
    if (entry.page == null) {
      findings.add(Finding(name,
          'its `page:` is not a plain string literal — unreadable, so '
          'containment cannot be proved'));
      continue;
    }
    final String path = '$corpusRoot/${entry.page}.md';
    if (!File(path).existsSync()) {
      findings.add(Finding(name, 'names $path, which does not exist'));
    }
  }

  stdout.writeln('containment gate — ${spreads.length} spreads, '
      '${entries.length} entries');
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

/// The names `galleryEntries` spreads, in declaration order.
///
/// Scoped to that one list's own brackets, not the whole file: a `...name`
/// anywhere else in `main.dart` is not the registry, and the registry is what
/// this gate is defined against.
List<String> _registrySpreads(String source) {
  final int at = source.indexOf(RegExp(r'galleryEntries\s*=\s*<GalleryEntry>\['));
  if (at < 0) return const <String>[];
  final int open = source.indexOf('[', at);
  final String body = _balanced(source, open, '[', ']');
  return RegExp(r'\.\.\.(\w+)')
      .allMatches(body)
      .map((RegExpMatch m) => m.group(1)!)
      .toList();
}

/// A list declaration located in a file.
class _ListDeclaration {
  _ListDeclaration(this.file, this.body);

  final String file;

  /// The source between the list's own `[` and its matching `]`, inclusive.
  final String body;
}

/// The declaration of `List<GalleryEntry> [name]`, searched across `lib/`.
_ListDeclaration? _findList(String name) {
  final RegExp declaration = RegExp(
    r'List<GalleryEntry>\s+' + RegExp.escape(name) + r'\s*=\s*<GalleryEntry>\[',
  );
  final List<File> files = Directory(libRoot)
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))
      .toList()
    ..sort((File a, File b) => a.path.compareTo(b.path));

  for (final File file in files) {
    final String source = _stripComments(file.readAsStringSync());
    final RegExpMatch? m = declaration.firstMatch(source);
    if (m == null) continue;
    final int open = source.indexOf('[', m.start);
    return _ListDeclaration(file.path, _balanced(source, open, '[', ']'));
  }
  return null;
}

/// Every `GalleryEntry(...)` literal inside [declaration], with its `id:` and
/// `page:`.
///
/// Each literal's own balanced parenthesis span is taken before either field
/// is read, so a nested builder's `GalleryEntry`-shaped argument can never
/// lend its `page:` to the entry above it.
List<ParsedEntry> _entriesIn(_ListDeclaration declaration) {
  final List<ParsedEntry> parsed = <ParsedEntry>[];
  final RegExp literal = RegExp(r'\bGalleryEntry\s*\(');
  for (final RegExpMatch m in literal.allMatches(declaration.body)) {
    final int open = declaration.body.indexOf('(', m.start);
    final String span = _balanced(declaration.body, open, '(', ')');
    parsed.add(ParsedEntry(
      _stringField(span, 'id'),
      _stringField(span, 'page'),
      declaration.file,
    ));
  }
  return parsed;
}

/// The value of `[field]: '<literal>'` at the TOP LEVEL of [span].
///
/// Depth-guarded: a `page:` inside a nested call belongs to that call. Only
/// a plain single- or double-quoted literal with no interpolation counts;
/// anything else returns null and is reported by the caller.
String? _stringField(String span, String field) {
  final RegExp candidate = RegExp(
    '''\\b${RegExp.escape(field)}\\s*:\\s*(?:'([^'\$\\\\]*)'|"([^"\$\\\\]*)")''',
  );
  for (final RegExpMatch m in candidate.allMatches(span)) {
    if (_depthAt(span, m.start) != 1) continue;
    return m.group(1) ?? m.group(2);
  }
  // Present but not a plain literal, or absent: both are "cannot be read".
  return null;
}

/// The parenthesis nesting depth at [index] within [span], where [span] opens
/// with the entry's own `(` — so the entry's own arguments sit at depth 1.
int _depthAt(String span, int index) {
  int depth = 0;
  bool inString = false;
  String quote = '';
  for (int i = 0; i < index; i++) {
    final String c = span[i];
    if (inString) {
      if (c == '\\') {
        i++;
      } else if (c == quote) {
        inString = false;
      }
      continue;
    }
    switch (c) {
      case "'":
      case '"':
        inString = true;
        quote = c;
      case '(':
        depth++;
      case ')':
        depth--;
    }
  }
  return depth;
}

/// [source] with comments blanked out, length preserved is NOT required —
/// every consumer re-searches the stripped text, so indices stay internally
/// consistent.
///
/// Necessary, not decorative: an apostrophe in a doc comment (`the page's`)
/// would otherwise open a string literal that never closes, and every span
/// scanned after it would run to end of file.
String _stripComments(String source) {
  final StringBuffer out = StringBuffer();
  bool inString = false;
  String quote = '';
  for (int i = 0; i < source.length; i++) {
    final String c = source[i];
    if (inString) {
      out.write(c);
      if (c == '\\' && i + 1 < source.length) {
        out.write(source[i + 1]);
        i++;
      } else if (c == quote) {
        inString = false;
      }
      continue;
    }
    if (c == "'" || c == '"') {
      inString = true;
      quote = c;
      out.write(c);
      continue;
    }
    if (c == '/' && i + 1 < source.length && source[i + 1] == '/') {
      while (i < source.length && source[i] != '\n') {
        i++;
      }
      out.write('\n');
      continue;
    }
    if (c == '/' && i + 1 < source.length && source[i + 1] == '*') {
      i += 2;
      while (i + 1 < source.length && !(source[i] == '*' && source[i + 1] == '/')) {
        i++;
      }
      i++;
      continue;
    }
    out.write(c);
  }
  return out.toString();
}

/// The substring from [open] to its matching close, inclusive.
///
/// String literals are skipped, so a bracket inside prose — a description, a
/// doc comment — never closes a span early.
String _balanced(String source, int open, String opener, String closer) {
  int depth = 0;
  bool inString = false;
  String quote = '';
  for (int i = open; i < source.length; i++) {
    final String c = source[i];
    if (inString) {
      if (c == '\\') {
        i++;
      } else if (c == quote) {
        inString = false;
      }
      continue;
    }
    if (c == "'" || c == '"') {
      inString = true;
      quote = c;
      continue;
    }
    if (c == opener) depth++;
    if (c == closer) {
      depth--;
      if (depth == 0) return source.substring(open, i + 1);
    }
  }
  return source.substring(open);
}
