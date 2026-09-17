/// Rating — the star rating primitive, read-only or interactive.
///
/// Built from the rendered specimen
/// `components/surfaces/identity-status.card.html` → *"Ratings — evaluation"*
/// and its source `components/surfaces/Rating.jsx`. **No ticket asked for this
/// component**; the design draws it, so it is built. See the class doc.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// The three star sizes of `Rating.jsx`: `{ sm: 18, md: 24, lg: 30 }`.
///
/// The specimen's own token table names them as such — *"18 · 24 · 30 —
/// `sm` / `md` / `lg` star size"* — and all three land exactly on the icon
/// ramp, so each step is expressed through [DabblerSizing] rather than as a
/// literal.
enum DabblerRatingSize {
  /// 18px — [DabblerSizing.iconSm]. *"`sm` inside cards."*
  sm(DabblerSizing.iconSm),

  /// 24px — [DabblerSizing.iconMd]. The default.
  md(DabblerSizing.iconMd),

  /// 30px — [DabblerSizing.iconLg]. *"`lg` in a review sheet."*
  lg(DabblerSizing.iconLg);

  const DabblerRatingSize(this.starSize);

  /// The star's side in logical pixels.
  final double starSize;
}

/// Rating — a score, shown or collected.
///
/// ```dart
/// const DabblerRating(value: 4.2, count: 128, showValue: true,
///     size: DabblerRatingSize.sm);              // read-only
/// DabblerRating(value: rating, onChanged: setRating);  // interactive
/// ```
///
/// ## Passing [onChanged] is what makes it interactive
///
/// That is the source's rule verbatim (`Rating.jsx`: *"Passing `onChange` is
/// what makes it interactive"*), and it is the only switch: there is no
/// `readOnly` flag and no `interactive` flag to disagree with it.
///
/// ## Halves are clipped, never drawn
///
/// A fractional value fills the star by **clipping a bold star over the linear
/// one** to the exact fraction. `Rating.jsx` is explicit about why: *"there is
/// no such glyph in Iconsax and hand-drawn SVG is not allowed."* Any fraction
/// works, not only `.5`. The clip is anchored at the **inline start** by
/// [_StarFractionClipper], so under `rtl` the star fills from the right exactly
/// as `inset-inline-start` does on the web.
///
/// A star that is *wholly* filled is the bold glyph on its own, with no empty
/// glyph beneath it — see [_DabblerRatingState._star] for why stacking both,
/// which is what the web does, draws a grey rim here that the design has not.
///
/// ## Colours
///
/// | part | source | here |
/// |---|---|---|
/// | filled star | `--color-status-warning`, bold | `colors.warning.base` |
/// | empty star | `--color-text-tertiary`, linear | `colors.textTertiary` |
/// | value / count | `--color-text-secondary` | `colors.textSecondary` |
///
/// `--color-status-warning` is the **bare** indicator, which is
/// [DabblerStatusColor.base] — not `-surface` and not `-strong`. It shifts per
/// theme, which the specimen's token table calls out. Measured on the rendered
/// specimen it is `rgb(245, 158, 11)`, which is [DabblerPalette.warning500]
/// (`#F59E0B`) exactly: the filled star matches the drawing byte for byte.
///
/// ### One knowing deviation: the empty star is darker here
///
/// The specimen draws the empty star at `#B8B0A0` — measured
/// `rgb(184, 176, 160)` — because on the web `--color-text-tertiary` resolves
/// through `--t-text-3` to `--subtle` (`tokens/colors.css:39,70,120`). **This
/// system deliberately paints `#8C8C8C` for that role instead**:
/// `DECISIONS.md` **D-003(a)** demoted `--subtle` out of every light-brightness
/// text role at 2.15:1 contrast, and `test/tokens/no_subtle_as_text_test.dart`
/// enforces it.
///
/// So the empty star is a colder, darker grey than the drawing. That is the
/// **ruling** disagreeing with the drawing, not this widget disagreeing with
/// either, and it is reported rather than worked around — reaching past
/// [DabblerColors.textTertiary] to [DabblerPalette.subtle] here would evade an
/// accessibility decision to win a screenshot. If `cxo` rules for the drawing,
/// the fix is in the token layer and this widget does not change at all.
///
/// ## It rendered inverted while it was being built, and that was not this file
///
/// The first build of this widget drew the filled star as an amber **outline**
/// and the empty one as a **solid** grey — the exact reverse of the drawing.
/// The cause was [DabblerIconRegistry.keyFor], which had `linear` and `bold`
/// mapped to the wrong `Iconsax` keys and so drew every icon in the package at
/// the wrong weight. That was corrected on 2026-09-17 and this widget needed no
/// change: the weights named here have always been the ones the design asks for
/// (`bold` filled, `linear` empty). Recorded because the next weight oddity
/// seen here is far likelier to be the registry than the Rating.
///
/// ## Not a ticket
///
/// Nothing in the built backlog asked for a Rating. It is drawn on the identity
/// specimen with a full variant set, an accessibility contract and a token
/// table, and the fidelity brief's rule is that the drawing is the spec, so it
/// is implemented here and reported as unasked-for scope.
class DabblerRating extends StatefulWidget {
  /// A rating showing [value] out of [max].
  const DabblerRating({
    super.key,
    this.value = 0,
    this.max = 5,
    this.onChanged,
    this.size = DabblerRatingSize.md,
    this.count,
    this.showValue = false,
    this.label = 'Rating',
  })  : assert(max > 0, 'a rating needs at least one star'),
        assert(value >= 0, 'a rating cannot be negative');

