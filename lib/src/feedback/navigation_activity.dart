import 'dart:async';

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../navigation/bottom_bar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';
import 'action_area.dart';
import 'progress_bar.dart';
import 'ring.dart';
import 'spinner.dart';

/// The six ways the Action Area reports activity, transcribed from
/// `NavigationActivity`'s `presentation` (`status-feedback.card.html` —
/// *Spinner*, *ProgressBar*, *Action Area · system states*).
enum DabblerNavigationActivityPresentation {
  /// Collapsed: the brand circle keeps its fill and the plus becomes an
  /// `onBrand` [DabblerSpinner] — *"the action button, working"*.
  spinner,

  /// Collapsed: the brand circle carries a [DabblerRing.progress] at
  /// [DabblerSizing.actionAreaRing] (32), optionally around an icon, so the
  /// Action Area reports progress **without** expanding.
  ring,

  /// Expanded row: a `--surface-card` row with a `brand` [DabblerSpinner] and
  /// a `.t-subheadline` label — the create menu's surface.
  spinnerLabel,

  /// Expanded row: an indeterminate [DabblerProgressBar] (`sm`), sweeping.
  indeterminate,

  /// Expanded row: a determinate [DabblerProgressBar] (`sm`) with its own
  /// label and value — no glyph beside it.
  progress,

  /// Expanded to content: a [DabblerProgressBar] (`md`) with label and value,
  /// and a `.t-caption-1` status line — for a longer operation.
  progressExpanded;

  /// Whether this presentation lives in the collapsed circle.
  bool get compact =>
      this == DabblerNavigationActivityPresentation.spinner ||
      this == DabblerNavigationActivityPresentation.ring;

  /// Whether the circle it grows from carries a ring (a value) rather than a
  /// spinner.
  bool get determinate =>
      this == DabblerNavigationActivityPresentation.ring ||
      this == DabblerNavigationActivityPresentation.progress ||
      this == DabblerNavigationActivityPresentation.progressExpanded;
}

/// NavigationActivity — loading and progress presented on the bottom
/// navigation's action footprint.
///
/// Transcribed from `components/feedback/NavigationActivity.jsx` as rendered
/// on `status-feedback.card.html`. Built on [DabblerActionArea], composing the
/// **same** [DabblerSpinner], [DabblerProgressBar] and [DabblerRing.progress]
/// the content column uses: *"nothing new is painted"*.
///
/// ## Colours
///
/// | phase | surface | ink |
/// |---|---|---|
/// | collapsed | [DabblerColors.brandPrimary] — the action, working | [DabblerColors.onBrand] |
/// | expanded | [DabblerColors.surfaceCard] + [DabblerColors.borderDefault] — the create-menu precedent | [DabblerColors.textPrimary] |
///
/// ## The indicator is never doubled
///
/// Once expanded, the progress rows show **no** glyph beside the bar — *"the
/// bar is the indicator; the ring or Spinner appears only in the collapsed
/// circle the row grows from"*. Only [DabblerNavigationActivityPresentation.spinnerLabel]
/// keeps its glyph, turning from `onBrand` to `brand` as it lands on the card.
///
/// ## Lifecycle
///
/// None beyond the order of states: the application composes them
/// (*"No lifecycle is implemented here"*). When an expanded presentation
/// follows idle, the circle shows for [DabblerMotion.actionAreaHold] before
/// it grows, so the row always reads as grown **from** the action. Pass
/// [phase] to pin a state.
///
/// ## Accessibility
///
/// The surface carries `role="status"`; the [DabblerSpinner],
/// [DabblerProgressBar] and [DabblerRing.progress] inside expose their own
/// name and value (`progressbar` when determinate).
class DabblerNavigationActivity extends StatefulWidget {
  /// Creates navigation-integrated activity over [bar].
  const DabblerNavigationActivity({
    super.key,
    this.active = true,
    this.presentation = DabblerNavigationActivityPresentation.spinner,
    this.label,
    this.value,
    this.status,
    this.icon,
    this.tone = DabblerSpinnerTone.brand,
    this.phase,
    this.bar = const DabblerNavigationBottomBar(),
    this.safeArea = true,
  });

  /// False is idle navigation: the bar alone.
  final bool active;

  /// Which presentation.
  final DabblerNavigationActivityPresentation presentation;

  /// The activity's name — the spinner's label, the bar's caption, the
  /// ring's accessible name. *"joining game"*, *"uploading"*.
  final String? label;

  /// Progress as a fraction 0–1. Null is indeterminate: the ring spins and
  /// the progress rows sweep.
  final double? value;

  /// The `.t-caption-1` status line of
  /// [DabblerNavigationActivityPresentation.progressExpanded] — *"3 of 8
  /// photos · about a minute left"*.
  final String? status;

  /// An Iconsax name drawn inside the ring.
  final String? icon;

  /// The expanded spinner's tone — `brand` by default, or `inherit`. The
  /// collapsed circle is always `onBrand`.
  final DabblerSpinnerTone tone;

  /// Pins a phase. Null derives it from [active] and [presentation].
  final DabblerActionAreaPhase? phase;

  /// The real bottom navigation, rendered verbatim beneath.
  final DabblerNavigationBottomBar bar;

  /// Passed to [DabblerActionArea.safeArea].
  final bool safeArea;

  @override
  State<DabblerNavigationActivity> createState() =>
      _DabblerNavigationActivityState();
}

