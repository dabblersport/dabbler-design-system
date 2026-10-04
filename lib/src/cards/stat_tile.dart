import 'package:flutter/widgets.dart';

import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_palette.dart';
import '../tokens/dabbler_type.dart';
import 'stat_tile_value.dart';

/// The grid footprint and value type scale of a [DabblerStatTile].
///
/// `StatTile.jsx` `SIZES` (live design project, `components/cards/StatTile.jsx`
/// lines 15-17): small `2x1`, hero `4x2`, wide `6x2`.
enum DabblerStatTileSize {
  /// 2 columns by 1 row, value 26/30, padding 12.
  small(span: 2, rows: 1, padding: 12, valueSize: 26, valueLeading: 30),

  /// 4 columns by 2 rows, value 46/48, padding 15.
  hero(span: 4, rows: 2, padding: 15, valueSize: 46, valueLeading: 48),

  /// 6 columns by 2 rows, value 22/26, padding 15.
  wide(span: 6, rows: 2, padding: 15, valueSize: 22, valueLeading: 26),

  /// The Details screens' fact tile (`Details.dc.html:93-107`): 3 columns by
  /// 1 row by default, padding 15, a **sans** value at 20/25 bold over an
  /// 11/15 caption in the tone's muted ink. Unlike the profile sizes the
  /// value is not a display numeral, so it reads as a fact ("7:30 PM",
  /// "Open until 11 PM") rather than a score.
  detail(span: 3, rows: 1, padding: 15, valueSize: 20, valueLeading: 25);

  const DabblerStatTileSize({
    required this.span,
    required this.rows,
    required this.padding,
    required this.valueSize,
    required this.valueLeading,
  });

  /// Grid columns the tile spans by default.
  final int span;

  /// Grid rows the tile spans by default.
  final int rows;

  /// Inner padding on every edge.
  final double padding;

  /// The tile's corner: 18 on the profile sizes, 12 on [detail] — the
  /// Details screens draw their tiles at `--radius-lg`
  /// (`Details.dc.html:97`).
  BorderRadius get radius =>
      this == detail ? DabblerRadius.lgAll : DabblerRadius.xlAll;

  /// The value's font size as the source draws it.
  final double valueSize;

  /// The value's line height as the source draws it.
  final double valueLeading;
}

/// The fill treatment of a [DabblerStatTile] — `StatTile.jsx` `TONES`.
enum DabblerStatTileTone {
  /// `--surface-card` with the card outline.
  card,

  /// `--surface-sunken`, no visible outline.
  sunken,

  /// The active theme's brand fill, `onBrand` ink; the art knocks out to white.
  brand,

  /// The ink fill with page-coloured text; the art knocks out to white.
  ink,

  /// `--tile-amber-surface` / `--tile-amber-ink`.
  amber,

  /// `--tile-info-surface` / `--tile-info-ink`.
  info,

  /// `--tile-accent-surface` / `--tile-accent-ink`.
  accent,

  /// The error status surface with its strong ink.
  danger,

  /// The success status surface with its strong ink — the Details venue
  /// "Open until 11 PM" tile (`Details.dc.html:874-876`).
  success,
}

/// StatTile — the bento stat tile used across the profile screens: a large
/// value, a bold caption and an optional sub-line, with optional line art bled
/// off the inline end.
///
/// Ported from the live design project's `components/cards/StatTile.jsx` and
/// `StatTile.d.ts` (design system 1.2.0). The reference renders React; this is
/// the Flutter widget with the same props, driven by injected values only — it
/// owns no data and no navigation.
///
/// ## Interactive
///
/// A tile with [onTap] is a button; with [link] also set it is announced as a
/// link. Either gets the shared focus ring, the shared press scale and
/// Enter/Space activation, and is at least [DabblerSizing.touchTargetMin] tall.
/// [trailing] is pinned to the inline-end top corner (mirrors in RTL) and is
/// excluded from semantics.
///
/// ## Where the port states a type override (all recorded rulings)
///
/// * `small` — `title-1` face (display), size 26 / leading 30, a display-numeral
///   exception on the named step (the ramp has no 26).
/// * `hero` — `large-title` face, size 46 / leading 48, the same exception.
/// * `wide` — `title-2` at its own 22/28; the source's 26 leading is one step
///   from the ramp's 28, so the ramp wins.
/// * label — `footnote` 13/18 at weight 600; sub — `caption-1` 12/16.
/// * The source tracks the value at `-0.01em`. **That is not applied**: no ramp
///   step declares tracking (all are 0) and overrides are limited to size,
///   leading and weight, so the value keeps the step's tracking. This is a
///   recorded reference deviation (a design-source change request), not a
///   package decision to reopen.
///
/// ## Not built
///
/// The source's `art` is a URL; here it is an [ImageProvider] the caller
/// supplies. No asset is bundled.
class DabblerStatTile extends StatefulWidget {
  /// A stat tile.
  const DabblerStatTile({
    super.key,
    required this.value,
    required this.label,
    this.sub,
    this.size = DabblerStatTileSize.small,
    this.tone = DabblerStatTileTone.card,
    this.art,
    this.artOpacity = defaultArtOpacity,
    this.artWidth,
    this.artHeight,
    this.artRight,
    this.artTop,
    this.artFit = BoxFit.contain,
    this.artAlignment = Alignment.center,
    this.span,
    this.rows,
    this.onTap,
    this.link = false,
    this.trailing,
    this.semanticLabel,
    this.icon,
    this.fitValue = false,
    this.minValueScale = DabblerStatTileValue.defaultMinScale,
  });