  /// The score. Fractional values are drawn by clipping — see the class doc.
  final double value;

  /// How many stars. `5` in the source.
  final int max;

  /// Called with the picked star (1-based) when the rating is collected.
  ///
  /// **Non-null is what makes the widget interactive.** Null renders the
  /// read-only form.
  final ValueChanged<int>? onChanged;

  /// The star size. Defaults to [DabblerRatingSize.md].
  final DabblerRatingSize size;

  /// The number of ratings behind an average, rendered as `(128)`.
  ///
  /// *"Show `count` whenever the value is an average."*
  final int? count;

  /// Whether to print the value itself, to one decimal (`value.toFixed(1)`).
  final bool showValue;

  /// The group's accessible name. Read-only announces
  /// `"<label>: <value> of <max>"`, once, rather than as [max] images.
  final String label;

  /// The gap between the stars when the rating is **read-only** —
  /// `var(--space-1)` (`Rating.jsx`), i.e. [DabblerSpacing.space1] (3).
  ///
  /// Interactive mode uses `0`: the gap is already inside each star's
  /// [DabblerSizing.touchTargetMin] box.
  static const double readOnlyGap = DabblerSpacing.space1;

  /// The gap before the value/count text — `marginInlineStart: var(--space-2)`,
  /// i.e. [DabblerSpacing.space2] (6).
  static const double trailingGap = DabblerSpacing.space2;

  /// The Iconsax glyph both stars are drawn from, in either weight.
  ///
  /// `star` is the name the specimen's token table gives — *"filled stars
  /// (bold Iconsax `star`)"* — and it is kept even though the two fonts draw
  /// its bold weight differently. **Iconsax's bold `star` is not a plain solid
  /// star in either font:** it carries a streak. The web font cuts the streak
  /// out of the silhouette as a white slash; `iconsax_flutter` draws it as
  /// three short dashes sitting outside the star's leading edge. Same named
  /// glyph, different drawing of it.
  ///
  /// `iconsax_flutter` also ships a second pair, `star-1` / `star-1_copy`,
  /// which may be the plain star. It is **not** substituted here: the design
  /// asks for `star`, and [DabblerIcon]'s own rule is to *"always ask for the
  /// name the design wants, never hard-code a stand-in"*. Reported for `cxo`;
  /// if the plain star is wanted, that is a one-word change to this constant.
  static const String glyph = 'star';

  @override
  State<DabblerRating> createState() => _DabblerRatingState();
}

class _DabblerRatingState extends State<DabblerRating> {
  /// The star the pointer is previewing, 1-based, or null.
  ///
  /// `Rating.jsx` previews on hover and clears on leave; the shown value is
  /// `hover ?? value`.
  int? _hover;
  bool _focused = false;

  bool get _interactive => widget.onChanged != null;

  double get _shown => _hover?.toDouble() ?? widget.value;

