import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_neutral_status.dart';
import '../tokens/dabbler_type.dart';

/// The tones a [DabblerToast] can take, transcribed from `ToastTone` in
/// `components/feedback/Toast.d.ts`.
///
/// Four of the five are the semantic statuses of DS-102's
/// [DabblerStatusTone]. The fifth, [neutral], is **not** a status: the design
/// source's `statusTones.neutral` entry
/// (`components/foundations/overlay.jsx:161`) resolves to `--surface-card`,
/// `--ink` and `--outline-card` — the ordinary card roles — and has no
/// `--color-status-*` triple. `Toast.prompt.md` states the same rule in words:
/// *"`neutral` paints `--surface-card` + `--ink` with the standard
/// `--outline-card` hairline."* It therefore cannot be a member of
/// [DabblerStatusTone]; it is carried here instead and [status] returns `null`
/// for it.
///
/// This mirrors `DabblerBannerTone` in `banner.dart` deliberately — the two
/// components resolve colour from exactly the same four roles, and DS-405
/// established that resolution. They are separate enums because they are
/// separate public APIs with separate defaults (Banner defaults to `info`,
/// Toast to `neutral`), not because the tone model differs.
enum DabblerToastTone {
  /// Card surface, primary ink, card outline. Carries no status meaning.
  ///
  /// The source's default (`Toast.jsx:77`, `Toast.prompt.md` props table).
  neutral(null),

  /// `--color-status-success-*`.
  success(DabblerStatusTone.success),

  /// `--color-status-warning-*`.
  warning(DabblerStatusTone.warning),

  /// `--color-status-error-*`.
  error(DabblerStatusTone.error),

  /// `--color-status-info-*`.
  info(DabblerStatusTone.info);

  const DabblerToastTone(this.status);

  /// The DS-102 status tone this maps onto, or `null` for [neutral].
  final DabblerStatusTone? status;

  /// The tone's default Iconsax glyph, from `statusTones`
  /// (`components/foundations/overlay.jsx:161-166`).
  String get glyph => switch (this) {
        DabblerToastTone.success => 'tick-circle',
        DabblerToastTone.warning => 'warning-2',
        DabblerToastTone.error => 'danger',
        DabblerToastTone.info || DabblerToastTone.neutral => 'info-circle',
      };
}

/// Passed as a toast's `icon` to draw no leading glyph at all — the source's
/// explicit `icon={null}`, which is distinct from omitting the prop.
const Widget dabblerToastNoIcon = SizedBox.shrink();

/// The label and callback of a [DabblerToast]'s trailing action.
///
/// Transcribed from `ToastAction` in `components/feedback/Toast.d.ts`.
@immutable
class DabblerToastAction {
  /// Creates a toast action.
  const DabblerToastAction({required this.label, this.onPressed});

  /// The button's text.
  final String label;

  /// Called when the button is pressed, immediately before the toast is
  /// dismissed — the source fires `action.onPress()` and then `onDismiss()`
  /// from the same handler (`Toast.jsx:129`). A null callback leaves the
  /// button rendered but inert, matching the source's optional `onPress`.
  final VoidCallback? onPressed;
}

/// Everything needed to raise one toast — the Dart form of the source's
/// `ToastOptions` (`components/feedback/Toast.d.ts`).
///
/// Passed to [DabblerToastController.show]. It is a value, not a widget, so a
/// caller with no [BuildContext] of its own can describe a toast and hand it
/// to the controller.
@immutable
class DabblerToastSpec {
  /// Describes one toast.
  const DabblerToastSpec({
    required this.message,
    this.id,
    this.tone = DabblerToastTone.neutral,
    this.action,
    this.duration = defaultDuration,
    this.icon,
  });

  /// `duration` default `4000`ms (`Toast.prompt.md` props table).
  static const Duration defaultDuration = Duration(milliseconds: 4000);

  /// `0` = sticky (`Toast.d.ts`: *"ms before auto-dismiss. Default 4000.
  /// `0` = sticky."*). [Duration.zero] is the Dart spelling of that `0`.
  static const Duration sticky = Duration.zero;

