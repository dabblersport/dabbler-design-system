import 'package:flutter/material.dart'
    show RefreshIndicator, RefreshIndicatorStatus;
import 'package:flutter/widgets.dart';

import '../feedback/spinner.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';

/// Refresh — pull-to-refresh with the system's own indicator (KAN-409 item 3).
///
/// ```dart
/// DabblerRefresh(
///   onRefresh: () => repository.reload(),
///   child: ListView(children: rows),
/// );
/// ```
///
/// The gesture is Flutter's [RefreshIndicator.noSpinner] — drag tracking,
/// arming, edge detection and the `onRefresh` future are the framework's, and
/// it paints **nothing**. Every pixel shown is [DabblerSpinner] in
/// [DabblerSpinnerTone.brand]: still while the user drags, turning once armed
/// and while [onRefresh] is pending, gone when it completes. No Material
/// spinner, disc or elevation reaches the screen.
///
/// [child] must be a vertically scrolling widget whose physics allow
/// overscroll (any [ListView] or [CustomScrollView] does).
class DabblerRefresh extends StatefulWidget {
  /// Wraps [child] with pull-to-refresh.
  const DabblerRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.label,
  });

  /// The scrollable being refreshed.
  final Widget child;

  /// Called once the pull is armed and released. The indicator turns until the
  /// returned future completes.
  final Future<void> Function() onRefresh;

  /// The indicator's accessible label; [DabblerSpinner.defaultLabel] if null.
  final String? label;

  /// The gap between the top edge and the indicator — [DabblerSpacing.space4].
  static const double inset = DabblerSpacing.space4;

  /// Finds the indicator in a test.
  static const Key indicatorKey = ValueKey<String>('dabbler-refresh-indicator');

  @override
  State<DabblerRefresh> createState() => _DabblerRefreshState();
}

class _DabblerRefreshState extends State<DabblerRefresh> {
  RefreshIndicatorStatus? _status;

  bool get _visible => switch (_status) {
    RefreshIndicatorStatus.drag ||
    RefreshIndicatorStatus.armed ||
    RefreshIndicatorStatus.snap ||
    RefreshIndicatorStatus.refresh => true,
    _ => false,
  };

  bool get _turning => switch (_status) {
    RefreshIndicatorStatus.armed ||
    RefreshIndicatorStatus.snap ||
    RefreshIndicatorStatus.refresh => true,
    _ => false,
  };

  void _onStatus(RefreshIndicatorStatus? status) {
    if (!mounted || status == _status) return;
    setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        RefreshIndicator.noSpinner(
          onRefresh: widget.onRefresh,
          onStatusChange: _onStatus,
          child: widget.child,
        ),
        PositionedDirectional(
          top: DabblerRefresh.inset,
          start: 0,
          end: 0,
          child: IgnorePointer(
            child: Center(
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: DabblerMotion.base,
                curve: DabblerMotion.easeOut,
                child: _visible
                    ? DabblerSpinner(
                        key: DabblerRefresh.indicatorKey,
                        label: widget.label,
                        animate: _turning,
                      )
                    : const SizedBox.square(dimension: DabblerSizing.iconMd),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
