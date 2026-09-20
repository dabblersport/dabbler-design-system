/// Part of the `dialog.dart` library — [DabblerDialog]'s panel and its action
/// row.
///
/// **Why `part`, not a separate library (KAN-267).** `dialog.dart` reached 686
/// lines against the project's 500-line house rule once the untyped `actions`
/// slot became the typed [DabblerDialogAction] pair. Both classes below are
/// library-private and exist only to render [DabblerDialog]; exporting them
/// to split the file would have widened the public API to satisfy a line
/// count. `sheet.dart` met the same problem under KAN-265 and answered it the
/// same way — `sheet_panel.dart` and `sheet_route.dart` are its parts.
///
/// Nothing here is reachable from outside the library, and the public API is
/// byte-for-byte what it was before the split.
part of 'dialog.dart';

/// The panel itself — fill, hairline, radius, padding, shadow and content.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.description,
    required this.child,
    required this.primaryAction,
    required this.secondaryAction,
    required this.destructive,
    required this.onClose,
    required this.size,
    required this.colors,
  });

  final String? title;
  final String? description;
  final Widget? child;
  final DabblerDialogAction? primaryAction;
  final DabblerDialogAction? secondaryAction;
  final bool destructive;
  final VoidCallback? onClose;
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
    if (primaryAction != null || secondaryAction != null) {
      addGap();
      column.add(
        // `marginBlockStart: var(--space-2)` on the action row,
        // Dialog.jsx:95.
        Padding(
          padding: const EdgeInsetsDirectional.only(top: DabblerSpacing.space2),
          child: _Actions(
            stack: stack,
            primaryAction: primaryAction,
            secondaryAction: secondaryAction,
            destructive: destructive,
            onClose: onClose,
          ),
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
  const _Actions({
    required this.stack,
    required this.primaryAction,
    required this.secondaryAction,
    required this.destructive,
    required this.onClose,
  });

  final bool stack;
  final DabblerDialogAction? primaryAction;
  final DabblerDialogAction? secondaryAction;
  final bool destructive;
  final VoidCallback? onClose;

  /// `destructive ? 'destructive' : (primaryAction.tone || 'primary')` —
  /// `Dialog.jsx:52-53`. The flag outranks the per-action tone.
  DabblerButtonTone get _primaryTone => destructive
      ? DabblerButtonTone.destructive
      : (primaryAction?.tone ?? DabblerButtonTone.primary);

  @override
  Widget build(BuildContext context) {
    final List<Widget> spaced = <Widget>[];

    // Secondary first, primary last — `Dialog.jsx:101` then `:104`.
    if (secondaryAction != null) {
      spaced.add(
        DabblerButton(
          key: DabblerDialog.secondaryActionKey,
          label: secondaryAction!.label,
          // Always outlined; the source hard-codes it and reads no `tone`
          // from the secondary action.
          tone: DabblerButtonTone.outlined,
          fullWidth: stack,
          // `secondaryAction.onPress || onClose` — Dialog.jsx:102.
          onPressed: secondaryAction!.onPressed ?? onClose,
        ),
      );
    }
    if (primaryAction != null) {
      if (spaced.isNotEmpty) {
        spaced.add(
          stack
              ? const SizedBox(height: DabblerSpacing.space3)
              : const SizedBox(width: DabblerSpacing.space3),
        );
      }
      spaced.add(
        DabblerButton(
          key: DabblerDialog.primaryActionKey,
          label: primaryAction!.label,
          tone: _primaryTone,
          fullWidth: stack,
          onPressed: primaryAction!.onPressed,
        ),
      );
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