  /// The message. The source types this `ReactNode`; the Flutter cut takes a
  /// [String], as `DabblerBanner.message` does, because every call site in the
  /// specimens passes a plain string and a widget slot here would have to
  /// carry its own text style.
  final String message;

  /// An explicit identity for this toast, as `show({ id })` accepts. When
  /// null the controller assigns a sequential one.
  final String? id;

  /// The tone. Default [DabblerToastTone.neutral].
  final DabblerToastTone tone;

  /// The trailing action — *"reporting a recoverable failure with a retry"*.
  final DabblerToastAction? action;

  /// Time before auto-dismiss. [Duration.zero] ([sticky]) never auto-dismisses.
  final Duration duration;

  /// The leading glyph, in an 18×18 ([DabblerSizing.iconSm]) slot — the
  /// source's *"Iconsax bold at 18px"*.
  ///
  /// Defaults to the tone's own glyph — [DabblerToastTone.glyph], drawn
  /// `bold` at 18 — exactly as `Toast.jsx:104-105` does.
  ///
  /// This was `null` until this pass, on a comment saying DS-300 had yet to
  /// land `DabblerIcon`. DS-300 shipped, so every toast in the cut rendered
  /// without the glyph the design always draws. Pass [dabblerToastNoIcon] to
  /// suppress it.
  final Widget? icon;
}

/// One queued toast: a [DabblerToastSpec] plus the identity the controller
/// gave it.
@immutable
class DabblerToastEntry {
  /// Creates an entry. Normally built by [DabblerToastController.show].
  const DabblerToastEntry({required this.id, required this.spec});

  /// The identity [DabblerToastController.dismiss] takes.
  final String id;

  /// What to show.
  final DabblerToastSpec spec;
}

/// The toast queue — the state machine behind [DabblerToastProvider].
///
/// Transcribed from `ToastProvider`'s state in `components/feedback/Toast.jsx`
/// and the `Stacking` section of `Toast.prompt.md`:
///
/// > Maximum 3 visible, **newest at the bottom**, 9px gap. A fourth `show()`
/// > drops the oldest.
///
/// which is the source's `setItems((list) => [...list, item].slice(-max))`
/// (`Toast.jsx:47`). [visible] is therefore in oldest-to-newest order and the
/// viewport paints it top to bottom, putting the newest at the bottom.
///
/// It is a plain [ChangeNotifier] and owns no widgets, so the cap, the drop
/// order and dismissal can be exercised — and are, in
/// `test/feedback/toast_test.dart` — without building anything.
class DabblerToastController extends ChangeNotifier {
  /// Creates a queue capped at [max].
  DabblerToastController({this.max = defaultMax})
      : assert(max >= 1, 'a toast queue with no room shows nothing');

  /// `ToastProvider`: `max` (default 3) — `Toast.prompt.md`, `Toast.d.ts`.
  static const int defaultMax = 3;

  /// The most toasts visible at once. A [show] past this drops the oldest.
  final int max;

  final List<DabblerToastEntry> _items = <DabblerToastEntry>[];
  int _seq = 0;
  bool _disposed = false;

  /// The queue, oldest first. Never longer than [max].
  List<DabblerToastEntry> get visible => List<DabblerToastEntry>.unmodifiable(_items);

  /// Raises a toast and returns its id.
  ///
  /// The new toast is appended, then the queue is trimmed from the front to
  /// [max]. A fourth toast while three are showing drops the oldest and leaves
  /// the new one visible.
  String show(DabblerToastSpec spec) {
    _seq += 1;
    final String id = spec.id ?? 't$_seq';
    _items.add(DabblerToastEntry(id: id, spec: spec));
    if (_items.length > max) {
      _items.removeRange(0, _items.length - max);
    }
    notifyListeners();
    return id;
  }

