import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/text.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'card.dart';

/// TransactionRow — one money line in a history list, as a tappable card: a
/// leading tile, a title with a status badge beside it, a detail line, a
/// caption, and the amount with its time at the inline end.
///
/// ```dart
/// DabblerTransactionRow(
///   leading: const DabblerIconTile.named('calendar'),
///   title: 'Court Booking',
///   badge: const DabblerBadge(label: 'COMPLETED'),
///   detail: 'Zayed Sports City',
///   detailIcon: 'building',
///   caption: 'Visa •••• 4242',
///   amount: '-AED 200',
///   amountCaption: '2h ago',
///   onTap: openDetails,
/// )
/// ```
///
/// ## What it owns
///
/// The card shell, the gaps and every text style: the title is
/// [DabblerType.subheadline] at weight 600 (one line, ellipsis); the detail
/// is [DabblerType.footnote] in the secondary ink after an optional small
/// glyph; the caption and [amountCaption] are [DabblerType.caption2]; the
/// [amount] is [DabblerType.headline], in the success ink when
/// [amountTone] says so.
///
/// ## RTL
///
/// The leading tile sits at the inline start and the amount column at the
/// inline end; the amount is right-aligned in LTR and left-aligned in RTL.
class DabblerTransactionRow extends StatelessWidget {
  /// A transaction row.
  const DabblerTransactionRow({
    super.key,
    required this.title,
    required this.amount,
    this.leading,
    this.badge,
    this.detail,
    this.detailIcon,
    this.caption,
    this.amountCaption,
    this.amountTone = DabblerTextTone.primary,
    this.onTap,
    this.semanticLabel,
  });

  /// The main line.
  final String title;

  /// The amount, signed and with its currency, as it should read.
  final String amount;

  /// The inline-start slot — an icon tile.
  final Widget? leading;

  /// A status badge shown after the title.
  final Widget? badge;

  /// The second line — a counterparty or place.
  final String? detail;

  /// A small glyph before [detail], by name.
  final String? detailIcon;

  /// The third line — a payment method.
  final String? caption;

  /// A small line under [amount] — its time.
  final String? amountCaption;

  /// The ink of [amount]; `success` for money in.
  final DabblerTextTone amountTone;

  /// Makes the whole row a button.
  final VoidCallback? onTap;

  /// The accessible name of a tappable row.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return DabblerCard(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: Row(
        children: <Widget>[
          if (leading != null) ...<Widget>[
            leading!,
            const SizedBox(width: DabblerSpacing.space4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DabblerText(
                        title,
                        style: DabblerType.subheadline,
                        weight: DabblerTextWeight.semibold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badge != null) ...<Widget>[
                      const SizedBox(width: DabblerSpacing.space3),
                      badge!,
                    ],
                  ],
                ),
                if (detail != null) ...<Widget>[
                  const SizedBox(height: DabblerSpacing.space1),
                  Row(
                    children: <Widget>[
                      if (detailIcon != null) ...<Widget>[
                        DabblerIcon(
                          detailIcon!,
                          size: DabblerSizing.iconXs,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: DabblerSpacing.space1),
                      ],
                      Expanded(
                        child: DabblerText(
                          detail!,
                          style: DabblerType.footnote,
                          tone: DabblerTextTone.secondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (caption != null)
                  DabblerText(
                    caption!,
                    style: DabblerType.caption2,
                    tone: DabblerTextTone.secondary,
                  ),
              ],
            ),
          ),
          const SizedBox(width: DabblerSpacing.space4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              DabblerText(
                amount,
                style: DabblerType.headline,
                tone: amountTone,
              ),
              if (amountCaption != null)
                DabblerText(
                  amountCaption!,
                  style: DabblerType.caption2,
                  tone: DabblerTextTone.secondary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
