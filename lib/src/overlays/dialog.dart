import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../interaction/press_scale.dart';
import '../interaction/scrim.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// The two panel widths a [DabblerDialog] can take, transcribed from the
/// `MAX_WIDTH` map of the design source `components/overlays/Dialog.jsx:16`
/// and documented in `Dialog.d.ts:21`.
enum DabblerDialogSize {
  /// `sm` — max width 340px.
  sm(340),

  /// `md` — max width 420px. The source's default.
  md(420);

  const DabblerDialogSize(this.maxWidth);

  /// The panel's maximum width in logical pixels.
  ///
  /// These two are the only raw numbers in this file. They are not spacing and
  /// not a radius, so no [DabblerSpacing] step expresses them; they are the
  /// source's own container widths, copied verbatim from `Dialog.jsx:16`.
  final double maxWidth;
}

/// Dialog — the modal that interrupts to get one decision.
///
/// Transcribed from `components/overlays/Dialog.jsx`, `Dialog.d.ts` and
/// `Dialog.prompt.md`. It is the wide-viewport counterpart of Sheet: the same
/// job, a different presentation.
///
/// ## The one legal shadow
///
/// Dialog is the **only** component in the cut permitted to cast a shadow. It
/// paints [DabblerElevation.dialogFor], the transcription of `--elevation-2`,
/// which the source calls *"the ONE legal shadow and only for Material
/// dialogs"*. `dabbler_geometry.dart` reserves that token for this ticket by
/// name, and `test/overlays/dialog_test.dart` asserts the rendered panel
/// carries exactly that shadow for the current brightness, so the reservation
/// is checked rather than merely written down.
///
/// **A deliberate deviation from `Dialog.prompt.md:37`**, recorded here because
/// the two sources disagree. The prompt says of the web component: *"No shadow
/// appears in computed styles — separation comes from the scrim and the
/// hairline, not elevation. (`--elevation-2` remains legal only for Material
/// dialogs in the Flutter layer, not here.)"* This package **is** the Flutter
/// layer, and KAN-232 AC1 requires the shadow here. So: web flat, Flutter
/// elevated, by the source's own carve-out. Everything else about the panel —
/// fill, hairline, radius, padding, type — is the flat transcription.
///
/// ## Composition
///
/// The wash is [DabblerScrim] (DS-200), never a colour of this component's
/// own. The panel, the fade, the focus trap and the key handling are Dialog's.
/// A screen must not build its own modal wrapper, scrim or focus trap —
/// `Dialog.prompt.md:78-80` is explicit that the plumbing is shared.
///
/// ## Actions
///
/// [actions] is a slot of arbitrary widgets rather than a typed
/// `primaryAction` / `secondaryAction` pair, because Button (DS-400) does not
/// exist yet in this package. The source's rule is *"actions are `Button`
/// instances — never raw `<button>`s"* (`Dialog.prompt.md:77`), which cannot be
/// enforced against a component that has not been written. **Follow-up:** once
/// DS-400 lands, this slot should gain the typed action pair and the
/// `destructive` flag that paints the primary action with
/// `--color-status-error-solid` (`Dialog.d.ts:14`). Reported to the
/// orchestrator with this ticket.
///
/// Below a 360px viewport the action row stacks vertically and each action is
/// stretched to full width (`Dialog.prompt.md:57-59`, and the `stack`
/// media query at `Dialog.jsx:29`).
///
/// ## Behaviour
///
/// * Focus moves into the panel on open, Tab cycles inside it, and focus
///   returns to the invoking element on close.
/// * Escape closes when [dismissible].
/// * A press on the scrim closes when [dismissible].
/// * Enter runs [onConfirm] — the source's *"`Enter` triggers the primary
///   action"* (`Dialog.prompt.md:55`). It is a callback rather than a lookup
///   into [actions] for the reason above: with an untyped slot there is no
///   primary action to find.
/// * Body scroll lock (`Dialog.prompt.md:53`) has no Flutter counterpart and
///   is deliberately not ported: the route is modal and the content beneath it
///   receives no pointers, which is what the CSS lock exists to achieve.
///
/// ## Use
///
/// Either push it with [showDabblerDialog], which owns the route, the fade and
/// focus restoration, or place it in a [Stack] and drive [open] yourself. The
/// widget is self-contained in both cases: it paints its own scrim and centres
/// its own panel, exactly as the source's component does.
class DabblerDialog extends StatefulWidget {
  /// Creates a dialog, shown when [open].
  const DabblerDialog({
    super.key,
    this.open = true,
    this.onClose,
    this.title,
    this.description,
    this.child,
    this.actions = const <Widget>[],
    this.size = DabblerDialogSize.md,
    this.dismissible = true,
    this.onConfirm,
    this.scrimDismissLabel,
  });

