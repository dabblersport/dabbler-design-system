import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

/// The zero-literal pass: every app-role token pinned to its value, stated
/// independently here so a typo in the token class is caught.
void main() {
  group('DabblerMotion app roles', () {
    const Map<String, int> ms = <String, int>{
      'contentSwap': 300,
      'scrollTo': 400,
      'snapBack': 200,
      'pageTransition': 300,
      'pageTransitionSlide': 350,
      'pageTransitionModal': 400,
      'heroCrossfade': 500,
      'screenEntrance': 800,
      'ambientLoop': 1200,
      'toastBrief': 1000,
      'toastShort': 2000,
      'toastLong': 3000,
      'autoAdvance': 3000,
      'autoAdvanceHero': 5000,
      'debounceSearch': 350,
      'debounceValidation': 500,
      'debounceSuggestion': 800,
      'timeoutShort': 5000,
      'timeoutNetwork': 10000,
      'pollInterval': 30000,
      'delayFrame': 100,
      'delaySettle': 300,
      'delayRetry': 500,
      'delayRetryLong': 1000,
      'delayRetryMax': 2000,
    };

    test('each role has its pinned value', () {
      expect(motionAppRoles.keys.toSet(), ms.keys.toSet());
      for (final MapEntry<String, int> e in ms.entries) {
        expect(motionAppRoles[e.key]!.inMilliseconds, e.value, reason: e.key);
      }
    });

    test('snapBack is the source slow step, not a new value', () {
      expect(DabblerMotion.snapBack, DabblerMotion.slow);
    });

    test('app curves', () {
      expect(DabblerMotion.emphasizedDecelerate, Curves.easeOutCubic);
      expect(DabblerMotion.emphasizedAccelerate, Curves.easeInCubic);
      expect(DabblerMotion.standardInOut, Curves.easeInOut);
    });

    testWidgets('durationOf zeroes an animation under reduced motion', (
      WidgetTester tester,
    ) async {
      final List<Duration> seen = <Duration>[];
      for (final bool reduce in <bool>[false, true]) {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(disableAnimations: reduce),
            child: Builder(
              builder: (BuildContext context) {
                seen.add(
                  DabblerMotion.durationOf(context, DabblerMotion.contentSwap),
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      }
      expect(seen, <Duration>[DabblerMotion.contentSwap, Duration.zero]);
    });
  });

  group('DabblerSizing / DabblerSpacing app roles', () {
    const Map<String, double> px = <String, double>{
      'iconXs': 12,
      'iconInline': 15,
      'iconRow': 21,
      'iconXl': 36,
      'tileMd': 45,
      'tileLg': 48,
      'illustrationSm': 54,
      'illustrationMd': 72,
      'illustrationLg': 96,
      'dot': 9,
      'swatch': 15,
      'indicatorThickness': 6,
      'thumbnail': 60,
      'optionTileHeight': 66,
      'labelColumnWidth': 90,
      'heroCoverHeight': 240,
      'mediaPreviewHeight': 180,
      'mediaPreviewCompactHeight': 120,
      'mediaRowHeight': 150,
      'loadingBlockHeight': 144,
      'railCardWidth': 180,
      'railCardHeight': 96,
      'skeletonTitleHeight': 24,
      'skeletonLineHeight': 12,
      'skeletonBlockHeight': 90,
      'skeletonWidthLong': 216,
      'skeletonWidthMedium': 156,
      'skeletonWidthShort': 144,
      'skeletonWidthMeta': 96,
      'listBottomInset': 24,
      'floatingBarClearance': 96,
      'stickyActionBarClearance': 96,
    };

    test('each role has its pinned value', () {
      expect(sizingAppRoles.keys.toSet(), px.keys.toSet());
      for (final MapEntry<String, double> e in px.entries) {
        expect(sizingAppRoles[e.key], e.value, reason: e.key);
      }
    });

    test('every role sits on the base-3 grid', () {
      for (final MapEntry<String, double> e in sizingAppRoles.entries) {
        expect(e.value % 3, 0, reason: e.key);
      }
    });

    test('every off-grid ruling is pinned and is not a base-3 multiple', () {
      const Map<String, double> pinned = <String, double>{
        'resultTile': 40,
        'articleHeroHeight': 230,
        'mediaRailHeight': 128,
        'mediaRailAddWidth': 64,
        'mediaRailTileWidth': 104,
        'navItem': 44,
        'navBarHeight': 56,
        'navGlyphLarge': 26,
        'navCreateTile': 62,
        'navFadeHeight': 80,
      };
      expect(sizingOffGridRulings.keys.toSet(), pinned.keys.toSet());
      for (final MapEntry<String, double> e in pinned.entries) {
        expect(sizingOffGridRulings[e.key], e.value, reason: e.key);
        expect(e.value % 3, isNot(0), reason: '${e.key} is a grid step');
      }
    });

    test('the skeleton line role equals DabblerSkeleton.lineHeight', () {
      expect(DabblerSizing.skeletonLineHeight, DabblerSkeleton.lineHeight);
    });

    test('illustrationMd equals DabblerHeroIcon.defaultSize', () {
      expect(DabblerSizing.illustrationMd, DabblerHeroIcon.defaultSize);
    });
  });

  group('DabblerInsets and DabblerRadius additions', () {
    test('insets', () {
      expect(DabblerInsets.screen, const EdgeInsets.symmetric(horizontal: 24));
      expect(DabblerInsets.card, const EdgeInsets.all(18));
      expect(DabblerInsets.listBottom, const EdgeInsets.only(bottom: 24));
      expect(DabblerInsets.underFloatingBar, const EdgeInsets.only(bottom: 96));
      expect(
        DabblerInsets.feedScreen,
        const EdgeInsets.symmetric(horizontal: 18),
      );
      expect(DabblerInsets.feedBottom, const EdgeInsets.only(bottom: 120));
      expect(
        DabblerInsets.rowVertical,
        const EdgeInsets.symmetric(vertical: 12),
      );
      expect(
        DabblerInsets.segmentGap,
        const EdgeInsets.symmetric(horizontal: 3),
      );
    });

    test('top-only radii', () {
      expect(
        DabblerRadius.xlTop,
        const BorderRadius.vertical(top: Radius.circular(18)),
      );
      expect(
        DabblerRadius.xxlTop,
        const BorderRadius.vertical(top: Radius.circular(24)),
      );
      expect(DabblerRadius.topSheet, DabblerRadius.xxlTop);
    });
  });

  group('DabblerGap', () {
    testWidgets('v and h size one axis only', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DabblerGap.v(DabblerSpacing.space4, key: Key('v')),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DabblerGap.h(DabblerSpacing.space8, key: Key('h')),
                ],
              ),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byKey(const Key('v'))).height, 12);
      expect(tester.getSize(find.byKey(const Key('h'))).width, 24);
    });

    testWidgets('sliver form is a SliverToBoxAdapter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            height: 200,
            child: CustomScrollView(
              slivers: <Widget>[
                DabblerGap.sliver(DabblerSpacing.floatingBarClearance),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(SliverToBoxAdapter), findsOneWidget);
    });

    testWidgets('an off-scale extent is rejected in debug', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerGap.v(7)));
      expect(tester.takeException(), isAssertionError);
    });
  });

  group('DabblerInert', () {
    testWidgets('inert dims to the system disabled opacity and blocks taps', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      Widget build(bool inert) => host(
        DabblerInert(
          inert: inert,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps++,
            child: const SizedBox(width: 48, height: 48, key: Key('t')),
          ),
        ),
      );
      await tester.pumpWidget(build(true));
      expect(
        tester.widget<Opacity>(find.byType(Opacity)).opacity,
        DabblerToggle.disabledOpacity,
      );
      await tester.tap(find.byKey(const Key('t')), warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('live is fully opaque and takes taps', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      Widget build(bool inert) => host(
        DabblerInert(
          inert: inert,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps++,
            child: const SizedBox(width: 48, height: 48, key: Key('t')),
          ),
        ),
      );
      await tester.pumpWidget(build(false));
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
      await tester.tap(find.byKey(const Key('t')));
      expect(taps, 1);
    });
  });
}
