import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';
import '_host.dart';

List<String> _hits(String text, String query) =>
    DabblerHighlightedText.matchRanges(
      text,
      query,
    ).map((TextRange r) => text.substring(r.start, r.end)).toList();

/// The flattened leaf spans of the single rich text under test.
List<TextSpan> _leaves(WidgetTester tester) {
  final RichText rich = tester.widget<RichText>(
    find.descendant(
      of: find.byType(DabblerHighlightedText),
      matching: find.byType(RichText),
    ),
  );
  final List<TextSpan> out = <TextSpan>[];
  rich.text.visitChildren((InlineSpan s) {
    if (s is TextSpan && s.text != null) {
      out.add(s);
    }
    return true;
  });
  return out;
}

void main() {
  group('matchRanges', () {
    test('is case-insensitive and keeps the original casing', () {
      expect(_hits('The Dabbler app', 'dabbler'), <String>['Dabbler']);
      expect(_hits('The DABBLER app', 'Dabbler'), <String>['DABBLER']);
    });

    test('finds every non-overlapping occurrence', () {
      expect(_hits('Dabbler, dabbler, DABBLER', 'dabbler'), hasLength(3));
      expect(_hits('aa aa', 'aa'), <String>['aa', 'aa']);
      // Adjacent matches read as one highlight.
      expect(_hits('aaaa', 'aa'), <String>['aaaa']);
    });

    test('empty query, no occurrence and a query longer than the text', () {
      expect(_hits('abc', ''), isEmpty);
      expect(_hits('abc', 'x'), isEmpty);
      expect(_hits('abc', 'abcd'), isEmpty);
      expect(_hits('', 'a'), isEmpty);
    });

    test('regex metacharacters are literal', () {
      expect(_hits('a.b a+b (x)', '.'), <String>['.']);
      expect(_hits('a.b a+b (x)', 'a+b'), <String>['a+b']);
      expect(_hits('a.b a+b (x)', '(x)'), <String>['(x)']);
    });

    test('Western digits are matched as written, never rewritten', () {
      expect(_hits('Court 12 at 7pm', '12'), <String>['12']);
      expect(_hits('ملعب 12 الساعة 7', '12'), <String>['12']);
    });

    test('Arabic matches', () {
      expect(_hits('لاعب دابلر يبحث عن مباراة', 'دابلر'), <String>['دابلر']);
      expect(_hits('دابلر ودابلر', 'دابلر'), hasLength(2));
    });

    test('a Latin match inside Arabic text', () {
      expect(_hits('تطبيق Dabbler لحجز الملاعب', 'dabbler'), <String>[
        'Dabbler',
      ]);
    });

    test('a match is widened over adjoining Arabic vowel signs', () {
      // ب + fatha + س: the query is the base letter only.
      const String text = 'بَسم';
      expect(_hits(text, 'ب'), <String>['بَ']);
      // A query that already includes the mark is not duplicated.
      expect(_hits(text, 'بَ'), <String>['بَ']);
    });

    test('the regexp fallback agrees with the indexOf path', () {
      // `İ`.toLowerCase() changes length on some platforms, where the indexOf
      // path would drift off the original; the fallback indexes `text`.
      for (final (String, String) c in <(String, String)>[
        ('İstanbul Dabbler dabbler', 'dabbler'),
        ('تطبيق Dabbler لحجز', 'dabbler'),
        ('بَسم', 'ب'),
        ('a.b a+b', 'a+b'),
      ]) {
        expect(
          DabblerHighlightedText.matchRangesByRegExp(c.$1, c.$2),
          DabblerHighlightedText.matchRanges(c.$1, c.$2),
          reason: '${c.$1} / ${c.$2}',
        );
      }
      expect(DabblerHighlightedText.matchRangesByRegExp('abc', ''), isEmpty);
    });
  });

  group('DabblerHighlightedText', () {
    testWidgets('empty query renders one plain span', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerHighlightedText(text: 'The Dabbler', query: '')),
      );
      expect(find.text('The Dabbler'), findsOneWidget);
    });

    testWidgets('the match takes brand colour, semibold and a brand tint', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerHighlightedText(
            text: 'The Dabbler app',
            query: 'dabbler',
          ),
        ),
      );
      final DabblerColors c = testColors();
      final List<TextSpan> leaves = _leaves(tester);
      expect(leaves.map((TextSpan s) => s.text).toList(), <String?>[
        'The ',
        'Dabbler',
        ' app',
      ]);
      final TextStyle hit = leaves[1].style!;
      expect(hit.color, c.brandPrimary);
      expect(hit.fontWeight, FontWeight.w600);
      expect(
        hit.background!.color.toARGB32(),
        Color.alphaBlend(
          c.brandPrimary.withValues(alpha: 0.14),
          c.surfaceCard,
        ).toARGB32(),
      );
      expect(leaves[0].style, isNull, reason: 'unmatched text inherits base');
    });

    testWidgets('unmatched text takes the caller colour, weight and step', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          DabblerHighlightedText(
            text: 'ab',
            query: 'a',
            style: DabblerType.footnote,
            color: testColors().textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      final RichText rich = tester.widget<RichText>(
        find.descendant(
          of: find.byType(DabblerHighlightedText),
          matching: find.byType(RichText),
        ),
      );
      final TextStyle base = (rich.text as TextSpan).children!.first.style!;
      expect(base.fontSize, DabblerType.footnote.fontSize);
      expect(base.fontWeight, FontWeight.w600);
      expect(base.color, testColors().textSecondary);
    });

    testWidgets('semantics is the plain text, in one piece', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          const DabblerHighlightedText(
            text: 'The Dabbler app',
            query: 'dabbler',
          ),
        ),
      );
      expect(find.bySemanticsLabel('The Dabbler app'), findsOneWidget);
      expect(find.bySemanticsLabel('Dabbler'), findsNothing);
      handle.dispose();
    });

    testWidgets('maxLines and ellipsis are honoured', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerHighlightedText(
            text: 'Dabbler Dabbler Dabbler Dabbler Dabbler Dabbler Dabbler',
            query: 'dabbler',
            maxLines: 1,
          ),
          width: 120,
        ),
      );
      final RenderParagraph p = tester.renderObject<RenderParagraph>(
        find.descendant(
          of: find.byType(DabblerHighlightedText),
          matching: find.byType(RichText),
        ),
      );
      expect(p.maxLines, 1);
      expect(p.overflow, TextOverflow.ellipsis);
      expect(p.didExceedMaxLines, isTrue);
    });

    testWidgets('Arabic text is highlighted and set in the Arabic step', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerHighlightedText(
            text: 'لاعب دابلر يبحث عن مباراة',
            query: 'دابلر',
          ),
          direction: TextDirection.rtl,
        ),
      );
      final List<TextSpan> leaves = _leaves(tester);
      expect(leaves.map((TextSpan s) => s.text).toList(), <String?>[
        'لاعب ',
        'دابلر',
        ' يبحث عن مباراة',
      ]);
      expect(leaves[1].style!.color, testColors().brandPrimary);
      final RichText rich = tester.widget<RichText>(
        find.descendant(
          of: find.byType(DabblerHighlightedText),
          matching: find.byType(RichText),
        ),
      );
      expect(
        (rich.text as TextSpan).children!.first.style!.fontSize,
        DabblerType.subheadline.arabicFontSize,
      );
    });

    testWidgets('a Latin match inside an Arabic sentence, RTL', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerHighlightedText(
            text: 'تطبيق Dabbler لحجز الملاعب',
            query: 'dabbler',
          ),
          direction: TextDirection.rtl,
        ),
      );
      expect(_leaves(tester).map((TextSpan s) => s.text).toList(), <String?>[
        'تطبيق ',
        'Dabbler',
        ' لحجز الملاعب',
      ]);
    });

    testWidgets('the paragraph takes the ambient direction', (
      WidgetTester tester,
    ) async {
      const Widget w = DabblerHighlightedText(text: 'دابلر', query: 'دابلر');
      for (final TextDirection d in TextDirection.values) {
        await tester.pumpWidget(host(w, direction: d));
        final RenderParagraph p = tester.renderObject<RenderParagraph>(
          find.descendant(
            of: find.byType(DabblerHighlightedText),
            matching: find.byType(RichText),
          ),
        );
        expect(p.textDirection, d);
      }
    });
  });

  group('DabblerHighlightedText — renders (AC5)', () {
    for (final TextDirection d in TextDirection.values) {
      final String tag = d == TextDirection.ltr ? 'ltr' : 'rtl';
      testWidgets('highlighted text $tag', (WidgetTester tester) async {
        await renderPng(
          tester,
          Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              width: 354,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const DabblerHighlightedText(
                    text: 'The Dabbler player',
                    query: 'dabbler',
                    fontWeight: FontWeight.w600,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 12),
                  const DabblerHighlightedText(
                    text:
                        'Photos from the Dabbler community meetup — every '
                        'Dabbler welcome',
                    query: 'dabbler',
                  ),
                  const SizedBox(height: 12),
                  const DabblerHighlightedText(
                    text: 'لاعب دابلر يبحث عن مباراة 12',
                    query: 'دابلر',
                    maxLines: 1,
                  ),
                  const SizedBox(height: 12),
                  const DabblerHighlightedText(
                    text: 'تطبيق Dabbler لحجز الملاعب',
                    query: 'dabbler',
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
          name: 'highlighted_text_$tag',
          size: const Size(390, 230),
          direction: d,
          alignment: Alignment.topCenter,
        );
      });
    }
  });
}
