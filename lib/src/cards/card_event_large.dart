import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/sport_background.dart';
import '../foundations/sport_icon.dart';
import '../foundations/sports.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'card.dart';

/// The event card family's geometry — **every value in it is ruled by
/// `DECISIONS.md` D-006, not transcribed from the design bundle.**
///
/// This block exists because the bundle carries no event card at all: its
/// exported `CardEvent*` nodes (`8:36`, `8:37`, `8:38`) are mis-labelled
/// settings rows, which [DabblerCardEventLarge]'s class doc records in full.
/// `cxo` confirmed that by `diff` and then ruled the geometry from the system
/// rather than leaving it to a component ticket to choose.
///
/// Everything a reader would otherwise have to hunt for across three widgets
/// and their tests is therefore declared once, here. The three widgets and
/// `test/cards/card_event_test.dart` all read these constants and none of them
/// repeats a literal, so a later amendment to D-006 — or the re-export of the
/// correct Figma nodes, which is in progress — is an edit to this block alone.
///
/// Values that are ordinary system tokens ([DabblerSpacing], [DabblerRadius],
/// [DabblerSizing]) are *not* here; they need no ruling and are taken at their
/// call sites as any other component takes them.
abstract final class DabblerCardEventGeometry {
  /// Large's cover ratio — **16:9**, full-bleed. D-006.
  ///
  /// Ruled, and it confirms what KAN-252 proposed: the sport artwork is a
  /// ~941×1672 *portrait* illustration and is a fallback rather than the
  /// intended cover, so the cover's own ratio could not be taken from it.
  static const double coverAspectRatio = 16 / 9;

  /// The radius Large's cover is clipped to.
  ///
  /// **The one place this file does not take D-006's literal, and the reason
  /// is a standing package ruling rather than a preference.** D-006 says the
  /// cover's top corners are **16**. The cover is full-bleed in
  /// [DabblerCard.media], which clips it to the *card's* corner, and this
  /// package's card corner is [DabblerCard.defaultRadius] — [DabblerRadius.lg]
  /// (12) — because 16 is not a step of the base-3 ramp and
  /// `tokens/spacing.css:27` annotates `--radius-lg` *"cards, icon tiles"*.
  /// [DabblerCard] and [DabblerCardHouse] both already record that same
  /// token-over-literal deviation against the same literal 16.
  ///
  /// Giving the cover its own 16 would either be invisible (the card clips
  /// first) or draw a second corner inside the first. So the cover inherits
  /// the card's corner, whatever that corner is.
  ///
  /// **Closed by D-018, and this constant needs no edit when it lands.**
  /// KAN-252 reported the 16-versus-12 conflict as a question, on the grounds
  /// that honouring 16 here would mean changing every card in the system.
  /// That is what `cxo` then decided: D-018 makes 16 a real card-corner step,
  /// [DabblerCard.defaultRadius] becomes 16, and [DabblerRadius.lg] (12) is
  /// redefined as the corner of a *tile inside* a card. D-006's cover 16 is
  /// therefore honoured unamended — by the card changing, not by the cover.
  ///
  /// Because this constant tracks [DabblerCard.defaultRadius] rather than a
  /// number, it follows D-018 automatically. D-018 lands as its own ticket,
  /// not this one.
  static const double coverCornerRadius = DabblerCard.defaultRadius;

  /// Medium's thumbnail side — **64**. D-006.
  ///
  /// Confirms KAN-252's proposal, with the same reasoning: 64 is the side
  /// `CardHouse.jsx` writes for a card's leading well and which
  /// [DabblerCardHouse.wellSide] already transcribes, so the two row cards
  /// stay the same height in a mixed list.
  static const double mediumThumbSide = 64;

  /// Medium's thumbnail radius — **12**, which is [DabblerRadius.lg] exactly.
  /// D-006, and no deviation: the ruled number is already a ramp step.
  static const double mediumThumbRadius = DabblerRadius.lg;

  /// Small's thumbnail side — **48**. D-006.
  ///
  /// **This replaces KAN-252's proposed 45, which `cxo` rejected**, and the
  /// rejection is worth keeping written down: 45 came from
  /// [DabblerSizing.touchTargetMin], which is a *hit-target floor* and not a
  /// thumbnail scale, and 45 is off the 4dp grid and off every scale in the
  /// system. 48 is on it.
  static const double smallThumbSide = 48;

