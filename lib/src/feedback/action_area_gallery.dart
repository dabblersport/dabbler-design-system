/// Gallery entries for the Action Area family — [DabblerActionArea],
/// [DabblerNavigationStatus], [DabblerNavigationFeedback],
/// [DabblerNavigationActivity] — and the progress form of [DabblerRing].
///
/// Laid out to mirror `components/feedback/status-feedback.card.html`: every
/// state the card draws is a specimen here, each in the card's own `Screen`
/// frame — a phone-width column with the bar in its safe area, on the page
/// background, bottom-aligned (`padding: 0 12px 22px`).
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../foundations/icon.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../navigation/bottom_bar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';
import 'action_area.dart';
import 'navigation_activity.dart';
import 'navigation_feedback.dart';
import 'navigation_status.dart';
import 'ring.dart';
import 'toast.dart';

/// The card's `Screen` width — `width: 384`, which is `8 × --space-11`.
const double _phoneWidth = DabblerSpacing.space11 * 8;

/// The bar every specimen renders: the real one, its inset handled by the
/// Action Area.
const DabblerNavigationBottomBar _bar = DabblerNavigationBottomBar(
  safeArea: false,
);

/// The card's `NAV_TOASTS`.
const List<DabblerNavigationFeedbackData> _navToasts =
    <DabblerNavigationFeedbackData>[
      DabblerNavigationFeedbackData(
        tone: DabblerToastTone.success,
        message: 'joined game',
      ),
      DabblerNavigationFeedbackData(
        tone: DabblerToastTone.neutral,
        message: 'link copied',
        action: DabblerToastAction(label: 'undo'),
      ),
      DabblerNavigationFeedbackData(
        tone: DabblerToastTone.info,
        message: '8 players going',
      ),
      DabblerNavigationFeedbackData(
        tone: DabblerToastTone.warning,
        message: 'only 2 spots left',
      ),
      DabblerNavigationFeedbackData(
        tone: DabblerToastTone.error,
        message: "couldn't join",
        action: DabblerToastAction(label: 'retry'),
      ),
    ];

/// The card's `NAV_BANNERS`.
const List<DabblerNavigationFeedbackData> _navBanners =
    <DabblerNavigationFeedbackData>[
      DabblerNavigationFeedbackData(
        tone: DabblerToastTone.info,
        title: 'new season starting',
        message: 'fixtures for the winter league are open for registration.',
      ),
      DabblerNavigationFeedbackData(
        tone: DabblerToastTone.success,
        title: 'booking confirmed',
        message: 'tuesday 5-a-side at zayed sports city, 6:00 pm.',
      ),
      DabblerNavigationFeedbackData(
        tone: DabblerToastTone.warning,
        title: 'verification needed',
        message: 'add a phone number before you can host games.',
        action: DabblerToastAction(label: 'verify now'),
      ),
      DabblerNavigationFeedbackData(
        tone: DabblerToastTone.error,
        title: 'game cancelled',
        message: 'tuesday 5-a-side was cancelled. your AED 35 was refunded.',
        dismissible: true,
      ),
      DabblerNavigationFeedbackData(
        tone: DabblerToastTone.neutral,
        title: 'profile is private',
        message: 'only followers can see your games.',
      ),
    ];

