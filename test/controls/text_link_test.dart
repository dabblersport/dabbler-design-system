import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SemanticsNode;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

const TextStyle _legal = TextStyle(fontSize: 12, height: 1.5);

Widget _sentence(VoidCallback? onTerms) => Text.rich(
  TextSpan(
    style: _legal,
    children: <InlineSpan>[
      const TextSpan(text: 'By continuing you agree to our '),
      DabblerTextLink.span(label: 'Terms', onPressed: onTerms, style: _legal),
      const TextSpan(text: '.'),
    ],
  ),
);

Text _linkText(WidgetTester t, String label) => t.widget<Text>(
  find.descendant(of: find.byType(DabblerTextLink), matching: find.text(label)),
);

void main() {
  group('DabblerTextLink — standalone', () {
    testWidgets('brand, underlined, subheadline medium', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          Center(
            child: DabblerTextLink(label: 'Log in', onPressed: () {}),
          ),
        ),
      );
      final TextStyle s = _linkText(tester, 'Log in').style!;
      expect(s.color, testColors().brandPrimary);
      expect(s.decoration, TextDecoration.underline);
      expect(s.decorationColor, testColors().brandPrimary);
      expect(s.fontSize, DabblerType.subheadline.fontSize);
      expect(s.fontWeight, DabblerType.medium);
    });

    testWidgets('hit target is at least 45×45, text painted smaller', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          Center(
            child: DabblerTextLink(label: 'Go', onPressed: () {}),
          ),
        ),
      );
      final Size target = tester.getSize(find.byType(DabblerTextLink));
      expect(target.height, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
      expect(target.width, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
      expect(
        tester.getSize(find.text('Go')).height,
        lessThan(DabblerSizing.touchTargetMin),
      );
    });

    testWidgets('tap fires; disabled is tertiary and inert', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        host(
          Column(
            children: <Widget>[
              DabblerTextLink(label: 'On', onPressed: () => taps++),
              const DabblerTextLink(label: 'Off'),
            ],
          ),
        ),
      );
      await tester.tap(find.text('On'));
      await tester.tap(find.text('Off'));
      expect(taps, 1);
      expect(_linkText(tester, 'Off').style!.color, testColors().textTertiary);
    });

    testWidgets('Enter and Space activate it with keyboard focus', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        host(
          DabblerTextLink(
            label: 'Key',
            onPressed: () => taps++,
            autofocus: true,
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(taps, 2);
    });

    testWidgets('announced as an enabled link with its label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          DabblerTextLink(
            label: 'Log in',
            semanticsLabel: 'Log in to Dabbler',
            onPressed: () {},
          ),
        ),
      );
      final SemanticsNode n = tester.getSemantics(find.byType(DabblerTextLink));
      expect(n.flagsCollection.isLink, isTrue);
      expect(n.label, 'Log in to Dabbler');
      h.dispose();
    });
  });

  group('DabblerTextLink — inline span', () {
    for (final TextDirection d in TextDirection.values) {
      testWidgets('takes the sentence size, no 45 padding (${d.name})', (
        WidgetTester tester,
      ) async {
        bool tapped = false;
        await tester.pumpWidget(
          host(_sentence(() => tapped = true), direction: d),
        );
        final TextStyle s = _linkText(tester, 'Terms').style!;
        expect(s.fontSize, 12);
        expect(s.color, testColors().brandPrimary);
        expect(s.decoration, TextDecoration.underline);
        expect(
          tester.getSize(find.byType(DabblerTextLink)).height,
          lessThan(DabblerSizing.touchTargetMin),
        );
        await tester.tap(find.byType(DabblerTextLink));
        expect(tapped, isTrue);
      });
    }

    testWidgets('RTL: the link follows the paragraph direction', (
      WidgetTester tester,
    ) async {
      Widget arabic(TextDirection d) => host(
        Text.rich(
          TextSpan(
            style: _legal,
            children: <InlineSpan>[
              const TextSpan(text: 'أوافق على '),
              DabblerTextLink.span(
                label: 'الشروط',
                onPressed: () {},
                style: _legal,
              ),
            ],
          ),
        ),
        direction: d,
      );
      await tester.pumpWidget(arabic(TextDirection.rtl));
      final Rect para = tester.getRect(find.byType(RichText).first);
      final Rect link = tester.getRect(find.byType(DabblerTextLink));
      // In RTL the trailing link sits to the left of the sentence start.
      expect(link.left, lessThan(para.right - link.width));
    });
  });
}
