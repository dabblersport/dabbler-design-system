import 'package:flutter/widgets.dart';

import '../navigation/bottom_bar.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import 'action_area.dart';
import 'navigation_status.dart';
import 'status_tones.dart';
import 'toast.dart';

/// Which reference component the navigation-integrated feedback presents.
enum DabblerNavigationFeedbackPresentation {
  /// The Toast, as a [DabblerSizing.actionAreaSize] row along the bar.
  toast,

  /// The Banner, grown up and along from the action footprint.
  banner,
}

/// The shared feedback payload — the source's `{ tone, title, message, icon,
/// action, dismissible, duration }`, which Toast and Banner also read
/// (`status-feedback.card.html` — *Navigation interaction preview*, API).
///
/// **Tone is [DabblerToastTone].** Toast and Banner each carry their own tone
/// enum with identical members (`banner.dart` documents why); this payload is
/// shared by both presentations, so it reuses the existing Toast tone rather
/// than adding a third copy of the same five values. Null takes the
/// presentation's default, as `NavigationFeedback.jsx` does: `neutral` for a
/// toast, `info` for a banner.
@immutable
class DabblerNavigationFeedbackData {
  /// Describes one message.
  const DabblerNavigationFeedbackData({
    this.tone,
    this.title,
    this.message,
    this.icon,
    this.action,
    this.dismissible = false,
    this.duration,
  });

  /// The status tone; colours come from [DabblerStatusToneColors]. Null is
  /// the presentation's default — see [toneFor].
  final DabblerToastTone? tone;

  /// The tone this payload resolves to under [presentation].
  DabblerToastTone toneFor(
    DabblerNavigationFeedbackPresentation presentation,
  ) =>
      tone ??
      (presentation == DabblerNavigationFeedbackPresentation.banner
          ? DabblerToastTone.info
          : DabblerToastTone.neutral);

  /// The banner's `.t-headline` line. A toast shows [message] only.
  final String? title;

  /// The `.t-subheadline` line.
  final String? message;

  /// An Iconsax name overriding the tone's glyph ([DabblerToastTone.glyph]).
  final String? icon;

  /// The action: a text button on a toast, an outlined button on a banner.
  /// Pressing it runs [DabblerToastAction.onPressed] and then dismisses.
  final DabblerToastAction? action;

  /// Whether a banner draws its 45×45 dismiss button. Ignored by a toast.
  final bool dismissible;

  /// Time held expanded before it contracts by itself. Null takes the
  /// presentation's default — [DabblerToastSpec.defaultDuration] (4000ms)
  /// for a toast, sticky for a banner. [Duration.zero] is sticky.
  final Duration? duration;

  /// `role="alert"` for error and warning banners — interrupting is correct
  /// there — and `role="status"` otherwise (the Banner's own rule).
  bool get interrupts =>
      tone == DabblerToastTone.error || tone == DabblerToastTone.warning;
}

/// NavigationFeedback — Toast and Banner presented **from** the bottom
/// navigation: the bar's action footprint becomes the tone glyph, then grows
/// along the row into the message.
///
/// Transcribed from `components/feedback/NavigationFeedback.jsx` as rendered
/// on `status-feedback.card.html` (*Toast*, *Banner*, *Navigation interaction
/// preview*). Built on [DabblerActionArea]; the colours are exactly the
/// [DabblerToast] / [DabblerBanner] ones, through the shared
/// [DabblerStatusToneColors] — no colours, radii or type of its own.
///
/// ## Presentations
///
/// * [DabblerNavigationFeedbackPresentation.toast] — a
///   [DabblerSizing.actionAreaSize]-tall pill row: tone glyph, a one-line
///   `.t-subheadline` message, an optional action. *"Anything longer is a
///   banner."*
/// * [DabblerNavigationFeedbackPresentation.banner] — grown to content and
///   bottom-anchored on the bar's baseline: glyph at the top-leading corner,
///   `.t-headline` title and `.t-subheadline` message in the tone's strong
///   ink, the outlined action, and the 45×45 dismiss at the top-trailing
///   corner when [DabblerNavigationFeedbackData.dismissible].
///
/// ## Lifecycle
///
/// With [phase] null the widget runs the card's *Sequence* itself whenever
/// [feedback] arrives:
///
/// | step | what happens | timing |
/// |---|---|---|
/// | collapsed | the tone circle over the action | [DabblerMotion.actionAreaHold] |
/// | expanded | the surface grows, then the content fades in; the dismissal timer starts | toast 4000ms · banner sticky |
/// | hold | readable; hover and focus on the surface pause the timer | — |
/// | close | collapsed, then idle after [DabblerMotion.slow] (0 under reduced motion) + the hold | — |
/// | idle | [onDone] | — |
///
/// The action and the dismiss button start the contraction at once. Pass
/// [phase] to pin a state for a specimen; nothing then runs on a timer.
///
/// A thin wrapper over [DabblerNavigationStatus] with a message payload. To
/// morph an activity into its result on one surface, place
/// [DabblerNavigationStatus] itself: swapping this widget for a
/// [DabblerNavigationActivity] replaces the surface.
///
/// ## When to use it
///
/// When the message is a direct consequence of the user's action on this
/// screen and the screen has the bottom bar. Never while the create menu is
/// open, over a Dialog or Sheet, or on a screen without the bar; standard
/// Toast and Banner stay the default. The widget cannot see the create menu:
/// the host holds the message back (or uses
/// [DabblerNavigationStatus.suspended]) while it is open.
class DabblerNavigationFeedback extends StatefulWidget {
  /// Creates navigation-integrated feedback over [bar].
  const DabblerNavigationFeedback({
    super.key,
    this.presentation = DabblerNavigationFeedbackPresentation.toast,
    this.feedback,
    this.phase,
    this.onDone,
    this.onEnded,
    this.bar = const DabblerNavigationBottomBar(),
    this.safeArea = true,
    this.dismissSemanticLabel = defaultDismissSemanticLabel,
  });

