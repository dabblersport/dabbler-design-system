import 'package:dabbler_design_system/src/feedback/toast.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/interaction/press_scale.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// The resolved tokens the toast is checked against, for [theme] at
/// [brightness].
DabblerColors _colors({
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

/// Wraps a widget in the minimum a toast needs: a [ThemeData] carrying the
/// [DabblerColors] extension, a direction, and a [MediaQuery] we can steer.
Widget _host(
  Widget child, {
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
  TextDirection direction = TextDirection.ltr,
  bool reduceMotion = false,
  EdgeInsets viewPadding = EdgeInsets.zero,
  bool bounded = true,
}) {
  return MaterialApp(
    theme: ThemeData(
      brightness: brightness,
      extensions: <ThemeExtension<dynamic>>[
        _colors(theme: theme, brightness: brightness),
      ],
    ),
    builder: (BuildContext context, Widget? home) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        disableAnimations: reduceMotion,
        padding: viewPadding,
      ),
      child: home!,
    ),
    home: Directionality(
      textDirection: direction,
      // A bare toast is bounded by its host, as the provider's viewport
      // bounds it in the app. Nothing can refuse tight parent constraints,
      // so the 420 maximum is asserted where it is actually applied — in the
      // provider group below.
      child: bounded
          ? Align(
              alignment: Alignment.topCenter,
              child: SizedBox(width: 360, child: child),
            )
          : child,
    ),
  );
}

/// The toast's own shell decoration — the [Container] that carries the fill,
/// the hairline and the radius.
BoxDecoration _shell(WidgetTester tester) {
  final Container container = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(DabblerToast),
          matching: find.byType(Container),
        )
        .first,
  );
  return container.decoration! as BoxDecoration;
}

DabblerToastSpec _spec(String message, {String? id, Duration? duration}) =>
    DabblerToastSpec(
      message: message,
      id: id,
      duration: duration ?? DabblerToastSpec.defaultDuration,
    );

