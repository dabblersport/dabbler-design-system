import 'package:flutter/widgets.dart';

import '../navigation/bottom_bar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'action_area.dart';
import 'navigation_feedback.dart';
import 'navigation_status.dart';
import 'progress_bar.dart';
import 'ring.dart';
import 'spinner.dart';
import 'toast.dart';

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
/// A thin wrapper over [DabblerNavigationStatus] with an activity payload.
/// To resolve an activity into its result on the **same** surface, place
/// [DabblerNavigationStatus] itself and hand it the result: swapping this
/// widget for a [DabblerNavigationFeedback] replaces the surface and its
/// growth.
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
    this.action,
    this.onEnded,
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

  /// An optional action on the expanded rows — *Cancel* — with the toast
  /// action's treatment, after the row's content. Ignored by the compact
  /// presentations. Pressing it runs [DabblerToastAction.onPressed], contracts
  /// the surface back to the bar and reports
  /// [DabblerNavigationStatusEndReason.action] through [onEnded].
  final DabblerToastAction? action;

  /// The activity ended by its [action]. An activity has no other end: the
  /// application replaces it.
  final ValueChanged<DabblerNavigationStatusEndReason>? onEnded;

  /// The real bottom navigation, rendered verbatim beneath.
  final DabblerNavigationBottomBar bar;

  /// Passed to [DabblerActionArea.safeArea].
  final bool safeArea;

  @override
  State<DabblerNavigationActivity> createState() =>
      _DabblerNavigationActivityState();
}

class _DabblerNavigationActivityState extends State<DabblerNavigationActivity> {
  @override
  Widget build(BuildContext context) => DabblerNavigationStatus(
    payload: DabblerNavigationStatusActivity(
      presentation: widget.presentation,
      label: widget.label,
      value: widget.value,
      status: widget.status,
      icon: widget.icon,
      spinnerTone: widget.tone,
      action: widget.action,
    ),
    // Inactive is idle navigation; the payload is kept, as it always was.
    suspended: !widget.active,
    phase: widget.phase,
    bar: widget.bar,
    safeArea: widget.safeArea,
    onDone: widget.onEnded,
  );
}
