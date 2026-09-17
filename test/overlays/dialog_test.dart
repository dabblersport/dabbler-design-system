import 'package:dabbler_design_system/src/tokens/dabbler_motion.dart';
import 'package:dabbler_design_system/src/interaction/scrim.dart';
import 'package:dabbler_design_system/src/overlays/dialog.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The minimum a Dialog test needs: a [Directionality], a [MediaQuery] the
/// test controls (size drives the 360px stacking rule, `disableAnimations`
/// drives the fade) and a [DabblerColors] for `DabblerColors.of` to find.
Widget host(
  Widget child, {
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
  Size size = const Size(800, 600),
  bool disableAnimations = false,
}) {
  final DabblerColors colors = DabblerColors.resolve(
    theme: theme,
    brightness: brightness,
  );
  return MediaQuery(
    data: MediaQueryData(size: size, disableAnimations: disableAnimations),
    child: Directionality(
      textDirection: textDirection,
      child: Theme(
        data: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
        child: child,
      ),
    ),
  );
}

BoxDecoration _panelDecoration(WidgetTester tester) =>
    tester.widget<DecoratedBox>(find.byKey(DabblerDialog.panelKey)).decoration
        as BoxDecoration;

void main() {
  group('the one legal shadow — KAN-232 AC1', () {
    testWidgets('light paints exactly DabblerElevation.dialogLight', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerDialog(title: 'leave?')));
      expect(
        _panelDecoration(tester).boxShadow,
        DabblerElevation.dialogFor(Brightness.light),
      );
      expect(_panelDecoration(tester).boxShadow, DabblerElevation.dialogLight);
    });

    testWidgets('dark paints exactly DabblerElevation.dialogDark', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerDialog(title: 'leave?'), brightness: Brightness.dark),
      );
      expect(
        _panelDecoration(tester).boxShadow,
        DabblerElevation.dialogFor(Brightness.dark),
      );
      expect(_panelDecoration(tester).boxShadow, DabblerElevation.dialogDark);
    });

    testWidgets(
      'the shadow is the same in every theme — it is not brand-tinted',
      (WidgetTester tester) async {
        for (final DabblerTheme theme in DabblerTheme.values) {
          await tester.pumpWidget(
            host(const DabblerDialog(title: 'leave?'), theme: theme),
          );
          expect(
            _panelDecoration(tester).boxShadow,
            DabblerElevation.dialogLight,
          );
        }
      },
    );

    testWidgets('it is the ONLY shadow in the tree — the system stays flat', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerDialog(title: 'leave?')));
      final Iterable<DecoratedBox> boxes = tester.widgetList<DecoratedBox>(
        find.byType(DecoratedBox),
      );
      final Iterable<DecoratedBox> shadowed = boxes.where((DecoratedBox box) {
        final Decoration decoration = box.decoration;
        return decoration is BoxDecoration &&
            (decoration.boxShadow?.isNotEmpty ?? false);
      });
      expect(shadowed, hasLength(1));
    });
  });

  group('the scrim is DS-200, not a wash of our own — KAN-232 AC1', () {
    testWidgets('a DabblerScrim is what sits behind the panel', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerDialog(title: 'leave?')));
      expect(find.byType(DabblerScrim), findsOneWidget);
    });

    testWidgets('the wash colour is --color-scrim', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerDialog(title: 'leave?')));
      final ColoredBox wash = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(DabblerScrim),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(
        wash.color,
        DabblerColors.resolve(
          theme: DabblerTheme.main,
          brightness: Brightness.light,
        ).scrim,
      );
    });

    testWidgets('the scrim is inert when the dialog is not dismissible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerDialog(title: 'leave?', dismissible: false)),
      );
      expect(
        tester.widget<DabblerScrim>(find.byType(DabblerScrim)).onDismiss,
        isNull,
      );
    });
  });

  group('the panel', () {
    testWidgets('open: false renders nothing at all (Dialog.jsx:38)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerDialog(open: false, title: 'leave?')),
      );
      expect(find.byKey(DabblerDialog.panelKey), findsNothing);
      expect(find.byType(DabblerScrim), findsNothing);
      expect(find.text('leave?'), findsNothing);
    });

    testWidgets('fill, hairline and radius come from the tokens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerDialog(title: 'leave?')));
      final DabblerColors colors = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      final BoxDecoration decoration = _panelDecoration(tester);
      expect(decoration.color, colors.surfaceCard);
      expect(decoration.borderRadius, DabblerRadius.xlAll);
      expect(
        decoration.border,
        Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      );
      expect(decoration.gradient, isNull);
    });

    testWidgets('padding is --space-8 (Dialog.jsx:79)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerDialog(title: 'leave?')));
      final SingleChildScrollView scroller = tester
          .widget<SingleChildScrollView>(
            find.descendant(
              of: find.byKey(DabblerDialog.panelKey),
              matching: find.byType(SingleChildScrollView),
            ),
          );
      expect(scroller.padding, const EdgeInsets.all(DabblerSpacing.space8));
    });

    testWidgets('md caps at 420 and sm at 340 (Dialog.jsx:16)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerDialog(title: 'leave?')));
      expect(
        tester.getSize(find.byKey(DabblerDialog.panelKey)).width,
        DabblerDialogSize.md.maxWidth,
      );

      await tester.pumpWidget(
        host(const DabblerDialog(title: 'leave?', size: DabblerDialogSize.sm)),
      );
      expect(
        tester.getSize(find.byKey(DabblerDialog.panelKey)).width,
        DabblerDialogSize.sm.maxWidth,
      );
    });

    testWidgets('the panel is capped at viewport height minus --space-11', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          DabblerDialog(
            title: 'leave?',
            child: Column(
              children: List<Widget>.generate(
                60,
                (int i) => const SizedBox(height: 40),
              ),
            ),
          ),
        ),
      );
      expect(
        tester.getSize(find.byKey(DabblerDialog.panelKey)).height,
        600 - DabblerSpacing.space11,
      );
    });

    testWidgets('title is .t-title-3 and description .t-body', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerDialog(
            title: 'leave this game?',
            description: 'your spot goes back to the waitlist.',
          ),
        ),
      );
      final DabblerColors colors = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      final TextStyle title = tester
          .widget<Text>(find.text('leave this game?'))
          .style!;
      expect(title.fontSize, DabblerType.title3.fontSize);
      expect(title.color, colors.textPrimary);

      final TextStyle body = tester
          .widget<Text>(find.text('your spot goes back to the waitlist.'))
          .style!;
      expect(body.fontSize, DabblerType.body.fontSize);
      expect(body.color, colors.textSecondary);
    });
  });

  group('the action row', () {
    const List<Widget> actions = <Widget>[
      SizedBox(height: 45, child: Text('stay')),
      SizedBox(height: 45, child: Text('leave')),
    ];

    testWidgets('is a row aligned to the end at wide widths', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerDialog(title: 'leave?', actions: actions)),
      );
      final Row row = tester.widget<Row>(find.byKey(DabblerDialog.actionsKey));
      expect(row.mainAxisAlignment, MainAxisAlignment.end);
    });

    testWidgets('stacks below 360px (Dialog.prompt.md:57-59)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerDialog(title: 'leave?', actions: actions),
          size: const Size(359, 600),
        ),
      );
      final Column column = tester.widget<Column>(
        find.byKey(DabblerDialog.actionsKey),
      );
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
    });

    testWidgets('at exactly 360 it is still a row — the rule is "below"', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerDialog(title: 'leave?', actions: actions),
          size: const Size(360, 600),
        ),
      );
      expect(find.byKey(DabblerDialog.actionsKey), findsOneWidget);
      expect(tester.widget(find.byKey(DabblerDialog.actionsKey)), isA<Row>());
    });

    testWidgets('mirrors under RTL without any left/right of its own', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerDialog(title: 'leave?', actions: actions),
          textDirection: TextDirection.rtl,
        ),
      );
      // `justify-content: flex-end` is the end of the reading direction, so
      // the same MainAxisAlignment.end mirrors: the last action lands left.
      expect(
        tester.getCenter(find.text('leave')).dx,
        lessThan(tester.getCenter(find.text('stay')).dx),
      );
    });
  });

  group('motion', () {
    testWidgets('the panel fades over --motion-base with --ease-out', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerDialog(title: 'leave?')));
      final AnimatedOpacity fade = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity).last,
      );
      expect(fade.duration, DabblerMotion.base);
      expect(fade.curve, DabblerMotion.easeOut);
    });

    testWidgets('reduced motion drops the fade entirely (overlay.jsx:43)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerDialog(title: 'leave?'), disableAnimations: true),
      );
      final AnimatedOpacity fade = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity).last,
      );
      expect(fade.duration, Duration.zero);
    });
  });

  group('behaviour', () {
    testWidgets('Escape closes when dismissible', (WidgetTester tester) async {
      int closed = 0;
      await tester.pumpWidget(
        host(DabblerDialog(title: 'leave?', onClose: () => closed++)),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(closed, 1);
    });

    testWidgets('Escape does nothing when not dismissible', (
      WidgetTester tester,
    ) async {
      int closed = 0;
      await tester.pumpWidget(
        host(
          DabblerDialog(
            title: 'leave?',
            dismissible: false,
            onClose: () => closed++,
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(closed, 0);
    });

    testWidgets('a press on the scrim closes when dismissible', (
      WidgetTester tester,
    ) async {
      int closed = 0;
      await tester.pumpWidget(
        host(DabblerDialog(title: 'leave?', onClose: () => closed++)),
      );
      // The top-left corner is scrim: the panel is centred and inset by the
      // --space-8 gutter.
      await tester.tapAt(const Offset(4, 4));
      await tester.pump();
      expect(closed, 1);
    });

    testWidgets('a press on the panel does not close', (
      WidgetTester tester,
    ) async {
      int closed = 0;
      await tester.pumpWidget(
        host(DabblerDialog(title: 'leave?', onClose: () => closed++)),
      );
      await tester.tap(find.byKey(DabblerDialog.panelKey));
      await tester.pump();
      expect(closed, 0);
    });

    testWidgets('Enter runs onConfirm (Dialog.prompt.md:55)', (
      WidgetTester tester,
    ) async {
      int confirmed = 0;
      await tester.pumpWidget(
        host(DabblerDialog(title: 'leave?', onConfirm: () => confirmed++)),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(confirmed, 1);
    });
  });

  group('accessibility', () {
    testWidgets('focus moves into the panel on open', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerDialog(title: 'leave?')));
      await tester.pump();
      final FocusNode? focused = FocusManager.instance.primaryFocus;
      expect(focused, isNotNull);
      expect(
        find.descendant(
          of: find.byType(DabblerDialog),
          matching: find.byWidget(focused!.context!.widget),
        ),
        findsOneWidget,
      );
    });

    testWidgets('focus returns to the invoking element on close', (
      WidgetTester tester,
    ) async {
      final FocusNode invoker = FocusNode();
      addTearDown(invoker.dispose);

      Widget build(bool open) => host(
        Stack(
          children: <Widget>[
            Focus(focusNode: invoker, child: const SizedBox(width: 10)),
            DabblerDialog(open: open, title: 'leave?'),
          ],
        ),
      );

      await tester.pumpWidget(build(false));
      invoker.requestFocus();
      await tester.pump();
      expect(FocusManager.instance.primaryFocus, invoker);

      await tester.pumpWidget(build(true));
      await tester.pump();
      expect(FocusManager.instance.primaryFocus, isNot(invoker));

      await tester.pumpWidget(build(false));
      await tester.pump();
      expect(FocusManager.instance.primaryFocus, invoker);
    });

    testWidgets('the dialog scopes and names its route', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const DabblerDialog(title: 'leave this game?')),
      );
      expect(
        tester.getSemantics(
          find
              .descendant(
                of: find.byType(DabblerDialog),
                matching: find.byType(Focus),
              )
              .first,
        ),
        isSemantics(
          scopesRoute: true,
          namesRoute: true,
          label: 'leave this game?',
        ),
      );
      handle.dispose();
    });

    testWidgets('the scrim announces the dismiss label it is given', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          DabblerDialog(
            title: 'leave?',
            scrimDismissLabel: 'Close',
            onClose: () {},
          ),
        ),
      );
      expect(find.bySemanticsLabel('Close'), findsOneWidget);
      handle.dispose();
    });
  });

  group('showDabblerDialog', () {
    testWidgets('pushes the dialog and pops with its result', (
      WidgetTester tester,
    ) async {
      final DabblerColors colors = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      late BuildContext pageContext;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
          home: Builder(
            builder: (BuildContext context) {
              pageContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final Future<String?> result = showDabblerDialog<String>(
        context: pageContext,
        builder: (BuildContext context) => DabblerDialog(
          title: 'leave?',
          onClose: () => Navigator.of(context).pop('closed'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(DabblerDialog.panelKey), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byKey(DabblerDialog.panelKey), findsNothing);
      expect(await result, 'closed');
    });

    testWidgets('the route paints no barrier of its own — one scrim only', (
      WidgetTester tester,
    ) async {
      final DabblerColors colors = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      late BuildContext pageContext;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
          home: Builder(
            builder: (BuildContext context) {
              pageContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      unawaited(
        showDabblerDialog<void>(
          context: pageContext,
          builder: (BuildContext context) =>
              const DabblerDialog(title: 'leave?'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DabblerScrim), findsOneWidget);
      final ModalBarrier barrier = tester.widget<ModalBarrier>(
        find.byType(ModalBarrier).last,
      );
      expect(barrier.color, isNull);
    });
  });
}

/// Local stand-in for `dart:async`'s `unawaited`, kept here so the test file
/// takes no import it does not otherwise need.
void unawaited(Future<void> future) {}
