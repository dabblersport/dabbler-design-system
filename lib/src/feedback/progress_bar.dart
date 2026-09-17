import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';

/// The two track heights [DabblerProgressBar] can take, transcribed from
/// `components/feedback/ProgressBar.jsx` (`const SIZES = { sm: 3, md: 6 }`).
enum DabblerProgressBarSize {
  /// 3px. `ProgressBar.prompt.md`: *"for inline use inside a card or row"*.
  sm,

  /// 6px, the default. *"for a section or screen-level bar"*.
  md,
}

/// The fill tone of a [DabblerProgressBar] — `tone` in `ProgressBar.d.ts`.
///
/// [brand] takes `--color-brand-primary`; the four status tones take that
/// status's **`base`** role, which is what the source reads off its
/// `statusTones` map. `base` is the bare indicator, and this is exactly the
/// use [DabblerStatusColor.base] is documented for: a bar carries no text, so
/// the 2.1–3.8:1 white-on-base problem that forces [DabblerStatusColor.solid]
/// elsewhere does not arise here.
enum DabblerProgressBarTone {
  /// `--color-brand-primary`. The default, and re-tints per section theme.
  brand,

  /// [DabblerStatusColor.base] of `success`.
  success,

  /// [DabblerStatusColor.base] of `warning`.
  warning,

  /// [DabblerStatusColor.base] of `error`.
  error,

  /// [DabblerStatusColor.base] of `info`.
  info,
}

/// ProgressBar — progress with a known end, or a busy bar when the end is not
/// known.
///
/// Transcribed from `components/feedback/ProgressBar.jsx`, `ProgressBar.d.ts`
/// and `ProgressBar.prompt.md`. A flat track of [DabblerColors.bgTertiary]
/// carries a flat fill at pill radius: no gradient, no shadow, no glass.
///
/// ```dart
/// const DabblerProgressBar(value: 0.6, label: 'profile', showValue: true);
/// const DabblerProgressBar.indeterminate(label: 'uploading');
/// ```
///
/// ## The value is a fraction, not a percentage
///
/// [value] is `0–1`, clamped, exactly as the source's
/// `Math.min(1, Math.max(0, value))`. Only [showValue] turns it into a rounded
/// percentage for display, and only the semantics layer reports it as 0–100.
/// Handing this widget `60` for "60%" therefore renders a full bar rather than
/// throwing, which is what the source does too.
///
/// ## RTL
///
/// The fill is anchored with [AlignmentDirectional.centerStart] — the Flutter
/// equivalent of the source's `inset-inline-start` — so a determinate bar grows
/// from the **start** edge: leftwards from the right under
/// [TextDirection.rtl], with no direction prop. The indeterminate sweep travels
/// start → end for the same reason, and its physical sign is flipped for RTL
/// because [FractionalTranslation] is a physical transform where CSS
/// `inset-inline-start` is not.
///
/// ## Reduced motion
///
/// Under [MediaQueryData.disableAnimations] the determinate fill snaps instead
/// of animating, and the indeterminate sweep becomes an opacity pulse — the
/// source's own reduced-motion rule, `.dbl-indeterminate{animation:dbl-pulse
/// 1.2s ease-in-out infinite;transform:none}`. This mirrors
/// `lib/src/feedback/skeleton.dart`, which resolves the same pulse.
///
/// ## Accessibility
///
/// A determinate bar carries [SemanticsRole.progressBar] with `minValue` `0`,
/// `maxValue` `100` and the rounded percentage as its value. An indeterminate
/// bar carries [SemanticsRole.loadingSpinner] and **no** value, which is how
/// assistive technology announces "busy" rather than a number — the source
/// makes the same distinction by omitting `aria-valuenow`. Pass [label] so the
/// bar has a name; a bar with neither a label nor a nearby heading is
/// decoration. The visible label row is wrapped in [ExcludeSemantics] so the
/// caption and the percentage are announced once, by the bar, rather than
/// three times.
class DabblerProgressBar extends StatefulWidget {
  /// A determinate bar filled to [value], a fraction from 0 to 1.
  const DabblerProgressBar({
    super.key,
    required double this.value,
    this.tone = DabblerProgressBarTone.brand,
    this.size = DabblerProgressBarSize.md,
    this.label,
    this.showValue = false,
  });

  /// A bar for work whose total is not known.
  ///
  /// [showValue] is not offered: the source renders the percentage only when
  /// `!indeterminate`, because there is no number to render.
  const DabblerProgressBar.indeterminate({
    super.key,
    this.tone = DabblerProgressBarTone.brand,
    this.size = DabblerProgressBarSize.md,
    this.label,
  })  : value = null,
        showValue = false;

