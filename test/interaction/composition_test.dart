import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/interaction/press_scale.dart';
import 'package:dabbler_design_system/src/interaction/scrim.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'interaction_host.dart';

/// AC4's stub control: a focusable, pressable thing that opens an overlay,
/// composing all three primitives.
///
/// It is deliberately **not** a real control and deliberately dull to read —
/// its whole job is to be the proof that the three primitives compose. Note
/// what is *not* in it: no ring geometry, no ring colour, no focus-visible
/// rule, no scale value, no press duration, no curve, no scrim colour, no
/// scrim opacity and no fade. Every one of those lives in exactly one place,
/// and a control that wants them writes what is below. If any of that logic
/// had to be restated here, AC4 would not be met.
class _StubControl extends StatefulWidget {
  const _StubControl({this.enabled = true});

  final bool enabled;

  @override
  State<_StubControl> createState() => _StubControlState();
}

class _StubControlState extends State<_StubControl> {
  bool _pressed = false;
  bool _overlayOpen = false;

  @override
  Widget build(BuildContext context) {
    final Widget control = DabblerFocusRing(
      enabled: widget.enabled,
      borderRadius: DabblerRadius.mdAll,
      child: DabblerPressScale(
        pressed: _pressed,
        enabled: widget.enabled,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: () => setState(() {
            _pressed = false;
            _overlayOpen = true;
          }),
          child: Container(
            key: const Key('surface'),
            width: DabblerSizing.touchTargetMin * 2,
            height: DabblerSizing.touchTargetMin,
            decoration: BoxDecoration(
              color: DabblerColors.of(context).surfaceCard,
              borderRadius: DabblerRadius.mdAll,
              border: Border.all(color: DabblerColors.of(context).borderDefault),
            ),
          ),
        ),
      ),
    );

    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        children: <Widget>[
          Align(child: control),
          Positioned.fill(
            child: DabblerScrim(
              visible: _overlayOpen,
              dismissLabel: 'Close',
              onDismiss: () => setState(() => _overlayOpen = false),
            ),
          ),
        ],
      ),
    );
  }
}

bool _ringPainted(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .any((CustomPaint p) => p.foregroundPainter != null);

double _scale(WidgetTester tester) => tester
    .widget<Transform>(
      find.ancestor(
        of: find.byKey(const Key('surface')),
        matching: find.byType(Transform),
      ).first,
    )
    .transform
    .storage[0];

double _scrimOpacity(WidgetTester tester) =>
    tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity.value;

void main() {
  testWidgets('the stub composes all three primitives at once',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(const _StubControl()));

    expect(find.byType(DabblerFocusRing), findsOneWidget);
    expect(find.byType(DabblerPressScale), findsOneWidget);
    expect(find.byType(DabblerScrim), findsOneWidget);
  });

  testWidgets('focus, press and overlay work independently and together',
      (WidgetTester tester) async {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() => FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.automatic);

    await tester.pumpWidget(host(const _StubControl()));
    expect(_ringPainted(tester), isFalse);
    expect(_scale(tester), 1);
    await tester.pumpAndSettle();
    expect(_scrimOpacity(tester), 0);

    // Keyboard focus: the ring alone.
    final Element ringElement = tester.element(find.byType(DabblerFocusRing));
    Focus.of(tester.element(find.byKey(const Key('surface')))).requestFocus();
    // Two frames: FocusManager applies a focus change at the end of the frame
    // it was requested in, so the dependent repaint lands on the next.
    await tester.pumpAndSettle();
    expect(ringElement.mounted, isTrue);
    expect(_ringPainted(tester), isTrue);
    expect(_scale(tester), 1, reason: 'focus is not press');

    // Press while focused: both at once, neither cancelling the other.
    final TestGesture gesture = await tester
        .startGesture(tester.getCenter(find.byKey(const Key('surface'))));
    await tester.pumpAndSettle();
    expect(_ringPainted(tester), isTrue);
    expect(_scale(tester), closeTo(DabblerMotion.pressScale, 0.0001));

    // Release: press ends, focus stays, the overlay opens.
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_scale(tester), 1);
    expect(_ringPainted(tester), isTrue);
    expect(_scrimOpacity(tester), 1);

    // Dismiss the overlay through the scrim.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(_scrimOpacity(tester), 0);
  });

  testWidgets('disabling the stub silences the ring and the press together',
      (WidgetTester tester) async {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() => FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.automatic);

    await tester.pumpWidget(host(const _StubControl(enabled: false)));
    final TestGesture gesture = await tester
        .startGesture(tester.getCenter(find.byKey(const Key('surface'))));
    await tester.pumpAndSettle();
    expect(_ringPainted(tester), isFalse);
    expect(_scale(tester), 1);
    await gesture.up();
  });

  testWidgets('reduced motion reaches every primitive through one MediaQuery',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      host(const _StubControl(), disableAnimations: true),
    );
    await tester.tap(find.byKey(const Key('surface')));
    await tester.pump();
    // No settle: with animations disabled both the press release and the scrim
    // are already at their end state on the very next frame.
    expect(_scale(tester), 1);
    expect(_scrimOpacity(tester), 1);
  });
}