  /// The large display-font figure.
  final String value;

  /// The bold caption under the value.
  final String label;

  /// An optional third line, in the tone's muted colour.
  final String? sub;

  /// Grid footprint and type scale. Defaults to [DabblerStatTileSize.small].
  final DabblerStatTileSize size;

  /// The fill treatment. Defaults to [DabblerStatTileTone.card].
  final DabblerStatTileTone tone;

  /// Line art bled off the inline end, supplied by the caller.
  final ImageProvider? art;

  /// The art's opacity. `0.32` in the source.
  final double artOpacity;

  /// Overrides the size's art width, as a fraction of the tile's width.
  final double? artWidth;

  /// Overrides the size's art height, as a fraction of the tile's height.
  final double? artHeight;

  /// Overrides the size's art inline-end offset, as a fraction of the width.
  final double? artRight;

  /// Overrides the size's art top offset, as a fraction of the height.
  final double? artTop;

  /// How the art fits its box. `contain` in the source.
  final BoxFit artFit;

  /// Where the art sits in its box. `center` in the source.
  final Alignment artAlignment;

  /// Overrides the size's column span (read by [DabblerStatGrid]).
  final int? span;

  /// Overrides the size's row span (read by [DabblerStatGrid]).
  final int? rows;

  /// Makes the tile interactive: a button with the focus ring, press scale and
  /// keyboard activation.
  final VoidCallback? onTap;

  /// Announces an interactive tile as a link instead of a button — the source's
  /// `href` form.
  final bool link;

  /// Pinned to the inline-end top corner — usually a chevron.
  final Widget? trailing;

  /// A glyph above the value — `Details.dc.html:96-99` draws an 18px linear
  /// icon in the tile's ink over the figure. Typically a [DabblerIcon] at
  /// [DabblerSizing.iconSm]; it inherits the tile's foreground through
  /// [IconTheme] and is decorative (excluded from semantics — the value and
  /// label carry the meaning). Null, the default, draws nothing.
  final Widget? icon;

  /// Scale a too-wide value down to fit instead of clipping it, never below
  /// [minValueScale] — see [DabblerStatTileValue]. Off by default so existing
  /// tiles render exactly as before; turn it on wherever the figure is data
  /// (a count that may grow, a localised number).
  final bool fitValue;

  /// The floor [fitValue] shrinks to, as a fraction of the value's size.
  /// Defaults to [DabblerStatTileValue.defaultMinScale] (0.6).
  final double minValueScale;

  /// The accessible name; defaults to value, label and sub together.
  final String? semanticLabel;

  /// `artOpacity` default in the source.
  static const double defaultArtOpacity = 0.32;

  /// The label's weight — `fontWeight: 600` (`StatTile.jsx:82`).
  static const FontWeight labelWeight = FontWeight.w600;

  /// Art geometry per size as fractions of the tile: width, height, inline-end
  /// offset, top offset — `SIZES[*].art`.
  static ({double width, double height, double right, double top}) artBoxFor(
    DabblerStatTileSize size,
  ) => switch (size) {
    DabblerStatTileSize.small => (
      width: 0.30,
      height: 0.82,
      right: 0.02,
      top: 0.06,
    ),
    DabblerStatTileSize.hero => (
      width: 0.52,
      height: 0.72,
      right: -0.04,
      top: 0.14,
    ),
    DabblerStatTileSize.wide => (
      width: 0.30,
      height: 1.0,
      right: 0.02,
      top: 0.0,
    ),
    DabblerStatTileSize.detail => (
      width: 0.30,
      height: 0.82,
      right: 0.02,
      top: 0.06,
    ),
  };

