import 'dart:math' as math;

import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

/// DabblerNavigationStatus — one persistent Action Area surface for
/// activity and feedback. Every measurement is read off the rendered tree and
/// compared with a token or with another measurement, never a literal.

const double _width = 384;
const double _s = DabblerSizing.actionAreaSize;

const DabblerNavigationBottomBar _bar = DabblerNavigationBottomBar(
  safeArea: false,
);

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

Widget _status(
  DabblerNavigationStatusPayload? payload, {
  ValueChanged<DabblerNavigationStatusEndReason>? onDone,
  VoidCallback? onClosed,
  bool suspended = false,
  TextDirection direction = TextDirection.ltr,
  bool reduceMotion = false,
  Brightness brightness = Brightness.light,
}) => _hosted(
  DabblerNavigationStatus(
    payload: payload,
    onDone: onDone,
    onClosed: onClosed,
    suspended: suspended,
    bar: _bar,
    safeArea: false,
  ),
  direction: direction,
  reduceMotion: reduceMotion,
  brightness: brightness,
);

Rect _surface(WidgetTester tester) =>
    tester.getRect(find.byKey(DabblerActionArea.surfaceKey));

Rect _barRect(WidgetTester tester) =>
    tester.getRect(find.byKey(DabblerActionArea.barKey));

DabblerActionArea _area(WidgetTester tester) =>
    tester.widget<DabblerActionArea>(find.byType(DabblerActionArea));

State _areaState(WidgetTester tester) =>
    tester.state(find.byType(DabblerActionArea));

