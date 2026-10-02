// User-authored messaging text takes its paragraph direction from its own
// first strong character (HTML dir="auto"), not the ambient Directionality.
import 'dart:io';

import 'package:dabbler_design_system/src/messaging/message.dart';
import 'package:dabbler_design_system/src/messaging/messaging_auto_direction.dart';
import 'package:dabbler_design_system/src/messaging/messaging_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';
import 'messaging_parts_host.dart';

RenderParagraph _p(WidgetTester t, String s) =>
    t.renderObject<RenderParagraph>(find.text(s));

/// The x of the last character's box relative to the paragraph's own centre:
/// positive means it is drawn at the right.
double _lastCharSide(RenderParagraph p, String s) {
  final List<TextBox> boxes = p.getBoxesForSelection(
    TextSelection(baseOffset: s.length - 1, extentOffset: s.length),
  );
  return boxes.first.left - p.size.width / 2;
}

void main() {
  group('DabblerAutoDirection.detect', () {
    test('first strong character decides', () {
      expect(DabblerAutoDirection.detect('Who has a ball?'), TextDirection.ltr);
      expect(DabblerAutoDirection.detect('مين معه كرة؟'), TextDirection.rtl);
      expect(DabblerAutoDirection.detect('7 ملعب'), TextDirection.rtl);
      expect(DabblerAutoDirection.detect('ok ملعب'), TextDirection.ltr);
    });
    test('no strong character inherits the ambient direction', () {
      expect(DabblerAutoDirection.detect('17:02 👍 ?'), isNull);
      expect(
        DabblerAutoDirection.resolve('17:02', TextDirection.rtl),
        TextDirection.rtl,
      );
    });
  });

  group('Message content', () {
    const String en = 'I will bring one.';
    const String ar = 'سأحضر واحدة.';

    testWidgets('Latin in RTL ambient is an LTR paragraph, stop at the right', (
      tester,
    ) async {
      await tester.pumpWidget(
        partsHost(
          const DabblerMessage(content: en),
          direction: TextDirection.rtl,
        ),
      );
      final RenderParagraph p = _p(tester, en);
      expect(p.textDirection, TextDirection.ltr);
      expect(_lastCharSide(p, en), greaterThan(0));
    });

    testWidgets('Arabic in LTR ambient is an RTL paragraph, stop at the left', (
      tester,
    ) async {
      await tester.pumpWidget(partsHost(const DabblerMessage(content: ar)));
      final RenderParagraph p = _p(tester, ar);
      expect(p.textDirection, TextDirection.rtl);
      expect(_lastCharSide(p, ar), lessThan(0));
    });

    testWidgets('bubble placement stays on the ambient side', (tester) async {
      await tester.pumpWidget(
        partsHost(
          const DabblerMessage(content: en),
          direction: TextDirection.rtl,
        ),
      );
      final Rect text = tester.getRect(find.text(en));
      // RTL ambient, incoming: the bubble sits at the right (inline start).
      expect(text.center.dx, greaterThan(180));
    });
  });

  group('MessageReplyReference', () {
    testWidgets('Latin sender and content in RTL are LTR, start at the left', (
      tester,
    ) async {
      await tester.pumpWidget(
        partsHost(
          const DabblerMessageReplyReference(
            sender: 'Layla',
            content: 'Court 2 is booked.',
          ),
          direction: TextDirection.rtl,
        ),
      );
      for (final String s in <String>['Layla', 'Court 2 is booked.']) {
        final RenderParagraph p = _p(tester, s);
        expect(p.textDirection, TextDirection.ltr, reason: s);
        expect(p.textAlign, TextAlign.start, reason: s);
      }
    });

    testWidgets('Arabic content in LTR is RTL', (tester) async {
      await tester.pumpWidget(
        partsHost(
          const DabblerMessageReplyReference(sender: 'ليلى', content: 'تم.'),
        ),
      );
      expect(_p(tester, 'تم.').textDirection, TextDirection.rtl);
      expect(_p(tester, 'ليلى').textDirection, TextDirection.rtl);
    });
  });

  testWidgets('renders mixed-direction bubbles in RTL and LTR', (tester) async {
    for (final TextDirection d in TextDirection.values) {
      final File f = await renderPng(
        tester,
        const SizedBox(
          width: 390,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DabblerMessage(content: 'Who has a ball?'),
              DabblerMessage(
                direction: DabblerMessageDirection.outgoing,
                content: 'I will bring one.',
              ),
              DabblerMessage(content: 'مين معه كرة؟'),
              DabblerMessageReplyReference(
                sender: 'Layla',
                content: 'Court 2 is booked for 7pm.',
              ),
            ],
          ),
        ),
        name: 'auto_direction_${d.name}',
        size: const Size(390, 300),
        direction: d,
        alignment: Alignment.topCenter,
      );
      expect(f.lengthSync(), greaterThan(1000));
    }
  });

  test('messaging gallery specimens use Western digits only', () {
    final RegExp easternDigits = RegExp('[٠-٩۰-۹]');
    final List<File> files = Directory('lib/src/messaging')
        .listSync()
        .whereType<File>()
        .where((File f) => f.path.endsWith('_gallery.dart'))
        .toList();
    expect(files, isNotEmpty);
    for (final File f in files) {
      expect(
        easternDigits.hasMatch(f.readAsStringSync()),
        isFalse,
        reason: '${f.path}: numerals are always 0-9 (typography.css)',
      );
    }
  });
}