  /// A row card's thumbnail corner — [DabblerRadius.lg] (12).
  ///
  /// D-006 rules Medium's radius at 12 and is silent on Small's; KAN-252
  /// carried the ruled step across rather than inventing a second, and named
  /// the constant a *fallback* while that was an inference.
  ///
  /// **It is not an inference any more, and the name no longer says
  /// fallback.** D-018 redefines [DabblerRadius.lg] as the corner of a tile
  /// *inside* a card, which is exactly what both row thumbnails are. 12 is the
  /// ruled value for this job, at both sizes.
  static const double rowThumbRadius = DabblerRadius.lg;

  /// The gap between a row card's thumbnail and its text column — **12**.
  /// D-006, and it is [DabblerSpacing.stackDefault] exactly: the `gap: 12`
  /// all three exported nodes carry, and the gap [DabblerCard] already puts
  /// between its own slots.
  static const double rowGap = DabblerSpacing.stackDefault;

  /// The sport-overlay well's diameter — **32**, filled
  /// [DabblerColors.surfaceCard]. D-006.
  ///
  /// Replaces KAN-252's proposed 36 ([DabblerSpacing.space10]).
  static const double overlayWellSide = 32;

  /// The mark inside that well — **24**, which is [DabblerSizing.iconMd]
  /// exactly. D-006, and no deviation.
  static const double overlayIconSize = DabblerSizing.iconMd;

  /// The well's inset from the image's bottom and **leading** edge — **8**.
  /// D-006.
  ///
  /// Replaces KAN-252's proposed 6. The *directional* half of the placement
  /// was proposed and confirmed: leading, not left, so the mark follows the
  /// reading order under RTL.
  static const double overlayInset = 8;
}