/// The Action Area family's specimens.
const List<GalleryEntry> actionAreaGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'action-area/system-states',
    page: 'components/action-area',
    group: GalleryPurpose.statusAndFeedback,
    title: 'Action Area — system states',
    description:
        'The reusable states the bottom navigation can be in: idle, '
        'loading, progress and the four status tones — all the same '
        'surface on the real bottom bar.',
    builder: _systemStates,
  ),
  GalleryEntry(
    id: 'action-area/completion',
    page: 'components/action-area',
    group: GalleryPurpose.statusAndFeedback,
    title: 'Action Area — completion',
    description:
        'How activity resolves into feedback: the collapsed circle changes '
        'tone, then expands; the ring closes, then becomes the tone glyph.',
    builder: _completion,
  ),
  GalleryEntry(
    id: 'navigation-status/sequences',
    page: 'components/navigation-status',
    group: GalleryPurpose.statusAndFeedback,
    title: 'NavigationStatus — sequences',
    description:
        'One persistent surface carrying an operation to its result: '
        'processing → success; processing → error + retry → processing → '
        'success; progress 0 → 100 → success; a sticky info banner and its '
        'dismiss. Each plays once and can be replayed.',
    builder: _statusSequences,
  ),
  GalleryEntry(
    id: 'navigation-feedback/toast',
    page: 'components/navigation-feedback',
    group: GalleryPurpose.statusAndFeedback,
    title: 'NavigationFeedback — toast',
    description:
        'The five toast tones presented from the bottom navigation, '
        'expanded phase pinned.',
    builder: _toasts,
  ),
  GalleryEntry(
    id: 'navigation-feedback/banner',
    page: 'components/navigation-feedback',
    group: GalleryPurpose.statusAndFeedback,
    title: 'NavigationFeedback — banner',
    description:
        'The five banner tones grown from the bottom navigation, expanded '
        'phase pinned.',
    builder: _banners,
  ),
  GalleryEntry(
    id: 'navigation-feedback/sequence',
    page: 'components/navigation-feedback',
    group: GalleryPurpose.statusAndFeedback,
    title: 'NavigationFeedback — interaction preview',
    description:
        'Idle, collapsed and looping expansion, then a live pair (LTR and '
        'RTL): fire one and watch the sequence. The toast holds 3s, the '
        'banner until dismissed.',
    builder: _sequence,
  ),
  GalleryEntry(
    id: 'navigation-activity/spinner',
    page: 'components/navigation-activity',
    group: GalleryPurpose.statusAndFeedback,
    title: 'NavigationActivity — spinner',
    description:
        'The same Spinner on the action footprint: compact on the brand '
        'circle, and grown into a card row with a label, in LTR and RTL.',
    builder: _activitySpinner,
  ),
  GalleryEntry(
    id: 'navigation-activity/progress',
    page: 'components/navigation-activity',
    group: GalleryPurpose.statusAndFeedback,
    title: 'NavigationActivity — progress',
    description:
        'The same ProgressBar composed into the Action Area — compact, '
        'expanded, indeterminate — and the progress ring on the footprint.',
    builder: _activityProgress,
  ),
  GalleryEntry(
    id: 'ring/progress',
    page: 'components/ring',
    group: GalleryPurpose.statusAndFeedback,
    title: 'Ring — progress',
    description:
        'The progress form on its own: 24 and 36, indeterminate, a status '
        'tone, and with an icon in the centre.',
    builder: _progressRings,
  ),
];

/// The card's `Screen`: a phone-width frame with the bar at the bottom.
class _Screen extends StatelessWidget {
  const _Screen({required this.child, this.rtl = false});

  final Widget child;
  final bool rtl;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Widget frame = Container(
      width: _phoneWidth,
      constraints: const BoxConstraints(
        minHeight: DabblerSizing.mediaPreviewCompactHeight,
      ),
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsetsDirectional.only(
        start: DabblerSpacing.space4,
        end: DabblerSpacing.space4,
        bottom: DabblerSpacing.space7,
      ),
      decoration: BoxDecoration(
        color: colors.bgPrimary,
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
        borderRadius: DabblerRadius.xlAll,
      ),
      child: child,
    );
    return rtl
        ? Directionality(textDirection: TextDirection.rtl, child: frame)
        : frame;
  }
}

Widget _screen(String label, Widget child, {bool rtl = false}) =>
    GallerySpecimen(
      label: label,
      child: _Screen(rtl: rtl, child: child),
    );

Widget _toastAt(int i) => DabblerNavigationFeedback(
  bar: _bar,
  safeArea: false,
  feedback: _navToasts[i],
  phase: DabblerActionAreaPhase.expanded,
);

Widget _systemStates(BuildContext context) => GalleryWrap(
  children: <Widget>[
    _screen(
      'idle navigation',
      const DabblerNavigationActivity(
        active: false,
        bar: _bar,
        safeArea: false,
      ),
    ),
    _screen(
      'loading · compact',
      const DabblerNavigationActivity(
        label: 'joining',
        bar: _bar,
        safeArea: false,
      ),
    ),
    _screen(
      'loading · with label',
      const DabblerNavigationActivity(
        presentation: DabblerNavigationActivityPresentation.spinnerLabel,
        label: 'joining game',
        bar: _bar,
        safeArea: false,
      ),
    ),
    _screen(
      'progress · determinate',
      const DabblerNavigationActivity(
        presentation: DabblerNavigationActivityPresentation.progress,
        label: 'uploading',
        value: 0.35,
        bar: _bar,
        safeArea: false,
      ),
    ),
    _screen(
      'progress · indeterminate',
      const DabblerNavigationActivity(
        presentation: DabblerNavigationActivityPresentation.indeterminate,
        label: 'syncing',
        bar: _bar,
        safeArea: false,
      ),
    ),
    _screen(
      'progress · ring',
      const DabblerNavigationActivity(
        presentation: DabblerNavigationActivityPresentation.ring,
        label: 'uploading',
        value: 0.65,
        icon: 'gallery',
        bar: _bar,
        safeArea: false,
      ),
    ),
    _screen('success', _toastAt(0)),
    _screen('warning', _toastAt(3)),
    _screen('error', _toastAt(4)),
    _screen('info', _toastAt(2)),
  ],
);

