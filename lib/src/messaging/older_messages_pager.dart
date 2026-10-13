/// OlderMessagesPager — the control at the top of a thread that loads the
/// previous page.
library;

import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../feedback/spinner.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// Where the older-messages load is.
enum DabblerOlderMessagesState {
  /// More history is available; the button loads it.
  idle,

  /// A page is on its way.
  loading,

  /// The last attempt failed; the caller's text and a retry button show.
  error,
}

/// Loads older messages: a button when [DabblerOlderMessagesState.idle], a
/// spinner with text while loading, an error line with retry on failure.
///
/// Every string is the caller's. The widget wraps, so a 200 percent text scale
/// grows it instead of clipping.
class DabblerOlderMessagesPager extends StatelessWidget {
  /// A pager in [state].
  const DabblerOlderMessagesPager({
    super.key,
    this.state = DabblerOlderMessagesState.idle,
    required this.idleLabel,
    required this.loadingLabel,
    required this.errorText,
    required this.retryLabel,
    this.onLoad,
    this.onRetry,
  });

  /// The current state.
  final DabblerOlderMessagesState state;

  /// The idle button's label.
  final String idleLabel;

  /// Shown beside the spinner while loading.
  final String loadingLabel;

  /// Shown when the load failed.
  final String errorText;

  /// The retry button's label.
  final String retryLabel;

  /// Called by the idle button.
  final VoidCallback? onLoad;

  /// Called by the retry button.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final TextStyle caption = DabblerType.caption1
        .resolveForDirection(dir)
        .copyWith(color: colors.textSecondary);
    final Widget content = switch (state) {
      DabblerOlderMessagesState.idle => DabblerButton(
        label: idleLabel,
        tone: DabblerButtonTone.outlined,
        size: DabblerButtonSize.small,
        onPressed: onLoad,
      ),
      DabblerOlderMessagesState.loading => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const DabblerSpinner(size: DabblerSpinnerSize.sm),
          const SizedBox(width: DabblerSpacing.space3),
          Flexible(child: Text(loadingLabel, style: caption)),
        ],
      ),
      DabblerOlderMessagesState.error => Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: DabblerSpacing.space3,
        runSpacing: DabblerSpacing.space2,
        children: <Widget>[
          Text(
            errorText,
            style: caption.copyWith(
              color: colors.status(DabblerStatusTone.error).strong,
            ),
          ),
          DabblerButton(
            label: retryLabel,
            tone: DabblerButtonTone.outlined,
            size: DabblerButtonSize.small,
            onPressed: onRetry,
          ),
        ],
      ),
    };
    return Semantics(
      container: true,
      liveRegion: state != DabblerOlderMessagesState.idle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DabblerSpacing.space4,
          horizontal: DabblerSpacing.space4,
        ),
        child: Center(child: content),
      ),
    );
  }
}
