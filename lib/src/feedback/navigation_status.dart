import 'dart:async';

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../navigation/bottom_bar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';
import 'action_area.dart';
import 'navigation_activity.dart';
import 'navigation_feedback.dart';
import 'progress_bar.dart';
import 'ring.dart';
import 'spinner.dart';
import 'status_tones.dart';
import 'toast.dart';

/// Why a payload handed to [DabblerNavigationStatus] ended — the argument of
/// [DabblerNavigationStatus.onDone].
enum DabblerNavigationStatusEndReason {
  /// A message's duration ran out while it was expanded and not paused.
  timeout,

  /// The banner's dismiss button was pressed.
  dismissed,

  /// The payload's [DabblerToastAction] was pressed — a message's action
  /// (*Retry*, *Undo*) or an activity's (*Cancel*). Its
  /// [DabblerToastAction.onPressed] has already run.
  action,

  /// A message that had not ended was superseded by a different non-null
  /// payload.
  replaced,
}

/// What [DabblerNavigationStatus] presents: an activity (loading, progress)
/// or a message (a toast or a banner). Null, at the widget, is idle.
///
/// Sealed, so a host maps its own state onto exactly one of the two with an
/// exhaustive `switch`.
@immutable
sealed class DabblerNavigationStatusPayload {
  const DabblerNavigationStatusPayload();
}

/// Loading or progress on the action footprint — the payload form of
/// [DabblerNavigationActivity]'s props.
///
/// An activity has no lifecycle of its own: the host replaces it (with a
/// newer value, a result, or null). Successive activities are the **same**
/// operation updating in place — a new [value], a new [label], a different
/// [presentation] — and morph without restarting anything. Value equality.
final class DabblerNavigationStatusActivity
    extends DabblerNavigationStatusPayload {
  /// Describes one activity.
  const DabblerNavigationStatusActivity({
    this.presentation = DabblerNavigationActivityPresentation.spinner,
    this.label,
    this.value,
    this.status,
    this.icon,
    this.spinnerTone = DabblerSpinnerTone.brand,
    this.action,
  });

  /// Which of the six presentations — see
  /// [DabblerNavigationActivityPresentation].
  final DabblerNavigationActivityPresentation presentation;

  /// The activity's name — the spinner's label, the bar's caption, the ring's
  /// accessible name.
  final String? label;

  /// Progress as a fraction 0–1. Null is indeterminate.
  final double? value;

  /// The `.t-caption-1` status line of
  /// [DabblerNavigationActivityPresentation.progressExpanded].
  final String? status;

  /// An Iconsax name drawn inside the ring.
  final String? icon;

  /// The expanded spinner's tone — [DabblerNavigationActivity.tone].
  final DabblerSpinnerTone spinnerTone;

  /// An optional action on an **expanded** activity row — *Cancel*. Drawn
  /// with the toast action's treatment after the row's content; ignored by
  /// the compact presentations, whose circle has no room for it. Pressing it
  /// runs [DabblerToastAction.onPressed], closes the surface and reports
  /// [DabblerNavigationStatusEndReason.action].
  final DabblerToastAction? action;

  @override
  bool operator ==(Object other) =>
      other is DabblerNavigationStatusActivity &&
      other.presentation == presentation &&
      other.label == label &&
      other.value == value &&
      other.status == status &&
      other.icon == icon &&
      other.spinnerTone == spinnerTone &&
      identical(other.action, action);

  @override
  int get hashCode => Object.hash(
    presentation,
    label,
    value,
    status,
    icon,
    spinnerTone,
    action,
  );
}

/// A toast or banner message — [DabblerNavigationFeedbackData] and the
/// presentation it takes.
///
/// **A message is identified by its [data] object**, exactly as
/// [DabblerNavigationFeedback] identifies it: a new
/// [DabblerNavigationFeedbackData] instance is a new message and runs the
/// sequence again; the same instance (even re-wrapped in a new payload, or
/// with a different [presentation]) is the message already showing.
final class DabblerNavigationStatusFeedback
    extends DabblerNavigationStatusPayload {
  /// Describes one message.
  const DabblerNavigationStatusFeedback(
    this.data, {
    this.presentation = DabblerNavigationFeedbackPresentation.toast,
  });

  /// The message — tone, title, message, icon, action, dismissible, duration.
  final DabblerNavigationFeedbackData data;

  /// Toast or banner.
  final DabblerNavigationFeedbackPresentation presentation;

  /// Whether this is a banner.
  bool get banner =>
      presentation == DabblerNavigationFeedbackPresentation.banner;
}