  void _change(int next) =>
      widget.onChanged?.call(next.clamp(1, widget.max));

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (_interactive && event is! KeyUpEvent) {
      final int current = widget.value.round();
      switch (event.logicalKey) {
        // The source moves by one on either axis in each direction.
        case LogicalKeyboardKey.arrowRight:
        case LogicalKeyboardKey.arrowUp:
          _change(current + 1);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.arrowDown:
          _change(current == 0 ? 1 : current - 1);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.space:
        case LogicalKeyboardKey.enter:
          _change(current == 0 ? 1 : current);
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  /// One star: the linear glyph, with the bold glyph clipped over it to
  /// [fill] of its width.
  Widget _star(int index, DabblerColors colors) {
    final double side = widget.size.starSize;
    final double fill = (_shown - index).clamp(0, 1);
    final Widget bold = DabblerIcon(
      DabblerRating.glyph,
      weight: DabblerIconWeight.bold,
      size: side,
      color: colors.warning.base,
    );

    // A whole star is the bold glyph alone. The empty glyph underneath it would
    // only show as a grey rim: `iconsax_flutter`'s solid star sits marginally
    // inside its outline one, where the web font's covers it, so stacking both
    // — which is what `Rating.jsx` does — draws a halo the design does not.
    // Same result, drawn the way it looks.
    if (fill >= 1) return bold;

    return SizedBox(
      width: side,
      height: side,
      child: Stack(
        children: <Widget>[
          DabblerIcon(
            DabblerRating.glyph,
            size: side,
            color: colors.textTertiary,
          ),
          if (fill > 0)
            // Clipped to the exact fraction, anchored at the inline start, so
            // it mirrors under RTL as `inset-inline-start` does. A clipper
            // rather than `Align(widthFactor:)`: inside a [Stack] the align
            // box takes the incoming constraints and the factor is lost, which
            // left the bold glyph a hair out of register with the outline one.
            ClipRect(
              clipper: _StarFractionClipper(
                fraction: fill,
                direction: Directionality.of(context),
              ),
              child: bold,
            ),
        ],
      ),
    );
  }

  /// An interactive star: the glyph centred in a full touch target.
  Widget _target(int index, DabblerColors colors) {
    final int oneBased = index + 1;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: widget.value.round() == oneBased,
      label: '$oneBased',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = oneBased),
        onExit: (_) => setState(() => _hover = null),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _change(oneBased),
          child: SizedBox(
            // `--touch-target-min` per star, the source's own note.
            width: DabblerSizing.touchTargetMin,
            height: DabblerSizing.touchTargetMin,
            child: Center(child: _star(index, colors)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);

    final List<Widget> stars = <Widget>[
      for (int i = 0; i < widget.max; i++)
        if (_interactive) _target(i, colors) else _star(i, colors),
    ];

    final String? trailing = _trailingText();

    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < stars.length; i++) ...<Widget>[
          if (i > 0 && !_interactive)
            const SizedBox(width: DabblerRating.readOnlyGap),
          stars[i],
        ],
        if (trailing != null) ...<Widget>[
          const SizedBox(width: DabblerRating.trailingGap),
          Text(
            trailing,
            maxLines: 1,
            style: DabblerType.caption1
                .resolveForDirection(direction)
                .copyWith(color: colors.textSecondary),
          ),
        ],
      ],
    );

    if (!_interactive) {
      // `role="img"` with a full label, announced once rather than as five
      // images — so the stars themselves are excluded.
      return Semantics(
        label: '${widget.label}: ${_plain(widget.value)} of ${widget.max}',
        image: true,
        excludeSemantics: true,
        child: row,
      );
    }

    // One tab stop for the whole group, arrows to change — the source's
    // `role="radiogroup"` contract.
    row = DabblerFocusRing.visible(
      visible: _focused,
      borderRadius: DabblerRadius.smAll,
      child: row,
    );
    return Semantics(
      label: widget.label,
      container: true,
      child: Focus(
        onKeyEvent: _onKey,
        onFocusChange: (bool has) => setState(() => _focused = has),
        child: row,
      ),
    );
  }

  /// `value.toFixed(1)` and/or `(count)`, joined by a space when both show —
  /// `Rating.jsx`'s exact composition.
  String? _trailingText() {
    if (!widget.showValue && widget.count == null) return null;
    final StringBuffer out = StringBuffer();
    if (widget.showValue) out.write(widget.value.toStringAsFixed(1));
    if (widget.count != null) {
      if (widget.showValue) out.write(' ');
      out.write('(${widget.count})');
    }
    return out.toString();
  }

  /// The value as the source's template literal prints it in the label:
  /// `${value}`, so `4` reads "4" and `4.2` reads "4.2" — not "4.0".
  String _plain(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

/// Clips a star to [fraction] of its width from the **inline start**.
///
/// `Rating.jsx` draws a partial star as `width: <fraction>%` on a container
/// with `inset-inline-start: 0` and `overflow: hidden`. This is that rule, with
/// the anchor taken from [direction] so the fill grows rightward under `ltr`
/// and leftward under `rtl` rather than always from the left edge.
class _StarFractionClipper extends CustomClipper<Rect> {
  const _StarFractionClipper({required this.fraction, required this.direction});

  /// How much of the star is filled, `0..1`.
  final double fraction;

  /// Which edge the fill grows from.
  final TextDirection direction;

  @override
  Rect getClip(Size size) {
    final double width = size.width * fraction;
    return direction == TextDirection.rtl
        ? Rect.fromLTWH(size.width - width, 0, width, size.height)
        : Rect.fromLTWH(0, 0, width, size.height);
  }

  @override
  bool shouldReclip(_StarFractionClipper old) =>
      old.fraction != fraction || old.direction != direction;
}