/// CardEventLarge — one event at full width: a cover image carrying the
/// sport's mark, the event's title, and the date/time and place beneath it.
///
/// **This file is the pattern-setter for the whole card-event family**
/// (KAN-252 AC1). [DabblerCardEventMedium] and [DabblerCardEventSmall] do not
/// re-derive the image treatment, the title truncation, the sport-icon overlay
/// or the metadata row — they call the statics declared here
/// ([mediaContent], [sportOverlay], [metaRow], [titleStyleFor],
/// [metaStyleFor]) so that the three sizes cannot drift apart.
///
/// ```dart
/// DabblerCardEventLarge(
///   title: 'Sunday five-a-side at Al Barsha Pond Park',
///   sport: DabblerSport.football,
///   dateTime: 'Sun 21 Sep · 18:00',
///   location: 'Al Barsha Pond Park',
///   onTap: () {},
/// )
/// ```
///
/// ## The design source for this component is the wrong component
///
/// **Read this before changing any value in this file.** The design bundle
/// ships `components/cards/CardEventLarge.jsx` (Figma node `8:36
/// Card/Event/Large`), `CardEventMedium.jsx` (`8:37`) and `CardEventSmall.jsx`
/// (`8:38`), and all three are *byte-identical settings rows*: a leading 24px
/// Iconsax glyph, a bold title, a caption subtitle and a 48×28 pill toggle on
/// the trailing edge. Their `.d.ts` defaults settle it — Large is
/// *"contacts" / "see which friends are already here"*, Medium is
/// *"microphone" / "enable mic so you can speak in rooms"*, Small is
/// *"notifications" / "get notified when friends go live"*. The specimen
/// (`components/cards/cards.card.html:57-58`) only renders the three at
/// `width: 400` and shows nothing further.
///
/// There is no cover image, no sport mark and no date/time anywhere in those
/// three files, and the only difference between the three "sizes" is the
/// default icon and the default copy. They are mis-exported Figma nodes, not
/// the event card.
///
/// Two other sources in the same bundle describe the real component, and they
/// agree with each other and with KAN-252 AC1:
///
/// * `components/cards/Card.jsx`'s own `VARIANTS` comment — quoted in
///   [DabblerCardVariant] — counts **Event** among the nine content-specific
///   cards drawn on the neutral-200 shell;
/// * DS-800's slot table, in [DabblerCard.media], names that slot's content as
///   *"`CardTicket`'s coloured header strip; **an event cover image**"*, and
///   [DabblerCard.gap] cites *"the source's own inter-slot gap on `CardHouse`
///   and `CardEventLarge`"* — i.e. 12, which this file takes.
///
/// So this component is built to AC1 and to the shell the source does
/// specify. Transcribing the exported node instead would have shipped three
/// identical settings rows under the name `CardEvent`.
///
/// ## Every value that has no source is ruled, and lives in one block
///
/// Because the exported node is the wrong component, the event cover's
/// geometry is **not specified anywhere in the bundle**. It is not invented
/// here either: `cxo` confirmed the mis-export by `diff` and ruled the
/// geometry from the system in `DECISIONS.md` **D-006** — cover 16:9, Medium
/// thumbnail 64 at radius 12, Small thumbnail 48, a 24 mark in a 32
/// `--surface-card` well inset 8 from the bottom and leading edges, row gap
/// 12.
///
/// Every one of those values is declared in [DabblerCardEventGeometry], with
/// the reasoning on each constant, and is read from there by all three widgets
/// and by the tests. Nothing in this family repeats a geometry literal, so
/// applying a later amendment — or the re-export of nodes `8:36`–`8:38`, which
/// is in progress — is an edit to that one block.
///
/// KAN-252 held two points open against D-006 rather than quietly diverging
/// from it, and **`cxo` closed both in the ticket's favour**:
///
/// * **D-022 — the sport overlay is Large's only.** D-006 ruled one overlay
///   geometry and did not carve out the smaller sizes; `cxo` recorded that as
///   its own omission rather than non-compliance here, and extended the
///   exemption to Medium as well. See the overlay section below.
/// * **D-018 — the cover's corner.** The 16-versus-12 conflict is resolved by
///   the *card* changing, not the cover; see
///   [DabblerCardEventGeometry.coverCornerRadius].
///
/// Everything else *is* source-backed: the shell is
/// [DabblerCardVariant.standard] (`backgroundColor: var(--neutral-200)`, no
/// border, which is what all three exported nodes paint), and the radius, the
/// padding and the inter-slot gap all come from [DabblerCard] rather than
/// being restated.
///
/// ## The image treatment (AC1)
///
/// One resolution order, declared once in [mediaContent] and used by all three
/// sizes:
///
/// 1. the caller's [cover] widget, if any;
/// 2. otherwise [DabblerSportBackground.maybe] for [sport];
/// 3. otherwise a flat [DabblerColors.surfaceGrey] well.
///
/// Step 2 **routinely returns null and that is not an error**:
/// `DabblerSportBackgroundRegistry` has no `main` artwork for `golf` or
/// `table-tennis`, and no artwork at all for the entire `matchDay` variant,
/// by design and without throwing. Step 3 is the normal result for those, not
/// a failure path. The art is never scrimmed, blurred or faded — the
/// background primitive forbids all four, and the quiet zone is composed into
/// the illustration.
///
/// ## The sport-icon overlay — Large's only (AC1, DS-301, D-022)
///
/// A circular [DabblerColors.surfaceCard] well carrying [DabblerSportIcon],
/// pinned to the **bottom-start** corner of the cover with
/// [PositionedDirectional] — so it sits bottom-left in LTR and bottom-right in
/// RTL, following the reading order rather than a fixed edge. It is flat: no
/// shadow, no ring, in keeping with the system's flat ruling. It is omitted
/// when [sport] is null.
///
/// **It is drawn at this size and at no other.** `DECISIONS.md` **D-022**:
/// the two row sizes do not carry it, Medium included. The rule it states is
/// deliberately *not* a size ladder, and `cxo` was explicit that it did not
/// want one invented:
///
/// > the overlay exists where the cover is large enough to still read as a
/// > cover underneath it.
///
/// A mark competing with the image for the image's own area is not a smaller
/// overlay — it is the wrong component. That is why [mediaContent] takes a
/// boolean and not a scale, and why there is one ruled well size rather than
/// three.
///
/// **A licensed sport glyph set shipping does not reopen this.** The obvious
/// wrong inference is *"turn it back on when the real icons land"*: a real
/// glyph at 32-on-48 is still 44% of the cover's area, which is the same
/// defect drawn better. It reopens only if a **smaller mark is drawn in the
/// design source**, and that would be a new node with its own geometry, not a
/// re-scaling of this one.
///
/// ## Title truncation (AC1)
///
/// [titleMaxLines] lines then [TextOverflow.ellipsis], at every size. Large
/// allows two lines because an event title is a sentence
/// (*"Sunday five-a-side at Al Barsha Pond Park"*); the two row cards allow
/// one, because a second line would push them past the row height the source's
/// Medium/Small frames set (`height: 78`). The cap is the same mechanism in
/// all three and is direction-independent — nothing about it changes under
/// RTL.
///
/// ## Date and time: the DS-602 seam
///
/// [dateTime] and [location] are **plain strings, already formatted**, and no
/// card in this family parses, formats or localises a date. DS-602 (the
/// date/time formatter AC1 names) was being written in parallel with this
/// ticket and is deliberately not imported.
///
/// **The follow-up, stated for whoever picks it up:** replace the
/// `String? dateTime` and `String? location` parameters — three call sites,
/// one per size — with DS-602's formatted value type, and call its formatter
/// where [metaRow] currently receives the string. [metaRow] is the single
/// place all three sizes render it, so the seam is one function wide and no
/// widget in this family needs to learn what a date is. Reported as a
/// hand-off with KAN-252.
class DabblerCardEventLarge extends StatelessWidget {
  /// A full-width event card for [title].
  const DabblerCardEventLarge({
    super.key,
    required this.title,
    this.sport,
    this.cover,
    this.dateTime,
    this.location,
    this.footer,
    this.onTap,
    this.enabled = true,
    this.semanticLabel,
    this.width,
  });

