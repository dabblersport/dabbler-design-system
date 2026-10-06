import 'package:flutter/widgets.dart';

import '../cards/card.dart';
import '../cards/card_event_listing.dart';
import '../tokens/dabbler_geometry.dart';
import 'skeleton.dart';

/// Which listing card a [DabblerListingSkeleton] stands in for.
enum DabblerListingSkeletonKind {
  /// The game card's placeholder (`Listings.dc.html:175-190`).
  game,

  /// The meetup card's placeholder (`Listings.dc.html:486-503`).
  meetup,

  /// The venue card's placeholder (`Listings.dc.html:724-735`).
  venue,
}

/// ListingSkeleton — the loading placeholder for one listing card, in the
/// shape of the card that will replace it.
///
/// The Listings frame draws a different skeleton per listing, each on the
/// listing card's own shell (`--surface-card`, 1px `--outline-card`,
/// `--radius-xl`, `padding: 15`) with `--surface-sunken` blocks:
///
/// | Kind | Blocks |
/// |---|---|
/// | game | a row of a 45² tile (r 12), two lines (52% × 14, 30% × 11, gap 7) and a 64 × 28 block; a 52-tall block (r 12); a 45-tall bar (r 9) — gap 12 |
/// | meetup | a row of two lines (62% × 16, 34% × 11) and a 64 × 24 block; a row of a 36 circle and a 40% × 12 line; a 45-tall bar — gap 12 |
/// | venue | a 160-tall media block, then 58% × 16, 38% × 11 and a 38-tall bar (r 9) — gap 9 |
///
/// Every block is a [DabblerSkeleton] so the pulse, its reduced-motion
/// fallback and the decorative semantics are the skeleton's own.
///
/// ```dart
/// const DabblerListingSkeleton(kind: DabblerListingSkeletonKind.venue)
/// ```
///
/// ## RTL
///
/// Fractional lines start at the inline start, so under Arabic they hug the
/// right edge, as the frame's Arabic copy does.
class DabblerListingSkeleton extends StatelessWidget {
  /// A placeholder for one [kind] card.
  const DabblerListingSkeleton({super.key, required this.kind});

  /// The card it stands in for.
  final DabblerListingSkeletonKind kind;

  /// The venue placeholder's media block — `height: 160px` (`:727`).
  static const double venueMediaHeight = 160;

  /// The game placeholder's middle block — `height: 52px` (`:186`).
  static const double gameBlockHeight = 52;

  /// The trailing block of the game / meetup head row — `width: 64px`.
  static const double headBlockWidth = 64;

  /// Its height on the game card — `28px`; on the meetup card — `24px`.
  static const double gameHeadBlockHeight = 28;

  /// See [gameHeadBlockHeight].
  static const double meetupHeadBlockHeight = DabblerSpacing.space8;

  /// The venue placeholder's bar — `height: 38px`.
  static const double venueBarHeight = 38;

  /// A title line — `16px`, a game title line `14px`, a sub line `11px`, the
  /// meetup face line `12px`.
  static const double titleLine = 16;

  /// See [titleLine].
  static const double gameTitleLine = 14;

  /// See [titleLine].
  static const double subLine = 11;

  /// See [titleLine].
  static const double faceLine = DabblerSpacing.space4;

  /// Line gap in the head column — `gap: 7px`.
  static const double lineGap = 7;

  Widget _line(double fraction, double height) => FractionallySizedBox(
    alignment: AlignmentDirectional.centerStart,
    widthFactor: fraction,
    child: DabblerSkeleton.rect(height: height, radius: DabblerRadius.sm),
  );

  Widget _game() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: DabblerSpacing.stackDefault,
    children: <Widget>[
      Row(
        spacing: DabblerSpacing.stackDefault,
        children: <Widget>[
          const DabblerSkeleton.rect(
            width: DabblerSizing.touchTargetMin,
            height: DabblerSizing.touchTargetMin,
            radius: DabblerRadius.lg,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: lineGap,
              children: <Widget>[
                _line(0.52, gameTitleLine),
                _line(0.30, subLine),
              ],
            ),
          ),
          const DabblerSkeleton.rect(
            width: headBlockWidth,
            height: gameHeadBlockHeight,
            radius: DabblerRadius.sm,
          ),
        ],
      ),
      const DabblerSkeleton.rect(
        height: gameBlockHeight,
        radius: DabblerRadius.lg,
      ),
      const DabblerSkeleton.rect(
        height: DabblerSizing.touchTargetMin,
        radius: DabblerRadius.md,
      ),
    ],
  );

  Widget _meetup() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: DabblerSpacing.stackDefault,
    children: <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DabblerSpacing.stackDefault,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: lineGap,
              children: <Widget>[_line(0.62, titleLine), _line(0.34, subLine)],
            ),
          ),
          const DabblerSkeleton.rect(
            width: headBlockWidth,
            height: meetupHeadBlockHeight,
            radius: DabblerRadius.sm,
          ),
        ],
      ),
      Row(
        spacing: DabblerSpacing.space3,
        children: <Widget>[
          const DabblerSkeleton.circle(width: DabblerSpacing.space10),
          Expanded(child: _line(0.40, faceLine)),
        ],
      ),
      const DabblerSkeleton.rect(
        height: DabblerSizing.touchTargetMin,
        radius: DabblerRadius.md,
      ),
    ],
  );

  Widget _venueBody() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: DabblerSpacing.space3,
    children: <Widget>[
      _line(0.58, titleLine),
      _line(0.38, subLine),
      const DabblerSkeleton.rect(
        height: venueBarHeight,
        radius: DabblerRadius.md,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: DabblerCard(
        variant: DabblerCardVariant.white,
        radius: DabblerCardEventListing.cardRadius,
        padding: DabblerCardEventListing.cardPadding,
        media: kind == DabblerListingSkeletonKind.venue
            ? const DabblerSkeleton.rect(height: venueMediaHeight, radius: 0)
            : null,
        child: switch (kind) {
          DabblerListingSkeletonKind.game => _game(),
          DabblerListingSkeletonKind.meetup => _meetup(),
          DabblerListingSkeletonKind.venue => _venueBody(),
        },
      ),
    );
  }
}
