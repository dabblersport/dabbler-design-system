/// Swipe-to-reveal row actions (KAN-410 item a).
library;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';

part 'swipe_action_item.dart';

/// A row that slides toward its inline-end edge to reveal [actions] behind it.
///
/// ```dart
/// DabblerSwipeAction(
///   actions: <DabblerSwipeActionItem>[
///     DabblerSwipeActionItem(
///       label: 'Hide',
///       icon: 'eye-slash',
///       tone: DabblerSwipeActionTone.destructive,
///       onPressed: hidePost,
///     ),
///   ],
///   child: DabblerNewsCard(...),
/// )
/// ```
///
/// * **Direction.** The actions sit at the inline **end**; the row is dragged
///   toward the start to reveal them — leftward in English, rightward in
///   Arabic.
/// * **Closing.** Tapping an action fires it and closes the row; tapping the
///   open row, or dragging it back, closes it without firing anything.
/// * **No gesture required.** Every action is also a semantics custom action
///   on the row, so a screen reader can invoke it without swiping.
/// * **Inside lists.** Only horizontal drags are claimed, so a vertical
///   scrollable around it keeps scrolling. There is no dismiss animation and
///   no `Dismissible`: the row never leaves the list on its own.
class DabblerSwipeAction extends StatefulWidget {
  /// A swipeable [child] revealing [actions].
  const DabblerSwipeAction({
    super.key,
    required this.child,
    required this.actions,
    this.enabled = true,
  }) : assert(actions.length > 0, 'a swipe action needs at least one action');

  /// The row. Its own height is the revealed actions' height.
  final Widget child;

  /// The actions, in reading order from the row's edge outward.
  final List<DabblerSwipeActionItem> actions;

  /// False disables the gesture and the semantics actions.
  final bool enabled;

  /// Each revealed box's width: `space11 + space8` (72).
  static const double actionWidth =
      DabblerSpacing.space11 + DabblerSpacing.space8;

  @override
  State<DabblerSwipeAction> createState() => DabblerSwipeActionState();
}

/// The state of a [DabblerSwipeAction]; [open] and [close] drive it from code.
class DabblerSwipeActionState extends State<DabblerSwipeAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: DabblerMotion.slow,
  );

  double get _extent => DabblerSwipeAction.actionWidth * widget.actions.length;

  /// Whether the actions are (partly or fully) revealed.
  bool get isOpen => _controller.value > 0;

  /// Reveals the actions.
  void open() => _controller.animateTo(1, curve: DabblerMotion.easeOut);

  /// Hides the actions.
  void close() => _controller.animateTo(0, curve: DabblerMotion.easeOut);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// +1 when a positive dx opens the row (RTL), -1 when it closes it (LTR).
  double _openSign(BuildContext context) =>
      Directionality.of(context) == TextDirection.rtl ? 1 : -1;

  void _onDragUpdate(DragUpdateDetails d) {
    final double delta = d.primaryDelta! * _openSign(context);
    _controller.value = (_controller.value + delta / _extent).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails d) {
    final double v = d.primaryVelocity! * _openSign(context);
    if (v > DabblerSwipeAction.actionWidth * 5) {
      open();
    } else if (v < -DabblerSwipeAction.actionWidth * 5) {
      close();
    } else if (_controller.value >= 0.5) {
      open();
    } else {
      close();
    }
  }

  void _fire(DabblerSwipeActionItem item) {
    item.onPressed();
    close();
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final double sign = _openSign(context);
    final Map<CustomSemanticsAction, VoidCallback> semanticsActions =
        <CustomSemanticsAction, VoidCallback>{
          if (widget.enabled)
            for (final DabblerSwipeActionItem item in widget.actions)
              CustomSemanticsAction(label: item.label): () => _fire(item),
        };
    return Semantics(
      customSemanticsActions: semanticsActions,
      child: GestureDetector(
        onHorizontalDragUpdate: widget.enabled ? _onDragUpdate : null,
        onHorizontalDragEnd: widget.enabled ? _onDragEnd : null,
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            child: widget.child,
            builder: (BuildContext context, Widget? child) {
              final double t = _controller.value;
              return Stack(
                fit: StackFit.passthrough,
                children: <Widget>[
                  PositionedDirectional(
                    top: 0,
                    bottom: 0,
                    end: 0,
                    width: _extent,
                    child: IgnorePointer(
                      ignoring: t == 0,
                      child: ExcludeSemantics(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            for (final DabblerSwipeActionItem item
                                in widget.actions)
                              SizedBox(
                                width: DabblerSwipeAction.actionWidth,
                                child: _ActionBox(
                                  item: item,
                                  onTap: () => _fire(item),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(sign * t * _extent, 0),
                    child: Stack(
                      fit: StackFit.passthrough,
                      children: <Widget>[
                        ColoredBox(color: colors.bgPrimary, child: child),
                        if (t > 0)
                          Positioned.fill(
                            child: GestureDetector(
                              key: const ValueKey<String>('swipe-action-scrim'),
                              behavior: HitTestBehavior.opaque,
                              onTap: close,
                              excludeFromSemantics: true,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
