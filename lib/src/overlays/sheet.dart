import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../interaction/scrim.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// How a [DabblerSheet] presents itself, transcribed from the source's
/// `presentation` prop (`components/overlays/Sheet.d.ts:21`).
enum DabblerSheetPresentation {
  /// Owns the viewport: scrim, bottom alignment, Escape and focus capture.
  modal,

  /// The panel only — no scrim, no positioning. The source restricts this to
  /// *"documentation cards and embedded previews only, never for a live
  /// modal"* (`Sheet.prompt.md:76`).
  inline,
}

/// Sheet — the canonical bottom sheet.
///
/// Transcribed from `components/overlays/Sheet.jsx`, `Sheet.d.ts` and
/// `Sheet.prompt.md`. It is the phone-width presentation of a modal (its
/// wide-viewport counterpart is Dialog, DS-702) and the container Menu
/// (DS-700) falls back to below 480px.
///
/// ## What it composes, and what it does not restate
///
/// The wash is DS-200's [DabblerScrim] and nothing here re-declares its
/// colour, its opacity or its fade — `Sheet.prompt.md:34` and
/// `Dialog.prompt.md:34` name the same `--color-scrim` token precisely so
/// there is one scrim, not three. Everything the scrim documents itself as
/// *not* doing — the panel, the positioning, the entry and exit transition,
/// drag-to-dismiss, Escape and focus capture — is owned here.
///
/// ## Flat
///
/// Opaque [DabblerColors.surfaceCard] fill, a 1px [DabblerColors.borderDefault]
/// hairline (`--outline-card`), top corners [DabblerRadius.xl], no shadow:
/// *"the scrim separates it"* (`Sheet.jsx:9`). [DabblerElevation.dialogFor] is
/// reserved for Dialog and is deliberately not referenced.
///
/// ## Detents and dragging
///
/// [detents] are fractions of the viewport height, sorted ascending
/// (`Sheet.jsx:30`). Dragging the handle moves the panel with a
/// [Transform.translate] and nothing else — the source is explicit that the
/// gesture must use *"`transform` only — never height, top or margin"*
/// (`Sheet.prompt.md:58`) so it stays off the layout path. On release the
/// panel snaps to the nearest detent; dragging well past the smallest detent
/// dismisses when [dismissible]. Both thresholds are transcribed:
/// [dragResistance] (24) and [dismissFraction] (0.55).
///
/// ## Dismissal
///
/// Three routes, all gated on [dismissible]: `Escape`, a press on the scrim,
/// and the close affordance. The close button is
/// [DabblerSizing.touchTargetMin] (45) square — above the 44pt floor — and is
/// a **visible** affordance, which is a deliberate addition to the source,
/// whose web presentation relies on the pointer alone. The drag handle's row
/// is the same 45 tall (`Sheet.jsx:104`).
///
/// ## Route integration
///
/// [showDabblerSheet] pushes this as a [PopupRoute] and is what application
/// code should normally call; the widget is public for inline previews,
/// gallery entries, and for DS-700's Menu, which needs to compose the panel
/// itself rather than push a route.
class DabblerSheet extends StatefulWidget {
  /// Creates a sheet.
  const DabblerSheet({
    super.key,
    this.open = true,
    this.onClose,
    this.detents = const <double>[0.5],
    this.snapTo,
    this.dragHandle = true,
    this.title,
    this.footer,
    this.child,
    this.dismissible = true,
    this.presentation = DabblerSheetPresentation.modal,
    this.closeLabel = defaultCloseLabel,
    this.scrimLabel = defaultScrimLabel,
  });

  /// The default English semantics label for the close affordance. The package
  /// ships no localised strings; a host app passes its own.
  static const String defaultCloseLabel = 'Close';

  /// The default English semantics label for the scrim's dismiss gesture.
  static const String defaultScrimLabel = 'Dismiss';

  /// `max-width: 520` (`Sheet.jsx:80`). Full width below it, centred above.
  static const double maxPanelWidth = 520;