BoxDecoration _decoration(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(find.byKey(DabblerActionArea.surfaceKey))
            .decoration
        as BoxDecoration;

double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

const DabblerNavigationStatusActivity _joining =
    DabblerNavigationStatusActivity(
      presentation: DabblerNavigationActivityPresentation.spinnerLabel,
      label: 'joining game',
    );

const DabblerNavigationFeedbackData _joined = DabblerNavigationFeedbackData(
  tone: DabblerToastTone.success,
  message: 'joined game',
);

DabblerNavigationStatusActivity _progress(double value) =>
    DabblerNavigationStatusActivity(
      presentation: DabblerNavigationActivityPresentation.progress,
      label: 'uploading',
      value: value,
    );

/// Pumps [total] in [step] frames, recording the surface width each frame.
Future<List<double>> _sampleWidths(
  WidgetTester tester,
  Duration total, {
  Duration step = const Duration(milliseconds: 8),
}) async {
  final List<double> widths = <double>[_surface(tester).width];
  Duration elapsed = Duration.zero;
  while (elapsed < total) {
    await tester.pump(step);
    elapsed += step;
    widths.add(_surface(tester).width);
  }
  return widths;
}

double _maxStep(List<double> samples) {
  double worst = 0;
  for (int i = 1; i < samples.length; i++) {
    worst = math.max(worst, (samples[i] - samples[i - 1]).abs());
  }
  return worst;
}

void main() {
  group('one surface', () {
    testWidgets('the Action Area State survives every payload switch', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_status(null));
      final State first = _areaState(tester);
      final Element element = tester.element(find.byType(DabblerActionArea));

      final List<DabblerNavigationStatusPayload?> sequence =
          <DabblerNavigationStatusPayload?>[
            _joining,
            const DabblerNavigationStatusFeedback(
              DabblerNavigationFeedbackData(
                tone: DabblerToastTone.error,
                message: "couldn't join",
              ),
            ),
            _progress(0.2),
            _progress(0.8),
            const DabblerNavigationStatusFeedback(_joined),
            const DabblerNavigationStatusFeedback(
              DabblerNavigationFeedbackData(title: 'new season'),
              presentation: DabblerNavigationFeedbackPresentation.banner,
            ),
            null,
          ];
      for (final DabblerNavigationStatusPayload? payload in sequence) {
        await tester.pumpWidget(_status(payload));
        await tester.pump(DabblerMotion.slow);
        expect(identical(_areaState(tester), first), isTrue);
        expect(
          identical(tester.element(find.byType(DabblerActionArea)), element),
          isTrue,
        );
      }
      await tester.pumpAndSettle();
    });

    testWidgets('swapping the two wrapper widgets does NOT keep it — the '
        'defect this widget exists for', (WidgetTester tester) async {
      await tester.pumpWidget(
        _hosted(
          const DabblerNavigationActivity(
            presentation: DabblerNavigationActivityPresentation.spinnerLabel,
            label: 'joining game',
            bar: _bar,
            safeArea: false,
          ),
        ),
      );
      final State before = _areaState(tester);
      await tester.pumpWidget(
        _hosted(
          const DabblerNavigationFeedback(
            feedback: _joined,
            bar: _bar,
            safeArea: false,
          ),
        ),
      );
      expect(identical(_areaState(tester), before), isFalse);
      await tester.pumpAndSettle();
    });

    testWidgets('processing → result: the geometry is continuous, through the '
        'circle', (WidgetTester tester) async {
      await tester.pumpWidget(_status(_joining));
      expect(_surface(tester).width, _width);

      await tester.pumpWidget(
        _status(const DabblerNavigationStatusFeedback(_joined)),
      );
      final List<double> widths = await _sampleWidths(
        tester,
        DabblerNavigationStatus.morphToFeedbackDuration(reduceMotion: false),
      );
      // Never a jump: a swap of surfaces snaps the full bar width at once.
      expect(_maxStep(widths), lessThan((_width - _s) / 2));
      // It passes through the tone circle and grows back to the bar.
      expect(widths.reduce(math.min), _s);
      await tester.pump();
      expect(_surface(tester).width, _width);
      expect(find.text('joined game'), findsOneWidget);
    });

    testWidgets('the outgoing content is what fades while it shrinks', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_status(_joining));
      await tester.pumpWidget(
        _status(const DabblerNavigationStatusFeedback(_joined)),
      );
      await tester.pump(DabblerMotion.fast ~/ 2);
      expect(find.text('joining game'), findsOneWidget);
      expect(find.text('joined game'), findsNothing);
      // …but the circle already carries the success tone.
      await tester.pump(
        DabblerActionArea.contractDuration(reduceMotion: false),
      );
      await tester.pump(DabblerMotion.base);
      expect(_decoration(tester).color, testColors().success.surface);
      await tester.pumpAndSettle();
    });
  });

  group('processing → success', () {
    testWidgets('spinner circle takes the tone, holds, grows, times out', (
      WidgetTester tester,
    ) async {
      final List<DabblerNavigationStatusEndReason> ended =
          <DabblerNavigationStatusEndReason>[];
      int closed = 0;
      Widget build(DabblerNavigationStatusPayload? p) =>
          _status(p, onDone: ended.add, onClosed: () => closed++);
      await tester.pumpWidget(
        build(const DabblerNavigationStatusActivity(label: 'joining')),
      );
      await tester.pump(DabblerMotion.base);
      expect(_surface(tester).size, const Size(_s, _s));
      expect(_decoration(tester).color, testColors().brandPrimary);

      await tester.pumpWidget(
        build(const DabblerNavigationStatusFeedback(_joined)),
      );
      await tester.pump(DabblerMotion.base);
      // Still the circle, now in the success tone, holding.
      expect(_surface(tester).size, const Size(_s, _s));
      expect(_decoration(tester).color, testColors().success.surface);
      expect(_area(tester).phase, DabblerActionAreaPhase.collapsed);

      await tester.pump(DabblerMotion.actionAreaHold - DabblerMotion.base);
      await tester.pump(DabblerActionArea.expandDuration(reduceMotion: false));
      await tester.pump();
      expect(_surface(tester).width, _width);
      expect(ended, isEmpty);

      await tester.pump(DabblerToastSpec.defaultDuration);
      // Reported the moment it ends; the close is still playing.
      expect(ended, <DabblerNavigationStatusEndReason>[
        DabblerNavigationStatusEndReason.timeout,
      ]);
      expect(closed, 0);
      await tester.pump(DabblerMotion.slow + DabblerMotion.actionAreaHold);
      await tester.pump();
      expect(closed, 1);
      expect(_area(tester).phase, DabblerActionAreaPhase.idle);
      await tester.pumpAndSettle();
    });
  });

  group('processing → error + retry → processing → success', () {
    testWidgets('Retry restarts the work on the same surface', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<DabblerNavigationStatusPayload?> payload =
          ValueNotifier<DabblerNavigationStatusPayload?>(_joining);
      final List<DabblerNavigationStatusEndReason> ended =
          <DabblerNavigationStatusEndReason>[];
      int retried = 0;
      final DabblerNavigationStatusFeedback failure =
          DabblerNavigationStatusFeedback(
            DabblerNavigationFeedbackData(
              tone: DabblerToastTone.error,
              message: "couldn't join",
              action: DabblerToastAction(
                label: 'retry',
                onPressed: () {
                  retried++;
                  payload.value = _joining;
                },
              ),
            ),
          );

      await tester.pumpWidget(
        _hosted(
          ValueListenableBuilder<DabblerNavigationStatusPayload?>(
            valueListenable: payload,
            builder: (_, DabblerNavigationStatusPayload? p, _) =>
                DabblerNavigationStatus(
                  payload: p,
                  onDone: ended.add,
                  bar: _bar,
                  safeArea: false,
                ),
          ),
        ),
      );
      final State area = _areaState(tester);

      payload.value = failure;
      await tester.pump();
      await tester.pump(
        DabblerNavigationStatus.morphToFeedbackDuration(reduceMotion: false),
      );
      await tester.pump();
      expect(_decoration(tester).color, testColors().error.surface);
      // An error toast with Retry is still a toast: status, not alert.
      expect(_area(tester).role, DabblerActionAreaRole.status);
      final Size target = tester.getSize(
        find.byKey(DabblerNavigationStatus.actionTargetKey),
      );
      expect(target.height, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));

      await tester.tap(find.byKey(DabblerNavigationStatus.actionTargetKey));
      expect(retried, 1);
      expect(ended, <DabblerNavigationStatusEndReason>[
        DabblerNavigationStatusEndReason.action,
      ]);
      // Back through the brand circle into the processing row.
      final List<double> widths = await _sampleWidths(
        tester,
        DabblerActionArea.contractDuration(reduceMotion: false) +
            DabblerActionArea.expandDuration(reduceMotion: false),
      );
      expect(_maxStep(widths), lessThan((_width - _s) / 2));
      expect(widths.reduce(math.min), _s);
      await tester.pump();
      expect(_surface(tester).width, _width);
      expect(find.text('joining game'), findsOneWidget);
      expect(_decoration(tester).color, testColors().surfaceCard);

      payload.value = const DabblerNavigationStatusFeedback(_joined);
      await tester.pump();
      await tester.pump(
        DabblerNavigationStatus.morphToFeedbackDuration(reduceMotion: false),
      );
      await tester.pump();
      expect(find.text('joined game'), findsOneWidget);
      expect(_decoration(tester).color, testColors().success.surface);
      expect(identical(_areaState(tester), area), isTrue);
      // The action end was the only report — replacing an activity reports
      // nothing.
      expect(ended, <DabblerNavigationStatusEndReason>[
        DabblerNavigationStatusEndReason.action,
      ]);
      payload.value = null;
      await tester.pumpAndSettle();
    });
  });

  group('progress 0 → 100 → success', () {
    testWidgets('a progress tick updates in place; 100 resolves to success', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_status(_progress(0)));
      await tester.pump();
      expect(_surface(tester).width, _width);
      for (final double v in <double>[0.25, 0.5, 0.75, 1]) {
        await tester.pumpWidget(_status(_progress(v)));
        await tester.pump();
        // No contraction, no restart: the same grown row.
        expect(_area(tester).phase, DabblerActionAreaPhase.expanded);
        expect(_surface(tester).width, _width);
        expect(
          tester
              .widget<DabblerProgressBar>(find.byType(DabblerProgressBar))
              .value,
          v,
        );
      }
      await tester.pumpWidget(
        _status(
          const DabblerNavigationStatusFeedback(
            DabblerNavigationFeedbackData(
              tone: DabblerToastTone.success,
              message: 'photos uploaded',
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(
        DabblerNavigationStatus.morphToFeedbackDuration(reduceMotion: false),
      );
      await tester.pump();
      expect(find.text('photos uploaded'), findsOneWidget);
      expect(find.byType(DabblerProgressBar), findsNothing);
      expect(_surface(tester).width, _width);
      await tester.pumpAndSettle();
    });

    testWidgets('the ring fills on the circle and becomes the tone glyph', (
      WidgetTester tester,
    ) async {
      DabblerNavigationStatusActivity ring(double v) =>
          DabblerNavigationStatusActivity(
            presentation: DabblerNavigationActivityPresentation.ring,
            label: 'uploading',
            value: v,
          );
      await tester.pumpWidget(_status(ring(0)));
      await tester.pumpWidget(_status(ring(1)));
      await tester.pump();
      expect(_surface(tester).size, const Size(_s, _s));
      await tester.pumpWidget(
        _status(const DabblerNavigationStatusFeedback(_joined)),
      );
      await tester.pump();
      expect(find.byType(DabblerRing), findsNothing);
      expect(_surface(tester).size, const Size(_s, _s));
      // From a circle, the hold starts at once.
      await tester.pump(DabblerMotion.actionAreaHold);
      await tester.pump(DabblerActionArea.expandDuration(reduceMotion: false));
      await tester.pump();
      expect(_surface(tester).width, _width);
      await tester.pumpAndSettle();
    });
  });

  group('information', () {
    testWidgets('an info banner is sticky and ends on dismiss', (
      WidgetTester tester,
    ) async {
      final List<DabblerNavigationStatusEndReason> ended =
          <DabblerNavigationStatusEndReason>[];
      await tester.pumpWidget(
        _status(
          const DabblerNavigationStatusFeedback(
            DabblerNavigationFeedbackData(
              title: 'new season starting',
              message: 'fixtures are open for registration.',
              dismissible: true,
            ),
            presentation: DabblerNavigationFeedbackPresentation.banner,
          ),
          onDone: ended.add,
        ),
      );
      await tester.pump(DabblerMotion.actionAreaHold);
      await tester.pump(DabblerActionArea.expandDuration(reduceMotion: false));
      await tester.pump(DabblerToastSpec.defaultDuration * 5);
      expect(ended, isEmpty);
      expect(_surface(tester).height, greaterThan(_s));
      expect(_decoration(tester).color, testColors().info.surface);
      expect(_area(tester).role, DabblerActionAreaRole.status);
      expect(
        tester.getSize(find.byKey(DabblerNavigationStatus.dismissTargetKey)),
        const Size.square(DabblerSizing.touchTargetMin),
      );
      await tester.tap(find.byKey(DabblerNavigationStatus.dismissTargetKey));
      expect(ended, <DabblerNavigationStatusEndReason>[
        DabblerNavigationStatusEndReason.dismissed,
      ]);
      await tester.pumpAndSettle();
      expect(_area(tester).phase, DabblerActionAreaPhase.idle);
    });

    testWidgets('error and warning banners are alerts', (
      WidgetTester tester,
    ) async {
      for (final DabblerToastTone tone in DabblerToastTone.values) {
        await tester.pumpWidget(
          _hosted(
            DabblerNavigationStatus(
              payload: DabblerNavigationStatusFeedback(
                DabblerNavigationFeedbackData(tone: tone, title: 't'),
                presentation: DabblerNavigationFeedbackPresentation.banner,
              ),
              phase: DabblerActionAreaPhase.expanded,
              bar: _bar,
              safeArea: false,
            ),
          ),
        );
        final bool interrupts =
            tone == DabblerToastTone.error || tone == DabblerToastTone.warning;
        expect(
          _area(tester).role,
          interrupts
              ? DabblerActionAreaRole.alert
              : DabblerActionAreaRole.status,
          reason: tone.name,
        );
      }
    });
  });

  group('onDone reasons', () {
    testWidgets('replaced: a running message superseded by a new one', (
      WidgetTester tester,
    ) async {
      final List<DabblerNavigationStatusEndReason> ended =
          <DabblerNavigationStatusEndReason>[];
      await tester.pumpWidget(
        _status(
          const DabblerNavigationStatusFeedback(_joined),
          onDone: ended.add,
        ),
      );
      await tester.pump(DabblerMotion.actionAreaHold);
      await tester.pumpWidget(
        _status(
          const DabblerNavigationStatusFeedback(
            DabblerNavigationFeedbackData(message: 'link copied'),
          ),
          onDone: ended.add,
        ),
      );
      // After the frame that handed the new payload in.
      expect(ended, <DabblerNavigationStatusEndReason>[
        DabblerNavigationStatusEndReason.replaced,
      ]);
      await tester.pump(
        DabblerNavigationStatus.morphToFeedbackDuration(reduceMotion: false),
      );
      await tester.pump();
      expect(find.text('link copied'), findsOneWidget);
      expect(find.text('joined game'), findsNothing);
      await tester.pumpAndSettle();
    });

    testWidgets('the same message re-wrapped is not a new message', (
      WidgetTester tester,
    ) async {
      final List<DabblerNavigationStatusEndReason> ended =
          <DabblerNavigationStatusEndReason>[];
      await tester.pumpWidget(
        _status(
          const DabblerNavigationStatusFeedback(_joined),
          onDone: ended.add,
        ),
      );
      await tester.pump(DabblerMotion.actionAreaHold);
      await tester.pump(DabblerActionArea.expandDuration(reduceMotion: false));
      // A new wrapper around the same data: nothing restarts.
      await tester.pumpWidget(
        _status(
          // ignore: prefer_const_constructors
          DabblerNavigationStatusFeedback(_joined),
          onDone: ended.add,
        ),
      );
      await tester.pump();
      expect(_area(tester).phase, DabblerActionAreaPhase.expanded);
      expect(ended, isEmpty);
    });

    testWidgets('a null from onDone does not cut the close short', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<DabblerNavigationStatusPayload?> payload =
          ValueNotifier<DabblerNavigationStatusPayload?>(
            const DabblerNavigationStatusFeedback(_joined),
          );
      int closed = 0;
      await tester.pumpWidget(
        _hosted(
          ValueListenableBuilder<DabblerNavigationStatusPayload?>(
            valueListenable: payload,
            builder: (_, DabblerNavigationStatusPayload? p, _) =>
                DabblerNavigationStatus(
                  payload: p,
                  onDone: (_) => payload.value = null,
                  onClosed: () => closed++,
                  bar: _bar,
                  safeArea: false,
                ),
          ),
        ),
      );
      await tester.pump(DabblerMotion.actionAreaHold);
      await tester.pump(DabblerActionArea.expandDuration(reduceMotion: false));
      await tester.pump(DabblerToastSpec.defaultDuration);
      await tester.pump();
      expect(payload.value, isNull);
      // Still the tone circle, holding — not snapped to idle.
      expect(_area(tester).phase, DabblerActionAreaPhase.collapsed);
      await tester.pump(DabblerMotion.slow + DabblerMotion.actionAreaHold);
      await tester.pump();
      expect(closed, 1);
      expect(_area(tester).phase, DabblerActionAreaPhase.idle);
    });
  });

  group('activity action (cancel)', () {
    testWidgets('a cancel on the row: touch target, onPressed, action, idle', (
      WidgetTester tester,
    ) async {
      int cancelled = 0;
      int closed = 0;
      final List<DabblerNavigationStatusEndReason> ended =
          <DabblerNavigationStatusEndReason>[];
      final DabblerNavigationStatusActivity uploading =
          DabblerNavigationStatusActivity(
            presentation: DabblerNavigationActivityPresentation.progress,
            label: 'uploading',
            value: 0.4,
            action: DabblerToastAction(
              label: 'cancel',
              onPressed: () => cancelled++,
            ),
          );
      await tester.pumpWidget(
        _status(uploading, onDone: ended.add, onClosed: () => closed++),
      );
      await tester.pump();
      final Finder target = find.byKey(DabblerNavigationStatus.actionTargetKey);
      expect(target, findsOneWidget);
      expect(
        tester.getSize(target).height,
        greaterThanOrEqualTo(DabblerSizing.touchTargetMin),
      );
      // The toast action's treatment, in the card's ink.
      final Text label = tester.widget<Text>(find.text('cancel'));
      expect(label.style!.fontWeight, DabblerType.semibold);
      expect(label.style!.color, testColors().textPrimary);
      // After the bar, at the inline end.
      expect(
        tester.getRect(target).left,
        greaterThan(tester.getRect(find.byType(DabblerProgressBar)).right),
      );

      await tester.tap(target);
      expect(cancelled, 1);
      expect(ended, <DabblerNavigationStatusEndReason>[
        DabblerNavigationStatusEndReason.action,
      ]);
      await tester.pump(
        DabblerActionArea.contractDuration(reduceMotion: false),
      );
      await tester.pump();
      expect(closed, 1);
      expect(_area(tester).phase, DabblerActionAreaPhase.idle);
      // The same activity handed in again does not reopen it.
      await tester.pumpWidget(
        _status(uploading, onDone: ended.add, onClosed: () => closed++),
      );
      await tester.pump();
      expect(_area(tester).phase, DabblerActionAreaPhase.idle);
      await tester.pumpAndSettle();
    });

    testWidgets('RTL: the cancel sits at the inline end, on the left', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _status(
          const DabblerNavigationStatusActivity(
            presentation: DabblerNavigationActivityPresentation.spinnerLabel,
            label: 'joining game',
            action: DabblerToastAction(label: 'cancel'),
          ),
          direction: TextDirection.rtl,
        ),
      );
      await tester.pump();
      final Rect target = tester.getRect(
        find.byKey(DabblerNavigationStatus.actionTargetKey),
      );
      final Rect text = tester.getRect(find.text('joining game'));
      expect(target.right, lessThanOrEqualTo(text.left));
      expect(target.left, greaterThan(_surface(tester).left));
    });

    testWidgets('the compact circle has no room for it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _status(
          const DabblerNavigationStatusActivity(
            label: 'joining',
            action: DabblerToastAction(label: 'cancel'),
          ),
        ),
      );
      expect(find.byKey(DabblerNavigationStatus.actionTargetKey), findsNothing);
      expect(find.text('cancel'), findsNothing);
    });

    testWidgets('DabblerNavigationActivity forwards action and onEnded', (
      WidgetTester tester,
    ) async {
      final List<DabblerNavigationStatusEndReason> ended =
          <DabblerNavigationStatusEndReason>[];
      await tester.pumpWidget(
        _hosted(
          DabblerNavigationActivity(
            presentation: DabblerNavigationActivityPresentation.spinnerLabel,
            label: 'joining game',
            action: const DabblerToastAction(label: 'cancel'),
            onEnded: ended.add,
            bar: _bar,
            safeArea: false,
          ),
        ),
      );
      await tester.tap(find.byKey(DabblerNavigationStatus.actionTargetKey));
      expect(ended, <DabblerNavigationStatusEndReason>[
        DabblerNavigationStatusEndReason.action,
      ]);
      // The spinner never settles; the contraction is timers and a fade.
      await tester.pump(
        DabblerActionArea.contractDuration(reduceMotion: false),
      );
      await tester.pump();
      expect(_area(tester).phase, DabblerActionAreaPhase.idle);
    });
  });

  group('suspended', () {
    testWidgets('holds the surface idle and runs no timer; resumes from the '
        'start', (WidgetTester tester) async {
      final List<DabblerNavigationStatusEndReason> ended =
          <DabblerNavigationStatusEndReason>[];
      await tester.pumpWidget(
        _status(
          const DabblerNavigationStatusFeedback(_joined),
          onDone: ended.add,
          suspended: true,
        ),
      );
      await tester.pump(DabblerToastSpec.defaultDuration * 3);
      expect(_area(tester).phase, DabblerActionAreaPhase.idle);
      expect(ended, isEmpty);
      // The bar stays live while suspended.
      expect(
        tester
            .widget<IgnorePointer>(
              find
                  .descendant(
                    of: find.byKey(DabblerActionArea.barKey),
                    matching: find.byType(IgnorePointer),
                  )
                  .first,
            )
            .ignoring,
        isFalse,
      );

      await tester.pumpWidget(
        _status(
          const DabblerNavigationStatusFeedback(_joined),
          onDone: ended.add,
        ),
      );
      await tester.pump();
      expect(_area(tester).phase, DabblerActionAreaPhase.collapsed);
      await tester.pump(DabblerMotion.actionAreaHold);
      await tester.pump();
      expect(_area(tester).phase, DabblerActionAreaPhase.expanded);
      await tester.pump(DabblerToastSpec.defaultDuration);
      expect(ended, <DabblerNavigationStatusEndReason>[
        DabblerNavigationStatusEndReason.timeout,
      ]);
      await tester.pumpAndSettle();
    });

    testWidgets(
      'suspending a running activity drops to idle, resuming restores it, no report',
      (WidgetTester tester) async {
        final List<DabblerNavigationStatusEndReason> ended =
            <DabblerNavigationStatusEndReason>[];
        await tester.pumpWidget(_status(_joining, onDone: ended.add));
        await tester.pumpWidget(
          _status(_joining, onDone: ended.add, suspended: true),
        );
        expect(_area(tester).phase, DabblerActionAreaPhase.idle);
        await tester.pumpWidget(_status(_joining, onDone: ended.add));
        expect(_area(tester).phase, DabblerActionAreaPhase.expanded);
        expect(ended, isEmpty);
      },
    );
  });

  group('reduced motion', () {
    testWidgets('the morph keeps its order; the size jumps', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_status(_joining, reduceMotion: true));
      await tester.pumpWidget(
        _status(
          const DabblerNavigationStatusFeedback(_joined),
          reduceMotion: true,
        ),
      );
      await tester.pump();
      // The content fade still runs before the size changes…
      expect(_surface(tester).width, _width);
      await tester.pump(DabblerMotion.fast);
      await tester.pump();
      // …then the circle, with no growth leg.
      expect(_surface(tester).size, const Size(_s, _s));
      await tester.pump(DabblerMotion.actionAreaHold);
      await tester.pump();
      expect(_surface(tester).width, _width);
      expect(
        DabblerNavigationStatus.morphToFeedbackDuration(reduceMotion: true),
        DabblerMotion.fast + DabblerMotion.actionAreaHold + DabblerMotion.base,
      );
      await tester.pumpAndSettle();
    });
  });

  group('direction and brightness', () {
    testWidgets('RTL: the circle sits over the action on the left', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _status(
          const DabblerNavigationStatusFeedback(_joined),
          direction: TextDirection.rtl,
        ),
      );
      await tester.pump();
      expect(_surface(tester).left, _barRect(tester).left);
      expect(_surface(tester).size, const Size(_s, _s));
      await tester.pump(DabblerMotion.actionAreaHold);
      await tester.pump(DabblerActionArea.expandDuration(reduceMotion: false));
      await tester.pump();
      expect(_surface(tester).width, _width);
      // Grows rightward from the left: the glyph leads on the right.
      expect(
        tester.getRect(find.byKey(DabblerActionArea.glyphKey)).right,
        greaterThan(tester.getRect(find.text('joined game')).right),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('the tone ink clears AA in light and dark', (
      WidgetTester tester,
    ) async {
      for (final Brightness b in Brightness.values) {
        await tester.pumpWidget(
          _hosted(
            const DabblerNavigationStatus(
              payload: DabblerNavigationStatusFeedback(
                DabblerNavigationFeedbackData(
                  tone: DabblerToastTone.error,
                  message: "couldn't join",
                ),
              ),
              phase: DabblerActionAreaPhase.expanded,
              bar: _bar,
              safeArea: false,
            ),
            brightness: b,
          ),
        );
        await tester.pumpAndSettle();
        final Color ink = tester
            .widget<Text>(find.text("couldn't join"))
            .style!
            .color!;
        final Color fill = _decoration(tester).color!;
        expect(fill, testColors(brightness: b).error.surface, reason: b.name);
        expect(_contrast(ink, fill), greaterThanOrEqualTo(4.5), reason: b.name);
      }
    });
  });

  group('semantics', () {
    testWidgets('an activity announces as a status', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_status(_joining));
      await tester.pump();
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
      expect(node.getSemanticsData().role, SemanticsRole.status);
      handle.dispose();
    });
  });
}
