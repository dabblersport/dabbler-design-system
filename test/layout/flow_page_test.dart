import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

Widget _page({
  VoidCallback? onBack,
  VoidCallback? onPrimary,
  bool step = true,
  bool centered = false,
  bool loading = false,
  Widget? banner,
  String title = 'Tell us a bit about you',
  String primary = 'Continue',
  String back = 'Back',
}) => SizedBox(
  height: 700,
  child: DabblerFlowPage(
    onBack: onBack,
    backLabel: onBack == null ? null : back,
    stepCount: step ? 5 : null,
    stepIndex: step ? 1 : null,
    stepLabel: step ? 'Step 2 of 5' : null,
    title: title,
    subtitle: 'Subtitle',
    centered: centered,
    content: const <Widget>[Text('body one'), Text('body two')],
    footerBanner: banner,
    primaryLabel: primary,
    primaryLoading: loading,
    onPrimary: onPrimary,
  ),
);

void main() {
  group('DabblerFlowPage', () {
    testWidgets('draws back, progress, title, body and the action in order', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(_page(onBack: () {}, onPrimary: () {}), width: 393),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(DabblerStepProgress), findsOneWidget);
      final double back = tester.getCenter(find.byType(DabblerButton).first).dy;
      final double title = tester
          .getCenter(find.text('Tell us a bit about you'))
          .dy;
      final double body = tester.getCenter(find.text('body one')).dy;
      final double cta = tester.getCenter(find.text('Continue')).dy;
      expect(back < title && title < body && body < cta, isTrue);
    });

    testWidgets('the back button calls onBack and has its label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      int backs = 0;
      await tester.pumpWidget(host(_page(onBack: () => backs++), width: 393));
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Back'));
      expect(backs, 1);
      handle.dispose();
    });

    testWidgets('a null onPrimary disables the action, loading keeps it busy', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(_page(), width: 393));
      DabblerButton button = tester
          .widgetList<DabblerButton>(find.byType(DabblerButton))
          .last;
      expect(button.disabled, isTrue);

      await tester.pumpWidget(host(_page(loading: true), width: 393));
      button = tester
          .widgetList<DabblerButton>(find.byType(DabblerButton))
          .last;
      expect(button.loading, isTrue);
      expect(button.disabled, isFalse);
    });

    testWidgets('a footer banner sits above the action', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          _page(
            onPrimary: () {},
            banner: const DabblerBanner(
              tone: DabblerBannerTone.error,
              message: 'Too young',
            ),
          ),
          width: 393,
        ),
      );
      expect(
        tester.getCenter(find.text('Too young')).dy,
        lessThan(tester.getCenter(find.text('Continue')).dy),
      );
    });

    testWidgets('centred puts the title block in the middle of the page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(_page(step: false, centered: true, onPrimary: () {}), width: 393),
      );
      final double title = tester
          .getCenter(find.text('Tell us a bit about you'))
          .dy;
      expect(title, greaterThan(60));
      expect(title, lessThan(450));
      expect(find.byType(DabblerStepProgress), findsNothing);
    });

    testWidgets('content is never wider than the maximum', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: <ThemeExtension<dynamic>>[testColors()]),
          home: _page(onPrimary: () {}),
        ),
      );
      expect(
        tester.getSize(find.byType(DabblerButton).last).width,
        lessThanOrEqualTo(DabblerFlowPage.maxContentWidth),
      );
    });

    test('the back arrow is 24, as Auth and Onboarding.dc.html:150 draws it', () {
      expect(DabblerFlowPage.backGlyphSize, 24);
    });

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('the back glyph renders at 24 and the target stays 45 ($dir)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(_page(onBack: () {}), direction: dir, width: 393),
        );
        final Finder back = find.descendant(
          of: find.byType(DabblerButton).first,
          matching: find.byType(DabblerIcon),
        );
        expect(tester.widget<DabblerIcon>(back).size, 24);
        expect(
          tester.getSize(find.byType(DabblerButton).first).height,
          greaterThanOrEqualTo(DabblerSizing.touchTargetMin),
        );
      });
    }

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('title at the inline start, back arrow mirrored ($dir)', (
        WidgetTester tester,
      ) async {
        final bool rtl = dir == TextDirection.rtl;
        await tester.pumpWidget(
          host(
            _page(
              onBack: () {},
              onPrimary: () {},
              title: rtl ? 'لماذا أنت هنا؟' : 'Why are you here?',
              primary: rtl ? 'المتابعة' : 'Continue',
              back: rtl ? 'رجوع' : 'Back',
            ),
            direction: dir,
            width: 393,
          ),
        );
        expect(tester.takeException(), isNull);
        final Finder titleFinder = find.text(
          rtl ? 'لماذا أنت هنا؟' : 'Why are you here?',
        );
        final double titleStart = rtl
            ? tester.getTopRight(titleFinder).dx
            : tester.getTopLeft(titleFinder).dx;
        final double mid = tester.getCenter(find.byType(DabblerFlowPage)).dx;
        final double backCentre = tester
            .getCenter(find.byType(DabblerButton).first)
            .dx;
        expect(rtl ? backCentre > mid : backCentre < mid, isTrue);
        expect(rtl ? titleStart > mid : titleStart < mid, isTrue);
      });
    }
  });
}
