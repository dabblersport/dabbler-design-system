import 'dart:math' as math;

import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

/// The Action Area family — `status-feedback.card.html`, the sections
/// *Navigation interaction preview* and *Action Area · system states*.
///
/// Every measurement is read off the rendered tree and compared with a token,
/// never a literal.

const double _width = 384;
const double _s = DabblerSizing.actionAreaSize;

const DabblerNavigationBottomBar _bar = DabblerNavigationBottomBar(
  safeArea: false,
);

Widget _area(
  DabblerActionAreaPhase phase, {
  DabblerActionAreaFit fit = DabblerActionAreaFit.row,
  bool withGlyph = true,
  bool glyphAtTop = false,
  Widget? child,
  DabblerNavigationBottomBar bar = _bar,
}) => DabblerActionArea(
  bar: bar,
  phase: phase,
  fit: fit,
  glyphAtTop: glyphAtTop,
  safeArea: false,
  glyph: withGlyph
      ? const SizedBox.square(
          key: Key('glyph-probe'),
          dimension: DabblerSizing.iconMd,
        )
      : null,
  children: <Widget>[?child],
);

/// `glyphInset` for the default 24 glyph — `(S − 2 − 24) / 2`.
final double _inset = DabblerActionArea.glyphInsetFor(DabblerSizing.iconMd);
const double _b = DabblerSizing.borderDefault;

Widget _hosted(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  bool reduceMotion = false,
  Brightness brightness = Brightness.light,
}) => MediaQuery(
  data: MediaQueryData(disableAnimations: reduceMotion),
  child: host(
    child,
    direction: direction,
    width: _width,
    brightness: brightness,
  ),
);

Rect _surface(WidgetTester tester) =>
    tester.getRect(find.byKey(DabblerActionArea.surfaceKey));

Rect _barRect(WidgetTester tester) =>
    tester.getRect(find.byKey(DabblerActionArea.barKey));