  /// `max-height: 96dvh` (`Sheet.jsx:82`), as a fraction.
  static const double maxHeightFraction = 0.96;

  /// The 40×4 grab bar (`Sheet.jsx:112`). Its radius is [DabblerRadius.pill].
  static const double handleWidth = 40;

  /// The grab bar's thickness — `height: 4` (`Sheet.jsx:112`).
  static const double handleHeight = 4;

  /// Upward drag is clamped to `Math.max(-24, …)` (`Sheet.jsx:60`): the panel
  /// resists being dragged above its detent instead of growing.
  static const double dragResistance = 24;

  /// A release below `stops[0] * 0.55` dismisses (`Sheet.jsx:68`).
  static const double dismissFraction = 0.55;

  /// Whether the sheet is shown. Toggling it slides and fades.
  final bool open;

  /// Called on every dismissal route. A null callback leaves the sheet
  /// undismissable in practice, matching the source's optional `onClose`.
  final VoidCallback? onClose;

  /// Heights as fractions of the viewport (0–1). Default `[0.5]`.
  final List<double> detents;

  /// Index into [detents] to snap to. Controlled snapping; null uses the
  /// largest detent, as `Sheet.jsx:33` does.
  final int? snapTo;

  /// Whether the draggable grab handle is shown. Default true.
  final bool dragHandle;

  /// The title line, rendered in [DabblerType.title3].
  final String? title;

  /// Pinned footer — actions. Safe-area padded, and separated by a `--faint`
  /// hairline. `Sheet.prompt.md:79` requires actions to live here rather than
  /// at the end of the scroll area so they stay reachable at every detent.
  final Widget? footer;

  /// The scrolling body.
  final Widget? child;

  /// Whether Escape, the scrim, the close button and drag-past dismiss.
  final bool dismissible;

  /// Modal (scrim + viewport) or inline (panel only).
  final DabblerSheetPresentation presentation;

  /// Semantics label for the close affordance.
  final String closeLabel;

  /// Semantics label handed to [DabblerScrim.dismissLabel].
  final String scrimLabel;

  @override
  State<DabblerSheet> createState() => _DabblerSheetState();
}

class _DabblerSheetState extends State<DabblerSheet> {
  late List<double> _stops = _sorted(widget.detents);
  late int _index = widget.snapTo ?? _stops.length - 1;
  double _drag = 0;
  bool _dragging = false;

  static List<double> _sorted(List<double> detents) {
    final List<double> copy =
        detents.isEmpty ? <double>[0.5] : List<double>.of(detents);
    copy.sort();
    return copy;
  }

