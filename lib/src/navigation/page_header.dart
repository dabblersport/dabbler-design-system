import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/text.dart';
import '../interaction/expanded_hit_area.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// One icon action in a [DabblerPageHeader] — a search or filter button, with
/// an optional count badge (the filter's "3 narrowing filters on").
@immutable
class DabblerPageHeaderAction {
  /// An icon action named [icon] in the icon vocabulary.
  const DabblerPageHeaderAction({
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.count = 0,
  });

  /// The glyph's name — `search-normal`, `filter`, `heart`.
  final String icon;

  /// The accessible name. Required: there is no visible label.
  final String semanticLabel;

  /// Tapped. Null draws it disabled.
  final VoidCallback? onPressed;

  /// The count badge. Zero or less draws none.
  final int count;
}

/// A single header icon button on its own: the same 40 `--surface-card` circle
/// in a 1px `--outline-card` hairline (`Listings.dc.html:77-85`) that
/// [DabblerPageHeader] draws for its actions, for a screen whose header row is
/// not a listing's - the Favourites screen's back button
/// (`Favourites.dc.html:10-12`). The 45 target is a hit-test-only area around
/// the circle; the label is required because there is no visible text.
class DabblerPageHeaderButton extends StatelessWidget {
  /// An icon button named [icon] in the icon vocabulary.
  const DabblerPageHeaderButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
  });

  /// The glyph's name — `arrow-circle-left`.
  final String icon;

  /// The accessible name.
  final String semanticLabel;

  /// Tapped. Null draws it disabled.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool enabled = onPressed != null;
    final Widget circle = Container(
      width: DabblerPageHeader.actionDiameter,
      height: DabblerPageHeader.actionDiameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: DabblerIcon(
        icon,
        size: DabblerPageHeader.actionIconSize,
        color: enabled ? colors.textPrimary : colors.textTertiary,
      ),
    );
    return DabblerExpandedHitArea(
      minimum: const Size.square(DabblerSizing.touchTargetMin),
      child: Semantics(
        button: true,
        enabled: enabled,
        label: semanticLabel,
        onTap: onPressed,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: DabblerFocusRing(
            borderRadius: DabblerRadius.pillAll,
            child: DabblerPressScale.gesture(enabled: enabled, child: circle),
          ),
        ),
      ),
    );
  }
}

/// PageHeader — the heading of a listing screen: a display title, a tappable
/// location row beneath it, and outlined icon actions at the inline end.
///
/// Drawn from the Listings frames' header, `Listings.dc.html:60-100`
/// (Games), the same block on Meetups and Venues. Alpha fidelity rebuild,
/// KAN-426: [DabblerNavigationTopBar] deliberately cannot carry a title, so
/// the listing header is its own component rather than a stretch of that one.
///
/// ```dart
/// DabblerPageHeader(
///   title: 'Games',
///   locationLabel: 'Sheikha Fatima Bint Mubarak Street',
///   onLocationPressed: openPicker,
///   actions: <DabblerPageHeaderAction>[
///     DabblerPageHeaderAction(icon: 'search-normal', semanticLabel: 'Search', onPressed: search),
///     DabblerPageHeaderAction(icon: 'filter', semanticLabel: 'Filters', onPressed: filter, count: 3),
///   ],
/// )
/// ```
///
/// ## Anatomy
///
/// | Part | Here |
/// |---|---|
/// | title, display 28/34 | [DabblerType.title1] |
/// | location row: bold `location` glyph in brand, caption, `arrow-circle-down` | [locationLabel] row; absent when [locationLabel] is null |
/// | actions, 40 circles in a 1px hairline (42), gap 6 | a [actionDiameter] `--surface-card` circle with a 45 hit-test-only target |
/// | count badge on an action, 18 brand pill at -3/-3 | [badgeKey], `--color-brand-primary` with on-brand 11 600 |
///
/// ## RTL
///
/// Everything is directional: the title block sits at the inline start and the
/// actions at the inline end; the badge overhangs the inline end.
///
/// ## Accessibility
///
/// The location row is one button named [locationSemanticLabel], or the label
/// itself. An action with a count reads `label, count`.
class DabblerPageHeader extends StatelessWidget {
  /// A header titled [title].
  const DabblerPageHeader({
    super.key,
    required this.title,
    this.locationLabel,
    this.onLocationPressed,
    this.locationSemanticLabel,
    this.actions = const <DabblerPageHeaderAction>[],
    this.safeArea = true,
    this.contentPadding,
  });

  /// The screen title.
  final String title;

  /// The current location, already localised. Null hides the row.
  final String? locationLabel;

  /// Tapped on the location row.
  final VoidCallback? onLocationPressed;

  /// The location row's accessible name; defaults to [locationLabel].
  final String? locationSemanticLabel;

  /// Icon actions, in reading order.
  final List<DabblerPageHeaderAction> actions;

  /// Whether to pad the block start by the device's top inset.
  final bool safeArea;

  /// Overrides [padding] — the collapsing listing header (Listings design,
  /// 2026-10-08) pads the title row `6 18 10` and nudges its end by 2 (games,
  /// meetups) or 3 (venues): see [listingPadding] and [listingVenuesPadding].
  final EdgeInsetsGeometry? contentPadding;

  /// The gutter — `padding: 6px 18px 12px` (`Listings.dc.html:60`).
  static const EdgeInsetsDirectional padding = EdgeInsetsDirectional.fromSTEB(
    DabblerSpacing.space6,
    DabblerSpacing.space2,
    DabblerSpacing.space6,
    DabblerSpacing.space4,
  );

