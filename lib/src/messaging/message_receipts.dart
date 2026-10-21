import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../overlays/sheet.dart';
import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'messaging_foundations.dart';

/// Delivery and receipt copy — `DELIVERY_LABELS` and `receiptText` in the
/// source (messaging §11). The package ships no localised strings of its own;
/// these two languages are the messaging set, and every widget that reads them
/// also takes an explicit override.
abstract final class DabblerDeliveryCopy {
  const DabblerDeliveryCopy._();

  static const Map<String, Map<String, String>> _labels =
      <String, Map<String, String>>{
        'en': <String, String>{
          'sending': 'Sending',
          'retrying': 'Retrying',
          'sent': 'Sent',
          'delivered': 'Delivered',
          'seen': 'Seen',
          'failed': 'Not sent',
          'retry': 'Retry',
        },
        'ar': <String, String>{
          'sending': 'جارٍ الإرسال',
          'retrying': 'جارٍ إعادة المحاولة',
          'sent': 'أُرسلت',
          'delivered': 'وصلت',
          'seen': 'شوهدت',
          'failed': 'لم تُرسل',
          'retry': 'أعد المحاولة',
        },
      };

  /// The word for [state] in [lang] (`en` or `ar`; anything else is English).
  static String label(DabblerDeliveryState state, [String lang = 'en']) =>
      (_labels[lang] ?? _labels['en']!)[state.name]!;

  /// The default Retry word in [lang].
  static String retry([String lang = 'en']) =>
      (_labels[lang] ?? _labels['en']!)['retry']!;
}

/// How many recipients of a group message have received and seen it — the
/// source's `receipt` prop. Counts, never a tick per person.
@immutable
class DabblerReceipt {
  /// A receipt tally. [delivered] counts everyone the server has delivered to
  /// including those who have also seen it; [total] is the recipient count.
  const DabblerReceipt({this.seen = 0, this.delivered = 0, this.total = 0});

  /// Recipients who have viewed the message.
  final int seen;

  /// Recipients whose device has received the message.
  final int delivered;

  /// Everyone the message was sent to.
  final int total;

  /// The state the tally reads as: seen when anyone saw it, delivered when
  /// anyone received it, otherwise sent.
  DabblerDeliveryState get state => seen > 0
      ? DabblerDeliveryState.seen
      : delivered > 0
      ? DabblerDeliveryState.delivered
      : DabblerDeliveryState.sent;

  /// The compact group label (`receiptText` in the source):
  ///
  /// | tally | English |
  /// |---|---|
  /// | seen ≥ total | Seen by everyone |
  /// | seen > 0 | Seen by 4 of 9 |
  /// | delivered > 0 | Delivered to 7 of 9 |
  /// | otherwise | Sent |
  String text([String lang = 'en']) {
    final bool ar = lang == 'ar';
    if (total > 0 && seen >= total) {
      return ar ? 'شاهدها الجميع' : 'Seen by everyone';
    }
    if (seen > 0) {
      return ar ? 'شاهدها $seen من $total' : 'Seen by $seen of $total';
    }
    if (delivered > 0) {
      return ar
          ? 'وصلت إلى $delivered من $total'
          : 'Delivered to $delivered of $total';
    }
    return ar ? 'أُرسلت' : 'Sent';
  }

  @override
  bool operator ==(Object other) =>
      other is DabblerReceipt &&
      other.seen == seen &&
      other.delivered == delivered &&
      other.total == total;

  @override
  int get hashCode => Object.hash(seen, delivered, total);
}

/// One person in the Message info drawer.
@immutable
class DabblerReceiptPerson {
  /// A person row: [name] and an optional [subtitle] and [time].
  const DabblerReceiptPerson({
    required this.name,
    this.subtitle,
    this.time,
    this.avatarSeed,
  });

  /// The display name.
  final String name;

  /// A second line, e.g. a role.
  final String? subtitle;

  /// When they received or saw it. Absent for people it has not reached.
  final String? time;

  /// The avatar seed; defaults to [name].
  final String? avatarSeed;
}

/// One list in the Message info drawer: everyone in a single [state].
@immutable
class DabblerReceiptGroup {
  /// A group of people. [state] picks the glyph and tone: [seen](DabblerDeliveryState.seen),
  /// [delivered](DabblerDeliveryState.delivered) or [sent](DabblerDeliveryState.sent)
  /// for "not delivered yet".
  const DabblerReceiptGroup({
    required this.state,
    required this.people,
    this.label,
    this.shortLabel,
  });

  /// The state every person in [people] is in.
  final DabblerDeliveryState state;

  /// The people.
  final List<DabblerReceiptPerson> people;