  /// Whether the dialog is shown. `false` renders nothing at all — the source
  /// returns `null` and leaves no hidden DOM (`Dialog.jsx:38`).
  final bool open;

  /// Called when the dialog asks to close: Escape, or a press on the scrim.
  /// Only reached when [dismissible].
  final VoidCallback? onClose;

  /// The title line, set in [DabblerType.title3] on
  /// [DabblerColors.textPrimary]. Also the dialog's accessible name.
  final String? title;

  /// The description line, set in [DabblerType.body] on
  /// [DabblerColors.textSecondary].
  final String? description;

  /// A custom body, placed under [description].
  final Widget? child;

  /// The action row. Arbitrary widgets — see the class doc for why.
  final List<Widget> actions;

  /// Which of the two panel widths to use. Defaults to
  /// [DabblerDialogSize.md].
  final DabblerDialogSize size;

  /// Whether Escape and a scrim press close the dialog. Defaults to true.
  final bool dismissible;

  /// Run when Enter is pressed inside the panel. See the class doc.
  final VoidCallback? onConfirm;

  /// The semantics label for the scrim's dismiss gesture, handed to
  /// [DabblerScrim.dismissLabel]. This package ships no strings of its own, so
  /// a caller that wants the affordance announced supplies the word.
  final String? scrimDismissLabel;

  /// The viewport width below which the action row stacks —
  /// `(max-width: 359px)` at `Dialog.jsx:29`, i.e. stack **below** 360.
  static const double stackBelowWidth = 360;

  /// Identifies the panel, so a test can measure the rendered box and read its
  /// decoration rather than trust a comment.
  static const Key panelKey = Key('DabblerDialog.panel');

  /// Identifies the action row, so a test can assert its axis.
  static const Key actionsKey = Key('DabblerDialog.actions');

  @override
  State<DabblerDialog> createState() => _DabblerDialogState();
}

class _DabblerDialogState extends State<DabblerDialog> {
  /// The scope the panel's focus is trapped in. A [FocusScopeNode] is how
  /// Flutter expresses the source's `useFocusTrap`: traversal within a scope
  /// wraps at its ends instead of escaping to whatever is behind the scrim.
  final FocusScopeNode _scope = FocusScopeNode(debugLabel: 'DabblerDialog');

  /// The node that had focus when the dialog opened, restored on close —
  /// *"focus returns to the invoking element on close"*
  /// (`Dialog.prompt.md:51`).
  FocusNode? _restoreTo;

  @override
  void initState() {
    super.initState();
    if (widget.open) {
      _captureFocus();
    }
  }

