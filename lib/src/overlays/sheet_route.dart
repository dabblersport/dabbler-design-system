/// Part of the `sheet.dart` library — [DabblerSheetRoute] and
/// [showDabblerSheet], the route half of the component.
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

/// The route [showDabblerSheet] pushes.
///
/// A [PopupRoute] rather than a [ModalBottomSheetRoute]: the barrier is
/// transparent because the wash is [DabblerScrim], drawn inside the page so
/// the sheet owns one scrim and not two. The barrier is still present, so it
/// absorbs pointers and the content behind cannot be scrolled — the Flutter
/// equivalent of the source's `useScrollLock` (`Sheet.prompt.md:65`, unverified: file not mirrored). The
/// route also supplies the focus trap and focus restoration that
/// `useFocusTrap` provides on the web.
class DabblerSheetRoute<T> extends PopupRoute<T> {
  /// Creates a sheet route.
  DabblerSheetRoute({
    required this.builder,
    this.detents = const <double>[0.5],
    this.dragHandle = true,
    this.title,
    this.titleSpan,
    this.titleWidget,
    this.headerActionBuilder,
    this.footerBuilder,
    this.dismissible = true,
    this.closeLabel = DabblerSheet.defaultCloseLabel,
    this.scrimLabel = DabblerSheet.defaultScrimLabel,
    this.detent = DabblerSheetDetent.fractions,
    this.contentMaxFraction = DabblerSheet.defaultContentMaxFraction,
    this.pageBackground = false,
    this.hairlineOutside = false,
    this.showCloseButton = true,
    this.headerDivider = false,
    super.settings,
  });

  /// See [DabblerSheet.detent].
  final DabblerSheetDetent detent;

  /// See [DabblerSheet.contentMaxFraction].
  final double contentMaxFraction;

  /// See [DabblerSheet.pageBackground].
  final bool pageBackground;

  /// See [DabblerSheet.hairlineOutside].
  final bool hairlineOutside;

  /// See [DabblerSheet.showCloseButton].
  final bool showCloseButton;

  /// See [DabblerSheet.headerDivider].
  final bool headerDivider;

  /// Builds the scrolling body.
  final WidgetBuilder builder;

  /// See [DabblerSheet.detents].
  final List<double> detents;

  /// See [DabblerSheet.dragHandle].
  final bool dragHandle;

  /// See [DabblerSheet.title].
  final String? title;

  /// See [DabblerSheet.titleSpan].
  final InlineSpan? titleSpan;

  /// See [DabblerSheet.titleWidget].
  final Widget? titleWidget;

  /// Builds the trailing header action. See [DabblerSheet.headerAction].
  final WidgetBuilder? headerActionBuilder;

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
      titleSpan: titleSpan,
      titleWidget: titleWidget,
      headerAction: headerActionBuilder?.call(context),
      footer: footerBuilder?.call(context),
      dismissible: dismissible,
      closeLabel: closeLabel,
      scrimLabel: scrimLabel,
      detent: detent,
      contentMaxFraction: contentMaxFraction,
      pageBackground: pageBackground,
      hairlineOutside: hairlineOutside,
      showCloseButton: showCloseButton,
      headerDivider: headerDivider,
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
///
/// A filters sheet with a trailing *Reset* action (`Listings.dc.html:286-289`)
/// passes `headerActionBuilder`; the builder runs in the route's context, so
/// the action can pop or reset as it needs.
Future<T?> showDabblerSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  List<double> detents = const <double>[0.5],
  bool dragHandle = true,
  String? title,
  InlineSpan? titleSpan,
  Widget? titleWidget,
  WidgetBuilder? headerActionBuilder,
  WidgetBuilder? footerBuilder,
  bool dismissible = true,
  String closeLabel = DabblerSheet.defaultCloseLabel,
  String scrimLabel = DabblerSheet.defaultScrimLabel,
  DabblerSheetDetent detent = DabblerSheetDetent.fractions,
  double contentMaxFraction = DabblerSheet.defaultContentMaxFraction,
  bool pageBackground = false,
  bool hairlineOutside = false,
  bool showCloseButton = true,
  bool headerDivider = false,
}) {
  return Navigator.of(context, rootNavigator: true).push<T>(
    DabblerSheetRoute<T>(
      builder: builder,
      detents: detents,
      dragHandle: dragHandle,
      title: title,
      titleSpan: titleSpan,
      titleWidget: titleWidget,
      headerActionBuilder: headerActionBuilder,
      footerBuilder: footerBuilder,
      dismissible: dismissible,
      closeLabel: closeLabel,
      scrimLabel: scrimLabel,
      detent: detent,
      contentMaxFraction: contentMaxFraction,
      pageBackground: pageBackground,
      hairlineOutside: hairlineOutside,
      showCloseButton: showCloseButton,
      headerDivider: headerDivider,
    ),
  );
}
