/// Part of the `sheet.dart` library — [DabblerSheet]'s state: the panel,
/// the detent maths, the drag gesture, the close affordance and the footer.
///
/// **Why `part`, not separate libraries (KAN-265).** `sheet.dart` stood at 684
/// lines against the project's 500-line house rule, roughly 40% of it the
/// source-citation documentation this package's traceability discipline
/// requires and which therefore cannot be cut. [_DabblerSheetState] is
/// library-private and [DabblerSheetRoute] is tightly coupled to
/// [DabblerSheet]'s private state; a plain second-file split would have forced
/// private detail public, which this package does not do anywhere else.
/// `part`/`part of` keeps one logical library, keeps private access between
/// the pieces, changes no public API, and gets every resulting file under the
/// rule. No exemption was recorded — the rule holds and the file complies.
///
/// The imports are the library's — a part file declares none of its own.
part of 'sheet.dart';

class _DabblerSheetState extends State<DabblerSheet> {
  late List<double> _stops = _sorted(widget.detents);
  late int _index = widget.snapTo ?? _stops.length - 1;
  final GlobalKey _panelKey = GlobalKey();
  bool get _contentSized => widget.detent == DabblerSheetDetent.content;
  double _drag = 0;
  bool _dragging = false;

  static List<double> _sorted(List<double> detents) {
    final List<double> copy = detents.isEmpty
        ? <double>[0.5]
        : List<double>.of(detents);
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
    // `settled = (h - drag) / vh` (`Sheet.jsx:64`).
    // A content-sized panel has one height, so its fraction is of itself.
    final double basis = _contentSized ? panelHeight : viewportHeight;
    final double settled = basis == 0 ? 0 : (panelHeight - _drag) / basis;
    final double floor = _contentSized ? 1 : _stops.first;
    if (_canDismiss && settled < floor * DabblerSheet.dismissFraction) {
      setState(() {
        _drag = 0;
        _dragging = false;
      });
      _close();
      return;
    }
    if (_contentSized) {
      // One height only: a shorter drag springs back.
      setState(() {
        _drag = 0;
        _dragging = false;
      });
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
    // Content-sized: no fixed height, only a cap (`max-height`, not `height`).
    final double? height = _contentSized
        ? null
        : math.min(
            viewport.height * fraction,
            viewport.height * DabblerSheet.maxHeightFraction,
          );
    final double? maxHeight = _contentSized
        ? dabblerSheetContentMaxHeight(
            viewport.height,
            widget.contentMaxFraction,
          )
        : null;

    final bool reduceMotion = DabblerMotion.reduceMotion(context);
    final Widget panel = AnimatedSlide(
      offset: widget.open ? Offset.zero : const Offset(0, 1),
      duration: reduceMotion ? Duration.zero : DabblerMotion.slow,
      curve: DabblerMotion.easeOut,
      child: _panel(
        context,
        modal: true,
        height: height,
        maxHeight: maxHeight,
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
    double? maxHeight,
    double viewportHeight = 0,
  }) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool reduceMotion = DabblerMotion.reduceMotion(context);

    final Widget body = DecoratedBox(
      decoration: BoxDecoration(
        // `background: var(--surface-card)` (`Sheet.jsx:86`).
        color: widget.pageBackground ? colors.bgPrimary : colors.surfaceCard,
        // `1px solid var(--outline-card)`; the modal presentation drops the
        // bottom edge, which sits off-screen (`Sheet.jsx:87-88`).
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
        // Top corners only when modal (`Sheet.jsx:89`).
        borderRadius: modal
            ? const BorderRadius.vertical(
                top: Radius.circular(DabblerRadius.xl),
              )
            : DabblerRadius.xlAll,
      ),
      child: Padding(
        padding: widget.hairlineOutside
            ? EdgeInsetsDirectional.only(
                start: DabblerSizing.borderDefault,
                end: DabblerSizing.borderDefault,
                top: DabblerSizing.borderDefault,
              )
            : EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _header(context, colors, viewportHeight),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsetsDirectional.fromSTEB(
                  DabblerSpacing.space6,
                  widget.dragHandle || _hasTitle ? 0 : DabblerSpacing.space6,
                  DabblerSpacing.space6,
                  DabblerSpacing.space6,
                ),
                child: widget.child ?? const SizedBox.shrink(),
              ),
            ),
            if (widget.footer != null) _footerBar(context, colors),
          ],
        ),
      ),
    );

    final Widget sized = ConstrainedBox(
      key: _panelKey,
      constraints: BoxConstraints(
        maxWidth: DabblerSheet.maxPanelWidth,
        maxHeight: maxHeight ?? double.infinity,
      ),
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
    // never height, top or margin (`Sheet.prompt.md:58`, unverified: file not mirrored). During an active
    // drag the transition is off so the panel tracks the finger; on release
    // it animates home over `--motion-slow` (`Sheet.prompt.md:69`, unverified: file not mirrored).
    return AnimatedContainer(
      duration: _dragging || reduceMotion ? Duration.zero : DabblerMotion.slow,
      curve: DabblerMotion.easeOut,
      transform: Matrix4.translationValues(0, _drag, 0),
      child: Semantics(
        container: true,
        scopesRoute: true,
        explicitChildNodes: true,
        namesRoute: _semanticTitle != null,
        label: _semanticTitle,
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
          onVerticalDragEnd: (DragEndDetails _) =>
              _onDragEnd(_measuredHeight(viewportHeight), viewportHeight),
          onVerticalDragCancel: () => setState(() {
            _drag = 0;
            _dragging = false;
          }),
          child: SizedBox(
            // `min-height: var(--touch-target-min)` (`Sheet.jsx:101`).
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

    final Widget? close = _canDismiss && widget.showCloseButton
        ? _closeButton(context, colors)
        : null;

    if (_hasTitle || widget.headerAction != null || close != null) {
      final Widget header = Padding(
        // `padding: 0 var(--space-6) var(--space-4)` (`Sheet.jsx:108`).
        padding: const EdgeInsetsDirectional.fromSTEB(
          DabblerSpacing.space6,
          0,
          DabblerSpacing.space6,
          DabblerSpacing.space4,
        ),
        child: Row(
          // `gap: 12` between the title and the action
          // (`Listings.dc.html:286`) — [DabblerSpacing.space4].
          spacing: widget.headerAction == null ? 0 : DabblerSpacing.space4,
          children: <Widget>[
            Expanded(child: _titleContent(context, colors)),
            ?widget.headerAction,
            ?close,
          ],
        ),
      );
      rows.add(
        widget.headerDivider
            ? DecoratedBox(
                decoration: BoxDecoration(
                  // `border-bottom: 1px solid var(--faint)`
                  // (`Listings.dc.html:289`).
                  border: Border(
                    bottom: BorderSide(
                      color: colors.bgTertiary,
                      width: DabblerSizing.borderDefault,
                    ),
                  ),
                ),
                child: header,
              )
            : header,
      );
    }

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  bool get _hasTitle =>
      widget.title != null ||
      widget.titleSpan != null ||
      widget.titleWidget != null;

  /// The route's accessible name: [DabblerSheet.title], else the plain text
  /// of [DabblerSheet.titleSpan].
  String? get _semanticTitle => widget.title ?? widget.titleSpan?.toPlainText();

  Widget _titleContent(BuildContext context, DabblerColors colors) {
    if (widget.titleWidget != null) {
      return widget.titleWidget!;
    }
    final TextStyle style = DabblerType.title3
        .resolveForDirection(Directionality.of(context))
        .copyWith(color: colors.textPrimary);
    if (widget.titleSpan != null) {
      return Text.rich(widget.titleSpan!, style: style);
    }
    if (widget.title != null) {
      return Text(widget.title!, style: style);
    }
    return const SizedBox.shrink();
  }

  double _measuredHeight(double viewportHeight) {
    if (_contentSized) {
      final RenderObject? box = _panelKey.currentContext?.findRenderObject();
      return box is RenderBox && box.hasSize ? box.size.height : 0;
    }
    return viewportHeight * _stops[math.min(_index, _stops.length - 1)];
  }

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
                // KAN-265: the ✕ was two hand-drawn strokes while the icon
                // package was still a `cto` hand-off. DS-300 (KAN-235) landed
                // `iconsax_flutter` (T-083), so the real glyph is drawn here
                // and the stand-in painter is gone rather than kept as a
                // fallback. `close-square` is not in
                // [DabblerIconRegistry.vocabulary], which is documentation and
                // a test fixture rather than a gate — `resolve` never consults
                // it — so no registry change is needed.
                child: DabblerIcon(
                  'close-square',
                  size: DabblerSizing.iconSm,
                  color: colors.textSecondary,
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
        // `border-block-start: 1px solid var(--faint)` (`Sheet.jsx:121`).
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
        // (`Sheet.jsx:119-120`).
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