/// NavigationStatus — **one** persistent Action Area surface that carries
/// activity and feedback in turn, so *Processing → Result* and *Processing →
/// progress → Result* morph on the same surface instead of replacing it.
///
/// It owns exactly one [DabblerActionArea] for its whole lifetime. Changing
/// [payload] — between an activity and a message, from one progress value to
/// the next, from one message to another — never rebuilds that element: the
/// surface, its growth and its colours carry over. Swapping a
/// [DabblerNavigationActivity] for a [DabblerNavigationFeedback] at the same
/// slot cannot do that (they are different widget types, so the area and its
/// growth are discarded); this is the widget an app places when its bottom
/// navigation reports an operation from start to result. Both of those
/// widgets are thin wrappers over this one.
///
/// Nothing here is new to look at: the activity states are
/// [DabblerNavigationActivity]'s, the messages [DabblerNavigationFeedback]'s,
/// with the same [DabblerStatusToneColors], glyphs, hold and timings.
///
/// ## Transitions
///
/// | from → to | what the surface does |
/// |---|---|
/// | idle → activity | straight to the activity's phase — collapsed for `spinner`/`ring`, grown for the rest |
/// | activity → activity | in place: a new value, label or presentation updates the same surface (a progress tick never restarts anything) |
/// | idle or a collapsed circle → message | the circle takes the tone and glyph, holds [DabblerMotion.actionAreaHold], then grows into the message |
/// | grown surface → message | the content fades and the surface shrinks to the tone circle ([DabblerActionArea.contractDuration]), holds, then grows into the message |
/// | message → activity | through the circle: shrink to the brand circle, then grow if the activity is a row |
/// | message ends | collapsed, then idle after [DabblerMotion.slow] (0 under reduced motion) + the hold |
/// | anything → null | idle at once — unless a close is already running, which then plays out |
///
/// While the surface shrinks, the **outgoing** content is what fades: the new
/// payload's content is laid in only once the surface is a circle again.
///
/// ## Ending and [onDone]
///
/// [onDone] reports, once per payload, **why** it ended — at the moment it
/// ends, while the close still plays:
///
/// * [DabblerNavigationStatusEndReason.timeout] — a message's duration ran
///   out (toast 4000ms by default, banner sticky; hover and focus pause it);
/// * [DabblerNavigationStatusEndReason.dismissed] — the banner's dismiss;
/// * [DabblerNavigationStatusEndReason.action] — the message's action, or an
///   activity's (*Cancel*), after its `onPressed` ran;
/// * [DabblerNavigationStatusEndReason.replaced] — a message that had not
///   ended was superseded by a different non-null payload. Delivered after
///   the frame that handed the new payload in; it describes the **previous**
///   message, never the current one.
///
/// Clear the payload, or hand in the next one, from [onDone]: the close that
/// is already running is not cut short by a null, and a next payload morphs
/// out of it. A payload the host withdraws (sets to null) before it ended is
/// not reported — the host did that itself. An activity ends only by its
/// action; replacing an activity reports nothing. [onClosed] fires when a
/// close has finished and the surface is idle.
///
/// ## Suspended
///
/// While [suspended] is true the surface stays idle and no timer runs — the
/// payload is kept, not dropped. When it turns false the current payload is
/// presented from the start (a message runs its full sequence again; one that
/// had already ended stays idle). A host sets it while the bottom bar's
/// create menu is open: **NavigationStatus must never present over the open
/// create menu**, and nothing in this widget can see that menu.
///
/// ## Accessibility
///
/// The surface is `role="status"`, or `role="alert"` for an error or warning
/// **banner** — never a toast, never an activity. The activity indicators
/// expose their own name and value; the message and its action are read from
/// the content. Action and dismiss keep [DabblerSizing.touchTargetMin].
class DabblerNavigationStatus extends StatefulWidget {
  /// Creates one persistent status surface over [bar].
  const DabblerNavigationStatus({
    super.key,
    this.payload,
    this.onDone,
    this.onClosed,
    this.suspended = false,
    this.phase,
    this.bar = const DabblerNavigationBottomBar(),
    this.safeArea = true,
    this.dismissSemanticLabel =
        DabblerNavigationFeedback.defaultDismissSemanticLabel,
  });