  /// The tile's effective column span.
  int get effectiveSpan => span ?? size.span;

  /// The tile's effective row span.
  int get effectiveRows => rows ?? size.rows;

  /// Background fill of [tone].
  static Color fillFor(DabblerColors colors, DabblerStatTileTone tone) =>
      switch (tone) {
        DabblerStatTileTone.card => colors.surfaceCard,
        DabblerStatTileTone.sunken => colors.surfaceSunken,
        DabblerStatTileTone.brand => colors.brandPrimary,
        DabblerStatTileTone.ink => colors.textPrimary,
        DabblerStatTileTone.amber => DabblerColors.tileAmber.surface,
        DabblerStatTileTone.info => DabblerColors.tileInfo.surface,
        DabblerStatTileTone.accent => DabblerColors.tileAccent.surface,
        DabblerStatTileTone.danger => colors.error.surface,
        DabblerStatTileTone.success => colors.success.surface,
      };

  /// 1px border colour of [tone].
  static Color borderFor(DabblerColors colors, DabblerStatTileTone tone) =>
      switch (tone) {
        DabblerStatTileTone.card => colors.borderDefault,
        _ => fillFor(colors, tone),
      };

  /// Primary text colour of [tone].
  static Color foregroundFor(DabblerColors colors, DabblerStatTileTone tone) =>
      switch (tone) {
        DabblerStatTileTone.card ||
        DabblerStatTileTone.sunken => colors.textPrimary,
        DabblerStatTileTone.brand => colors.onBrand,
        DabblerStatTileTone.ink => colors.bgPrimary,
        DabblerStatTileTone.amber => DabblerColors.tileAmber.ink,
        DabblerStatTileTone.info => DabblerColors.tileInfo.ink,
        DabblerStatTileTone.accent => DabblerColors.tileAccent.ink,
        DabblerStatTileTone.danger => colors.error.strong,
        DabblerStatTileTone.success => colors.success.strong,
      };

  /// Sub-line colour of [tone] — the source's `sub`.
  static Color subFor(DabblerColors colors, DabblerStatTileTone tone) =>
      switch (tone) {
        DabblerStatTileTone.brand => DabblerPalette.paper.withValues(
          alpha: 0.8,
        ),
        DabblerStatTileTone.ink => colors.bgPrimary.withValues(alpha: 0.7),
        DabblerStatTileTone.amber => DabblerPalette.ink.withValues(alpha: 0.62),
        DabblerStatTileTone.success => colors.success.strong,
        _ => colors.textSecondary,
      };

  /// Whether the art knocks out to white on [tone] (`brand` and `ink`).
  static bool knockoutFor(DabblerStatTileTone tone) =>
      tone == DabblerStatTileTone.brand || tone == DabblerStatTileTone.ink;

  /// The value's text style for [size].
  static TextStyle valueStyleFor(
    DabblerStatTileSize size,
    TextDirection direction,
  ) {
    final DabblerTypeStyle base = switch (size) {
      DabblerStatTileSize.small => DabblerType.title1,
      DabblerStatTileSize.hero => DabblerType.largeTitle,
      DabblerStatTileSize.wide => DabblerType.title2,
      DabblerStatTileSize.detail => DabblerType.headline,
    };
    final TextStyle resolved = base.resolveForDirection(direction);
    if (size == DabblerStatTileSize.wide) return resolved;
    if (size == DabblerStatTileSize.detail) {
      return resolved.copyWith(
        fontSize: size.valueSize,
        height: size.valueLeading / size.valueSize,
        fontWeight: DabblerType.bold,
      );
    }
    return resolved.copyWith(
      fontSize: size.valueSize,
      height: size.valueLeading / size.valueSize,
    );
  }

  @override
  State<DabblerStatTile> createState() => _DabblerStatTileState();
}

class _DabblerStatTileState extends State<DabblerStatTile> {
  bool _pressed = false;
  bool _focused = false;