double _contentOpacity(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(find.byKey(DabblerActionArea.contentKey))
    .opacity;

double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

BoxDecoration _surfaceDecoration(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(find.byKey(DabblerActionArea.surfaceKey))
            .decoration
        as BoxDecoration;

void main() {
  group('tokens', () {
    test('--action-area-size is 56 and is the bar action', () {
      expect(DabblerSizing.actionAreaSize, 56);
      expect(DabblerSizing.actionAreaSize, DabblerSizing.navBarHeight);
      expect(DabblerSizing.actionAreaSize, DabblerFab.size);
    });

    test('--action-area-hold is 260ms', () {
      expect(DabblerMotion.actionAreaHold, const Duration(milliseconds: 260));
    });

    test('the ring on the footprint is 32', () {
      expect(DabblerSizing.actionAreaRing, 32);
    });
  });

  group('phase geometry', () {
    testWidgets('collapsed is a 56 circle over the action, at the inline end', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_hosted(_area(DabblerActionAreaPhase.collapsed)));
      final Rect s = _surface(tester);
      expect(s.size, const Size(_s, _s));
      expect(s.right, _barRect(tester).right);
      expect(s.bottom, _barRect(tester).bottom);
      expect(
        _surfaceDecoration(tester).borderRadius,
        DabblerRadius.pillAll,
      );
    });

    testWidgets('expanded row is the bar width and one row tall', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_hosted(_area(DabblerActionAreaPhase.expanded)));
      final Rect s = _surface(tester);
      expect(s.width, _barRect(tester).width);
      expect(s.width, _width);
      expect(s.height, _s);
    });

    testWidgets('content fit grows in height to its content', (
      WidgetTester tester,
    ) async {
      const double tall = DabblerSizing.mediaPreviewCompactHeight;
      await tester.pumpWidget(
        _hosted(
          _area(
            DabblerActionAreaPhase.expanded,
            fit: DabblerActionAreaFit.content,
            child: const SizedBox(height: tall),
          ),
        ),
      );
      final Rect s = _surface(tester);
      expect(s.width, _width);
      // `max(contentHeight, S)`: the content box carries 15 block padding.
      expect(s.height, tall + DabblerSpacing.space5 * 2);
      // Bottom-anchored on the bar's baseline.
      expect(s.bottom, _barRect(tester).bottom);
      expect(
        _surfaceDecoration(tester).borderRadius,
        BorderRadius.circular(DabblerRadius.xxl),
      );
    });

    testWidgets('content fit never shrinks below a row', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _hosted(
          _area(
            DabblerActionAreaPhase.expanded,
            fit: DabblerActionAreaFit.content,
            child: const SizedBox(height: DabblerSpacing.space4),
          ),
        ),
      );
      expect(_surface(tester).height, _s);
    });

    testWidgets('idle draws no hittable or announced surface', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_hosted(_area(DabblerActionAreaPhase.idle)));
      await tester.pumpAndSettle();
      final AnimatedOpacity surface = tester.widget<AnimatedOpacity>(
        find
            .ancestor(
              of: find.byKey(DabblerActionArea.surfaceKey),
              matching: find.byType(AnimatedOpacity),
            )
            .last,
      );
      expect(surface.opacity, 0);
    });
  });

  group('glyph rides the leading edge', () {
    for (final TextDirection direction in TextDirection.values) {
      testWidgets('collapsed: centred in the circle (${direction.name})', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _hosted(
            _area(DabblerActionAreaPhase.collapsed),
            direction: direction,
          ),
        );
        expect(
          tester.getCenter(find.byKey(const Key('glyph-probe'))),
          _surface(tester).center,
        );
      });
    }

    test('glyphInset = (S − 2 − glyphSize) / 2; content start from it', () {
      expect(DabblerActionArea.glyphInsetFor(DabblerSizing.iconMd), 15);
      expect(DabblerActionArea.glyphInsetFor(DabblerSizing.actionAreaRing), 11);
      expect(DabblerActionArea.contentStartFor(hasGlyph: true), 60);
      expect(DabblerActionArea.contentStartFor(hasGlyph: false), 15);
    });

    testWidgets('LTR expanded: inline-start glyphInset, bottom glyphInset', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_hosted(_area(DabblerActionAreaPhase.expanded)));
      final Rect glyph = tester.getRect(find.byKey(DabblerActionArea.glyphKey));
      final Rect s = _surface(tester);
      expect(glyph.left, s.left + _b + _inset);
      expect(glyph.bottom, s.bottom - _b - _inset);
      expect(glyph.size, const Size.square(DabblerSizing.iconMd));
    });

    testWidgets('glyphAtTop moves it to top 15 only once expanded', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _hosted(
          _area(
            DabblerActionAreaPhase.expanded,
            fit: DabblerActionAreaFit.content,
            glyphAtTop: true,
            child: const SizedBox(
              height: DabblerSizing.mediaPreviewCompactHeight,
            ),
          ),
        ),
      );
      final Rect s = _surface(tester);
      expect(
        tester.getRect(find.byKey(DabblerActionArea.glyphKey)).top,
        s.top + _b + DabblerSpacing.space5,
      );
    });

    testWidgets('content starts at glyphInset × 2 + glyphSize + 6', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _hosted(
          _area(
            DabblerActionAreaPhase.expanded,
            child: const SizedBox(key: Key('c'), width: 1, height: 1),
          ),
        ),
      );
      expect(
        tester.getRect(find.byKey(const Key('c'))).left,
        _surface(tester).left + _b + DabblerActionArea.contentStartFor(
          hasGlyph: true,
        ),
      );
    });

    testWidgets('RTL expanded: at the right edge, the surface on the left', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _hosted(
          _area(DabblerActionAreaPhase.collapsed),
          direction: TextDirection.rtl,
        ),
      );
      // Collapsed, the circle sits over the RTL action — on the left.
      expect(_surface(tester).left, _barRect(tester).left);

      await tester.pumpWidget(
        _hosted(
          _area(DabblerActionAreaPhase.expanded),
          direction: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();
      final Rect glyph = tester.getRect(find.byKey(DabblerActionArea.glyphKey));
      final Rect s = _surface(tester);
      expect(glyph.right, s.right - _b - _inset);
      expect(s.left, _barRect(tester).left);
    });

    testWidgets('mid-growth the glyph is still at the moving leading edge', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_hosted(_area(DabblerActionAreaPhase.collapsed)));
      await tester.pumpWidget(_hosted(_area(DabblerActionAreaPhase.expanded)));
      await tester.pump(DabblerMotion.slow ~/ 2);
      final Rect s = _surface(tester);
      expect(s.width, greaterThan(_s));
      expect(s.width, lessThan(_width));
      expect(s.right, _barRect(tester).right);
      expect(
        tester.getRect(find.byKey(DabblerActionArea.glyphKey)).left,
        s.left + _b + _inset,
      );
    });

    testWidgets('a bar pinned unmirrored keeps the surface on the right', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _hosted(
          _area(
            DabblerActionAreaPhase.collapsed,
            bar: const DabblerNavigationBottomBar(
              safeArea: false,
              mirrorInRtl: false,
            ),
          ),
          direction: TextDirection.rtl,
        ),
      );
      expect(_surface(tester).right, _barRect(tester).right);
    });
  });

  group('fade order', () {
    testWidgets('expand: the surface grows first, then the content fades in', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _hosted(_area(DabblerActionAreaPhase.collapsed, child: const Text('x'))),
      );
      expect(_contentOpacity(tester), 0);

      await tester.pumpWidget(
        _hosted(_area(DabblerActionAreaPhase.expanded, child: const Text('x'))),
      );
      await tester.pump(DabblerMotion.slow ~/ 2);
      // Growing, and the content is still out.
      expect(_surface(tester).width, lessThan(_width));
      expect(_contentOpacity(tester), 0);

      await tester.pump(DabblerMotion.slow);
      expect(_surface(tester).width, _width);
      expect(_contentOpacity(tester), 1);
    });

    testWidgets('contract: the content fades first, then the surface shrinks', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _hosted(_area(DabblerActionAreaPhase.expanded, child: const Text('x'))),
      );
      expect(_contentOpacity(tester), 1);

      await tester.pumpWidget(
        _hosted(_area(DabblerActionAreaPhase.collapsed, child: const Text('x'))),
      );
      await tester.pump(DabblerMotion.fast ~/ 2);
      // The content is on its way out while the surface is still full.
      expect(_contentOpacity(tester), 0);
      expect(_surface(tester).width, _width);

      await tester.pump(DabblerMotion.fast);
      await tester.pump(DabblerMotion.slow);
      await tester.pump(DabblerMotion.slow);
      expect(_surface(tester).size, const Size(_s, _s));
    });

    testWidgets('without a glyph the content starts 15 in', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _hosted(
          _area(
            DabblerActionAreaPhase.expanded,
            withGlyph: false,
            child: const SizedBox(key: Key('c'), width: 1, height: 1),
          ),
        ),
      );
      expect(find.byKey(DabblerActionArea.glyphKey), findsNothing);
      expect(
        tester.getRect(find.byKey(const Key('c'))).left,
        _surface(tester).left + _b + DabblerSpacing.space5,
      );
    });
  });

  group('reduced motion', () {
    testWidgets('size transitions are dropped; only opacity animates', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _hosted(
          _area(DabblerActionAreaPhase.collapsed, child: const Text('x')),
          reduceMotion: true,
        ),
      );
      await tester.pumpWidget(
        _hosted(
          _area(DabblerActionAreaPhase.expanded, child: const Text('x')),
          reduceMotion: true,
        ),
      );
      await tester.pump();
      // Full width at once — no growth frames.
      expect(_surface(tester).width, _width);
      // The content still fades (an AnimatedOpacity with a real duration).
      expect(_contentOpacity(tester), 1);
      final AnimatedOpacity content = tester.widget<AnimatedOpacity>(
        find.byKey(DabblerActionArea.contentKey),
      );
      expect(content.duration, greaterThan(Duration.zero));

      await tester.pumpWidget(
        _hosted(
          _area(DabblerActionAreaPhase.collapsed, child: const Text('x')),
          reduceMotion: true,
        ),
      );
      await tester.pump(DabblerMotion.fast);
      await tester.pump();
      expect(_surface(tester).size, const Size(_s, _s));
    });

    test('expand/contract durations drop only the size step', () {
      expect(
        DabblerActionArea.expandDuration(reduceMotion: true),
        DabblerMotion.base,
      );
      expect(
        DabblerActionArea.contractDuration(reduceMotion: true),
        DabblerMotion.fast,
      );
      expect(
        DabblerActionArea.expandDuration(reduceMotion: false),
        DabblerMotion.slow + DabblerMotion.base,
      );
    });
  });

  group('the bar underneath', () {
    testWidgets('is inert and hidden while expanded, live again when idle', (
      WidgetTester tester,
    ) async {
      final List<String> selected = <String>[];
      Widget build(DabblerActionAreaPhase phase) => _hosted(
        DabblerActionArea(
          phase: phase,
          safeArea: false,
          bar: DabblerNavigationBottomBar(
            safeArea: false,
            onSelect: selected.add,
          ),
        ),
      );

      await tester.pumpWidget(build(DabblerActionAreaPhase.expanded));
      await tester.pumpAndSettle();
      final SemanticsHandle handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Explore'), findsNothing);
      await tester.tap(find.byKey(DabblerActionArea.barKey), warnIfMissed: false);
      expect(selected, isEmpty);

      await tester.pumpWidget(build(DabblerActionAreaPhase.idle));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Explore'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('stays live beside the collapsed circle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_hosted(_area(DabblerActionAreaPhase.collapsed)));
      final SemanticsHandle handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Explore'), findsOneWidget);
      handle.dispose();
    });
  });

  group('semantics', () {
    testWidgets('the surface is role status, or alert', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      for (final DabblerActionAreaRole role in DabblerActionAreaRole.values) {
        await tester.pumpWidget(
          _hosted(
            DabblerActionArea(
              phase: DabblerActionAreaPhase.expanded,
              role: role,
              safeArea: false,
              bar: _bar,
              children: const <Widget>[Text('message')],
            ),
          ),
        );
        final SemanticsNode node = tester.getSemantics(
          find
              .ancestor(
                of: find.byKey(DabblerActionArea.surfaceKey),
                matching: find.byWidgetPredicate(
                  (Widget w) => w is Semantics && w.properties.role != null,
                ),
              )
              .first,
        );
        expect(
          node.getSemanticsData().role,
          role == DabblerActionAreaRole.alert
              ? SemanticsRole.alert
              : SemanticsRole.status,
        );
      }
      handle.dispose();
    });
  });

  group('NavigationFeedback — toast lifecycle', () {
    const DabblerNavigationFeedbackData joined = DabblerNavigationFeedbackData(
      tone: DabblerToastTone.success,
      message: 'joined game',
    );

    testWidgets('collapsed, hold, expanded, auto-dismiss, idle, onDone', (
      WidgetTester tester,
    ) async {
      int done = 0;
      Widget build(DabblerNavigationFeedbackData? data) => _hosted(
        DabblerNavigationFeedback(
          feedback: data,
          bar: _bar,
          safeArea: false,
          onDone: () => done++,
        ),
      );
      await tester.pumpWidget(build(null));
      await tester.pumpWidget(build(joined));
      await tester.pump();
      expect(_surface(tester).size, const Size(_s, _s));

      // Held for --action-area-hold, then grows.
      await tester.pump(DabblerMotion.actionAreaHold);
      await tester.pump(DabblerActionArea.expandDuration(reduceMotion: false));
      await tester.pump();
      expect(_surface(tester).width, _width);
      expect(_contentOpacity(tester), 1);

      // The 4000ms runs from the expanded phase; not before it.
      await tester.pump(
        DabblerToastSpec.defaultDuration -
            DabblerActionArea.expandDuration(reduceMotion: false) -
            DabblerMotion.slow,
      );
      expect(_surface(tester).width, _width);
      expect(done, 0);

      // close(): collapsed now, idle + onDone after 200 + HOLD.
      await tester.pump(DabblerMotion.slow);
      await tester.pump(DabblerMotion.slow);
      expect(done, 0);
      await tester.pump(DabblerMotion.actionAreaHold);
      await tester.pump();
      expect(done, 1);
      await tester.pumpAndSettle();
      expect(_surface(tester).size, const Size(_s, _s));
    });

    testWidgets('hover pauses the timer; leaving re-arms it', (
      WidgetTester tester,
    ) async {
      int done = 0;
      await tester.pumpWidget(
        _hosted(
          DabblerNavigationFeedback(
            feedback: joined,
            bar: _bar,
            safeArea: false,
            onDone: () => done++,
          ),
        ),
      );
      await tester.pump(DabblerMotion.actionAreaHold);
      await tester.pump(DabblerActionArea.expandDuration(reduceMotion: false));
      await tester.pump();

      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: _surface(tester).center);
      await tester.pump();
      await tester.pump(DabblerToastSpec.defaultDuration * 2);
      expect(_surface(tester).width, _width);
      expect(done, 0);

      await mouse.moveTo(Offset.zero);
      await tester.pump();
      await tester.pump(DabblerToastSpec.defaultDuration);
      // close(): idle after 200 + HOLD — timers, not frames.
      await tester.pump(DabblerMotion.slow + DabblerMotion.actionAreaHold);
      await tester.pump();
      expect(done, 1);
      await mouse.removePointer();
    });

    testWidgets('the action fires, then the toast contracts', (
      WidgetTester tester,
    ) async {
      int pressed = 0;
      int done = 0;
      await tester.pumpWidget(
        _hosted(
          DabblerNavigationFeedback(
            feedback: DabblerNavigationFeedbackData(
              tone: DabblerToastTone.error,
              message: "couldn't join",
              action: DabblerToastAction(
                label: 'retry',
                onPressed: () => pressed++,
              ),
            ),
            bar: _bar,
            safeArea: false,
            onDone: () => done++,
          ),
        ),
      );
      await tester.pump(DabblerMotion.actionAreaHold);
      await tester.pump(DabblerActionArea.expandDuration(reduceMotion: false));
      await tester.pump();
      final Size target = tester.getSize(
        find.byKey(DabblerNavigationFeedback.actionTargetKey),
      );
      // `minHeight: --touch-target-min`, `paddingInline: --space-2`.
      expect(target.height, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
      await tester.tap(find.byKey(DabblerNavigationFeedback.actionTargetKey));
      await tester.pumpAndSettle();
      expect(pressed, 1);
      expect(done, 1);
    });

    testWidgets('tone defaults: neutral for a toast, info for a banner', (
      WidgetTester tester,
    ) async {
      const DabblerNavigationFeedbackData untoned =
          DabblerNavigationFeedbackData(message: 'm');
      expect(
        untoned.toneFor(DabblerNavigationFeedbackPresentation.toast),
        DabblerToastTone.neutral,
      );
      expect(
        untoned.toneFor(DabblerNavigationFeedbackPresentation.banner),
        DabblerToastTone.info,
      );
      final DabblerColors c = testColors();
      await tester.pumpWidget(
        _hosted(
          const DabblerNavigationFeedback(
            presentation: DabblerNavigationFeedbackPresentation.banner,
            feedback: untoned,
            phase: DabblerActionAreaPhase.expanded,
            bar: _bar,
            safeArea: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(_surfaceDecoration(tester).color, c.info.surface);
    });

    testWidgets('the toast message stays on one line', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _hosted(
          const DabblerNavigationFeedback(
            feedback: joined,
            phase: DabblerActionAreaPhase.expanded,
            bar: _bar,
            safeArea: false,
          ),
        ),
      );
      final Text text = tester.widget<Text>(find.text('joined game'));
      expect(text.maxLines, 1);
      expect(_surface(tester).height, _s);
    });
  });

  group('NavigationFeedback — banner', () {
    DabblerNavigationFeedbackData banner(DabblerToastTone tone) =>
        DabblerNavigationFeedbackData(
          tone: tone,
          title: 'game cancelled',
          message: 'tuesday 5-a-side was cancelled.',
          dismissible: true,
        );

    testWidgets('is sticky by default, and dismisses on the 45 target', (
      WidgetTester tester,
    ) async {
      int done = 0;
      await tester.pumpWidget(
        _hosted(
          DabblerNavigationFeedback(
            presentation: DabblerNavigationFeedbackPresentation.banner,
            feedback: banner(DabblerToastTone.error),
            bar: _bar,
            safeArea: false,
            onDone: () => done++,
          ),
        ),
      );
      await tester.pump(DabblerMotion.actionAreaHold);
      await tester.pump(DabblerActionArea.expandDuration(reduceMotion: false));
      await tester.pump(DabblerToastSpec.defaultDuration * 5);
      expect(done, 0);
      expect(_surface(tester).height, greaterThan(_s));

      final Rect dismiss = tester.getRect(
        find.byKey(DabblerNavigationFeedback.dismissTargetKey),
      );
      expect(
        dismiss.size,
        const Size.square(DabblerSizing.touchTargetMin),
      );
      // The content box is bottom-pinned in a padding box of
      // `max(contentHeight, S) − 2`, so its top sits one border above the
      // surface's outer top; the dismiss is 3 below that (15 padding − 12
      // margin) and 6 in from the content box's inline end (15 − 9).
      expect(
        dismiss.top,
        _surface(tester).top - _b + DabblerNavigationFeedback.dismissTop,
      );
      expect(
        _surface(tester).right - _b - dismiss.right,
        DabblerNavigationFeedback.dismissEnd,
      );
      expect(DabblerNavigationFeedback.dismissTop, 3);
      expect(DabblerNavigationFeedback.dismissEnd, 6);
      await tester.tap(find.byKey(DabblerNavigationFeedback.dismissTargetKey));
      await tester.pumpAndSettle();
      expect(done, 1);
    });

    testWidgets('glyph at the top-leading corner, content-fitted', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _hosted(
          DabblerNavigationFeedback(
            presentation: DabblerNavigationFeedbackPresentation.banner,
            feedback: banner(DabblerToastTone.info),
            phase: DabblerActionAreaPhase.expanded,
            bar: _bar,
            safeArea: false,
          ),
          direction: TextDirection.rtl,
        ),
      );
      final Rect s = _surface(tester);
      final Rect glyph = tester.getRect(find.byKey(DabblerActionArea.glyphKey));
      expect(glyph.top, s.top + _b + DabblerSpacing.space5);
      expect(glyph.right, s.right - _b - _inset);
      expect(s.width, _width);
    });

    testWidgets('role alert for error and warning, status otherwise', (
      WidgetTester tester,
    ) async {
      for (final DabblerToastTone tone in DabblerToastTone.values) {
        await tester.pumpWidget(
          _hosted(
            DabblerNavigationFeedback(
              presentation: DabblerNavigationFeedbackPresentation.banner,
              feedback: banner(tone),
              phase: DabblerActionAreaPhase.expanded,
              bar: _bar,
              safeArea: false,
            ),
          ),
        );
        final DabblerActionArea area = tester.widget(
          find.byType(DabblerActionArea),
        );
        final bool interrupts =
            tone == DabblerToastTone.error || tone == DabblerToastTone.warning;
        expect(
          area.role,
          interrupts ? DabblerActionAreaRole.alert : DabblerActionAreaRole.status,
          reason: tone.name,
        );
      }
    });

    testWidgets('a toast is never an alert, even in error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _hosted(
          const DabblerNavigationFeedback(
            feedback: DabblerNavigationFeedbackData(
              tone: DabblerToastTone.error,
              message: "couldn't join",
            ),
            phase: DabblerActionAreaPhase.expanded,
            bar: _bar,
            safeArea: false,
          ),
        ),
      );
      final DabblerActionArea area = tester.widget(
        find.byType(DabblerActionArea),
      );
      expect(area.role, DabblerActionAreaRole.status);
    });
  });

  group('NavigationFeedback — colour is the shared status tones', () {
    for (final Brightness b in Brightness.values) {
      testWidgets('ink clears AA on every tone surface (${b.name})', (
        WidgetTester tester,
      ) async {
        final DabblerColors colors = testColors(brightness: b);
        for (final DabblerToastTone tone in DabblerToastTone.values) {
          await tester.pumpWidget(
            _hosted(
              DabblerNavigationFeedback(
                feedback: DabblerNavigationFeedbackData(
                  tone: tone,
                  message: 'm-${tone.name}',
                ),
                phase: DabblerActionAreaPhase.expanded,
                bar: _bar,
                safeArea: false,
              ),
              brightness: b,
            ),
          );
          await tester.pumpAndSettle();
          final DabblerStatusToneColors expected = DabblerStatusToneColors.of(
            colors,
            tone.status,
          );
          final BoxDecoration d = _surfaceDecoration(tester);
          expect(d.color, expected.surface, reason: tone.name);
          expect(
            (d.border! as Border).top.color,
            expected.hairline,
            reason: tone.name,
          );
          final Color ink = tester
              .widget<Text>(find.text('m-${tone.name}'))
              .style!
              .color!;
          expect(ink, expected.ink, reason: tone.name);
          final double ratio = _contrast(ink, d.color!);
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '${tone.name} ${b.name}: $ratio',
          );
        }
      });
    }

    test('the hairline is the strong ink at 20%, neutral the card outline', () {
      final DabblerColors c = testColors();
      final DabblerStatusToneColors success = DabblerStatusToneColors.of(
        c,
        DabblerStatusTone.success,
      );
      expect(success.hairline, c.success.strong.withValues(alpha: 0.20));
      final DabblerStatusToneColors neutral = DabblerStatusToneColors.of(
        c,
        null,
      );
      expect(neutral.surface, c.surfaceCard);
      expect(neutral.ink, c.textPrimary);
      expect(neutral.hairline, c.borderDefault);
    });
  });

  group('NavigationActivity', () {
    Widget activity(
      DabblerNavigationActivityPresentation p, {
      double? value,
      bool active = true,
      String? status,
      Brightness brightness = Brightness.light,
    }) => _hosted(
      DabblerNavigationActivity(
        presentation: p,
        label: 'uploading',
        value: value,
        status: status,
        active: active,
        bar: _bar,
        safeArea: false,
      ),
      brightness: brightness,
    );

    testWidgets('inactive is idle navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        activity(DabblerNavigationActivityPresentation.spinner, active: false),
      );
      final DabblerActionArea area = tester.widget(
        find.byType(DabblerActionArea),
      );
      expect(area.phase, DabblerActionAreaPhase.idle);
    });

    testWidgets('spinner: the brand circle with an onBrand spinner', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        activity(DabblerNavigationActivityPresentation.spinner),
      );
      await tester.pump(DabblerMotion.base);
      final DabblerColors c = testColors();
      expect(_surface(tester).size, const Size(_s, _s));
      expect(_surfaceDecoration(tester).color, c.brandPrimary);
      final DabblerSpinner spinner = tester.widget(find.byType(DabblerSpinner));
      expect(spinner.tone, DabblerSpinnerTone.onBrand);
      expect(spinner.size, DabblerSpinnerSize.md);
    });

    testWidgets('ring: a 32 progress ring on the brand circle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        activity(DabblerNavigationActivityPresentation.ring, value: 0.65),
      );
      expect(_surface(tester).size, const Size(_s, _s));
      final Finder ring = find.byType(DabblerRing);
      expect(tester.getSize(ring), const Size.square(DabblerSizing.actionAreaRing));
      expect(tester.widget<DabblerRing>(ring).tone, DabblerRingTone.onBrand);
    });

    testWidgets('spinner-label: a card row with a brand spinner and a label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        activity(DabblerNavigationActivityPresentation.spinnerLabel),
      );
      await tester.pump(DabblerMotion.base);
      final DabblerColors c = testColors();
      expect(_surface(tester).width, _width);
      expect(_surface(tester).height, _s);
      expect(_surfaceDecoration(tester).color, c.surfaceCard);
      expect(find.text('uploading'), findsOneWidget);
      final DabblerSpinner spinner = tester.widget(find.byType(DabblerSpinner));
      expect(spinner.tone, DabblerSpinnerTone.brand);
    });

    testWidgets('progress: a determinate sm bar, no indicator beside it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        activity(DabblerNavigationActivityPresentation.progress, value: 0.35),
      );
      final DabblerProgressBar bar = tester.widget(
        find.byType(DabblerProgressBar),
      );
      expect(bar.value, 0.35);
      expect(bar.size, DabblerProgressBarSize.sm);
      expect(bar.showValue, isTrue);
      // The bar is the indicator: no glyph once expanded.
      expect(find.byKey(DabblerActionArea.glyphKey), findsNothing);
      expect(_surface(tester).height, _s);
    });

    testWidgets('indeterminate: an indeterminate sm bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        activity(DabblerNavigationActivityPresentation.indeterminate),
      );
      final DabblerProgressBar bar = tester.widget(
        find.byType(DabblerProgressBar),
      );
      expect(bar.value, isNull);
      expect(bar.size, DabblerProgressBarSize.sm);
    });

    testWidgets('progress-expanded: md bar + status line, grown to content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        activity(
          DabblerNavigationActivityPresentation.progressExpanded,
          value: 0.35,
          status: '3 of 8 photos',
        ),
      );
      final DabblerProgressBar bar = tester.widget(
        find.byType(DabblerProgressBar),
      );
      expect(bar.size, DabblerProgressBarSize.md);
      expect(find.text('3 of 8 photos'), findsOneWidget);
      expect(_surface(tester).height, greaterThan(_s));
      expect(_surface(tester).width, _width);
    });

    testWidgets('activating an expanded presentation grows straight out', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        activity(DabblerNavigationActivityPresentation.progress, active: false),
      );
      await tester.pumpWidget(
        activity(DabblerNavigationActivityPresentation.progress, value: 0.2),
      );
      await tester.pump();
      final DabblerActionArea area = tester.widget(
        find.byType(DabblerActionArea),
      );
      expect(area.phase, DabblerActionAreaPhase.expanded);
      await tester.pumpAndSettle();
      expect(_surface(tester).width, _width);
    });

    testWidgets('collapsed: transparent hairline; the ring is 32 at inset 11', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        activity(DabblerNavigationActivityPresentation.ring, value: 0.5),
      );
      await tester.pump(DabblerMotion.base);
      final BoxDecoration d = _surfaceDecoration(tester);
      expect((d.border! as Border).top.color.a, 0);
      final Rect glyph = tester.getRect(find.byKey(DabblerActionArea.glyphKey));
      final Rect s = _surface(tester);
      expect(glyph.size, const Size.square(DabblerSizing.actionAreaRing));
      expect(
        glyph.left,
        s.left + _b + DabblerActionArea.glyphInsetFor(
          DabblerSizing.actionAreaRing,
        ),
      );
    });

    testWidgets('expanded rows: ink clears AA on the card, dark too', (
      WidgetTester tester,
    ) async {
      for (final Brightness b in Brightness.values) {
        await tester.pumpWidget(
          activity(
            DabblerNavigationActivityPresentation.spinnerLabel,
            brightness: b,
          ),
        );
        // The surface colours cross-fade over --motion-base when the
        // brightness flips; let that finish (the spinner never settles).
        await tester.pump(DabblerMotion.base);
        await tester.pump(DabblerMotion.base);
        final Color ink = tester.widget<Text>(find.text('uploading')).style!.color!;
        final Color fill = _surfaceDecoration(tester).color!;
        expect(_contrast(ink, fill), greaterThanOrEqualTo(4.5), reason: b.name);
      }
    });
  });

  group('DabblerRing.progress', () {
    testWidgets('determinate is a progressbar with its value', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          const Center(
            child: DabblerRing.progress(value: 0.65, semanticLabel: 'upload'),
          ),
        ),
      );
      final SemanticsData data = tester
          .getSemantics(find.byType(DabblerRing))
          .getSemanticsData();
      expect(data.role, SemanticsRole.progressBar);
      expect(data.value, '65%');
      expect(data.minValue, '0');
      expect(data.maxValue, '100');
      expect(data.label, 'upload');
      handle.dispose();
    });

    testWidgets('indeterminate spins and announces as a status', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const Center(child: DabblerRing.progress(semanticLabel: 'sync'))),
      );
      final SemanticsData data = tester
          .getSemantics(find.byType(DabblerRing))
          .getSemanticsData();
      expect(data.flagsCollection.isLiveRegion, isTrue);
      expect(data.label, 'sync');
      expect(data.value, isEmpty);
      expect(
        find.descendant(
          of: find.byType(DabblerRing),
          matching: find.byType(Transform),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('reduced motion pulses instead of turning', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: host(const Center(child: DabblerRing.progress())),
        ),
      );
      await tester.pump(DabblerMotion.slow);
      expect(
        find.descendant(
          of: find.byType(DabblerRing),
          matching: find.byType(Transform),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(DabblerRing),
          matching: find.byType(Opacity),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the arc runs clockwise from 12 and is not mirrored in RTL', (
      WidgetTester tester,
    ) async {
      Future<List<int>> pixels(TextDirection direction) async {
        final GlobalKey key = GlobalKey();
        await tester.pumpWidget(
          host(
            Center(
              child: RepaintBoundary(
                key: key,
                child: const DabblerRing.progress(
                  value: 0.25,
                  diameter: DabblerSizing.iconXl,
                ),
              ),
            ),
            direction: direction,
          ),
        );
        await tester.pumpAndSettle();
        late List<int> out;
        await tester.runAsync(() async {
          final RenderRepaintBoundary r =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await r.toImage();
          final data = await image.toByteData();
          out = data!.buffer.asUint8List().toList();
          image.dispose();
        });
        return out;
      }

      final List<int> ltr = await pixels(TextDirection.ltr);
      final List<int> rtl = await pixels(TextDirection.rtl);
      expect(rtl, ltr);

      // A quarter: the full-alpha arc is in the top-right quadrant (12 → 3
      // o'clock, clockwise), the top-left holds only the 25% track.
      const int side = 36;
      int alphaAt(int x, int y) => ltr[(y * side + x) * 4 + 3];
      const int mid = side ~/ 2;
      final int topRight = alphaAt(side - 2, mid - 6);
      final int topLeft = alphaAt(1, mid - 6);
      expect(topRight, greaterThan(topLeft));
    });
  });
}