  /// Toast or banner.
  final DabblerNavigationFeedbackPresentation presentation;

  /// The message. Null is idle: the bar alone.
  final DabblerNavigationFeedbackData? feedback;

  /// Pins a phase for a specimen. Null runs the lifecycle.
  final DabblerActionAreaPhase? phase;

  /// Called when the sequence has returned to idle — by time, by the action
  /// or by the dismiss button. The caller normally clears [feedback] here.
  final VoidCallback? onDone;

  /// Why the message ended — timeout, dismissed, action, or replaced by a new
  /// [feedback] before it ended — reported the moment it ends, while the
  /// close still plays. See [DabblerNavigationStatus.onDone]; [onDone] keeps
  /// its meaning (the sequence is back at idle).
  final ValueChanged<DabblerNavigationStatusEndReason>? onEnded;

  /// The real bottom navigation, rendered verbatim beneath.
  final DabblerNavigationBottomBar bar;

  /// Passed to [DabblerActionArea.safeArea].
  final bool safeArea;

  /// The dismiss button's accessible name — the source's
  /// `aria-label="Dismiss"`. The package ships no localised strings.
  final String dismissSemanticLabel;

  /// The source's literal `aria-label` value.
  static const String defaultDismissSemanticLabel = 'Dismiss';

  /// Identifies the action button's touch target.
  static const Key actionTargetKey = Key('DabblerNavigationFeedback.action');

  /// Identifies the dismiss button's touch target.
  static const Key dismissTargetKey = Key('DabblerNavigationFeedback.dismiss');

  /// The dismiss target's offset from the content box's top:
  /// `paddingBlock 15` + `marginBlock calc(--space-5 * -1 + --space-1)` =
  /// [DabblerSpacing.space1] (3).
  static const double dismissTop =
      DabblerSpacing.space5 - DabblerSpacing.space5 + DabblerSpacing.space1;

  /// The dismiss target's offset from the content box's inline end:
  /// `paddingInlineEnd 15` + `marginInlineEnd calc(--space-3 * -1)` = 6.
  static const double dismissEnd =
      DabblerSpacing.space5 - DabblerSpacing.space3;

  /// The row space the dismiss takes with its negative inline-end margin.
  static const double dismissReserve =
      DabblerSizing.touchTargetMin - DabblerSpacing.space3;

  @override
  State<DabblerNavigationFeedback> createState() =>
      _DabblerNavigationFeedbackState();
}

class _DabblerNavigationFeedbackState extends State<DabblerNavigationFeedback> {
  @override
  Widget build(BuildContext context) => DabblerNavigationStatus(
    payload: widget.feedback == null
        ? null
        : DabblerNavigationStatusFeedback(
            widget.feedback!,
            presentation: widget.presentation,
          ),
    phase: widget.phase,
    bar: widget.bar,
    safeArea: widget.safeArea,
    dismissSemanticLabel: widget.dismissSemanticLabel,
    onDone: widget.onEnded,
    onClosed: widget.onDone,
  );
}
