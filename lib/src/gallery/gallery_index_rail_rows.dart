/// The rail's row language — the filter field, the row itself, its disclosure
/// glyph, and the content pane that shows one documentation page.
///
/// A `part` of `gallery_index.dart` for the reason the rail itself is one
/// (`D-046`): every type here is private, and a part is never exported. It was
/// split out of `gallery_index_rail.dart` when the three-level collapsing rail
/// and its filter were added — that file was at 479 lines against the 500-line
/// rule (`013`) and adding to it would have broken the rule rather than
/// bending it. Nothing moved changed behaviour; [_NavRow] gained a leading
/// glyph and a trailing count, and [_FilterField] is new.
part of 'gallery_index.dart';

/// The filter field at the top of the rail — the reference's own **Filter**.
///
/// ## Why `EditableText` and not a design-system field
///
/// This is gallery chrome, not a screen (`D-046`), and the system's own input
/// components are specimens the gallery *displays* — building the gallery's
/// furniture out of them would make the chrome and the exhibit the same thing,
/// so a regression in one would be invisible in the other.
///
/// [EditableText] is `package:flutter/widgets.dart`, not Material: it is the
/// text-editing mechanism and carries no appearance of its own. Every pixel
/// around it here — the sunken fill, the hairline, the radius, the placeholder
/// — is [DabblerColors] and [DabblerType] (`D-017`). No `TextField`, no
/// `InputDecoration`, no Material selection theme.
class _FilterField extends StatefulWidget {
  const _FilterField({required this.controller});

  /// Owned by the rail, so the query survives a rail rebuild and the rail can
  /// read it without a callback.
  final TextEditingController controller;

  @override
  State<_FilterField> createState() => _FilterFieldState();
}

class _FilterFieldState extends State<_FilterField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_repaint);
    widget.controller.addListener(_repaint);
  }

  @override
  void dispose() {
    _focus.removeListener(_repaint);
    widget.controller.removeListener(_repaint);
    _focus.dispose();
    super.dispose();
  }

  void _repaint() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final TextStyle style = DabblerType.footnote
        .resolveForDirection(direction)
        .copyWith(color: colors.textPrimary);

    return GestureDetector(
      onTap: _focus.requestFocus,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DabblerSpacing.space4,
          vertical: DabblerSpacing.space3,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          border: Border.all(
            color: _focus.hasFocus ? colors.borderStrong : colors.borderDefault,
          ),
          borderRadius: DabblerRadius.smAll,
        ),
        child: Stack(
          children: <Widget>[
            if (widget.controller.text.isEmpty)
              Text(
                'Filter',
                style: style.copyWith(color: colors.textTertiary),
              ),
            EditableText(
              controller: widget.controller,
              focusNode: _focus,
              style: style,
              cursorColor: colors.textPrimary,
              backgroundCursorColor: colors.borderDefault,
              selectionColor: colors.surfaceGrey,
              textDirection: direction,
            ),
          ],
        ),
      ),
    );
  }
}

/// The disclosure triangle on an expandable row.
///
/// Drawn rather than imported: the system's icon foundation is a font with a
/// declared vocabulary, and a rail twisty is not in it. A [CustomPaint]
/// triangle is three points of geometry and needs no vocabulary entry, and it
/// is emphatically not a Material `Icons.arrow_drop_down`.
///
/// The rotation is the state: pointing at the row's start edge when collapsed,
/// a quarter turn down when expanded — so the glyph reads the same in RTL,
/// where "start" is the right.
class _Disclosure extends StatelessWidget {
  const _Disclosure({required this.expanded, required this.color});

  final bool expanded;
  final Color color;

  /// The glyph's box. Small enough to sit inside the row's own line height.
  static const double size = 9;

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: expanded ? 0.25 : 0,
      duration: const Duration(milliseconds: 120),
      child: CustomPaint(
        size: const Size.square(size),
        painter: _TrianglePainter(color),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(size.width * 0.25, 0)
      ..lineTo(size.width * 0.85, size.height / 2)
      ..lineTo(size.width * 0.25, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// One rail row.
///
/// ## The wrap is deliberate, which is the whole point
///
/// At a 288 rail a third-level row has about 252px of text, and the three
/// longest titles — *Telling the user something happened* is the worst at
/// ~280px — do not fit on one line. `cxo` ruled that a two-line row is
/// acceptable and an **accidental** one is not, and left the mechanism here.
///
/// The mechanism chosen is **wrap to at most two lines, then ellipsize**, with
/// the full title always on the [Semantics] node. Two lines because the titles
/// are prose and their tail is what distinguishes them (*Telling the user
/// something happened* versus *Nothing to show*) — a one-line ellipsis would
/// cut exactly the distinguishing half. The ellipsis is the floor under it, so
/// a longer title added tomorrow degrades visibly rather than silently
/// clipping, and a screen reader is never given the truncated string.
///
/// ## The leading glyph marks a level, not a decoration
///
/// The reference draws a small leading mark on GROUP rows and none on PAGE
/// rows, which is how a reader tells a collection from a document at a glance.
/// Here the same mark is the disclosure state, so one glyph carries both
/// facts. [expanded] `null` means this row does not collapse and draws no
/// glyph — every page row, and the two top-level destinations.
class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.detail,
    this.emphasised = false,
    this.indented = false,
    this.expanded,
    this.depth = 0,
  });