void main() {
  // ---------------------------------------------------------------------
  // AC2 — the queue, as a pure state machine. No widgets built.
  // Source: Toast.prompt.md "Maximum 3 visible, newest at the bottom ...
  // A fourth show() drops the oldest"; Toast.d.ts "max ... Default 3".
  // ---------------------------------------------------------------------
  group('DabblerToastController (AC2 — queue)', () {
    test('defaults to a cap of 3', () {
      expect(DabblerToastController.defaultMax, 3);
      expect(DabblerToastController().max, 3);
    });

    test('rejects a cap below 1', () {
      expect(() => DabblerToastController(max: 0), throwsAssertionError);
    });

    test('keeps insertion order, oldest first', () {
      final DabblerToastController c = DabblerToastController();
      c.show(_spec('a'));
      c.show(_spec('b'));
      expect(
        c.visible.map((DabblerToastEntry e) => e.spec.message),
        <String>['a', 'b'],
      );
      c.dispose();
    });

    test('a fourth show while three are visible drops the OLDEST', () {
      final DabblerToastController c = DabblerToastController();
      c.show(_spec('a'));
      c.show(_spec('b'));
      c.show(_spec('c'));
      expect(c.visible.length, 3);

      c.show(_spec('d'));

      expect(c.visible.length, 3, reason: 'the cap is 3, not 4');
      expect(
        c.visible.map((DabblerToastEntry e) => e.spec.message),
        <String>['b', 'c', 'd'],
        reason: 'the oldest is dropped and the newest is last (bottom)',
      );
      c.dispose();
    });

    test('the cap holds however many are pushed at once', () {
      final DabblerToastController c = DabblerToastController();
      for (int i = 0; i < 12; i++) {
        c.show(_spec('m$i'));
      }
      expect(c.visible.length, 3);
      expect(
        c.visible.map((DabblerToastEntry e) => e.spec.message),
        <String>['m9', 'm10', 'm11'],
      );
      c.dispose();
    });

    test('a non-default cap is honoured', () {
      final DabblerToastController c = DabblerToastController(max: 1);
      c.show(_spec('a'));
      c.show(_spec('b'));
      expect(c.visible.single.spec.message, 'b');
      c.dispose();
    });

    test('expiring one makes room for the next without dropping anything', () {
      final DabblerToastController c = DabblerToastController();
      final String a = c.show(_spec('a'));
      c.show(_spec('b'));
      c.show(_spec('c'));

      c.dismiss(a); // what the toast's own timer does when it elapses.
      expect(c.visible.length, 2);

      c.show(_spec('d'));
      expect(
        c.visible.map((DabblerToastEntry e) => e.spec.message),
        <String>['b', 'c', 'd'],
        reason: 'room was freed, so nothing else had to be dropped',
      );
      c.dispose();
    });

    test('dismissal is by id and order-independent', () {
      final DabblerToastController c = DabblerToastController();
      c.show(_spec('a'));
      final String b = c.show(_spec('b'));
      c.show(_spec('c'));

      c.dismiss(b); // the middle one, not the head of the queue.

      expect(
        c.visible.map((DabblerToastEntry e) => e.spec.message),
        <String>['a', 'c'],
      );
      c.dispose();
    });

    test('dismissing an unknown id changes nothing and notifies nothing', () {
      final DabblerToastController c = DabblerToastController();
      c.show(_spec('a'));
      int notifications = 0;
      c.addListener(() => notifications++);

      c.dismiss('no-such-toast');

      expect(c.visible.length, 1);
      expect(notifications, 0);
      c.dispose();
    });

    test('show returns the supplied id, or a generated one', () {
      final DabblerToastController c = DabblerToastController();
      expect(c.show(_spec('a', id: 'mine')), 'mine');
      expect(c.show(_spec('b')), isNotEmpty);
      c.dispose();
    });

    test('clear empties the queue; clearing twice notifies once', () {
      final DabblerToastController c = DabblerToastController();
      c.show(_spec('a'));
      c.show(_spec('b'));
      int notifications = 0;
      c.addListener(() => notifications++);

      c.clear();
      c.clear();

      expect(c.visible, isEmpty);
      expect(notifications, 1);
      c.dispose();
    });

    test('show and dismiss each notify once', () {
      final DabblerToastController c = DabblerToastController();
      int notifications = 0;
      c.addListener(() => notifications++);

      final String id = c.show(_spec('a'));
      expect(notifications, 1);
      c.dismiss(id);
      expect(notifications, 2);
      c.dispose();
    });

    test('visible is unmodifiable — callers cannot edit the queue', () {
      final DabblerToastController c = DabblerToastController();
      c.show(_spec('a'));
      expect(
        () => c.visible.add(const DabblerToastEntry(
          id: 'x',
          spec: DabblerToastSpec(message: 'x'),
        )),
        throwsUnsupportedError,
      );
      c.dispose();
    });
  });

  // ---------------------------------------------------------------------
  // AC1 — one toast, rendered from DS-102 colours and DS-200 geometry.
  // ---------------------------------------------------------------------
  group('DabblerToast (AC1 — the single toast)', () {
    testWidgets('renders its message', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerToast(message: 'joined game')));
      await tester.pumpAndSettle();
      expect(find.text('joined game'), findsOneWidget);
    });

    testWidgets('defaults to the neutral tone: card surface, primary ink, '
        'card outline', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerToast(message: 'link copied')));
      await tester.pumpAndSettle();

      final DabblerColors colors = _colors();
      final BoxDecoration shell = _shell(tester);
      expect(shell.color, colors.surfaceCard);
      expect((shell.border! as Border).top.color, colors.borderDefault);

      final Text text = tester.widget<Text>(find.text('link copied'));
      expect(text.style!.color, colors.textPrimary);
    });

    for (final DabblerToastTone tone in <DabblerToastTone>[
      DabblerToastTone.success,
      DabblerToastTone.warning,
      DabblerToastTone.error,
      DabblerToastTone.info,
    ]) {
      testWidgets('$tone paints status surface + strong ink + strong@20% '
          'hairline', (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(DabblerToast(tone: tone, message: 'msg')),
        );
        await tester.pumpAndSettle();

        final DabblerStatusColor expected =
            _colors().status(tone.status!);
        final BoxDecoration shell = _shell(tester);

        expect(shell.color, expected.surface);
        expect(
          (shell.border! as Border).top.color,
          expected.strong.withValues(alpha: 0.20),
        );
        expect(
          tester.widget<Text>(find.text('msg')).style!.color,
          expected.strong,
        );
      });
    }

    testWidgets('every tone resolves in dark too', (WidgetTester tester) async {
      for (final DabblerToastTone tone in DabblerToastTone.values) {
        await tester.pumpWidget(
          _host(
            DabblerToast(tone: tone, message: 'dark'),
            brightness: Brightness.dark,
          ),
        );
        await tester.pumpAndSettle();

        final DabblerColors dark = _colors(brightness: Brightness.dark);
        final Color expectedFill = tone.status == null
            ? dark.surfaceCard
            : dark.status(tone.status!).surface;
        expect(_shell(tester).color, expectedFill, reason: '$tone in dark');
      }
    });

    testWidgets('geometry: radius lg, 1px hairline, 12/15 padding, '
        'min-height 45, max width 420', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerToast(message: 'geometry')));
      await tester.pumpAndSettle();

      final Container container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(DabblerToast),
              matching: find.byType(Container),
            )
            .first,
      );
      final BoxDecoration shell = container.decoration! as BoxDecoration;

      expect(shell.borderRadius, DabblerRadius.lgAll);
      expect((shell.border! as Border).top.width, DabblerSizing.borderDefault);
      expect(
        container.padding,
        const EdgeInsetsDirectional.symmetric(
          vertical: DabblerSpacing.space4, // 12
          horizontal: DabblerSpacing.space5, // 15
        ),
      );
      expect(container.constraints!.minHeight, DabblerSizing.touchTargetMin);
      expect(container.constraints!.maxWidth, 420);

      final Size rendered = tester.getSize(find.byType(DabblerToast));
      expect(rendered.height, greaterThanOrEqualTo(45));
    });

    testWidgets('is flat — no shadow, no gradient', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerToast(
          tone: DabblerToastTone.error,
          message: 'flat',
        )),
      );
      await tester.pumpAndSettle();
      final BoxDecoration shell = _shell(tester);
      expect(shell.boxShadow, anyOf(isNull, isEmpty));
      expect(shell.gradient, isNull);
    });

    testWidgets('the icon slot is 18×18 and inherits the tone ink',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerToast(
          tone: DabblerToastTone.success,
          message: 'with glyph',
          icon: Icon(Icons.check),
        )),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSize(find.byIcon(Icons.check)),
        const Size(DabblerSizing.iconSm, DabblerSizing.iconSm),
      );
      final DabblerStatusColor success =
          _colors().status(DabblerStatusTone.success);
      final IconThemeData theme = IconTheme.of(
        tester.element(find.byIcon(Icons.check)),
      );
      expect(theme.color, success.strong);
      expect(theme.size, DabblerSizing.iconSm);
    });

    testWidgets('no icon is rendered by default — the package has no icon '
        'dependency yet', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerToast(message: 'no glyph')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(DabblerToast),
          matching: find.byType(Icon),
        ),
        findsNothing,
      );
    });

    testWidgets('announces politely as a live region',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const DabblerToast(message: 'announced')));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('announced')),
        matchesSemantics(label: 'announced', isLiveRegion: true),
      );
      handle.dispose();
    });
  });

  // ---------------------------------------------------------------------
  // The action button.
  // ---------------------------------------------------------------------
  group('DabblerToast action', () {
    testWidgets('has a >=44x44 target — measured, not asserted in a comment',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(DabblerToast(
          message: "couldn't join",
          action: DabblerToastAction(label: 'retry', onPressed: () {}),
        )),
      );
      await tester.pumpAndSettle();

      final Size target = tester.getSize(find.byKey(DabblerToast.actionTargetKey));
      expect(target.width, greaterThanOrEqualTo(44));
      expect(target.height, greaterThanOrEqualTo(44));
      expect(target.height, DabblerSizing.touchTargetMin);
    });

    testWidgets('fires onPressed and then dismisses',
        (WidgetTester tester) async {
      final List<String> log = <String>[];
      await tester.pumpWidget(
        _host(DabblerToast(
          message: "couldn't join",
          duration: DabblerToastSpec.sticky,
          action: DabblerToastAction(
            label: 'retry',
            onPressed: () => log.add('pressed'),
          ),
          onDismiss: () => log.add('dismissed'),
        )),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(DabblerToast.actionTargetKey));
      await tester.pump();

      expect(log, <String>['pressed', 'dismissed']);
    });

    testWidgets('carries the shared focus ring', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(DabblerToast(
          message: 'msg',
          action: DabblerToastAction(label: 'retry', onPressed: () {}),
        )),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(DabblerToast),
          matching: find.byType(DabblerFocusRing),
        ),
        findsOneWidget,
      );
    });

    testWidgets('is a semantic button carrying its label',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(DabblerToast(
          message: 'msg',
          action: DabblerToastAction(label: 'retry', onPressed: () {}),
        )),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byKey(DabblerToast.actionTargetKey)),
        matchesSemantics(
          label: 'retry',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('no action renders no button', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerToast(message: 'msg')));
      await tester.pumpAndSettle();
      expect(find.byKey(DabblerToast.actionTargetKey), findsNothing);
    });
  });

  // ---------------------------------------------------------------------
  // The dismissal timer.
  // ---------------------------------------------------------------------
  group('DabblerToast timer', () {
    testWidgets('auto-dismisses after the default 4000ms, and not before',
        (WidgetTester tester) async {
      int dismissals = 0;
      await tester.pumpWidget(
        _host(DabblerToast(
          message: 'joined game',
          onDismiss: () => dismissals++,
        )),
      );
      await tester.pump(const Duration(milliseconds: 3900));
      expect(dismissals, 0);
      await tester.pump(const Duration(milliseconds: 200));
      expect(dismissals, 1);
      expect(DabblerToastSpec.defaultDuration.inMilliseconds, 4000);

      await tester.pumpWidget(_host(const SizedBox.shrink()));
    });

    testWidgets('a duration of zero is sticky — it never fires',
        (WidgetTester tester) async {
      int dismissals = 0;
      await tester.pumpWidget(
        _host(DabblerToast(
          message: 'syncing',
          duration: DabblerToastSpec.sticky,
          onDismiss: () => dismissals++,
        )),
      );
      await tester.pump(const Duration(seconds: 30));
      expect(dismissals, 0);
      await tester.pumpWidget(_host(const SizedBox.shrink()));
    });

    testWidgets('a disposed toast never fires its timer',
        (WidgetTester tester) async {
      int dismissals = 0;
      await tester.pumpWidget(
        _host(DabblerToast(
          message: 'gone',
          onDismiss: () => dismissals++,
        )),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // The widget leaves the tree well before its 4000ms elapses.
      await tester.pumpWidget(_host(const SizedBox.shrink()));
      await tester.pump(const Duration(seconds: 10));

      expect(
        dismissals,
        0,
        reason: 'the timer must be cancelled in dispose, not left running',
      );
    });

    testWidgets('hover pauses the timer and leaving re-arms it',
        (WidgetTester tester) async {
      int dismissals = 0;
      await tester.pumpWidget(
        _host(DabblerToast(
          message: 'hover me',
          onDismiss: () => dismissals++,
        )),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final TestPointer mouse =
          TestPointer(1, PointerDeviceKind.mouse);
      final Offset centre = tester.getCenter(find.byType(DabblerToast));
      await tester.sendEventToBinding(mouse.hover(centre));
      await tester.pump();

      await tester.pump(const Duration(seconds: 20));
      expect(dismissals, 0, reason: 'hover pauses the dismissal timer');

      await tester.sendEventToBinding(mouse.hover(const Offset(-500, -500)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 3900));
      expect(dismissals, 0, reason: 'the timer restarts from the beginning');
      await tester.pump(const Duration(milliseconds: 200));
      expect(dismissals, 1);

      await tester.pumpWidget(_host(const SizedBox.shrink()));
    });

    testWidgets('focus pauses the timer and blur re-arms it',
        (WidgetTester tester) async {
      int dismissals = 0;
      await tester.pumpWidget(
        _host(DabblerToast(
          message: 'focus me',
          action: DabblerToastAction(label: 'retry', onPressed: () {}),
          onDismiss: () => dismissals++,
        )),
      );
      await tester.pumpAndSettle();

      final FocusNode node = tester
          .widget<DabblerFocusRing>(find.byType(DabblerFocusRing))
          .focusNode!;
      node.requestFocus();
      await tester.pump();

      await tester.pump(const Duration(seconds: 20));
      expect(dismissals, 0, reason: 'focus pauses the dismissal timer');

      node.unfocus();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 4100));
      expect(dismissals, 1);

      await tester.pumpWidget(_host(const SizedBox.shrink()));
    });
  });

  // ---------------------------------------------------------------------
  // Motion.
  // ---------------------------------------------------------------------
  group('DabblerToast motion', () {
    testWidgets('entry animates opacity and a downward 9px translate',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerToast(
          message: 'entering',
          duration: DabblerToastSpec.sticky,
        )),
      );
      await tester.pump(); // build; the entry has not started.

      final Finder fade = find.descendant(
        of: find.byType(DabblerToast),
        matching: find.byType(FadeTransition),
      );
      expect(tester.widget<FadeTransition>(fade).opacity.value, 0);
      expect(
        find.descendant(
          of: find.byType(DabblerToast),
          matching: find.byType(Transform),
        ),
        findsWidgets,
        reason: 'the translate is present when motion is allowed',
      );

      await tester.pumpAndSettle();
      expect(tester.widget<FadeTransition>(fade).opacity.value, 1);
      expect(DabblerMotion.base.inMilliseconds, 120);
    });

    testWidgets('reduced motion drops the translate and animates opacity only',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerToast(
            message: 'still',
            duration: DabblerToastSpec.sticky,
          ),
          reduceMotion: true,
        ),
      );
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(DabblerToast),
          matching: find.byType(FadeTransition),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(DabblerToast),
          matching: find.byType(Transform),
        ),
        findsNothing,
        reason: 'under reduced motion only opacity animates',
      );
      await tester.pumpAndSettle();
    });
  });

  // ---------------------------------------------------------------------
  // The provider and its viewport.
  // ---------------------------------------------------------------------
  group('DabblerToastProvider', () {
    testWidgets('renders the child and, initially, no toast',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(bounded: false, const DabblerToastProvider(child: Text('app'))),
      );
      await tester.pumpAndSettle();
      expect(find.text('app'), findsOneWidget);
      expect(find.byType(DabblerToast), findsNothing);
    });

    testWidgets('of() reaches the queue and showing paints a toast',
        (WidgetTester tester) async {
      late BuildContext inner;
      await tester.pumpWidget(
        _host(bounded: false, DabblerToastProvider(
          child: Builder(builder: (BuildContext context) {
            inner = context;
            return const Text('app');
          }),
        )),
      );
      await tester.pumpAndSettle();

      DabblerToastProvider.of(inner).show(_spec('joined game'));
      await tester.pumpAndSettle();

      expect(find.byType(DabblerToast), findsOneWidget);
      expect(find.text('joined game'), findsOneWidget);
    });

    testWidgets('caps the painted toasts at 3, newest at the bottom',
        (WidgetTester tester) async {
      final DabblerToastController controller = DabblerToastController();
      await tester.pumpWidget(
        _host(bounded: false, DabblerToastProvider(
          controller: controller,
          child: const Text('app'),
        )),
      );
      for (final String m in <String>['a', 'b', 'c', 'd']) {
        controller.show(_spec(m, duration: DabblerToastSpec.sticky));
      }
      await tester.pumpAndSettle();

      expect(find.byType(DabblerToast), findsNWidgets(3));
      expect(find.text('a'), findsNothing, reason: 'the oldest was dropped');

      final double bTop = tester.getTopLeft(find.text('b')).dy;
      final double dTop = tester.getTopLeft(find.text('d')).dy;
      expect(dTop, greaterThan(bTop), reason: 'newest sits at the bottom');

      await tester.pumpWidget(_host(const SizedBox.shrink()));
      controller.dispose();
    });

    testWidgets('stacks with a 9px gap', (WidgetTester tester) async {
      final DabblerToastController controller = DabblerToastController();
      await tester.pumpWidget(
        _host(bounded: false, DabblerToastProvider(
          controller: controller,
          child: const Text('app'),
        )),
      );
      controller.show(_spec('one', duration: DabblerToastSpec.sticky));
      controller.show(_spec('two', duration: DabblerToastSpec.sticky));
      await tester.pumpAndSettle();

      final List<Element> toasts =
          find.byType(DabblerToast).evaluate().toList(growable: false);
      final Rect first = tester.getRect(find.byWidget(toasts[0].widget));
      final Rect second = tester.getRect(find.byWidget(toasts[1].widget));
      expect(second.top - first.bottom, DabblerSpacing.space3);

      await tester.pumpWidget(_host(const SizedBox.shrink()));
      controller.dispose();
    });

    testWidgets('the viewport clears the bottom safe-area inset',
        (WidgetTester tester) async {
      final DabblerToastController controller = DabblerToastController();
      const double inset = 34; // a home-indicator-sized inset.
      await tester.pumpWidget(
        _host(
          DabblerToastProvider(
            controller: controller,
            child: const Text('app'),
          ),
          bounded: false,
          viewPadding: const EdgeInsets.only(bottom: inset),
        ),
      );
      controller.show(_spec('safe', duration: DabblerToastSpec.sticky));
      await tester.pumpAndSettle();

      final double screenBottom = tester.getSize(find.byType(MaterialApp)).height;
      final double toastBottom = tester.getRect(find.byType(DabblerToast)).bottom;
      expect(
        screenBottom - toastBottom,
        inset + DabblerSpacing.space4,
        reason: 'space4 above the safe-area inset',
      );

      await tester.pumpWidget(_host(const SizedBox.shrink()));
      controller.dispose();
    });

    testWidgets('the viewport gutters by 12 and caps the toast at 420 wide',
        (WidgetTester tester) async {
      final DabblerToastController controller = DabblerToastController();
      await tester.pumpWidget(
        _host(
          bounded: false,
          DabblerToastProvider(
            controller: controller,
            child: const Text('app'),
          ),
        ),
      );
      controller.show(_spec('wide', duration: DabblerToastSpec.sticky));
      await tester.pumpAndSettle();

      final double screenWidth = tester.getSize(find.byType(MaterialApp)).width;
      final Rect toast = tester.getRect(find.byType(DabblerToast));
      expect(screenWidth, greaterThan(420 + 2 * DabblerSpacing.space4));
      expect(toast.width, 420, reason: 'capped at the 420 maximum measure');

      await tester.pumpWidget(_host(const SizedBox.shrink()));
      controller.dispose();
    });

    testWidgets('a narrow viewport leaves a 12px gutter on each side',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final DabblerToastController controller = DabblerToastController();
      await tester.pumpWidget(
        _host(
          bounded: false,
          DabblerToastProvider(
            controller: controller,
            child: const Text('app'),
          ),
        ),
      );
      controller.show(_spec('narrow', duration: DabblerToastSpec.sticky));
      await tester.pumpAndSettle();

      final Rect toast = tester.getRect(find.byType(DabblerToast));
      expect(toast.left, DabblerSpacing.space4);
      expect(320 - toast.right, DabblerSpacing.space4);

      await tester.pumpWidget(_host(const SizedBox.shrink()));
      controller.dispose();
    });

    testWidgets('a toast whose timer elapses leaves the queue and the tree',
        (WidgetTester tester) async {
      final DabblerToastController controller = DabblerToastController();
      await tester.pumpWidget(
        _host(bounded: false, DabblerToastProvider(
          controller: controller,
          child: const Text('app'),
        )),
      );
      controller.show(_spec('transient'));
      await tester.pumpAndSettle();
      expect(find.byType(DabblerToast), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 4100));
      await tester.pumpAndSettle();

      expect(controller.visible, isEmpty);
      expect(find.byType(DabblerToast), findsNothing);

      await tester.pumpWidget(_host(const SizedBox.shrink()));
      controller.dispose();
    });

    testWidgets('the app behind the viewport stays tappable',
        (WidgetTester tester) async {
      final DabblerToastController controller = DabblerToastController();
      int taps = 0;
      await tester.pumpWidget(
        _host(bounded: false, DabblerToastProvider(
          controller: controller,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: GestureDetector(
              onTap: () => taps++,
              child: const SizedBox(width: 60, height: 60, child: Text('hit')),
            ),
          ),
        )),
      );
      controller.show(_spec('over it', duration: DabblerToastSpec.sticky));
      await tester.pumpAndSettle();

      await tester.tap(find.text('hit'), warnIfMissed: false);
      await tester.pump();
      expect(taps, 1, reason: 'the viewport gaps must not swallow hits');

      await tester.pumpWidget(_host(const SizedBox.shrink()));
      controller.dispose();
    });

    testWidgets('maybeOf returns null with no provider',
        (WidgetTester tester) async {
      late BuildContext inner;
      await tester.pumpWidget(
        _host(Builder(builder: (BuildContext context) {
          inner = context;
          return const Text('bare');
        })),
      );
      expect(DabblerToastProvider.maybeOf(inner), isNull);
    });
  });

  // ---------------------------------------------------------------------
  // The imperative escape hatch.
  // ---------------------------------------------------------------------
  group('DabblerToasts', () {
    testWidgets('routes to the mounted provider and unregisters on unmount',
        (WidgetTester tester) async {
      final DabblerToastController controller = DabblerToastController();
      await tester.pumpWidget(
        _host(bounded: false, DabblerToastProvider(
          controller: controller,
          child: const Text('app'),
        )),
      );
      await tester.pumpAndSettle();

      expect(DabblerToasts.show(_spec('imperative')), isNotNull);
      await tester.pumpAndSettle();
      expect(find.text('imperative'), findsOneWidget);

      await tester.pumpWidget(_host(const SizedBox.shrink()));
      expect(DabblerToasts.controller, isNull);
      expect(DabblerToasts.show(_spec('nowhere')), isNull);
      controller.dispose();
    });
  });
}
