import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// KAN-228 AC1, as a gate on the source rather than on the rendering:
///
/// > Section/Divider use DS-104 spacing tokens exclusively — no literal
/// > `EdgeInsets`.
///
/// The widget tests in `section_test.dart` and `divider_test.dart` prove that
/// the *rendered* gaps equal the [DabblerSpacing] constants. That is necessary
/// but not sufficient: a file could hard-code `12` and still pass every one of
/// them, because 12 is what `stackDefault` is. So this test reads the two
/// source files and fails on a bare number where a token belongs.
///
/// The two checks:
///
/// 1. **No `EdgeInsets` of any kind carries a digit.** Any argument to an
///    `EdgeInsets*` constructor must be a named constant.
/// 2. **No geometry constructor carries a bare numeric argument.** `SizedBox`,
///    `ConstrainedBox`/`BoxConstraints`, `Padding` and `Radius` are the places
///    a literal would hide.
///
/// Comments are stripped first, so the dartdoc tables that quote the source's
/// own pixel values (`12`, `6`, `24`) do not trip the scan — documenting where
/// a number came from is the house style, and is the opposite of hard-coding
/// it.
const List<String> surfaces = <String>[
  'lib/src/layout/section.dart',
  'lib/src/layout/divider.dart',
];

/// A **bare numeric literal** — a number that is not part of an identifier.
///
/// The lookbehind is what makes the scan usable: `DabblerSpacing.space4` and
/// `DabblerType.caption1` end in digits but are token references, not
/// measurements, and must not trip the gate. Only a number standing on its own
/// is a hard-coded value.
final RegExp _bareNumber = RegExp(r'(?<![A-Za-z0-9_.$])[0-9]+(?:\.[0-9]+)?');

/// Strips `///`, `//` and `/* … */` so only executable Dart is scanned.
String _stripComments(String source) {
  final String noBlock = source.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
  return noBlock
      .split('\n')
      .map((String line) {
        final int slashes = line.indexOf('//');
        return slashes == -1 ? line : line.substring(0, slashes);
      })
      .join('\n');
}

/// Every `Name(...)` call for [constructor] in [code], balanced to one level of
/// nesting — enough for `EdgeInsetsDirectional.symmetric(horizontal: inset)`.
List<String> _calls(String code, String constructor) {
  // `[A-Za-z]*` is load-bearing: without it, `EdgeInsets` does not match
  // `EdgeInsetsDirectional.only(...)`, and the two EdgeInsets checks below
  // pass vacuously on a file whose every inset is directional — which is
  // exactly the file this gate is supposed to police.
  final RegExp head = RegExp('$constructor[A-Za-z]*(?:\\.[a-zA-Z]+)?\\(');
  final List<String> found = <String>[];
  for (final RegExpMatch m in head.allMatches(code)) {
    int depth = 0;
    for (int i = m.end - 1; i < code.length; i++) {
      if (code[i] == '(') depth++;
      if (code[i] == ')') {
        depth--;
        if (depth == 0) {
          found.add(code.substring(m.start, i + 1));
          break;
        }
      }
    }
  }
  return found;
}

/// The **direct** arguments of [call] — the text between its outermost
/// parentheses with every nested parenthesised sub-expression removed.
///
/// Without this, scanning `Padding(padding: …, child: Row(children: [Text(…,
/// maxLines: 1)]))` would read the whole subtree and flag the `1` inside a
/// `Text`, which is not spacing at all. Each nested constructor is checked on
/// its own pass anyway, because `_calls` finds it independently.
String _directArgs(String call) {
  final int open = call.indexOf('(');
  final StringBuffer direct = StringBuffer();
  int depth = 0;
  for (int i = open + 1; i < call.length - 1; i++) {
    final String c = call[i];
    if (c == '(' || c == '[' || c == '{') {
      depth++;
      continue;
    }
    if (c == ')' || c == ']' || c == '}') {
      depth--;
      continue;
    }
    if (depth == 0) direct.write(c);
  }
  return direct.toString();
}

void main() {
  late Map<String, String> sources;

  setUpAll(() {
    sources = <String, String>{
      for (final String path in surfaces)
        path: () {
          final File file = File(path);
          expect(
            file.existsSync(),
            isTrue,
            reason: '$path must exist — it is a KAN-228 surface',
          );
          return _stripComments(file.readAsStringSync());
        }(),
      };
  });

  group('KAN-228 AC1 — spacing comes from DS-104 tokens, never from a '
      'literal', () {
    test('no EdgeInsets anywhere carries a numeric literal', () {
      sources.forEach((String path, String code) {
        for (final String call in _calls(code, 'EdgeInsets')) {
          expect(
            _bareNumber.hasMatch(_directArgs(call)),
            isFalse,
            reason: '$path: literal EdgeInsets value in `$call` — '
                'use a DabblerSpacing constant',
          );
        }
      });
    });

    test('every EdgeInsets is directional', () {
      sources.forEach((String path, String code) {
        final List<String> all = _calls(code, 'EdgeInsets');
        for (final String call in all) {
          expect(
            call.startsWith('EdgeInsetsDirectional'),
            isTrue,
            reason: '$path: `$call` is not RTL-safe — '
                'use EdgeInsetsDirectional',
          );
        }
      });
    });

    test('geometry constructors take constants, not bare numbers', () {
      const List<String> geometry = <String>[
        'SizedBox',
        'BoxConstraints',
        'Padding',
        'Radius',
      ];
      sources.forEach((String path, String code) {
        for (final String constructor in geometry) {
          for (final String call in _calls(code, constructor)) {
            expect(
              _bareNumber.hasMatch(_directArgs(call)),
              isFalse,
              reason: '$path: bare number in `$call` — '
                  'use a DabblerSpacing/DabblerSizing constant',
            );
          }
        }
      });
    });

    test('neither file names left or right', () {
      sources.forEach((String path, String code) {
        for (final String banned in <String>[
          'EdgeInsets.only(left',
          'EdgeInsets.only(right',
          'Alignment.centerLeft',
          'Alignment.centerRight',
          'TextAlign.left',
          'TextAlign.right',
        ]) {
          expect(
            code.contains(banned),
            isFalse,
            reason: '$path: `$banned` is not RTL-safe',
          );
        }
      });
    });

    test('both files actually reach for the spacing tokens', () {
      sources.forEach((String path, String code) {
        expect(
          code.contains('DabblerSpacing.'),
          isTrue,
          reason: '$path must draw its spacing from DabblerSpacing',
        );
      });
    });
  });
}