  /// What to present. Null is idle: the bar alone.
  final DabblerNavigationStatusPayload? payload;

  /// The payload ended, and why. See *Ending and onDone* above.
  final ValueChanged<DabblerNavigationStatusEndReason>? onDone;

  /// A close has finished and the surface is idle again.
  final VoidCallback? onClosed;

  /// Keeps the surface idle while true — for the open create menu.
  final bool suspended;

  /// Pins a phase for a specimen; nothing then runs on a timer. Null runs the
  /// transitions.
  final DabblerActionAreaPhase? phase;

  /// The real bottom navigation, rendered verbatim beneath.
  final DabblerNavigationBottomBar bar;

  /// Passed to [DabblerActionArea.safeArea].
  final bool safeArea;

  /// The banner dismiss button's accessible name. The package ships no
  /// localised strings.
  final String dismissSemanticLabel;

  /// Identifies the action button's touch target — a message's action or an
  /// activity's. The same key [DabblerNavigationFeedback] exposes.
  static const Key actionTargetKey = DabblerNavigationFeedback.actionTargetKey;

  /// Identifies the banner dismiss button's touch target.
  static const Key dismissTargetKey =
      DabblerNavigationFeedback.dismissTargetKey;

  /// From a grown surface to a message fully grown: the shrink to the circle,
  /// the hold, then the growth with the content fade.
  static Duration morphToFeedbackDuration({required bool reduceMotion}) =>
      DabblerActionArea.contractDuration(reduceMotion: reduceMotion) +
      DabblerMotion.actionAreaHold +
      DabblerActionArea.expandDuration(reduceMotion: reduceMotion);

  @override
  State<DabblerNavigationStatus> createState() =>
      _DabblerNavigationStatusState();
}

class _DabblerNavigationStatusState extends State<DabblerNavigationStatus> {
  /// The payload the surface draws: glyph, colours, role.
  DabblerNavigationStatusPayload? _shown;

  /// The outgoing payload whose content (and fit) is kept while the surface
  /// shrinks, so the old content is what fades.
  DabblerNavigationStatusPayload? _retiring;

  DabblerActionAreaPhase _phase = DabblerActionAreaPhase.idle;

  /// The sequence timer: hold, open, dismissal, close.
  Timer? _timer;

  /// Ends [_retiring].
  Timer? _retire;

  /// Expanded and readable — the only stage a message's timer applies to.
  bool _holding = false;

  /// Pointer or focus on the surface.
  bool _engaged = false;

  /// A close is running (collapsed → idle).
  bool _closing = false;

  /// The current payload's end has been reported.
  bool _ended = false;

  /// Read in [build]; used by timers and [didUpdateWidget], which must not
  /// look an inherited widget up themselves.
  bool _reduceMotion = false;

  bool get _pinned => widget.phase != null;

  @override
  void initState() {
    super.initState();
    _shown = widget.payload;
    if (!_pinned && !widget.suspended && _shown != null) {
      _present(null);
    }
  }

  @override
  void didUpdateWidget(DabblerNavigationStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_pinned) {
      _reset();
      _ended = false;
      _shown = widget.payload;
      return;
    }
    final bool unpinned = oldWidget.phase != null;
    final bool resumed = oldWidget.suspended && !widget.suspended;
    final DabblerNavigationStatusPayload? previous = _shown;
    final DabblerNavigationStatusPayload? next = widget.payload;

    if (unpinned || (!oldWidget.suspended && widget.suspended)) {
      _reset();
      _phase = DabblerActionAreaPhase.idle;
      if (unpinned) _ended = false;
    }

    final bool fresh = _isNew(previous, next);
    if (fresh &&
        !unpinned &&
        previous is DabblerNavigationStatusFeedback &&
        !_ended) {
      _reportLater(DabblerNavigationStatusEndReason.replaced);
    }

    if (next == null) {
      if (!_closing) {
        _reset();
        _phase = DabblerActionAreaPhase.idle;
      }
      // `_shown` stays, so the outgoing content fades with the surface.
      return;
    }

    if (fresh) _ended = false;
    _shown = next;