Widget _collapsedToast(DabblerNavigationFeedbackData data) =>
    DabblerNavigationFeedback(
      bar: _bar,
      safeArea: false,
      feedback: data,
      phase: DabblerActionAreaPhase.collapsed,
    );

Widget _completion(BuildContext context) => GalleryWrap(
  children: <Widget>[
    GallerySpecimen(
      label:
          'loading → success · the collapsed circle changes tone, then '
          'expands',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: DabblerSpacing.space3,
        children: <Widget>[
          const _Screen(
            child: DabblerNavigationActivity(
              label: 'joining',
              bar: _bar,
              safeArea: false,
            ),
          ),
          _Screen(child: _collapsedToast(_navToasts[0])),
          _Screen(child: _toastAt(0)),
        ],
      ),
    ),
    GallerySpecimen(
      label: 'loading → error · same route, error tone, retry action',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: DabblerSpacing.space3,
        children: <Widget>[
          const _Screen(
            child: DabblerNavigationActivity(
              presentation: DabblerNavigationActivityPresentation.spinnerLabel,
              label: 'joining game',
              bar: _bar,
              safeArea: false,
            ),
          ),
          _Screen(child: _collapsedToast(_navToasts[4])),
          _Screen(child: _toastAt(4)),
        ],
      ),
    ),
    GallerySpecimen(
      label:
          'progress 100% → success icon · the ring closes, then becomes '
          'the tone glyph',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: DabblerSpacing.space3,
        children: <Widget>[
          const _Screen(
            child: DabblerNavigationActivity(
              presentation: DabblerNavigationActivityPresentation.ring,
              label: 'uploading',
              value: 0.65,
              icon: 'gallery',
              bar: _bar,
              safeArea: false,
            ),
          ),
          const _Screen(
            child: DabblerNavigationActivity(
              presentation: DabblerNavigationActivityPresentation.ring,
              label: 'uploading',
              value: 1,
              icon: 'gallery',
              bar: _bar,
              safeArea: false,
            ),
          ),
          _Screen(
            child: _collapsedToast(
              const DabblerNavigationFeedbackData(
                tone: DabblerToastTone.success,
                message: 'photos uploaded',
              ),
            ),
          ),
        ],
      ),
    ),
  ],
);

Widget _toasts(BuildContext context) => GalleryWrap(
  children: <Widget>[
    for (int i = 0; i < _navToasts.length; i++)
      _screen(
        _navToasts[i].toneFor(DabblerNavigationFeedbackPresentation.toast).name,
        _toastAt(i),
      ),
  ],
);

Widget _banners(BuildContext context) => GalleryWrap(
  children: <Widget>[
    for (final DabblerNavigationFeedbackData banner in _navBanners)
      _screen(
        banner.toneFor(DabblerNavigationFeedbackPresentation.banner).name,
        DabblerNavigationFeedback(
          presentation: DabblerNavigationFeedbackPresentation.banner,
          bar: _bar,
          safeArea: false,
          feedback: banner,
          phase: DabblerActionAreaPhase.expanded,
        ),
      ),
  ],
);