  /// The event's title. Truncated to [titleMaxLines] with an ellipsis.
  ///
  /// Required: an event card with no title is not a state the product has.
  final String title;

  /// The event's sport, which selects the fallback artwork and the overlay
  /// mark. Null draws neither — a flat well and no overlay.
  final DabblerSport? sport;

  /// An explicit cover image, taking precedence over the sport artwork.
  ///
  /// Any widget: an `Image.network` for a user-uploaded cover, a
  /// [DabblerSkeleton] while one loads. It is drawn full-bleed and clipped to
  /// the card's radius, so it should not carry its own corners.
  final Widget? cover;

  /// The event's date and time, **already formatted** — see the DS-602 seam in
  /// the class doc. Null drops the entry from [metaRow].
  final String? dateTime;

  /// The event's place, already formatted. Null drops the entry from
  /// [metaRow].
  final String? location;

  /// An optional row beneath the metadata — an attendee strip, a join action.
  /// Passed to [DabblerCard.footer].
  final Widget? footer;

  /// Makes the whole card tappable — opening the event. Passed straight to
  /// [DabblerCard.onTap], so the press scale and focus ring are the system's.
  final VoidCallback? onTap;

  /// Whether a tappable card currently accepts input.
  final bool enabled;

  /// The accessible label of a tappable card. Ignored when [onTap] is null.
  final String? semanticLabel;

  /// Fixed width. Null sizes to the incoming constraints.
  ///
  /// The source's `width: 855` is a Figma frame measurement, not a
  /// specification — a card in a list takes its column's width.
  final double? width;

  /// The cover's aspect ratio — [DabblerCardEventGeometry.coverAspectRatio].
  ///
  /// Re-exported rather than redeclared, so a caller composing a cover of its
  /// own reads the same constant the widget does.
  static const double coverAspectRatio =
      DabblerCardEventGeometry.coverAspectRatio;

  /// How many lines a title may take before it ellipses, at this size.
  static const int titleMaxLines = 2;

  /// The gap between a metadata entry's icon and its text —
  /// [DabblerSpacing.iconGap] (6).
  static const double metaIconGap = DabblerSpacing.iconGap;

  /// The gap between the two metadata entries — [DabblerSpacing.stackDefault]
  /// (12), the family's one horizontal rhythm.
  static const double metaEntryGap = DabblerSpacing.stackDefault;

  /// A metadata line's icon — [DabblerSizing.iconSm] (18).
  static const double metaIconSize = DabblerSizing.iconSm;

  /// The title's style at the large size: `.t-headline`, the ramp's own
  /// 17/22 at weight 600.
  ///
  /// The exported node's `--font-size-body` at `fontWeight: 700` is not taken,
  /// because that node is a settings row's label rather than an event's title
  /// — see the class doc. `.t-headline` is the step the ramp names for a
  /// card's leading line, and it carries its weight itself, so nothing is
  /// borrowed on top of it.
  static TextStyle titleStyleFor(TextDirection direction) =>
      DabblerType.headline.resolveForDirection(direction);