    if (widget.suspended) {
      _phase = DabblerActionAreaPhase.idle;
      return;
    }
    if (unpinned || resumed) {
      if (!_ended) _present(null);
      return;
    }
    if (fresh) {
      _present(previous);
      return;
    }
    // The same message, or the same operation updating in place.
    if (next is DabblerNavigationStatusActivity && !_closing && !_ended) {
      _moveTo(_activityPhase(next), retire: previous);
    }
  }

  @override
  void dispose() {
    _reset();
    super.dispose();
  }

  /// Whether [next] is a new thing to present rather than an update of
  /// [previous].
  bool _isNew(
    DabblerNavigationStatusPayload? previous,
    DabblerNavigationStatusPayload? next,
  ) {
    if (next == null) return false;
    if (previous == null) return true;
    if (previous.runtimeType != next.runtimeType) return true;
    if (next is DabblerNavigationStatusFeedback) {
      return !identical(
        (previous as DabblerNavigationStatusFeedback).data,
        next.data,
      );
    }
    // An activity after its own action closed it: a different one reopens.
    return _ended && previous != next;
  }

  void _reset() {
    _timer?.cancel();
    _timer = null;
    _retire?.cancel();
    _retire = null;
    _retiring = null;
    _holding = false;
    _closing = false;
  }

  DabblerActionAreaPhase _activityPhase(DabblerNavigationStatusActivity a) =>
      a.presentation.compact
      ? DabblerActionAreaPhase.collapsed
      : DabblerActionAreaPhase.expanded;

  /// Sets the phase; leaving the expanded phase keeps [retire]'s content for
  /// the contraction.
  void _moveTo(
    DabblerActionAreaPhase target, {
    DabblerNavigationStatusPayload? retire,
  }) {
    if (_phase == DabblerActionAreaPhase.expanded &&
        target != DabblerActionAreaPhase.expanded &&
        retire != null) {
      _retireFor(retire);
    }
    _phase = target;
  }

  void _retireFor(DabblerNavigationStatusPayload payload) {
    _retire?.cancel();
    _retiring = payload;
    _retire = Timer(
      DabblerActionArea.contractDuration(reduceMotion: _reduceMotion),
      () {
        if (!mounted) return;
        setState(() => _retiring = null);
      },
    );
  }

  /// Presents [_shown] on the surface as it is now — the transitions table.
  /// Called from [initState] and [didUpdateWidget], both of which rebuild, so
  /// the phase is set directly rather than through `setState`.
  void _present(DabblerNavigationStatusPayload? previous) {
    final DabblerNavigationStatusPayload? next = _shown;
    if (next == null) return;
    final bool wasClosing = _closing;
    final bool open = _phase == DabblerActionAreaPhase.expanded || wasClosing;
    final DabblerNavigationStatusPayload? outgoing = _retiring ?? previous;
    _timer?.cancel();
    _timer = null;
    _holding = false;
    _closing = false;
    final Duration shrink = DabblerActionArea.contractDuration(
      reduceMotion: _reduceMotion,
    );

    switch (next) {
      case DabblerNavigationStatusFeedback():
        if (open && outgoing != null) _retireFor(outgoing);
        _phase = DabblerActionAreaPhase.collapsed;
        // From a grown (or closing) surface the hold starts once it is a
        // circle again; from idle or a circle, at once.
        _timer = Timer(
          (open ? shrink : Duration.zero) + DabblerMotion.actionAreaHold,
          _open,
        );
      case DabblerNavigationStatusActivity():
        final DabblerActionAreaPhase target = _activityPhase(next);
        final bool throughCircle =
            open &&
            (previous is! DabblerNavigationStatusActivity || wasClosing);
        if (!throughCircle) {
          _moveTo(target, retire: outgoing);
          return;
        }
        if (outgoing != null) _retireFor(outgoing);
        _phase = DabblerActionAreaPhase.collapsed;
        if (target == DabblerActionAreaPhase.expanded) {
          _timer = Timer(shrink, () {
            if (!mounted) return;
            _retire?.cancel();
            setState(() {
              _retiring = null;
              _phase = DabblerActionAreaPhase.expanded;
            });
          });
        }
    }
  }

  /// collapsed → expanded for a message; arms the dismissal timer.
  void _open() {
    if (!mounted) return;
    _retire?.cancel();
    setState(() {
      _retiring = null;
      _phase = DabblerActionAreaPhase.expanded;
    });
    _holding = true;
    _arm();
  }

  Duration get _duration {
    final DabblerNavigationStatusPayload? shown = _shown;
    if (shown is! DabblerNavigationStatusFeedback) return Duration.zero;
    if (shown.data.duration != null) return shown.data.duration!;
    // `duration` default: 4000 toast, 0 (sticky) banner.
    return shown.banner
        ? DabblerToastSpec.sticky
        : DabblerToastSpec.defaultDuration;
  }

  /// Starts, or restarts, the dismissal timer — a sticky or paused message
  /// arms nothing.
  void _arm() {
    _timer?.cancel();
    _timer = null;
    if (!mounted || !_holding || _engaged) return;
    if (_duration <= Duration.zero) return;
    _timer = Timer(
      _duration,
      () => _close(DabblerNavigationStatusEndReason.timeout),
    );
  }

  void _setEngaged(bool value) {
    if (_engaged == value) return;
    _engaged = value;
    if (!_holding) return;
    if (value) {
      _timer?.cancel();
      _timer = null;
    } else {
      _arm();
    }
  }

  /// Ends the current payload for [reason]: closes it — a message through the
  /// tone circle and the hold, an activity straight back to the bar — and
  /// reports it.
  void _close(DabblerNavigationStatusEndReason reason) {
    if (!mounted) return;
    if (_pinned) {
      widget.onDone?.call(reason);
      widget.onClosed?.call();
      return;
    }
    if (_closing || _ended) return;
    _timer?.cancel();
    _timer = null;
    _holding = false;
    _closing = true;
    _ended = true;
    final bool message = _shown is DabblerNavigationStatusFeedback;
    setState(() {
      _phase = message
          ? DabblerActionAreaPhase.collapsed
          : DabblerActionAreaPhase.idle;
    });
    // `close()`: collapsed, then after `(reducedMotion ? 0 : 200) + HOLD`
    // idle. An activity has no tone circle to hold; it contracts away.
    final Duration rest = message
        ? (_reduceMotion ? Duration.zero : DabblerMotion.slow) +
              DabblerMotion.actionAreaHold
        : DabblerActionArea.contractDuration(reduceMotion: _reduceMotion);
    _timer = Timer(rest, () {
      if (!mounted) return;
      setState(() {
        _phase = DabblerActionAreaPhase.idle;
        _closing = false;
      });
      widget.onClosed?.call();
    });
    widget.onDone?.call(reason);
  }

  /// A report that arises while a new payload is being handed in — during a
  /// build, where the host may not set state — goes out after the frame.
  void _reportLater(DabblerNavigationStatusEndReason reason) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onDone?.call(reason);
    });
  }

  void _invokeAction(DabblerToastAction action) {
    action.onPressed?.call();
    _close(DabblerNavigationStatusEndReason.action);
  }

  @override
  Widget build(BuildContext context) {
    _reduceMotion = DabblerMotion.reduceMotion(context);
    final DabblerColors colors = DabblerColors.of(context);
    final DabblerNavigationStatusPayload? payload = _pinned
        ? widget.payload
        : _shown;
    final DabblerActionAreaPhase phase = payload == null
        ? DabblerActionAreaPhase.idle
        : _pinned
        ? widget.phase!
        : widget.suspended
        ? DabblerActionAreaPhase.idle
        : _phase;
    // The content (and its fit) is the outgoing payload's while it fades.
    final DabblerNavigationStatusPayload? content = _pinned
        ? payload
        : _retiring ?? payload;
    final bool live = identical(content, payload);
    final bool expanded = phase == DabblerActionAreaPhase.expanded;

    final _Paint paint = switch (payload) {
      DabblerNavigationStatusFeedback(
        :final DabblerNavigationFeedbackData data,
        :final DabblerNavigationFeedbackPresentation presentation,
      ) =>
        _Paint.tone(
          DabblerStatusToneColors.of(colors, data.toneFor(presentation).status),
        ),
      // The create menu's card once grown.
      DabblerNavigationStatusActivity() when expanded => _Paint(
        surface: colors.surfaceCard,
        hairline: colors.borderDefault,
        ink: colors.textPrimary,
      ),
      // The action, working: `hairline: transparent`.
      DabblerNavigationStatusActivity() => _Paint(
        surface: colors.brandPrimary,
        hairline: colors.brandPrimary.withValues(alpha: 0),
        ink: colors.onBrand,
      ),
      null => const _Paint(),
    };

    return DabblerActionArea(
      bar: widget.bar,
      phase: phase,
      fit: _fitOf(content),
      surface: paint.surface,
      hairline: paint.hairline,
      ink: paint.ink,
      safeArea: widget.safeArea,
      onPause: () => _setEngaged(true),
      onResume: () => _setEngaged(false),
      glyphSize:
          payload is DabblerNavigationStatusActivity &&
              payload.presentation == DabblerNavigationActivityPresentation.ring
          ? DabblerSizing.actionAreaRing
          : DabblerSizing.iconMd,
      glyphAtTop: switch (payload) {
        DabblerNavigationStatusFeedback(:final bool banner) => banner,
        DabblerNavigationStatusActivity(
          :final DabblerNavigationActivityPresentation presentation,
        ) =>
          presentation ==
              DabblerNavigationActivityPresentation.progressExpanded,
        null => false,
      },
      role:
          payload is DabblerNavigationStatusFeedback &&
              payload.banner &&
              payload.data.interrupts
          ? DabblerActionAreaRole.alert
          : DabblerActionAreaRole.status,
      glyph: _glyph(payload, colors, expanded: expanded),
      overlay:
          content is DabblerNavigationStatusFeedback &&
              content.banner &&
              content.data.dismissible
          ? PositionedDirectional(
              top: DabblerNavigationFeedback.dismissTop,
              end: DabblerNavigationFeedback.dismissEnd,
              child: _dismiss(
                DabblerStatusToneColors.of(
                  colors,
                  content.data.toneFor(content.presentation).status,
                ),
                live: live,
              ),
            )
          : null,
      children: _children(context, colors, content, live: live),
    );
  }

  DabblerActionAreaFit _fitOf(DabblerNavigationStatusPayload? content) =>
      switch (content) {
        DabblerNavigationStatusFeedback(:final bool banner) =>
          banner ? DabblerActionAreaFit.content : DabblerActionAreaFit.row,
        DabblerNavigationStatusActivity(
          :final DabblerNavigationActivityPresentation presentation,
        ) =>
          presentation == DabblerNavigationActivityPresentation.progressExpanded
              ? DabblerActionAreaFit.content
              : DabblerActionAreaFit.row,
        null => DabblerActionAreaFit.row,
      };

  // ── Glyphs ────────────────────────────────────────────────────────────────

  Widget? _glyph(
    DabblerNavigationStatusPayload? payload,
    DabblerColors colors, {
    required bool expanded,
  }) {
    switch (payload) {
      case null:
        return null;
      case DabblerNavigationStatusFeedback(
        :final DabblerNavigationFeedbackData data,
        :final DabblerNavigationFeedbackPresentation presentation,
      ):
        final DabblerToastTone tone = data.toneFor(presentation);
        // The tone glyph, Iconsax bold at 24 in the circle. Decorative — the
        // message names the state.
        return ExcludeSemantics(
          child: DabblerIcon(
            data.icon ?? tone.glyph,
            weight: DabblerIconWeight.bold,
            size: DabblerSizing.iconMd,
            color: DabblerStatusToneColors.of(colors, tone.status).ink,
          ),
        );
      case DabblerNavigationStatusActivity():
        return _activityGlyph(payload, colors, expanded: expanded);
    }
  }

  /// [DabblerNavigationActivity]'s indicator: a Spinner for `spinner` and
  /// `spinnerLabel`, the 32 ring for `ring`, none for the progress rows.
  Widget? _activityGlyph(
    DabblerNavigationStatusActivity a,
    DabblerColors colors, {
    required bool expanded,
  }) {
    switch (a.presentation) {
      case DabblerNavigationActivityPresentation.ring:
        return DabblerRing.progress(
          value: a.value,
          diameter: DabblerSizing.actionAreaRing,
          tone: expanded ? DabblerRingTone.brand : DabblerRingTone.onBrand,
          semanticLabel: a.label,
          child: a.icon == null
              ? null
              : DabblerIcon(
                  a.icon!,
                  weight: DabblerIconWeight.bold,
                  // `size 16` — half the 32 ring.
                  size: DabblerSizing.actionAreaRing / 2,
                  color: expanded ? colors.textPrimary : colors.onBrand,
                ),
        );
      case DabblerNavigationActivityPresentation.spinner:
      case DabblerNavigationActivityPresentation.spinnerLabel:
        return DabblerSpinner(
          tone: expanded ? a.spinnerTone : DabblerSpinnerTone.onBrand,
          label: a.label,
        );
      case DabblerNavigationActivityPresentation.indeterminate:
      case DabblerNavigationActivityPresentation.progress:
      case DabblerNavigationActivityPresentation.progressExpanded:
        return null;
    }
  }

  // ── Content ───────────────────────────────────────────────────────────────

  List<Widget> _children(
    BuildContext context,
    DabblerColors colors,
    DabblerNavigationStatusPayload? content, {
    required bool live,
  }) {
    switch (content) {
      case null:
        return const <Widget>[];
      case DabblerNavigationStatusFeedback(
        :final DabblerNavigationFeedbackData data,
        :final DabblerNavigationFeedbackPresentation presentation,
        :final bool banner,
      ):
        final DabblerStatusToneColors tone = DabblerStatusToneColors.of(
          colors,
          data.toneFor(presentation).status,
        );
        return banner
            ? _banner(context, data, tone, live: live)
            : _toast(context, data, tone, live: live);
      case DabblerNavigationStatusActivity():
        return _activity(context, colors, content, live: live);
    }
  }

  /// The toast row: one-line `t-subheadline` message, then the text action.
  List<Widget> _toast(
    BuildContext context,
    DabblerNavigationFeedbackData data,
    DabblerStatusToneColors tone, {
    required bool live,
  }) {
    final TextDirection direction = Directionality.of(context);
    return <Widget>[
      Expanded(
        child: Text(
          data.message ?? data.title ?? '',
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: DabblerType.subheadline
              .resolveForDirection(direction)
              .copyWith(color: tone.ink),
        ),
      ),
      if (data.action != null)
        _textAction(context, data.action!, tone.ink, live: live),
    ];
  }

  /// The banner: `t-headline` title and `t-subheadline` message (`--space-1`
  /// apart), the outlined action `--space-2` below; then the dismiss's room.
  List<Widget> _banner(
    BuildContext context,
    DabblerNavigationFeedbackData data,
    DabblerStatusToneColors tone, {
    required bool live,
  }) {
    final TextDirection direction = Directionality.of(context);
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: DabblerSpacing.space1,
          children: <Widget>[
            if (data.title != null)
              Text(
                data.title!,
                style: DabblerType.headline
                    .resolveForDirection(direction)
                    .copyWith(color: tone.ink),
              ),
            if (data.message != null)
              Text(
                data.message!,
                style: DabblerType.subheadline
                    .resolveForDirection(direction)
                    .copyWith(color: tone.ink),
              ),
            if (data.action != null)
              Padding(
                // `marginBlockStart: --space-2`, added to the `--space-1` gap.
                padding: const EdgeInsets.only(top: DabblerSpacing.space2),
                child: _outlinedAction(context, data.action!, tone, live: live),
              ),
          ],
        ),
      ),
      if (data.dismissible)
        const SizedBox(width: DabblerNavigationFeedback.dismissReserve),
    ];
  }

  /// [DabblerNavigationActivity]'s rows, plus the optional action after them.
  List<Widget> _activity(
    BuildContext context,
    DabblerColors colors,
    DabblerNavigationStatusActivity a, {
    required bool live,
  }) {
    final TextDirection direction = Directionality.of(context);
    final Widget? body = switch (a.presentation) {
      // The spinner already announces the label; this is its visible twin.
      DabblerNavigationActivityPresentation.spinnerLabel => ExcludeSemantics(
        child: Text(
          a.label ?? '',
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: DabblerType.subheadline
              .resolveForDirection(direction)
              .copyWith(color: colors.textPrimary),
        ),
      ),
      DabblerNavigationActivityPresentation.indeterminate =>
        DabblerProgressBar.indeterminate(
          size: DabblerProgressBarSize.sm,
          label: a.label,
        ),
      DabblerNavigationActivityPresentation.progress =>
        a.value == null
            ? DabblerProgressBar.indeterminate(
                size: DabblerProgressBarSize.sm,
                label: a.label,
              )
            : DabblerProgressBar(
                value: a.value!,
                size: DabblerProgressBarSize.sm,
                label: a.label,
                showValue: true,
              ),
      DabblerNavigationActivityPresentation.progressExpanded => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DabblerSpacing.space2,
        children: <Widget>[
          // The value is shown only when determinate.
          if (a.value == null)
            DabblerProgressBar.indeterminate(label: a.label)
          else
            DabblerProgressBar(
              value: a.value!,
              label: a.label,
              showValue: true,
            ),
          if (a.status != null)
            Text(
              a.status!,
              style: DabblerType.caption1
                  .resolveForDirection(direction)
                  .copyWith(color: colors.textSecondary),
            ),
        ],
      ),
      DabblerNavigationActivityPresentation.spinner ||
      DabblerNavigationActivityPresentation.ring => null,
    };
    if (body == null) return const <Widget>[];
    return <Widget>[
      Expanded(child: body),
      if (a.action != null)
        _textAction(context, a.action!, colors.textPrimary, live: live),
    ];
  }

  // ── Targets ───────────────────────────────────────────────────────────────

  Widget _interactive({required Widget child}) => DabblerFocusRing(
    borderRadius: DabblerRadius.mdAll,
    child: DabblerPressScale.gesture(child: child),
  );

  /// The [DabblerToast] action's treatment: semibold `t-subheadline` in the
  /// surface's ink, `--space-2` inline padding, the touch-target minimum.
  Widget _textAction(
    BuildContext context,
    DabblerToastAction action,
    Color ink, {
    required bool live,
  }) {
    final VoidCallback? onTap = live ? () => _invokeAction(action) : null;
    return Semantics(
      container: true,
      button: true,
      label: action.label,
      excludeSemantics: true,
      onTap: onTap,
      child: _interactive(
        child: GestureDetector(
          key: live ? DabblerNavigationStatus.actionTargetKey : null,
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: DabblerSizing.touchTargetMin,
            ),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: DabblerSpacing.space2,
            ),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                action.label,
                style: DabblerType.subheadline
                    .resolveForDirection(Directionality.of(context))
                    .copyWith(color: ink, fontWeight: DabblerType.semibold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The [DabblerBanner] action's treatment: outlined in the tone hairline.
  Widget _outlinedAction(
    BuildContext context,
    DabblerToastAction action,
    DabblerStatusToneColors tone, {
    required bool live,
  }) {
    final VoidCallback? onTap = live ? () => _invokeAction(action) : null;
    return Semantics(
      container: true,
      button: true,
      label: action.label,
      excludeSemantics: true,
      onTap: onTap,
      child: _interactive(
        child: GestureDetector(
          key: live ? DabblerNavigationStatus.actionTargetKey : null,
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: DabblerSizing.touchTargetMin,
            ),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: DabblerSpacing.space4,
            ),
            alignment: AlignmentDirectional.center,
            decoration: BoxDecoration(
              borderRadius: DabblerRadius.mdAll,
              border: Border.all(
                color: tone.hairline,
                width: DabblerSizing.borderDefault,
              ),
            ),
            child: Text(
              action.label,
              style: DabblerType.subheadline
                  .resolveForDirection(Directionality.of(context))
                  .copyWith(color: tone.ink, fontWeight: DabblerType.semibold),
            ),
          ),
        ),
      ),
    );
  }

  /// The 45×45 dismiss, carrying the Banner's `close-circle` at 18.
  Widget _dismiss(DabblerStatusToneColors tone, {required bool live}) {
    final VoidCallback? onTap = live
        ? () => _close(DabblerNavigationStatusEndReason.dismissed)
        : null;
    return Semantics(
      container: true,
      button: true,
      label: widget.dismissSemanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: _interactive(
        child: GestureDetector(
          key: live ? DabblerNavigationStatus.dismissTargetKey : null,
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox.square(
            dimension: DabblerSizing.touchTargetMin,
            child: Center(
              child: DabblerIcon(
                'close-circle',
                size: DabblerSizing.iconSm,
                color: tone.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Surface, hairline and ink for one payload. Null fields take the Action
/// Area's defaults.
@immutable
class _Paint {
  const _Paint({this.surface, this.hairline, this.ink});

  _Paint.tone(DabblerStatusToneColors tone)
    : surface = tone.surface,
      hairline = tone.hairline,
      ink = tone.ink;

  final Color? surface;
  final Color? hairline;
  final Color? ink;
}