  /// Progress as a fraction from 0 to 1, clamped. Null means indeterminate.
  final double? value;

  /// The fill tone. Defaults to [DabblerProgressBarTone.brand].
  final DabblerProgressBarTone tone;

  /// The track height. Defaults to [DabblerProgressBarSize.md].
  final DabblerProgressBarSize size;

  /// The caption above the bar, and the bar's accessible name.
  final String? label;

  /// Whether to show the rounded percentage at the inline end of the label row.
  /// Ignored when the bar is indeterminate.
  final bool showValue;

  /// `SIZES.sm` — 3px. Equal to [DabblerSpacing.space1], so the track height
  /// stays on the base-3 grid rather than being a loose number.
  static const double trackHeightSm = DabblerSpacing.space1;

  /// `SIZES.md` — 6px, i.e. [DabblerSpacing.space2].
  static const double trackHeightMd = DabblerSpacing.space2;

  /// The width of the sweeping bar on an indeterminate track — `width: '33%'`.
  static const double indeterminateWidthFactor = 0.33;

  /// `.dbl-indeterminate{animation:dbl-indeterminate 1.4s …}` in
  /// `components/foundations/overlay.jsx:33`.
  static const Duration sweepPeriod = Duration(milliseconds: 1400);

  /// `@keyframes dbl-indeterminate{0%{transform:translateX(-100%)}}`, in
  /// multiples of the sweeping bar's own width, as a CSS translate percentage
  /// is.
  static const double sweepStart = -1;

  /// `100%{transform:translateX(300%)}`.
  static const double sweepEnd = 3;

  /// `--motion-base` — 120ms. The determinate fill's `transition: width`.
  static const Duration valueTransition = Duration(milliseconds: 120);

  /// `--ease-out: cubic-bezier(.2, 0, .2, 1)` from `tokens/spacing.css:61`.
  static const Cubic easeOut = Cubic(0.2, 0, 0.2, 1);

  /// The reduced-motion substitute's period — `dbl-pulse 1.2s`. Identical to
  /// `DabblerSkeleton.pulsePeriod`; both resolve the same source keyframe.
  static const Duration pulsePeriod = Duration(milliseconds: 1200);

  /// `50%{opacity:.55}` of `dbl-pulse`.
  static const double pulseMinOpacity = 0.55;

  /// The track height for [size].
  static double trackHeightFor(DabblerProgressBarSize size) => switch (size) {
        DabblerProgressBarSize.sm => trackHeightSm,
        DabblerProgressBarSize.md => trackHeightMd,
      };

  /// The clamped [value] as a rounded percentage, 0–100. Null when
  /// indeterminate.
  static int? percentOf(double? value) =>
      value == null ? null : (value.clamp(0.0, 1.0) * 100).round();

  /// The fill colour for [tone], resolved off [colors].
  static Color fillFor(DabblerProgressBarTone tone, DabblerColors colors) =>
      switch (tone) {
        DabblerProgressBarTone.brand => colors.brandPrimary,
        DabblerProgressBarTone.success => colors.success.base,
        DabblerProgressBarTone.warning => colors.warning.base,
        DabblerProgressBarTone.error => colors.error.base,
        DabblerProgressBarTone.info => colors.info.base,
      };

  @override
  State<DabblerProgressBar> createState() => _DabblerProgressBarState();
}

