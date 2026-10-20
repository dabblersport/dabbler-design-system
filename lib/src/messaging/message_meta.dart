/// Part of the `message.dart` library — the metadata line under a bubble
/// (timestamp, edited, delivery glyph and word, group receipt count, Retry).
///
/// **Why `part`, not a separate library.** `message.dart` would otherwise pass
/// the project's 500-line house rule (`013`) with the receipt rules. `part`/
/// `part of` keeps one logical library and private names private; no public API
/// changes. No exemption was recorded.
///
/// The imports are the library's — a part file declares none of its own.
part of 'message.dart';

/// The metadata line, a library-private extension so `message.dart` stays
/// under the rule.
///
/// Source rules (`Message` in `components/messaging/messaging.jsx`, messaging
/// §11):
///
/// * `inFlight` = sending, retrying or failed.
/// * `groupReceipt` = outgoing, group, not in flight, and a [receipt] given.
/// * `showDelivery` = outgoing, a delivery state, no group receipt, and either
///   direct context or in flight.
/// * the word shows when failed, or when `showDelivery` and
///   [DabblerMessage.showDeliveryLabel] (or group, where only in-flight and
///   failed reach here).
///
/// Deviation, as for Retry: the source pulls the receipt count and Retry back
/// into the line with negative margins so their 45px targets overlap their
/// neighbours. Flutter cannot hit-test outside a box's layout, so the line
/// grows to 45px when either shows.
extension _MessageMeta on DabblerMessage {
  Widget? _meta(
    BuildContext buildContext,
    DabblerColors colors,
    TextDirection dir,
  ) {
    final bool out = direction == DabblerMessageDirection.outgoing;
    final bool group = context == DabblerMessageContext.group;
    final DabblerDeliveryState? d = deliveryState;
    final bool failed = d == DabblerDeliveryState.failed;
    final bool inFlight = failed || (d?.inFlight ?? false);
    final DabblerReceipt? r = receipt;
    final bool groupReceipt = out && group && !inFlight && r != null;
    final bool showDelivery =
        out && d != null && !groupReceipt && (!group || inFlight);
    final bool labelled =
        failed || (showDelivery && (showDeliveryLabel || group));
    if (!DabblerMessage.trails(groupPosition) ||
        !(timestamp != null || showDelivery || edited || groupReceipt)) {
      return null;
    }

    final TextStyle caption1 = DabblerType.caption1.resolveForDirection(dir);
    final Color metaColor = failed ? colors.error.strong : colors.textSecondary;
    final String word = d == null
        ? ''
        : (deliveryLabel ?? DabblerDeliveryCopy.label(d, lang));

    return Padding(
      padding: const EdgeInsets.only(
        left: DabblerSpacing.space1,
        right: DabblerSpacing.space1,
        top: DabblerMessagingSpacing.metaGap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (timestamp != null)
            Text(timestamp!, style: caption1.copyWith(color: metaColor)),
          if (edited) ...<Widget>[
            const SizedBox(width: DabblerSpacing.space1),
            Text('· $editedLabel', style: caption1.copyWith(color: metaColor)),
          ],
          if (showDelivery) ...<Widget>[
            const SizedBox(width: DabblerSpacing.space1),
            Flexible(
              child: Semantics(
                label: word,
                image: true,
                excludeSemantics: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DabblerIcon(
                      d.icon,
                      weight: d.weight,
                      size: DabblerMessage.deliveryGlyph,
                      color: d.colorFor(colors),
                    ),
                    if (labelled) ...<Widget>[
                      const SizedBox(width: DabblerSpacing.space1),
                      Flexible(
                        child: Text(
                          word,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: caption1.copyWith(
                            color: d.colorFor(colors),
                            fontWeight: failed
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          if (groupReceipt) ...<Widget>[
            const SizedBox(width: DabblerSpacing.space1),
            Flexible(
              child: DabblerMessagingTap(
                key: DabblerMessage.receiptsKey,
                onTap: onReceipts,
                label: r.text(lang),
                scale: false,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: onReceipts == null
                        ? 0
                        : DabblerSizing.touchTargetMin,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DabblerIcon(
                        r.state.icon,
                        weight: r.state.weight,
                        size: DabblerMessage.deliveryGlyph,
                        color: r.state.colorFor(colors),
                      ),
                      const SizedBox(width: DabblerSpacing.space1),
                      Flexible(
                        child: Text(
                          r.text(lang),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: caption1.copyWith(
                            color: r.state.colorFor(colors),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (failed && onRetry != null) ...<Widget>[
            const SizedBox(width: DabblerSpacing.space1),
            DabblerMessagingTap(
              key: DabblerMessage.retryKey,
              onTap: onRetry,
              label: retryLabel ?? DabblerDeliveryCopy.retry(lang),
              scale: false,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: DabblerSizing.touchTargetMin,
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    retryLabel ?? DabblerDeliveryCopy.retry(lang),
                    style: caption1.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.error.strong,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