  bool get _interactive => widget.onTap != null;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  void _setFocused(bool v) {
    if (_focused != v) setState(() => _focused = v);
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final Color fg = DabblerStatTile.foregroundFor(colors, widget.tone);
    final DabblerStatTileSize size = widget.size;

    final Widget text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.icon != null)
          Padding(
            // `gap: 4` in the design's column (`Details.dc.html:95`) is off
            // the base-3 grid. Deviation: the nearest step, `--space-1` (3).
            padding: const EdgeInsetsDirectional.only(
              bottom: DabblerSpacing.space1,
            ),
            child: ExcludeSemantics(
              child: IconTheme.merge(
                data: IconThemeData(color: fg, size: DabblerSizing.iconSm),
                child: widget.icon!,
              ),
            ),
          ),
        if (widget.fitValue)
          DabblerStatTileValue(
            widget.value,
            minScale: widget.minValueScale,
            style: DabblerStatTile.valueStyleFor(
              size,
              direction,
            ).copyWith(color: fg),
          )
        else
          Text(
            widget.value,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: DabblerStatTile.valueStyleFor(
              size,
              direction,
            ).copyWith(color: fg),
          ),
        Text(
          widget.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: size == DabblerStatTileSize.detail
              // The Details fact tile's caption: 11/15 regular in the tone's
              // muted ink (`Details.dc.html:102`).
              ? DabblerType.caption2
                    .resolveForDirection(direction)
                    .copyWith(color: DabblerStatTile.subFor(colors, widget.tone))
              : DabblerType.footnote
                    .resolveForDirection(direction)
                    .copyWith(
                      color: fg,
                      fontWeight: DabblerStatTile.labelWeight,
                    ),
        ),
        if (widget.sub != null)
          Text(
            widget.sub!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DabblerType.caption1
                .resolveForDirection(direction)
                .copyWith(color: DabblerStatTile.subFor(colors, widget.tone)),
          ),
      ],
    );

    final Widget tile = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final ({double width, double height, double right, double top}) a =
            DabblerStatTile.artBoxFor(size);
        final double w = box.hasBoundedWidth ? box.maxWidth : 0;
        final double h = box.hasBoundedHeight ? box.maxHeight : 0;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: DabblerStatTile.fillFor(colors, widget.tone),
            borderRadius: size.radius,
            border: Border.all(
              color: DabblerStatTile.borderFor(colors, widget.tone),
              width: DabblerSizing.borderDefault,
            ),
          ),
          child: ClipRRect(
            borderRadius: size.radius,
            child: Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                if (widget.art != null && w > 0 && h > 0)
                  PositionedDirectional(
                    end: (widget.artRight ?? a.right) * w,
                    top: (widget.artTop ?? a.top) * h,
                    width: (widget.artWidth ?? a.width) * w,
                    height: (widget.artHeight ?? a.height) * h,
                    child: IgnorePointer(
                      child: ExcludeSemantics(
                        child: Opacity(
                          opacity: widget.artOpacity,
                          child: DabblerStatTile.knockoutFor(widget.tone)
                              ? ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                    DabblerPalette.paper,
                                    BlendMode.srcIn,
                                  ),
                                  child: _art(),
                                )
                              : _art(),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(size.padding),
                  // `justifyContent: 'flex-end'` inside `overflow: 'hidden'`:
                  // content taller than the tile (a small tile with a sub-line
                  // is 88 in a 78 row) overflows at the top and is clipped, it
                  // is not an error. [OverflowBox] is that behaviour.
                  child: OverflowBox(
                    alignment: AlignmentDirectional.bottomStart,
                    minHeight: 0,
                    maxHeight: double.infinity,
                    child: text,
                  ),
                ),
                if (widget.trailing != null)
                  PositionedDirectional(
                    top: size.padding,
                    end: size.padding,
                    child: IgnorePointer(
                      child: ExcludeSemantics(
                        child: Opacity(
                          opacity: 0.72,
                          child: IconTheme.merge(
                            data: IconThemeData(color: fg),
                            child: widget.trailing!,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );

    final String name =
        widget.semanticLabel ??
        <String>[
          widget.value,
          widget.label,
          if (widget.sub != null) widget.sub!,
        ].join(', ');

    if (!_interactive) {
      return Semantics(
        container: true,
        label: name,
        child: ExcludeSemantics(child: tile),
      );
    }

    return Semantics(
      button: !widget.link,
      link: widget.link,
      label: name,
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: DabblerSizing.touchTargetMin,
          ),
          child: FocusableActionDetector(
            mouseCursor: SystemMouseCursors.click,
            onShowFocusHighlight: _setFocused,
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (ActivateIntent intent) {
                  widget.onTap?.call();
                  return null;
                },
              ),
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              onTapDown: (TapDownDetails _) => _setPressed(true),
              onTapUp: (TapUpDetails _) => _setPressed(false),
              onTapCancel: () => _setPressed(false),
              child: DabblerFocusRing.visible(
                visible: _focused,
                borderRadius: size.radius,
                child: DabblerPressScale(pressed: _pressed, child: tile),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _art() => Image(
    image: widget.art!,
    fit: widget.artFit,
    alignment: widget.artAlignment,
  );
}

/// StatGrid — the six-column bento the tiles sit in: `repeat(6, 1fr)` columns,
/// `78` row height, `9` gap (`StatTile.jsx` `StatGrid`).
///
/// Children are laid out like CSS grid's default auto-placement: row-major,
/// each tile taking its [DabblerStatTile.effectiveSpan] columns and
/// [DabblerStatTile.effectiveRows] rows at the first free slot at or after the
/// previous tile. Only [DabblerStatTile] children are accepted.
class DabblerStatGrid extends StatelessWidget {
  /// A bento grid of [children].
  const DabblerStatGrid({
    super.key,
    required this.children,
    this.rowExtent = rowHeight,
  });

  /// The tiles.
  final List<DabblerStatTile> children;

  /// Columns — `repeat(6, 1fr)`.
  static const int columns = 6;

  /// The default row height — `gridAutoRows: '78px'`.
  static const double rowHeight = 78;

  /// This grid's row height. Defaults to [rowHeight] (78); the Details
  /// screen's tiles use [detailsRowHeight] (`Details.dc.html:93`). Named
  /// `rowExtent` because the static [rowHeight] is already public API.
  final double rowExtent;

  /// `grid-auto-rows: 100px` — the Details screen's stat grids
  /// (`Details.dc.html:93, 257, 399`).
  static const double detailsRowHeight = 100;

  /// Gap between cells — `gap: 9`.
  static const double gap = DabblerSpacing.space3;

  /// Places [spans] (column, row) into the grid and returns, per item, its
  /// `(column, row)` origin plus the total number of rows used.
  static ({List<(int, int)> origins, int rows}) place(List<(int, int)> spans) {
    final List<List<bool>> taken = <List<bool>>[];
    bool free(int c, int r, int cs, int rs) {
      if (c + cs > columns) return false;
      for (int y = r; y < r + rs; y++) {
        if (y >= taken.length) continue;
        for (int x = c; x < c + cs; x++) {
          if (taken[y][x]) return false;
        }
      }
      return true;
    }

    void mark(int c, int r, int cs, int rs) {
      while (taken.length < r + rs) {
        taken.add(List<bool>.filled(columns, false));
      }
      for (int y = r; y < r + rs; y++) {
        for (int x = c; x < c + cs; x++) {
          taken[y][x] = true;
        }
      }
    }

    final List<(int, int)> origins = <(int, int)>[];
    int cursorRow = 0;
    int cursorCol = 0;
    for (final (int, int) s in spans) {
      final int cs = s.$1.clamp(1, columns);
      final int rs = s.$2 < 1 ? 1 : s.$2;
      int r = cursorRow;
      int c = cursorCol;
      while (!free(c, r, cs, rs)) {
        c++;
        if (c + cs > columns) {
          c = 0;
          r++;
        }
      }
      mark(c, r, cs, rs);
      origins.add((c, r));
      cursorRow = r;
      cursorCol = c + cs;
      if (cursorCol >= columns) {
        cursorCol = 0;
        cursorRow = r + 1;
      }
    }
    return (origins: origins, rows: taken.length);
  }

  @override
  Widget build(BuildContext context) {
    final ({List<(int, int)> origins, int rows}) layout = place(<(int, int)>[
      for (final DabblerStatTile t in children)
        (t.effectiveSpan, t.effectiveRows),
    ]);
    final double height = layout.rows == 0
        ? 0
        : layout.rows * rowExtent + (layout.rows - 1) * gap;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double cell = (box.maxWidth - (columns - 1) * gap) / columns;
        return SizedBox(
          width: box.maxWidth,
          height: height,
          child: Stack(
            children: <Widget>[
              for (int i = 0; i < children.length; i++)
                PositionedDirectional(
                  start: layout.origins[i].$1 * (cell + gap),
                  top: layout.origins[i].$2 * (rowExtent + gap),
                  width:
                      children[i].effectiveSpan * cell +
                      (children[i].effectiveSpan - 1) * gap,
                  height:
                      children[i].effectiveRows * rowExtent +
                      (children[i].effectiveRows - 1) * gap,
                  child: children[i],
                ),
            ],
          ),
        );
      },
    );
  }
}