  /// The title's style at the two row sizes: `.t-subheadline` at
  /// [DabblerType.bold].
  ///
  /// The precedent is [DabblerCardHouse.nameStyleFor], which takes the same
  /// step and applies the source's own 700 on top of it rather than inventing
  /// a ramp step — the two row cards sit in the same lists as `CardHouse` and
  /// must read as the same size of thing.
  static TextStyle compactTitleStyleFor(TextDirection direction) =>
      DabblerType.subheadline
          .resolveForDirection(direction)
          .copyWith(fontWeight: DabblerType.bold);

  /// The metadata line's style: `.t-footnote`, unmodified — the step
  /// [DabblerCardHouse.metaStyleFor] already uses for a card's second line.
  static TextStyle metaStyleFor(TextDirection direction) =>
      DabblerType.footnote.resolveForDirection(direction);

  /// The imagery for a media box, resolved in the order the class doc states.
  ///
  /// Expands to fill its parent, so the caller decides the box: an
  /// [AspectRatio] on [DabblerCardEventLarge], a [SizedBox] on the two row
  /// sizes. Never throws, and a sport with no registered artwork is a normal
  /// result rather than an error.
  static Widget mediaContent(
    BuildContext context, {
    Widget? cover,
    DabblerSport? sport,
    bool overlay = true,
  }) {
    final DabblerColors colors = DabblerColors.of(context);
    final Widget? art = cover ??
        (sport == null ? null : DabblerSportBackground.maybe(sport));

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        art ?? ColoredBox(color: colors.surfaceGrey),
        if (overlay && sport != null)
          PositionedDirectional(
            start: DabblerCardEventGeometry.overlayInset,
            bottom: DabblerCardEventGeometry.overlayInset,
            child: sportOverlay(colors, sport),
          ),
      ],
    );
  }

  /// The circular sport-mark well drawn over the imagery.
  static Widget sportOverlay(DabblerColors colors, DabblerSport sport) {
    return Container(
      width: DabblerCardEventGeometry.overlayWellSide,
      height: DabblerCardEventGeometry.overlayWellSide,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        shape: BoxShape.circle,
      ),
      child: DabblerSportIcon(
        sport,
        size: DabblerCardEventGeometry.overlayIconSize,
        color: colors.textPrimary,
      ),
    );
  }

  /// The date/time and place line the three sizes share.
  ///
  /// Returns null when both entries are null, so a caller can drop the line
  /// rather than reserve empty height for it. Each entry is [Flexible] and
  /// ellipses independently, which is what keeps a long venue name from
  /// pushing the time off the card.
  static Widget? metaRow(
    TextDirection direction,
    DabblerColors colors, {
    String? dateTime,
    String? location,
  }) {
    final List<Widget> entries = <Widget>[
      if (dateTime != null) _metaEntry('calendar', dateTime, direction, colors),
      if (location != null) _metaEntry('location', location, direction, colors),
    ];
    if (entries.isEmpty) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < entries.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: metaEntryGap),
          entries[i],
        ],
      ],
    );
  }

  /// One icon-and-text metadata entry.
  static Widget _metaEntry(
    String iconName,
    String text,
    TextDirection direction,
    DabblerColors colors,
  ) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          DabblerIcon(
            iconName,
            size: metaIconSize,
            color: colors.textSecondary,
          ),
          const SizedBox(width: metaIconGap),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: metaStyleFor(direction)
                  .copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  /// The title [Text] every size draws, with this family's truncation.
  ///
  /// Declared once so that AC1's truncation rule cannot be restated three
  /// times and drift.
  static Widget titleText(
    String title,
    TextDirection direction,
    DabblerColors colors, {
    required int maxLines,
    required TextStyle style,
  }) {
    return Text(
      title,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      softWrap: maxLines > 1,
      style: style.copyWith(color: colors.textPrimary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final Widget? meta = metaRow(
      direction,
      colors,
      dateTime: dateTime,
      location: location,
    );

    return DabblerCard(
      width: width,
      onTap: onTap,
      enabled: enabled,
      semanticLabel: semanticLabel,
      footer: footer,
      media: AspectRatio(
        aspectRatio: DabblerCardEventGeometry.coverAspectRatio,
        child: mediaContent(context, cover: cover, sport: sport),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          titleText(
            title,
            direction,
            colors,
            maxLines: titleMaxLines,
            style: titleStyleFor(direction),
          ),
          if (meta != null) ...<Widget>[
            const SizedBox(height: DabblerSpacing.stackTight),
            meta,
          ],
        ],
      ),
    );
  }
}