class _DabblerProgressBarState extends State<DabblerProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Runs the sweep, the pulse, or nothing. Called from [build], because
  /// reduced motion arrives through the [MediaQuery] and the widget can be
  /// rebuilt from determinate to indeterminate and back.
  void _syncController({required bool indeterminate, required bool reduceMotion}) {
    if (!indeterminate) {
      if (_controller.isAnimating) _controller.stop();
      return;
    }
    final Duration period = reduceMotion
        ? DabblerProgressBar.pulsePeriod
        : DabblerProgressBar.sweepPeriod;
    if (_controller.duration != period) {
      _controller.duration = period;
      if (_controller.isAnimating) _controller.repeat();
    }
    if (!_controller.isAnimating) _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final bool indeterminate = widget.value == null;
    _syncController(indeterminate: indeterminate, reduceMotion: reduceMotion);

    final int? percent = DabblerProgressBar.percentOf(widget.value);
    final Color fill = DabblerProgressBar.fillFor(widget.tone, colors);

    final Widget track = SizedBox(
      height: DabblerProgressBar.trackHeightFor(widget.size),
      width: double.infinity,
      child: ClipRRect(
        // `overflow: hidden` — the sweep is clipped by the track, not by its
        // own bounds.
        borderRadius: DabblerRadius.pillAll,
        child: ColoredBox(
          color: colors.bgTertiary,
          child: indeterminate
              ? _sweep(fill: fill, direction: direction, reduceMotion: reduceMotion)
              : _fill(fill: fill, percent: percent!, reduceMotion: reduceMotion),
        ),
      ),
    );

    final Widget? header = _header(colors, direction, percent);

    return Semantics(
      label: widget.label,
      role: indeterminate
          ? SemanticsRole.loadingSpinner
          : SemanticsRole.progressBar,
      minValue: indeterminate ? null : '0',
      maxValue: indeterminate ? null : '100',
      value: indeterminate ? null : '$percent%',
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (header != null) ...<Widget>[
            // `gap: var(--space-2)` on the outer column. The row is excluded
            // from semantics because the enclosing node already carries both
            // pieces of it — the caption as the bar's name and the percentage
            // as its value. Without this, a screen reader reads the name, the
            // number and then the bar again.
            ExcludeSemantics(child: header),
            const SizedBox(height: DabblerSpacing.space2),
          ],
          track,
        ],
      ),
    );
  }

  /// The label row: caption on the start edge, percentage on the end edge.
  ///
  /// Returns null when there is nothing to put in it — the source renders the
  /// row only for `(label || showValue)`.
  Widget? _header(DabblerColors colors, TextDirection direction, int? percent) {
    final bool showsValue = widget.showValue && percent != null;
    if (widget.label == null && !showsValue) return null;

    // Both are `.t-caption-1`. The percentage takes the same script resolution
    // as the label: DabblerType.numeralFeatures disables `anum`, so the digits
    // stay Western Arabic with lining figures under the Arabic face too, which
    // is what `ProgressBar.prompt.md` asks for.
    final TextStyle caption =
        DabblerType.caption1.resolveForDirection(direction);

    return Row(
      children: <Widget>[
        Expanded(
          child: widget.label == null
              ? const SizedBox.shrink()
              : Text(
                  widget.label!,
                  style: caption.copyWith(color: colors.textSecondary),
                ),
        ),
        if (showsValue) ...<Widget>[
          // `gap: var(--space-3)` between the caption and the value.
          const SizedBox(width: DabblerSpacing.space3),
          Text(
            '$percent%',
            style: caption.copyWith(color: colors.textPrimary),
          ),
        ],
      ],
    );
  }

  /// The determinate fill: `width: pct%`, anchored to the inline start.
  Widget _fill({
    required Color fill,
    required int percent,
    required bool reduceMotion,
  }) {
    final Widget bar = ColoredBox(color: fill);
    if (reduceMotion) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: percent / 100,
          heightFactor: 1,
          child: bar,
        ),
      );
    }
    return AnimatedFractionallySizedBox(
      duration: DabblerProgressBar.valueTransition,
      curve: DabblerProgressBar.easeOut,
      alignment: AlignmentDirectional.centerStart,
      widthFactor: percent / 100,
      heightFactor: 1,
      child: bar,
    );
  }

  /// The indeterminate treatment: a 33%-wide bar sweeping start → end, or,
  /// under reduced motion, that same bar pulsing in place.
  Widget _sweep({
    required Color fill,
    required TextDirection direction,
    required bool reduceMotion,
  }) {
    final Widget bar = Align(
      alignment: AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: DabblerProgressBar.indeterminateWidthFactor,
        heightFactor: 1,
        child: ColoredBox(color: fill),
      ),
    );

    if (reduceMotion) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) => Opacity(
          opacity: DabblerMotion.pulseOpacityAt(
            _controller.value,
            minOpacity: DabblerProgressBar.pulseMinOpacity,
          ),
          child: child,
        ),
        child: bar,
      );
    }

    // CSS translateX percentages are relative to the translated element's own
    // width, which is what FractionalTranslation measures in too. The sign is
    // flipped under RTL because the transform is physical while the anchor is
    // directional — without this the sweep would start off-screen at the end
    // edge and travel the wrong way.
    final double sign = direction == TextDirection.rtl ? -1 : 1;
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) => FractionalTranslation(
        translation: Offset(sign * progressSweepOffsetAt(_controller.value), 0),
        child: child,
      ),
      child: bar,
    );
  }
}

/// `@keyframes dbl-indeterminate` — `translateX(-100%)` to `translateX(300%)`,
/// `ease-in-out`, sampled at [t] cycles.
///
/// Exposed for the test, which checks the endpoints rather than pumping frames.
double progressSweepOffsetAt(double t) {
  final double eased = Curves.easeInOut.transform(t.clamp(0.0, 1.0));
  return DabblerProgressBar.sweepStart +
      (DabblerProgressBar.sweepEnd - DabblerProgressBar.sweepStart) * eased;
}