  /// Removes the toast with [id]. Unknown ids are ignored, as the source's
  /// `filter` ignores them.
  void dismiss(String id) {
    final int before = _items.length;
    _items.removeWhere((DabblerToastEntry e) => e.id == id);
    if (_items.length != before) {
      notifyListeners();
    }
  }

  /// Removes every toast.
  void clear() {
    if (_items.isEmpty) {
      return;
    }
    _items.clear();
    notifyListeners();
  }

  /// Whether [dispose] has run. Read by [DabblerToasts], which holds a
  /// reference that outlives the widget tree in a hot reload.
  bool get isDisposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    _items.clear();
    super.dispose();
  }
}

/// Imperative access to the mounted [DabblerToastProvider], for callers with
/// no [BuildContext] — a repository, a controller, an error handler.
///
/// Transcribed from the source's `Toasts` escape hatch (`Toast.jsx:19-30`),
/// including its behaviour with nothing mounted: it warns and returns `null`
/// rather than throwing, because a toast is never load-bearing.
abstract final class DabblerToasts {
  static DabblerToastController? _live;

  /// The mounted provider's controller, or null if none is mounted.
  static DabblerToastController? get controller =>
      (_live != null && !_live!.isDisposed) ? _live : null;

  /// Raises a toast, or returns null with a debug warning if no
  /// [DabblerToastProvider] is mounted.
  static String? show(DabblerToastSpec spec) {
    final DabblerToastController? live = controller;
    if (live == null) {
      assert(() {
        debugPrint(
          '[Dabbler DS] DabblerToasts.show() called with no '
          'DabblerToastProvider mounted.',
        );
        return true;
      }());
      return null;
    }
    return live.show(spec);
  }

  /// Dismisses a toast by id, if a provider is mounted.
  static void dismiss(String id) => controller?.dismiss(id);

  /// Clears every toast, if a provider is mounted.
  static void clear() => controller?.clear();
}

/// Mounts the toast viewport and the queue that feeds it.
///
/// Transcribed from `ToastProvider` in `components/feedback/Toast.jsx`.
/// `Toast.prompt.md`'s composition rules: *"Exactly one `ToastProvider` per
/// app, mounted above the router"*, and *"a screen never renders its own toast
/// container or positions a toast itself"* — so this wraps the app, and screens
/// call [DabblerToastProvider.of].
///
/// ## The viewport
///
/// Bottom-anchored and centred, full width minus a [DabblerSpacing.space4]
/// (12) gutter up to 420, sitting [DabblerSpacing.space4] above
/// [MediaQueryData.padding]'s bottom inset — the source's
/// `bottom: calc(var(--space-4) + env(safe-area-inset-bottom, 0px))` — so it
/// clears the home indicator. Toasts stack with a [DabblerSpacing.space3] (9)
/// gap, newest at the bottom.
///
/// Layering is the [Stack] this widget owns, which is the Flutter equivalent
/// of the source's `--z-toast`: no descendant ever sets its own.
///
/// The viewport itself is not hit-testable ([IgnorePointer] over the gaps,
/// the source's `pointerEvents: 'none'`), so the app behind it stays usable;
/// each toast re-enables hits for itself.
class DabblerToastProvider extends StatefulWidget {
  /// Wraps [child] — normally the whole app — in the toast viewport.
  const DabblerToastProvider({
    super.key,
    required this.child,
    this.max = DabblerToastController.defaultMax,
    this.controller,
  });

  /// The app.
  final Widget child;

  /// The concurrency cap. Ignored when [controller] is supplied, which carries
  /// its own.
  final int max;

  /// A queue to adopt instead of creating one. The caller that supplies it
  /// also disposes it.
  final DabblerToastController? controller;

  /// Identifies the viewport column, so a test can measure its geometry.
  static const Key viewportKey = Key('DabblerToastProvider.viewport');

  /// The nearest provider's queue.
  ///
  /// Throws in debug if there is none — a `show()` that silently does nothing
  /// is the failure mode this assert exists to catch. Use [maybeOf] where the
  /// provider is genuinely optional.
  static DabblerToastController of(BuildContext context) {
    final DabblerToastController? found = maybeOf(context);
    assert(
      found != null,
      'No DabblerToastProvider above this context. Mount one above the router.',
    );
    return found!;
  }

