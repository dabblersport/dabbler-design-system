import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../foundations/icon.dart';
import '../foundations/text.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../surfaces/badge.dart';
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
/// | actions, 40 circles, gap 6 | [DabblerButton.icon] outlined |
/// | count badge on an action | [DabblerBadge] pill at the action's top inline end |
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

  /// The gutter — `padding: 6px 18px 12px` (`Listings.dc.html:60`).
  static const EdgeInsetsDirectional padding = EdgeInsetsDirectional.fromSTEB(
    DabblerSpacing.space6,
    DabblerSpacing.space2,
    DabblerSpacing.space6,
    DabblerSpacing.space4,
  );

  /// The badge's minimum width, keeping a single digit round.
  static const double badgeMinWidth = DabblerSizing.iconSm;

  /// Finds the count badge in a test.
  static const Key badgeKey = ValueKey<String>('dabbler-page-header-badge');

  Widget _location(BuildContext context, DabblerColors colors) {
    final Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DabblerIcon(
          'location',
          weight: DabblerIconWeight.bold,
          size: DabblerSizing.iconXs,
          color: colors.brandPrimary,
        ),
        const SizedBox(width: DabblerSpacing.space1),
        Flexible(
          child: DabblerText(
            locationLabel!,
            style: DabblerType.caption2,
            tone: DabblerTextTone.secondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: DabblerSpacing.space1),
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

  Widget _action(DabblerPageHeaderAction a) {
    final Widget button = DabblerButton.icon(
      icon: a.icon,
      semanticLabel: a.count > 0
          ? '${a.semanticLabel}, ${a.count}'
          : a.semanticLabel,
      tone: DabblerButtonTone.outlined,
      onPressed: a.onPressed,
    );
    if (a.count <= 0) return button;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        button,
        PositionedDirectional(
          top: -DabblerSpacing.space1,
          end: -DabblerSpacing.space1,
          child: IgnorePointer(
            child: DabblerBadge(
              key: badgeKey,
              label: '${a.count}',
              tone: DabblerBadgeTone.pill,
              minWidth: badgeMinWidth,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Widget row = Padding(
      padding: padding,
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
          for (final DabblerPageHeaderAction a in actions) _action(a),
        ],
      ),
    );
    return safeArea ? SafeArea(bottom: false, child: row) : row;
  }
}