  @override
  void didUpdateWidget(DabblerDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open && !oldWidget.open) {
      _captureFocus();
    } else if (!widget.open && oldWidget.open) {
      _restoreFocus();
    }
  }

  @override
  void dispose() {
    _restoreFocus();
    _scope.dispose();
    super.dispose();
  }

  void _captureFocus() {
    _restoreTo = FocusManager.instance.primaryFocus;
  }

  void _restoreFocus() {
    final FocusNode? node = _restoreTo;
    _restoreTo = null;
    if (node != null && node.context != null) {
      node.requestFocus();
    }
  }

  void _close() {
    if (widget.dismissible) {
      widget.onClose?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.open) {
      return const SizedBox.shrink();
    }

    final DabblerColors colors = DabblerColors.of(context);
    final bool reduceMotion = DabblerMotion.reduceMotion(context);

    final Widget panel = _Panel(
      title: widget.title,
      description: widget.description,
      actions: widget.actions,
      size: widget.size,
      colors: colors,
      child: widget.child,
    );

    // The fade is the panel's only motion: `--motion-base` opacity, no scale
    // and no slide (`Dialog.prompt.md:69-71`). Under reduced motion the source
    // drops the animation entirely (`overlay.jsx:43`).
    final Widget faded = AnimatedOpacity(
      opacity: 1,
      duration: reduceMotion ? Duration.zero : DabblerMotion.base,
      curve: DabblerMotion.easeOut,
      child: panel,
    );

    // `role="dialog"`, `aria-modal="true"`, `aria-labelledby` on the title
    // (`Dialog.jsx:64-67`). `scopesRoute` + `namesRoute` is the Flutter
    // spelling of a modal with an accessible name; `explicitChildNodes` keeps
    // the title, body and actions as their own nodes rather than merging them
    // into one announcement.
    final Widget semantic = Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: widget.title,
      child: faded,
    );

    // The source gives the panel `tabIndex={-1}` and moves focus to it on open
    // (`Dialog.jsx:68`). The [Focus] node is that: something inside the scope
    // that can hold focus even when the dialog has no focusable content, so
    // the key handling below is reachable from the moment it opens.
    final Widget focusable = Focus(autofocus: true, child: semantic);

    final Widget trapped = FocusScope(
      node: _scope,
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          const SingleActivator(LogicalKeyboardKey.escape):
              const DismissIntent(),
          if (widget.onConfirm != null)
            const SingleActivator(LogicalKeyboardKey.enter):
                const _ConfirmIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (DismissIntent intent) {
                _close();
                return null;
              },
            ),
            _ConfirmIntent: CallbackAction<_ConfirmIntent>(
              onInvoke: (_ConfirmIntent intent) {
                widget.onConfirm?.call();
                return null;
              },
            ),
          },
          child: focusable,
        ),
      ),
    );

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: DabblerScrim(
            onDismiss: widget.dismissible ? _close : null,
            dismissLabel: widget.scrimDismissLabel,
          ),
        ),
        Positioned.fill(
          // `padding: var(--space-8)` on the scrim container, Dialog.jsx:60 —
          // the gutter that keeps the panel off the viewport edge.
          child: Padding(
            padding: const EdgeInsets.all(DabblerSpacing.space8),
            child: Center(child: trapped),
          ),
        ),
      ],
    );
  }
}

/// Enter's intent. Private: the accelerator is Dialog's, not an API.
class _ConfirmIntent extends Intent {
  const _ConfirmIntent();
}