  @override
  void didUpdateWidget(DabblerSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.detents, widget.detents)) {
      _stops = _sorted(widget.detents);
      _index = math.min(_index, _stops.length - 1);
    }
    if (widget.snapTo != null && widget.snapTo != oldWidget.snapTo) {
      _index = widget.snapTo!.clamp(0, _stops.length - 1);
    }
  }

  bool get _canDismiss => widget.dismissible && widget.onClose != null;

  void _close() {
    if (_canDismiss) {
      widget.onClose!();
    }
  }

  void _onDragStart(DragStartDetails _) {
    setState(() => _dragging = true);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _drag = math.max(-DabblerSheet.dragResistance, _drag + details.delta.dy);
    });
  }

  void _onDragEnd(double panelHeight, double viewportHeight) {
    // Where the panel ended up, as a fraction of the viewport — the source's
    // `settled = (h - drag) / vh` (`Sheet.jsx:66`).
    final double settled =
        viewportHeight == 0 ? 0 : (panelHeight - _drag) / viewportHeight;
    if (_canDismiss && settled < _stops.first * DabblerSheet.dismissFraction) {
      setState(() {
        _drag = 0;
        _dragging = false;
      });
      _close();
      return;
    }
    int nearest = 0;
    for (int i = 0; i < _stops.length; i++) {
      if ((_stops[i] - settled).abs() < (_stops[nearest] - settled).abs()) {
        nearest = i;
      }
    }
    setState(() {
      _index = nearest;
      _drag = 0;
      _dragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool modal = widget.presentation == DabblerSheetPresentation.modal;
    if (!modal) {
      return _panel(context, modal: false, height: null);
    }

    final Size viewport = MediaQuery.sizeOf(context);
    final double fraction = _stops[math.min(_index, _stops.length - 1)];
    final double height = math.min(
      viewport.height * fraction,
      viewport.height * DabblerSheet.maxHeightFraction,
    );

    final bool reduceMotion = DabblerMotion.reduceMotion(context);
    final Widget panel = AnimatedSlide(
      offset: widget.open ? Offset.zero : const Offset(0, 1),
      duration: reduceMotion ? Duration.zero : DabblerMotion.slow,
      curve: DabblerMotion.easeOut,
      child: _panel(
        context,
        modal: true,
        height: height,
        viewportHeight: viewport.height,
      ),
    );

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): _close,
      },
      child: FocusScope(
        autofocus: true,
        child: DabblerScrim(
          visible: widget.open,
          onDismiss: _canDismiss ? _close : null,
          dismissLabel: widget.scrimLabel,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(ignoring: !widget.open, child: panel),
          ),
        ),
      ),
    );
  }

  Widget _panel(
    BuildContext context, {
    required bool modal,
    required double? height,
    double viewportHeight = 0,
  }) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool reduceMotion = DabblerMotion.reduceMotion(context);

    final Widget body = DecoratedBox(
      decoration: BoxDecoration(
        // `background: var(--surface-card)` (`Sheet.jsx:83`).
        color: colors.surfaceCard,
        // `1px solid var(--outline-card)`; the modal presentation drops the
        // bottom edge, which sits off-screen (`Sheet.jsx:84-85`).
        border: Border(
          top: BorderSide(
            color: colors.borderDefault,
            width: DabblerSizing.borderDefault,
          ),
          left: BorderSide(
            color: colors.borderDefault,
            width: DabblerSizing.borderDefault,
          ),
          right: BorderSide(
            color: colors.borderDefault,
            width: DabblerSizing.borderDefault,
          ),
          bottom: modal
              ? BorderSide.none
              : BorderSide(
                  color: colors.borderDefault,
                  width: DabblerSizing.borderDefault,
                ),
        ),
        // Top corners only when modal (`Sheet.jsx:86`).
        borderRadius: modal
            ? const BorderRadius.vertical(top: Radius.circular(DabblerRadius.xl))
            : DabblerRadius.xlAll,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _header(context, colors, viewportHeight),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.fromSTEB(
                DabblerSpacing.space6,
                widget.dragHandle || widget.title != null
                    ? 0
                    : DabblerSpacing.space6,
                DabblerSpacing.space6,
                DabblerSpacing.space6,
              ),
              child: widget.child ?? const SizedBox.shrink(),
            ),
          ),
          if (widget.footer != null) _footerBar(context, colors),
        ],
      ),
    );

    final Widget sized = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: DabblerSheet.maxPanelWidth),
      child: height == null ? body : SizedBox(height: height, child: body),
    );

    final Widget clipped = ClipRRect(
      borderRadius: modal
          ? const BorderRadius.vertical(top: Radius.circular(DabblerRadius.xl))
          : DabblerRadius.xlAll,
      child: sized,
    );

    if (!modal) {
      return clipped;
    }
    // The drag and the snap back are both a translation and nothing else —
    // never height, top or margin (`Sheet.prompt.md:58`). During an active
    // drag the transition is off so the panel tracks the finger; on release
    // it animates home over `--motion-slow` (`Sheet.prompt.md:69`).
    return AnimatedContainer(
      duration: _dragging || reduceMotion ? Duration.zero : DabblerMotion.slow,
      curve: DabblerMotion.easeOut,
      transform: Matrix4.translationValues(0, _drag, 0),
      child: Semantics(
        container: true,
        scopesRoute: true,
        explicitChildNodes: true,
        namesRoute: widget.title != null,
        label: widget.title,
        child: clipped,
      ),
    );
  }

  Widget _header(
    BuildContext context,
    DabblerColors colors,
    double viewportHeight,
  ) {
    final List<Widget> rows = <Widget>[];

    if (widget.dragHandle) {
      rows.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: _onDragStart,
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: (DragEndDetails _) => _onDragEnd(
            _measuredHeight(viewportHeight),
            viewportHeight,
          ),
          onVerticalDragCancel: () => setState(() {
            _drag = 0;
            _dragging = false;
          }),
          child: SizedBox(
            // `min-height: var(--touch-target-min)` (`Sheet.jsx:104`).
            height: DabblerSizing.touchTargetMin,
            child: Center(
              // The bar itself carries no semantics: it is a pointer
              // affordance, and the named, focusable route out is the close
              // button.
              child: ExcludeSemantics(
                child: Container(
                  width: DabblerSheet.handleWidth,
                  height: DabblerSheet.handleHeight,
                  decoration: BoxDecoration(
                    color: colors.borderStrong,
                    borderRadius: DabblerRadius.pillAll,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final Widget? close = _canDismiss ? _closeButton(context, colors) : null;

    if (widget.title != null || close != null) {
      rows.add(
        Padding(
          // `padding: 0 var(--space-6) var(--space-4)` (`Sheet.jsx:117`).
          padding: const EdgeInsetsDirectional.fromSTEB(
            DabblerSpacing.space6,
            0,
            DabblerSpacing.space6,
            DabblerSpacing.space4,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: widget.title == null
                    ? const SizedBox.shrink()
                    : Text(
                        widget.title!,
                        style: DabblerType.title3
                            .resolveForDirection(Directionality.of(context))
                            .copyWith(color: colors.textPrimary),
                      ),
              ),
              ?close,
            ],
          ),
        ),
      );
    }

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  double _measuredHeight(double viewportHeight) =>
      viewportHeight * _stops[math.min(_index, _stops.length - 1)];

  Widget _closeButton(BuildContext context, DabblerColors colors) {
    return Semantics(
      button: true,
      label: widget.closeLabel,
      child: DabblerFocusRing(
        borderRadius: DabblerRadius.pillAll,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _close,
          child: DabblerPressScale.gesture(
            child: SizedBox(
              // ≥44×44: the source's own `--touch-target-min` is 45.
              width: DabblerSizing.touchTargetMin,
              height: DabblerSizing.touchTargetMin,
              child: Center(
                child: CustomPaint(
                  size: const Size.square(DabblerSizing.iconSm),
                  painter: _CloseGlyphPainter(colors.textSecondary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _footerBar(BuildContext context, DabblerColors colors) {
    final double safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    return DecoratedBox(
      decoration: BoxDecoration(
        // `border-block-start: 1px solid var(--faint)` (`Sheet.jsx:126`).
        border: Border(
          top: BorderSide(
            color: colors.bgTertiary,
            width: DabblerSizing.borderDefault,
          ),
        ),
      ),
      child: Padding(
        // `var(--space-4) var(--space-6)`, with the bottom at
        // `calc(var(--space-6) + env(safe-area-inset-bottom))`
        // (`Sheet.jsx:124-125`).
        padding: EdgeInsetsDirectional.fromSTEB(
          DabblerSpacing.space6,
          DabblerSpacing.space4,
          DabblerSpacing.space6,
          DabblerSpacing.space6 + safeBottom,
        ),
        child: widget.footer,
      ),
    );
  }
}

/// The ✕ glyph, drawn rather than imported.
///
/// The system's icon set is Iconsax and the dependency is a `cto` hand-off
/// (DS-40x), so this one mark is two token-coloured strokes on the 18px
/// [DabblerSizing.iconSm] grid. It is replaced by `Iconsax.close_square` the
/// moment the package lands.
class _CloseGlyphPainter extends CustomPainter {
  const _CloseGlyphPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = DabblerSizing.borderDefault * 1.5
      ..strokeCap = StrokeCap.round;
    const double inset = DabblerSpacing.space1;
    canvas.drawLine(
      const Offset(inset, inset),
      Offset(size.width - inset, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CloseGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// The route [showDabblerSheet] pushes.
///
/// A [PopupRoute] rather than a [ModalBottomSheetRoute]: the barrier is
/// transparent because the wash is [DabblerScrim], drawn inside the page so
/// the sheet owns one scrim and not two. The barrier is still present, so it
/// absorbs pointers and the content behind cannot be scrolled — the Flutter
/// equivalent of the source's `useScrollLock` (`Sheet.prompt.md:65`). The
/// route also supplies the focus trap and focus restoration that
/// `useFocusTrap` provides on the web.
class DabblerSheetRoute<T> extends PopupRoute<T> {
  /// Creates a sheet route.
  DabblerSheetRoute({
    required this.builder,
    this.detents = const <double>[0.5],
    this.dragHandle = true,
    this.title,
    this.footerBuilder,
    this.dismissible = true,
    this.closeLabel = DabblerSheet.defaultCloseLabel,
    this.scrimLabel = DabblerSheet.defaultScrimLabel,
    super.settings,
  });

  /// Builds the scrolling body.
  final WidgetBuilder builder;

  /// See [DabblerSheet.detents].
  final List<double> detents;

  /// See [DabblerSheet.dragHandle].
  final bool dragHandle;

  /// See [DabblerSheet.title].
  final String? title;

  /// Builds the pinned footer. See [DabblerSheet.footer].
  final WidgetBuilder? footerBuilder;

  /// See [DabblerSheet.dismissible].
  final bool dismissible;

  /// See [DabblerSheet.closeLabel].
  final String closeLabel;

  /// See [DabblerSheet.scrimLabel].
  final String scrimLabel;

  @override
  Color? get barrierColor => null;

  @override
  // Dismissal is the sheet's: the scrim, Escape and the close button all run
  // through [DabblerSheet.onClose], so the route must not pop a second time.
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => DabblerMotion.slow;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return DabblerSheet(
      onClose: () => Navigator.of(context).maybePop(),
      detents: detents,
      dragHandle: dragHandle,
      title: title,
      footer: footerBuilder?.call(context),
      dismissible: dismissible,
      closeLabel: closeLabel,
      scrimLabel: scrimLabel,
      child: builder(context),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (DabblerMotion.reduceMotion(context)) {
      return child;
    }
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
        CurvedAnimation(parent: animation, curve: DabblerMotion.easeOut),
      ),
      child: child,
    );
  }
}

/// Pushes a [DabblerSheet] and resolves with whatever the sheet pops.
///
/// This is how application code opens a sheet:
///
/// ```dart
/// final String? sport = await showDabblerSheet<String>(
///   context: context,
///   title: 'filters',
///   detents: <double>[0.45, 0.9],
///   builder: (BuildContext context) => const _FilterBody(),
/// );
/// ```
Future<T?> showDabblerSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  List<double> detents = const <double>[0.5],
  bool dragHandle = true,
  String? title,
  WidgetBuilder? footerBuilder,
  bool dismissible = true,
  String closeLabel = DabblerSheet.defaultCloseLabel,
  String scrimLabel = DabblerSheet.defaultScrimLabel,
}) {
  return Navigator.of(context, rootNavigator: true).push<T>(
    DabblerSheetRoute<T>(
      builder: builder,
      detents: detents,
      dragHandle: dragHandle,
      title: title,
      footerBuilder: footerBuilder,
      dismissible: dismissible,
      closeLabel: closeLabel,
      scrimLabel: scrimLabel,
    ),
  );
}