  /// The nearest provider's queue, or null.
  static DabblerToastController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_DabblerToastScope>()
      ?.controller;

  @override
  State<DabblerToastProvider> createState() => _DabblerToastProviderState();
}

class _DabblerToastProviderState extends State<DabblerToastProvider> {
  late DabblerToastController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _adopt(widget.controller ?? DabblerToastController(max: widget.max),
        owned: widget.controller == null);
  }

  void _adopt(DabblerToastController next, {required bool owned}) {
    _controller = next;
    _ownsController = owned;
    _controller.addListener(_onQueueChanged);
    DabblerToasts._live = _controller;
  }

  void _release() {
    _controller.removeListener(_onQueueChanged);
    if (identical(DabblerToasts._live, _controller)) {
      DabblerToasts._live = null;
    }
    if (_ownsController) {
      _controller.dispose();
    }
  }

  void _onQueueChanged() => setState(() {});

  @override
  void didUpdateWidget(DabblerToastProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool changed = widget.controller != oldWidget.controller ||
        (widget.controller == null && widget.max != oldWidget.max);
    if (changed) {
      _release();
      _adopt(widget.controller ?? DabblerToastController(max: widget.max),
          owned: widget.controller == null);
    }
  }

  @override
  void dispose() {
    _release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<DabblerToastEntry> items = _controller.visible;

    return _DabblerToastScope(
      controller: _controller,
      // The queue is state, not identity: a rebuild must reach dependents
      // whenever the list changes, so the notification predicate keys on it.
      itemIds: items.map((DabblerToastEntry e) => e.id).toList(growable: false),
      child: Stack(
        children: <Widget>[
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: Padding(
                // `bottom: calc(var(--space-4) + env(safe-area-inset-bottom))`
                // (Toast.jsx:63) — ADDITIVE, so the toast clears the home
                // indicator by the full gutter. SafeArea would take the
                // maximum of the two instead, which is a different rule.
                padding: EdgeInsets.only(
                  bottom: DabblerSpacing.space4 +
                      MediaQuery.paddingOf(context).bottom,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DabblerSpacing.space4,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _DabblerToastMetrics.maxWidth,
                      ),
                      child: Column(
                        key: DabblerToastProvider.viewportKey,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          for (int i = 0; i < items.length; i++) ...<Widget>[
                            if (i > 0)
                              const SizedBox(height: DabblerSpacing.space3),
                            // Re-enable hits per toast; the gaps stay inert.
                            IgnorePointer(
                              ignoring: false,
                              child: DabblerToast(
                                key: ValueKey<String>(items[i].id),
                                tone: items[i].spec.tone,
                                message: items[i].spec.message,
                                action: items[i].spec.action,
                                duration: items[i].spec.duration,
                                icon: items[i].spec.icon,
                                onDismiss: () => _controller.dismiss(items[i].id),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DabblerToastScope extends InheritedWidget {
  const _DabblerToastScope({
    required this.controller,
    required this.itemIds,
    required super.child,
  });

  final DabblerToastController controller;
  final List<String> itemIds;

  @override
  bool updateShouldNotify(_DabblerToastScope oldWidget) =>
      !identical(controller, oldWidget.controller) ||
      !listEquals(itemIds, oldWidget.itemIds);
}

/// The measurements `Toast.prompt.md`'s `Visual` section gives that are not
/// already tokens.
abstract final class _DabblerToastMetrics {
  /// *"max width 420px"*. Not on the spacing ramp and not a sizing token —
  /// it is this component's own maximum measure, so it is named here rather
  /// than invented at the call site.
  static const double maxWidth = 420;

  /// *"Enter and exit animate `opacity` and `translateY(9px)` only"*. 9 is
  /// [DabblerSpacing.space3]; it is the travel of the entry slide, expressed
  /// as a fraction of the toast's own height by [SlideTransition], so it is
  /// converted where it is used.
  static const double enterTravel = DabblerSpacing.space3;
}

/// Toast — transient confirmation of something that already happened.
///
/// Transcribed from `components/feedback/Toast.jsx`, `Toast.d.ts` and
/// `Toast.prompt.md`: *"joined game"*, *"link copied"*, *"game saved"*. It
/// fires, is readable, and disappears. A persistent condition is a
/// `DabblerBanner`; a decision is a Dialog; one field's validation is a
/// TextField `errorText`.
///
/// **Prefer [DabblerToastProvider.of] + [DabblerToastController.show].** This
/// widget is presentational — it renders one toast and owns its dismissal
/// timer, nothing more. A screen must never position one itself
/// (`Toast.prompt.md`, Composition rules).
///
/// ## Colour comes from the tone, never from a literal
///
/// Exactly the four roles DS-405 resolved for `DabblerBanner`: the fill is the
/// tone's [DabblerStatusColor.surface], the ink — message, glyph, action
/// label — is its [DabblerStatusColor.strong], and the hairline is that same
/// strong colour at **20%**, which is what the source's `statusHairline`
/// computes (`color-mix(in srgb, <strong> 20%, transparent)`,
/// `components/foundations/overlay.jsx:169-173`).
/// [DabblerToastTone.neutral] resolves to [DabblerColors.surfaceCard],
/// [DabblerColors.textPrimary] and [DabblerColors.borderDefault].
///
/// ## Flat
///
/// Fill, 1px hairline, [DabblerRadius.lg]. *"No shadow, no gradient, no
/// blur."*
///
/// ## Dismissal timer
///
/// [duration] arms a timer; [DabblerToastSpec.sticky] ([Duration.zero]) never
/// arms one. Pointer hover **and** focus pause it, and it re-arms on
/// leave/blur, *"so keyboard users are not raced"*. The timer is cancelled in
/// [State.dispose], so a toast removed from the queue — by dismissal, by a
/// fourth toast dropping it, or by the provider unmounting — can never fire
/// [onDismiss] afterwards. `test/feedback/toast_test.dart` asserts that.
///
/// ## Motion
///
/// Entry animates `opacity` and a [_DabblerToastMetrics.enterTravel] (9)
/// downward-origin translate over [DabblerMotion.base] with
/// [DabblerMotion.easeOut] — no scale, no shadow, no blur. Under reduced
/// motion ([MediaQueryData.disableAnimations]) the translate is dropped and
/// only opacity animates, which is the source's `prefersReducedMotion()`
/// branch and the same rule `skeleton.dart` follows.
///
/// **Deviation, written down:** the source describes an *exit* animation, but
/// `ToastProvider` removes the item with a plain `setItems(list.filter(...))`
/// (`Toast.jsx:37-39`), which unmounts the node immediately — the exit
/// transition never runs there either. This cut is faithful to the behaviour:
/// entry animates, removal is immediate. Animating removal would require the
/// queue to keep dismissed entries alive, which would change what "max 3
/// concurrent" counts. Flagged to the orchestrator rather than decided here.
///
/// ## Accessibility
///
/// `role="status"` + `aria-live="polite"` becomes [Semantics.liveRegion] on a
/// semantics container, so assistive technology announces the toast without
/// interrupting. The action button is a real button with the shared
/// [DabblerFocusRing], keyboard activation, and a
/// [DabblerSizing.touchTargetMin] (45) target measured by the test.
class DabblerToast extends StatefulWidget {
  /// Creates one presentational toast.
  const DabblerToast({
    super.key,
    required this.message,
    this.tone = DabblerToastTone.neutral,
    this.action,
    this.duration = DabblerToastSpec.defaultDuration,
    this.icon,
    this.onDismiss,
  });

  /// Creates one presentational toast from a [DabblerToastSpec].
  DabblerToast.fromSpec(DabblerToastSpec spec, {super.key, this.onDismiss})
      : message = spec.message,
        tone = spec.tone,
        action = spec.action,
        duration = spec.duration,
        icon = spec.icon;

  /// The message.
  final String message;

  /// The tone. Default [DabblerToastTone.neutral], as in `Toast.jsx:77`.
  final DabblerToastTone tone;

  /// The trailing action.
  final DabblerToastAction? action;

  /// Time before [onDismiss] fires. [Duration.zero] is sticky.
  final Duration duration;

  /// The leading glyph, in an 18×18 slot. See [DabblerToastSpec.icon] for why
  /// there is no default glyph yet.
  final Widget? icon;

  /// Called when the timer elapses or the action is pressed. The toast does
  /// **not** remove itself — the queue owns that.
  final VoidCallback? onDismiss;

  /// Identifies the action button's touch target, so a test can measure the
  /// rendered box rather than trust a comment.
  static const Key actionTargetKey = Key('DabblerToast.actionTarget');

  @override
  State<DabblerToast> createState() => _DabblerToastState();
}

class _DabblerToastState extends State<DabblerToast>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  bool _hovered = false;
  bool _focused = false;
  late final AnimationController _entry;
  late final FocusNode _actionNode;

  bool get _paused => _hovered || _focused;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(vsync: this, duration: DabblerMotion.base);
    _actionNode = FocusNode(debugLabel: 'DabblerToast.action')
      ..onKeyEvent = _onActionKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The source starts at opacity 0 and flips on the next frame
      // (`requestAnimationFrame`, Toast.jsx:92) so the transition has a
      // starting value to animate from.
      if (mounted) {
        _entry.forward();
      }
    });
    _arm();
  }

  @override
  void didUpdateWidget(DabblerToast oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _arm();
    }
  }

  /// Starts, or restarts, the dismissal timer. A zero [DabblerToast.duration]
  /// or a paused toast arms nothing — the source's `arm()` (`Toast.jsx:95`).
  void _arm() {
    _timer?.cancel();
    _timer = null;
    if (widget.duration <= Duration.zero || _paused) {
      return;
    }
    _timer = Timer(widget.duration, () {
      _timer = null;
      widget.onDismiss?.call();
    });
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
  }

  void _setHovered(bool value) {
    if (_hovered == value) {
      return;
    }
    _hovered = value;
    value ? _pause() : _arm();
  }

  void _setFocused(bool value) {
    if (_focused == value) {
      return;
    }
    _focused = value;
    value ? _pause() : _arm();
  }

  KeyEventResult _onActionKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final bool isActivator = event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter ||
        event.logicalKey == LogicalKeyboardKey.space;
    if (!isActivator) {
      return KeyEventResult.ignored;
    }
    _invokeAction();
    return KeyEventResult.handled;
  }

  /// `onClick={() => { action.onPress?.(); onDismiss?.(); }}` — Toast.jsx:129.
  void _invokeAction() {
    widget.action?.onPressed?.call();
    widget.onDismiss?.call();
  }

  @override
  void dispose() {
    // A toast that has left the tree must not fire onDismiss afterwards.
    _timer?.cancel();
    _timer = null;
    _actionNode.dispose();
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final DabblerStatusTone? status = widget.tone.status;
    final DabblerStatusColor? resolved =
        status == null ? null : colors.status(status);

    // `statusTones` / `statusHairline` in overlay.jsx:160-173. The neutral
    // triple is not re-derived here: it is the one shared definition
    // [dabblerNeutralStatus], which Badge composes too (KAN-266).
    final DabblerStatusColor tone = resolved ?? dabblerNeutralStatus(colors);
    final Color surface = tone.surface;
    final Color ink = tone.strong;
    final Color hairline = resolved == null
        ? tone.base
        : tone.strong.withValues(alpha: 0.20);

    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final TextDirection direction = Directionality.of(context);

    // `icon !== undefined ? icon : <Icon name={t.icon} type="bold" size={18} />`
    // (`Toast.jsx:104-105`).
    final Widget? glyph = identical(widget.icon, dabblerToastNoIcon)
        ? null
        : widget.icon ??
            DabblerIcon(
              widget.tone.glyph,
              weight: DabblerIconWeight.bold,
              size: DabblerSizing.iconSm,
              color: ink,
            );

    final Widget body = Container(
      // `width: '100%', maxWidth: 420` (`Toast.jsx:115`). The previous cut left
      // the width unconstrained and the row at `MainAxisSize.min`, so a toast
      // shrank to its message instead of filling its column the way the
      // specimen draws it.
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: DabblerSizing.touchTargetMin,
        maxWidth: _DabblerToastMetrics.maxWidth,
      ),
      // `padding: '12px 15px'` — Toast.jsx:117 — which is space4 / space5.
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: DabblerSpacing.space4,
        horizontal: DabblerSpacing.space5,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: DabblerRadius.lgAll,
        border: Border.all(
          color: hairline,
          width: DabblerSizing.borderDefault,
        ),
        // No boxShadow and no gradient: the system is flat.
      ),
      child: Row(
        children: <Widget>[
          if (glyph != null) ...<Widget>[
            SizedBox(
              width: DabblerSizing.iconSm,
              height: DabblerSizing.iconSm,
              child: IconTheme.merge(
                data: IconThemeData(color: ink, size: DabblerSizing.iconSm),
                child: glyph,
              ),
            ),
            // `gap: var(--space-3)` on the row, Toast.jsx:114.
            const SizedBox(width: DabblerSpacing.space3),
          ],
          Expanded(
            child: Text(
              widget.message,
              style: DabblerType.subheadline
                  .resolveForDirection(direction)
                  .copyWith(color: ink),
            ),
          ),
          if (widget.action != null) ...<Widget>[
            const SizedBox(width: DabblerSpacing.space3),
            _buildAction(context, ink: ink),
          ],
        ],
      ),
    );

    final Widget announced = Semantics(
      container: true,
      // role="status" + aria-live="polite".
      liveRegion: true,
      child: body,
    );

    final Widget interactive = MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: Focus(
        // Reports focus anywhere inside — the action button — without taking
        // any of its own or appearing in the traversal order.
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: _setFocused,
        child: announced,
      ),
    );

    final Animation<double> opacity = CurvedAnimation(
      parent: _entry,
      curve: DabblerMotion.easeOut,
    );

    if (reduceMotion) {
      // Only opacity animates; the translate is dropped.
      return FadeTransition(opacity: opacity, child: interactive);
    }

    return FadeTransition(
      opacity: opacity,
      child: AnimatedBuilder(
        animation: opacity,
        builder: (BuildContext context, Widget? child) => Transform.translate(
          offset: Offset(
            0,
            _DabblerToastMetrics.enterTravel * (1 - opacity.value),
          ),
          child: child,
        ),
        child: interactive,
      ),
    );
  }

  /// The trailing action: at least [DabblerSizing.touchTargetMin] on both
  /// axes, inline padding [DabblerSpacing.space2], the tone's ink at weight
  /// 600, the shared focus ring and the shared press scale.
  Widget _buildAction(BuildContext context, {required Color ink}) {
    final DabblerToastAction action = widget.action!;
    final TextStyle style = DabblerType.subheadline
        .resolveForDirection(Directionality.of(context))
        .copyWith(color: ink, fontWeight: DabblerType.semibold);

    return Semantics(
      container: true,
      button: true,
      enabled: action.onPressed != null,
      label: action.label,
      // The GestureDetector publishes a tap action of its own; without
      // excludeSemantics the two nodes sit side by side and the label never
      // reaches the tappable one.
      excludeSemantics: true,
      onTap: _invokeAction,
      child: DabblerFocusRing(
        focusNode: _actionNode,
        borderRadius: DabblerRadius.mdAll,
        child: DabblerPressScale.gesture(
          child: GestureDetector(
            key: DabblerToast.actionTargetKey,
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
              // Center with both factors set: the target centres its label
              // WITHOUT growing to the incoming maximum width, which a bare
              // `alignment:` on the Container would do.
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(action.label, style: style),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