/// The panel itself — fill, hairline, radius, padding, shadow and content.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.description,
    required this.child,
    required this.actions,
    required this.size,
    required this.colors,
  });

  final String? title;
  final String? description;
  final Widget? child;
  final List<Widget> actions;
  final DabblerDialogSize size;
  final DabblerColors colors;

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = Directionality.of(context);
    final double viewportWidth = MediaQuery.sizeOf(context).width;
    final double viewportHeight = MediaQuery.sizeOf(context).height;
    final bool stack = viewportWidth < DabblerDialog.stackBelowWidth;

    final List<Widget> column = <Widget>[];

    void addGap() {
      if (column.isNotEmpty) {
        // `gap: var(--space-4)` on the panel column, Dialog.jsx:80.
        column.add(const SizedBox(height: DabblerSpacing.space4));
      }
    }

    if (title != null) {
      column.add(
        Text(
          title!,
          // `.t-title-3`, `--color-text-primary` (Dialog.jsx:83).
          style: DabblerType.title3
              .resolveForDirection(direction)
              .copyWith(color: colors.textPrimary),
        ),
      );
    }
    if (description != null) {
      addGap();
      column.add(
        Text(
          description!,
          // `.t-body`, `--color-text-secondary` (Dialog.jsx:85).
          style: DabblerType.body
              .resolveForDirection(direction)
              .copyWith(color: colors.textSecondary),
        ),
      );
    }
    if (child != null) {
      addGap();
      column.add(child!);
    }
    if (actions.isNotEmpty) {
      addGap();
      column.add(
        // `marginBlockStart: var(--space-2)` on the action row,
        // Dialog.jsx:95.
        Padding(
          padding: const EdgeInsetsDirectional.only(top: DabblerSpacing.space2),
          child: _Actions(stack: stack, actions: actions),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: size.maxWidth,
        // `maxHeight: calc(100dvh - var(--space-11))`, Dialog.jsx:73.
        maxHeight: viewportHeight - DabblerSpacing.space11,
      ),
      // `width: '100%'` with the max width above (Dialog.jsx:72): the panel
      // fills the gutter-inset width until it reaches its cap.
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          key: DabblerDialog.panelKey,
          decoration: BoxDecoration(
            // `--surface-card` fill with the `--outline-card` 1px hairline,
            // `--radius-xl` (Dialog.jsx:75-78).
            color: colors.surfaceCard,
            borderRadius: DabblerRadius.xlAll,
            border: Border.all(
              color: colors.borderDefault,
              width: DabblerSizing.borderDefault,
            ),
            // The one legal shadow in the system. See the class doc.
            boxShadow: DabblerElevation.dialogFor(colors.brightness),
          ),
          child: ClipRRect(
            borderRadius: DabblerRadius.xlAll,
            child: SingleChildScrollView(
              // `overflowY: auto` — the panel scrolls internally rather than
              // pushing past the viewport cap (Dialog.jsx:74).
              padding: const EdgeInsets.all(DabblerSpacing.space8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: column,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The action row: `justify-content: flex-end` with a `--space-3` gap, which
/// stacks to a full-width column below 360px (`Dialog.jsx:88-94`).
///
/// `flex-end` is the *end* of the reading direction, so [MainAxisAlignment.end]
/// mirrors under RTL on its own — which is the source's stated RTL behaviour
/// (`Dialog.prompt.md:62-64`) and the reason no `left`/`right` appears here.
class _Actions extends StatelessWidget {
  const _Actions({required this.stack, required this.actions});

  final bool stack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final List<Widget> spaced = <Widget>[];
    for (int i = 0; i < actions.length; i++) {
      if (i > 0) {
        spaced.add(
          stack
              ? const SizedBox(height: DabblerSpacing.space3)
              : const SizedBox(width: DabblerSpacing.space3),
        );
      }
      spaced.add(actions[i]);
    }

    if (stack) {
      return Column(
        key: DabblerDialog.actionsKey,
        mainAxisSize: MainAxisSize.min,
        // `fullWidth` on both buttons when stacked, Dialog.jsx:98 and :101.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: spaced,
      );
    }
    return Row(
      key: DabblerDialog.actionsKey,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: spaced,
    );
  }
}

/// Pushes a [DabblerDialog] as a modal route and completes with its result.
///
/// The route owns what a route owns: it blocks the content beneath (the
/// Flutter answer to the source's body scroll lock), it restores focus to the
/// invoking element when it pops, and it fades the whole overlay in over
/// [DabblerMotion.base]. The dialog itself still paints [DabblerScrim] and
/// still traps focus, so the widget behaves identically whether it is pushed
/// or placed in a [Stack].
///
/// [builder] receives the route's context and returns the dialog's content —
/// typically `DabblerDialog(...)` with `onClose: () => Navigator.pop(context)`.
/// Nothing here supplies strings: labels, the confirm callback and the scrim's
/// dismiss label all come from the caller.
Future<T?> showDabblerDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useRootNavigator = true,
  RouteSettings? settings,
}) {
  return Navigator.of(
    context,
    rootNavigator: useRootNavigator,
  ).push<T>(_DabblerDialogRoute<T>(builder: builder, settings: settings));
}

/// The route [showDabblerDialog] pushes.
///
/// A [PopupRoute] rather than a [DialogRoute] because Material's dialog route
/// paints a barrier colour of its own, and this system has exactly one scrim
/// (DS-200) which the dialog widget already paints. [barrierColor] is
/// therefore null: no second wash.
class _DabblerDialogRoute<T> extends PopupRoute<T> {
  _DabblerDialogRoute({required this.builder, super.settings});

  final WidgetBuilder builder;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => DabblerMotion.base;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Opacity only — no scale, no slide (`Dialog.prompt.md:69-71`).
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: DabblerMotion.easeOut),
      child: child,
    );
  }
}