  /// The list heading (`Seen by`). Defaults to the English or Arabic set.
  final String? label;

  /// The summary tile caption (`Seen`). Defaults to the English or Arabic set.
  final String? shortLabel;

  /// The default list heading for [state] in [lang].
  static String headingFor(DabblerDeliveryState state, String lang) {
    final bool ar = lang == 'ar';
    return switch (state) {
      DabblerDeliveryState.seen => ar ? 'شاهدها' : 'Seen by',
      DabblerDeliveryState.delivered => ar ? 'وصلت إلى' : 'Delivered to',
      _ => ar ? 'لم تصل بعد' : 'Not delivered yet',
    };
  }

  /// The default tile caption for [state] in [lang].
  static String captionFor(DabblerDeliveryState state, String lang) {
    final bool ar = lang == 'ar';
    return switch (state) {
      DabblerDeliveryState.seen => ar ? 'شوهدت' : 'Seen',
      DabblerDeliveryState.delivered => ar ? 'وصلت' : 'Delivered',
      _ => ar ? 'لم تصل' : 'Not yet',
    };
  }
}

/// ReceiptsSheet — the Message info drawer (messaging §11, frames 29-30, 46-48).
///
/// The message, a row of summary tiles (Seen · Delivered · Not yet), then one
/// list per group with the people and the time each was reached. Presentation
/// only: props in, [onClose] out, no network. Group order and membership are
/// the caller's; empty groups keep their tile but have no list.
///
/// [show] pushes it as a content-height [DabblerSheet], which owns the drawer
/// motion (a 200ms slide under `--ease-out` with the scrim fading beside it;
/// under reduced motion the transform is dropped and both layers crossfade).
/// Build the widget directly to embed the same body elsewhere.
class DabblerReceiptsSheet extends StatelessWidget {
  /// The drawer body.
  const DabblerReceiptsSheet({
    super.key,
    this.preview,
    this.groups = const <DabblerReceiptGroup>[],
    this.note,
    this.lang = 'en',
    this.allLabel,
    this.nobodyLabel,
  });

  /// The message being inspected, drawn as a brand bubble (two lines at most).
  final String? preview;

  /// The groups, in display order.
  final List<DabblerReceiptGroup> groups;

  /// A footnote under the lists, e.g. a privacy line.
  final String? note;

  /// `en` or `ar`, for the default headings and captions.
  final String lang;

  /// The tile value shown instead of a count when every recipient is in that
  /// state (Seen and Delivered tiles). Defaults to `All` / `الجميع`.
  final String? allLabel;

  /// The tile value shown instead of 0 on the Not yet tile. Defaults to
  /// `Nobody` / `لا أحد`.
  final String? nobodyLabel;

  /// The default [allLabel] in [lang].
  static String defaultAll(String lang) => lang == 'ar' ? 'الجميع' : 'All';

  /// The default [nobodyLabel] in [lang].
  static String defaultNobody(String lang) =>
      lang == 'ar' ? 'لا أحد' : 'Nobody';

  /// The value a tile for [g] shows: a word where it reads better than the
  /// count, else the count. [total] is every recipient across all groups.
  /// Seen and Delivered read "All" when every recipient is in the state; Not
  /// yet reads "Nobody" at zero and never "All".
  String _tileValue(DabblerReceiptGroup g, int total) {
    final int n = g.people.length;
    if (g.state == DabblerDeliveryState.seen ||
        g.state == DabblerDeliveryState.delivered) {
      return total > 0 && n == total ? (allLabel ?? defaultAll(lang)) : '$n';
    }
    return n == 0 ? (nobodyLabel ?? defaultNobody(lang)) : '$n';
  }

  /// Identifies summary tile [index] (for tests and tooling).
  static Key tileKeyAt(int index) => ValueKey<String>('receipts-tile-$index');

  /// Identifies person [person] of group [group].
  static Key personKeyAt(int group, int person) =>
      ValueKey<String>('receipts-person-$group-$person');