Widget _sequence(BuildContext context) => GalleryStack(
  children: <Widget>[
    GalleryWrap(
      children: <Widget>[
        _screen(
          '1 · navigation — normal',
          const DabblerNavigationFeedback(
            bar: _bar,
            safeArea: false,
            phase: DabblerActionAreaPhase.idle,
          ),
        ),
        _screen(
          '2 · status — collapsed: the action footprint becomes the tone '
          'glyph',
          _collapsedToast(_navToasts[0]),
        ),
        _screen(
          '3 · status — expanded toast (looping: circle → full-width toast)',
          _Loop(
            presentation: DabblerNavigationFeedbackPresentation.toast,
            feedback: _navToasts[0],
          ),
        ),
        _screen(
          '4 · status — expanded banner (looping)',
          _Loop(
            presentation: DabblerNavigationFeedbackPresentation.banner,
            feedback: _navBanners[2],
          ),
        ),
      ],
    ),
    const GallerySpecimen(
      label:
          'live · fire one and watch the sequence; the toast holds 3s, '
          'the banner until dismissed',
      child: _LiveFeedback(),
    ),
  ],
);

Widget _activitySpinner(BuildContext context) => GalleryWrap(
  children: <Widget>[
    _screen(
      'compact — the action button, working: brand circle, on-brand '
      'Spinner md',
      const DabblerNavigationActivity(
        label: 'joining',
        bar: _bar,
        safeArea: false,
      ),
    ),
    _screen(
      'with label — the circle grows into a card row',
      const DabblerNavigationActivity(
        presentation: DabblerNavigationActivityPresentation.spinnerLabel,
        label: 'joining game',
        bar: _bar,
        safeArea: false,
      ),
    ),
    _screen(
      'with label — saving',
      const DabblerNavigationActivity(
        presentation: DabblerNavigationActivityPresentation.spinnerLabel,
        label: 'saving',
        bar: _bar,
        safeArea: false,
      ),
    ),
    _screen(
      'RTL — originates on the left, grows rightward; glyph leads',
      const DabblerNavigationActivity(
        presentation: DabblerNavigationActivityPresentation.spinnerLabel,
        label: 'syncing',
        bar: _bar,
        safeArea: false,
      ),
      rtl: true,
    ),
  ],
);

Widget _activityProgress(BuildContext context) => GalleryStack(
  children: <Widget>[
    GalleryWrap(
      children: <Widget>[
        _screen(
          'determinate compact — ProgressBar sm, label + value; no glyph '
          'beside it',
          const DabblerNavigationActivity(
            presentation: DabblerNavigationActivityPresentation.progress,
            label: 'uploading',
            value: 0.35,
            bar: _bar,
            safeArea: false,
          ),
        ),
        _screen(
          'determinate expanded — grows to content, ProgressBar md + status '
          'line',
          const DabblerNavigationActivity(
            presentation:
                DabblerNavigationActivityPresentation.progressExpanded,
            label: 'uploading',
            value: 0.35,
            status: '3 of 8 photos · about a minute left',
            bar: _bar,
            safeArea: false,
          ),
        ),
        _screen(
          'indeterminate — sweeping track, no value',
          const DabblerNavigationActivity(
            presentation: DabblerNavigationActivityPresentation.indeterminate,
            label: 'preparing game',
            bar: _bar,
            safeArea: false,
          ),
        ),
        _screen(
          'progress ring — compact; the action footprint carries the ring '
          '(± icon)',
          const DabblerNavigationActivity(
            presentation: DabblerNavigationActivityPresentation.ring,
            label: 'uploading',
            value: 0.65,
            icon: 'gallery',
            bar: _bar,
            safeArea: false,
          ),
        ),
        _screen(
          'progress ring — indeterminate',
          const DabblerNavigationActivity(
            presentation: DabblerNavigationActivityPresentation.ring,
            label: 'syncing',
            bar: _bar,
            safeArea: false,
          ),
        ),
      ],
    ),
    const GallerySpecimen(
      label: 'progress ring — a live value',
      child: _LiveRing(),
    ),
  ],
);

Widget _progressRings(BuildContext context) {
  final DabblerColors colors = DabblerColors.of(context);
  return GalleryWrap(
    children: <Widget>[
      const GallerySpecimen(
        label: '24 · 35%',
        child: DabblerRing.progress(value: 0.35, semanticLabel: 'upload'),
      ),
      const GallerySpecimen(
        label: '36 · 70%',
        child: DabblerRing.progress(
          value: 0.7,
          diameter: DabblerSizing.iconXl,
          semanticLabel: 'upload',
        ),
      ),
      const GallerySpecimen(
        label: '24 · indeterminate',
        child: DabblerRing.progress(semanticLabel: 'syncing'),
      ),
      const GallerySpecimen(
        label: '24 · complete, success tone',
        child: DabblerRing.progress(
          value: 1,
          tone: DabblerRingTone.success,
          semanticLabel: 'upload',
        ),
      ),
      GallerySpecimen(
        label: '36 · with an icon',
        child: DabblerRing.progress(
          value: 0.5,
          diameter: DabblerSizing.iconXl,
          semanticLabel: 'upload',
          child: DabblerIcon(
            'gallery',
            size: DabblerSizing.iconInline,
            color: colors.textPrimary,
          ),
        ),
      ),
    ],
  );
}

