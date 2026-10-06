import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../navigation/bottom_bar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
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
/// | collapsed | [DabblerColors.brandPrimary], transparent hairline — the action, working | [DabblerColors.onBrand] |
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
/// None: the phase follows [active] and [presentation] directly — compact
/// presentations collapsed, the rest expanded — and the application composes
/// the order of states (*"No lifecycle is implemented here"*). Pass [phase]
/// to pin a state.
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
  /// `phase`: pinned, else idle when inactive, collapsed for the compact
  /// presentations, expanded for the rest — exactly as the source derives it.
  DabblerActionAreaPhase get _phase {
    if (widget.phase != null) return widget.phase!;
    if (!widget.active) return DabblerActionAreaPhase.idle;
    return widget.presentation.compact
        ? DabblerActionAreaPhase.collapsed
        : DabblerActionAreaPhase.expanded;
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final DabblerNavigationActivityPresentation p = widget.presentation;
    final DabblerActionAreaPhase phase = _phase;
    final bool expanded = phase == DabblerActionAreaPhase.expanded;
    final bool ring = p == DabblerNavigationActivityPresentation.ring;
    final bool content =
        p == DabblerNavigationActivityPresentation.progressExpanded;

    return DabblerActionArea(
      bar: widget.bar,
      phase: phase,
      fit: content ? DabblerActionAreaFit.content : DabblerActionAreaFit.row,
      // Collapsed: the action, working. Expanded: the create menu's card.
      surface: expanded ? colors.surfaceCard : colors.brandPrimary,
      hairline: expanded
          ? colors.borderDefault
          // `hairline: transparent`.
          : colors.brandPrimary.withValues(alpha: 0),
      ink: expanded ? colors.textPrimary : colors.onBrand,
      safeArea: widget.safeArea,
      glyphSize: ring ? DabblerSizing.actionAreaRing : DabblerSizing.iconMd,
      glyphAtTop: content,
      role: DabblerActionAreaRole.status,
      glyph: _glyph(expanded: expanded),
      children: p.compact ? const <Widget>[] : _content(context, colors),
    );
  }

  /// The indicator: a [DabblerSpinner] (md) for `spinner` and `spinnerLabel`,
  /// a 32 [DabblerRing.progress] for `ring`, and **none** for the expanded
  /// progress presentations — the bar is the indicator there.
  Widget? _glyph({required bool expanded}) {
    final DabblerColors colors = DabblerColors.of(context);
    switch (widget.presentation) {
      case DabblerNavigationActivityPresentation.ring:
        return DabblerRing.progress(
          value: widget.value,
          diameter: DabblerSizing.actionAreaRing,
          tone: expanded ? DabblerRingTone.brand : DabblerRingTone.onBrand,
          semanticLabel: widget.label,
          child: widget.icon == null
              ? null
              : DabblerIcon(
                  widget.icon!,
                  weight: DabblerIconWeight.bold,
                  // `size 16` — half the 32 ring.
                  size: DabblerSizing.actionAreaRing / 2,
                  color: expanded ? colors.textPrimary : colors.onBrand,
                ),
        );
      case DabblerNavigationActivityPresentation.spinner:
      case DabblerNavigationActivityPresentation.spinnerLabel:
        return DabblerSpinner(
          tone: expanded ? widget.tone : DabblerSpinnerTone.onBrand,
          label: widget.label,
        );
      case DabblerNavigationActivityPresentation.indeterminate:
      case DabblerNavigationActivityPresentation.progress:
      case DabblerNavigationActivityPresentation.progressExpanded:
        return null;
    }
  }

  List<Widget> _content(BuildContext context, DabblerColors colors) {
    final TextDirection direction = Directionality.of(context);
    switch (widget.presentation) {
      case DabblerNavigationActivityPresentation.spinnerLabel:
        return <Widget>[
          Expanded(
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
        ];
      case DabblerNavigationActivityPresentation.indeterminate:
        return <Widget>[
          Expanded(
            child: DabblerProgressBar.indeterminate(
              size: DabblerProgressBarSize.sm,
              label: widget.label,
            ),
          ),
        ];
      case DabblerNavigationActivityPresentation.progress:
        return <Widget>[
          Expanded(
            child: widget.value == null
                ? DabblerProgressBar.indeterminate(
                    size: DabblerProgressBarSize.sm,
                    label: widget.label,
                  )
                : DabblerProgressBar(
                    value: widget.value!,
                    size: DabblerProgressBarSize.sm,
                    label: widget.label,
                    showValue: true,
                  ),
          ),
        ];
      case DabblerNavigationActivityPresentation.progressExpanded:
        return <Widget>[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: DabblerSpacing.space2,
              children: <Widget>[
                // The value is shown only when determinate.
                if (widget.value == null)
                  DabblerProgressBar.indeterminate(label: widget.label)
                else
                  DabblerProgressBar(
                    value: widget.value!,
                    label: widget.label,
                    showValue: true,
                  ),
                if (widget.status != null)
                  Text(
                    widget.status!,
                    style: DabblerType.caption1
                        .resolveForDirection(direction)
                        .copyWith(color: colors.textSecondary),
                  ),
              ],
            ),
          ),
        ];
      case DabblerNavigationActivityPresentation.spinner:
      case DabblerNavigationActivityPresentation.ring:
        return const <Widget>[];
    }
  }
}
