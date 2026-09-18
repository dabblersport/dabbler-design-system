/// Gallery entries for [DabblerMotion] — the motion token specimen (KAN-301,
/// `DECISIONS.md` D-034(b)).
///
/// ## Why this specimen animates rather than tabulating
///
/// `guidelines/measurements.html` documents motion as two table rows — a
/// duration column and an easing column — because a static HTML reference page
/// cannot do anything else. **That is the one place the design source is
/// weaker than what it specifies**, and the ticket says so: motion is the token
/// category prose alone cannot convey. 80ms and 200ms are two numbers on a
/// page and two visibly different movements on a screen, and only the second
/// tells a reviewer whether the scale is right.
///
/// So this file replicates the source's numbers exactly and then *runs* them:
/// the same travel, the same curve, three durations side by side, replayed on
/// a loop so the comparison is continuous rather than a thing you have to
/// catch.
///
/// ## What is compared against what
///
/// | design source | here |
/// |---|---|
/// | `measurements.html` §Layering & motion — `--motion-fast 80ms · press, tint change` | [DabblerMotion.fast] |
/// | same — `--motion-base 120ms · indicator slides, expand/collapse, toast enter` | [DabblerMotion.base] |
/// | same — `--motion-slow 200ms · sheet + dialog enter` | [DabblerMotion.slow] |
/// | same — `--ease-out: cubic-bezier(.2, 0, .2, 1)` | [DabblerMotion.easeOut] |
/// | `measurements.html` §Touch targets — `--press-scale .98` *"the system's only press transform"* | [DabblerMotion.pressScale] |
/// | `measurements.html` §Layering & motion — *"Under `prefers-reduced-motion: reduce` … no transforms, no slides, no spin"* | [DabblerMotion.reduceMotion] |
///
/// The one value the source page does **not** carry is `DabblerFab.pressedScale`
/// (0.96). It is drawn here as a **labelled deviation** rather than silently
/// alongside the 0.98, because that is what it is: `FAB.jsx` draws
/// `transform: scale(0.96)` while `measurements.html` calls .98 the system's
/// *only* press transform. Showing them as two equal steps would turn a
/// documented exception into a second token.
library;

import 'package:flutter/widgets.dart';

import '../controls/fab.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_page.dart';
import '../gallery/gallery_specimen.dart';
import 'dabbler_colors.dart';
import 'dabbler_geometry.dart';
import 'dabbler_motion.dart';
import 'dabbler_type.dart';

/// The motion token specimens.
const List<GalleryEntry> motionGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'motion/durations',
    page: 'foundations/motion',
    group: null,
    title: 'Motion — durations and the easing curve',
    description: 'The three durations running the same travel under the '
        'system\'s one curve, on a loop, so 80/120/200 can be compared '
        'rather than read.',
    builder: _durations,
  ),
  GalleryEntry(
    id: 'motion/press-scale',
    page: 'foundations/motion',
    group: null,
    title: 'Motion — press scale, and the FAB deviation',
    description: 'Press either target. 0.98 is the system\'s only press '
        'transform; the FAB\'s 0.96 is a documented exception, labelled as '
        'one.',
    builder: _press,
  ),
  GalleryEntry(
    id: 'motion/reduced',
    page: 'foundations/motion',
    group: null,
    title: 'Motion — reduced motion',
    description: 'What the platform is currently asking for, and the same '
        'travel with the reduced-motion rule applied.',
    builder: _reducedMotion,
  ),
];

/// `measurements.html`'s own wording for what each duration is for.
const List<(String, Duration, String)> _durationRoles =
    <(String, Duration, String)>[
  ('--motion-fast', DabblerMotion.fast, 'press, tint change'),
  (
    '--motion-base',
    DabblerMotion.base,
    'indicator slides, expand/collapse, toast enter',
  ),
  ('--motion-slow', DabblerMotion.slow, 'sheet + dialog enter'),
];

Widget _durations(BuildContext context) => GalleryStack(
      children: <Widget>[
        const GalleryUsage(
          '**Three durations, one curve.** `--ease-out` is '
          '`cubic-bezier(.2, 0, .2, 1)` and the system declares no other — '
          '*"transitions are short and ease-out, never bouncy"* '
          '(`measurements.html`). Each row below travels the same distance; '
          'only the duration differs.',
        ),
        for (final (String token, Duration duration, String role)
            in _durationRoles)
          GallerySpecimen(
            label: '$token · ${duration.inMilliseconds}ms · $role',
            child: _Runner(duration: duration),
          ),
        const GallerySpecimen(
          label: 'All three together, released on the same frame',
          child: _RunnerStack(),
        ),
        const GalleryUsage(
          'The curve itself: `DabblerMotion.easeOut` — `Cubic(0.2, 0, 0.2, 1)`, '
          'transcribed from `--ease-out`. It is the same curve on all three '
          'rows, so what separates them is duration alone.',
        ),
        const GallerySpecimen(
          label: 'easeOut — the curve, plotted',
          child: _CurvePlot(),
        ),
      ],
    );