  final String label;

  /// A second line under [label] — a group's authored tagline. Held to the
  /// same two-line rule as the label itself.
  final String? detail;
  final bool selected;
  final VoidCallback onTap;

  /// A group heading or a top-level destination: ink rather than soft ink.
  final bool emphasised;

  /// A leaf under a group. Kept as its own flag rather than folded into
  /// [depth] so existing call sites read unchanged.
  final bool indented;

  /// Whether this row's children are showing, or `null` where the row has no
  /// children and therefore no glyph.
  final bool? expanded;

  /// Extra indent steps, one [DabblerSpacing.space4] each. The third level of
  /// a three-level rail sits at `depth: 1` under a group at `depth: 0`.
  final int depth;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final Color ink = selected || emphasised
        ? colors.textPrimary
        : colors.textSecondary;

    final Widget text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: DabblerType.footnote
              .resolveForDirection(direction)
              .copyWith(
                color: ink,
                fontWeight: selected || emphasised
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
        ),
        if (detail != null)
          Text(
            detail!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: DabblerType.caption2
                .resolveForDirection(direction)
                .copyWith(color: colors.textTertiary, height: 1.4),
          ),
      ],
    );

    return _Pressable(
      onTap: onTap,
      // The untruncated strings, so an ellipsis is never what a screen reader
      // is given.
      semanticLabel: detail == null ? label : '$label. $detail',
      builder: (BuildContext context, bool pressed) => AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        padding: EdgeInsetsDirectional.fromSTEB(
          (indented ? DabblerSpacing.space4 : DabblerSpacing.space3) +
              depth * DabblerSpacing.space4,
          DabblerSpacing.space2,
          DabblerSpacing.space3,
          DabblerSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: pressed || selected ? colors.surfaceSunken : null,
          borderRadius: DabblerRadius.smAll,
        ),
        child: expanded == null
            ? text
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    // Aligns the glyph's centre with the first line's
                    // x-height rather than its top.
                    padding: const EdgeInsets.only(top: 4),
                    child: _Disclosure(expanded: expanded!, color: ink),
                  ),
                  const SizedBox(width: DabblerSpacing.space2),
                  Expanded(child: text),
                ],
              ),
      ),
    );
  }
}

/// One documentation page in the content pane.
///
/// The render itself is [DabblerDocPageView], which already existed and is not
/// restyled here (`D-041(c)4`); this is the loading seam around it, and it is
/// the WHOLE of what `KAN-327` asks for, not half of it. The separate
/// `GalleryDocPage` screen that ticket first produced was deleted once this
/// landed: it was never referenced, and pushing it would have put a second
/// doc-page renderer in one gallery — `D-053(b)`'s defect shape one level up
/// — over a rail the reader had just used, which `D-045` rules out by
/// construction.
class _DocPane extends StatefulWidget {
  const _DocPane({
    super.key,
    required this.entry,
    required this.loader,
    required this.resolver,
  });

  final _DocOrderEntry entry;
  final DabblerDocLoader loader;
  final DabblerDocSpecimenResolver resolver;

  @override
  State<_DocPane> createState() => _DocPaneState();
}

class _DocPaneState extends State<_DocPane> {
  late final Future<DabblerDocPage> _page = widget.loader.load(
    widget.entry.page,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DabblerDocPage>(
      future: _page,
      builder: (BuildContext context, AsyncSnapshot<DabblerDocPage> snapshot) {
        final DabblerDocPage? page = snapshot.data;
        if (page == null) {
          // A frame or two: the corpus is in the bundle, so this resolves
          // immediately in practice. Never a Material progress indicator.
          return const SizedBox(height: DabblerSpacing.space11);
        }
        return DabblerDocPageView(page: page, resolver: widget.resolver);
      },
    );
  }
}
