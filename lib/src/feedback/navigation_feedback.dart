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
/// than adding a third copy of the same five values. Its default is Toast's,
/// `neutral`.
@immutable
class DabblerNavigationFeedbackData {
  /// Describes one message.
  const DabblerNavigationFeedbackData({
    this.tone = DabblerToastTone.neutral,
    this.title,
    this.message,
    this.icon,
    this.action,
    this.dismissible = false,
    this.duration,
  });

  /// The status tone; colours come from [DabblerStatusToneColors].
  final DabblerToastTone tone;

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
/// | expanded | the surface grows, then the content fades in | [DabblerActionArea.expandDuration] |
/// | hold | readable; hover and focus pause the timer | toast 4000ms · banner sticky |
/// | contract | content fades, then the surface shrinks | [DabblerActionArea.contractDuration], then the hold |
/// | idle | [onDone] | — |
///
/// The action and the dismiss button start the contraction at once. Pass
/// [phase] to pin a state for a specimen; nothing then runs on a timer.
///
/// ## When to use it
///
/// When the message is a direct consequence of the user's action on this
/// screen and the screen has the bottom bar. Never while the create menu is
/// open, over a Dialog or Sheet, or on a screen without the bar; standard
/// Toast and Banner stay the default.
class DabblerNavigationFeedback extends StatefulWidget {
  /// Creates navigation-integrated feedback over [bar].
  const DabblerNavigationFeedback({
    super.key,
    this.presentation = DabblerNavigationFeedbackPresentation.toast,
    this.feedback,
    this.phase,
    this.onDone,
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

  /// The inset that centres a [DabblerSizing.touchTargetMin] dismiss target
  /// on the glyph row's centre line — `(56 - 45) / 2`, from tokens.
  static const double dismissInset =
      (DabblerActionArea.glyphSlot - DabblerSizing.touchTargetMin) / 2;

  @override
  State<DabblerNavigationFeedback> createState() =>
      _DabblerNavigationFeedbackState();
}

class _DabblerNavigationFeedbackState extends State<DabblerNavigationFeedback> {
  DabblerNavigationFeedbackData? _shown;
  DabblerActionAreaPhase _phase = DabblerActionAreaPhase.idle;
  Timer? _timer;

  /// True while expanded and readable — the only stage the dismissal timer
  /// and its pause apply to.
  bool _holding = false;
  bool _hovered = false;
  bool _focused = false;

  bool get _pinned => widget.phase != null;

  @override
  void initState() {
    super.initState();
    _shown = widget.feedback;
    if (!_pinned && widget.feedback != null) {
      _start();
    }
  }

  @override
  void didUpdateWidget(DabblerNavigationFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_pinned) {
      _cancel();
      _shown = widget.feedback;
      return;
    }
    if (oldWidget.phase != null) {
      // Unpinned: whatever was pinned is not a running sequence.
      _phase = DabblerActionAreaPhase.idle;
    }
    if (!identical(widget.feedback, oldWidget.feedback) ||
        oldWidget.phase != null) {
      if (widget.feedback == null) {
        _cancel();
        _phase = DabblerActionAreaPhase.idle;
      } else {
        _shown = widget.feedback;
        _start();
      }
    }
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
    _holding = false;
  }

  bool get _reduceMotion => DabblerMotion.reduceMotion(context);

  /// collapsed → (hold) → expanded. Called from [initState] and
  /// [didUpdateWidget], both of which rebuild anyway, so the phase is set
  /// directly rather than through `setState`.
  void _start() {
    _cancel();
    _phase = DabblerActionAreaPhase.collapsed;
    _timer = Timer(DabblerMotion.actionAreaHold, _open);
  }

  void _open() {
    if (!mounted) return;
    setState(() => _phase = DabblerActionAreaPhase.expanded);
    _timer = Timer(
      DabblerActionArea.expandDuration(reduceMotion: _reduceMotion),
      () {
        _holding = true;
        _arm();
      },
    );
  }

  Duration get _duration {
    final DabblerNavigationFeedbackData? data = _shown;
    if (data?.duration != null) return data!.duration!;
    return widget.presentation == DabblerNavigationFeedbackPresentation.toast
        ? DabblerToastSpec.defaultDuration
        : DabblerToastSpec.sticky;
  }

  /// Starts, or restarts, the dismissal timer — a sticky or paused message
  /// arms nothing, exactly as `DabblerToast` arms its own.
  void _arm() {
    _timer?.cancel();
    _timer = null;
    if (!mounted || !_holding || _hovered || _focused) return;
    if (_duration <= Duration.zero) return;
    _timer = Timer(_duration, _close);
  }

  void _pause() {
    if (!_holding) return;
    _timer?.cancel();
    _timer = null;
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    _hovered = value;
    value ? _pause() : _arm();
  }

  void _setFocused(bool value) {
    if (_focused == value) return;
    _focused = value;
    value ? _pause() : _arm();
  }

  /// expanded → contract → collapsed (hold) → idle, then [onDone].
  void _close() {
    if (!mounted) return;
    if (_pinned) {
      widget.onDone?.call();
      return;
    }
    _cancel();
    setState(() => _phase = DabblerActionAreaPhase.collapsed);
    _timer = Timer(
      DabblerActionArea.contractDuration(reduceMotion: _reduceMotion) +
          DabblerMotion.actionAreaHold,
      () {
        if (!mounted) return;
        setState(() => _phase = DabblerActionAreaPhase.idle);
        widget.onDone?.call();
      },
    );
  }

  void _invokeAction() {
    _shown?.action?.onPressed?.call();
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final DabblerNavigationFeedbackData? data = _pinned
        ? widget.feedback
        : _shown;
    final DabblerActionAreaPhase phase = data == null
        ? DabblerActionAreaPhase.idle
        : widget.phase ?? _phase;
    final DabblerStatusToneColors tone = DabblerStatusToneColors.of(
      colors,
      (data?.tone ?? DabblerToastTone.neutral).status,
    );
    final bool banner =
        widget.presentation == DabblerNavigationFeedbackPresentation.banner;

    return DabblerActionArea(
      bar: widget.bar,
      phase: phase,
      fit: banner ? DabblerActionAreaFit.content : DabblerActionAreaFit.row,
      surface: tone.surface,
      hairline: tone.hairline,
      ink: tone.ink,
      safeArea: widget.safeArea,
      role: banner && (data?.interrupts ?? false)
          ? DabblerActionAreaRole.alert
          : DabblerActionAreaRole.status,
      glyph: data == null
          ? null
          // The tone glyph, Iconsax bold at 24 in the circle (*Sequence*:
          // "24px bold glyph"). Decorative — the message names the state.
          : ExcludeSemantics(
              child: DabblerIcon(
                data.icon ?? data.tone.glyph,
                weight: DabblerIconWeight.bold,
                size: DabblerSizing.iconMd,
                color: tone.ink,
              ),
            ),
      child: data == null
          ? null
          : MouseRegion(
              onEnter: (_) => _setHovered(true),
              onExit: (_) => _setHovered(false),
              child: Focus(
                canRequestFocus: false,
                skipTraversal: true,
                onFocusChange: _setFocused,
                child: banner
                    ? _banner(context, data, tone)
                    : _toast(context, data, tone),
              ),
            ),
    );
  }

  /// The toast row: message on one line, the action at the inline end.
  Widget _toast(
    BuildContext context,
    DabblerNavigationFeedbackData data,
    DabblerStatusToneColors tone,
  ) {
    final TextDirection direction = Directionality.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: DabblerActionArea.glyphSlot,
        end: data.action == null ? DabblerSpacing.space5 : DabblerSpacing.space3,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              data.message ?? data.title ?? '',
              // The geometry is the bar's: one line, anything longer is a
              // banner.
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: DabblerType.subheadline
                  .resolveForDirection(direction)
                  .copyWith(color: tone.ink),
            ),
          ),
          if (data.action != null) ...<Widget>[
            const SizedBox(width: DabblerSpacing.space3),
            _textAction(context, data.action!, tone),
          ],
        ],
      ),
    );
  }

  /// The banner body: title, message and outlined action in the tone's
  /// strong ink, the dismiss target at the top-trailing corner.
  Widget _banner(
    BuildContext context,
    DabblerNavigationFeedbackData data,
    DabblerStatusToneColors tone,
  ) {
    final TextDirection direction = Directionality.of(context);
    final List<Widget> column = <Widget>[
      if (data.title != null)
        Text(
          data.title!,
          style: DabblerType.headline
              .resolveForDirection(direction)
              .copyWith(color: tone.ink),
        ),
      if (data.title != null && data.message != null)
        // `gap: var(--space-1)` — the Banner's own content column.
        const SizedBox(height: DabblerSpacing.space1),
      if (data.message != null)
        Text(
          data.message!,
          style: DabblerType.subheadline
              .resolveForDirection(direction)
              .copyWith(color: tone.ink),
        ),
      if (data.action != null) ...<Widget>[
        // `marginBlockStart: var(--space-2)` on the Banner's action.
        const SizedBox(height: DabblerSpacing.space2),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: _outlinedAction(context, data.action!, tone),
        ),
      ],
    ];

    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: DabblerActionArea.glyphSlot,
            top: DabblerSpacing.space5,
            bottom: DabblerSpacing.space5,
            end: data.dismissible
                ? DabblerActionArea.glyphSlot
                : DabblerSpacing.space5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: column,
          ),
        ),
        if (data.dismissible)
          PositionedDirectional(
            top: DabblerNavigationFeedback.dismissInset,
            end: DabblerNavigationFeedback.dismissInset,
            child: _dismiss(tone),
          ),
      ],
    );
  }

  Widget _interactive({required Widget child}) => DabblerFocusRing(
    borderRadius: DabblerRadius.mdAll,
    child: DabblerPressScale.gesture(child: child),
  );

  /// The toast's text action — the [DabblerToast] action's treatment.
  Widget _textAction(
    BuildContext context,
    DabblerToastAction action,
    DabblerStatusToneColors tone,
  ) {
    return Semantics(
      container: true,
      button: true,
      label: action.label,
      excludeSemantics: true,
      onTap: _invokeAction,
      child: _interactive(
        child: GestureDetector(
          key: DabblerNavigationFeedback.actionTargetKey,
          behavior: HitTestBehavior.opaque,
          onTap: _invokeAction,
          child: Container(
            constraints: const BoxConstraints(
              minWidth: DabblerSizing.touchTargetMin,
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
                    .copyWith(
                      color: tone.ink,
                      fontWeight: DabblerType.semibold,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The banner's outlined action — the [DabblerBanner] action's treatment.
  Widget _outlinedAction(
    BuildContext context,
    DabblerToastAction action,
    DabblerStatusToneColors tone,
  ) {
    return Semantics(
      container: true,
      button: true,
      label: action.label,
      excludeSemantics: true,
      onTap: _invokeAction,
      child: _interactive(
        child: GestureDetector(
          key: DabblerNavigationFeedback.actionTargetKey,
          behavior: HitTestBehavior.opaque,
          onTap: _invokeAction,
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
  Widget _dismiss(DabblerStatusToneColors tone) {
    return Semantics(
      container: true,
      button: true,
      label: widget.dismissSemanticLabel,
      excludeSemantics: true,
      onTap: _close,
      child: _interactive(
        child: GestureDetector(
          key: DabblerNavigationFeedback.dismissTargetKey,
          behavior: HitTestBehavior.opaque,
          onTap: _close,
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