Widget _press(BuildContext context) => GalleryStack(
      children: <Widget>[
        const GalleryUsage(
          '**`--press-scale: .98` is the system\'s only press transform** '
          '(`measurements.html`, §Touch targets & focus geometry). Every '
          'component reaches it through `DabblerMotion.pressScale`; the press '
          'runs at `--motion-fast`.',
        ),
        const GalleryWrap(
          children: <Widget>[
            GallerySpecimen(
              label: 'DabblerMotion.pressScale — 0.98 · the system value',
              child: _PressTarget(
                scale: DabblerMotion.pressScale,
                caption: '0.98',
              ),
            ),
            GallerySpecimen(
              label: 'DabblerFab.pressedScale — 0.96 · DEVIATION, not a token',
              child: _PressTarget(
                scale: DabblerFab.pressedScale,
                caption: '0.96',
                deviation: true,
              ),
            ),
          ],
        ),
        const GalleryUsage(
          '**The 0.96 is a deviation, and it is drawn as one.** `FAB.jsx` '
          'specifies `transform: scale(0.96)` while `measurements.html` calls '
          '`.98` the system\'s *only* press transform. `DabblerFab` owns that '
          'value itself (`DabblerFab.pressedScale`) and `DabblerMotion` does '
          'not carry it — a second constant in the token layer would make an '
          'exception look like a step of a scale. Nothing but the FAB may '
          'press to 0.96.',
        ),
      ],
    );

Widget _reducedMotion(BuildContext context) {
  final bool reduced = DabblerMotion.reduceMotion(context);
  return GalleryStack(
    children: <Widget>[
      GalleryUsage(
        '**The platform is currently asking for '
        '${reduced ? 'REDUCED motion' : 'normal motion'}.** '
        '`DabblerMotion.reduceMotion(context)` reads '
        '`MediaQuery.maybeDisableAnimationsOf`, defaulting to `false` when no '
        '`MediaQuery` is in scope. Flip the OS setting (macOS: Accessibility '
        '→ Display → Reduce motion) and this page answers differently.',
      ),
      GallerySpecimen(
        label: 'Honouring the platform — what this build is doing now',
        child: _Runner(duration: DabblerMotion.base, respectReduceMotion: true),
      ),
      const GallerySpecimen(
        label: 'Forced reduced — the degraded form, always',
        child: _Runner(duration: DabblerMotion.base, forceReduced: true),
      ),
      const GalleryUsage(
        '**The rule is a global law, not a per-component choice.** '
        '`measurements.html`: *"Under `prefers-reduced-motion: reduce` the '
        'global law applies: no transforms, no slides, no spin — components '
        'degrade to an opacity change or to no animation."* '
        '`DabblerPressScale` applies it by not scaling at all; '
        '`DabblerSkeleton`, `DabblerProgressBar` and `DabblerSpinner` apply it '
        'by holding their pulse at full opacity. The forced row above shows '
        'the travel collapsing to its end state with no transit.',
      ),
    ],
  );
}

/// The travel a duration row animates over, in logical pixels.
const double _trackLength = 240;

/// The moving mark's side.
const double _markSize = 26;

/// One duration, running the same travel on a loop.
///
/// Loops rather than waiting for a tap because the comparison this specimen
/// exists for is *between* rows, and a reviewer cannot press three targets on
/// the same frame.
///
/// **Driven by an [AnimationController], not by a delayed callback.** A
/// `Future.delayed` loop leaves a pending timer behind when the widget is
/// torn down, which `flutter_test` fails the enclosing test for — and every
/// entry in this gallery is pumped by `test/gallery_test.dart`. A ticker is
/// the mechanism the perpetual specimens already in the gallery (spinner,
/// skeleton, indeterminate progress bar) use, and it stops with the [State].
///
/// The leg is `dwell + duration`: the mark rests, then travels for exactly the
/// token's duration under [DabblerMotion.easeOut]. `repeat(reverse: true)`
/// mirrors that on the way back, so the return leg has the same timing.
class _Runner extends StatefulWidget {
  const _Runner({
    required this.duration,
    this.respectReduceMotion = false,
    this.forceReduced = false,
  });

  final Duration duration;

  /// Whether to apply [DabblerMotion.reduceMotion] from the platform.
  final bool respectReduceMotion;

  /// Whether to apply the reduced-motion degradation regardless of platform.
  final bool forceReduced;

  @override
  State<_Runner> createState() => _RunnerState();
}