class _DabblerNavigationActivityState extends State<DabblerNavigationActivity> {
  late DabblerActionAreaPhase _phase = _target(widget);
  Timer? _hold;

  static DabblerActionAreaPhase _target(DabblerNavigationActivity w) {
    if (w.phase != null) return w.phase!;
    if (!w.active) return DabblerActionAreaPhase.idle;
    return w.presentation.compact
        ? DabblerActionAreaPhase.collapsed
        : DabblerActionAreaPhase.expanded;
  }

  @override
  void didUpdateWidget(DabblerNavigationActivity oldWidget) {
    super.didUpdateWidget(oldWidget);
    final DabblerActionAreaPhase next = _target(widget);
    if (next == _phase && _hold == null) return;
    _hold?.cancel();
    _hold = null;
    if (widget.phase == null &&
        next == DabblerActionAreaPhase.expanded &&
        _phase == DabblerActionAreaPhase.idle) {
      // Grown FROM the action: show the circle first.
      _phase = DabblerActionAreaPhase.collapsed;
      _hold = Timer(DabblerMotion.actionAreaHold, () {
        if (!mounted) return;
        setState(() {
          _hold = null;
          _phase = _target(widget);
        });
      });
      return;
    }
    _phase = next;
  }

  @override
  void dispose() {
    _hold?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final DabblerNavigationActivityPresentation p = widget.presentation;
    final bool expanded = _phase == DabblerActionAreaPhase.expanded;

    return DabblerActionArea(
      bar: widget.bar,
      phase: _phase,
      fit: p == DabblerNavigationActivityPresentation.progressExpanded
          ? DabblerActionAreaFit.content
          : DabblerActionAreaFit.row,
      surface: expanded ? colors.surfaceCard : colors.brandPrimary,
      hairline: expanded ? colors.borderDefault : colors.brandPrimary,
      ink: expanded ? colors.textPrimary : colors.onBrand,
      safeArea: widget.safeArea,
      keepGlyph: p == DabblerNavigationActivityPresentation.spinnerLabel,
      glyph: AnimatedSwitcher(
        duration: DabblerMotion.base,
        switchInCurve: DabblerMotion.easeOut,
        switchOutCurve: DabblerMotion.easeOut,
        child: _glyph(onBrand: !expanded),
      ),
      child: p.compact ? null : _content(context, colors),
    );
  }

  /// The circle's indicator: a ring when there is (or will be) a value, a
  /// spinner otherwise. `onBrand` on the brand circle; the labelled spinner
  /// lands on the card in its own tone.
  Widget _glyph({required bool onBrand}) {
    final DabblerColors colors = DabblerColors.of(context);
    if (widget.presentation.determinate) {
      return DabblerRing.progress(
        key: const ValueKey<String>('ring'),
        value: widget.value,
        diameter: DabblerSizing.actionAreaRing,
        tone: DabblerProgressBarTone.onBrand,
        semanticLabel: widget.label,
        child: widget.icon == null
            ? null
            : DabblerIcon(
                widget.icon!,
                size: DabblerSizing.iconSm,
                color: colors.onBrand,
              ),
      );
    }
    return DabblerSpinner(
      key: ValueKey<bool>(onBrand),
      tone: onBrand ? DabblerSpinnerTone.onBrand : widget.tone,
      label: widget.label,
    );
  }

  Widget _content(BuildContext context, DabblerColors colors) {
    final TextDirection direction = Directionality.of(context);
    switch (widget.presentation) {
      case DabblerNavigationActivityPresentation.spinnerLabel:
        return Padding(
          padding: const EdgeInsetsDirectional.only(
            start: DabblerActionArea.glyphSlot,
            end: DabblerSpacing.space6,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            // The spinner already announces the label; this is its visible
            // twin.
            child: ExcludeSemantics(
              child: Text(
                widget.label ?? '',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: DabblerType.subheadline
                    .resolveForDirection(direction)
                    .copyWith(color: colors.textPrimary),
              ),
            ),
          ),
        );
      case DabblerNavigationActivityPresentation.indeterminate:
      case DabblerNavigationActivityPresentation.progress:
        final double? value =
            widget.presentation ==
                DabblerNavigationActivityPresentation.progress
            ? widget.value
            : null;
        return Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: DabblerSpacing.space8,
          ),
          child: Center(
            child: value == null
                ? DabblerProgressBar.indeterminate(
                    size: DabblerProgressBarSize.sm,
                    label: widget.label,
                  )
                : DabblerProgressBar(
                    value: value,
                    size: DabblerProgressBarSize.sm,
                    label: widget.label,
                    showValue: true,
                  ),
          ),
        );
      case DabblerNavigationActivityPresentation.progressExpanded:
        return Padding(
          padding: const EdgeInsets.all(DabblerSpacing.cardPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (widget.value == null)
                DabblerProgressBar.indeterminate(label: widget.label)
              else
                DabblerProgressBar(
                  value: widget.value!,
                  label: widget.label,
                  showValue: true,
                ),
              if (widget.status != null) ...<Widget>[
                const SizedBox(height: DabblerSpacing.space2),
                Text(
                  widget.status!,
                  style: DabblerType.caption1
                      .resolveForDirection(direction)
                      .copyWith(color: colors.textSecondary),
                ),
              ],
            ],
          ),
        );
      case DabblerNavigationActivityPresentation.spinner:
      case DabblerNavigationActivityPresentation.ring:
        return const SizedBox.shrink();
    }
  }
}
