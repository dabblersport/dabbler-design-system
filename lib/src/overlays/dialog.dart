import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controls/button.dart';
import '../tokens/dabbler_motion.dart';
import '../interaction/scrim.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

part 'dialog_panel.dart';

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

/// One of a [DabblerDialog]'s two actions — `Dialog.d.ts:3-8`'s
/// `DialogAction`.
///
/// A value, not a widget: the dialog builds the [DabblerButton] itself, which
/// is how `Dialog.prompt.md:77`'s rule — *"actions are `Button` instances —
/// never raw `<button>`s"* — becomes something the type system enforces
/// rather than something a caller is asked to remember.
@immutable
class DabblerDialogAction {
  /// Creates an action.
  const DabblerDialogAction({
    required this.label,
    this.onPressed,
    this.tone,
  });

  /// The button's label.
  final String label;

  /// Run when the action fires. Null renders the button disabled.
  ///
  /// On [DabblerDialog.secondaryAction] a null callback falls back to
  /// [DabblerDialog.onClose] instead of disabling — `Dialog.jsx:102`'s
  /// `secondaryAction.onPress || onClose`.
  final VoidCallback? onPressed;

  /// Overrides the primary action's tone.
  ///
  /// **Ignored when [DabblerDialog.destructive] is set** — `Dialog.d.ts:6`
  /// says so in as many words, and `Dialog.jsx:52` implements it as
  /// `destructive ? 'destructive' : (tone || 'primary')`. Unused on the
  /// secondary action, which is always [DabblerButtonTone.outlined].
  final DabblerButtonTone? tone;
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
/// [secondaryAction] then [primaryAction], in that order — `Dialog.jsx:101`
/// and `:104`. Both are [DabblerDialogAction] values and the dialog builds the
/// buttons, so `Dialog.prompt.md:77`'s *"actions are `Button` instances —
/// never raw `<button>`s"* is enforced by the type rather than trusted.
///
/// The primary takes [DabblerButtonTone.primary], or
/// [DabblerDialogAction.tone] if given, or [DabblerButtonTone.destructive]
/// when [destructive] is set — which outranks `tone`, per `Dialog.d.ts:6`.
/// The secondary is always [DabblerButtonTone.outlined] (`Dialog.jsx:101`) and
/// falls back to [onClose] when it carries no callback of its own.
///
/// **This replaced an untyped `actions: List<Widget>` slot** (KAN-267), which
/// existed only because Button did not yet exist in this package. With it went
/// `onConfirm`: Enter now activates [primaryAction] itself, so there is no
/// second callback that could disagree with the button the user can see.
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
/// * Enter fires [primaryAction] — *"`Enter` triggers the primary action"*
///   (`Dialog.prompt.md:51`). **Unless an action button already holds focus**,
///   in which case that button takes the key: `Dialog.jsx:46-48` skips its own
///   handler when the event target is a `button`, because the browser
///   activates a focused button on Enter natively. [DabblerButton] binds
///   `ActivateIntent` and does the same, so the guard is transcribed rather
///   than dropped — without it, Tabbing to Cancel and pressing Enter would
///   confirm.
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
    this.primaryAction,
    this.secondaryAction,
    this.destructive = false,
    this.size = DabblerDialogSize.md,
    this.dismissible = true,
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

  /// The confirming action, drawn last in the row. Enter fires it.
  final DabblerDialogAction? primaryAction;

  /// The dismissing action, drawn first. Always
  /// [DabblerButtonTone.outlined]; falls back to [onClose] when it carries no
  /// callback.
  final DabblerDialogAction? secondaryAction;

  /// Paints [primaryAction] with `--color-status-error-solid`
  /// ([DabblerButtonTone.destructive]) — `Dialog.d.ts:18`. Outranks
  /// [DabblerDialogAction.tone]. Defaults to false.
  final bool destructive;

  /// Which of the two panel widths to use. Defaults to
  /// [DabblerDialogSize.md].
  final DabblerDialogSize size;

  /// Whether Escape and a scrim press close the dialog. Defaults to true.
  final bool dismissible;

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

  /// Identifies the primary action's button.
  static const Key primaryActionKey = Key('DabblerDialog.primaryAction');

  /// Identifies the secondary action's button.
  static const Key secondaryActionKey = Key('DabblerDialog.secondaryAction');

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
      primaryAction: widget.primaryAction,
      secondaryAction: widget.secondaryAction,
      destructive: widget.destructive,
      onClose: widget.onClose,
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
          if (widget.primaryAction != null)
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
                // `Dialog.jsx:46-48` returns early when the key landed on a
                // button: the browser already activates a focused button on
                // Enter. [DabblerButton] binds `ActivateIntent`, so the same
                // hand-off is made explicit here — otherwise this shortcut,
                // sitting nearer the focused node than the app's default
                // binding, would swallow the key and confirm the dialog while
                // Cancel was focused.
                final BuildContext? focused =
                    FocusManager.instance.primaryFocus?.context;
                if (focused != null &&
                    focused.findAncestorWidgetOfExactType<DabblerButton>() !=
                        null) {
                  Actions.maybeInvoke<ActivateIntent>(
                    focused,
                    const ActivateIntent(),
                  );
                  return null;
                }
                widget.primaryAction?.onPressed?.call();
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