  /// Shows the drawer. [title] defaults to `Message info` / `معلومات الرسالة`.
  static Future<void> show(
    BuildContext context, {
    String? title,
    String? preview,
    List<DabblerReceiptGroup> groups = const <DabblerReceiptGroup>[],
    String? note,
    String lang = 'en',
    String? closeLabel,
    String? allLabel,
    String? nobodyLabel,
  }) {
    return showDabblerSheet<void>(
      context: context,
      title: title ?? (lang == 'ar' ? 'معلومات الرسالة' : 'Message info'),
      detent: DabblerSheetDetent.content,
      closeLabel: closeLabel ?? DabblerSheet.defaultCloseLabel,
      builder: (BuildContext _) => DabblerReceiptsSheet(
        preview: preview,
        groups: groups,
        note: note,
        lang: lang,
        allLabel: allLabel,
        nobodyLabel: nobodyLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final TextStyle caption1 = DabblerType.caption1.resolveForDirection(dir);
    final int total = groups.fold<int>(
      0,
      (int sum, DabblerReceiptGroup g) => sum + g.people.length,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DabblerSpacing.space4,
      children: <Widget>[
        if (preview != null)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FractionallySizedBox(
              widthFactor: 0.86,
              alignment: AlignmentDirectional.centerEnd,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.brandPrimary,
                  borderRadius: const BorderRadiusDirectional.only(
                    topStart: Radius.circular(DabblerRadius.xl),
                    topEnd: Radius.circular(DabblerRadius.xl),
                    bottomStart: Radius.circular(DabblerRadius.xl),
                    bottomEnd: Radius.circular(DabblerRadius.sm),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: DabblerMessagingSpacing.bubbleBlock,
                    horizontal: DabblerMessagingSpacing.bubbleInline,
                  ),
                  child: Text(
                    preview!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: DabblerType.subheadline
                        .resolveForDirection(dir)
                        .copyWith(color: colors.onBrand),
                  ),
                ),
              ),
            ),
          ),
        if (groups.isNotEmpty)
          Row(
            spacing: DabblerSpacing.space2,
            children: <Widget>[
              for (int gi = 0; gi < groups.length; gi++)
                Expanded(
                  child: _tile(groups[gi], gi, total, colors, dir, caption1),
                ),
            ],
          ),
        for (int gi = 0; gi < groups.length; gi++)
          if (groups[gi].people.isNotEmpty)
            _list(groups[gi], gi, caption1, colors),
        if (note != null)
          Text(note!, style: caption1.copyWith(color: colors.textSecondary)),
      ],
    );
  }

  Widget _tile(
    DabblerReceiptGroup g,
    int gi,
    int total,
    DabblerColors colors,
    TextDirection dir,
    TextStyle caption1,
  ) {
    final String value = _tileValue(g, total);
    final String caption =
        g.shortLabel ?? DabblerReceiptGroup.captionFor(g.state, lang);
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '$caption: $value',
      child: DecoratedBox(
        key: tileKeyAt(gi),
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          borderRadius: DabblerRadius.mdAll,
        ),
        child: Padding(
          padding: const EdgeInsets.all(DabblerSpacing.space3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: DabblerSpacing.space1,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: DabblerSpacing.space1,
                children: <Widget>[
                  DabblerIcon(
                    g.state.icon,
                    weight: g.state.weight,
                    size: 16,
                    color: g.state.colorFor(colors),
                  ),
                  // A word ("Nobody") is wider than a digit: shrink to fit the
                  // tile instead of clipping it.
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        value,
                        maxLines: 1,
                        style: DabblerType.headline
                            .resolveForDirection(dir)
                            .copyWith(color: colors.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: caption1.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(
    DabblerReceiptGroup g,
    int gi,
    TextStyle caption1,
    DabblerColors colors,
  ) {
    final String heading =
        g.label ?? DabblerReceiptGroup.headingFor(g.state, lang);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: DabblerSpacing.space1),
          child: Text(
            '$heading · ${g.people.length}',
            style: caption1.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textSecondary,
            ),
          ),
        ),
        for (int i = 0; i < g.people.length; i++)
          _PersonRow(
            key: personKeyAt(gi, i),
            person: g.people[i],
            divider: i < g.people.length - 1,
          ),
      ],
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({super.key, required this.person, required this.divider});

  final DabblerReceiptPerson person;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? Border(
                bottom: BorderSide(
                  color: colors.borderDefault,
                  width: DabblerSizing.borderDefault,
                ),
              )
            : null,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: DabblerSizing.touchTargetMin,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DabblerSpacing.space2),
          child: Row(
            spacing: DabblerSpacing.space3,
            children: <Widget>[
              DabblerAvatar(
                seed: person.avatarSeed ?? person.name,
                size: DabblerAvatarSize.sm,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      person.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DabblerType.subheadline
                          .resolveForDirection(dir)
                          .copyWith(color: colors.textPrimary),
                    ),
                    if (person.subtitle != null)
                      Text(
                        person.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DabblerType.caption1
                            .resolveForDirection(dir)
                            .copyWith(color: colors.textSecondary),
                      ),
                  ],
                ),
              ),
              if (person.time != null)
                Text(
                  person.time!,
                  style: DabblerType.caption1
                      .resolveForDirection(dir)
                      .copyWith(color: colors.textSecondary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