class _RunnerState extends State<_Runner>
    with SingleTickerProviderStateMixin {
  /// The rest before each run, long enough that even `slow` reads as a
  /// separate event rather than a continuous shuttle.
  static const Duration _dwell = Duration(milliseconds: 700);

  late final Duration _leg = _dwell + widget.duration;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _leg,
  )..repeat(reverse: true);

  /// The fraction of the leg spent at rest, which is where the travel starts.
  late final double _start =
      _dwell.inMilliseconds / _leg.inMilliseconds;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool reduced = widget.forceReduced ||
        (widget.respectReduceMotion && DabblerMotion.reduceMotion(context));

    return SizedBox(
      width: _trackLength + _markSize,
      height: _markSize + DabblerSpacing.space2,
      child: Stack(
        children: <Widget>[
          // The track — a hairline the mark travels along, so the distance is
          // legible when the mark is at rest.
          PositionedDirectional(
            start: 0,
            end: 0,
            top: _markSize / 2,
            child: SizedBox(
              height: DabblerSizing.borderDefault,
              child: ColoredBox(color: colors.borderDefault),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              final double raw = _controller.value;
              // Reduced motion keeps the arrival and drops the transit: the
              // mark cuts to its end state at the moment travel would begin.
              final double progress = reduced
                  ? (raw >= _start ? 1 : 0)
                  : Interval(
                      _start,
                      1,
                      curve: DabblerMotion.easeOut,
                    ).transform(raw);
              return PositionedDirectional(
                start: _trackLength * progress,
                top: 0,
                child: child!,
              );
            },
            child: _Mark(colors: colors),
          ),
        ],
      ),
    );
  }
}

/// The three durations released on one frame, stacked, so the difference is a
/// gap between marks rather than a memory of the previous row.
class _RunnerStack extends StatelessWidget {
  const _RunnerStack();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final (String token, Duration duration, _) in _durationRoles)
            Padding(
              padding: const EdgeInsets.only(bottom: DabblerSpacing.space2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 96,
                    child: GalleryMono('$token  ${duration.inMilliseconds}ms'),
                  ),
                  _Runner(duration: duration),
                ],
              ),
            ),
        ],
      );
}

/// The travelling mark — `--radius-sm`, brand fill, the same square the
/// source's own icon-size row draws.
class _Mark extends StatelessWidget {
  const _Mark({required this.colors});

  final DabblerColors colors;

  @override
  Widget build(BuildContext context) => Container(
        width: _markSize,
        height: _markSize,
        decoration: BoxDecoration(
          color: colors.brandPrimary,
          borderRadius: DabblerRadius.smAll,
        ),
      );
}

/// A press target that scales to [scale] over [DabblerMotion.fast].
///
/// Deliberately not `DabblerPressScale`: that primitive has its own specimen
/// under Interaction, and this one has to be able to press to 0.96 as well, so
/// it drives [AnimatedScale] directly with the value under demonstration.
class _PressTarget extends StatefulWidget {
  const _PressTarget({
    required this.scale,
    required this.caption,
    this.deviation = false,
  });

  final double scale;
  final String caption;

  /// Whether to draw this target as the documented exception rather than the
  /// system value.
  final bool deviation;

  @override
  State<_PressTarget> createState() => _PressTargetState();
}

class _PressTargetState extends State<_PressTarget> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool reduced = DabblerMotion.reduceMotion(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          scale: _pressed && !reduced ? widget.scale : 1,
          duration: DabblerMotion.fast,
          curve: DabblerMotion.easeOut,
          child: Container(
            width: 132,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.deviation ? colors.surfaceSunken : colors.surfaceCard,
              border: Border.all(
                color: widget.deviation
                    ? colors.warning.strong
                    : colors.borderDefault,
              ),
              borderRadius: DabblerRadius.cardAll,
            ),
            child: Text(
              widget.caption,
              style: DabblerType.title3
                  .resolveForDirection(Directionality.of(context))
                  .copyWith(
                    color: widget.deviation
                        ? colors.warning.strong
                        : colors.textPrimary,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

/// [DabblerMotion.easeOut] plotted as progress against time.
///
/// The curve is the one thing on this page a still frame *can* carry, and the
/// design source never draws it — `measurements.html` prints the
/// `cubic-bezier` coefficients and stops. Plotting it shows what those
/// coefficients mean: almost all of the travel happens in the first third.
class _CurvePlot extends StatelessWidget {
  const _CurvePlot();

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return SizedBox(
      width: 200,
      height: 120,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          border: Border.all(color: colors.borderDefault),
          borderRadius: DabblerRadius.lgAll,
        ),
        child: CustomPaint(
          painter: _CurvePainter(
            line: colors.brandPrimary,
            grid: colors.bgTertiary,
          ),
        ),
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  const _CurvePainter({required this.line, required this.grid});

  final Color line;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    const double inset = DabblerSpacing.space4;
    final Rect plot = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );

    // The linear reference, so the curve's departure from it is visible.
    canvas.drawLine(
      plot.bottomLeft,
      plot.topRight,
      Paint()
        ..color = grid
        ..strokeWidth = DabblerSizing.borderDefault,
    );

    final Path path = Path()..moveTo(plot.left, plot.bottom);
    const int steps = 48;
    for (int i = 1; i <= steps; i++) {
      final double t = i / steps;
      final double v = DabblerMotion.easeOut.transform(t);
      path.lineTo(plot.left + plot.width * t, plot.bottom - plot.height * v);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_CurvePainter oldDelegate) =>
      oldDelegate.line != line || oldDelegate.grid != grid;
}