/// The card's `Loop`: collapsed → expanded and back, so the growth itself is
/// visible in a pinned preview (700ms collapsed, 2600ms expanded).
class _Loop extends StatefulWidget {
  const _Loop({required this.presentation, required this.feedback});

  final DabblerNavigationFeedbackPresentation presentation;
  final DabblerNavigationFeedbackData feedback;

  /// `setTimeout(tick, phase === 'collapsed' ? 700 : 2600)` — the card's own
  /// preview cadence. A gallery demonstration value, not a component timing.
  static Duration dwell(DabblerActionAreaPhase phase) =>
      phase == DabblerActionAreaPhase.collapsed
      ? _LoopDwell.collapsed
      : _LoopDwell.expanded;

  @override
  State<_Loop> createState() => _LoopState();
}

/// The preview loop's two dwell times, from the motion tokens.
abstract final class _LoopDwell {
  /// How long the looping preview rests on the circle.
  static const Duration collapsed = Duration(milliseconds: 700);

  /// How long the looping preview rests expanded.
  static const Duration expanded = Duration(milliseconds: 2600);
}

class _LoopState extends State<_Loop> {
  DabblerActionAreaPhase _phase = DabblerActionAreaPhase.collapsed;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  void _schedule() {
    _timer = Timer(_Loop.dwell(_phase), () {
      if (!mounted) return;
      setState(() {
        _phase = _phase == DabblerActionAreaPhase.collapsed
            ? DabblerActionAreaPhase.expanded
            : DabblerActionAreaPhase.collapsed;
      });
      _schedule();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DabblerNavigationFeedback(
    presentation: widget.presentation,
    feedback: widget.feedback,
    phase: _phase,
    bar: _bar,
    safeArea: false,
  );
}

/// The card's live pair: one button per toast and banner; both screens run
/// the real lifecycle, the second in RTL.
class _LiveFeedback extends StatefulWidget {
  const _LiveFeedback();

  @override
  State<_LiveFeedback> createState() => _LiveFeedbackState();
}

class _LiveFeedbackState extends State<_LiveFeedback> {
  DabblerNavigationFeedbackData? _live;
  DabblerNavigationFeedbackPresentation _kind =
      DabblerNavigationFeedbackPresentation.toast;

  void _fire(
    DabblerNavigationFeedbackPresentation kind,
    DabblerNavigationFeedbackData data,
  ) {
    final bool toast = kind == DabblerNavigationFeedbackPresentation.toast;
    setState(() {
      _kind = kind;
      _live = DabblerNavigationFeedbackData(
        tone: data.tone,
        title: data.title,
        message: data.message,
        action: data.action,
        // The card's `fire()`: a 3s toast, a sticky dismissible banner.
        duration: toast ? _LiveLifetime.live : Duration.zero,
        dismissible: !toast,
      );
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    spacing: DabblerSpacing.space4,
    children: <Widget>[
      Wrap(
        spacing: DabblerSpacing.space4,
        runSpacing: DabblerSpacing.space4,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: <Widget>[
          _Screen(
            child: DabblerNavigationFeedback(
              presentation: _kind,
              feedback: _live,
              bar: _bar,
              safeArea: false,
              onDone: () => setState(() => _live = null),
            ),
          ),
          _Screen(
            rtl: true,
            child: DabblerNavigationFeedback(
              presentation: _kind,
              feedback: _live,
              bar: _bar,
              safeArea: false,
            ),
          ),
        ],
      ),
      Wrap(
        spacing: DabblerSpacing.space3,
        runSpacing: DabblerSpacing.space3,
        children: <Widget>[
          for (final DabblerNavigationFeedbackData t in _navToasts)
            DabblerButton(
              label:
                  'toast · ${t.toneFor(DabblerNavigationFeedbackPresentation.toast).name}',
              tone: DabblerButtonTone.neutral,
              size: DabblerButtonSize.small,
              onPressed: () =>
                  _fire(DabblerNavigationFeedbackPresentation.toast, t),
            ),
          for (final DabblerNavigationFeedbackData b in _navBanners)
            DabblerButton(
              label:
                  'banner · ${b.toneFor(DabblerNavigationFeedbackPresentation.banner).name}',
              tone: DabblerButtonTone.neutral,
              size: DabblerButtonSize.small,
              onPressed: () =>
                  _fire(DabblerNavigationFeedbackPresentation.banner, b),
            ),
        ],
      ),
    ],
  );
}

/// The live toast's lifetime on the card — `duration: 3000`.
abstract final class _LiveLifetime {
  /// `fire('toast', …)` sets `duration: 3000`.
  static const Duration live = Duration(seconds: 3);
}

/// The card's live ring: the ProgressBar section's ±15% buttons driving the
/// ring on the footprint.
class _LiveRing extends StatefulWidget {
  const _LiveRing();

  @override
  State<_LiveRing> createState() => _LiveRingState();
}

class _LiveRingState extends State<_LiveRing> {
  /// `useState(0.35)`.
  double _pct = _start;

  static const double _start = 0.35;

  /// The buttons' `±0.15`.
  static const double _step = 0.15;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    spacing: DabblerSpacing.space4,
    children: <Widget>[
      _Screen(
        child: DabblerNavigationActivity(
          presentation: DabblerNavigationActivityPresentation.ring,
          label: 'upload',
          value: _pct,
          icon: 'gallery',
          bar: _bar,
          safeArea: false,
        ),
      ),
      Wrap(
        spacing: DabblerSpacing.space3,
        children: <Widget>[
          DabblerButton(
            label: '−15%',
            tone: DabblerButtonTone.neutral,
            size: DabblerButtonSize.small,
            onPressed: () =>
                setState(() => _pct = (_pct - _step).clamp(0.0, 1.0)),
          ),
          DabblerButton(
            label: '+15%',
            tone: DabblerButtonTone.neutral,
            size: DabblerButtonSize.small,
            onPressed: () =>
                setState(() => _pct = (_pct + _step).clamp(0.0, 1.0)),
          ),
        ],
      ),
    ],
  );
}

// ── NavigationStatus ─────────────────────────────────────────────────────────

/// The sequences' demonstration cadences — how long the pretend work takes.
/// Gallery values built from the motion scale, not component timings: the
/// component's own hold, growth and dismissal come from the component.
abstract final class _Demo {
  /// How long a pretend operation runs before it resolves.
  static const Duration work = DabblerMotion.ambientLoop;

  /// The interval between pretend progress ticks.
  static const Duration tick = DabblerMotion.delaySettle;

  /// One pretend progress step, as a fraction.
  static const double step = 0.25;
}

/// One step of a scripted sequence: a payload, and how long to stay on it.
/// A null [stay] waits for the surface — its action, its dismiss or its own
/// timeout — before the next step.
class _Step {
  const _Step(this.payload, {this.stay});

  final DabblerNavigationStatusPayload? payload;
  final Duration? stay;
}

Widget _statusSequences(BuildContext context) => GalleryWrap(
  children: <Widget>[
    GallerySpecimen(
      label: 'processing → success',
      child: _Sequence(
        steps: (VoidCallback next, VoidCallback stop) => const <_Step>[
          _Step(
            DabblerNavigationStatusActivity(
              presentation: DabblerNavigationActivityPresentation.spinnerLabel,
              label: 'joining game',
            ),
            stay: _Demo.work,
          ),
          _Step(
            DabblerNavigationStatusFeedback(
              DabblerNavigationFeedbackData(
                tone: DabblerToastTone.success,
                message: 'joined game',
              ),
            ),
          ),
        ],
      ),
    ),
    GallerySpecimen(
      label: 'processing → error + retry → processing → success',
      child: _Sequence(
        steps: (VoidCallback next, VoidCallback stop) => <_Step>[
          const _Step(
            DabblerNavigationStatusActivity(label: 'joining'),
            stay: _Demo.work,
          ),
          _Step(
            DabblerNavigationStatusFeedback(
              DabblerNavigationFeedbackData(
                tone: DabblerToastTone.error,
                message: "couldn't join",
                // Sticky until the retry: the user decides.
                duration: DabblerToastSpec.sticky,
                action: DabblerToastAction(label: 'retry', onPressed: next),
              ),
            ),
          ),
          const _Step(
            DabblerNavigationStatusActivity(
              presentation: DabblerNavigationActivityPresentation.spinnerLabel,
              label: 'joining game',
            ),
            stay: _Demo.work,
          ),
          const _Step(
            DabblerNavigationStatusFeedback(
              DabblerNavigationFeedbackData(
                tone: DabblerToastTone.success,
                message: 'joined game',
              ),
            ),
          ),
        ],
      ),
    ),
    GallerySpecimen(
      label: 'progress 0 → 100 → success, with cancel',
      child: _Sequence(
        steps: (VoidCallback next, VoidCallback stop) {
          final DabblerToastAction cancel = DabblerToastAction(
            label: 'cancel',
            onPressed: stop,
          );
          return <_Step>[
            for (double v = 0; v <= 1; v += _Demo.step)
              _Step(
                DabblerNavigationStatusActivity(
                  presentation: DabblerNavigationActivityPresentation.progress,
                  label: 'uploading',
                  value: v,
                  action: cancel,
                ),
                stay: _Demo.tick,
              ),
            const _Step(
              DabblerNavigationStatusFeedback(
                DabblerNavigationFeedbackData(
                  tone: DabblerToastTone.success,
                  message: 'photos uploaded',
                ),
              ),
            ),
          ];
        },
      ),
    ),
    GallerySpecimen(
      label: 'information · sticky banner, dismissed by the user (RTL)',
      child: _Sequence(
        rtl: true,
        steps: (VoidCallback next, VoidCallback stop) => const <_Step>[
          _Step(
            DabblerNavigationStatusFeedback(
              DabblerNavigationFeedbackData(
                title: 'new season starting',
                message: 'fixtures for the winter league are open.',
                dismissible: true,
              ),
              presentation: DabblerNavigationFeedbackPresentation.banner,
            ),
          ),
        ],
      ),
    ),
  ],
);

/// A screen running one scripted sequence on a single
/// [DabblerNavigationStatus], once on mount and again on *replay*; under it,
/// how the last payload ended.
class _Sequence extends StatefulWidget {
  const _Sequence({required this.steps, this.rtl = false});

  /// The script; `next` advances it (a retry's `onPressed`) and `stop` ends
  /// it (a cancel's).
  final List<_Step> Function(VoidCallback next, VoidCallback stop) steps;
  final bool rtl;

  @override
  State<_Sequence> createState() => _SequenceState();
}

class _SequenceState extends State<_Sequence> {
  late List<_Step> _steps = widget.steps(_next, _stop);
  int _at = -1;
  DabblerNavigationStatusEndReason? _ended;
  Timer? _timer;

  DabblerNavigationStatusPayload? get _payload =>
      _at >= 0 && _at < _steps.length ? _steps[_at].payload : null;

  @override
  void initState() {
    super.initState();
    _go(0);
  }

  void _go(int i) {
    _timer?.cancel();
    _timer = null;
    _at = i;
    final Duration? stay = i < _steps.length ? _steps[i].stay : null;
    if (stay != null) _timer = Timer(stay, _next);
  }

  void _next() {
    if (!mounted) return;
    setState(() => _go(_at + 1));
  }

  void _stop() {
    if (!mounted) return;
    setState(() => _go(_steps.length));
  }

  void _replay() {
    setState(() {
      _steps = widget.steps(_next, _stop);
      _ended = null;
      _go(0);
    });
  }

  void _onDone(DabblerNavigationStatusEndReason reason) {
    if (!mounted) return;
    setState(() {
      _ended = reason;
      // A retry or a cancel has already moved the script; a timeout or a
      // dismiss moves it on.
      if (reason != DabblerNavigationStatusEndReason.action &&
          reason != DabblerNavigationStatusEndReason.replaced) {
        _go(_at + 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: DabblerSpacing.space3,
      children: <Widget>[
        _Screen(
          rtl: widget.rtl,
          child: DabblerNavigationStatus(
            payload: _payload,
            onDone: _onDone,
            bar: _bar,
            safeArea: false,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: DabblerSpacing.space3,
          children: <Widget>[
            DabblerButton(
              label: 'replay',
              tone: DabblerButtonTone.neutral,
              size: DabblerButtonSize.small,
              onPressed: _replay,
            ),
            Text(
              _ended == null ? 'running' : 'ended · ${_ended!.name}',
              style: DabblerType.caption1
                  .resolveForDirection(Directionality.of(context))
                  .copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
