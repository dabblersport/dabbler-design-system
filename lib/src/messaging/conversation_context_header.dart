/// Part of the `conversation_context.dart` library — the private header row ([_Header]) and its state.
///
/// **Why `part`, not a separate library.** The file stood over the
/// project's 500-line house rule (`013`). These declarations were moved
/// verbatim; `part`/`part of` keeps one logical library, so private names
/// stay private and no public API changes. No exemption was recorded.
///
/// The imports are the library's — a part file declares none of its own.
part of 'conversation_context.dart';

class _Header extends StatefulWidget {
  const _Header({required this.owner});

  final DabblerConversationContext owner;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final DabblerConversationContext o = widget.owner;
    final DabblerColors colors = DabblerColors.of(context);
    final bool cancelled = o.status == DabblerActivityStatus.cancelled;
    final bool done = o.status == DabblerActivityStatus.completed;
    final Color? tint = cancelled
        ? colors.status(DabblerStatusTone.error).base
        : done
        ? colors.textSecondary
        : null;
    final Widget glyph = DabblerSportIcon(
      o.sport,
      weight: DabblerIconWeight.bold,
      size: 20,
      color: tint ?? colors.brandPrimary,
    );
    final Widget tile = tint == null
        ? DabblerIconTile(glyph, size: 36)
        : DabblerIconTile.tinted(glyph, color: tint, size: 36);
    final bool reduce = DabblerMotion.reduceMotion(context);

    final Widget row = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: DabblerSizing.touchTargetMin,
      ),
      child: Padding(
        padding: const EdgeInsets.all(DabblerSpacing.space4),
        child: Row(
          children: <Widget>[
            KeyedSubtree(
              key: const ValueKey<String>('conversation-context-tile'),
              child: tile,
            ),
            const SizedBox(width: DabblerSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    o.title,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: _t(context, DabblerType.footnote).copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      decorationColor: colors.textPrimary,
                      decoration: cancelled
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  Text(
                    '${o.when} · ${o.venue}',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: _t(
                      context,
                      DabblerType.caption1,
                    ).copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DabblerSpacing.space3),
            DabblerBadge(
              label: o.resolvedStatusLabel,
              status: o.status.tone == null
                  ? DabblerBadge.neutralStatusOf(colors)
                  : colors.status(o.status.tone!),
            ),
            const SizedBox(width: DabblerSpacing.space3),
            AnimatedRotation(
              key: const ValueKey<String>('conversation-context-chevron'),
              turns: o.collapsed ? 0 : 0.5,
              duration: reduce ? Duration.zero : DabblerMotion.base,
              curve: DabblerMotion.easeOut,
              child: DabblerIcon(
                'arrow-circle-down',
                size: DabblerSizing.iconSm,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      expanded: !o.collapsed,
      label: '${o.title}, ${o.when} · ${o.venue}, ${o.resolvedStatusLabel}',
      onTap: o.onToggle,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          enabled: o.onToggle != null,
          mouseCursor: o.onToggle != null
              ? SystemMouseCursors.click
              : MouseCursor.defer,
          onShowFocusHighlight: (bool v) => setState(() => _focused = v),
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent _) {
                o.onToggle?.call();
                return null;
              },
            ),
          },
          child: GestureDetector(
            key: const ValueKey<String>('conversation-context-header'),
            behavior: HitTestBehavior.opaque,
            onTap: o.onToggle,
            child: DabblerFocusRing.visible(
              visible: _focused,
              borderRadius: DabblerRadius.lgAll,
              child: row,
            ),
          ),
        ),
      ),
    );
  }
}