  /// The title row of the collapsing listing header — the tinted header block
  /// pads `6 18 0` and the row carries `margin-bottom: 10` and
  /// `padding-right: 2px` (`Listings.dc.html`, 2026-10-08, games and meetups).
  static const EdgeInsetsDirectional listingPadding =
      EdgeInsetsDirectional.fromSTEB(
        DabblerSpacing.space6,
        DabblerSpacing.space2,
        DabblerSpacing.space6 + 2,
        10,
      );

  /// As [listingPadding] with the venues frame's `padding-right: 3px`.
  static const EdgeInsetsDirectional listingVenuesPadding =
      EdgeInsetsDirectional.fromSTEB(
        DabblerSpacing.space6,
        DabblerSpacing.space2,
        DabblerSpacing.space6 + DabblerSpacing.space1,
        10,
      );

  /// The badge's minimum width, keeping a single digit round.
  static const double badgeMinWidth = DabblerSizing.iconSm;

  /// The action circle — `40px` inside a 1px hairline (`Listings.dc.html:77`).
  static const double actionDiameter = 42;

  /// The action glyph — `size="20"`.
  static const double actionIconSize = 20;

  /// The count badge's offset — `top: -3px; right: -3px`.
  static const double badgeInset = DabblerSpacing.space1;

  /// The count badge's inline padding — `padding: 0 5px`.
  static const double badgePadding = 5;

  /// The location pin — `size="13"` (`Listings.dc.html:68`).
  static const double locationIconSize = 13;

  /// The location row's gap — `gap: 4px`.
  static const double locationGap = 4;

  /// Finds the count badge in a test.
  static const Key badgeKey = ValueKey<String>('dabbler-page-header-badge');

  Widget _location(BuildContext context, DabblerColors colors) {
    final Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DabblerIcon(
          'location',
          weight: DabblerIconWeight.bold,
          size: locationIconSize,
          color: colors.brandPrimary,
        ),
        const SizedBox(width: locationGap),
        Flexible(
          child: DabblerText(
            locationLabel!,
            // `11/14 500` (`Listings.dc.html:70`) — `.t-tag-tight` at medium.
            style: DabblerType.tagTight,
            weight: DabblerTextWeight.medium,
            tone: DabblerTextTone.secondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: locationGap),
        DabblerIcon(
          'arrow-circle-down',
          size: DabblerSizing.iconXs,
          color: colors.textSecondary,
        ),
      ],
    );
    return Semantics(
      button: true,
      label: locationSemanticLabel ?? locationLabel,
      excludeSemantics: true,
      onTap: onLocationPressed,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onLocationPressed,
        child: DabblerFocusRing(
          borderRadius: DabblerRadius.smAll,
          child: DabblerPressScale.gesture(
            enabled: onLocationPressed != null,
            child: row,
          ),
        ),
      ),
    );
  }

  Widget _action(BuildContext context, DabblerPageHeaderAction a) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool enabled = a.onPressed != null;
    // `width: 40px; height: 40px` inside a 1px `--outline-card` hairline on
    // `--surface-card`, `--radius-pill` (`Listings.dc.html:77-85`): a 42
    // circle. The 45 target is a hit-test-only area around it.
    final Widget circle = Container(
      width: actionDiameter,
      height: actionDiameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: DabblerIcon(
        a.icon,
        size: actionIconSize,
        color: enabled ? colors.textPrimary : colors.textTertiary,
      ),
    );
    // The hit area is the outermost box, so no 42-wide ancestor rejects the
    // margin before it is reached.
    Widget button = DabblerExpandedHitArea(
      minimum: const Size.square(DabblerSizing.touchTargetMin),
      child: Semantics(
        button: true,
        enabled: enabled,
        label: a.count > 0 ? '${a.semanticLabel}, ${a.count}' : a.semanticLabel,
        onTap: a.onPressed,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: a.onPressed,
          child: DabblerFocusRing(
            borderRadius: DabblerRadius.pillAll,
            child: DabblerPressScale.gesture(enabled: enabled, child: circle),
          ),
        ),
      ),
    );
    if (a.count <= 0) return button;
    button = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        button,
        PositionedDirectional(
          top: -badgeInset,
          end: -badgeInset,
          child: IgnorePointer(
            child: Container(
              key: badgeKey,
              height: badgeMinWidth,
              constraints: const BoxConstraints(minWidth: badgeMinWidth),
              padding: const EdgeInsets.symmetric(horizontal: badgePadding),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.brandPrimary,
                borderRadius: DabblerRadius.pillAll,
              ),
              child: Text(
                '${a.count}',
                maxLines: 1,
                style: DabblerType.tag
                    .resolveForDirection(direction)
                    .copyWith(color: colors.onBrand),
              ),
            ),
          ),
        ),
      ],
    );
    return button;
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Widget row = Padding(
      padding: contentPadding ?? padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: DabblerSpacing.space2,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: DabblerSpacing.space1,
              children: <Widget>[
                DabblerText(
                  title,
                  style: DabblerType.title1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (locationLabel != null) _location(context, colors),
              ],
            ),
          ),
          for (final DabblerPageHeaderAction a in actions) _action(context, a),
        ],
      ),
    );
    return safeArea ? SafeArea(bottom: false, child: row) : row;
  }
}
